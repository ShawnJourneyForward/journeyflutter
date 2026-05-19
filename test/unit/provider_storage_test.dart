import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/user_profile.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('provider storage smoke tests', () {
    test('empty storage loads without crashing', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final profile = await container.read(profileProvider.future);
      final journal = await container.read(journalProvider.future);
      final slips = await container.read(slipProvider.future);

      expect(profile, isNull);
      expect(journal, isEmpty);
      expect(slips, isEmpty);
    });

    test('basic mocked profile storage can be read', () async {
      const profile = UserProfile(
        username: 'Shawn',
        soberDate: '2026-05-01T08:00:00.000',
      );
      SharedPreferences.setMockInitialValues({
        'profile': profile.toJsonString(),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final loaded = await container.read(profileProvider.future);

      expect(loaded?.username, 'Shawn');
      expect(loaded?.soberDate, '2026-05-01T08:00:00.000');
    });

    test('corrupted profile JSON returns null instead of crashing', () async {
      SharedPreferences.setMockInitialValues({
        'profile': '{not-valid-json',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(profileProvider.future);
      expect(result, isNull);
    });
  });
}
