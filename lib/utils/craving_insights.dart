// Personal craving insights — fully on-device aggregation over the user's
// own logged cravings. No network, no AI, no cloud — just counting and
// sorting. The point of this module: when a craving hits, the user's
// executive function is exactly the resource that just collapsed. Don't
// make them remember what worked last time. Surface it.
//
// All public functions are pure — given the same list, they return the
// same result. That makes them trivial to wrap in a Riverpod Provider and
// also trivial to unit-test in isolation later.

import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// A response option the craving sheet offers. The label is what the user
/// sees on the chip; the slug is what we persist in CravingEntry.responseChosen.
class CravingResponse {
  final String slug;
  final String label;
  const CravingResponse(this.slug, this.label);

  /// Localised response label, resolved by stable [slug]. Falls back to the
  /// English [label] for any unknown slug (e.g. legacy persisted values).
  String localizedLabel(AppLocalizations l) => switch (slug) {
        'walked' => l.cravingResponseWalked,
        'called' => l.cravingResponseCalled,
        'breathed' => l.cravingResponseBreathed,
        'journaled' => l.cravingResponseJournaled,
        'water' => l.cravingResponseWater,
        'grounded' => l.cravingResponseGrounded,
        _ => label,
      };
}

/// Localised label for a HALT slug ('hungry', 'angry', 'lonely', 'tired').
/// Falls back to the raw slug for any unknown value.
String localizedHaltLabel(AppLocalizations l, String slug) => switch (slug) {
      'hungry' => l.haltHungry,
      'angry' => l.haltAngry,
      'lonely' => l.haltLonely,
      'tired' => l.haltTired,
      _ => slug,
    };

/// Canonical menu of responses. Keep short — long lists fragment the data
/// and weaken the insight signal. Six is the sweet spot.
const kCravingResponses = <CravingResponse>[
  CravingResponse('walked', 'Walked away / outside'),
  CravingResponse('called', 'Called someone'),
  CravingResponse('breathed', 'Breathed / urge-surfed'),
  CravingResponse('journaled', 'Journaled / wrote'),
  CravingResponse('water', 'Drank water / ate'),
  CravingResponse('grounded', 'Grounded / prayed / meditated'),
];

/// HALT pre-check options. The labels are the words the user sees; the
/// slugs are what we persist. Lowercase, short, no punctuation.
const kHaltOptions = <(String slug, String label)>[
  ('hungry', 'Hungry'),
  ('angry', 'Angry'),
  ('lonely', 'Lonely'),
  ('tired', 'Tired'),
];

/// Aggregated stat for one response strategy.
class ResponseStat {
  final String slug;
  final String label;
  final int totalUses;
  final int soberOutcomes;
  double get successRate => totalUses == 0 ? 0 : soberOutcomes / totalUses;

  const ResponseStat({
    required this.slug,
    required this.label,
    required this.totalUses,
    required this.soberOutcomes,
  });

  /// Localised response label, resolved by stable [slug]. Falls back to the
  /// English [label].
  String localizedLabel(AppLocalizations l) =>
      CravingResponse(slug, label).localizedLabel(l);
}

/// Craving outcomes that mean the user got through it WITHOUT drinking. All
/// three positive outcomes — stayed sober, reached out, practiced tools — count
/// as a success for insights. ('slipped'/'unclear' are legacy values that may
/// still appear in a restored backup; they never count as success.)
const kSoberOutcomes = {'stayed_sober', 'reached_out', 'practiced_tools'};

/// Compute "what worked" — for each response strategy the user has tried at
/// least N times, what fraction led to a positive (got-through-it) outcome. We
/// require a minimum sample (default 2) so a single lucky walk-out doesn't crown
/// a strategy that hasn't really been tested.
List<ResponseStat> bestResponses(
  List<CravingEntry> all, {
  int minUses = 2,
}) {
  final byResponse = <String, List<CravingEntry>>{};
  for (final e in all) {
    final r = e.responseChosen;
    if (r == null || r.isEmpty) continue;
    byResponse.putIfAbsent(r, () => []).add(e);
  }

  final out = <ResponseStat>[];
  for (final entry in byResponse.entries) {
    if (entry.value.length < minUses) continue;
    final sober =
        entry.value.where((e) => kSoberOutcomes.contains(e.outcome)).length;
    final label = kCravingResponses
        .firstWhere((r) => r.slug == entry.key,
            orElse: () => CravingResponse(entry.key, entry.key))
        .label;
    out.add(ResponseStat(
      slug: entry.key,
      label: label,
      totalUses: entry.value.length,
      soberOutcomes: sober,
    ));
  }

  // Sort by success rate desc, then by sample size desc as a tiebreaker
  // (more uses = more confidence at the same rate).
  out.sort((a, b) {
    final r = b.successRate.compareTo(a.successRate);
    return r != 0 ? r : b.totalUses.compareTo(a.totalUses);
  });
  return out;
}

/// Find the most recent craving at roughly the given intensity level (±2)
/// where the user logged a response and an outcome. Used by the craving
/// sheet to show "Last time at this intensity, walking helped — passed in
/// 12 min." That single line is sometimes the difference between a slip
/// and a save.
CravingEntry? lastSimilar(List<CravingEntry> all, int intensity) {
  final lower = (intensity - 2).clamp(1, 10);
  final upper = (intensity + 2).clamp(1, 10);
  for (final e in all) {
    if (e.intensity < lower || e.intensity > upper) continue;
    if (e.responseChosen == null || e.outcome == null) continue;
    return e;
  }
  return null;
}

// ─── Risk window — time-of-day craving clustering ────────────────────────────

/// The user's highest-risk 3-hour window, found by sliding a wrap-around
/// 3-hour window over an hour-of-day histogram of their logged cravings.
class RiskWindow {
  /// Window start hour, 0–23. The window covers [startHour, startHour+3).
  final int startHour;

  /// Cravings inside the window / total cravings logged.
  final int count;
  final int total;
  const RiskWindow(
      {required this.startHour, required this.count, required this.total});

  /// "8–11 PM" style label. End hour is exclusive so a window starting at 20
  /// reads 8–11 PM (covers 20:00–22:59).
  String get label {
    String fmt(int h) {
      final h12 = h % 12 == 0 ? 12 : h % 12;
      return '$h12 ${h < 12 ? 'AM' : 'PM'}';
    }

    return '${fmt(startHour)}–${fmt((startHour + 3) % 24)}';
  }

  /// Localised "8–11 PM" style label. AM/PM markers and the range separator
  /// are resolved through [AppLocalizations] so the format can adapt per
  /// locale; falls back structurally to the English [label] format.
  String localizedLabel(AppLocalizations l) {
    String fmt(int h) {
      final h12 = h % 12 == 0 ? 12 : h % 12;
      final meridiem = h < 12 ? l.cravingTimeAm : l.cravingTimePm;
      return l.cravingHourMeridiem(h12, meridiem);
    }

    return l.cravingRiskWindowRange(fmt(startHour), fmt((startHour + 3) % 24));
  }
}

/// Find the dominant craving window, or null when there isn't a real pattern.
/// Requires a minimum sample (default 8 logs) AND real concentration — the
/// best window must hold ≥ 35% of all cravings (uniform noise would put
/// 12.5% in any 3-hour slice), so we never invent a pattern from noise.
RiskWindow? topRiskWindow(List<CravingEntry> all, {int minTotal = 8}) {
  if (all.length < minTotal) return null;
  final byHour = List<int>.filled(24, 0);
  for (final e in all) {
    byHour[e.date.hour]++;
  }
  var bestStart = 0, bestCount = -1;
  for (var h = 0; h < 24; h++) {
    final c = byHour[h] + byHour[(h + 1) % 24] + byHour[(h + 2) % 24];
    if (c > bestCount) {
      bestCount = c;
      bestStart = h;
    }
  }
  if (bestCount / all.length < 0.35) return null;
  return RiskWindow(startHour: bestStart, count: bestCount, total: all.length);
}

/// HALT prevalence — which underlying states most often accompany the user's
/// cravings. Surfaced on the insights screen later as "Your cravings cluster
/// when you're tired." Returns a map slug → count, sorted desc.
Map<String, int> haltPrevalence(List<CravingEntry> all) {
  final counts = <String, int>{};
  for (final e in all) {
    for (final h in e.halt) {
      counts[h] = (counts[h] ?? 0) + 1;
    }
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return Map.fromEntries(sorted);
}

// ─── Trigger frequency — the user's own words ────────────────────────────────

/// One trigger the user has logged, with how often it appeared. The label is
/// the user's own text (preserved with its first-seen casing); `count` is how
/// many cravings named it.
class TriggerStat {
  final String label;
  final int count;
  const TriggerStat({required this.label, required this.count});
}

/// The triggers that most often accompany the user's cravings, most-frequent
/// first. Triggers are free text the user typed, so we de-duplicate
/// case-insensitively (trimmed) but display the first casing we saw. A single
/// one-off trigger is signal too, so there's no minimum — callers cap the list.
/// Reads both the modern [CravingEntry.triggers] list and the legacy single
/// [CravingEntry.trigger] field so older logs still count.
List<TriggerStat> topTriggers(List<CravingEntry> all) {
  final counts = <String, int>{}; // normalized key → count
  final display = <String, String>{}; // normalized key → first-seen casing
  void tally(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return;
    final key = text.toLowerCase();
    counts[key] = (counts[key] ?? 0) + 1;
    display.putIfAbsent(key, () => text);
  }

  for (final e in all) {
    if (e.triggers.isNotEmpty) {
      for (final t in e.triggers) {
        tally(t);
      }
    } else {
      // Only fall back to the single legacy field when there's no list, so a
      // record that has both doesn't double-count its primary trigger.
      tally(e.trigger);
    }
  }

  final out = counts.entries
      .map((e) => TriggerStat(label: display[e.key]!, count: e.value))
      .toList()
    ..sort((a, b) {
      final c = b.count.compareTo(a.count);
      return c != 0 ? c : a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });
  return out;
}

// ─── Outcome tally — stayed sober vs slipped vs unclear ───────────────────────

/// How the user's logged cravings resolved. Only counts cravings that recorded
/// an outcome — quick-logs without one are excluded from every field so the
/// "stayed sober" count is never inflated by un-tagged entries.
class OutcomeTally {
  final int stayedSober;
  final int slipped;
  final int unclear;
  const OutcomeTally({
    required this.stayedSober,
    required this.slipped,
    required this.unclear,
  });

  /// Cravings that recorded any outcome at all.
  int get totalWithOutcome => stayedSober + slipped + unclear;
}

OutcomeTally outcomeTally(List<CravingEntry> all) {
  var sober = 0, slipped = 0, unclear = 0;
  for (final e in all) {
    final o = e.outcome;
    if (kSoberOutcomes.contains(o)) {
      sober++; // stayed sober / reached out / practiced tools — got through it
    } else if (o == 'slipped') {
      slipped++; // legacy value, restored backups only
    } else if (o == 'unclear') {
      unclear++; // legacy value
    }
    // else: no outcome recorded — excluded
  }
  return OutcomeTally(stayedSober: sober, slipped: slipped, unclear: unclear);
}
