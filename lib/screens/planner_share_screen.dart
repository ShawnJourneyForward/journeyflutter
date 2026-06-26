// Shareable training summary. Pick a date range (1 / 2 / 4 weeks or all time)
// and the screen renders a branded card — total distance, active time, session
// count and a per-discipline breakdown over that window — which is captured to
// a PNG (RepaintBoundary → toImage) and handed to the system share sheet. Same
// capture-and-share pattern as the 100-day challenge card.
//
// Read-only: it never writes. Distances/weights convert to the user's units at
// display time; all copy comes from the l10n getters.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../components/back_button.dart';
import '../l10n/app_localizations.dart';
import '../models/planner_activity.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../theme/planner_palette.dart';
import '../utils/haptic_service.dart';
import '../utils/locale_format.dart';

/// The selectable share windows.
enum _ShareRange { week1, week2, week4, all }

/// Lookback length in days, or null for "all time".
int? _rangeDays(_ShareRange r) {
  switch (r) {
    case _ShareRange.week1:
      return 7;
    case _ShareRange.week2:
      return 14;
    case _ShareRange.week4:
      return 28;
    case _ShareRange.all:
      return null;
  }
}

String _rangeLabel(AppLocalizations l10n, _ShareRange r) {
  switch (r) {
    case _ShareRange.week1:
      return l10n.plannerRange1Week;
    case _ShareRange.week2:
      return l10n.plannerRange2Weeks;
    case _ShareRange.week4:
      return l10n.plannerRange4Weeks;
    case _ShareRange.all:
      return l10n.plannerRangeAll;
  }
}

/// Running totals for one discipline within the window.
class _Agg {
  int count = 0;
  int minutes = 0;
  double distanceKm = 0;
  double volumeKg = 0;
}

String _fmtActiveTime(AppLocalizations l10n, int minutes) {
  if (minutes < 60) return l10n.commonMin(minutes);
  return l10n.plannerDurationHm(minutes ~/ 60, minutes % 60);
}

class PlannerShareScreen extends ConsumerStatefulWidget {
  const PlannerShareScreen({super.key});

  @override
  ConsumerState<PlannerShareScreen> createState() => _PlannerShareScreenState();
}

class _PlannerShareScreenState extends ConsumerState<PlannerShareScreen> {
  final _cardKey = GlobalKey();
  _ShareRange _range = _ShareRange.week1;
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    H.medium();
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final file = File('${Directory.systemTemp.path}/journey_training.png');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.plannerShareMessage,
      );
    } catch (_) {
      // Capture / share failed — degrade quietly.
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(profileProvider).valueOrNull;
    final imperial = profile?.useImperial ?? false;
    final imperialWeight = profile?.useImperialWeight ?? false;

    final activities =
        ref.watch(plannerActivityProvider).valueOrNull ?? const [];

    // ── Filter to the selected window ──────────────────────────────────────
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = _rangeDays(_range);
    final cutoff =
        days == null ? null : today.subtract(Duration(days: days - 1));
    final inRange = activities
        .where((a) => cutoff == null || !a.date.isBefore(cutoff))
        .toList();

    // ── Aggregate ──────────────────────────────────────────────────────────
    var totalKm = 0.0;
    var totalMin = 0;
    final byDiscipline = <ActivityDiscipline, _Agg>{};
    for (final a in inRange) {
      totalKm += a.distanceKm ?? 0;
      totalMin += a.minutes;
      final agg = byDiscipline.putIfAbsent(a.effectiveDiscipline, _Agg.new);
      agg.count += 1;
      agg.minutes += a.minutes;
      agg.distanceKm += a.distanceKm ?? 0;
      agg.volumeKg += a.strengthVolumeKg ?? 0;
    }
    final rows = byDiscipline.entries.toList()
      ..sort((x, y) => y.value.minutes.compareTo(x.value.minutes));
    final topRows = rows.take(5).toList();

    // ── Range subtitle ─────────────────────────────────────────────────────
    final df = DateFormat.MMMd(Intl.defaultLocale);
    final subtitle = (cutoff == null)
        ? l10n.plannerRangeAll
        : '${df.format(cutoff)} – ${df.format(today)}';

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  LuxuryBackButton(color: AppColors.forest700),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(l10n.plannerShareProgress,
                        style: AppTextStyles.greetingSerif),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                children: [
                  // ── Range picker ───────────────────────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ShareRange.values.map((r) {
                      final sel = r == _range;
                      return GestureDetector(
                        onTap: () {
                          H.selection();
                          setState(() => _range = r);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.forest600.withValues(alpha: .12)
                                : AppColors.card,
                            borderRadius: AppRadius.pill,
                            border: Border.all(
                              color: sel
                                  ? AppColors.forest600.withValues(alpha: .35)
                                  : AppColors.stone100,
                            ),
                          ),
                          child: Text(
                            _rangeLabel(l10n, r),
                            style: AppTextStyles.labelLarge.copyWith(
                              color: sel
                                  ? AppColors.forest600
                                  : AppColors.stone600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── The shareable card ─────────────────────────────────
                  RepaintBoundary(
                    key: _cardKey,
                    child: _ShareCard(
                      subtitle: subtitle,
                      totalDistance:
                          formatDistance(totalKm, imperial: imperial, l10n: l10n),
                      totalTime: _fmtActiveTime(l10n, totalMin),
                      sessions: inRange.length,
                      rows: topRows,
                      imperial: imperial,
                      imperialWeight: imperialWeight,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Share button ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _sharing ? null : _share,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.forest600,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      icon: _sharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.ios_share_rounded, size: 18),
                      label: Text(l10n.plannerShareCta),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── The captured card ────────────────────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.subtitle,
    required this.totalDistance,
    required this.totalTime,
    required this.sessions,
    required this.rows,
    required this.imperial,
    required this.imperialWeight,
  });

  final String subtitle;
  final String totalDistance;
  final String totalTime;
  final int sessions;
  final List<MapEntry<ActivityDiscipline, _Agg>> rows;
  final bool imperial;
  final bool imperialWeight;

  String _rowValue(AppLocalizations l10n, ActivityDiscipline d, _Agg agg) {
    if (distanceDisciplines.contains(d) && agg.distanceKm > 0) {
      return formatDistance(agg.distanceKm, imperial: imperial, l10n: l10n);
    }
    if (d == ActivityDiscipline.gym && agg.volumeKg > 0) {
      return formatWeight(agg.volumeKg, imperial: imperialWeight, l10n: l10n);
    }
    return _fmtActiveTime(l10n, agg.minutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xxl,
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand row ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.mintChip,
                  borderRadius: AppRadius.pill,
                  border: Border.all(color: AppColors.forest100),
                ),
                child: Icon(Icons.eco_outlined,
                    size: 16, color: AppColors.forest600),
              ),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context).appTitle,
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.forest700)),
            ],
          ),
          const SizedBox(height: 18),

          // ── Heading + range ────────────────────────────────────────────
          Text(l10n.plannerShareHeading,
              style: AppTextStyles.greetingSerif
                  .copyWith(fontSize: 26, color: AppColors.forestDark)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.stone500)),
          const SizedBox(height: 18),

          // ── Headline stats ─────────────────────────────────────────────
          Row(
            children: [
              _Stat(label: l10n.plannerTotalDistance, value: totalDistance),
              _Stat(label: l10n.plannerTotalActiveTime, value: totalTime),
              _Stat(label: l10n.plannerMeasureSessions, value: '$sessions'),
            ],
          ),

          if (rows.isNotEmpty) ...[
            const SizedBox(height: 18),
            Divider(color: AppColors.stone100, height: 1),
            const SizedBox(height: 14),
            Text(l10n.plannerByActivity,
                style: AppTextStyles.overline),
            const SizedBox(height: 10),
            ...rows.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: disciplineTint(e.key),
                          borderRadius: AppRadius.sm,
                        ),
                        child: Icon(disciplineIcon(e.key),
                            size: 16, color: disciplineColor(e.key)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(disciplineLabel(l10n, e.key),
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.stoneText)),
                      ),
                      Text(_rowValue(l10n, e.key, e.value),
                          style: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.forest700)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTextStyles.titleLarge
                    .copyWith(color: AppColors.forestDark)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      );
}
