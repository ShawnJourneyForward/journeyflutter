// A "non-scale victory" (NSV) — a body-care win that has nothing to do with a
// number on the scale: more energy, clothes feeling better, riding out a
// craving, sleeping well, "I just showed up today". These are the heart of the
// Body Care module's safety + engagement: there is ALWAYS something positive to
// log, so the app stays rewarding on a flat-or-up-scale day instead of becoming
// a shame trigger.
//
// [kind] is a STABLE slug — one of the preset wins (see body_care_shared.dart)
// or 'custom' for a free-typed win whose text lives in [note]. Storing the slug
// (not the translated label) keeps wins language-independent and lets the label
// re-localise. Tolerant fromJson via lib/utils/safe_parse.dart — a malformed
// entry loads with safe fallbacks rather than dropping the row.

import '../utils/safe_parse.dart';

class BodyCareWin {
  final String id;
  final DateTime date;

  /// Stable slug: a preset win key, or 'custom' for a free-typed one.
  final String kind;

  /// Optional reflection; for a 'custom' win this carries the user's own words.
  final String? note;

  const BodyCareWin({
    required this.id,
    required this.date,
    required this.kind,
    this.note,
  });

  factory BodyCareWin.fromJson(Map<String, dynamic> j) => BodyCareWin(
        id: safeId(j['id']),
        date: safeParseDate(j['date']),
        kind: (j['kind'] as String?)?.trim().isNotEmpty == true
            ? (j['kind'] as String)
            : 'custom',
        note: j['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'kind': kind,
        if (note != null) 'note': note,
      };

  BodyCareWin copyWith({
    String? id,
    DateTime? date,
    String? kind,
    String? note,
  }) =>
      BodyCareWin(
        id: id ?? this.id,
        date: date ?? this.date,
        kind: kind ?? this.kind,
        note: note ?? this.note,
      );
}
