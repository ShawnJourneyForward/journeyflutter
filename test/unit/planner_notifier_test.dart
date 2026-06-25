// Unit tests for the five planner AsyncNotifiers in app_providers.dart:
// goals, sessions, weight logs, activities and the single settings record.
//
// These exercise the data-safety FOUNDATION (the UI is built on top): every
// collection must round-trip through EncryptedStore, survive a fresh container,
// and never wipe the user's data on a corrupt-JSON read. Beyond the generic
// add/update/delete coverage, four planner-specific behaviours are pinned:
//   • goalCampaignStats sums in-window activity (any discipline) toward an
//     exercise goal's target and reports the on-track pace verdict;
//   • markComplete flips completed and links completedActivityId;
//   • addImported de-dups by stravaId (importing the same id twice -> one row);
//   • PlannerSettings mutators persist on top of a RESTORED record, not a
//     freshly-defaulted one (so an early write can't blow away a stored field).
//
// The flutter_secure_storage MethodChannel mock + per-test reset are installed
// globally by test/flutter_test_config.dart, so individual tests here only need
// to seed SharedPreferences and (optionally) seedSecureStorage for corrupt-data
// fixtures.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/planner_activity.dart';
import 'package:journey_forward/models/planner_goal.dart';
import 'package:journey_forward/models/planner_session.dart';
import 'package:journey_forward/models/planner_settings.dart';
import 'package:journey_forward/models/planner_weight_log.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  // ─── Planner goals ─────────────────────────────────────────────────────────

  group('PlannerGoalNotifier', () {
    PlannerGoal goal(String id, {bool archived = false}) => PlannerGoal(
          id: id,
          createdAt: DateTime(2026, 5, 1),
          type: GoalType.exercise,
          title: 'Run a 10k',
          measure: ExerciseMeasure.distance,
          targetValue: 10,
          archived: archived,
        );

    test('seeds empty and add() stores the goal', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(plannerGoalProvider.future), isEmpty);

      await container.read(plannerGoalProvider.notifier).add(goal('g1'));

      final goals = await container.read(plannerGoalProvider.future);
      expect(goals, hasLength(1));
      expect(goals.first.id, 'g1');
      expect(goals.first.title, 'Run a 10k');
    });

    test('updateGoal() replaces the matching goal', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerGoalProvider.future);
      await container.read(plannerGoalProvider.notifier).add(goal('g1'));
      await container
          .read(plannerGoalProvider.notifier)
          .updateGoal(goal('g1').copyWith(title: 'Run a faster 10k'));

      final goals = await container.read(plannerGoalProvider.future);
      expect(goals, hasLength(1));
      expect(goals.first.title, 'Run a faster 10k');
    });

    test('archive() soft-hides without deleting the record', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerGoalProvider.future);
      await container.read(plannerGoalProvider.notifier).add(goal('g1'));
      await container.read(plannerGoalProvider.notifier).archive('g1');

      final goals = await container.read(plannerGoalProvider.future);
      expect(goals, hasLength(1)); // still present, just archived
      expect(goals.first.archived, isTrue);

      // …and un-archive flips it back.
      await container
          .read(plannerGoalProvider.notifier)
          .archive('g1', archived: false);
      expect((await container.read(plannerGoalProvider.future)).first.archived,
          isFalse);
    });

    test('delete() removes the goal by id', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerGoalProvider.future);
      await container.read(plannerGoalProvider.notifier).add(goal('g1'));
      await container.read(plannerGoalProvider.notifier).delete('g1');

      expect(await container.read(plannerGoalProvider.future), isEmpty);
    });

    test('persists across a fresh container', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(plannerGoalProvider.future);
      await c1.read(plannerGoalProvider.notifier).add(goal('g1'));

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final goals = await c2.read(plannerGoalProvider.future);
      expect(goals, hasLength(1));
      expect(goals.first.id, 'g1');
    });

    test('corrupt JSON returns empty list (data not wiped)', () async {
      SharedPreferences.setMockInitialValues({});
      seedSecureStorage({'planner_goals': '{bad json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(plannerGoalProvider.future), isEmpty);
    });
  });

  // ─── Planner sessions (the plan) ───────────────────────────────────────────

  group('PlannerSessionNotifier', () {
    PlannerSession session(String id,
            {String goalId = 'g1',
            DateTime? date,
            SessionType type = SessionType.easyRun}) =>
        PlannerSession(
          id: id,
          goalId: goalId,
          date: date ?? DateTime(2026, 5, 5),
          type: type,
          plannedDistanceKm: 5,
        );

    test('seeds empty and add() stores the session', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(plannerSessionProvider.future), isEmpty);

      await container.read(plannerSessionProvider.notifier).add(session('s1'));

      final sessions = await container.read(plannerSessionProvider.future);
      expect(sessions, hasLength(1));
      expect(sessions.first.id, 's1');
    });

    test('updateSession() replaces the matching session', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerSessionProvider.future);
      await container.read(plannerSessionProvider.notifier).add(session('s1'));
      await container
          .read(plannerSessionProvider.notifier)
          .updateSession(session('s1').copyWith(type: SessionType.tempo));

      final sessions = await container.read(plannerSessionProvider.future);
      expect(sessions, hasLength(1));
      expect(sessions.first.type, SessionType.tempo);
    });

    test('delete() removes the session by id', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerSessionProvider.future);
      await container.read(plannerSessionProvider.notifier).add(session('s1'));
      await container.read(plannerSessionProvider.notifier).delete('s1');

      expect(await container.read(plannerSessionProvider.future), isEmpty);
    });

    test('markComplete() flips completed and links the activity', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerSessionProvider.future);
      await container.read(plannerSessionProvider.notifier).add(session('s1'));

      // Sanity: starts incomplete and unlinked.
      var s = (await container.read(plannerSessionProvider.future)).single;
      expect(s.completed, isFalse);
      expect(s.completedActivityId, isNull);

      await container
          .read(plannerSessionProvider.notifier)
          .markComplete('s1', 'act-42');

      s = (await container.read(plannerSessionProvider.future)).single;
      expect(s.completed, isTrue);
      expect(s.completedActivityId, 'act-42');
    });

    test('markComplete() with a null activity still completes', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerSessionProvider.future);
      await container.read(plannerSessionProvider.notifier).add(session('s1'));
      await container
          .read(plannerSessionProvider.notifier)
          .markComplete('s1', null);

      final s = (await container.read(plannerSessionProvider.future)).single;
      expect(s.completed, isTrue);
      expect(s.completedActivityId, isNull);
    });

    test('markSkipped() flips skipped, clears completed + activity link',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerSessionProvider.future);
      await container.read(plannerSessionProvider.notifier).add(session('s1'));
      // Complete + link first; skipping must DROP the link (no activity logged).
      await container
          .read(plannerSessionProvider.notifier)
          .markComplete('s1', 'act-1');
      await container.read(plannerSessionProvider.notifier).markSkipped('s1');

      final s = (await container.read(plannerSessionProvider.future)).single;
      expect(s.skipped, isTrue);
      expect(s.completed, isFalse);
      expect(s.completedActivityId, isNull);
      expect(s.isPending, isFalse);
    });

    test('markComplete() clears a prior skipped flag (mutually exclusive)',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerSessionProvider.future);
      await container.read(plannerSessionProvider.notifier).add(session('s1'));
      await container.read(plannerSessionProvider.notifier).markSkipped('s1');
      await container
          .read(plannerSessionProvider.notifier)
          .markComplete('s1', 'act-9');

      final s = (await container.read(plannerSessionProvider.future)).single;
      expect(s.completed, isTrue);
      expect(s.skipped, isFalse);
      expect(s.completedActivityId, 'act-9');
    });

    test('reopen() resets a completed/skipped session to pending', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerSessionProvider.future);
      await container.read(plannerSessionProvider.notifier).add(session('s1'));
      await container
          .read(plannerSessionProvider.notifier)
          .markComplete('s1', 'act-1');
      await container.read(plannerSessionProvider.notifier).reopen('s1');

      final s = (await container.read(plannerSessionProvider.future)).single;
      expect(s.completed, isFalse);
      expect(s.skipped, isFalse);
      expect(s.completedActivityId, isNull);
      expect(s.isPending, isTrue);
    });

    test('persists across a fresh container', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(plannerSessionProvider.future);
      await c1.read(plannerSessionProvider.notifier).add(session('s1'));
      await c1
          .read(plannerSessionProvider.notifier)
          .markComplete('s1', 'act-7');

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final sessions = await c2.read(plannerSessionProvider.future);
      expect(sessions, hasLength(1));
      expect(sessions.first.completed, isTrue);
      expect(sessions.first.completedActivityId, 'act-7');
    });

    test('corrupt JSON returns empty list (data not wiped)', () async {
      SharedPreferences.setMockInitialValues({});
      seedSecureStorage({'planner_sessions': '{bad json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(plannerSessionProvider.future), isEmpty);
    });
  });

  // ─── Planner weight logs ───────────────────────────────────────────────────

  group('PlannerWeightNotifier', () {
    PlannerWeightLog log(String id, {DateTime? date, double weightKg = 80}) =>
        PlannerWeightLog(
          id: id,
          date: date ?? DateTime(2026, 5, 1),
          weightKg: weightKg,
        );

    test('seeds empty and add() stores the log', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(plannerWeightProvider.future), isEmpty);

      await container.read(plannerWeightProvider.notifier).add(log('w1'));

      final logs = await container.read(plannerWeightProvider.future);
      expect(logs, hasLength(1));
      expect(logs.first.weightKg, 80);
    });

    test('updateLog() replaces the matching log', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerWeightProvider.future);
      await container.read(plannerWeightProvider.notifier).add(log('w1'));
      await container
          .read(plannerWeightProvider.notifier)
          .updateLog(log('w1').copyWith(weightKg: 78.5));

      final logs = await container.read(plannerWeightProvider.future);
      expect(logs, hasLength(1));
      expect(logs.first.weightKg, 78.5);
    });

    test('logs are stored oldest-first', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerWeightProvider.future);
      // Add out of order; the notifier sorts ascending by date.
      await container
          .read(plannerWeightProvider.notifier)
          .add(log('late', date: DateTime(2026, 6, 1), weightKg: 77));
      await container
          .read(plannerWeightProvider.notifier)
          .add(log('early', date: DateTime(2026, 5, 1), weightKg: 80));

      final logs = await container.read(plannerWeightProvider.future);
      expect(logs.first.id, 'early');
      expect(logs.last.id, 'late');
    });

    test('delete() removes the log by id', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerWeightProvider.future);
      await container.read(plannerWeightProvider.notifier).add(log('w1'));
      await container.read(plannerWeightProvider.notifier).delete('w1');

      expect(await container.read(plannerWeightProvider.future), isEmpty);
    });

    test('persists across a fresh container', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(plannerWeightProvider.future);
      await c1.read(plannerWeightProvider.notifier).add(log('w1', weightKg: 81));

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final logs = await c2.read(plannerWeightProvider.future);
      expect(logs, hasLength(1));
      expect(logs.first.weightKg, 81);
    });

    test('corrupt JSON returns empty list (data not wiped)', () async {
      SharedPreferences.setMockInitialValues({});
      seedSecureStorage({'planner_weight_logs': '{bad json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(plannerWeightProvider.future), isEmpty);
    });
  });

  // ─── Planner activities (manual + Strava import) ───────────────────────────

  group('PlannerActivityNotifier', () {
    PlannerActivity activity(String id,
            {String? stravaId,
            ActivitySource source = ActivitySource.manual,
            DateTime? date}) =>
        PlannerActivity(
          id: id,
          date: date ?? DateTime(2026, 5, 10),
          type: SessionType.easyRun,
          minutes: 30,
          distanceKm: 5,
          source: source,
          stravaId: stravaId,
        );

    test('seeds empty and add() stores the activity', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(plannerActivityProvider.future), isEmpty);

      await container
          .read(plannerActivityProvider.notifier)
          .add(activity('a1'));

      final acts = await container.read(plannerActivityProvider.future);
      expect(acts, hasLength(1));
      expect(acts.first.id, 'a1');
    });

    test('addImported() de-dups by stravaId (same id twice -> one row)',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerActivityProvider.future);

      await container.read(plannerActivityProvider.notifier).addImported(
            activity('import-a', stravaId: '12345',
                source: ActivitySource.strava),
          );
      // Re-importing the same Strava id (different local row id) must NOT
      // create a second row.
      await container.read(plannerActivityProvider.notifier).addImported(
            activity('import-b', stravaId: '12345',
                source: ActivitySource.strava),
          );

      final acts = await container.read(plannerActivityProvider.future);
      expect(acts.where((a) => a.stravaId == '12345'), hasLength(1));
      expect(acts.first.id, 'import-a'); // the first import won
    });

    test('addImported() with a distinct stravaId adds a second row', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerActivityProvider.future);
      await container.read(plannerActivityProvider.notifier).addImported(
          activity('i1', stravaId: '1', source: ActivitySource.strava));
      await container.read(plannerActivityProvider.notifier).addImported(
          activity('i2', stravaId: '2', source: ActivitySource.strava));

      expect(await container.read(plannerActivityProvider.future), hasLength(2));
    });

    test('delete() removes the activity by id', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerActivityProvider.future);
      await container
          .read(plannerActivityProvider.notifier)
          .add(activity('a1'));
      await container.read(plannerActivityProvider.notifier).delete('a1');

      expect(await container.read(plannerActivityProvider.future), isEmpty);
    });

    test('persists across a fresh container (incl. dedup state)', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(plannerActivityProvider.future);
      await c1.read(plannerActivityProvider.notifier).addImported(
          activity('i1', stravaId: '99', source: ActivitySource.strava));

      // Fresh container: re-importing the same stravaId must still de-dup
      // against the persisted row.
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      await c2.read(plannerActivityProvider.future);
      await c2.read(plannerActivityProvider.notifier).addImported(
          activity('i1-again', stravaId: '99', source: ActivitySource.strava));

      final acts = await c2.read(plannerActivityProvider.future);
      expect(acts.where((a) => a.stravaId == '99'), hasLength(1));
    });

    test('corrupt JSON returns empty list (data not wiped)', () async {
      SharedPreferences.setMockInitialValues({});
      seedSecureStorage({'planner_activities': '{bad json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(plannerActivityProvider.future), isEmpty);
    });
  });

  // ─── Planner settings (single record) ──────────────────────────────────────

  group('PlannerSettingsNotifier', () {
    test('seeds default and mutators persist', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = await container.read(plannerSettingsProvider.future);
      expect(initial.stravaConnected, isFalse);
      expect(initial.activeGoalId, isNull);

      await container
          .read(plannerSettingsProvider.notifier)
          .setStravaConnected(true);
      await container
          .read(plannerSettingsProvider.notifier)
          .setActiveGoalId('g1');

      final after = await container.read(plannerSettingsProvider.future);
      expect(after.stravaConnected, isTrue);
      expect(after.activeGoalId, 'g1');
    });

    test('setActiveGoalId(null) clears the active goal', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerSettingsProvider.future);
      await container
          .read(plannerSettingsProvider.notifier)
          .setActiveGoalId('g1');
      await container
          .read(plannerSettingsProvider.notifier)
          .setActiveGoalId(null);

      expect((await container.read(plannerSettingsProvider.future)).activeGoalId,
          isNull);
    });

    test('disconnectStrava() clears connection and last-sync stamp', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerSettingsProvider.future);
      await container
          .read(plannerSettingsProvider.notifier)
          .setStravaConnected(true);
      await container
          .read(plannerSettingsProvider.notifier)
          .setLastStravaSync(DateTime(2026, 5, 1));
      await container
          .read(plannerSettingsProvider.notifier)
          .disconnectStrava();

      final s = await container.read(plannerSettingsProvider.future);
      expect(s.stravaConnected, isFalse);
      expect(s.lastStravaSync, isNull);
    });

    test('mutators persist on top of a RESTORED record, not a default',
        () async {
      // Seed a NON-default settings record already on disk. A mutator that
      // reads a freshly-defaulted object instead of this restored one would
      // silently wipe activeGoalId — this pins the never-clobber rule.
      const restored = PlannerSettings(
        stravaConnected: true,
        activeGoalId: 'goal-keep',
      );
      SharedPreferences.setMockInitialValues({});
      seedSecureStorage({'planner_settings': jsonEncode(restored.toJson())});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Confirm the restored values loaded.
      final loaded = await container.read(plannerSettingsProvider.future);
      expect(loaded.stravaConnected, isTrue);
      expect(loaded.activeGoalId, 'goal-keep');

      // Mutate ONE field; the others must survive untouched.
      await container
          .read(plannerSettingsProvider.notifier)
          .setLastStravaSync(DateTime(2026, 6, 1));

      final after = await container.read(plannerSettingsProvider.future);
      expect(after.activeGoalId, 'goal-keep'); // not wiped
      expect(after.stravaConnected, isTrue); // not wiped
      expect(after.lastStravaSync, DateTime(2026, 6, 1));
    });

    test('persists across a fresh container', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(plannerSettingsProvider.future);
      await c1
          .read(plannerSettingsProvider.notifier)
          .setActiveGoalId('g-persist');

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final s = await c2.read(plannerSettingsProvider.future);
      expect(s.activeGoalId, 'g-persist');
    });

    test('corrupt JSON returns default settings (data not wiped)', () async {
      SharedPreferences.setMockInitialValues({});
      seedSecureStorage({'planner_settings': '{bad json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final s = await container.read(plannerSettingsProvider.future);
      expect(s.stravaConnected, isFalse);
      expect(s.activeGoalId, isNull);
      expect(s.lastStravaSync, isNull);
    });
  });

  // ─── Exercise-goal campaign engine (the on-track stats) ────────────────────

  group('goalCampaignStats', () {
    PlannerActivity act(String id, SessionType type, double km, DateTime date,
            {int minutes = 30}) =>
        PlannerActivity(
          id: id,
          date: date,
          type: type,
          minutes: minutes,
          distanceKm: km,
          source: ActivitySource.manual,
        );

    PlannerGoal exerciseGoal({
      required ExerciseMeasure measure,
      required double target,
      DateTime? start,
      DateTime? end,
    }) =>
        PlannerGoal(
          id: 'g1',
          createdAt: DateTime(2026, 1, 1),
          type: GoalType.exercise,
          title: 'Campaign',
          measure: measure,
          targetValue: target,
          startDate: start,
          endDate: end,
        );

    test('distance progress sums in-window activity across ALL disciplines',
        () async {
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerGoalProvider.future);
      await container.read(plannerActivityProvider.future);

      await container.read(plannerGoalProvider.notifier).add(exerciseGoal(
            measure: ExerciseMeasure.distance,
            target: 24,
            start: now.subtract(const Duration(days: 10)),
            end: now.add(const Duration(days: 90)),
          ));
      // A run, a swim and a cross-train all count toward the same km target.
      await container.read(plannerActivityProvider.notifier).add(act(
          'a1', SessionType.easyRun, 5, now.subtract(const Duration(days: 5))));
      await container.read(plannerActivityProvider.notifier).add(act(
          'a2', SessionType.swim, 4, now.subtract(const Duration(days: 3))));
      await container.read(plannerActivityProvider.notifier).add(act('a3',
          SessionType.crossTrain, 3, now.subtract(const Duration(days: 2))));

      final stats = container.read(goalCampaignStatsProvider('g1'))!;
      expect(stats.measure, ExerciseMeasure.distance);
      expect(stats.activityCount, 3);
      expect(stats.loggedValue, closeTo(12, 1e-9));
      expect(stats.progress, closeTo(0.5, 1e-9));
    });

    test('activities outside the goal window are excluded', () async {
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerGoalProvider.future);
      await container.read(plannerActivityProvider.future);

      await container.read(plannerGoalProvider.notifier).add(exerciseGoal(
            measure: ExerciseMeasure.distance,
            target: 10,
            start: now.subtract(const Duration(days: 7)),
            end: now.add(const Duration(days: 30)),
          ));
      // Before the window — must NOT count.
      await container.read(plannerActivityProvider.notifier).add(act('old',
          SessionType.easyRun, 8, now.subtract(const Duration(days: 30))));
      // Inside the window — counts.
      await container.read(plannerActivityProvider.notifier).add(act(
          'in', SessionType.easyRun, 5, now.subtract(const Duration(days: 1))));

      final stats = container.read(goalCampaignStatsProvider('g1'))!;
      expect(stats.activityCount, 1);
      expect(stats.loggedValue, closeTo(5, 1e-9));
    });

    test('sessions measure counts activities toward the target', () async {
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerGoalProvider.future);
      await container.read(plannerActivityProvider.future);

      await container.read(plannerGoalProvider.notifier).add(exerciseGoal(
            measure: ExerciseMeasure.sessions,
            target: 4,
            start: now.subtract(const Duration(days: 5)),
            end: now.add(const Duration(days: 20)),
          ));
      for (var i = 0; i < 3; i++) {
        await container.read(plannerActivityProvider.notifier).add(act(
            's$i', SessionType.easyRun, 5, now.subtract(Duration(days: i + 1)),
            minutes: 20));
      }

      final stats = container.read(goalCampaignStatsProvider('g1'))!;
      expect(stats.loggedValue, closeTo(3, 1e-9)); // three sessions
      expect(stats.progress, closeTo(0.75, 1e-9));
    });

    test('reports ahead-of-pace when progress outruns elapsed time', () async {
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerGoalProvider.future);
      await container.read(plannerActivityProvider.future);

      // ~10 of ~100 days elapsed, but already 50% of the distance done.
      await container.read(plannerGoalProvider.notifier).add(exerciseGoal(
            measure: ExerciseMeasure.distance,
            target: 100,
            start: now.subtract(const Duration(days: 10)),
            end: now.add(const Duration(days: 90)),
          ));
      await container.read(plannerActivityProvider.notifier).add(act(
          'big', SessionType.longRun, 50, now.subtract(const Duration(days: 1))));

      final stats = container.read(goalCampaignStatsProvider('g1'))!;
      expect(stats.progress, closeTo(0.5, 1e-9));
      expect(stats.pace, GoalPace.ahead);
      expect(stats.daysLeft, isNotNull);
      expect(stats.perWeekToFinish, isNotNull);
    });

    test('weight goal: campaign stats null; progress from weigh-ins', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(plannerGoalProvider.future);
      await container.read(plannerWeightProvider.future);

      await container.read(plannerGoalProvider.notifier).add(PlannerGoal(
            id: 'gw',
            createdAt: DateTime(2026, 1, 1),
            type: GoalType.weight,
            title: 'Cut',
            startWeightKg: 90,
            goalWeightKg: 80,
          ));
      await container.read(plannerWeightProvider.notifier).add(PlannerWeightLog(
            id: 'w1',
            date: DateTime(2026, 2, 1),
            weightKg: 85,
          ));

      expect(container.read(goalCampaignStatsProvider('gw')), isNull);
      expect(container.read(goalProgressForProvider('gw')), closeTo(0.5, 1e-9));
    });
  });

  // ─── Goal timeline (the overview countdown math) ───────────────────────────

  group('goalTimelineFor', () {
    PlannerGoal datedGoal({DateTime? start, DateTime? end, DateTime? created}) =>
        PlannerGoal(
          id: 'g',
          createdAt: created ?? DateTime(2026, 1, 1),
          type: GoalType.exercise,
          title: 'Race',
          startDate: start,
          endDate: end,
        );

    test('returns null when the goal has no goal/end date', () {
      expect(goalTimelineFor(datedGoal(end: null), DateTime(2026, 6, 1)),
          isNull);
    });

    test('mid-window: bar at elapsed/total, days-left to the goal', () {
      // Day 5 of a 10-day window.
      final t = goalTimelineFor(
        datedGoal(start: DateTime(2026, 1, 1), end: DateTime(2026, 1, 11)),
        DateTime(2026, 1, 6),
      )!;
      expect(t.passed, isFalse);
      expect(t.notStarted, isFalse);
      expect(t.daysToGoal, 5);
      expect(t.fraction, closeTo(0.5, 1e-9));
      expect(t.start, DateTime(2026, 1, 1));
    });

    test('not started: future start → fraction 0, days-to-start set', () {
      final t = goalTimelineFor(
        datedGoal(start: DateTime(2026, 2, 1), end: DateTime(2026, 3, 1)),
        DateTime(2026, 1, 20),
      )!;
      expect(t.notStarted, isTrue);
      expect(t.daysToStart, 12); // Jan 20 → Feb 1
      expect(t.fraction, 0.0);
      expect(t.daysToGoal, 40); // Jan 20 → Mar 1 (2026 is not a leap year)
    });

    test('goal date passed: fraction 1, zero days left', () {
      final t = goalTimelineFor(
        datedGoal(start: DateTime(2026, 1, 1), end: DateTime(2026, 1, 10)),
        DateTime(2026, 1, 20),
      )!;
      expect(t.passed, isTrue);
      expect(t.daysToGoal, 0);
      expect(t.fraction, 1.0);
    });

    test('goal day today: not passed, zero days left, full bar', () {
      final t = goalTimelineFor(
        datedGoal(start: DateTime(2026, 1, 1), end: DateTime(2026, 1, 10)),
        DateTime(2026, 1, 10),
      )!;
      expect(t.passed, isFalse);
      expect(t.daysToGoal, 0);
      expect(t.fraction, closeTo(1.0, 1e-9));
    });

    test('no explicit start: bar creeps from the creation day, start hidden',
        () {
      final t = goalTimelineFor(
        datedGoal(
            start: null,
            end: DateTime(2026, 1, 11),
            created: DateTime(2026, 1, 1)),
        DateTime(2026, 1, 6),
      )!;
      expect(t.start, isNull); // no explicit start → UI hides the label
      expect(t.notStarted, isFalse);
      expect(t.fraction, closeTo(0.5, 1e-9));
      expect(t.daysToGoal, 5);
    });
  });
}
