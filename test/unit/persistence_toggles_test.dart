import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:journey_forward/utils/encrypted_store.dart';
import 'package:journey_forward/utils/week_dates.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  // Goal-text snapshot passed to toggle() — long enough for every index used.
  const goals = ['Walk daily', 'Read', 'Call sponsor', 'Cook'];

  // The rollover prunes completed goals from the profile, which lives in
  // EncryptedStore — mock it so those reads resolve (to null when no profile is
  // written) instead of hitting the unmocked secure-storage channel.
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installSecureStorageMock();
  });
  setUp(resetSecureStorageMock);

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
      await container
          .read(weeklyGoalTogglesProvider.notifier)
          .toggle(2, goals);

      expect(container.read(weeklyGoalTogglesProvider), contains(2));
    });

    test('toggle() removes index when already present', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpEventQueue();
      await container
          .read(weeklyGoalTogglesProvider.notifier)
          .toggle(1, goals);
      await container
          .read(weeklyGoalTogglesProvider.notifier)
          .toggle(1, goals);

      expect(container.read(weeklyGoalTogglesProvider), isNot(contains(1)));
    });

    test('toggle() persists across container restart (same week)', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await pumpEventQueue();
      await c1.read(weeklyGoalTogglesProvider.notifier).toggle(0, goals);
      await c1.read(weeklyGoalTogglesProvider.notifier).toggle(3, goals);

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
      await container.read(weeklyGoalTogglesProvider.notifier).toggle(0, goals);
      await container.read(weeklyGoalTogglesProvider.notifier).toggle(1, goals);
      await container.read(weeklyGoalTogglesProvider.notifier).toggle(2, goals);
      await container
          .read(weeklyGoalTogglesProvider.notifier)
          .toggle(1, goals); // remove

      final state = container.read(weeklyGoalTogglesProvider);
      expect(state, containsAll([0, 2]));
      expect(state, isNot(contains(1)));
    });

    test('legacy plain-list value is cleared as a stale pre-feature week',
        () async {
      // Pre-week-stamp builds stored a bare index list with no week boundary.
      // On upgrade it's an undatable stale week, so it clears (matches the user
      // expectation that old ticks reset) rather than lingering forever.
      SharedPreferences.setMockInitialValues({
        'weekly_goal_toggles': '[0,1,2]',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(weeklyGoalTogglesProvider);
      await pumpEventQueue();

      expect(container.read(weeklyGoalTogglesProvider), isEmpty);
    });

    test('current-week stamp restores the ticked set', () async {
      final thisWeek = weekKeySunday(DateTime.now());
      SharedPreferences.setMockInitialValues({
        'weekly_goal_toggles':
            '{"week":"$thisWeek","done":[1,3],"goals":${_json(goals)}}',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(weeklyGoalTogglesProvider);
      await pumpEventQueue();

      expect(container.read(weeklyGoalTogglesProvider), containsAll([1, 3]));
    });

    test('a prior week resets to empty AND archives achieved goals', () async {
      final lastWeek =
          weekKeySunday(DateTime.now().subtract(const Duration(days: 7)));
      SharedPreferences.setMockInitialValues({
        'weekly_goal_toggles':
            '{"week":"$lastWeek","done":[0,2],"goals":${_json(goals)}}',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Read both so the history notifier exists when the toggle load archives.
      container.read(weeklyGoalHistoryProvider);
      container.read(weeklyGoalTogglesProvider);
      await pumpEventQueue();

      // Toggles cleared for the fresh week.
      expect(container.read(weeklyGoalTogglesProvider), isEmpty);

      // The two achieved goals were archived under last week's key.
      final history = container.read(weeklyGoalHistoryProvider);
      expect(history, hasLength(1));
      expect(history.first.weekKey, lastWeek);
      expect(history.first.achieved, containsAll(['Walk daily', 'Call sponsor']));
      expect(history.first.total, 4);
    });

    test('archiving a prior week preserves existing history', () async {
      final twoWeeksAgo =
          weekKeySunday(DateTime.now().subtract(const Duration(days: 14)));
      final lastWeek =
          weekKeySunday(DateTime.now().subtract(const Duration(days: 7)));
      SharedPreferences.setMockInitialValues({
        'weekly_goal_history':
            '[{"week":"$twoWeeksAgo","achieved":["Old goal"],"total":2}]',
        'weekly_goal_toggles':
            '{"week":"$lastWeek","done":[1],"goals":${_json(goals)}}',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(weeklyGoalHistoryProvider);
      container.read(weeklyGoalTogglesProvider);
      await pumpEventQueue();

      // The freshly-archived week is added WITHOUT dropping the older record.
      final history = container.read(weeklyGoalHistoryProvider);
      expect(history, hasLength(2));
      expect(history.map((w) => w.weekKey), containsAll([twoWeeksAgo, lastWeek]));
    });

    test('a prior week with nothing achieved archives nothing', () async {
      final lastWeek =
          weekKeySunday(DateTime.now().subtract(const Duration(days: 7)));
      SharedPreferences.setMockInitialValues({
        'weekly_goal_toggles':
            '{"week":"$lastWeek","done":[],"goals":${_json(goals)}}',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(weeklyGoalHistoryProvider);
      container.read(weeklyGoalTogglesProvider);
      await pumpEventQueue();

      expect(container.read(weeklyGoalTogglesProvider), isEmpty);
      expect(container.read(weeklyGoalHistoryProvider), isEmpty);
    });

    test('recheckWeek() archives + clears when the week rolled over (warm '
        'resume across Sunday midnight)', () async {
      final thisWeek = weekKeySunday(DateTime.now());
      SharedPreferences.setMockInitialValues({
        'weekly_goal_toggles':
            '{"week":"$thisWeek","done":[0,1],"goals":${_json(goals)}}',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(weeklyGoalHistoryProvider);
      container.read(weeklyGoalTogglesProvider);
      await pumpEventQueue();
      expect(container.read(weeklyGoalTogglesProvider), containsAll([0, 1]));

      // Simulate the app having been open since LAST week: the on-disk stamp is
      // now a prior week. A warm resume calls recheckWeek (the in-foreground
      // midnight timer never fired because we were backgrounded).
      final lastWeek =
          weekKeySunday(DateTime.now().subtract(const Duration(days: 7)));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weekly_goal_toggles',
          '{"week":"$lastWeek","done":[0,1],"goals":${_json(goals)}}');
      await container.read(weeklyGoalTogglesProvider.notifier).recheckWeek();
      await pumpEventQueue();

      expect(container.read(weeklyGoalTogglesProvider), isEmpty);
      expect(container.read(weeklyGoalHistoryProvider).map((w) => w.weekKey),
          contains(lastWeek));
    });

    test('recheckWeek() is a no-op within the same week (no flicker/clear)',
        () async {
      final thisWeek = weekKeySunday(DateTime.now());
      SharedPreferences.setMockInitialValues({
        'weekly_goal_toggles':
            '{"week":"$thisWeek","done":[2],"goals":${_json(goals)}}',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(weeklyGoalTogglesProvider);
      await pumpEventQueue();
      await container.read(weeklyGoalTogglesProvider.notifier).recheckWeek();
      await pumpEventQueue();
      expect(container.read(weeklyGoalTogglesProvider), containsAll([2]));
    });

    test('rollover REMOVES completed goals + archives them, keeps unfinished',
        () async {
      final lastWeek =
          weekKeySunday(DateTime.now().subtract(const Duration(days: 7)));
      SharedPreferences.setMockInitialValues({
        'has_profile': '1',
        'weekly_goal_toggles':
            '{"week":"$lastWeek","done":[0,2],"goals":${_json(goals)}}',
      });
      await EncryptedStore.write(
          'profile',
          '{"username":"S","soberDate":"2026-01-01T00:00:00.000",'
          '"weeklyGoals":${_json(goals)}}');

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(weeklyGoalHistoryProvider);
      container.read(weeklyGoalTogglesProvider);
      // recheckWeek awaits the load completer, so by the time it returns the
      // rollover (archive + profile prune) has finished.
      await container.read(weeklyGoalTogglesProvider.notifier).recheckWeek();
      await pumpEventQueue();

      // Completed goals (index 0 Walk, 2 Call) removed; unfinished carry over.
      final profile = await container.read(profileProvider.future);
      expect(profile!.weeklyGoals, ['Read', 'Cook']);
      // Ticks cleared.
      expect(container.read(weeklyGoalTogglesProvider), isEmpty);
      // Completed goals archived to history.
      expect(
          container.read(weeklyGoalHistoryProvider).expand((w) => w.achieved),
          containsAll(['Walk daily', 'Call sponsor']));
    });

    test('rollover with nothing ticked leaves all goals to carry over',
        () async {
      final lastWeek =
          weekKeySunday(DateTime.now().subtract(const Duration(days: 7)));
      const g2 = ['Walk daily', 'Read'];
      SharedPreferences.setMockInitialValues({
        'has_profile': '1',
        'weekly_goal_toggles':
            '{"week":"$lastWeek","done":[],"goals":${_json(g2)}}',
      });
      await EncryptedStore.write(
          'profile',
          '{"username":"S","soberDate":"2026-01-01T00:00:00.000",'
          '"weeklyGoals":${_json(g2)}}');

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(weeklyGoalHistoryProvider);
      container.read(weeklyGoalTogglesProvider);
      await container.read(weeklyGoalTogglesProvider.notifier).recheckWeek();
      await pumpEventQueue();

      final profile = await container.read(profileProvider.future);
      expect(profile!.weeklyGoals, ['Walk daily', 'Read']); // unchanged
      expect(container.read(weeklyGoalHistoryProvider), isEmpty);
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
  });
}

/// Minimal JSON array encoder for the goal-text snapshot used in fixtures.
String _json(List<String> items) =>
    '[${items.map((s) => '"$s"').join(',')}]';
