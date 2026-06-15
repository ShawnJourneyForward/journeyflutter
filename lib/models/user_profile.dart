import 'dart:convert';

// Sentinel for copyWith — distinguishes "pass null to clear" from "omit to keep".
const _absent = Object();

class UserProfile {
  final String username;
  final String soberDate; // ISO-8601 date string
  final double dailySpend;
  final String currency; // 'R' for ZAR, '$' for USD, etc.
  final String timezone;
  final int pledgeStreak;
  final String lastPledgeDate; // YYYY-MM-DD
  final String? lastPledgeText;
  final EmergencyContact? emergencyContact;
  final double? savingsGoal;
  final String? savingsGoalName;
  final List<String> weeklyGoals;
  final List<String> myReasons;
  final List<String> pros;
  final List<String> cons;
  final String lockMethod; // 'none' | 'biometric' | 'pin'
  final bool hapticsEnabled;
  final List<int> firedMilestoneDays;
  final List<double> firedSavingsTiers;
  // Pre-craving plan: 3 short steps the user has pre-committed to running
  // when a craving hits. Surfaces BEFORE the craving log so the plan is the
  // first thing they see when they're at risk.
  final List<String> preCravingPlan;
  // Parallel to preCravingPlan — a GoRouter route path for each step that the
  // user linked to a Toolkit exercise (e.g. '/emergency'). Empty string means
  // no link for that step.  Shorter than preCravingPlan means remaining steps
  // have no link.
  final List<String> preCravingLinks;
  // High-contrast variant of the Stillwater theme — separate from dark mode.
  // Recovery hours skew late-night, this keeps text legible on tired eyes.
  final bool highContrast;
  // When true the activity sheet labels distance in miles instead of km.
  final bool useImperial;

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
    this.pros = const [],
    this.cons = const [],
    this.lockMethod = 'none',
    this.hapticsEnabled = true,
    this.firedMilestoneDays = const [],
    this.firedSavingsTiers = const [],
    this.preCravingPlan = const [],
    this.preCravingLinks = const [],
    this.highContrast = false,
    this.useImperial = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        username: j['username'] as String? ?? '',
        soberDate:
            j['soberDate'] as String? ?? DateTime.now().toIso8601String(),
        dailySpend: (j['dailySpend'] as num?)?.toDouble() ?? 0,
        currency: j['currency'] as String? ?? 'R',
        timezone: j['timezone'] as String? ?? 'UTC',
        pledgeStreak: j['pledgeStreak'] as int? ?? 0,
        lastPledgeDate: j['lastPledgeDate'] as String? ?? '',
        lastPledgeText: j['lastPledgeText'] as String?,
        // Defensive parsing: never let one mistyped element throw out of
        // fromJson and orphan the WHOLE profile (which would drop the user to
        // onboarding with their streak "gone" until a code fix). `whereType`
        // silently skips wrong-typed elements; numbers are coerced. This is the
        // same robustness the collection lists already have via _safeParseList.
        emergencyContact: j['emergencyContact'] is Map
            ? EmergencyContact.fromJson(
                (j['emergencyContact'] as Map).cast<String, dynamic>())
            : null,
        savingsGoal: (j['savingsGoal'] as num?)?.toDouble(),
        savingsGoalName: j['savingsGoalName'] as String?,
        weeklyGoals:
            (j['weeklyGoals'] as List<dynamic>?)?.whereType<String>().toList() ??
                [],
        myReasons:
            (j['myReasons'] as List<dynamic>?)?.whereType<String>().toList() ??
                [],
        pros: (j['pros'] as List<dynamic>?)?.whereType<String>().toList() ?? [],
        cons: (j['cons'] as List<dynamic>?)?.whereType<String>().toList() ?? [],
        lockMethod: j['lockMethod'] as String? ?? 'none',
        hapticsEnabled: j['hapticsEnabled'] as bool? ?? true,
        firedMilestoneDays: (j['firedMilestoneDays'] as List<dynamic>?)
                ?.whereType<num>()
                .map((e) => e.toInt())
                .toList() ??
            [],
        firedSavingsTiers: (j['firedSavingsTiers'] as List<dynamic>?)
                ?.whereType<num>()
                .map((e) => e.toDouble())
                .toList() ??
            [],
        preCravingPlan: (j['preCravingPlan'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            const [],
        preCravingLinks: (j['preCravingLinks'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            const [],
        highContrast: (j['highContrast'] as bool?) ?? false,
        useImperial: (j['useImperial'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'soberDate': soberDate,
        'dailySpend': dailySpend,
        'currency': currency,
        'timezone': timezone,
        'pledgeStreak': pledgeStreak,
        'lastPledgeDate': lastPledgeDate,
        if (lastPledgeText != null) 'lastPledgeText': lastPledgeText,
        if (emergencyContact != null)
          'emergencyContact': emergencyContact!.toJson(),
        if (savingsGoal != null) 'savingsGoal': savingsGoal,
        if (savingsGoalName != null) 'savingsGoalName': savingsGoalName,
        'weeklyGoals': weeklyGoals,
        'myReasons': myReasons,
        'pros': pros,
        'cons': cons,
        'lockMethod': lockMethod,
        'hapticsEnabled': hapticsEnabled,
        'firedMilestoneDays': firedMilestoneDays,
        'firedSavingsTiers': firedSavingsTiers,
        'preCravingPlan': preCravingPlan,
        'preCravingLinks': preCravingLinks,
        'highContrast': highContrast,
        'useImperial': useImperial,
      };

  String toJsonString() => jsonEncode(toJson());

  UserProfile copyWith({
    String? username,
    String? soberDate,
    double? dailySpend,
    String? currency,
    String? timezone,
    int? pledgeStreak,
    String? lastPledgeDate,
    Object? lastPledgeText = _absent,
    Object? emergencyContact = _absent,
    Object? savingsGoal = _absent,
    Object? savingsGoalName = _absent,
    List<String>? weeklyGoals,
    List<String>? myReasons,
    List<String>? pros,
    List<String>? cons,
    String? lockMethod,
    bool? hapticsEnabled,
    List<int>? firedMilestoneDays,
    List<double>? firedSavingsTiers,
    List<String>? preCravingPlan,
    List<String>? preCravingLinks,
    bool? highContrast,
    bool? useImperial,
  }) =>
      UserProfile(
        username: username ?? this.username,
        soberDate: soberDate ?? this.soberDate,
        dailySpend: dailySpend ?? this.dailySpend,
        currency: currency ?? this.currency,
        timezone: timezone ?? this.timezone,
        pledgeStreak: pledgeStreak ?? this.pledgeStreak,
        lastPledgeDate: lastPledgeDate ?? this.lastPledgeDate,
        lastPledgeText: lastPledgeText == _absent
            ? this.lastPledgeText
            : lastPledgeText as String?,
        emergencyContact: emergencyContact == _absent
            ? this.emergencyContact
            : emergencyContact as EmergencyContact?,
        savingsGoal:
            savingsGoal == _absent ? this.savingsGoal : savingsGoal as double?,
        savingsGoalName: savingsGoalName == _absent
            ? this.savingsGoalName
            : savingsGoalName as String?,
        weeklyGoals: weeklyGoals ?? this.weeklyGoals,
        myReasons: myReasons ?? this.myReasons,
        pros: pros ?? this.pros,
        cons: cons ?? this.cons,
        lockMethod: lockMethod ?? this.lockMethod,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        firedMilestoneDays: firedMilestoneDays ?? this.firedMilestoneDays,
        firedSavingsTiers: firedSavingsTiers ?? this.firedSavingsTiers,
        preCravingPlan: preCravingPlan ?? this.preCravingPlan,
        preCravingLinks: preCravingLinks ?? this.preCravingLinks,
        highContrast: highContrast ?? this.highContrast,
        useImperial: useImperial ?? this.useImperial,
      );
}

class EmergencyContact {
  final String name;
  final String phone;
  const EmergencyContact({required this.name, required this.phone});

  factory EmergencyContact.fromJson(Map<String, dynamic> j) => EmergencyContact(
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
      );

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

  // ── Future quit-date countdown ──────────────────────────────────────────────
  // When the user picks a quit date that hasn't arrived yet, soberDate is in the
  // future. In that window `isCountdown` is true and `untilStart` is the time
  // remaining until day one. The count-up fields above stay clamped to 0 so
  // every existing consumer (plant, milestones, savings…) keeps behaving as if
  // sobriety hasn't started — because it hasn't. Only the home counter opts in
  // to displaying the countdown. The moment now >= soberDate the flag flips off
  // and the normal count-up takes over with no migration or write needed.
  final bool isCountdown;
  final Duration untilStart;

  int get untilDays => untilStart.inDays;
  int get untilHours => untilStart.inHours.remainder(24);
  int get untilMinutes => untilStart.inMinutes.remainder(60);
  int get untilSeconds => untilStart.inSeconds.remainder(60);

  const SoberStats({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.heartbeats,
    required this.breaths,
    required this.moneySaved,
    required this.elapsed,
    this.isCountdown = false,
    this.untilStart = Duration.zero,
  });

  static SoberStats compute(UserProfile profile, DateTime now) {
    final soberDate = DateTime.tryParse(profile.soberDate) ?? now;
    final elapsed = now.difference(soberDate);
    final isCountdown = elapsed.isNegative;
    final untilStart = isCountdown ? soberDate.difference(now) : Duration.zero;
    final total = elapsed.inSeconds.clamp(0, 999999999);
    return SoberStats(
      isCountdown: isCountdown,
      untilStart: untilStart,
      days: elapsed.inDays.clamp(0, 99999),
      hours: elapsed.inHours.remainder(24).clamp(0, 23),
      minutes: elapsed.inMinutes.remainder(60).clamp(0, 59),
      seconds: elapsed.inSeconds.remainder(60).clamp(0, 59),
      heartbeats: (total * 1.2).round(), // ~72 bpm
      breaths: (total * 0.267).round(), // ~16 rpm
      moneySaved: elapsed.inSeconds.clamp(0, 999999999).toDouble() *
          profile.dailySpend.clamp(0.0, double.infinity) /
          86400.0,
      elapsed: elapsed,
    );
  }
}
