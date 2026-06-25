// Logged-activity history — a date-descending list of every PlannerActivity
// (manual or Strava-imported), each a swipe-to-delete card. Mirrors the
// Stillwater idiom of the recovery History screen's activity rows: a SolidCard
// with a left accent bar in the session colour, a soft icon chip, and a meta
// line. Distances and paces convert to imperial only at display time via the
// locale_format helpers; all prose comes from the l10n getters.
//
// Strava brand compliance: any row sourced from Strava carries an orange
// "Strava" source chip (#FC4C02), and whenever at least one Strava-sourced
// activity is visible we render a "Powered by Strava" attribution mark at the
// bottom of the screen — Strava requires attribution wherever its data shows.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../models/planner_activity.dart';
import '../providers/app_providers.dart';
import '../services/strava_config.dart';
import '../theme/app_theme.dart';
import '../theme/planner_palette.dart';
import '../utils/haptic_service.dart';
import '../utils/locale_format.dart';

/// Strava brand orange — used ONLY for the Strava source chip and the
/// attribution mark, per the Strava brand guidelines. Not a palette token
/// (the Stillwater palette has no orange / no blue), so it lives here as the
/// single sanctioned exception, scoped to Strava attribution surfaces.
const Color _kStravaOrange = Color(0xFFFC4C02);

class PlannerHistoryScreen extends ConsumerWidget {
  const PlannerHistoryScreen({super.key});

  // ─── Swipe-to-delete confirmation ───────────────────────────────────────────

  Future<bool> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    H.medium();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
        title: Text(l10n.historyDeleteEntryTitle,
            style: AppTextStyles.titleMedium),
        content:
            Text(l10n.historyDeleteEntryBody, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel,
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.stone600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete,
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.blush500)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  // ─── Source chip ────────────────────────────────────────────────────────────

  Widget _sourceChip(AppLocalizations l10n, ActivitySource source) {
    final isStrava = source == ActivitySource.strava;
    final label =
        isStrava ? l10n.plannerSourceStrava : l10n.plannerSourceManual;
    final fg = isStrava ? _kStravaOrange : AppColors.stone600;
    final bg = isStrava
        ? _kStravaOrange.withValues(alpha: 0.10)
        : AppColors.stone100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: fg),
      ),
    );
  }

  // ─── Powered-by-Strava attribution mark ─────────────────────────────────────

  Widget _poweredByStrava(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Center(
        child: Text(
          l10n.plannerPoweredByStrava,
          style: AppTextStyles.labelSmall.copyWith(color: _kStravaOrange),
        ),
      ),
    );
  }

  // ─── Activity card ──────────────────────────────────────────────────────────

  /// Format elevation gain (canonical metres) in the user's unit.
  String _fmtElevation(double m, bool imperial, AppLocalizations l10n) {
    if (imperial) return '${(m * 3.28084).round()} ${l10n.plannerUnitFeet}';
    return '${m.round()} ${l10n.plannerUnitMeters}';
  }

  /// Min/km pace for runs/walks/hikes, speed for rides, /100m for swims — each
  /// discipline's natural readout.
  String _paceOrSpeed(ActivityDiscipline d, double km, int minutes,
      bool imperial, AppLocalizations l10n) {
    switch (d) {
      case ActivityDiscipline.ride:
        return formatSpeed(km, minutes, imperial: imperial, l10n: l10n);
      case ActivityDiscipline.swim:
        return formatSwimPace(km, minutes, l10n: l10n);
      default:
        return formatPace(km, minutes, imperial: imperial, l10n: l10n);
    }
  }

  Widget _activityCard(
    AppLocalizations l10n,
    PlannerActivity a,
    bool imperial,
    bool imperialWeight,
  ) {
    final discipline = a.effectiveDiscipline;
    final accent = disciplineColor(discipline);
    final tint = disciplineTint(discipline);
    final icon = disciplineIcon(discipline);
    final label = disciplineLabel(l10n, discipline);

    // Meta line: distance · pace · minutes. Distance + pace only show for
    // disciplines that carry a meaningful distance AND have a positive value.
    final meta = <String>[];
    final hasDistance = distanceDisciplines.contains(discipline) &&
        a.distanceKm != null &&
        a.distanceKm! > 0;
    if (hasDistance) {
      meta.add(formatDistance(a.distanceKm!,
          imperial: imperial, l10n: l10n));
      meta.add(_paceOrSpeed(
          discipline, a.distanceKm!, a.minutes, imperial, l10n));
    }
    meta.add(l10n.commonMin(a.minutes));

    // Secondary line: discipline-specific extras (elevation, pool length, gym
    // summary + tonnage, effort) — only the ones this activity actually carries.
    final meta2 = <String>[];
    if (a.elevationGainM != null && a.elevationGainM! > 0) {
      meta2.add('↑ ${_fmtElevation(a.elevationGainM!, imperial, l10n)}');
    }
    if (a.poolLengthM != null && a.poolLengthM! > 0) {
      meta2.add('${a.poolLengthM!.round()} ${l10n.plannerUnitMeters}');
    }
    if (a.strengthSets.isNotEmpty) {
      meta2.add(l10n.plannerStrengthSummary(a.strengthSets.length));
      final vol = a.strengthVolumeKg;
      if (vol != null && vol > 0) {
        meta2.add(formatWeight(vol, imperial: imperialWeight, l10n: l10n));
      }
    }
    if (a.rpe != null) meta2.add(l10n.plannerEffortValue(a.rpe!));

    return SolidCard(
      padding: const EdgeInsets.all(0),
      borderRadius: AppRadius.xl,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar in the session colour.
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Soft session-tinted icon chip.
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: tint,
                            borderRadius: AppRadius.md,
                          ),
                          child: Icon(icon, size: 18, color: accent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: AppTextStyles.titleSmall),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat.yMMMMd().format(a.date),
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (stravaConfigured) ...[
                          const SizedBox(width: 8),
                          _sourceChip(l10n, a.source),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meta.join('  ·  '),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone500),
                    ),
                    if (meta2.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        meta2.join('  ·  '),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.stone400),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty state ────────────────────────────────────────────────────────────

  Widget _emptyState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_run_outlined,
              size: 52, color: AppColors.stone200),
          const SizedBox(height: 16),
          Text(
            l10n.plannerNoActivities,
            style:
                AppTextStyles.titleMedium.copyWith(color: AppColors.stone500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final activities =
        ref.watch(plannerActivityProvider).valueOrNull ?? const [];
    // Distance/pace display unit follows the profile; default to metric when
    // the profile hasn't loaded yet (distances are stored canonical in km).
    final imperial =
        ref.watch(profileProvider).valueOrNull?.useImperial ?? false;
    final imperialWeight =
        ref.watch(profileProvider).valueOrNull?.useImperialWeight ?? false;

    // Date-descending — most recent first.
    final sorted = [...activities]..sort((a, b) => b.date.compareTo(a.date));
    final hasStrava =
        sorted.any((a) => a.source == ActivitySource.strava);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  const LuxuryBackButton(),
                  const SizedBox(width: 4),
                  Text(l10n.plannerHistory, style: AppTextStyles.titleLarge),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── List / empty state ─────────────────────────────────────────
            Expanded(
              child: sorted.isEmpty
                  ? SingleChildScrollView(child: _emptyState(l10n))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final a = sorted[index];
                        return Dismissible(
                          key: Key('planner_activity_${a.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.blush50,
                              borderRadius: AppRadius.xl,
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.blush500,
                              size: 20,
                            ),
                          ),
                          confirmDismiss: (_) => _confirmDelete(context),
                          onDismissed: (_) {
                            H.medium();
                            ref
                                .read(plannerActivityProvider.notifier)
                                .delete(a.id);
                          },
                          child: _activityCard(
                              l10n, a, imperial, imperialWeight),
                        );
                      },
                    ),
            ),

            // ── Strava attribution (only when the integration is enabled) ──
            if (stravaConfigured && hasStrava) _poweredByStrava(l10n),
          ],
        ),
      ),
    );
  }
}
