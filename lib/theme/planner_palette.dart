// Color + icon mapping for [SessionType], used by the planner calendar and
// session cells. Everything here resolves through AppColors tokens so the
// mapping inverts automatically with the Stillwater dark palette — there are
// no raw hex literals.
//
// Three accessors per session type:
//   * [sessionTypeColor] — the strong accent (chip ink, icon tint, dot).
//   * [sessionTypeTint]  — a soft fill for calendar day-cell backgrounds.
//   * [sessionTypeIcon]  — a Material *outline* glyph for the session kind.
//
// Palette intent (on-brand): runs stay in the FOREST family (the primary
// green), the rest day uses calm STONE, swim borrows HONEY for warmth, and
// `other` falls back to neutral stone. We never reach for BLUSH here — blush
// is reserved app-wide for destructive / slip UI, and a workout is not an
// error state.

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/planner_activity.dart';
import '../models/planner_session.dart';
import 'app_theme.dart';

/// Strong accent colour for [t] — used for the session chip ink, the calendar
/// dot, and the icon tint. Resolves through [AppColors] so it inverts with the
/// active (light / dark) palette.
Color sessionTypeColor(SessionType t) {
  switch (t) {
    case SessionType.easyRun:
      // Gentle base run — mid forest.
      return AppColors.forest500;
    case SessionType.intervals:
      // High-intensity bursts — the deepest, most active forest.
      return AppColors.forest700;
    case SessionType.tempo:
      // Sustained hard effort — primary-CTA forest.
      return AppColors.forest600;
    case SessionType.longRun:
      // Endurance — leaf green reads distinct from the tempo/interval forests.
      return AppColors.leafGreen;
    case SessionType.rest:
      // Recovery day — calm, recessive stone (a deliberate non-green).
      return AppColors.stone500;
    case SessionType.crossTrain:
      // Strength / alt-cardio — honey warmth to set it apart from the runs.
      return AppColors.honey600;
    case SessionType.swim:
      // Water work — honey accent (no blue token exists in the palette; honey
      // keeps it warm and on-brand while distinct from the running greens).
      return AppColors.honey500;
    // General disciplines — mirror disciplineColor so a planned session and the
    // activity it mints read the same accent.
    case SessionType.ride:
      return AppColors.forest500;
    case SessionType.walk:
      return AppColors.leafGreen;
    case SessionType.hike:
      return AppColors.forest700;
    case SessionType.gym:
      return AppColors.honey600;
    case SessionType.yoga:
      return AppColors.stone500;
    case SessionType.cardio:
      return AppColors.honey500;
    case SessionType.other:
      // Catch-all — neutral secondary-text stone.
      return AppColors.stone600;
  }
}

/// Soft fill colour for [t] — used as the calendar day-cell background behind
/// the icon / dot. A lighter, lower-chroma sibling of [sessionTypeColor] from
/// the same family, so a filled cell stays readable under dark or light text.
Color sessionTypeTint(SessionType t) {
  switch (t) {
    case SessionType.easyRun:
    case SessionType.intervals:
    case SessionType.tempo:
      // All forest-family runs share the soft forest chip fill.
      return AppColors.forest50;
    case SessionType.longRun:
      // Endurance — the mint chip fill, a touch distinct from forest50.
      return AppColors.mintChip;
    case SessionType.rest:
      // Recovery — neutral stone hairline fill.
      return AppColors.stone100;
    case SessionType.crossTrain:
    case SessionType.swim:
    case SessionType.gym:
    case SessionType.cardio:
      // Honey-family work — soft honey chip background.
      return AppColors.honeySoft;
    case SessionType.ride:
    case SessionType.walk:
      // Mint sibling fill (matches disciplineTint for ride/walk).
      return AppColors.mintChip;
    case SessionType.hike:
      // Forest-family — soft forest fill.
      return AppColors.forest50;
    case SessionType.yoga:
    case SessionType.other:
      // Calm / catch-all — plainest stone fill.
      return AppColors.stone100;
  }
}

/// Material *outline* glyph representing [t]. Used in calendar cells, the
/// session list, and the today-session home tile.
IconData sessionTypeIcon(SessionType t) {
  switch (t) {
    case SessionType.easyRun:
      return Icons.directions_run_outlined;
    case SessionType.intervals:
      return Icons.bolt_outlined;
    case SessionType.tempo:
      return Icons.speed_outlined;
    case SessionType.longRun:
      return Icons.terrain_outlined;
    case SessionType.rest:
      return Icons.hotel_outlined;
    case SessionType.crossTrain:
      return Icons.fitness_center_outlined;
    case SessionType.swim:
      return Icons.pool_outlined;
    // General disciplines — same glyphs as disciplineIcon.
    case SessionType.ride:
      return Icons.directions_bike_outlined;
    case SessionType.walk:
      return Icons.directions_walk_outlined;
    case SessionType.hike:
      return Icons.terrain_outlined;
    case SessionType.gym:
      return Icons.fitness_center_outlined;
    case SessionType.yoga:
      return Icons.self_improvement_outlined;
    case SessionType.cardio:
      return Icons.bolt_outlined;
    case SessionType.other:
      return Icons.more_horiz_outlined;
  }
}

// ─── Discipline mapping (the launch axis for logging + insights tiles) ────────
// Same palette intent as the session-type mapping: runs stay forest, water work
// borrows honey, strength/cardio use honey warmth, the calm disciplines (yoga,
// rest-like "other") use recessive stone. Never BLUSH — that's reserved app-wide
// for destructive / slip UI.

/// Strong accent colour for a [discipline] — chip ink, icon tint, accent bar.
Color disciplineColor(ActivityDiscipline d) {
  switch (d) {
    case ActivityDiscipline.run:
      return AppColors.forest600;
    case ActivityDiscipline.ride:
      return AppColors.forest500;
    case ActivityDiscipline.swim:
      return AppColors.honey500;
    case ActivityDiscipline.walk:
      return AppColors.leafGreen;
    case ActivityDiscipline.hike:
      return AppColors.forest700;
    case ActivityDiscipline.gym:
      return AppColors.honey600;
    case ActivityDiscipline.yoga:
      return AppColors.stone500;
    case ActivityDiscipline.cardio:
      return AppColors.honey500;
    case ActivityDiscipline.other:
      return AppColors.stone600;
  }
}

/// Soft fill colour for a [discipline] — icon-chip background.
Color disciplineTint(ActivityDiscipline d) {
  switch (d) {
    case ActivityDiscipline.run:
    case ActivityDiscipline.hike:
      return AppColors.forest50;
    case ActivityDiscipline.ride:
    case ActivityDiscipline.walk:
      return AppColors.mintChip;
    case ActivityDiscipline.swim:
    case ActivityDiscipline.gym:
    case ActivityDiscipline.cardio:
      return AppColors.honeySoft;
    case ActivityDiscipline.yoga:
    case ActivityDiscipline.other:
      return AppColors.stone100;
  }
}

/// Material *outline* glyph representing a [discipline].
IconData disciplineIcon(ActivityDiscipline d) {
  switch (d) {
    case ActivityDiscipline.run:
      return Icons.directions_run_outlined;
    case ActivityDiscipline.ride:
      return Icons.directions_bike_outlined;
    case ActivityDiscipline.swim:
      return Icons.pool_outlined;
    case ActivityDiscipline.walk:
      return Icons.directions_walk_outlined;
    case ActivityDiscipline.hike:
      return Icons.terrain_outlined;
    case ActivityDiscipline.gym:
      return Icons.fitness_center_outlined;
    case ActivityDiscipline.yoga:
      return Icons.self_improvement_outlined;
    case ActivityDiscipline.cardio:
      return Icons.bolt_outlined;
    case ActivityDiscipline.other:
      return Icons.more_horiz_outlined;
  }
}

/// Localized label for a [discipline]. Kept here so history, insights and the
/// log sheet all read the same word from one place.
String disciplineLabel(AppLocalizations l10n, ActivityDiscipline d) {
  switch (d) {
    case ActivityDiscipline.run:
      return l10n.plannerDisciplineRun;
    case ActivityDiscipline.ride:
      return l10n.plannerDisciplineRide;
    case ActivityDiscipline.swim:
      return l10n.plannerDisciplineSwim;
    case ActivityDiscipline.walk:
      return l10n.plannerDisciplineWalk;
    case ActivityDiscipline.hike:
      return l10n.plannerDisciplineHike;
    case ActivityDiscipline.gym:
      return l10n.plannerDisciplineGym;
    case ActivityDiscipline.yoga:
      return l10n.plannerDisciplineYoga;
    case ActivityDiscipline.cardio:
      return l10n.plannerDisciplineCardio;
    case ActivityDiscipline.other:
      return l10n.plannerDisciplineOther;
  }
}

