import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode, Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/future_letter.dart';
import '../models/hard_day.dart';
import '../models/thought_record.dart';
import '../models/urge_ride.dart';
import '../models/user_profile.dart';
import '../utils/encrypted_store.dart';

// ─── Secure storage helper ───────────────────────────────────────────────────
//
// All sensitive collections (journal, cravings, thoughts, slips, etc.) are
// stored in EncryptedStore (Android Keystore–backed EncryptedSharedPreferences)
// rather than plain SharedPreferences. A one-shot startup migration
// (StorageMigration.migrateAll) moves any existing plain entries across on
// first launch; subsequent reads/writes go straight to EncryptedStore.
//
// SharedPreferences is still used for non-sensitive state: lock method flag,
// profile presence sentinel, notification prefs, goal toggles, etc.

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
    raw == null ? DateTime(2000) : (DateTime.tryParse(raw) ?? DateTime(2000));

/// Nullable variant: returns null for null/invalid input instead of `now()`.
/// Used for genuinely optional date fields (e.g. vision target date).
DateTime? _nullableParseDate(String? raw) =>
    raw == null ? null : DateTime.tryParse(raw);

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
    // Mirror the sober date (and only the sober date) into plain prefs so
    // the home-screen widget — which cannot read encrypted storage — can
    // render the streak. Sober date alone is what's already visible on the
    // lock screen counter, so this doesn't widen the user's exposure.
    await prefs.setString('profile_sober_date', profile.soberDate);
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

// ─── Progress screen tab index ────────────────────────────────────────────────
// Settings "Mood & craving insights" sets this to 1 before navigating to /progress.
final progressTabProvider = StateProvider<int>((ref) => 0);

// ─── App start date (Day 1 of app use, NOT sober date) ───────────────────────
// Anchors the mini cravings heatmap so a user who is already 3 weeks sober
// when they install still sees Day 1 = today, not 21 cells of greyed-out
// pre-start dates. Lazy-initialised: the first read writes today's date and
// keeps it forever. Stored in plain SharedPreferences (no encryption needed —
// install date is not sensitive).
class AppStartDateNotifier extends AsyncNotifier<DateTime> {
  static const _key = 'app_start_date'; // YYYY-MM-DD

  @override
  Future<DateTime> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    final raw = prefs.getString(_key);
    if (raw != null) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return DateTime(parsed.year, parsed.month, parsed.day);
      }
    }
    // First read → freeze today as Day 1 forever.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await prefs.setString(_key, today.toIso8601String().substring(0, 10));
    return today;
  }
}

final appStartDateProvider =
    AsyncNotifierProvider<AppStartDateNotifier, DateTime>(
        AppStartDateNotifier.new);

// ─── Show / hide the mini cravings heatmap on Progress screen ────────────────
// Users further into recovery often don't have frequent cravings; the heatmap
// just shows a wall of empty cells. They can hide it from the card itself
// (and re-enable from settings). Default true so new users see it.
class ShowCravingsHeatmapNotifier extends AsyncNotifier<bool> {
  static const _key = 'progress_show_cravings_heatmap';

  @override
  Future<bool> build() async {
    final prefs = await ref.watch(prefsProvider.future);
    return prefs.getBool(_key) ?? true;
  }

  Future<void> setVisible(bool visible) async {
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setBool(_key, visible);
    state = AsyncData(visible);
  }
}

final showCravingsHeatmapProvider =
    AsyncNotifierProvider<ShowCravingsHeatmapNotifier, bool>(
        ShowCravingsHeatmapNotifier.new);

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
    final raw = await EncryptedStore.read(_key);
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
    final raw = await EncryptedStore.read(_key);
    final list = raw != null
        ? (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    // Upsert: remove any existing entry for today before adding the new one
    // so calling add() twice on the same day replaces rather than duplicates.
    final today = _today();
    list.removeWhere((m) => m['date'] == today);
    list.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': today,
      'text': text,
    });
    await EncryptedStore.write(_key, jsonEncode(list));
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
  // Re-run when today's gratitude changes
  ref.watch(gratitudeProvider);
  final raw = await EncryptedStore.read('gratitude');
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

  // v2 fields — all optional, all backwards-compatible. Old JSON loads cleanly
  // and picks up the safe defaults below.
  final String? subMood; // refined feeling: 'ashamed', 'proud', 'grieving', …
  final List<String> tags; // user-defined themes: 'work', 'family', 'ex', …
  final String? promptId; // which seed prompt the user picked, if any
  final bool locked; // requires re-auth to view; hide preview in list
  final DateTime? editedAt; // null until the user edits the original entry
  final List<String> attachments; // reserved for v2.1 (photos / audio paths)

  const JournalEntry({
    required this.id,
    required this.date,
    required this.text,
    required this.mood,
    this.subMood,
    this.tags = const [],
    this.promptId,
    this.locked = false,
    this.editedAt,
    this.attachments = const [],
  });

  factory JournalEntry.fromJson(Map<String, dynamic> j) {
    final tagList = <String>[];
    final rawTags = j['tags'];
    if (rawTags is List) {
      for (final t in rawTags) {
        if (t is String && t.trim().isNotEmpty) tagList.add(t);
      }
    }
    final attachList = <String>[];
    final rawAttach = j['attachments'];
    if (rawAttach is List) {
      for (final a in rawAttach) {
        if (a is String && a.isNotEmpty) attachList.add(a);
      }
    }
    return JournalEntry(
      id: j['id'] as String,
      date: _safeParseDate(j['date'] as String?),
      text: j['text'] as String,
      mood: (j['mood'] as String?) ?? 'okay',
      subMood: j['subMood'] as String?,
      tags: tagList,
      promptId: j['promptId'] as String?,
      locked: (j['locked'] as bool?) ?? false,
      editedAt: _nullableParseDate(j['editedAt'] as String?),
      attachments: attachList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'text': text,
        'mood': mood,
        if (subMood != null) 'subMood': subMood,
        if (tags.isNotEmpty) 'tags': tags,
        if (promptId != null) 'promptId': promptId,
        if (locked) 'locked': true,
        if (editedAt != null) 'editedAt': editedAt!.toIso8601String(),
        if (attachments.isNotEmpty) 'attachments': attachments,
      };

  JournalEntry copyWith({
    String? text,
    String? mood,
    Object? subMood = _sentinel,
    List<String>? tags,
    Object? promptId = _sentinel,
    bool? locked,
    Object? editedAt = _sentinel,
    List<String>? attachments,
  }) =>
      JournalEntry(
        id: id,
        date: date,
        text: text ?? this.text,
        mood: mood ?? this.mood,
        subMood: subMood == _sentinel ? this.subMood : subMood as String?,
        tags: tags ?? this.tags,
        promptId: promptId == _sentinel ? this.promptId : promptId as String?,
        locked: locked ?? this.locked,
        editedAt: editedAt == _sentinel ? this.editedAt : editedAt as DateTime?,
        attachments: attachments ?? this.attachments,
      );
}

class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  static const _key = 'journal_entries';

  @override
  Future<List<JournalEntry>> build() async {
    final raw = await EncryptedStore.read(_key);
    return _safeParseList(raw, JournalEntry.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Serialize writes so two rapid add() / delete() calls can't read the same
  // `state.valueOrNull` snapshot and overwrite each other.
  Future<void> _writeLock = Future.value();

  /// Add a new entry. The optional v2 args let the new entry sheet supply
  /// the richer fields without changing the old call-sites that just pass
  /// (text, mood).
  Future<void> add(
    String text,
    String mood, {
    String? subMood,
    List<String> tags = const [],
    String? promptId,
    bool locked = false,
  }) =>
      _writeLock = _writeLock.then((_) async {
        final entry = JournalEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          text: text,
          mood: mood,
          subMood: subMood,
          tags: tags,
          promptId: promptId,
          locked: locked,
        );
        final current = state.valueOrNull ?? [];
        final updated = [entry, ...current];
        await EncryptedStore.write(
          _key,
          jsonEncode(updated.map((e) => e.toJson()).toList()),
        );
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[JournalNotifier] write error: $e');
      });

  /// Edit an existing entry. Stamps `editedAt` so the UI can show that a
  /// historical entry has been revised — important transparency for a diary.
  /// (Named `editEntry` rather than `update` because AsyncNotifier already
  /// has an inherited `update` for transforming state.)
  Future<void> editEntry(
    String id, {
    String? text,
    String? mood,
    Object? subMood = _sentinel,
    List<String>? tags,
    bool? locked,
  }) =>
      _writeLock = _writeLock.then((_) async {
        final current = state.valueOrNull ?? [];
        final updated = current.map((e) {
          if (e.id != id) return e;
          return e.copyWith(
            text: text,
            mood: mood,
            subMood: subMood,
            tags: tags,
            locked: locked,
            editedAt: DateTime.now(),
          );
        }).toList();
        await EncryptedStore.write(
          _key,
          jsonEncode(updated.map((e) => e.toJson()).toList()),
        );
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[JournalNotifier] write error: $e');
      });

  /// Flip the locked flag without touching `editedAt` — locking isn't an
  /// edit to the content itself.
  Future<void> toggleLocked(String id) =>
      _writeLock = _writeLock.then((_) async {
        final current = state.valueOrNull ?? [];
        final updated = current.map((e) {
          if (e.id != id) return e;
          return e.copyWith(locked: !e.locked);
        }).toList();
        await EncryptedStore.write(
          _key,
          jsonEncode(updated.map((e) => e.toJson()).toList()),
        );
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[JournalNotifier] write error: $e');
      });

  Future<void> delete(String id) => _writeLock = _writeLock.then((_) async {
        final current = state.valueOrNull ?? [];
        final updated = current.where((e) => e.id != id).toList();
        await EncryptedStore.write(
          _key,
          jsonEncode(updated.map((e) => e.toJson()).toList()),
        );
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[JournalNotifier] write error: $e');
      });
}

final journalProvider =
    AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(
        JournalNotifier.new);

// ─── Derived diary providers (search, streak, on-this-day) ───────────────────

/// Filter state shared by the diary board. Plain class so a single
/// `copyWith` keeps the board's `setState` calls cheap.
class JournalFilter {
  const JournalFilter({
    this.query = '',
    this.mode = JournalFilterMode.all,
    this.tag,
  });
  final String query;
  final JournalFilterMode mode;
  final String? tag;

  JournalFilter copyWith({
    String? query,
    JournalFilterMode? mode,
    Object? tag = _sentinel,
  }) =>
      JournalFilter(
        query: query ?? this.query,
        mode: mode ?? this.mode,
        tag: tag == _sentinel ? this.tag : tag as String?,
      );

  bool get isEmpty =>
      query.isEmpty && mode == JournalFilterMode.all && tag == null;
}

enum JournalFilterMode { all, today, hard, wins, locked }

final journalFilterProvider =
    StateProvider<JournalFilter>((_) => const JournalFilter());

/// Returns the entries that match the current filter, already sorted newest
/// first (the underlying notifier guarantees that ordering).
final filteredJournalProvider = Provider<List<JournalEntry>>((ref) {
  final all = ref.watch(journalProvider).valueOrNull ?? const [];
  final f = ref.watch(journalFilterProvider);
  if (f.isEmpty) return all;

  final q = f.query.trim().toLowerCase();
  final now = DateTime.now();
  final todayKey = DateTime(now.year, now.month, now.day);

  return all.where((e) {
    // Mode gate first — it's cheaper than the text search.
    switch (f.mode) {
      case JournalFilterMode.all:
        break;
      case JournalFilterMode.today:
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        if (d != todayKey) return false;
        break;
      case JournalFilterMode.hard:
        if (e.mood != 'hard' && e.mood != 'crisis') return false;
        break;
      case JournalFilterMode.wins:
        if (e.mood != 'great' && e.mood != 'good') return false;
        break;
      case JournalFilterMode.locked:
        if (!e.locked) return false;
        break;
    }
    if (f.tag != null && !e.tags.contains(f.tag)) return false;
    if (q.isEmpty) return true;
    // Locked entries are intentionally NOT searched by body text — even
    // surfacing a match would leak the contents.
    if (e.locked) {
      return e.tags.any((t) => t.toLowerCase().contains(q));
    }
    return e.text.toLowerCase().contains(q) ||
        e.tags.any((t) => t.toLowerCase().contains(q));
  }).toList();
});

/// Set of every tag the user has ever used. Drives the suggested-tag chips
/// in the entry sheet so the user reuses their own vocabulary.
final allJournalTagsProvider = Provider<List<String>>((ref) {
  final all = ref.watch(journalProvider).valueOrNull ?? const [];
  final seen = <String>{};
  for (final e in all) {
    seen.addAll(e.tags);
  }
  final list = seen.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return list;
});

/// Consecutive days (ending today or yesterday) that contain at least one
/// journal entry. Used for the gentle streak ribbon above the list.
///
/// "Today or yesterday" matters — if the user hasn't written yet today their
/// streak shouldn't break visually until midnight tomorrow.
final journalStreakProvider = Provider<int>((ref) {
  final all = ref.watch(journalProvider).valueOrNull ?? const [];
  if (all.isEmpty) return 0;
  final days = <DateTime>{};
  for (final e in all) {
    days.add(DateTime(e.date.year, e.date.month, e.date.day));
  }
  final now = DateTime.now();
  var cursor = DateTime(now.year, now.month, now.day);
  // Grace: if no entry yet today, start counting from yesterday.
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }
  var count = 0;
  while (days.contains(cursor)) {
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return count;
});

/// Entries written on the same calendar day (month/day) in prior years. The
/// "on this day" peek card uses this — recovery anniversaries hit hard.
final onThisDayProvider = Provider<List<JournalEntry>>((ref) {
  final all = ref.watch(journalProvider).valueOrNull ?? const [];
  final now = DateTime.now();
  return all
      .where((e) =>
          e.date.month == now.month &&
          e.date.day == now.day &&
          e.date.year != now.year)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date)); // most recent year first
});

// ─── Custom affirmations ──────────────────────────────────────────────────────

class AffirmationNotifier extends AsyncNotifier<List<String>> {
  static const _key = 'custom_affirmations';

  @override
  Future<List<String>> build() async {
    final raw = await EncryptedStore.read(_key);
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
    await EncryptedStore.write(_key, jsonEncode(updated));
    state = AsyncData(updated);
  }

  Future<void> remove(String text) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((e) => e != text).toList();
    await EncryptedStore.write(_key, jsonEncode(updated));
    state = AsyncData(updated);
  }
}

final affirmationProvider =
    AsyncNotifierProvider<AffirmationNotifier, List<String>>(
        AffirmationNotifier.new);

// ─── Vision board items ───────────────────────────────────────────────────────

/// A small concrete step the user wants to take toward a vision.
class VisionMilestone {
  final String id;
  final String text;
  final bool done;

  const VisionMilestone({
    required this.id,
    required this.text,
    this.done = false,
  });

  factory VisionMilestone.fromJson(Map<String, dynamic> j) => VisionMilestone(
        id: (j['id'] as String?) ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        text: (j['text'] as String?) ?? '',
        done: (j['done'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'done': done};

  VisionMilestone copyWith({String? text, bool? done}) => VisionMilestone(
        id: id,
        text: text ?? this.text,
        done: done ?? this.done,
      );
}

/// Life-area buckets used for grouping the board. Stored as the raw key
/// (`growth`, `health`, etc.) — old items without a category land in `none`.
enum VisionCategory {
  none,
  health,
  family,
  career,
  growth,
  freedom,
  adventure,
  service,
  creativity,
}

VisionCategory _categoryFromString(String? s) {
  if (s == null) return VisionCategory.none;
  for (final c in VisionCategory.values) {
    if (c.name == s) return c;
  }
  return VisionCategory.none;
}

class VisionItem {
  final String id;
  final String title;
  final String description;
  final String emoji; // stores icon key (e.g. 'guide') or legacy emoji

  // v2 fields — all optional, all backwards-compatible.
  final List<String> imagePaths;
  final VisionCategory category;
  final DateTime? targetDate;
  final List<VisionMilestone> milestones;
  final String affirmation;
  final String whyItMatters;
  final bool pinned;
  final bool achieved;
  final DateTime? achievedDate;
  final int? accentColor; // ARGB int, optional per-card tint

  const VisionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.imagePaths = const [],
    this.category = VisionCategory.none,
    this.targetDate,
    this.milestones = const [],
    this.affirmation = '',
    this.whyItMatters = '',
    this.pinned = false,
    this.achieved = false,
    this.achievedDate,
    this.accentColor,
  });

  /// Back-compat shim: old call sites still pass a single `imagePath`.
  String? get imagePath => imagePaths.isEmpty ? null : imagePaths.first;

  /// Milestone progress 0..1. Returns 0 for no milestones.
  double get progress {
    if (milestones.isEmpty) return 0.0;
    final done = milestones.where((m) => m.done).length;
    return done / milestones.length;
  }

  factory VisionItem.fromJson(Map<String, dynamic> j) {
    // Migrate single legacy imagePath → imagePaths list.
    final paths = <String>[];
    final legacy = j['imagePath'] as String?;
    if (legacy != null && legacy.isNotEmpty) paths.add(legacy);
    final newList = j['imagePaths'] as List<dynamic>?;
    if (newList != null) {
      for (final p in newList) {
        if (p is String && p.isNotEmpty && !paths.contains(p)) paths.add(p);
      }
    }

    final milestoneJson = j['milestones'] as List<dynamic>?;
    final milestones = <VisionMilestone>[];
    if (milestoneJson != null) {
      for (final m in milestoneJson) {
        try {
          milestones.add(VisionMilestone.fromJson(m as Map<String, dynamic>));
        } catch (_) {}
      }
    }

    return VisionItem(
      id: j['id'] as String,
      title: j['title'] as String,
      description: (j['description'] as String?) ?? '',
      emoji: (j['emoji'] as String?) ?? 'guide',
      imagePaths: paths,
      category: _categoryFromString(j['category'] as String?),
      targetDate: _nullableParseDate(j['targetDate'] as String?),
      milestones: milestones,
      affirmation: (j['affirmation'] as String?) ?? '',
      whyItMatters: (j['whyItMatters'] as String?) ?? '',
      pinned: (j['pinned'] as bool?) ?? false,
      achieved: (j['achieved'] as bool?) ?? false,
      achievedDate: _nullableParseDate(j['achievedDate'] as String?),
      accentColor: j['accentColor'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
        if (imagePaths.isNotEmpty) 'imagePaths': imagePaths,
        if (category != VisionCategory.none) 'category': category.name,
        if (targetDate != null) 'targetDate': targetDate!.toIso8601String(),
        if (milestones.isNotEmpty)
          'milestones': milestones.map((m) => m.toJson()).toList(),
        if (affirmation.isNotEmpty) 'affirmation': affirmation,
        if (whyItMatters.isNotEmpty) 'whyItMatters': whyItMatters,
        if (pinned) 'pinned': true,
        if (achieved) 'achieved': true,
        if (achievedDate != null)
          'achievedDate': achievedDate!.toIso8601String(),
        if (accentColor != null) 'accentColor': accentColor,
      };

  VisionItem copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    List<String>? imagePaths,
    VisionCategory? category,
    Object? targetDate = _sentinel,
    List<VisionMilestone>? milestones,
    String? affirmation,
    String? whyItMatters,
    bool? pinned,
    bool? achieved,
    Object? achievedDate = _sentinel,
    Object? accentColor = _sentinel,
  }) =>
      VisionItem(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        emoji: emoji ?? this.emoji,
        imagePaths: imagePaths ?? this.imagePaths,
        category: category ?? this.category,
        targetDate:
            targetDate == _sentinel ? this.targetDate : targetDate as DateTime?,
        milestones: milestones ?? this.milestones,
        affirmation: affirmation ?? this.affirmation,
        whyItMatters: whyItMatters ?? this.whyItMatters,
        pinned: pinned ?? this.pinned,
        achieved: achieved ?? this.achieved,
        achievedDate: achievedDate == _sentinel
            ? this.achievedDate
            : achievedDate as DateTime?,
        accentColor:
            accentColor == _sentinel ? this.accentColor : accentColor as int?,
      );
}

const _sentinel = Object();

class VisionBoardNotifier extends AsyncNotifier<List<VisionItem>> {
  static const _key = 'vision_board';

  @override
  Future<List<VisionItem>> build() async {
    return _safeParseList(await EncryptedStore.read(_key), VisionItem.fromJson);
  }

  Future<void> add(VisionItem item) async {
    final current = state.valueOrNull ?? [];
    final updated = [...current, item];
    await EncryptedStore.write(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }

  Future<void> saveItem(VisionItem item) async {
    final current = state.valueOrNull ?? [];
    final updated = current.map((e) => e.id == item.id ? item : e).toList();
    await EncryptedStore.write(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((e) => e.id != id).toList();
    await EncryptedStore.write(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }

  /// Toggle the pinned flag. Cap at 3 pinned dreams so the home "North Star"
  /// card stays focused — extra pins are silently ignored.
  Future<void> togglePinned(String id) async {
    final current = state.valueOrNull ?? [];
    final pinnedCount = current.where((e) => e.pinned).length;
    final updated = current.map((e) {
      if (e.id != id) return e;
      if (!e.pinned && pinnedCount >= 3) return e; // cap reached
      return e.copyWith(pinned: !e.pinned);
    }).toList();
    await EncryptedStore.write(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }

  /// Flip the achieved flag. Stamps `achievedDate` on transition to true,
  /// clears it on transition back to active.
  Future<void> toggleAchieved(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.map((e) {
      if (e.id != id) return e;
      final nowAchieved = !e.achieved;
      return e.copyWith(
        achieved: nowAchieved,
        achievedDate: nowAchieved ? DateTime.now() : null,
      );
    }).toList();
    await EncryptedStore.write(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }

  /// Flip a single milestone done/undone.
  Future<void> toggleMilestone(String itemId, String milestoneId) async {
    final current = state.valueOrNull ?? [];
    final updated = current.map((e) {
      if (e.id != itemId) return e;
      final newMilestones = e.milestones
          .map((m) => m.id == milestoneId ? m.copyWith(done: !m.done) : m)
          .toList();
      return e.copyWith(milestones: newMilestones);
    }).toList();
    await EncryptedStore.write(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }

  /// Persist a custom ordering (after drag-reorder on the board).
  Future<void> reorder(List<String> orderedIds) async {
    final current = state.valueOrNull ?? [];
    final byId = {for (final e in current) e.id: e};
    final updated = <VisionItem>[
      for (final id in orderedIds)
        if (byId.containsKey(id)) byId[id]!,
      // Append anything missing from the order list so nothing is lost.
      for (final e in current)
        if (!orderedIds.contains(e.id)) e,
    ];
    await EncryptedStore.write(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }
}

final visionBoardProvider =
    AsyncNotifierProvider<VisionBoardNotifier, List<VisionItem>>(
        VisionBoardNotifier.new);

/// Convenience: just the pinned, active dreams. Used by the home "North Star"
/// surface (v2.1) but exposed now so future wiring is trivial.
final pinnedVisionsProvider = Provider<List<VisionItem>>((ref) {
  final all = ref.watch(visionBoardProvider).valueOrNull ?? const [];
  return all.where((v) => v.pinned && !v.achieved).toList();
});

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
    final raw = await EncryptedStore.read(_key);
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

    final existing = state.valueOrNull ?? [];
    final updated = [slip, ...existing];
    final priorSlipJson = await EncryptedStore.read(_key); // for rollback

    // ── Atomic two-step write ────────────────────────────────────────────────
    // Step 1: persist the slip log. Step 2: reset the profile streak. If
    // step 2 throws, roll step 1 back so the slip log can never show a
    // recorded slip while the profile still claims an active streak.
    try {
      await EncryptedStore.write(
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
        await EncryptedStore.delete(_key);
      } else {
        await EncryptedStore.write(_key, priorSlipJson);
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

  // ── v2 clinical fields ──────────────────────────────────────────────────
  // HALT pre-check: which underlying states were present when the urge hit.
  // Naming the underlying state is one of the highest-evidence craving-
  // interrupt heuristics in addiction medicine (Marlatt). Optional — old
  // records and quick-logs leave it empty.
  final List<String> halt; // any of: 'hungry','angry','lonely','tired'

  // ABC functional analysis — what the user did in response, and what
  // happened. Aggregated across logs to surface "what worked last time"
  // and to auto-update the personal relapse-prevention plan.
  final String? responseChosen; // e.g. 'walked', 'called', 'breathed'
  final String? outcome; // 'stayed_sober' | 'slipped' | 'unclear'

  const CravingEntry({
    required this.id,
    required this.date,
    required this.intensity,
    this.trigger,
    this.severity,
    this.triggers = const [],
    this.durationMinutes,
    this.notes,
    this.halt = const [],
    this.responseChosen,
    this.outcome,
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
        halt: ((j['halt'] as List<dynamic>?) ?? const <dynamic>[])
            .map((e) => e.toString())
            .toList(),
        responseChosen: j['responseChosen'] as String?,
        outcome: j['outcome'] as String?,
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
        if (halt.isNotEmpty) 'halt': halt,
        if (responseChosen != null) 'responseChosen': responseChosen,
        if (outcome != null) 'outcome': outcome,
      };
}

class CravingNotifier extends AsyncNotifier<List<CravingEntry>> {
  static const _key = 'cravings';

  @override
  Future<List<CravingEntry>> build() async {
    final raw = await EncryptedStore.read(_key);
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
    List<String> halt = const [],
    String? responseChosen,
    String? outcome,
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
          halt: halt,
          responseChosen: responseChosen,
          outcome: outcome,
        );
        final current = state.valueOrNull ?? [];
        final updated = [entry, ...current];
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[CravingNotifier] write error: $e');
      });

  Future<void> delete(String id) => _writeLock = _writeLock.then((_) async {
        final current = state.valueOrNull ?? [];
        final updated = current.where((e) => e.id != id).toList();
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[CravingNotifier] write error: $e');
      });
}

final cravingProvider =
    AsyncNotifierProvider<CravingNotifier, List<CravingEntry>>(
        CravingNotifier.new);

// ─── Daily Intention (morning ↔ evening pairing) ─────────────────────────────
//
// Behavior-change research (BJ Fogg, Wendy Wood) consistently shows that
// pairing an explicit morning intention with an evening review is one of the
// strongest single behavioral practices for habit formation. We store one
// intention per local-calendar day, and let the user mark it `did`, `partly`,
// or `not_yet` later in the day. `not_yet` is intentional (not "failed") —
// the user might still get to it before sleep.

class DailyIntention {
  final String id;
  final DateTime date; // local-day key — use only y/m/d when comparing
  final String text;
  final String? outcome; // null | 'did' | 'partly' | 'not_yet'
  final DateTime? reviewedAt;

  const DailyIntention({
    required this.id,
    required this.date,
    required this.text,
    this.outcome,
    this.reviewedAt,
  });

  factory DailyIntention.fromJson(Map<String, dynamic> j) => DailyIntention(
        id: j['id'] as String,
        date: _safeParseDate(j['date'] as String?),
        text: (j['text'] as String?) ?? '',
        outcome: j['outcome'] as String?,
        reviewedAt: j['reviewedAt'] != null
            ? _safeParseDate(j['reviewedAt'] as String?)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'text': text,
        if (outcome != null) 'outcome': outcome,
        if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
      };
}

class IntentionNotifier extends AsyncNotifier<List<DailyIntention>> {
  static const _key = 'daily_intentions';

  @override
  Future<List<DailyIntention>> build() async {
    return _safeParseList(
        await EncryptedStore.read(_key), DailyIntention.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _writeLock = Future.value();

  /// Set (or replace) today's morning intention. There's only ever one per
  /// local day — editing pre-evening replaces the text in place.
  Future<void> setToday(String text) => _writeLock = _writeLock.then((_) async {
        final trimmed = text.trim();
        if (trimmed.isEmpty) return;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final current = state.valueOrNull ?? [];
        final existing = current.indexWhere((e) =>
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day);
        final entry = DailyIntention(
          id: existing >= 0
              ? current[existing].id
              : now.millisecondsSinceEpoch.toString(),
          date: today,
          text: trimmed,
          outcome: existing >= 0 ? current[existing].outcome : null,
          reviewedAt: existing >= 0 ? current[existing].reviewedAt : null,
        );
        final updated = [...current];
        if (existing >= 0) {
          updated[existing] = entry;
        } else {
          updated.insert(0, entry);
        }
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[IntentionNotifier] write error: $e');
      });

  /// Stamp the evening review on today's intention.
  Future<void> reviewToday(String outcome) =>
      _writeLock = _writeLock.then((_) async {
        final now = DateTime.now();
        final current = state.valueOrNull ?? [];
        final idx = current.indexWhere((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day);
        if (idx < 0) return; // can't review what wasn't set
        final updated = [...current];
        updated[idx] = DailyIntention(
          id: current[idx].id,
          date: current[idx].date,
          text: current[idx].text,
          outcome: outcome,
          reviewedAt: now,
        );
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[IntentionNotifier] write error: $e');
      });
}

final intentionProvider =
    AsyncNotifierProvider<IntentionNotifier, List<DailyIntention>>(
        IntentionNotifier.new);

/// Today's intention, or null if none set yet. Watched by Home so the
/// morning prompt or evening review surfaces at the right time.
final todaysIntentionProvider = Provider<DailyIntention?>((ref) {
  final list = ref.watch(intentionProvider).valueOrNull ?? const [];
  final now = DateTime.now();
  for (final e in list) {
    if (e.date.year == now.year &&
        e.date.month == now.month &&
        e.date.day == now.day) return e;
  }
  return null;
});

// ─── Recovery Capital (weekly check) ──────────────────────────────────────────
//
// William White & John Kelly's research frames recovery as accumulation of
// "recovery capital" — relationships, meaning, health, environment. Tracking
// these signals weekly (not daily — that would feel like another chore)
// produces a multi-dimensional picture of growth that pure sober-day counts
// miss. We store one entry per ISO week.

class RecoveryCapitalWeek {
  final String id;
  final DateTime weekStart; // Monday of the week, local
  final bool connected; // talked to a supportive person
  final bool physical; // moved my body
  final bool slept; // slept enough most nights
  final bool helpfulPlace; // spent time somewhere good for me
  final bool meaningful; // did something I find meaningful
  final String? note;

  const RecoveryCapitalWeek({
    required this.id,
    required this.weekStart,
    required this.connected,
    required this.physical,
    required this.slept,
    required this.helpfulPlace,
    required this.meaningful,
    this.note,
  });

  int get score => [connected, physical, slept, helpfulPlace, meaningful]
      .where((b) => b)
      .length;

  factory RecoveryCapitalWeek.fromJson(Map<String, dynamic> j) =>
      RecoveryCapitalWeek(
        id: j['id'] as String,
        weekStart: _safeParseDate(j['weekStart'] as String?),
        connected: (j['connected'] as bool?) ?? false,
        physical: (j['physical'] as bool?) ?? false,
        slept: (j['slept'] as bool?) ?? false,
        helpfulPlace: (j['helpfulPlace'] as bool?) ?? false,
        meaningful: (j['meaningful'] as bool?) ?? false,
        note: j['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'weekStart': weekStart.toIso8601String(),
        'connected': connected,
        'physical': physical,
        'slept': slept,
        'helpfulPlace': helpfulPlace,
        'meaningful': meaningful,
        if (note != null) 'note': note,
      };
}

class RecoveryCapitalNotifier extends AsyncNotifier<List<RecoveryCapitalWeek>> {
  static const _key = 'recovery_capital';

  @override
  Future<List<RecoveryCapitalWeek>> build() async {
    return _safeParseList(
        await EncryptedStore.read(_key), RecoveryCapitalWeek.fromJson)
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
  }

  Future<void> _writeLock = Future.value();

  /// Set / replace the current ISO week's check.
  Future<void> setCurrentWeek({
    required bool connected,
    required bool physical,
    required bool slept,
    required bool helpfulPlace,
    required bool meaningful,
    String? note,
  }) =>
      _writeLock = _writeLock.then((_) async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        // Monday-of-week, local. weekday=1 → Mon, 7 → Sun.
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final current = state.valueOrNull ?? [];
        final idx = current.indexWhere((e) =>
            e.weekStart.year == weekStart.year &&
            e.weekStart.month == weekStart.month &&
            e.weekStart.day == weekStart.day);
        final entry = RecoveryCapitalWeek(
          id: idx >= 0
              ? current[idx].id
              : now.millisecondsSinceEpoch.toString(),
          weekStart: weekStart,
          connected: connected,
          physical: physical,
          slept: slept,
          helpfulPlace: helpfulPlace,
          meaningful: meaningful,
          note: note?.trim().isEmpty == true ? null : note?.trim(),
        );
        final updated = [...current];
        if (idx >= 0) {
          updated[idx] = entry;
        } else {
          updated.insert(0, entry);
        }
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[RecoveryCapitalNotifier] write error: $e');
      });
}

final recoveryCapitalProvider =
    AsyncNotifierProvider<RecoveryCapitalNotifier, List<RecoveryCapitalWeek>>(
        RecoveryCapitalNotifier.new);

/// Current ISO-week's recovery capital entry, or null if not filled yet.
final thisWeekCapitalProvider = Provider<RecoveryCapitalWeek?>((ref) {
  final list = ref.watch(recoveryCapitalProvider).valueOrNull ?? const [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  for (final e in list) {
    if (e.weekStart.year == weekStart.year &&
        e.weekStart.month == weekStart.month &&
        e.weekStart.day == weekStart.day) return e;
  }
  return null;
});

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
    final raw = await EncryptedStore.read(_key);
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
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[ThoughtNotifier] write error: $e');
      });

  Future<void> delete(String id) => _writeLock = _writeLock.then((_) async {
        final current = state.valueOrNull ?? [];
        final updated = current.where((e) => e.id != id).toList();
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[ThoughtNotifier] write error: $e');
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
    final raw = await EncryptedStore.read(_key);
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
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[ActivityNotifier] write error: $e');
      });

  Future<void> delete(String id) => _writeLock = _writeLock.then((_) async {
        final current = state.valueOrNull ?? [];
        final updated = current.where((e) => e.id != id).toList();
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[ActivityNotifier] write error: $e');
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
    final raw = await EncryptedStore.read(_key);
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
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[SleepNotifier] write error: $e');
      });

  Future<void> delete(String id) => _writeLock = _writeLock.then((_) async {
        final current = state.valueOrNull ?? [];
        final updated = current.where((e) => e.id != id).toList();
        await EncryptedStore.write(
            _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
        state = AsyncData(updated);
      }).catchError((Object e, StackTrace s) {
        debugPrint('[SleepNotifier] write error: $e');
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
    final raw = await EncryptedStore.read(_key);
    return _safeParseList(raw, Meeting.fromJson)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<void> _persist(List<Meeting> list) async {
    await EncryptedStore.write(
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

final meetingsProvider = AsyncNotifierProvider<MeetingsNotifier, List<Meeting>>(
    MeetingsNotifier.new);

// ─── Future-self letters ──────────────────────────────────────────────────────

class FutureLetterNotifier extends AsyncNotifier<List<FutureLetter>> {
  static const _key = 'future_letters';

  @override
  Future<List<FutureLetter>> build() async {
    final raw = await EncryptedStore.read(_key);
    return _safeParseList(raw, FutureLetter.fromJson)
      ..sort((a, b) => a.unlockAt.compareTo(b.unlockAt));
  }

  Future<void> _persist(List<FutureLetter> list) async {
    await EncryptedStore.write(
        _key, jsonEncode(list.map((e) => e.toJson()).toList()));
    state = AsyncData(list);
  }

  Future<void> add(FutureLetter letter) async {
    final current = state.valueOrNull ?? [];
    await _persist(
        [...current, letter]..sort((a, b) => a.unlockAt.compareTo(b.unlockAt)));
  }

  Future<void> markOpened(String id) async {
    final current = state.valueOrNull ?? [];
    final updated =
        current.map((l) => l.id == id ? l.copyWith(opened: true) : l).toList();
    await _persist(updated);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    await _persist(current.where((l) => l.id != id).toList());
  }
}

final futureLetterProvider =
    AsyncNotifierProvider<FutureLetterNotifier, List<FutureLetter>>(
        FutureLetterNotifier.new);

// ─── Hard day badges ──────────────────────────────────────────────────────────

class HardDayNotifier extends AsyncNotifier<List<HardDay>> {
  static const _key = 'hard_days';

  @override
  Future<List<HardDay>> build() async {
    final raw = await EncryptedStore.read(_key);
    return _safeParseList(raw, HardDay.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _persist(List<HardDay> list) async {
    await EncryptedStore.write(
        _key, jsonEncode(list.map((e) => e.toJson()).toList()));
    state = AsyncData(list);
  }

  Future<void> mark({String? note}) async {
    final current = state.valueOrNull ?? [];
    final today = DateTime.now();
    // One per calendar day — marking twice on the same day updates the note
    // rather than double-counting.
    final existingIdx = current.indexWhere((h) =>
        h.date.year == today.year &&
        h.date.month == today.month &&
        h.date.day == today.day);
    final entry = HardDay(
      id: today.millisecondsSinceEpoch.toString(),
      date: today,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );
    final updated = [...current];
    if (existingIdx >= 0) {
      updated[existingIdx] = entry;
    } else {
      updated.insert(0, entry);
    }
    await _persist(updated);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    await _persist(current.where((h) => h.id != id).toList());
  }

  bool isMarkedToday() {
    final list = state.valueOrNull ?? [];
    final today = DateTime.now();
    return list.any((h) =>
        h.date.year == today.year &&
        h.date.month == today.month &&
        h.date.day == today.day);
  }
}

final hardDayProvider =
    AsyncNotifierProvider<HardDayNotifier, List<HardDay>>(HardDayNotifier.new);

// ─── Urge rides ("ride the wave" timer wins) ──────────────────────────────────

class UrgeRideNotifier extends AsyncNotifier<List<UrgeRide>> {
  static const _key = 'urge_rides';

  @override
  Future<List<UrgeRide>> build() async {
    final raw = await EncryptedStore.read(_key);
    return _safeParseList(raw, UrgeRide.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> record(int seconds) async {
    final current = state.valueOrNull ?? [];
    final now = DateTime.now();
    final updated = [
      UrgeRide(
        id: now.millisecondsSinceEpoch.toString(),
        date: now,
        seconds: seconds,
      ),
      ...current,
    ];
    await EncryptedStore.write(
        _key, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = AsyncData(updated);
  }
}

final urgeRideProvider = AsyncNotifierProvider<UrgeRideNotifier, List<UrgeRide>>(
    UrgeRideNotifier.new);

// ─── Theme mode (Appearance) ─────────────────────────────────────────────────
// 'theme_mode' lives in plain prefs so the first frame can apply it without
// awaiting storage. Light/cream is the default experience; dark is opt-in.

/// Raw 'theme_mode' pref ('system' | 'light' | 'dark'). Set by main() from
/// the cached SharedPreferences before runApp so the first build is correct.
String? initialThemeModeRaw;

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const prefsKey = 'theme_mode';

  static ThemeMode fromRaw(String? raw) => switch (raw) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };

  @override
  ThemeMode build() => fromRaw(initialThemeModeRaw);

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      prefsKey,
      switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
        ThemeMode.light => 'light',
      },
    );
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ─── App language (locale) ────────────────────────────────────────────────────

/// Raw 'app_locale' pref: a language code ('en','af',…) or null = follow the
/// device language. Read by main() from the cached SharedPreferences before
/// runApp so the very first frame is already in the right language.
String? initialLocaleRaw;

class LocaleNotifier extends Notifier<Locale?> {
  static const prefsKey = 'app_locale';

  /// null/empty → follow the device language (MaterialApp resolves it against
  /// supportedLocales).
  static Locale? fromRaw(String? raw) =>
      (raw == null || raw.isEmpty) ? null : Locale(raw);

  @override
  Locale? build() => fromRaw(initialLocaleRaw);

  /// Pass null to follow the device language.
  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(prefsKey);
    } else {
      await prefs.setString(prefsKey, locale.languageCode);
    }
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

// ─── CBT thought records (full version) ───────────────────────────────────────

class ThoughtRecordNotifier extends AsyncNotifier<List<ThoughtRecord>> {
  static const _key = 'thought_records';

  @override
  Future<List<ThoughtRecord>> build() async {
    final raw = await EncryptedStore.read(_key);
    return _safeParseList(raw, ThoughtRecord.fromJson)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _persist(List<ThoughtRecord> list) async {
    await EncryptedStore.write(
        _key, jsonEncode(list.map((e) => e.toJson()).toList()));
    state = AsyncData(list);
  }

  Future<void> add(ThoughtRecord record) async {
    final current = state.valueOrNull ?? [];
    await _persist([record, ...current]);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    await _persist(current.where((r) => r.id != id).toList());
  }
}

final thoughtRecordProvider =
    AsyncNotifierProvider<ThoughtRecordNotifier, List<ThoughtRecord>>(
        ThoughtRecordNotifier.new);

// ─── Craving pattern detection (derived) ──────────────────────────────────────
//
// Reads cravings and surfaces ONE actionable pattern: the day-of-week +
// 2-hour window that holds the most cravings. Returns null when there
// aren't enough data points (<5) — a pattern from 2 cravings is noise.

class CravingPattern {
  final int weekday; // 1 = Monday, 7 = Sunday (DateTime.weekday convention)
  final int startHour; // 0–22 (window is [startHour, startHour+2))
  final int count;
  final int totalCravings;
  const CravingPattern({
    required this.weekday,
    required this.startHour,
    required this.count,
    required this.totalCravings,
  });

  String get weekdayLabel => const [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][weekday];

  String get timeLabel {
    String fmt(int h) {
      if (h == 0) return '12am';
      if (h < 12) return '${h}am';
      if (h == 12) return '12pm';
      return '${h - 12}pm';
    }

    return '${fmt(startHour)}–${fmt((startHour + 2) % 24)}';
  }
}

final cravingPatternProvider = Provider<CravingPattern?>((ref) {
  final cravings = ref.watch(cravingProvider).valueOrNull ?? const [];
  if (cravings.length < 5) return null;

  // Bucket by (weekday, 2-hour window). 7 days × 12 windows = 84 buckets.
  final buckets = <int, int>{};
  for (final c in cravings) {
    final wd = c.date.weekday;
    final win = c.date.hour ~/ 2; // 0..11
    final key = wd * 100 + win;
    buckets[key] = (buckets[key] ?? 0) + 1;
  }
  // Pick the largest bucket; require at least 3 cravings in it.
  int bestKey = 0;
  int bestCount = 0;
  buckets.forEach((k, v) {
    if (v > bestCount) {
      bestCount = v;
      bestKey = k;
    }
  });
  if (bestCount < 3) return null;
  return CravingPattern(
    weekday: bestKey ~/ 100,
    startHour: (bestKey % 100) * 2,
    count: bestCount,
    totalCravings: cravings.length,
  );
});
