import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/user_profile.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _baseProfile = UserProfile(
  username: 'Shawn',
  soberDate: '2026-01-01T00:00:00.000',
);

void main() {
  group('ProfileNotifier', () {
    test('save() stores profile and updates state', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(profileProvider.future);
      await container.read(profileProvider.notifier).save(_baseProfile);

      final loaded = await container.read(profileProvider.future);
      expect(loaded?.username, 'Shawn');
      expect(loaded?.soberDate, '2026-01-01T00:00:00.000');
    });

    test('save() persists across container restart', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(profileProvider.future);
      await c1.read(profileProvider.notifier).save(_baseProfile);

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final loaded = await c2.read(profileProvider.future);
      expect(loaded?.username, 'Shawn');
    });

    test('patch() applies updater to current profile', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(profileProvider.future);
      await container.read(profileProvider.notifier).save(_baseProfile);
      await container.read(profileProvider.notifier)
          .patch((p) => p.copyWith(username: 'Updated'));

      final loaded = await container.read(profileProvider.future);
      expect(loaded?.username, 'Updated');
      expect(loaded?.soberDate, '2026-01-01T00:00:00.000');
    });

    test('patch() is a no-op when profile is null', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(profileProvider.future);
      // No save() — profile is null
      await container.read(profileProvider.notifier)
          .patch((p) => p.copyWith(username: 'Should not apply'));

      expect(await container.read(profileProvider.future), isNull);
    });

    test('patchGoal() sets savings goal', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(profileProvider.future);
      await container.read(profileProvider.notifier).save(_baseProfile);
      await container.read(profileProvider.notifier)
          .patchGoal(amount: 5000.0, name: 'New Car');

      final loaded = await container.read(profileProvider.future);
      expect(loaded?.savingsGoal, 5000.0);
      expect(loaded?.savingsGoalName, 'New Car');
    });

    test('patchGoal() clears goal to null', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(profileProvider.future);
      await container.read(profileProvider.notifier).save(
        const UserProfile(
          username: 'Shawn',
          soberDate: '2026-01-01T00:00:00.000',
          savingsGoal: 1000.0,
          savingsGoalName: 'Old Goal',
        ),
      );
      await container.read(profileProvider.notifier)
          .patchGoal(amount: null, name: null);

      final loaded = await container.read(profileProvider.future);
      expect(loaded?.savingsGoal, isNull);
      expect(loaded?.savingsGoalName, isNull);
    });

    test('patchGoal() is a no-op when profile is null', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(profileProvider.future);
      await container.read(profileProvider.notifier)
          .patchGoal(amount: 999.0, name: 'Ghost Goal');

      expect(await container.read(profileProvider.future), isNull);
    });

    test('corrupt JSON returns null instead of throwing', () async {
      SharedPreferences.setMockInitialValues({'profile': '{bad json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final loaded = await container.read(profileProvider.future);
      expect(loaded, isNull);
    });

    test('corrupt JSON clears the stored key', () async {
      SharedPreferences.setMockInitialValues({'profile': '{bad json'});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(profileProvider.future); // triggers recovery

      // New container — key should be gone, profile null
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      expect(await c2.read(profileProvider.future), isNull);
    });

    test('copyWith preserves unchanged nullable fields', () {
      const profile = UserProfile(
        username: 'Shawn',
        soberDate: '2026-01-01',
        savingsGoal: 500.0,
        savingsGoalName: 'Trip',
        lastPledgeText: 'I pledge',
        emergencyContact: EmergencyContact(name: 'Mom', phone: '555-0000'),
      );

      final patched = profile.copyWith(username: 'Changed');
      expect(patched.savingsGoal, 500.0);
      expect(patched.savingsGoalName, 'Trip');
      expect(patched.lastPledgeText, 'I pledge');
      expect(patched.emergencyContact?.name, 'Mom');
    });

    test('copyWith can clear nullable fields to null', () {
      const profile = UserProfile(
        username: 'Shawn',
        soberDate: '2026-01-01',
        savingsGoal: 500.0,
        savingsGoalName: 'Trip',
        lastPledgeText: 'I pledge',
        emergencyContact: EmergencyContact(name: 'Mom', phone: '555-0000'),
      );

      final cleared = profile.copyWith(
        savingsGoal: null,
        savingsGoalName: null,
        lastPledgeText: null,
        emergencyContact: null,
      );
      expect(cleared.savingsGoal, isNull);
      expect(cleared.savingsGoalName, isNull);
      expect(cleared.lastPledgeText, isNull);
      expect(cleared.emergencyContact, isNull);
    });
  });
}
