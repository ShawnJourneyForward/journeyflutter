import 'dart:convert';

class UserProfile {
  final String username;
  final String soberDate;       // ISO-8601 date string
  final double dailySpend;
  final String currency;        // 'R' for ZAR, '$' for USD, etc.
  final String timezone;
  final int pledgeStreak;
  final String lastPledgeDate;  // YYYY-MM-DD
  final String? lastPledgeText;
  final EmergencyContact? emergencyContact;
  final double? savingsGoal;
  final String? savingsGoalName;
  final List<String> weeklyGoals;
  final List<String> myReasons;
  final String lockMethod;      // 'none' | 'biometric' | 'pin'
  final List<int> firedMilestoneDays;
  final List<double> firedSavingsTiers;

  const UserProfile({
    required this.username,
    required this.soberDate,
    this.dailySpend = 0,
    this.currency = 'R',
    this.timezone = 'UTC',
    this.pledgeStreak = 0,
    this.lastPledgeDate = '',
    this.lastPledgeText,
    this.emergencyContact,
    this.savingsGoal,
    this.savingsGoalName,
    this.weeklyGoals = const [],
    this.myReasons = const [],
    this.lockMethod = 'none',
    this.firedMilestoneDays = const [],
    this.firedSavingsTiers = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    username:           j['username'] as String? ?? '',
    soberDate:          j['soberDate'] as String? ?? DateTime.now().toIso8601String(),
    dailySpend:         (j['dailySpend'] as num?)?.toDouble() ?? 0,
    currency:           j['currency'] as String? ?? 'R',
    timezone:           j['timezone'] as String? ?? 'UTC',
    pledgeStreak:       j['pledgeStreak'] as int? ?? 0,
    lastPledgeDate:     j['lastPledgeDate'] as String? ?? '',
    lastPledgeText:     j['lastPledgeText'] as String?,
    emergencyContact:   j['emergencyContact'] != null
        ? EmergencyContact.fromJson(j['emergencyContact'] as Map<String, dynamic>)
        : null,
    savingsGoal:        (j['savingsGoal'] as num?)?.toDouble(),
    savingsGoalName:    j['savingsGoalName'] as String?,
    weeklyGoals:        (j['weeklyGoals'] as List<dynamic>?)
        ?.map((e) => e as String).toList() ?? [],
    myReasons:          (j['myReasons'] as List<dynamic>?)
        ?.map((e) => e as String).toList() ?? [],
    lockMethod:         j['lockMethod'] as String? ?? 'none',
    firedMilestoneDays: (j['firedMilestoneDays'] as List<dynamic>?)
        ?.map((e) => e as int).toList() ?? [],
    firedSavingsTiers:  (j['firedSavingsTiers'] as List<dynamic>?)
        ?.map((e) => (e as num).toDouble()).toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'username':           username,
    'soberDate':          soberDate,
    'dailySpend':         dailySpend,
    'currency':           currency,
    'timezone':           timezone,
    'pledgeStreak':       pledgeStreak,
    'lastPledgeDate':     lastPledgeDate,
    if (lastPledgeText != null) 'lastPledgeText': lastPledgeText,
    if (emergencyContact != null) 'emergencyContact': emergencyContact!.toJson(),
    if (savingsGoal != null) 'savingsGoal': savingsGoal,
    if (savingsGoalName != null) 'savingsGoalName': savingsGoalName,
    'weeklyGoals':        weeklyGoals,
    'myReasons':          myReasons,
    'lockMethod':         lockMethod,
    'firedMilestoneDays': firedMilestoneDays,
    'firedSavingsTiers':  firedSavingsTiers,
  };

  String toJsonString() => jsonEncode(toJson());

  UserProfile copyWith({
    String? username, String? soberDate, double? dailySpend,
    String? currency, String? timezone, int? pledgeStreak,
    String? lastPledgeDate, String? lastPledgeText,
    EmergencyContact? emergencyContact,
    double? savingsGoal, String? savingsGoalName,
    List<String>? weeklyGoals, List<String>? myReasons, String? lockMethod,
    List<int>? firedMilestoneDays, List<double>? firedSavingsTiers,
  }) => UserProfile(
    username:           username ?? this.username,
    soberDate:          soberDate ?? this.soberDate,
    dailySpend:         dailySpend ?? this.dailySpend,
    currency:           currency ?? this.currency,
    timezone:           timezone ?? this.timezone,
    pledgeStreak:       pledgeStreak ?? this.pledgeStreak,
    lastPledgeDate:     lastPledgeDate ?? this.lastPledgeDate,
    lastPledgeText:     lastPledgeText ?? this.lastPledgeText,
    emergencyContact:   emergencyContact ?? this.emergencyContact,
    savingsGoal:        savingsGoal ?? this.savingsGoal,
    savingsGoalName:    savingsGoalName ?? this.savingsGoalName,
    weeklyGoals:        weeklyGoals ?? this.weeklyGoals,
    myReasons:          myReasons ?? this.myReasons,
    lockMethod:         lockMethod ?? this.lockMethod,
    firedMilestoneDays: firedMilestoneDays ?? this.firedMilestoneDays,
    firedSavingsTiers:  firedSavingsTiers ?? this.firedSavingsTiers,
  );
}

class EmergencyContact {
  final String name;
  final String phone;
  const EmergencyContact({required this.name, required this.phone});

  factory EmergencyContact.fromJson(Map<String, dynamic> j) =>
      EmergencyContact(name: j['name'] as String, phone: j['phone'] as String);

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};
}

// ─── Computed sober stats (recalculated every second) ─────────────────────────

class SoberStats {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final int heartbeats;
  final int breaths;
  final double moneySaved;
  final Duration elapsed;

  const SoberStats({
    required this.days, required this.hours,
    required this.minutes, required this.seconds,
    required this.heartbeats, required this.breaths,
    required this.moneySaved, required this.elapsed,
  });

  static SoberStats compute(UserProfile profile, DateTime now) {
    final soberDate = DateTime.tryParse(profile.soberDate) ?? now;
    final elapsed = now.difference(soberDate);
    final total = elapsed.inSeconds.clamp(0, 999999999);
    return SoberStats(
      days:       elapsed.inDays.clamp(0, 99999),
      hours:      elapsed.inHours.remainder(24).clamp(0, 23),
      minutes:    elapsed.inMinutes.remainder(60).clamp(0, 59),
      seconds:    elapsed.inSeconds.remainder(60).clamp(0, 59),
      heartbeats: (total * 1.2).round(),   // ~72 bpm
      breaths:    (total * 0.267).round(), // ~16 rpm
      moneySaved: elapsed.inSeconds.clamp(0, 999999999).toDouble() * profile.dailySpend / 86400.0,
      elapsed:    elapsed,
    );
  }
}
