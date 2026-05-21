// "Hard day" record — the user stayed sober but had to fight for it. This is
// a WIN, not a slip. We surface these on the home screen counter and in
// progress so users can see how many battles they've won, not just their
// uninterrupted streak.

class HardDay {
  final String id;
  final DateTime date;
  final String? note;

  const HardDay({required this.id, required this.date, this.note});

  factory HardDay.fromJson(Map<String, dynamic> j) => HardDay(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        note: j['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        if (note != null) 'note': note,
      };
}
