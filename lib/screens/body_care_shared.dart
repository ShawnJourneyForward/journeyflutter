// Shared pieces for the Body Care module: the non-scale-victory (NSV) preset
// deck, and the "tended weeks" / plant-growth maths.
//
// The design rule baked in here is recovery-safe by construction: growth is
// driven by CONSISTENCY of self-care (showing up), never by a number on the
// scale, and the "weeks tended" count is MONOTONIC — it only ever rises, so a
// rest week is never a punishment or a broken streak.

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/body_care_win.dart';
import '../models/planner_activity.dart';
import '../models/planner_weight_log.dart';
import '../utils/week_dates.dart';

/// Tracking modes the opt-in gate writes to `UserProfile.weightTrackingMode`.
const String kBodyCareModeFeelings = 'feelings'; // care, never a number
const String kBodyCareModeSometimes = 'sometimes'; // gentle occasional weighing

/// A preset non-scale victory: a stable [slug] (persisted) + its icon. The
/// label is resolved at display time via [bodyCareWinLabel] so it localises.
class BodyCareWinKind {
  const BodyCareWinKind(this.slug, this.icon);
  final String slug;
  final IconData icon;
}

/// The deck of preset wins, in the order they appear. Slugs are STABLE — never
/// rename one (it's the persisted value); add new ones at the end.
const List<BodyCareWinKind> kBodyCareWinKinds = [
  BodyCareWinKind('energy', Icons.bolt_rounded),
  BodyCareWinKind('clothes', Icons.checkroom_rounded),
  BodyCareWinKind('moved', Icons.directions_walk_rounded),
  BodyCareWinKind('craving', Icons.local_fire_department_outlined),
  BodyCareWinKind('sleep', Icons.bedtime_outlined),
  BodyCareWinKind('nourished', Icons.spa_outlined),
  BodyCareWinKind('strong', Icons.fitness_center_outlined),
  BodyCareWinKind('showedup', Icons.favorite_outline_rounded),
];

/// Icon for a win slug ('custom'/unknown → a generic spark).
IconData bodyCareWinIcon(String slug) {
  for (final k in kBodyCareWinKinds) {
    if (k.slug == slug) return k.icon;
  }
  return Icons.auto_awesome_outlined;
}

/// Localised label for a preset win slug. A 'custom' win shows its own note
/// text instead of this, so this falls back to the generic custom label.
String bodyCareWinLabel(AppLocalizations l, String slug) => switch (slug) {
      'energy' => l.bodyCareWinEnergy,
      'clothes' => l.bodyCareWinClothes,
      'moved' => l.bodyCareWinMoved,
      'craving' => l.bodyCareWinCraving,
      'sleep' => l.bodyCareWinSleep,
      'nourished' => l.bodyCareWinNourished,
      'strong' => l.bodyCareWinStrong,
      'showedup' => l.bodyCareWinShowedUp,
      _ => l.bodyCareWinCustom,
    };

/// The text to show for a logged win: the preset label, or — for a custom win —
/// the user's own words (falling back to the generic label if somehow empty).
String bodyCareWinDisplay(AppLocalizations l, BodyCareWin win) {
  if (win.kind == 'custom') {
    final n = win.note?.trim();
    return (n != null && n.isNotEmpty) ? n : l.bodyCareWinCustom;
  }
  return bodyCareWinLabel(l, win.kind);
}

/// Count of DISTINCT Sunday-weeks (see [weekKeySunday]) in which the user did
/// ANY act of body care — a win, a weigh-in, or a logged activity. Monotonic:
/// it only ever rises, so a missed week is never a penalty.
int bodyCareWeeksTended({
  required List<BodyCareWin> wins,
  required List<PlannerWeightLog> weights,
  required List<PlannerActivity> activities,
}) {
  final weeks = <String>{};
  for (final w in wins) {
    weeks.add(weekKeySunday(w.date));
  }
  for (final w in weights) {
    weeks.add(weekKeySunday(w.date));
  }
  for (final a in activities) {
    weeks.add(weekKeySunday(a.date));
  }
  return weeks.length;
}

/// Whether any act of care landed in the CURRENT Sunday-week.
bool bodyCareTendedThisWeek({
  required List<BodyCareWin> wins,
  required List<PlannerWeightLog> weights,
  required List<PlannerActivity> activities,
}) {
  final now = DateTime.now();
  final start = startOfWeekSunday(now);
  final end = start.add(const Duration(days: 7));
  bool inWeek(DateTime d) => !d.isBefore(start) && d.isBefore(end);
  return wins.any((w) => inWeek(w.date)) ||
      weights.any((w) => inWeek(w.date)) ||
      activities.any((a) => inWeek(a.date));
}

/// Plant growth stage (0..1) from cumulative tended weeks — fills over ~16
/// weeks of showing up. A small floor once they've started so the pot is never
/// bare after the very first act of care; a true 0 only before anything is
/// logged (an inviting empty pot).
double bodyCarePlantStage(int weeksTended) {
  if (weeksTended <= 0) return 0.04;
  return (weeksTended / 16).clamp(0.12, 1.0);
}
