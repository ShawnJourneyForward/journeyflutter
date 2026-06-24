// Letter the user writes to their future self. Sealed until [unlockDay] of
// sobriety. The user picks 30/90/365 (or custom) at write time; we compute
// the calendar unlock date from the profile's sober date when the letter is
// created so changing the sober date later does NOT shift the unlock target.

import '../utils/safe_parse.dart';

class FutureLetter {
  final String id;
  final DateTime writtenAt;
  final DateTime unlockAt; // calendar date when it can be opened
  final int unlockDay; // sobriety day-count target (30 / 90 / 365 / custom)
  final String body;
  final bool opened;

  const FutureLetter({
    required this.id,
    required this.writtenAt,
    required this.unlockAt,
    required this.unlockDay,
    required this.body,
    this.opened = false,
  });

  FutureLetter copyWith({bool? opened}) => FutureLetter(
        id: id,
        writtenAt: writtenAt,
        unlockAt: unlockAt,
        unlockDay: unlockDay,
        body: body,
        opened: opened ?? this.opened,
      );

  bool unlockedAt(DateTime now) => !now.isBefore(unlockAt);

  factory FutureLetter.fromJson(Map<String, dynamic> j) => FutureLetter(
        id: safeId(j['id']),
        writtenAt: safeParseDate(j['writtenAt']),
        unlockAt: safeParseDate(j['unlockAt']),
        unlockDay: safeInt(j['unlockDay']),
        body: safeString(j['body']),
        opened: (j['opened'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'writtenAt': writtenAt.toIso8601String(),
        'unlockAt': unlockAt.toIso8601String(),
        'unlockDay': unlockDay,
        'body': body,
        'opened': opened,
      };
}
