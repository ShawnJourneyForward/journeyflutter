import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../utils/encrypted_store.dart';

// ─── Safe JSON list parsing ───────────────────────────────────────────────────
// Single source of truth for "decode a stored JSON list, tolerate malformed
// entries". A single bad entry must NEVER cause the whole collection to be
// wiped — that was the previous behaviour and it could silently destroy a
// user's entire journal/slips/cravings history on one corrupt date string.
List<T> _safeParseList<T>(
    String? raw, T Function(Map<String, dynamic>) fromJson) {
  if (raw == null) return <T>[];
  late final List<dynamic> list;
  try {
    list = jsonDecode(raw) as List<dynamic>;
  } catch (e) {
    debugPrint('[app_providers] JSON decode failed: $e');
    return <T>[];
  }
  final results = <T>[];
  for (final e in list) {
    try {
      results.add(fromJson(e as Map<String, dynamic>));
    } catch (err) {
      debugPrint('[app_providers] Skipping malformed entry: $err');
    }
  }
  return results;
}

/// Parse a stored ISO-8601 date string with a safe fallback so a single bad
/// value does not throw out of a `fromJson` factory.
DateTime _safeParseDate(String? raw) =>
    raw == null ? DateTime.now() : (DateTime.tryParse(raw) ?? DateTime.now());

// ─── 1-second tick ────────────────────────────────────────────────────────────

final timerProvider = StreamProvider<DateTime>((ref) =>
    Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()));

// ─── SharedPreferences instance ───────────────────────────────────────────────

final prefsProvider =
    FutureProvider<SharedPreferences>((_) => SharedPreferences.getInstance());

// ─── Profile ──────────────────────────────────────────────────────────────────

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  // Encrypted-storage key for the actual profile JSON.
  static const _dataKey = 'profile';
  // Legacy plaintext key — only read for one-shot migration off plaintext.
  static const _legacyKey = 'profile';
  // Synchronous presence sentinel in plain SharedPreferences. Must be a
  // DIFFERENT key from _dataKey or the router redirect's prefs read will
  // collide with the migration path and silently corrupt the encrypted
  // value (this is what broke the previous build — the sentinel '1' got
  // copied into encrypted storage and clobbered the real JSON).
  static const _existsKey = 'has_profile';

  @override
  Future<UserProfile?> build() async {
    final prefs = await ref.watch(prefsProvider.future);

    // Path 1: read from encrypted storage (the new home).
    String? raw = await EncryptedStore.read(_dataKey);

    // Recovery: detect the '1' corruption from the broken first build of
    // the encrypted-storage migration (where the presence sentinel collided
    // with the data key and ended up written into EncryptedStore). Anything
    // that isn't a JSON object is invalid profile data — wipe it so we
    // fall through to the legacy/empty paths cleanly.
    if (raw != null && !raw.startsWith('{')) {
      debugPrint('[ProfileNotifier] wiping corrupted encrypted value: $raw');
      await EncryptedStore.delete(_dataKey);
      raw = null;
    }

    // Path 2: legacy migration. If nothing in encrypted storage but the
    // old plaintext key has JSON, copy it across. Only treat the value as
    // a real profile if it looks like JSON (starts with '{') — protects
    // against any leftover '1' sentinel from the broken build.
    if (raw == null) {
      final legacy = prefs.getString(_legacyKey);
      if (legacy != null && legacy.startsWith('{')) {
        try {
          await EncryptedStore.write(_dataKey, legacy);
          await prefs.setString(_existsKey, '1');
          await prefs.remove(_legacyKey);
          raw = legacy;
        } catch (e) {
          // Keystore temporarily unavailable — fall through and return null.
          // The migration will be retried on the next cold start.
          debugPrint('[ProfileNotifier] migration write failed: $e');
        }
      } else if (legacy != null) {
        // It's a stale sentinel from the broken build (value '1'). Wipe it
        // so the router redirect stops treating it as "profile exists" and
        // the user gets a clean onboarding instead of a permanent spinner.
        await prefs.remove(_legacyKey);
        await prefs.remove(_existsKey);
      }
    } else {
      // Encrypted data exists — make sure the sentinel is in sync so the
      // router redirect lets the user reach /home on the next cold start.
      if (prefs.getString(_existsKey) == null) {
        await prefs.setString(_existsKey, '1');
      }
    }

    if (raw == null) {
      // No profile data anywhere — make sure the synchronous router-redirect
      // sentinel ('has_profile' in plain prefs) is ALSO cleared. Otherwise
      // the router keeps sending the user to /home (because the sentinel
      // still claims a profile exists), the home screen sees null and tries
      // to redirect to /onboarding, and the router bounces them right back.
      // That's exactly the stuck-loading-screen-after-cold-restart bug.
      if (prefs.getString(_existsKey) != null) {
        await prefs.remove(_existsKey);
      }
      return null;
    }
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[ProfileNotifier] failed to decode profile: $e');
      if (prefs.getString(_existsKey) != null) {
        await prefs.remove(_existsKey);
      }
      return null;
    }
  }

  Future<void> save(UserProfile profile) async {
    // Write JSON to encrypted storage; write the presence sentinel to the
    // SEPARATE 'has_profile' prefs key so the router redirect (which reads
    // prefs synchronously in main.dart) can answer "is there a profile?"
    // without waiting on encrypted storage and without colliding with the
    // data key.
    final prefs = await ref.read(prefsProvider.future);
    final json = profile.toJsonString();
    await EncryptedStore.write(_dataKey, json);
    await prefs.setString(_existsKey, '1');
    // Remove any legacy plaintext profile entry so future loads only see
    // the encrypted value.
    await prefs.remove(_legacyKey);
    state = AsyncData(profile);
  }

  Future<void> patch(UserProfile Function(UserProfile) updater) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await save(updater(current));
  }

  // copyWith uses the _absent sentinel so it can safely clear nullable fields.
  Future<void> patchGoal(
          {required double? amount, required String? name}) async =>
      patch((p) => p.copyWith(savingsGoal: amount, savingsGoalName: name));
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

// ─── 10-second tick — for money display (live but scroll-safe) ───────────────

/// Exposed (no underscore) so widget tests can override it to a single
/// value — left private it kept `Timer.periodic` running after the widget
/// tree was disposed, which trips the test-binding invariant check.
final slowTimerProvider = StreamProvider<DateTime>((ref) =>
    Stream.periodic(const Duration(seconds: 10), (_) => DateTime.now()));

/// Sober stats that refresh every 10 seconds.
/// Use for money-saved displays: live enough to feel real, not fast enough
/// to cause scroll jitter.
final soberMoneyProvider = Provider<SoberStats?>((ref) {
  final profileAsync = ref.watch(profileProvider);
  final now = ref.watch(slowTimerProvider).value ?? DateTime.now();
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
    try {
      final list = (jsonDecode(raw) as List<dynamic>);
      final today = _today();
      for (final entry in list.reversed) {
        try {
          final m = entry as Map<String, dynamic>;
          if ((m['date'] as String?) == today) return m['text'] as String?;
        } catch (_) {
          // Skip malformed entry, keep scanning.
        }
      }
      return null;
    } catch (e) {
      // JSON decode failure — don't wipe the user's gratitude history.
      debugPrint('[GratitudeNotifier] decode failed: $e');
      return null;
    }
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
  const GratitudeEntry(
      {required this.id, required this.date, required this.text});

  factory GratitudeEntry.fromJson(Map<String, dynamic> j) => GratitudeEntry(
        id: j['id'] as String? ??
            j['date'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        date: j['date'] as String? ?? '',
        text: j['text'] as String? ?? '',
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

// ─── Weekly goal completion toggles (persisted) ───────────────────────────────

class WeeklyGoalTogglesNotifier extends Notifier<Set<int>> {
  static const _key = 'weekly_goal_toggles';

  @override
  Set<int> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    final prefs = await ref.read(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) {
      _loadedCompleter.complete();
      return;
    }
    try {
      final list = (jsonDecode(raw) as List<dynamic>).whereType<int>().toSet();
      state = list;
    } catch (e) {
      debugPrint('[WeeklyGoalToggles] decode failed: $e');
    } finally {
      if (!_loadedCompleter.isCompleted) _loadedCompleter.complete();
    }
  }

  /// Resolved once `_load()` has finished. `toggle()` awaits this so a user
  /// tap in the first ~200 ms after launch can't be silently overwritten by
  /// a late-arriving disk read.
  final _loadedCompleter = Completer<void>();

  Future<void> toggle(int index) async {
    await _loadedCompleter.future;
    final n = Set<int>.from(state);
    n.contains(index) ? n.remove(index) : n.add(index);
    state = n;
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(_key, jsonEncode(n.toList()));
  }
}

final weeklyGoalTogglesProvider =
    NotifierProvider<WeeklyGoalTogglesNotifier, Set<int>>(
        WeeklyGoalTogglesNotifier.new);

// ─── Daily mission completion toggles (persisted, resets each day) ────────────

class MissionTogglesNotifier extends Notifier<Set<int>> {
  static const _key = 'mission_toggles';

  @override
  Set<int> build() {
    _load();
    return const {};
  }

  final _loadedCompleter = Completer<void>();

  Future<void> _load() async {
    final prefs = await ref.read(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) {
      _loadedCompleter.complete();
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['date'] != _today()) {
        await prefs.remove(_key);
        return;
      }
      state = (map['done'] as List<dynamic>).whereType<int>().toSet();
    } catch (e) {
      debugPrint('[MissionToggles] decode failed: $e');
    } finally {
      if (!_loadedCompleter.isCompleted) _loadedCompleter.complete();
    }
  }

  Future<void> toggle(int index) async {
    await _loadedCompleter.future;
    final n = Set<int>.from(state);
    n.contains(index) ? n.remove(index) : n.add(index);
    state = n;
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(
        _key, jsonEncode({'date': _today(), 'done': n.toList()}));
  }

  String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

final missionTogglesProvider =
    NotifierProvider<MissionTogglesNotifier, Set<int>>(
        MissionTogglesNotifier.new);

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
        date: _safeParseDate(j['date'] as String?),
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
    return _safeParseList(raw, JournalEntry.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Serialize writes so two rapid add() / delete() calls can't read the same
  // `state.valueOrNull` snapshot and overwrite each other.
  Future<void> _writeLock = Future.value();

  Future<void> add(String text, String mood) =>
      _writeLock = _writeLock.then((_) async {
        final entry = JournalEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          text: text,
          mood: mood,
        );
        final current = state.valueOrNull ?? [];
        final updated = [entry, ...current];
        final prefs = await ref.read(prefsProvider.future);
        await prefs.setString(
          _key,
          jsonEncode(updated.map((e) => e.toJson()).toList()),
        );
        state = AsyncData(updated);
      });

  Future<void> delete(String id) => _writeLock = _writeLock.then((_) async {
        final current = state.valueOrNull ?? [];
        final updated = current.where((e) => e.id != id).toList();
        final prefs = await ref.read(prefsProvider.future);
        await prefs.setString(
          _key,
          jsonEncode(updated.map((e) => e.toJson()).toList()),
        );
        state = AsyncData(updated);
      });
}

final journalProvider =
    AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(
        JournalNotifier.new);

// ─── Custom affirmations ──────────────────────────────────────────────────────

class AffirmationNotifier extends AsyncNotifier<List<String>> {
  static const _key = 'custom_affirmations';

  @override
  Future<List<String>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      // Skip non-string entries instead of wiping the whole list.
      final list = jsonDecode(raw) as List<dynamic>;
      return list.whereType<String>().toList();
    } catch (e) {
      debugPrint('[Affirmations] JSON decode failed: $e');
      return [];
    }
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
    AsyncNotifierProvider<AffirmationNotifier, List<String>>(
        AffirmationNotifier.new);

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
    return _safeParseList(raw, VisionItem.fromJson);
  }

  Future<void> add(VisionItem item) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, item];
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((e) => e.id != id).toList();
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }
}

final visionBoardProvider =
    AsyncNotifierProvider<VisionBoardNotifier, List<VisionItem>>(
        VisionBoardNotifier.new);

// ─── Slip log ─────────────────────────────────────────────────────────────────

class Slip {
  final String id;
  final DateTime date;
  final int streakDays; // streak length at time of slip
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
        id: j['id'] as String,
        date: _safeParseDate(j['date'] as String?),
        streakDays: j['streakDays'] as int,
        previousSoberDate: j['previousSoberDate'] as String,
        note: j['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'streakDays': streakDays,
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
    return _safeParseList(raw, Slip.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> record({required UserProfile current, String? note}) async {
    final now = DateTime.now();
    final slip = Slip(
      id: now.millisecondsSinceEpoch.toString(),
      date: now,
      streakDays: SoberStats.compute(current, now).days,
      previousSoberDate: current.soberDate,
      note: note,
    );

    final prefs = await ref.read(prefsProvider.future);
    final existing = state.valueOrNull ?? [];
    final updated = [slip, ...existing];
    final priorSlipJson = prefs.getString(_key); // for rollback

    // ── Atomic two-step write ────────────────────────────────────────────────
    // Step 1: persist the slip log. Step 2: reset the profile streak. If
    // step 2 throws, roll step 1 back so the slip log can never show a
    // recorded slip while the profile still claims an active streak.
    try {
      await prefs.setString(
        _key,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );

      await ref.read(profileProvider.notifier).patch(
            (p) => p.copyWith(
              soberDate: now.toIso8601String(),
              firedMilestoneDays: [],
              firedSavingsTiers: [],
            ),
          );

      // Both succeeded — commit the in-memory state.
      state = AsyncData(updated);
    } catch (e) {
      // Roll back the slip log write so it stays consistent with the profile.
      if (priorSlipJson == null) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, priorSlipJson);
      }
      // Re-throw so the calling UI can surface the failure to the user.
      rethrow;
    }
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
        date: _safeParseDate(j['date'] as String?),
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
    return _safeParseList(raw, CravingEntry.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _writeLock = Future.value();

  Future<void> add(
    int intensity, {
    String? trigger,
    String? severity,
    List<String> triggers = const [],
    int? durationMinutes,
    String? notes,
  }) =>
      _writeLock = _writeLock.then((_) async {
        final cleanTriggers =
            triggers.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
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
      });
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
        date: _safeParseDate(j['date'] as String?),
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
    return _safeParseList(raw, ThoughtEntry.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _writeLock = Future.value();

  Future<void> add(
    String text,
    String type, {
    String? strength,
    List<String> triggers = const [],
    int? durationMinutes,
    String? notes,
  }) =>
      _writeLock = _writeLock.then((_) async {
        final entry = ThoughtEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          text: text,
          type: type,
          strength: strength,
          triggers:
              triggers.map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
          durationMinutes: durationMinutes,
          notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        );
        final current = state.valueOrNull ?? [];
        final updated = [entry, ...current];
        final prefs = await ref.read(prefsProvider.future);
        await prefs.setString(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      });
}

final thoughtProvider =
    AsyncNotifierProvider<ThoughtNotifier, List<ThoughtEntry>>(
        ThoughtNotifier.new);

// ─── Activity log ─────────────────────────────────────────────────────────────

class ActivityEntry {
  final String id;
  final DateTime date;
  // 'walk' | 'run' | 'cycle' | 'swim' | 'weights' | 'yoga' | 'other'
  final String activity;
  final int minutes;
  final String? effort;
  final String? outcome;
  final String? notes;

  /// Distance in kilometres — only recorded for run / cycle / swim.
  final double? distance;

  const ActivityEntry({
    required this.id,
    required this.date,
    required this.activity,
    required this.minutes,
    this.effort,
    this.outcome,
    this.notes,
    this.distance,
  });

  factory ActivityEntry.fromJson(Map<String, dynamic> j) => ActivityEntry(
        id: j['id'] as String,
        date: _safeParseDate(j['date'] as String?),
        activity: j['activity'] as String,
        minutes: j['minutes'] as int,
        effort: j['effort'] as String?,
        outcome: j['outcome'] as String?,
        notes: j['notes'] as String?,
        distance: (j['distance'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'activity': activity,
        'minutes': minutes,
        if (effort != null) 'effort': effort,
        if (outcome != null) 'outcome': outcome,
        if (notes != null) 'notes': notes,
        if (distance != null) 'distance': distance,
      };
}

class ActivityNotifier extends AsyncNotifier<List<ActivityEntry>> {
  static const _key = 'activities';

  @override
  Future<List<ActivityEntry>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    return _safeParseList(raw, ActivityEntry.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _writeLock = Future.value();

  Future<void> add(
    String activity,
    int minutes, {
    String? effort,
    String? outcome,
    String? notes,
    double? distance,
  }) =>
      _writeLock = _writeLock.then((_) async {
        final entry = ActivityEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          activity: activity,
          minutes: minutes,
          effort: effort,
          outcome: outcome,
          notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
          distance: distance,
        );
        final current = state.valueOrNull ?? [];
        final updated = [entry, ...current];
        final prefs = await ref.read(prefsProvider.future);
        await prefs.setString(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      });
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
        date: _safeParseDate(j['date'] as String?),
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
    return _safeParseList(raw, SleepEntry.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _writeLock = Future.value();

  Future<void> add(
    double hours,
    int quality, {
    List<String> factors = const [],
    String? notes,
  }) =>
      _writeLock = _writeLock.then((_) async {
        final entry = SleepEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          hours: hours,
          quality: quality,
          factors:
              factors.map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
          notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        );
        final current = state.valueOrNull ?? [];
        final updated = [entry, ...current];
        final prefs = await ref.read(prefsProvider.future);
        await prefs.setString(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      });
}

final sleepProvider =
    AsyncNotifierProvider<SleepNotifier, List<SleepEntry>>(SleepNotifier.new);

// ─── Meetings (recovery groups, sponsor calls, therapy, etc.) ────────────────

class Meeting {
  final String id;
  final String title;
  final DateTime dateTime;
  final String? location;
  final String? notes;
  final bool notify;
  /// Minutes before [dateTime] to fire a reminder notification.
  /// Common values: 5, 15, 30, 60, 1440 (1 day). Ignored when [notify] is false.
  final int reminderMinutesBefore;

  const Meeting({
    required this.id,
    required this.title,
    required this.dateTime,
    this.location,
    this.notes,
    this.notify = true,
    this.reminderMinutesBefore = 15,
  });

  Meeting copyWith({
    String? title,
    DateTime? dateTime,
    String? location,
    String? notes,
    bool? notify,
    int? reminderMinutesBefore,
  }) =>
      Meeting(
        id: id,
        title: title ?? this.title,
        dateTime: dateTime ?? this.dateTime,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        notify: notify ?? this.notify,
        reminderMinutesBefore:
            reminderMinutesBefore ?? this.reminderMinutesBefore,
      );

  factory Meeting.fromJson(Map<String, dynamic> j) => Meeting(
        id: j['id'] as String,
        title: j['title'] as String,
        dateTime: _safeParseDate(j['dateTime'] as String?),
        location: j['location'] as String?,
        notes: j['notes'] as String?,
        notify: (j['notify'] as bool?) ?? true,
        reminderMinutesBefore:
            (j['reminderMinutesBefore'] as num?)?.toInt() ?? 15,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateTime': dateTime.toIso8601String(),
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
        'notify': notify,
        'reminderMinutesBefore': reminderMinutesBefore,
      };
}

class MeetingsNotifier extends AsyncNotifier<List<Meeting>> {
  static const _key = 'meetings';

  @override
  Future<List<Meeting>> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    return _safeParseList(raw, Meeting.fromJson)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<void> _persist(List<Meeting> list) async {
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString(
        _key, jsonEncode(list.map((e) => e.toJson()).toList()));
    state = AsyncData(list);
  }

  Future<void> add(Meeting meeting) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, meeting]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    await _persist(updated);
  }

  // Renamed away from `update` because Riverpod's [AsyncNotifier] already
  // defines an `update` with a different signature.
  Future<void> edit(Meeting meeting) async {
    final current = state.valueOrNull ?? [];
    final updated = current
        .map((m) => m.id == meeting.id ? meeting : m)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    await _persist(updated);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((m) => m.id != id).toList();
    await _persist(updated);
  }
}

final meetingsProvider =
    AsyncNotifierProvider<MeetingsNotifier, List<Meeting>>(
        MeetingsNotifier.new);
