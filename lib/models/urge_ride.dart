/// A completed "ride the wave" — the user stayed with an urge until it
/// passed instead of acting on it. Every recorded ride is a win: ending the
/// timer early via "I'm steady now" still counts (the urge passed sooner).
class UrgeRide {
  final String id;
  final DateTime date;

  /// How long the user stayed with the urge, in seconds.
  final int seconds;

  const UrgeRide({
    required this.id,
    required this.date,
    required this.seconds,
  });

  factory UrgeRide.fromJson(Map<String, dynamic> j) => UrgeRide(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        seconds: (j['seconds'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'seconds': seconds,
      };
}
