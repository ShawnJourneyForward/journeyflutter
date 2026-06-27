// A logged (completed) workout — either entered manually or imported from
// Strava. Distinct from PlannerSession (which is the PLAN). Activities feed
// history, weekly volume, the per-discipline insights tiles, and any exercise
// goal whose date window they fall inside.
//
// Distance is stored canonical KM, weights canonical KG, elevation/pool length
// canonical METRES — conversion to imperial happens ONLY at display time.
// [paceMinPerKm] is derived (minutes / km) and null when there is no positive
// distance.
//
// DISCIPLINE vs TYPE. [discipline] (run / ride / swim / gym / yoga …) is the
// launch axis — it decides the icon, the history label, the insights tile, and
// WHICH metrics the log sheet shows ("how it went" differs per discipline:
// elevation for a run, pool length for a swim, sets×reps×weight for the gym).
// [type] is the legacy SessionType kept for the plan / back-compat. Older rows
// have a null [discipline]; [effectiveDiscipline] derives one from [type]. Both
// enums persist as their `.name` string and degrade to a safe default (never
// throw) — see lib/utils/safe_parse.dart. Every new metric is additive and
// optional, so old rows load unchanged.

import '../utils/safe_parse.dart';
import 'planner_session.dart';

/// Where a logged activity came from. Persisted as the enum `.name` string.
enum ActivitySource { manual, strava }

/// The kind of exercise a logged activity is. This is the user-facing axis for
/// logging and the per-discipline insights tiles. Persisted as the enum `.name`.
enum ActivityDiscipline {
  run,
  ride, // cycling
  swim,
  walk,
  hike,
  gym, // strength / weights
  yoga, // yoga / mobility / pilates
  cardio, // rowing, elliptical, HIIT, generic cross-training
  other,
}

/// Disciplines that carry a meaningful distance (so a distance/pace reads make
/// sense). Strength/yoga/cardio are time-first and excluded.
const Set<ActivityDiscipline> distanceDisciplines = {
  ActivityDiscipline.run,
  ActivityDiscipline.ride,
  ActivityDiscipline.swim,
  ActivityDiscipline.walk,
  ActivityDiscipline.hike,
};

/// Disciplines for which an elevation-gain field makes sense.
const Set<ActivityDiscipline> elevationDisciplines = {
  ActivityDiscipline.run,
  ActivityDiscipline.ride,
  ActivityDiscipline.walk,
  ActivityDiscipline.hike,
};

/// Parse an [ActivitySource] from its stored `.name`, degrading to
/// [ActivitySource.manual] for null / non-String / unknown values.
ActivitySource activitySourceFromName(Object? v) {
  if (v is String) {
    for (final s in ActivitySource.values) {
      if (s.name == v) return s;
    }
  }
  return ActivitySource.manual;
}

/// Parse an [ActivityDiscipline] from its stored `.name`, degrading to
/// [ActivityDiscipline.other] for null / non-String / unknown values.
ActivityDiscipline activityDisciplineFromName(Object? v) {
  if (v is String) {
    for (final d in ActivityDiscipline.values) {
      if (d.name == v) return d;
    }
  }
  return ActivityDiscipline.other;
}

/// Derive a discipline from a legacy [SessionType] for rows that predate the
/// discipline field (or for an activity minted from a planned session). The
/// run-family session kinds collapse to [ActivityDiscipline.run]; cross-training
/// can't be recovered more precisely, so it maps to [ActivityDiscipline.cardio].
ActivityDiscipline disciplineFromSessionType(SessionType t) {
  switch (t) {
    case SessionType.easyRun:
    case SessionType.intervals:
    case SessionType.tempo:
    case SessionType.longRun:
      return ActivityDiscipline.run;
    case SessionType.swim:
      return ActivityDiscipline.swim;
    case SessionType.crossTrain:
    case SessionType.cardio:
      return ActivityDiscipline.cardio;
    case SessionType.ride:
      return ActivityDiscipline.ride;
    case SessionType.walk:
      return ActivityDiscipline.walk;
    case SessionType.hike:
      return ActivityDiscipline.hike;
    case SessionType.gym:
      return ActivityDiscipline.gym;
    case SessionType.yoga:
      return ActivityDiscipline.yoga;
    case SessionType.rest:
    case SessionType.other:
      return ActivityDiscipline.other;
  }
}

/// One strength-training entry inside a gym activity: an exercise performed for
/// [sets] × [reps] at an optional [weightKg] (null = bodyweight). Weight is
/// canonical KG, converted to lb only at display time. Tolerant fromJson — a
/// malformed entry loads with safe fallbacks instead of dropping the row.
class StrengthSet {
  final String exercise;
  final int sets;
  final int reps;
  final double? weightKg;

  const StrengthSet({
    required this.exercise,
    this.sets = 0,
    this.reps = 0,
    this.weightKg,
  });

  /// Total volume (tonnage) for this entry: sets × reps × weight, or null when
  /// there is no weight (bodyweight work has no tonnage).
  double? get volumeKg =>
      weightKg == null ? null : sets * reps * weightKg!;

  factory StrengthSet.fromJson(Map<String, dynamic> j) => StrengthSet(
        exercise: safeString(j['exercise']),
        sets: safeInt(j['sets']),
        reps: safeInt(j['reps']),
        weightKg: safeNullableDouble(j['weightKg']),
      );

  Map<String, dynamic> toJson() => {
        'exercise': exercise,
        'sets': sets,
        'reps': reps,
        if (weightKg != null) 'weightKg': weightKg,
      };

  StrengthSet copyWith({
    String? exercise,
    int? sets,
    int? reps,
    double? weightKg,
  }) =>
      StrengthSet(
        exercise: exercise ?? this.exercise,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        weightKg: weightKg ?? this.weightKg,
      );
}

class PlannerActivity {
  final String id;
  final DateTime date;
  final SessionType type;
  final int minutes;
  final double? distanceKm;
  final int? avgHeartRate;
  final ActivitySource source;
  final String? stravaId;
  final String? goalId;
  final String? notes;

  /// The exercise discipline. Null on rows written before disciplines existed —
  /// read [effectiveDiscipline] instead of this to get a never-null value.
  final ActivityDiscipline? discipline;

  // ── Per-discipline "how it went" metrics (all optional, all additive) ──────
  /// Perceived effort, 1–10 (RPE). Universal across disciplines.
  final int? rpe;

  /// Elevation gain in canonical METRES (run / ride / walk / hike).
  final double? elevationGainM;

  /// Pool length in canonical METRES (swim).
  final double? poolLengthM;

  /// Strength exercises (gym): exercise → sets × reps × weight. Empty for every
  /// other discipline.
  final List<StrengthSet> strengthSets;

  // ── Plan snapshot ──────────────────────────────────────────────────────────
  // Set ONLY when this activity was logged by closing off a planned
  // PlannerSession — it captures what the session originally planned so history
  // can show "planned X · did Y". Null on free-form manual logs and Strava
  // imports. Both additive + optional, so older rows load unchanged.
  final double? plannedDistanceKm; // canonical KM the session planned
  final int? plannedMinutes; // minutes the session planned

  const PlannerActivity({
    required this.id,
    required this.date,
    required this.type,
    required this.minutes,
    this.distanceKm,
    this.avgHeartRate,
    this.source = ActivitySource.manual,
    this.stravaId,
    this.goalId,
    this.notes,
    this.discipline,
    this.rpe,
    this.elevationGainM,
    this.poolLengthM,
    this.strengthSets = const [],
    this.plannedDistanceKm,
    this.plannedMinutes,
  });

  /// True when this activity carries the plan it was logged against (i.e. it was
  /// created by completing a PlannerSession), so history can show planned-vs-did.
  bool get hasPlanSnapshot =>
      plannedDistanceKm != null || plannedMinutes != null;

  /// The discipline to display / aggregate by: the stored [discipline] when set,
  /// otherwise derived from the legacy [type] so old rows still bucket sensibly.
  ActivityDiscipline get effectiveDiscipline =>
      discipline ?? disciplineFromSessionType(type);

  /// Pace in minutes per km, or null when there is no positive distance.
  double? get paceMinPerKm =>
      (distanceKm != null && distanceKm! > 0) ? minutes / distanceKm! : null;

  /// Total strength tonnage across all entries (sets × reps × weight), or null
  /// when nothing carried a weight.
  double? get strengthVolumeKg {
    var total = 0.0;
    var any = false;
    for (final s in strengthSets) {
      final v = s.volumeKg;
      if (v != null) {
        total += v;
        any = true;
      }
    }
    return any ? total : null;
  }

  factory PlannerActivity.fromJson(Map<String, dynamic> j) {
    final rawSets = j['strengthSets'];
    final sets = <StrengthSet>[];
    if (rawSets is List) {
      for (final e in rawSets) {
        if (e is Map<String, dynamic>) sets.add(StrengthSet.fromJson(e));
      }
    }
    return PlannerActivity(
      id: safeId(j['id']),
      date: safeParseDate(j['date']),
      type: sessionTypeFromName(j['type']),
      minutes: safeInt(j['minutes']),
      distanceKm: safeNullableDouble(j['distanceKm']),
      avgHeartRate: safeNullableInt(j['avgHeartRate']),
      source: activitySourceFromName(j['source']),
      stravaId: j['stravaId'] as String?,
      goalId: j['goalId'] as String?,
      notes: j['notes'] as String?,
      // Null when the key is absent (older rows) — effectiveDiscipline derives.
      discipline: j['discipline'] == null
          ? null
          : activityDisciplineFromName(j['discipline']),
      rpe: safeNullableInt(j['rpe']),
      elevationGainM: safeNullableDouble(j['elevationGainM']),
      poolLengthM: safeNullableDouble(j['poolLengthM']),
      strengthSets: sets,
      plannedDistanceKm: safeNullableDouble(j['plannedDistanceKm']),
      plannedMinutes: safeNullableInt(j['plannedMinutes']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.name,
        'minutes': minutes,
        if (distanceKm != null) 'distanceKm': distanceKm,
        if (avgHeartRate != null) 'avgHeartRate': avgHeartRate,
        'source': source.name,
        if (stravaId != null) 'stravaId': stravaId,
        if (goalId != null) 'goalId': goalId,
        if (notes != null) 'notes': notes,
        if (discipline != null) 'discipline': discipline!.name,
        if (rpe != null) 'rpe': rpe,
        if (elevationGainM != null) 'elevationGainM': elevationGainM,
        if (poolLengthM != null) 'poolLengthM': poolLengthM,
        if (strengthSets.isNotEmpty)
          'strengthSets': strengthSets.map((e) => e.toJson()).toList(),
        if (plannedDistanceKm != null) 'plannedDistanceKm': plannedDistanceKm,
        if (plannedMinutes != null) 'plannedMinutes': plannedMinutes,
      };

  PlannerActivity copyWith({
    String? id,
    DateTime? date,
    SessionType? type,
    int? minutes,
    double? distanceKm,
    int? avgHeartRate,
    ActivitySource? source,
    String? stravaId,
    String? goalId,
    String? notes,
    ActivityDiscipline? discipline,
    int? rpe,
    double? elevationGainM,
    double? poolLengthM,
    List<StrengthSet>? strengthSets,
    double? plannedDistanceKm,
    int? plannedMinutes,
  }) =>
      PlannerActivity(
        id: id ?? this.id,
        date: date ?? this.date,
        type: type ?? this.type,
        minutes: minutes ?? this.minutes,
        distanceKm: distanceKm ?? this.distanceKm,
        avgHeartRate: avgHeartRate ?? this.avgHeartRate,
        source: source ?? this.source,
        stravaId: stravaId ?? this.stravaId,
        goalId: goalId ?? this.goalId,
        notes: notes ?? this.notes,
        discipline: discipline ?? this.discipline,
        rpe: rpe ?? this.rpe,
        elevationGainM: elevationGainM ?? this.elevationGainM,
        poolLengthM: poolLengthM ?? this.poolLengthM,
        strengthSets: strengthSets ?? this.strengthSets,
        plannedDistanceKm: plannedDistanceKm ?? this.plannedDistanceKm,
        plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      );
}
