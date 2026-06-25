// A single planned training session inside a goal's plan. The plan is a list
// of these — one per scheduled workout (or a rest day). Completing a session
// can link it to a logged PlannerActivity via [completedActivityId].
//
// SessionType is the shared workout-kind enum used by BOTH PlannerSession and
// PlannerActivity. It is persisted as its enum `.name` string and degrades to
// [SessionType.other] for any unknown value (never throws) — see the frozen
// tolerant-parse contract in lib/utils/safe_parse.dart.

import '../utils/safe_parse.dart';

/// Kind of training session. Persisted on disk as the enum `.name` string.
enum SessionType {
  easyRun,
  intervals,
  tempo,
  longRun,
  rest,
  crossTrain,
  swim,
  other,
}

/// Session types that carry a meaningful distance (used to decide whether a
/// distance field / pace makes sense for the session).
const Set<SessionType> distanceSessionTypes = {
  SessionType.easyRun,
  SessionType.intervals,
  SessionType.tempo,
  SessionType.longRun,
  SessionType.swim,
};

/// Parse a [SessionType] from its stored `.name`, degrading to
/// [SessionType.other] for null / non-String / unknown values (never throws).
SessionType sessionTypeFromName(Object? v) {
  if (v is String) {
    for (final t in SessionType.values) {
      if (t.name == v) return t;
    }
  }
  return SessionType.other;
}

class PlannerSession {
  final String id;
  final String goalId;
  final DateTime date;
  final SessionType type;
  final String? title;
  final double? plannedDistanceKm;
  final int? plannedMinutes;
  final String? notes;
  final bool completed;
  final String? completedActivityId;

  const PlannerSession({
    required this.id,
    this.goalId = '',
    required this.date,
    required this.type,
    this.title,
    this.plannedDistanceKm,
    this.plannedMinutes,
    this.notes,
    this.completed = false,
    this.completedActivityId,
  });

  factory PlannerSession.fromJson(Map<String, dynamic> j) => PlannerSession(
        id: safeId(j['id']),
        goalId: safeString(j['goalId']),
        date: safeParseDate(j['date']),
        type: sessionTypeFromName(j['type']),
        title: j['title'] as String?,
        plannedDistanceKm: safeNullableDouble(j['plannedDistanceKm']),
        plannedMinutes: safeNullableInt(j['plannedMinutes']),
        notes: j['notes'] as String?,
        completed: safeBool(j['completed']),
        completedActivityId: j['completedActivityId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'goalId': goalId,
        'date': date.toIso8601String(),
        'type': type.name,
        if (title != null) 'title': title,
        if (plannedDistanceKm != null) 'plannedDistanceKm': plannedDistanceKm,
        if (plannedMinutes != null) 'plannedMinutes': plannedMinutes,
        if (notes != null) 'notes': notes,
        'completed': completed,
        if (completedActivityId != null)
          'completedActivityId': completedActivityId,
      };

  /// Copy with overrides. [completedActivityId] is null-coalesced (passing null
  /// leaves the existing link untouched); to DROP the link explicitly, pass
  /// `clearActivity: true` (mirrors PlannerSettings.clearLastStravaSync). This is
  /// what lets a session be un-completed without keeping a stale, possibly
  /// dangling activity id.
  PlannerSession copyWith({
    String? id,
    String? goalId,
    DateTime? date,
    SessionType? type,
    String? title,
    double? plannedDistanceKm,
    int? plannedMinutes,
    String? notes,
    bool? completed,
    String? completedActivityId,
    bool clearActivity = false,
  }) =>
      PlannerSession(
        id: id ?? this.id,
        goalId: goalId ?? this.goalId,
        date: date ?? this.date,
        type: type ?? this.type,
        title: title ?? this.title,
        plannedDistanceKm: plannedDistanceKm ?? this.plannedDistanceKm,
        plannedMinutes: plannedMinutes ?? this.plannedMinutes,
        notes: notes ?? this.notes,
        completed: completed ?? this.completed,
        completedActivityId: clearActivity
            ? null
            : (completedActivityId ?? this.completedActivityId),
      );
}
