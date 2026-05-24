import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/user_profile.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:journey_forward/utils/encrypted_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  // Slip recording calls ProfileNotifier.patch which writes to EncryptedStore.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installSecureStorageMock();
  });
  setUp(resetSecureStorageMock);

  group('Slip', () {
    test('serializes and deserializes valid entries', () {
      final slip = Slip(
        id: 'slip-1',
        date: DateTime(2026, 5, 18, 9, 30),
        streakDays: 12,
        previousSoberDate: '2026-05-06T09:30:00.000',
        note: 'Hard evening',
      );

      final decoded = Slip.fromJson(
        jsonDecode(jsonEncode(slip.toJson())) as Map<String, dynamic>,
      );

      expect(decoded.id, 'slip-1');
      expect(decoded.date, DateTime(2026, 5, 18, 9, 30));
      expect(decoded.streakDays, 12);
      expect(decoded.note, 'Hard evening');
    });

    test('blank note is preserved according to current behavior', () {
      final slip = Slip(
        id: 'slip-2',
        date: DateTime(2026, 5, 18),
        streakDays: 1,
        previousSoberDate: '2026-05-17T00:00:00.000',
        note: '',
      );

      final decoded = Slip.fromJson(slip.toJson());

      expect(decoded.note, '');
    });

    test('future timestamps currently parse without validation', () {
      final future = DateTime(2030, 1, 1);
      final slip = Slip.fromJson({
        'id': 'future-slip',
        'date': future.toIso8601String(),
        'streakDays': 3,
        'previousSoberDate': '2029-12-29T00:00:00.000',
      });

      expect(slip.date, future);
    });
  });

  group('SlipNotifier', () {
    test('record persists a slip and resets streak milestones', () async {
      final profile = UserProfile(
        username: 'Shawn',
        soberDate:
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        firedMilestoneDays: const [1, 3],
        firedSavingsTiers: const [50],
      );
      SharedPreferences.setMockInitialValues({
        'profile': profile.toJsonString(),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final loadedProfile = await container.read(profileProvider.future);
      await container.read(slipProvider.future);
      await container
          .read(slipProvider.notifier)
          .record(current: loadedProfile!, note: 'Difficult night');

      final slips = await container.read(slipProvider.future);
      final updatedProfile = await container.read(profileProvider.future);
      // Slip log now lives in encrypted storage (Android Keystore-backed)
      // rather than plain SharedPreferences, so assert against EncryptedStore.
      final storedSlipJson = await EncryptedStore.read('slip_log');

      expect(slips, hasLength(1));
      expect(slips.first.note, 'Difficult night');
      expect(storedSlipJson, isNotNull);
      expect(updatedProfile?.firedMilestoneDays, isEmpty);
      expect(updatedProfile?.firedSavingsTiers, isEmpty);
    });
  });
}
