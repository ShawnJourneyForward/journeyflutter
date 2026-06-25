// A single body-weight entry on the "body journey" timeline. Weight is stored
// canonical KG — conversion to lb happens ONLY at display time. An optional
// [milestoneLabel] tags entries the user wants to celebrate (e.g. "first 5 kg").
//
// Tolerant fromJson via lib/utils/safe_parse.dart — a malformed entry loads
// with a safe fallback instead of dropping the whole record.

import '../utils/safe_parse.dart';

class PlannerWeightLog {
  final String id;
  final DateTime date;
  final double weightKg;
  final String? note;
  final String? milestoneLabel;

  const PlannerWeightLog({
    required this.id,
    required this.date,
    required this.weightKg,
    this.note,
    this.milestoneLabel,
  });

  factory PlannerWeightLog.fromJson(Map<String, dynamic> j) => PlannerWeightLog(
        id: safeId(j['id']),
        date: safeParseDate(j['date']),
        weightKg: safeDouble(j['weightKg']),
        note: j['note'] as String?,
        milestoneLabel: j['milestoneLabel'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        if (note != null) 'note': note,
        if (milestoneLabel != null) 'milestoneLabel': milestoneLabel,
      };

  PlannerWeightLog copyWith({
    String? id,
    DateTime? date,
    double? weightKg,
    String? note,
    String? milestoneLabel,
  }) =>
      PlannerWeightLog(
        id: id ?? this.id,
        date: date ?? this.date,
        weightKg: weightKg ?? this.weightKg,
        note: note ?? this.note,
        milestoneLabel: milestoneLabel ?? this.milestoneLabel,
      );
}
