// Training insights — read-only analytics over logged [PlannerActivity]s.
//
// Mirrors the existing wellbeing InsightsScreen idiom exactly (same header,
// SolidCard chart cards, _SimpleLineChart / _SimpleBarChart, _EmptyChart and
// _StatChip widgets — cloned here so the two screens stay visually identical
// without coupling). Differences are domain-only:
//   * data comes from plannerActivityProvider (logged workouts), not journals;
//   * distances are canonical KM and rendered unit-aware via formatDistance /
//     formatPace, keyed off profile.useImperial;
//   * if any aggregated activity is source = strava, the Strava attribution
//     mark is shown (their brand guidelines require "Powered by Strava" on any
//     surface that displays Strava-derived data).
//
// Aggregation window: the last 8 ISO weeks (current week back through 7 prior),
// so the trend/volume charts always have a stable 8-point x-axis even when only
// a few weeks have activity. Metric cards (total distance, average pace) sum
// over that same window.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../models/planner_activity.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../theme/planner_palette.dart';
import '../utils/locale_format.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Monday 00:00 of the ISO week containing [d].
DateTime _weekStart(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

/// The last 8 ISO week-start Mondays, oldest first (… , last week, this week).
List<DateTime> _last8Weeks() {
  final thisWeek = _weekStart(DateTime.now());
  return List.generate(8, (i) => thisWeek.subtract(Duration(days: 7 * (7 - i))));
}

bool _sameWeek(DateTime a, DateTime b) => _weekStart(a) == _weekStart(b);

/// Short week-start labels (e.g. `6/2`) for the x-axis. Kept numeric +
/// locale-agnostic so the axis reads the same in every language (the unit word
/// lives in the card title / metric chips, not on every tick).
List<String> _weekLabels(List<DateTime> weeks) =>
    weeks.map((w) => '${w.month}/${w.day}').toList();

// ─── Planner Insights Screen ────────────────────────────────────────────────

class PlannerInsightsScreen extends ConsumerWidget {
  const PlannerInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final profile = ref.watch(profileProvider).valueOrNull;
    final imperial = profile?.useImperial ?? false;
    final imperialWeight = profile?.useImperialWeight ?? false;

    final activities = ref.watch(plannerActivityProvider).valueOrNull ?? [];

    final weeks = _last8Weeks();
    final labels = _weekLabels(weeks);

    // Only activities that fall inside the 8-week window feed the charts/metrics.
    final windowStart = weeks.first;
    final inWindow = activities
        .where((a) => !a.date.isBefore(windowStart))
        .toList(growable: false);

    // ── Distance (km) per week ───────────────────────────────────────────────
    final distanceByWeek = weeks.map((w) {
      return inWindow
          .where((a) => _sameWeek(a.date, w))
          .fold<double>(0, (sum, a) => sum + (a.distanceKm ?? 0));
    }).toList();

    // ── Active minutes per week (volume) ─────────────────────────────────────
    final volumeByWeek = weeks.map((w) {
      return inWindow
          .where((a) => _sameWeek(a.date, w))
          .fold<int>(0, (sum, a) => sum + a.minutes)
          .toDouble();
    }).toList();

    // ── Aggregate metrics over the window ────────────────────────────────────
    final totalKm = distanceByWeek.fold<double>(0, (a, b) => a + b);
    final totalMinutes = inWindow.fold<int>(0, (sum, a) => sum + a.minutes);

    final hasDistance = distanceByWeek.any((v) => v > 0);
    final hasVolume = volumeByWeek.any((v) => v > 0);
    final hasAnything = inWindow.isNotEmpty;

    // Per-discipline aggregation over the window, busiest first.
    final byDiscipline = <ActivityDiscipline, _DisciplineAgg>{};
    for (final a in inWindow) {
      final agg =
          byDiscipline.putIfAbsent(a.effectiveDiscipline, _DisciplineAgg.new);
      agg.count += 1;
      agg.minutes += a.minutes;
      agg.distanceKm += a.distanceKm ?? 0;
      agg.volumeKg += a.strengthVolumeKg ?? 0;
    }
    final disciplineRows = byDiscipline.entries.toList()
      ..sort((x, y) => y.value.minutes.compareTo(x.value.minutes));

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 24, 0),
              child: Row(
                children: [
                  LuxuryBackButton(color: AppColors.forest700),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(l10n.plannerInsights,
                        style: AppTextStyles.greetingSerif),
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: hasAnything
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      children: [
                        // ── Metric cards ─────────────────────────────────
                        Row(
                          children: [
                            _StatChip(
                              label: l10n.plannerTotalDistance,
                              value: formatDistance(totalKm,
                                  imperial: imperial, l10n: l10n),
                              color: AppColors.forest600,
                            ),
                            const SizedBox(width: 10),
                            _StatChip(
                              label: l10n.plannerTotalActiveTime,
                              value: _fmtActiveTime(l10n, totalMinutes),
                              color: AppColors.honey600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Distance trend (line) ────────────────────────
                        _ChartCard(
                          title: l10n.plannerDistanceTrend,
                          child: hasDistance
                              ? _SimpleLineChart(
                                  data: distanceByWeek,
                                  labels: labels,
                                  color: AppColors.forest500,
                                  // Axis ticks are unit-aware: convert km→mi via
                                  // the same formatter the rest of the app uses.
                                  formatAxis: (km) => formatDistance(km,
                                      imperial: imperial, l10n: l10n),
                                )
                              : _EmptyChart(label: l10n.plannerNoActivities),
                        ),
                        const SizedBox(height: 12),

                        // ── Weekly volume (bar) ──────────────────────────
                        _ChartCard(
                          title: l10n.plannerWeeklyVolume,
                          child: hasVolume
                              ? _SimpleBarChart(
                                  data: volumeByWeek,
                                  labels: labels,
                                  color: AppColors.honey500,
                                )
                              : _EmptyChart(label: l10n.plannerNoActivities),
                        ),

                        // ── Per-discipline tiles ─────────────────────────
                        if (disciplineRows.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Semantics(
                            header: true,
                            child: Text(l10n.plannerByActivity,
                                style: AppTextStyles.titleSmall),
                          ),
                          const SizedBox(height: 12),
                          for (var i = 0; i < disciplineRows.length; i += 2)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _DisciplineTile(
                                        entry: disciplineRows[i],
                                        imperial: imperial,
                                        imperialWeight: imperialWeight),
                                  ),
                                  const SizedBox(width: 12),
                                  if (i + 1 < disciplineRows.length)
                                    Expanded(
                                      child: _DisciplineTile(
                                          entry: disciplineRows[i + 1],
                                          imperial: imperial,
                                          imperialWeight: imperialWeight),
                                    )
                                  else
                                    const Expanded(child: SizedBox()),
                                ],
                              ),
                            ),
                        ],
                      ],
                    )
                  : _EmptyState(label: l10n.plannerNoActivities),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: SolidCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.displaySmall
                    .copyWith(fontSize: 22, color: color),
              ),
            ],
          ),
        ),
      );
}

// ─── Chart Card ───────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.child,
  });
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SolidCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header so a screen-reader user can jump chart-to-chart; the
            // fl_chart body itself carries no useful semantics.
            Semantics(
              header: true,
              child: Text(title, style: AppTextStyles.titleSmall),
            ),
            const SizedBox(height: 14),
            SizedBox(height: 120, child: child),
          ],
        ),
      );
}

// ─── Empty Chart (in-card) ──────────────────────────────────────────────────

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_rounded,
                color: AppColors.stone200, size: 32),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      );
}

// ─── Empty State (full screen) ──────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insights_outlined,
                  color: AppColors.stone200, size: 44),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

// ─── Simple Line Chart ────────────────────────────────────────────────────────

class _SimpleLineChart extends StatelessWidget {
  const _SimpleLineChart({
    required this.data,
    required this.labels,
    required this.color,
    this.formatAxis,
  });
  final List<double> data;
  final List<String> labels;
  final Color color;

  /// Optional left-axis tick formatter (e.g. unit-aware distance). When null
  /// no left titles are drawn — matching the wellbeing InsightsScreen.
  final String Function(double)? formatAxis;

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final maxVal = data.fold<double>(0, (a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.stone100, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: formatAxis == null
              ? const AxisTitles(sideTitles: SideTitles(showTitles: false))
              : AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    // Only label the top of the axis so a unit-bearing string
                    // fits without crowding the plot.
                    getTitlesWidget: (v, meta) {
                      if (v < meta.max) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(formatAxis!(v),
                            style: AppTextStyles.caption),
                      );
                    },
                  ),
                ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Text(labels[i], style: AppTextStyles.caption);
              },
              reservedSize: 20,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        maxY: maxVal > 0 ? maxVal * 1.2 : 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            // Stop the spline from dipping below the lowest point: with mostly-
            // flat weeks then a spike, an unclamped curve undershoots below zero
            // and reads as a phantom "dip" before the rise. This pins the curve
            // so it never overshoots past the actual data values.
            preventCurveOverShooting: true,
            color: color,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Simple Bar Chart ─────────────────────────────────────────────────────────

class _SimpleBarChart extends StatelessWidget {
  const _SimpleBarChart({
    required this.data,
    required this.labels,
    required this.color,
  });
  final List<double> data;
  final List<String> labels;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold<double>(0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.stone100, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Text(labels[i], style: AppTextStyles.caption);
              },
              reservedSize: 20,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data
            .asMap()
            .entries
            .map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value,
                      color: color,
                      width: 14,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: (maxVal * 1.2).clamp(1, double.infinity),
                        color: AppColors.stone50,
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

// ─── Per-discipline aggregation + tile ────────────────────────────────────────

class _DisciplineAgg {
  int count = 0;
  int minutes = 0;
  double distanceKm = 0;
  double volumeKg = 0; // strength tonnage (gym)
}

/// Format summed active minutes as "Xh Ym" (or "N min" under an hour).
String _fmtActiveTime(AppLocalizations l10n, int minutes) {
  if (minutes < 60) return l10n.commonMin(minutes);
  return l10n.plannerDurationHm(minutes ~/ 60, minutes % 60);
}

/// One tile in the "By activity" grid: discipline icon + label, a headline
/// (total distance for distance disciplines, otherwise total active time), and
/// the activity count over the window.
class _DisciplineTile extends StatelessWidget {
  const _DisciplineTile({
    required this.entry,
    required this.imperial,
    required this.imperialWeight,
  });

  final MapEntry<ActivityDiscipline, _DisciplineAgg> entry;
  final bool imperial;
  final bool imperialWeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = entry.key;
    final agg = entry.value;
    final isDistance = distanceDisciplines.contains(d) && agg.distanceKm > 0;
    // Gym headlines its tonnage (sets×reps×weight) when there is any.
    final isGymTonnage = d == ActivityDiscipline.gym && agg.volumeKg > 0;
    final headline = isDistance
        ? formatDistance(agg.distanceKm, imperial: imperial, l10n: l10n)
        : isGymTonnage
            ? formatWeight(agg.volumeKg, imperial: imperialWeight, l10n: l10n)
            : _fmtActiveTime(l10n, agg.minutes);

    return SolidCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: disciplineTint(d),
                  borderRadius: AppRadius.md,
                ),
                child:
                    Icon(disciplineIcon(d), size: 17, color: disciplineColor(d)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(disciplineLabel(l10n, d),
                    style: AppTextStyles.titleSmall,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(headline,
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.forestDark)),
          const SizedBox(height: 2),
          Text(l10n.plannerActivityCount(agg.count),
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
