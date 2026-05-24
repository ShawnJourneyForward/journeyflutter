// Personal craving insights — fully on-device aggregation over the user's
// own logged cravings. No network, no AI, no cloud — just counting and
// sorting. The point of this module: when a craving hits, the user's
// executive function is exactly the resource that just collapsed. Don't
// make them remember what worked last time. Surface it.
//
// All public functions are pure — given the same list, they return the
// same result. That makes them trivial to wrap in a Riverpod Provider and
// also trivial to unit-test in isolation later.

import '../providers/app_providers.dart';

/// A response option the craving sheet offers. The label is what the user
/// sees on the chip; the slug is what we persist in CravingEntry.responseChosen.
class CravingResponse {
  final String slug;
  final String label;
  const CravingResponse(this.slug, this.label);
}

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
}

/// Compute "what worked" — for each response strategy the user has tried at
/// least N times, what fraction led to a 'stayed_sober' outcome. We require
/// a minimum sample (default 2) so a single lucky walk-out doesn't crown a
/// strategy that hasn't really been tested.
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
        entry.value.where((e) => e.outcome == 'stayed_sober').length;
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
