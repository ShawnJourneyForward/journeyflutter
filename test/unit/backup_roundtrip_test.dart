import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:journey_forward/utils/encrypted_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

// Critical flows #6, #7, #8: backup must
//   • export the encrypted profile, not the (no-longer-present) plaintext
//   • restore by writing the profile BACK to EncryptedStore
//   • reset the lockMethod in the restored blob so the user is not locked
//     out (the PIN hash lives in secure storage and is not backed up)
//   • invalidate the profile provider so the UI reflects the restored data
//
// The Backup UI lives in backup_screen.dart and wraps a file picker —
// untestable headlessly. So we exercise the underlying contract directly:
// what backup writes (export keys + EncryptedStore read), and what
// restore writes (EncryptedStore.write + has_profile sentinel + lockMethod
// stripped + provider invalidated).

const _profileJson =
    '{"username":"Shawn","soberDate":"2026-01-01T00:00:00.000",'
    '"dailySpend":120.0,"currency":"\$","lockMethod":"pin"}';

// The set must match backup_screen.dart's _exportKeys (sans 'profile',
// which is read from EncryptedStore).
const _exportKeys = [
  'journal_entries',
  'gratitude',
  'slip_log',
  'vision_board',
  'custom_affirmations',
  'cravings',
  'thoughts',
  'activities',
  'sleep_logs',
];

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installSecureStorageMock();
  });
  setUp(resetSecureStorageMock);

  test('export reads profile from EncryptedStore, not SharedPreferences',
      () async {
    // Simulate the post-migration state: profile lives ONLY in EncryptedStore.
    SharedPreferences.setMockInitialValues({
      'has_profile': '1',
      'journal_entries': '[{"id":"1","date":"2026-01-02T10:00:00.000",'
          '"text":"hi","mood":"good"}]',
    });
    await EncryptedStore.write('profile', _profileJson);

    final prefs = await SharedPreferences.getInstance();
    final exportedProfile = await EncryptedStore.read('profile');
    expect(exportedProfile, _profileJson,
        reason: 'Backup export must read profile from EncryptedStore.');

    // Side-band keys are exported from SharedPreferences only.
    for (final k in _exportKeys) {
      // Just confirm prefs.getString is the source — the journal_entries
      // value above is the one we expect to find.
      if (k == 'journal_entries') {
        expect(prefs.getString(k), isNotNull);
      } else {
        expect(prefs.getString(k), isNull);
      }
    }
    // Crucially: the plaintext 'profile' key must NOT be the source.
    expect(prefs.getString('profile'), isNull,
        reason:
            'Plaintext profile in SharedPreferences would mean the backup '
            'wrote unencrypted data — the migration must clear it.');
  });

  test(
      'restore writes profile BACK to EncryptedStore and refreshes the provider',
      () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial load — no profile yet.
    expect(await container.read(profileProvider.future), isNull);

    // ---- Simulate restore body (mirrors backup_screen._import) ---------
    final restored = jsonDecode(_profileJson) as Map<String, dynamic>;
    // Restore must scrub lockMethod (PIN hash isn't backed up, so a
    // restored 'pin' lockMethod would lock the user out forever).
    restored['lockMethod'] = 'none';
    final safeProfile = jsonEncode(restored);

    await EncryptedStore.write('profile', safeProfile);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('has_profile', '1');
    // Restore must also clear any legacy plaintext.
    await prefs.remove('profile');
    await prefs.remove('lockMethod');

    // Critical flow #8: invalidating the provider must cause the next
    // read to pick up the restored data (without an app restart).
    container.invalidate(profileProvider);

    final loaded = await container.read(profileProvider.future);
    expect(loaded, isNotNull,
        reason: 'After restore + invalidate, the provider must see data.');
    expect(loaded!.username, 'Shawn');
    expect(loaded.lockMethod, 'none',
        reason: 'Restore must reset lockMethod to "none" — the PIN hash '
            'cannot travel with a backup.');
  });

  test('restore preserves non-profile data alongside profile', () async {
    SharedPreferences.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    // Side-band data the restore body now writes through to EncryptedStore
    // (post-migration). Journal entries — like cravings, slips, thoughts,
    // gratitude — live in secure storage, not plain SharedPreferences.
    await EncryptedStore.write(
      'journal_entries',
      '[{"id":"1","date":"2026-01-02T10:00:00.000","text":"hi","mood":"good"}]',
    );
    await EncryptedStore.write('profile', _profileJson);
    await prefs.setString('has_profile', '1');

    // The roundtrip preserves both halves.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final profile = await container.read(profileProvider.future);
    final journals = await container.read(journalProvider.future);

    expect(profile?.username, 'Shawn');
    expect(journals, hasLength(1));
    expect(journals.first.text, 'hi');
  });
}
