import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

// ─── 1-second tick ────────────────────────────────────────────────────────────

final timerProvider = StreamProvider<DateTime>((ref) =>
    Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()));

// ─── SharedPreferences instance ───────────────────────────────────────────────

final prefsProvider = FutureProvider<SharedPreferences>(
    (_) => SharedPreferences.getInstance());

// ─── Profile ──────────────────────────────────────────────────────────────────

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  static const _key = 'profile';

  @override
  Future<UserProfile?> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(UserProfile profile) async {
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(_key, profile.toJsonString());
    state = AsyncData(profile);
  }

  Future<void> patch(UserProfile Function(UserProfile) updater) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await save(updater(current));
  }

  Future<void> patchGoal({required double? amount, required String? name}) async {
    final current = state.valueOrNull;
    if (current == null) return;
    // UserProfile.copyWith cannot clear nullable fields, so build explicitly.
    await save(UserProfile(
      username: current.username,
      soberDate: current.soberDate,
      dailySpend: current.dailySpend,
      currency: current.currency,
      timezone: current.timezone,
      pledgeStreak: current.pledgeStreak,
      lastPledgeDate: current.lastPledgeDate,
      lastPledgeText: current.lastPledgeText,
      emergencyContact: current.emergencyContact,
      savingsGoal: amount,
      savingsGoalName: name,
      weeklyGoals: current.weeklyGoals,
      myReasons: current.myReasons,
      lockMethod: current.lockMethod,
      firedMilestoneDays: current.firedMilestoneDays,
      firedSavingsTiers: current.firedSavingsTiers,
    ));
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile?>(ProfileNotifier.new);

// ─── Live sober stats (recomputed every second — use only for the clock widget) ─

final soberStatsProvider = Provider<SoberStats?>((ref) {
  final profileAsync = ref.watch(profileProvider);
  final now = ref.watch(timerProvider).value ?? DateTime.now();

  return profileAsync.when(
    data: (profile) =>
        profile == null ? null : SoberStats.compute(profile, now),
    loading: () => null,
    error: (_, __) => null,
  );
});

// ─── Stable sober stats (updates only when profile changes or at midnight) ────
// Use this for any widget that doesn't need the per-second h/m/s clock.

final soberDaysProvider = Provider<SoberStats?>((ref) {
  final profileAsync = ref.watch(profileProvider);
  // Re-run only when the calendar date changes, not every tick
  ref.watch(timerProvider.select((s) {
    final now = s.value ?? DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }));
  final now = DateTime.now();
  return profileAsync.when(
    data: (profile) =>
        profile == null ? null : SoberStats.compute(profile, now),
    loading: () => null,
    error: (_, __) => null,
  );
});

// ─── Today's gratitude entry ──────────────────────────────────────────────────

class GratitudeNotifier extends AsyncNotifier<String?> {
  static const _key = 'gratitude';

  @override
  Future<String?> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    final list = (jsonDecode(raw) as List<dynamic>);
    final today = _today();
    for (final entry in list.reversed) {
      final m = entry as Map<String, dynamic>;
      if ((m['date'] as String?) == today) return m['text'] as String?;
    }
    return null;
  }

  Future<void> add(String text) async {
    final prefs = await ref.read(prefsProvider.future);
    final raw = prefs.getString(_key);
    final list = raw != null
        ? (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    list.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': _today(),
      'text': text,
    });
    await prefs.setString(_key, jsonEncode(list));
    state = AsyncData(text);
  }

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}

final gratitudeProvider =
    AsyncNotifierProvider<GratitudeNotifier, String?>(GratitudeNotifier.new);

// ─── All gratitude entries (for History screen) ───────────────────────────────

class GratitudeEntry {
  final String id;
  final String date; // YYYY-MM-DD
  final String text;
  const GratitudeEntry({required this.id, required this.date, required this.text});

  factory GratitudeEntry.fromJson(Map<String, dynamic> j) => GratitudeEntry(
    id:   j['id'] as String? ?? j['date'] as String,
    date: j['date'] as String,
    text: j['text'] as String,
  );
}

final allGratitudeProvider = FutureProvider<List<GratitudeEntry>>((ref) async {
  final prefs = await ref.watch(prefsProvider.future);
  // Re-run when today's gratitude changes
  ref.watch(gratitudeProvider);
  final raw = prefs.getString('gratitude');
  if (raw == null) return [];
  final list = (jsonDecode(raw) as List<dynamic>);
  return list
      .map((e) => GratitudeEntry.fromJson(e as Map<String, dynamic>))
      .toList()
      .reversed
      .toList();
});

// ─── Weekly goal completion toggles (in-memory per session) ──────────────────

final weeklyGoalTogglesProvider =
    StateProvider<Set<int>>((ref) => const {});

// ─── Daily mission completion toggles (in-memory per session) ────────────────

final missionTogglesProvider =
    StateProvider<Set<int>>((ref) => const {});

// ─── Journal entries ──────────────────────────────────────────────────────────

class JournalEntry {
  final String id;
  final DateTime date;
  final String text;
  final String mood; // 'great' | 'good' | 'okay' | 'hard' | 'crisis'

  const JournalEntry({
    required this.id,
    required this.date,
    required this.text,
    required this.mood,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        text: j['text'] as String,
        mood: (j['mood'] as String?) ?? 'okay',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'text': text,
        'mood': mood,
      };
}

class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  static const _key = 'journal_entries';

  @override
  Future<List<JournalEntry>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add(String text, String mood) async {
    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      text: text,
      mood: mood,
    );
    final current = state.valueOrNull ?? [];
    final updated = [entry, ...current];
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(_key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }

  Future<void> delete(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((e) => e.id != id).toList();
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(_key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }
}

final journalProvider =
    AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(JournalNotifier.new);

// ─── Custom affirmations ──────────────────────────────────────────────────────

class AffirmationNotifier extends AsyncNotifier<List<String>> {
  static const _key = 'custom_affirmations';

  @override
  Future<List<String>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }

  Future<void> add(String text) async {
    final current = state.valueOrNull ?? [];
    if (current.contains(text)) return;
    final updated = [text, ...current];
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(_key, jsonEncode(updated));
    state = AsyncData(updated);
  }

  Future<void> remove(String text) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((e) => e != text).toList();
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(_key, jsonEncode(updated));
    state = AsyncData(updated);
  }
}

final affirmationProvider =
    AsyncNotifierProvider<AffirmationNotifier, List<String>>(AffirmationNotifier.new);

// ─── Vision board items ───────────────────────────────────────────────────────

class VisionItem {
  final String id;
  final String title;
  final String description;
  final String emoji;

  const VisionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });

  factory VisionItem.fromJson(Map<String, dynamic> j) => VisionItem(
        id: j['id'] as String,
        title: j['title'] as String,
        description: (j['description'] as String?) ?? '',
        emoji: (j['emoji'] as String?) ?? '✨',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
      };
}

class VisionBoardNotifier extends AsyncNotifier<List<VisionItem>> {
  static const _key = 'vision_board';

  @override
  Future<List<VisionItem>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => VisionItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> add(VisionItem item) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, item];
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(_key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((e) => e.id != id).toList();
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(_key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }
}

final visionBoardProvider =
    AsyncNotifierProvider<VisionBoardNotifier, List<VisionItem>>(VisionBoardNotifier.new);

// ─── Slip log ─────────────────────────────────────────────────────────────────

class Slip {
  final String id;
  final DateTime date;
  final int streakDays;       // streak length at time of slip
  final String previousSoberDate;
  final String? note;

  const Slip({
    required this.id,
    required this.date,
    required this.streakDays,
    required this.previousSoberDate,
    this.note,
  });

  factory Slip.fromJson(Map<String, dynamic> j) => Slip(
    id:                 j['id'] as String,
    date:               DateTime.parse(j['date'] as String),
    streakDays:         j['streakDays'] as int,
    previousSoberDate:  j['previousSoberDate'] as String,
    note:               j['note'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id':               id,
    'date':             date.toIso8601String(),
    'streakDays':       streakDays,
    'previousSoberDate': previousSoberDate,
    if (note != null) 'note': note,
  };
}

class SlipNotifier extends AsyncNotifier<List<Slip>> {
  static const _key = 'slip_log';

  @override
  Future<List<Slip>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Slip.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> record({required UserProfile current, String? note}) async {
    final now = DateTime.now();
    final slip = Slip(
      id:                DateTime.now().millisecondsSinceEpoch.toString(),
      date:              now,
      streakDays:        SoberStats.compute(current, now).days,
      previousSoberDate: current.soberDate,
      note:              note,
    );

    final existing = state.valueOrNull ?? [];
    final updated = [slip, ...existing];
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(_key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);

    // Reset streak — clear milestone/savings tier fires so they re-trigger
    await ref.read(profileProvider.notifier).patch(
      (p) => p.copyWith(
        soberDate: now.toIso8601String(),
        firedMilestoneDays: [],
        firedSavingsTiers: [],
      ),
    );
  }
}

final slipProvider =
    AsyncNotifierProvider<SlipNotifier, List<Slip>>(SlipNotifier.new);

// ─── Craving log ──────────────────────────────────────────────────────────────

class CravingEntry {
  final String id;
  final DateTime date;
  final int intensity; // 1–10
  final String? trigger;
  final String? severity;
  final List<String> triggers;
  final int? durationMinutes;
  final String? notes;

  const CravingEntry({
    required this.id,
    required this.date,
    required this.intensity,
    this.trigger,
    this.severity,
    this.triggers = const [],
    this.durationMinutes,
    this.notes,
  });

  factory CravingEntry.fromJson(Map<String, dynamic> j) => CravingEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        intensity: j['intensity'] as int,
        trigger: j['trigger'] as String?,
        severity: j['severity'] as String?,
        triggers: ((j['triggers'] as List<dynamic>?) ??
                ((j['trigger'] as String?)?.trim().isNotEmpty == true
                    ? <dynamic>[j['trigger']]
                    : const <dynamic>[]))
            .map((e) => e.toString())
            .toList(),
        durationMinutes: (j['durationMinutes'] as num?)?.toInt(),
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'intensity': intensity,
        if (trigger != null) 'trigger': trigger,
        if (severity != null) 'severity': severity,
        if (triggers.isNotEmpty) 'triggers': triggers,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (notes != null) 'notes': notes,
      };
}

class CravingNotifier extends AsyncNotifier<List<CravingEntry>> {
  static const _key = 'cravings';

  @override
  Future<List<CravingEntry>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CravingEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add(
    int intensity, {
    String? trigger,
    String? severity,
    List<String> triggers = const [],
    int? durationMinutes,
    String? notes,
  }) async {
    final cleanTriggers = triggers
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final cleanTrigger = trigger?.trim();
    final fallbackTrigger = cleanTriggers.isNotEmpty
        ? cleanTriggers.first
        : (cleanTrigger?.isNotEmpty == true ? cleanTrigger : null);
    final entry = CravingEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      intensity: intensity,
      trigger: fallbackTrigger,
      severity: severity,
      triggers: cleanTriggers,
      durationMinutes: durationMinutes,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );
    final current = state.valueOrNull ?? [];
    final updated = [entry, ...current];
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }
}

final cravingProvider =
    AsyncNotifierProvider<CravingNotifier, List<CravingEntry>>(
        CravingNotifier.new);

// ─── Thought log ──────────────────────────────────────────────────────────────

class ThoughtEntry {
  final String id;
  final DateTime date;
  final String text;
  final String type; // 'negative' | 'neutral' | 'positive'
  final String? strength;
  final List<String> triggers;
  final int? durationMinutes;
  final String? notes;

  const ThoughtEntry({
    required this.id,
    required this.date,
    required this.text,
    required this.type,
    this.strength,
    this.triggers = const [],
    this.durationMinutes,
    this.notes,
  });

  factory ThoughtEntry.fromJson(Map<String, dynamic> j) => ThoughtEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        text: j['text'] as String,
        type: (j['type'] as String?) ?? 'neutral',
        strength: j['strength'] as String?,
        triggers: ((j['triggers'] as List<dynamic>?) ?? const <dynamic>[])
            .map((e) => e.toString())
            .toList(),
        durationMinutes: (j['durationMinutes'] as num?)?.toInt(),
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'text': text,
        'type': type,
        if (strength != null) 'strength': strength,
        if (triggers.isNotEmpty) 'triggers': triggers,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (notes != null) 'notes': notes,
      };
}

class ThoughtNotifier extends AsyncNotifier<List<ThoughtEntry>> {
  static const _key = 'thoughts';

  @override
  Future<List<ThoughtEntry>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ThoughtEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add(
    String text,
    String type, {
    String? strength,
    List<String> triggers = const [],
    int? durationMinutes,
    String? notes,
  }) async {
    final entry = ThoughtEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      text: text,
      type: type,
      strength: strength,
      triggers: triggers
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      durationMinutes: durationMinutes,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );
    final current = state.valueOrNull ?? [];
    final updated = [entry, ...current];
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }
}

final thoughtProvider =
    AsyncNotifierProvider<ThoughtNotifier, List<ThoughtEntry>>(
        ThoughtNotifier.new);

// ─── Activity log ─────────────────────────────────────────────────────────────

class ActivityEntry {
  final String id;
  final DateTime date;
  final String activity; // 'walk' | 'exercise' | 'yoga' | 'other'
  final int minutes;
  final String? effort;
  final String? outcome;
  final String? notes;

  const ActivityEntry({
    required this.id,
    required this.date,
    required this.activity,
    required this.minutes,
    this.effort,
    this.outcome,
    this.notes,
  });

  factory ActivityEntry.fromJson(Map<String, dynamic> j) => ActivityEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        activity: j['activity'] as String,
        minutes: j['minutes'] as int,
        effort: j['effort'] as String?,
        outcome: j['outcome'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'activity': activity,
        'minutes': minutes,
        if (effort != null) 'effort': effort,
        if (outcome != null) 'outcome': outcome,
        if (notes != null) 'notes': notes,
      };
}

class ActivityNotifier extends AsyncNotifier<List<ActivityEntry>> {
  static const _key = 'activities';

  @override
  Future<List<ActivityEntry>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ActivityEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add(
    String activity,
    int minutes, {
    String? effort,
    String? outcome,
    String? notes,
  }) async {
    final entry = ActivityEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      activity: activity,
      minutes: minutes,
      effort: effort,
      outcome: outcome,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );
    final current = state.valueOrNull ?? [];
    final updated = [entry, ...current];
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }
}

final activityProvider =
    AsyncNotifierProvider<ActivityNotifier, List<ActivityEntry>>(
        ActivityNotifier.new);

// ─── Sleep log ────────────────────────────────────────────────────────────────

class SleepEntry {
  final String id;
  final DateTime date;
  final double hours;
  final int quality; // 1–5
  final List<String> factors;
  final String? notes;

  const SleepEntry({
    required this.id,
    required this.date,
    required this.hours,
    required this.quality,
    this.factors = const [],
    this.notes,
  });

  factory SleepEntry.fromJson(Map<String, dynamic> j) => SleepEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        hours: (j['hours'] as num).toDouble(),
        quality: j['quality'] as int,
        factors: ((j['factors'] as List<dynamic>?) ?? const <dynamic>[])
            .map((e) => e.toString())
            .toList(),
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'hours': hours,
        'quality': quality,
        if (factors.isNotEmpty) 'factors': factors,
        if (notes != null) 'notes': notes,
      };
}

class SleepNotifier extends AsyncNotifier<List<SleepEntry>> {
  static const _key = 'sleep_logs';

  @override
  Future<List<SleepEntry>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SleepEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add(
    double hours,
    int quality, {
    List<String> factors = const [],
    String? notes,
  }) async {
    final entry = SleepEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      hours: hours,
      quality: quality,
      factors: factors
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );
    final current = state.valueOrNull ?? [];
    final updated = [entry, ...current];
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }
}

final sleepProvider =
    AsyncNotifierProvider<SleepNotifier, List<SleepEntry>>(SleepNotifier.new);
