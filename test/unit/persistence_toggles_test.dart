import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // ─── WeeklyGoalTogglesNotifier ─────────────────────────────────────────────

  group('WeeklyGoalTogglesNotifier', () {
    test('starts empty', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpEventQueue();
      expect(container.read(weeklyGoalTogglesProvider), isEmpty);
    });

    test('toggle() adds index to state', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpEventQueue();
      await container.read(weeklyGoalTogglesProvider.notifier).toggle(2);

      expect(container.read(weeklyGoalTogglesProvider), contains(2));
    });

    test('toggle() removes index when already present', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpEventQueue();
      await container.read(weeklyGoalTogglesProvider.notifier).toggle(1);
      await container.read(weeklyGoalTogglesProvider.notifier).toggle(1);

      expect(container.read(weeklyGoalTogglesProvider), isNot(contains(1)));
    });

    test('toggle() persists across container restart', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await pumpEventQueue();
      await c1.read(weeklyGoalTogglesProvider.notifier).toggle(0);
      await c1.read(weeklyGoalTogglesProvider.notifier).toggle(3);

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(weeklyGoalTogglesProvider);
      await pumpEventQueue();

      final loaded = c2.read(weeklyGoalTogglesProvider);
      expect(loaded, containsAll([0, 3]));
    });

    test('multiple toggles maintain correct set', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpEventQueue();
      await container.read(weeklyGoalTogglesProvider.notifier).toggle(0);
      await container.read(weeklyGoalTogglesProvider.notifier).toggle(1);
      await container.read(weeklyGoalTogglesProvider.notifier).toggle(2);
      await container
          .read(weeklyGoalTogglesProvider.notifier)
          .toggle(1); // remove

      final state = container.read(weeklyGoalTogglesProvider);
      expect(state, containsAll([0, 2]));
      expect(state, isNot(contains(1)));
    });
  });

  // ─── MissionTogglesNotifier ────────────────────────────────────────────────

  group('MissionTogglesNotifier', () {
    test('starts empty', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpEventQueue();
      expect(container.read(missionTogglesProvider), isEmpty);
    });

    test('toggle() adds index to state', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpEventQueue();
      await container.read(missionTogglesProvider.notifier).toggle(0);

      expect(container.read(missionTogglesProvider), contains(0));
    });

    test('toggle() removes index when already present', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpEventQueue();
      await container.read(missionTogglesProvider.notifier).toggle(2);
      await container.read(missionTogglesProvider.notifier).toggle(2);

      expect(container.read(missionTogglesProvider), isNot(contains(2)));
    });

    test('persists across container restart when date matches today', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await pumpEventQueue();
      await c1.read(missionTogglesProvider.notifier).toggle(1);

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(missionTogglesProvider);
      await pumpEventQueue();

      expect(c2.read(missionTogglesProvider), contains(1));
    });

    test('stale date clears stored toggles', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final ymd = '${yesterday.year}-'
          '${yesterday.month.toString().padLeft(2, '0')}-'
          '${yesterday.day.toString().padLeft(2, '0')}';

      SharedPreferences.setMockInitialValues({
        'mission_toggles': '{"date":"$ymd","done":[0,1,2]}',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(missionTogglesProvider);
      await pumpEventQueue();

      expect(container.read(missionTogglesProvider), isEmpty);
    });

    test('weekly goals do NOT reset on date change (unlike missions)',
        () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final ymd = '${yesterday.year}-'
          '${yesterday.month.toString().padLeft(2, '0')}-'
          '${yesterday.day.toString().padLeft(2, '0')}';

      // WeeklyGoalToggles stores a plain list, no date key — old toggles remain
      SharedPreferences.setMockInitialValues({
        'weekly_goal_toggles': '[0,1,2]',
        // mission_toggles with yesterday's date → should be discarded
        'mission_toggles': '{"date":"$ymd","done":[0,1,2]}',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(weeklyGoalTogglesProvider);
      container.read(missionTogglesProvider);
      await pumpEventQueue();

      expect(container.read(weeklyGoalTogglesProvider), containsAll([0, 1, 2]));
      expect(container.read(missionTogglesProvider), isEmpty);
    });
  });
}
