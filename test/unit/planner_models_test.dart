import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/planner_goal.dart';
import 'package:journey_forward/models/planner_session.dart';
import 'package:journey_forward/models/planner_weight_log.dart';
import 'package:journey_forward/models/planner_activity.dart';
import 'package:journey_forward/models/planner_settings.dart';

/// Round-trips a model through real JSON encode/decode so we exercise the same
/// path storage does (`Model.fromJson(jsonDecode(jsonEncode(m.toJson())))`).
Map<String, dynamic> roundTrip(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

void main() {
  group('PlannerGoal', () {
    test('full round-trip preserves every field across goal flavours', () {
      final goal = PlannerGoal(
        id: 'g1',
        createdAt: DateTime(2026, 5, 18, 9, 30),
        type: GoalType.exercise,
        title: 'Two Oceans Half',
        notes: 'The big one',
        archived: false,
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 5, 24),
        measure: ExerciseMeasure.distance,
        targetValue: 200,
        startWeightKg: 84.2,
        goalWeightKg: 78.0,
      );

      final decoded = PlannerGoal.fromJson(roundTrip(goal.toJson()));

      expect(decoded.id, 'g1');
      expect(decoded.createdAt, goal.createdAt);
      expect(decoded.type, GoalType.exercise);
      expect(decoded.title, 'Two Oceans Half');
      expect(decoded.notes, 'The big one');
      expect(decoded.archived, isFalse);
      expect(decoded.startDate, goal.startDate);
      expect(decoded.endDate, goal.endDate);
      expect(decoded.measure, ExerciseMeasure.distance);
      expect(decoded.targetValue, 200);
      expect(decoded.startWeightKg, 84.2);
      expect(decoded.goalWeightKg, 78.0);
    });

    test('minimal JSON loads defaults without throwing', () {
      final decoded = PlannerGoal.fromJson(const {});

      expect(decoded.id, isNotEmpty); // safeId generates a fallback.
      expect(decoded.type, GoalType.exercise); // safe default.
      expect(decoded.title, '');
      expect(decoded.archived, isFalse);
      expect(decoded.notes, isNull);
      expect(decoded.startDate, isNull);
      expect(decoded.endDate, isNull);
      expect(decoded.measure, isNull);
      expect(decoded.targetValue, isNull);
      expect(decoded.startWeightKg, isNull);
      expect(decoded.goalWeightKg, isNull);
    });

    test('unknown GoalType degrades to exercise; unknown measure to distance',
        () {
      final decoded = PlannerGoal.fromJson({
        'id': 'g2',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'type': 'zzz',
        'title': 'Mystery',
        'measure': 'teleportation',
      });

      expect(decoded.type, GoalType.exercise);
      expect(decoded.measure, ExerciseMeasure.distance);
    });

    test('legacy race goal loads as exercise and recovers its date', () {
      // Written by an older build: retired 'race' type + legacy raceDate.
      final decoded = PlannerGoal.fromJson({
        'id': 'old1',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'type': 'race',
        'title': 'Comrades 2027',
        'raceDate': DateTime(2027, 6, 14, 5, 30).toIso8601String(),
      });

      expect(decoded.type, GoalType.exercise);
      // endDate is recovered from the legacy raceDate field.
      expect(decoded.endDate, DateTime(2027, 6, 14, 5, 30));
    });

    test('legacy habit goal loads as exercise; endDate falls back to targetDate',
        () {
      final decoded = PlannerGoal.fromJson({
        'id': 'old2',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'type': 'habit',
        'title': 'Legacy habit',
        'targetDate': DateTime(2026, 9, 1).toIso8601String(),
      });

      expect(decoded.type, GoalType.exercise);
      expect(decoded.endDate, DateTime(2026, 9, 1));
    });

    test('tolerates a malformed createdAt and wrong-typed weights', () {
      final decoded = PlannerGoal.fromJson({
        'id': 'g3',
        'createdAt': 'not-a-date',
        'type': 'weight',
        'title': 'Cut',
        'startWeightKg': '90.5', // String that should parse.
        'goalWeightKg': true, // Garbage → null (not a num/parsable String).
      });

      expect(decoded.type, GoalType.weight);
      expect(decoded.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
      expect(decoded.startWeightKg, 90.5);
      expect(decoded.goalWeightKg, isNull);
    });

    test('toJson omits null optional fields', () {
      final json = PlannerGoal(
        id: 'g4',
        createdAt: DateTime(2026, 3, 1),
        type: GoalType.exercise,
        title: 'Move more',
      ).toJson();

      expect(json.containsKey('notes'), isFalse);
      expect(json.containsKey('startDate'), isFalse);
      expect(json.containsKey('endDate'), isFalse);
      expect(json.containsKey('measure'), isFalse);
      expect(json.containsKey('targetValue'), isFalse);
      expect(json.containsKey('startWeightKg'), isFalse);
      expect(json.containsKey('goalWeightKg'), isFalse);
      // Required / always-written keys remain.
      expect(json['type'], 'exercise');
      expect(json['archived'], false);
    });
  });

  group('PlannerSession', () {
    test('full round-trip preserves every field', () {
      final session = PlannerSession(
        id: 's1',
        goalId: 'g1',
        date: DateTime(2026, 5, 20, 6),
        type: SessionType.intervals,
        title: '6x800m',
        plannedDistanceKm: 8.5,
        plannedMinutes: 50,
        notes: 'Track session',
        completed: true,
        completedActivityId: 'a99',
      );

      final decoded = PlannerSession.fromJson(roundTrip(session.toJson()));

      expect(decoded.id, 's1');
      expect(decoded.goalId, 'g1');
      expect(decoded.date, session.date);
      expect(decoded.type, SessionType.intervals);
      expect(decoded.title, '6x800m');
      expect(decoded.plannedDistanceKm, 8.5);
      expect(decoded.plannedMinutes, 50);
      expect(decoded.notes, 'Track session');
      expect(decoded.completed, isTrue);
      expect(decoded.completedActivityId, 'a99');
    });

    test('minimal JSON loads defaults without throwing', () {
      final decoded = PlannerSession.fromJson(const {});

      expect(decoded.id, isNotEmpty);
      expect(decoded.goalId, ''); // default empty.
      expect(decoded.type, SessionType.other); // safe default.
      expect(decoded.completed, isFalse);
      expect(decoded.title, isNull);
      expect(decoded.plannedDistanceKm, isNull);
      expect(decoded.plannedMinutes, isNull);
      expect(decoded.notes, isNull);
      expect(decoded.completedActivityId, isNull);
    });

    test('unknown SessionType degrades to other', () {
      final decoded = PlannerSession.fromJson({
        'id': 's2',
        'date': DateTime(2026, 5, 20).toIso8601String(),
        'type': 'zzz',
      });

      expect(decoded.type, SessionType.other);
    });

    test('toJson omits null optional fields but always writes goalId/completed',
        () {
      final json = PlannerSession(
        id: 's3',
        date: DateTime(2026, 5, 21),
        type: SessionType.rest,
      ).toJson();

      expect(json.containsKey('title'), isFalse);
      expect(json.containsKey('plannedDistanceKm'), isFalse);
      expect(json.containsKey('plannedMinutes'), isFalse);
      expect(json.containsKey('notes'), isFalse);
      expect(json.containsKey('completedActivityId'), isFalse);
      expect(json['goalId'], ''); // always written.
      expect(json['completed'], false); // always written.
      expect(json['type'], 'rest');
    });
  });

  group('PlannerWeightLog', () {
    test('full round-trip preserves every field', () {
      final log = PlannerWeightLog(
        id: 'w1',
        date: DateTime(2026, 5, 22, 7),
        weightKg: 81.4,
        note: 'After breakfast',
        milestoneLabel: 'first 5 kg',
      );

      final decoded = PlannerWeightLog.fromJson(roundTrip(log.toJson()));

      expect(decoded.id, 'w1');
      expect(decoded.date, log.date);
      expect(decoded.weightKg, 81.4);
      expect(decoded.note, 'After breakfast');
      expect(decoded.milestoneLabel, 'first 5 kg');
    });

    test('minimal JSON loads defaults; weightKg falls back to 0', () {
      final decoded = PlannerWeightLog.fromJson(const {});

      expect(decoded.id, isNotEmpty);
      expect(decoded.weightKg, 0); // safeDouble fallback.
      expect(decoded.note, isNull);
      expect(decoded.milestoneLabel, isNull);
    });

    test('tolerates a String-encoded weight and malformed date', () {
      final decoded = PlannerWeightLog.fromJson({
        'id': 'w2',
        'date': 12345, // not a String → epoch fallback.
        'weightKg': '79.9',
      });

      expect(decoded.weightKg, 79.9);
      expect(decoded.date, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('toJson omits null note and milestoneLabel', () {
      final json = PlannerWeightLog(
        id: 'w3',
        date: DateTime(2026, 5, 23),
        weightKg: 80,
      ).toJson();

      expect(json.containsKey('note'), isFalse);
      expect(json.containsKey('milestoneLabel'), isFalse);
      expect(json['weightKg'], 80);
    });
  });

  group('PlannerActivity', () {
    test('full round-trip preserves every field (strava source)', () {
      final activity = PlannerActivity(
        id: 'a1',
        date: DateTime(2026, 5, 24, 8),
        type: SessionType.longRun,
        minutes: 120,
        distanceKm: 21.1,
        avgHeartRate: 152,
        source: ActivitySource.strava,
        stravaId: '987654321',
        goalId: 'g1',
        notes: 'Half marathon time trial',
      );

      final decoded = PlannerActivity.fromJson(roundTrip(activity.toJson()));

      expect(decoded.id, 'a1');
      expect(decoded.date, activity.date);
      expect(decoded.type, SessionType.longRun);
      expect(decoded.minutes, 120);
      expect(decoded.distanceKm, 21.1);
      expect(decoded.avgHeartRate, 152);
      expect(decoded.source, ActivitySource.strava);
      expect(decoded.stravaId, '987654321');
      expect(decoded.goalId, 'g1');
      expect(decoded.notes, 'Half marathon time trial');
    });

    test('manual source with no stravaId round-trips and omits stravaId', () {
      final activity = PlannerActivity(
        id: 'a2',
        date: DateTime(2026, 5, 25),
        type: SessionType.easyRun,
        minutes: 30,
        distanceKm: 5,
        source: ActivitySource.manual,
      );

      final json = activity.toJson();
      expect(json.containsKey('stravaId'), isFalse);
      expect(json['source'], 'manual');

      final decoded = PlannerActivity.fromJson(roundTrip(json));
      expect(decoded.source, ActivitySource.manual);
      expect(decoded.stravaId, isNull);
    });

    test('minimal JSON loads defaults; source defaults to manual', () {
      final decoded = PlannerActivity.fromJson(const {});

      expect(decoded.id, isNotEmpty);
      expect(decoded.type, SessionType.other);
      expect(decoded.minutes, 0); // safeInt fallback.
      expect(decoded.source, ActivitySource.manual); // safe default.
      expect(decoded.distanceKm, isNull);
      expect(decoded.avgHeartRate, isNull);
      expect(decoded.stravaId, isNull);
      expect(decoded.goalId, isNull);
      expect(decoded.notes, isNull);
    });

    test('unknown ActivitySource degrades to manual', () {
      final decoded = PlannerActivity.fromJson({
        'id': 'a3',
        'date': DateTime(2026, 5, 26).toIso8601String(),
        'type': 'easyRun',
        'minutes': 40,
        'source': 'garmin', // unknown.
      });

      expect(decoded.source, ActivitySource.manual);
    });

    test('paceMinPerKm derives minutes/km when distance is positive', () {
      final activity = PlannerActivity(
        id: 'a4',
        date: DateTime(2026, 5, 27),
        type: SessionType.tempo,
        minutes: 50,
        distanceKm: 10,
      );

      expect(activity.paceMinPerKm, closeTo(5.0, 1e-9));
    });

    test('paceMinPerKm is null when distance is null or zero (guard)', () {
      final noDistance = PlannerActivity(
        id: 'a5',
        date: DateTime(2026, 5, 28),
        type: SessionType.crossTrain,
        minutes: 45,
      );
      expect(noDistance.paceMinPerKm, isNull);

      final zeroDistance = PlannerActivity(
        id: 'a6',
        date: DateTime(2026, 5, 28),
        type: SessionType.easyRun,
        minutes: 45,
        distanceKm: 0,
      );
      expect(zeroDistance.paceMinPerKm, isNull);
    });

    test('toJson omits null optional fields but always writes source', () {
      final json = PlannerActivity(
        id: 'a7',
        date: DateTime(2026, 5, 29),
        type: SessionType.swim,
        minutes: 25,
      ).toJson();

      expect(json.containsKey('distanceKm'), isFalse);
      expect(json.containsKey('avgHeartRate'), isFalse);
      expect(json.containsKey('stravaId'), isFalse);
      expect(json.containsKey('goalId'), isFalse);
      expect(json.containsKey('notes'), isFalse);
      expect(json['source'], 'manual'); // always written.
      expect(json['minutes'], 25); // always written.
    });

    test('discipline round-trips and effectiveDiscipline prefers it', () {
      final activity = PlannerActivity(
        id: 'd1',
        date: DateTime(2026, 6, 1),
        type: SessionType.easyRun,
        minutes: 40,
        discipline: ActivityDiscipline.ride,
      );
      final decoded = PlannerActivity.fromJson(roundTrip(activity.toJson()));
      expect(decoded.discipline, ActivityDiscipline.ride);
      // Stored discipline wins over the type-derived one.
      expect(decoded.effectiveDiscipline, ActivityDiscipline.ride);
    });

    test('effectiveDiscipline derives from legacy type when discipline is null',
        () {
      // A row written before disciplines existed (no discipline key).
      final decoded = PlannerActivity.fromJson({
        'id': 'd2',
        'date': DateTime(2026, 6, 2).toIso8601String(),
        'type': 'swim',
        'minutes': 30,
      });
      expect(decoded.discipline, isNull);
      expect(decoded.effectiveDiscipline, ActivityDiscipline.swim);
    });

    test('disciplineFromSessionType collapses the run family and cross-train',
        () {
      expect(disciplineFromSessionType(SessionType.intervals),
          ActivityDiscipline.run);
      expect(disciplineFromSessionType(SessionType.longRun),
          ActivityDiscipline.run);
      expect(disciplineFromSessionType(SessionType.crossTrain),
          ActivityDiscipline.cardio);
      expect(disciplineFromSessionType(SessionType.rest),
          ActivityDiscipline.other);
    });

    test('gym metrics round-trip and tonnage ignores bodyweight rows', () {
      final activity = PlannerActivity(
        id: 'm1',
        date: DateTime(2026, 6, 3),
        type: SessionType.crossTrain,
        discipline: ActivityDiscipline.gym,
        minutes: 50,
        rpe: 8,
        strengthSets: const [
          StrengthSet(exercise: 'Bench', sets: 3, reps: 8, weightKg: 60),
          StrengthSet(exercise: 'Pull-up', sets: 4, reps: 10), // bodyweight
        ],
      );
      final decoded = PlannerActivity.fromJson(roundTrip(activity.toJson()));
      expect(decoded.rpe, 8);
      expect(decoded.strengthSets, hasLength(2));
      expect(decoded.strengthSets.first.exercise, 'Bench');
      expect(decoded.strengthSets.first.weightKg, 60);
      expect(decoded.strengthSets.last.weightKg, isNull);
      // Tonnage = 3 × 8 × 60 = 1440; the bodyweight row contributes nothing.
      expect(decoded.strengthVolumeKg, closeTo(1440, 1e-9));
    });

    test('elevation + pool length round-trip; empties omitted from toJson', () {
      final run = PlannerActivity(
        id: 'm2',
        date: DateTime(2026, 6, 4),
        type: SessionType.easyRun,
        discipline: ActivityDiscipline.run,
        minutes: 45,
        distanceKm: 9,
        elevationGainM: 120,
      );
      final decodedRun = PlannerActivity.fromJson(roundTrip(run.toJson()));
      expect(decodedRun.elevationGainM, 120);
      expect(decodedRun.poolLengthM, isNull);
      expect(decodedRun.strengthVolumeKg, isNull);

      // A bare activity omits every new optional key.
      final bare = PlannerActivity(
        id: 'm3',
        date: DateTime(2026, 6, 5),
        type: SessionType.other,
        minutes: 20,
      ).toJson();
      expect(bare.containsKey('rpe'), isFalse);
      expect(bare.containsKey('elevationGainM'), isFalse);
      expect(bare.containsKey('poolLengthM'), isFalse);
      expect(bare.containsKey('strengthSets'), isFalse);
    });

    test('StrengthSet tolerates malformed JSON', () {
      final s = StrengthSet.fromJson(const {
        'exercise': 'Squat',
        'sets': '5', // String that should parse via safeInt.
        'reps': 5,
        'weightKg': 'oops', // Garbage → null.
      });
      expect(s.exercise, 'Squat');
      expect(s.sets, 5);
      expect(s.reps, 5);
      expect(s.weightKg, isNull);
      expect(s.volumeKg, isNull); // no weight → no tonnage
    });
  });

  group('PlannerSettings', () {
    test('full round-trip preserves every field', () {
      final settings = PlannerSettings(
        stravaConnected: true,
        lastStravaSync: DateTime(2026, 5, 30, 12),
        activeGoalId: 'g1',
      );

      final decoded = PlannerSettings.fromJson(roundTrip(settings.toJson()));

      expect(decoded.stravaConnected, isTrue);
      expect(decoded.lastStravaSync, settings.lastStravaSync);
      expect(decoded.activeGoalId, 'g1');
    });

    test('empty JSON loads defaults without throwing', () {
      final decoded = PlannerSettings.fromJson(const {});

      expect(decoded.stravaConnected, isFalse);
      expect(decoded.lastStravaSync, isNull);
      expect(decoded.activeGoalId, isNull);
    });

    test('tolerates a wrong-typed stravaConnected flag', () {
      // safeBool tolerates the common 1/0 and "true"/"false" encodings.
      expect(
        PlannerSettings.fromJson(const {'stravaConnected': 1}).stravaConnected,
        isTrue,
      );
      expect(
        PlannerSettings.fromJson(const {'stravaConnected': 'true'})
            .stravaConnected,
        isTrue,
      );
      expect(
        PlannerSettings.fromJson(const {'stravaConnected': 'nonsense'})
            .stravaConnected,
        isFalse,
      );
    });

    test('toJson omits null lastStravaSync and activeGoalId', () {
      final json = const PlannerSettings(stravaConnected: false).toJson();

      expect(json.containsKey('lastStravaSync'), isFalse);
      expect(json.containsKey('activeGoalId'), isFalse);
      expect(json['stravaConnected'], false); // always written.
    });
  });

}
