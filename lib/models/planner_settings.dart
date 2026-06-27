// Planner-wide settings (one record, not a list). Tracks which goal is
// currently active.
//
// Tolerant fromJson via lib/utils/safe_parse.dart.

class PlannerSettings {
  final String? activeGoalId;

  const PlannerSettings({this.activeGoalId});

  factory PlannerSettings.fromJson(Map<String, dynamic> j) => PlannerSettings(
        activeGoalId: j['activeGoalId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (activeGoalId != null) 'activeGoalId': activeGoalId,
      };

  PlannerSettings copyWith({
    String? activeGoalId,
    bool clearActiveGoalId = false,
  }) =>
      PlannerSettings(
        activeGoalId:
            clearActiveGoalId ? null : (activeGoalId ?? this.activeGoalId),
      );
}
