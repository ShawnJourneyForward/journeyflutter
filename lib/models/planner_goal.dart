// A training-planner goal. For launch there are exactly two flavours:
//   • exercise — a dated campaign you chase with ANY logged activity (runs,
//     rides, swims, walks, gym…). Progress is the sum of in-window activity
//     toward a target measured in distance, active time, or sessions.
//   • weight   — a start→goal body-weight target, fed by the weight timeline.
//
// Distances are stored canonical KM and weights canonical KG — conversion to
// imperial happens ONLY at display time.
//
// Enums persist as their `.name` string and degrade to a safe default for
// unknown values (never throw) — see lib/utils/safe_parse.dart. Records written
// by earlier builds (type 'race' / 'habit', plus race-distance / metric fields)
// still load cleanly: the type degrades to [GoalType.exercise], the now-unused
// fields are ignored, and any saved date is recovered into [endDate].

import '../utils/safe_parse.dart';

/// What kind of goal this is. Persisted as the enum `.name` string.
enum GoalType { exercise, weight }

/// How a [GoalType.exercise] goal measures progress — i.e. what each logged
/// activity contributes toward the target. Persisted as the enum `.name`.
enum ExerciseMeasure {
  /// Canonical KM summed across in-window activities.
  distance,

  /// Active minutes summed across in-window activities.
  time,

  /// A simple count of in-window activities.
  sessions,
}

/// Parse a [GoalType] from its stored `.name`, degrading to [GoalType.exercise]
/// for null / non-String / unknown values — including the retired 'race' and
/// 'habit' types from earlier builds (never throws).
GoalType goalTypeFromName(Object? v) {
  if (v is String) {
    for (final t in GoalType.values) {
      if (t.name == v) return t;
    }
  }
  return GoalType.exercise;
}

/// Parse an [ExerciseMeasure] from its stored `.name`, degrading to
/// [ExerciseMeasure.distance] for null / non-String / unknown values.
ExerciseMeasure exerciseMeasureFromName(Object? v) {
  if (v is String) {
    for (final m in ExerciseMeasure.values) {
      if (m.name == v) return m;
    }
  }
  return ExerciseMeasure.distance;
}

class PlannerGoal {
  final String id;
  final DateTime createdAt;
  final GoalType type;
  final String title;
  final String? notes;
  final bool archived;

  // Campaign window (both flavours). [endDate] is the "by" date that drives the
  // countdown and the on-track pacing; [startDate] anchors the window start.
  final DateTime? startDate;
  final DateTime? endDate;

  // Exercise goals.
  final ExerciseMeasure? measure;
  final double? targetValue; // canonical: km / minutes / count per [measure]

  // Weight goals (canonical KG).
  final double? startWeightKg;
  final double? goalWeightKg;

  const PlannerGoal({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.title,
    this.notes,
    this.archived = false,
    this.startDate,
    this.endDate,
    this.measure,
    this.targetValue,
    this.startWeightKg,
    this.goalWeightKg,
  });

  factory PlannerGoal.fromJson(Map<String, dynamic> j) => PlannerGoal(
        id: safeId(j['id']),
        createdAt: safeParseDate(j['createdAt']),
        type: goalTypeFromName(j['type']),
        title: safeString(j['title']),
        notes: j['notes'] as String?,
        archived: safeBool(j['archived']),
        startDate: nullableParseDate(j['startDate']),
        // Recover a date from older field names so test-build goals keep theirs.
        endDate: nullableParseDate(j['endDate']) ??
            nullableParseDate(j['targetDate']) ??
            nullableParseDate(j['raceDate']),
        measure:
            j['measure'] == null ? null : exerciseMeasureFromName(j['measure']),
        targetValue: safeNullableDouble(j['targetValue']),
        startWeightKg: safeNullableDouble(j['startWeightKg']),
        goalWeightKg: safeNullableDouble(j['goalWeightKg']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'type': type.name,
        'title': title,
        if (notes != null) 'notes': notes,
        'archived': archived,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (measure != null) 'measure': measure!.name,
        if (targetValue != null) 'targetValue': targetValue,
        if (startWeightKg != null) 'startWeightKg': startWeightKg,
        if (goalWeightKg != null) 'goalWeightKg': goalWeightKg,
      };

  /// Copy with overrides. Scalar fields null-coalesce (passing null keeps the
  /// existing value); the goal editor builds a fresh record on save when it
  /// needs to CLEAR type-specific fields, so no sentinel clears are needed here.
  PlannerGoal copyWith({
    String? id,
    DateTime? createdAt,
    GoalType? type,
    String? title,
    String? notes,
    bool? archived,
    DateTime? startDate,
    DateTime? endDate,
    ExerciseMeasure? measure,
    double? targetValue,
    double? startWeightKg,
    double? goalWeightKg,
  }) =>
      PlannerGoal(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        type: type ?? this.type,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        archived: archived ?? this.archived,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        measure: measure ?? this.measure,
        targetValue: targetValue ?? this.targetValue,
        startWeightKg: startWeightKg ?? this.startWeightKg,
        goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      );
}
