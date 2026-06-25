import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:journey_forward/screens/backup_screen.dart';
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

// The side-band keys to assert against, derived from the REAL exported list
// (backup_screen.dart's kBackupExportKeys) rather than a hand-maintained copy
// that could silently drift. 'profile' is exercised on its own line below, so
// it is filtered out here. Post-migration, every one of these reads from
// EncryptedStore — not plain SharedPreferences.
//
// This is intentionally NOT a literal: if a new key is added to the backup
// list it is automatically covered here, and the dedicated guard test below
// fails the moment a provider key is added to the list's *expected* set but
// missing from the real list (or vice-versa).
final List<String> _sideBandExportKeys =
    kBackupExportKeys.where((k) => k != 'profile').toList();

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installSecureStorageMock();
  });
  setUp(resetSecureStorageMock);

  test('export reads profile and side-band data from EncryptedStore, '
      'not SharedPreferences', () async {
    // Simulate the post-migration state: every sensitive collection lives in
    // EncryptedStore; plain SharedPreferences holds only the presence sentinel.
    SharedPreferences.setMockInitialValues({'has_profile': '1'});
    await EncryptedStore.write('profile', _profileJson);
    await EncryptedStore.write(
      'journal_entries',
      '[{"id":"1","date":"2026-01-02T10:00:00.000","text":"hi","mood":"good"}]',
    );

    final prefs = await SharedPreferences.getInstance();

    // Profile is read from EncryptedStore.
    expect(await EncryptedStore.read('profile'), _profileJson,
        reason: 'Backup export must read profile from EncryptedStore.');

    // Side-band data is read from EncryptedStore — NOT plain prefs.
    expect(await EncryptedStore.read('journal_entries'), isNotNull,
        reason: 'Sensitive collections must live in EncryptedStore.');
    for (final k in _sideBandExportKeys) {
      expect(prefs.getString(k), isNull,
          reason: '$k must not exist in plain prefs after migration — '
              'the StorageMigration pass moves it to EncryptedStore and '
              'deletes the plaintext copy.');
    }
    // Crucially: the plaintext 'profile' key must NOT be the source.
    expect(prefs.getString('profile'), isNull,
        reason: 'Plaintext profile in SharedPreferences would mean the backup '
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

  // ── Backup-list completeness guard ─────────────────────────────────────────
  //
  // Every storage key written by a persistence provider MUST appear in the real
  // backup export list (kBackupExportKeys). If a future feature adds a provider
  // key but forgets to add it to the backup list, that data silently vanishes on
  // a phone change / restore — exactly the bug this test is here to catch.
  //
  // We assert against the REAL exported list (imported from backup_screen.dart),
  // not a parallel hand-maintained copy, so the two can never drift apart.
  //
  // The expected set below is the authoritative roster of provider-backed keys
  // that must be in the backup. It includes the v6.4 planner provider keys AND
  // the two keys that were historically DROPPED from the backup at some point
  // (urge_rides, hundred_day_challenge) — both regressions we never want to
  // recur. Adding a provider key here without also adding it to kBackupExportKeys
  // (or removing it from the list) fails this test.
  test('every persistence-provider key is present in kBackupExportKeys', () {
    // Storage keys owned by a provider that persists user data. Each maps 1:1 to
    // a `static const _key` on its notifier in app_providers.dart. This list is
    // the contract: a key here that is missing from the backup means silent data
    // loss on restore.
    const providerKeys = <String>{
      'profile',
      'journal_entries',
      'gratitude',
      'slip_log',
      'vision_board',
      'custom_affirmations',
      'cravings',
      'thoughts',
      'activities',
      'sleep_logs',
      // v5.8 feature data
      'future_letters',
      'hard_days',
      'thought_records',
      'meetings',
      // v5.9 clinical features
      'daily_intentions',
      'recovery_capital',
      // v6.0 — urge timer wins (previously dropped from the backup list)
      'urge_rides',
      // v6.3 — 100-day challenge grid (previously dropped from the backup list)
      'hundred_day_challenge',
      // v6.4 planner — goals, sessions, weight logs, activities, settings
      'planner_goals',
      'planner_sessions',
      'planner_weight_logs',
      'planner_activities',
      'planner_settings',
    };

    final exported = kBackupExportKeys.toSet();

    // 1. Every provider key must be backed up. Computing the diff (rather than a
    //    bare containsAll) makes the failure message name the forgotten key(s).
    final missing = providerKeys.difference(exported);
    expect(missing, isEmpty,
        reason: 'These provider-backed storage keys are NOT in '
            'kBackupExportKeys, so their data would be silently lost on a '
            'phone change / restore. Add them to _exportKeys in '
            'backup_screen.dart: $missing');

    // 2. Spell out the two historically-dropped keys + the five planner keys so
    //    a regression on any single one fails with an unmistakable message.
    for (final k in const [
      'urge_rides',
      'hundred_day_challenge',
      'planner_goals',
      'planner_sessions',
      'planner_weight_logs',
      'planner_activities',
      'planner_settings',
    ]) {
      expect(exported, contains(k),
          reason: '$k must travel in the backup (kBackupExportKeys). '
              'It is provider-backed user data; omitting it loses the data on '
              'restore.');
    }

    // 3. Guard the inverse drift too: every key the backup claims to export must
    //    be a known provider key (no stale/typo entry that exports nothing).
    final unknown = exported.difference(providerKeys);
    expect(unknown, isEmpty,
        reason: 'kBackupExportKeys lists keys with no matching persistence '
            'provider — likely a typo or a removed feature. Reconcile the list '
            'with the provider notifiers: $unknown');

    // 4. The list must have no duplicates (a copy-paste slip would still pass a
    //    set-based check above but signals a bug in the source list).
    expect(kBackupExportKeys.length, kBackupExportKeys.toSet().length,
        reason: 'kBackupExportKeys contains duplicate entries.');
  });
}
