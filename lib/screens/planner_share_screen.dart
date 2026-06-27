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
import '../theme/share_card_kit.dart';
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
      final image = await boundary.toImage(pixelRatio: 1.0);
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
    // Cap at 3 so the fixed 1080-tall card never overflows into the footer;
    // any remaining disciplines still count toward the headline totals above.
    final topRows = rows.take(3).toList();

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
                  // Built at native 1080x1080 inside a FittedBox so the on-screen
                  // preview and the captured PNG are the same pixels.
                  LayoutBuilder(
                    builder: (context, c) => SizedBox(
                      width: c.maxWidth,
                      height: c.maxWidth,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 1080,
                          height: 1080,
                          child: RepaintBoundary(
                            key: _cardKey,
                            child: _ShareCard(
                              subtitle: subtitle,
                              totalDistance: formatDistance(totalKm,
                                  imperial: imperial, l10n: l10n),
                              totalTime: _fmtActiveTime(l10n, totalMin),
                              sessions: inRange.length,
                              rows: topRows,
                              imperial: imperial,
                              imperialWeight: imperialWeight,
                            ),
                          ),
                        ),
                      ),
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

// ─── The captured card — Training Summary template (1080x1080) ───────────────

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

  // Split a "22.7 km" value into a big number + small unit; leaves values with
  // no trailing alpha unit (e.g. "6", "2h 29m") whole.
  List<InlineSpan> _valueSpans(String text) {
    final i = text.lastIndexOf(' ');
    if (i > 0) {
      final unit = text.substring(i + 1);
      if (unit.length <= 3 && RegExp(r'^[A-Za-z]+$').hasMatch(unit)) {
        return [
          TextSpan(text: text.substring(0, i)),
          TextSpan(
              text: ' $unit',
              style: scFrau(30, kScDateGrey, w: FontWeight.w500)),
        ];
      }
    }
    return [TextSpan(text: text)];
  }

  Widget _statCell(String value, String label) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(children: _valueSpans(value)),
                  maxLines: 1,
                  style: scFrau(62, kScTitleGreen, height: 1.0),
                ),
              ),
              const SizedBox(height: 10),
              Text(label, maxLines: 1, style: scInt(23, kScDateGrey)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalMin =
        rows.fold<int>(0, (s, e) => s + e.value.minutes).clamp(1, 1 << 30);

    return SizedBox(
      width: 1080,
      height: 1080,
      child: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: kScCream)),
          const Positioned(
            right: 18,
            bottom: 18,
            child: Opacity(
              opacity: 0.06,
              child: SizedBox(
                width: 460,
                height: 460,
                child:
                    CustomPaint(painter: GrowingPlant(color: kScForest, stage: 0.6)),
              ),
            ),
          ),
          Positioned(
            left: 34,
            top: 34,
            right: 34,
            bottom: 34,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: kScForest, width: 2),
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
          Positioned(
            left: 44,
            top: 44,
            right: 44,
            bottom: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: kScForestFaint, width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            left: 44,
            top: 44,
            right: 44,
            bottom: 44,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(64, 58, 64, 58),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 70,
                            height: 70,
                            child: CustomPaint(
                                painter: LotusMark(color: kScForest)),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('JOURNEY FORWARD',
                                    style: scInt(21, kScBrandGreen,
                                        w: FontWeight.w600,
                                        height: 1.0,
                                        ls: 0.22 * 21)),
                                const SizedBox(height: 5),
                                Text(l10n.plannerShareHeading,
                                    style: scFrau(60, kScTitleGreen,
                                        height: 1.0, ls: -0.015 * 60)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(subtitle, style: scInt(26, kScDateGrey)),
                      const SizedBox(height: 40),
                      // Stat box: distance / active time / sessions.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: kScStatBox,
                          border: Border.all(color: kScForestHair),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _statCell(
                                    totalDistance, l10n.plannerTotalDistance),
                                Container(width: 1, color: kScForestHair),
                                _statCell(
                                    totalTime, l10n.plannerTotalActiveTime),
                                Container(width: 1, color: kScForestHair),
                                _statCell(
                                    '$sessions', l10n.plannerMeasureSessions),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 42),
                      Text(l10n.plannerByActivity.toUpperCase(),
                          style: scInt(22, kScBrandGreen,
                              w: FontWeight.w600, height: 1.0, ls: 0.16 * 22)),
                      const SizedBox(height: 8),
                      ...rows.map((e) {
                        final d = e.key;
                        final frac = (e.value.minutes / totalMin).clamp(0.04, 1.0);
                        return Container(
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: kScForestHair)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: disciplineTint(d),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(disciplineIcon(d),
                                        size: 36, color: disciplineColor(d)),
                                  ),
                                  const SizedBox(width: 22),
                                  Expanded(
                                    child: Text(disciplineLabel(l10n, d),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: scInt(34, kScTitleGreen,
                                            w: FontWeight.w500, height: 1.0)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(_rowValue(l10n, d, e.value),
                                      style: scFrau(38, kScTitleGreen,
                                          height: 1.0)),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 86, top: 18),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    height: 10,
                                    // ignore: deprecated_member_use
                                    color: kScForest.withOpacity(0.1),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: frac,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: disciplineColor(d),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                // Footer pinned to the bottom of the content frame.
                Positioned(
                  left: 64,
                  right: 64,
                  bottom: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(l10n.weeklySummaryFooterPrivacy,
                            style: scInt(21, kScFooterGrey, height: 1.4)),
                      ),
                      const SizedBox(width: 16),
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CustomPaint(
                            painter: LotusMark(
                                color: kScForest,
                                includeCircle: false,
                                strokeWidth: 4.6)),
                      ),
                      const SizedBox(width: 12),
                      Text('journeyforward.app',
                          style:
                              scInt(22, kScBrandGreen, w: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
