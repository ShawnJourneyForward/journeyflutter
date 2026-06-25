// Planner-wide settings (one record, not a list). Tracks Strava connection
// state and which goal is currently active. The Strava OAuth TOKENS themselves
// live in flutter_secure_storage (key `strava_tokens`) and are deliberately
// excluded from backup — only the boolean "connected" flag lives here.
//
// Tolerant fromJson via lib/utils/safe_parse.dart.

import '../utils/safe_parse.dart';

class PlannerSettings {
  final bool stravaConnected;
  final DateTime? lastStravaSync;
  final String? activeGoalId;

  const PlannerSettings({
    this.stravaConnected = false,
    this.lastStravaSync,
    this.activeGoalId,
  });

  factory PlannerSettings.fromJson(Map<String, dynamic> j) => PlannerSettings(
        stravaConnected: safeBool(j['stravaConnected']),
        lastStravaSync: nullableParseDate(j['lastStravaSync']),
        activeGoalId: j['activeGoalId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'stravaConnected': stravaConnected,
        if (lastStravaSync != null)
          'lastStravaSync': lastStravaSync!.toIso8601String(),
        if (activeGoalId != null) 'activeGoalId': activeGoalId,
      };

  PlannerSettings copyWith({
    bool? stravaConnected,
    DateTime? lastStravaSync,
    String? activeGoalId,
    bool clearLastStravaSync = false,
    bool clearActiveGoalId = false,
  }) =>
      PlannerSettings(
        stravaConnected: stravaConnected ?? this.stravaConnected,
        lastStravaSync:
            clearLastStravaSync ? null : (lastStravaSync ?? this.lastStravaSync),
        activeGoalId:
            clearActiveGoalId ? null : (activeGoalId ?? this.activeGoalId),
      );
}
