import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../components/back_button.dart';
import '../theme/app_theme.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

List<DateTime> _last7() {
  final today = DateTime.now();
  return List.generate(7, (i) {
    final d = today.subtract(Duration(days: 6 - i));
    return DateTime(d.year, d.month, d.day);
  });
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<String> _weekLabels(List<DateTime> window) {
  const abbr = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return window.map((d) => abbr[d.weekday - 1]).toList();
}

int _moodScore(String mood) => switch (mood) {
      'great' => 5,
      'good' => 4,
      'okay' => 3,
      'hard' => 2,
      'crisis' => 1,
      _ => 0,
    };

Color _moodColor(int score) => switch (score) {
      5 => AppColors.forest600,
      4 => AppColors.forest400,
      3 => AppColors.honey500,
      2 => AppColors.blush400,
      1 => AppColors.blush600,
      _ => AppColors.stone100,
    };

// ─── Insights Screen ──────────────────────────────────────────────────────────

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final window = _last7();
    final labels = _weekLabels(window);

    final journals = ref.watch(journalProvider).valueOrNull ?? [];
    final cravings = ref.watch(cravingProvider).valueOrNull ?? [];
    final sleeps = ref.watch(sleepProvider).valueOrNull ?? [];
    final activities = ref.watch(activityProvider).valueOrNull ?? [];
    final thoughts = ref.watch(thoughtProvider).valueOrNull ?? [];

    // ── Mood per day (0 = no entry, 1–5 = mood scale) ────────────────────
    final moodByDay = window.map((day) {
      final entry = journals.where((j) => _sameDay(j.date, day)).firstOrNull;
      return entry == null ? 0 : _moodScore(entry.mood);
    }).toList();

    // ── Craving count per day ─────────────────────────────────────────────
    final cravingCounts = window
        .map((day) => cravings.where((c) => _sameDay(c.date, day)).length)
        .toList();
    final totalCravings = cravingCounts.fold(0, (a, b) => a + b);

    // ── Sleep hours per day (average if multiple entries) ─────────────────
    final sleepByDay = window.map((day) {
      final entries = sleeps.where((s) => _sameDay(s.date, day)).toList();
      if (entries.isEmpty) return 0.0;
      return entries.map((s) => s.hours).reduce((a, b) => a + b) /
          entries.length;
    }).toList();
    final validSleep = sleepByDay.where((h) => h > 0).toList();
    final avgSleep = validSleep.isEmpty
        ? 0.0
        : validSleep.reduce((a, b) => a + b) / validSleep.length;

    // ── Activity minutes per day ──────────────────────────────────────────
    final actByDay = window
        .map((day) => activities
            .where((a) => _sameDay(a.date, day))
            .fold(0, (sum, a) => sum + a.minutes))
        .toList();
    final activeDays = actByDay.where((m) => m > 0).length;

    // ── Thought sentiment last 7 days ─────────────────────────────────────
    final recent =
        thoughts.where((t) => window.any((d) => _sameDay(t.date, d))).toList();
    final positiveCount = recent.where((t) => t.type == 'positive').length;
    final neutralCount = recent.where((t) => t.type == 'neutral').length;
    final negativeCount = recent.where((t) => t.type == 'negative').length;

    final hasMood = moodByDay.any((v) => v > 0);
    final hasCravings = cravingCounts.any((v) => v > 0);
    final hasSleep = sleepByDay.any((v) => v > 0);
    final hasActivity = actByDay.any((v) => v > 0);

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 14, 24, 0),
                  child: Row(
                    children: [
                      LuxuryBackButton(color: AppColors.forest700),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(l10n.insightsTitle,
                            style: AppTextStyles.greetingSerif),
                      ),
                      Text(
                        l10n.insights7DayView,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone400),
                      ),
                    ],
                  ),
                ),

                // ── Content ───────────────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    children: [
                      // ── Summary stat chips ───────────────────────────────
                      Row(
                        children: [
                          _StatChip(
                            label: 'Cravings',
                            value: '$totalCravings',
                            sub: '7 days',
                            color: AppColors.honey500,
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            label: 'Avg Sleep',
                            value: avgSleep > 0
                                ? '${avgSleep.toStringAsFixed(1)}h'
                                : '—',
                            sub: '7 days',
                            color: AppColors.forest400,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StatChip(
                            label: 'Active Days',
                            value: '$activeDays',
                            sub: '7 days',
                            color: AppColors.honey500,
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            label: 'Journal Days',
                            value: '${moodByDay.where((v) => v > 0).length}',
                            sub: '7 days',
                            color: AppColors.forest600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Mood trend ───────────────────────────────────────
                      _ChartCard(
                        title: 'Mood — 7 days',
                        chartHeight: 148,
                        child: hasMood
                            ? _MoodBarChart(data: moodByDay, labels: labels)
                            : const _EmptyChart(
                                label: 'No journal entries yet'),
                      ),
                      const SizedBox(height: 12),

                      // ── Craving trend ────────────────────────────────────
                      _ChartCard(
                        title: 'Cravings — 7 days',
                        child: hasCravings
                            ? _SimpleLineChart(
                                data: cravingCounts
                                    .map((v) => v.toDouble())
                                    .toList(),
                                labels: labels,
                                color: AppColors.honey500,
                              )
                            : const _EmptyChart(label: 'No cravings logged'),
                      ),
                      const SizedBox(height: 12),

                      // ── Sleep ────────────────────────────────────────────
                      _ChartCard(
                        title: 'Sleep — 7 days (hours)',
                        child: hasSleep
                            ? _SimpleBarChart(
                                data: sleepByDay,
                                labels: labels,
                                color: AppColors.forest400,
                              )
                            : const _EmptyChart(label: 'No sleep logged'),
                      ),
                      const SizedBox(height: 12),

                      // ── Exercise ─────────────────────────────────────────
                      _ChartCard(
                        title: 'Exercise — 7 days (minutes)',
                        child: hasActivity
                            ? _SimpleBarChart(
                                data:
                                    actByDay.map((v) => v.toDouble()).toList(),
                                labels: labels,
                                color: AppColors.honey500,
                              )
                            : const _EmptyChart(label: 'No activity logged'),
                      ),
                      const SizedBox(height: 12),

                      // ── Thought patterns ─────────────────────────────────
                      _ThoughtPatternCard(
                        positive: positiveCount,
                        neutral: neutralCount,
                        negative: negativeCount,
                      ),
                    ],
                  ),
                ),
              ],
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
    required this.sub,
    required this.color,
  });
  final String label, value, sub;
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
              Text(value,
                  style: AppTextStyles.displaySmall
                      .copyWith(fontSize: 28, color: color)),
              Text(sub, style: AppTextStyles.bodySmall),
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
    this.chartHeight = 120,
  });
  final String title;
  final Widget child;
  final double chartHeight;

  @override
  Widget build(BuildContext context) => SolidCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleSmall),
            const SizedBox(height: 14),
            SizedBox(height: chartHeight, child: child),
          ],
        ),
      );
}

// ─── Empty Chart ──────────────────────────────────────────────────────────────

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

// ─── Mood Bar Chart ───────────────────────────────────────────────────────────

class _MoodBarChart extends StatelessWidget {
  const _MoodBarChart({required this.data, required this.labels});
  final List<int> data;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BarChart(
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
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(labels[i], style: AppTextStyles.caption);
                    },
                    reservedSize: 20,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              maxY: 5,
              barGroups: data.asMap().entries.map((e) {
                final score = e.value;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: score > 0 ? score.toDouble() : 0.15,
                      color: _moodColor(score),
                      width: 14,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MoodLegend(color: AppColors.forest600, label: 'Great'),
            SizedBox(width: 10),
            _MoodLegend(color: AppColors.honey500, label: 'Okay'),
            SizedBox(width: 10),
            _MoodLegend(color: AppColors.blush400, label: 'Hard'),
          ],
        ),
      ],
    );
  }
}

class _MoodLegend extends StatelessWidget {
  const _MoodLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      );
}

// ─── Simple Line Chart ────────────────────────────────────────────────────────

class _SimpleLineChart extends StatelessWidget {
  const _SimpleLineChart({
    required this.data,
    required this.labels,
    required this.color,
  });
  final List<double> data;
  final List<String> labels;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
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
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
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

// ─── Thought Pattern Card ─────────────────────────────────────────────────────

class _ThoughtPatternCard extends StatelessWidget {
  const _ThoughtPatternCard({
    required this.positive,
    required this.neutral,
    required this.negative,
  });
  final int positive, neutral, negative;

  @override
  Widget build(BuildContext context) {
    final total = positive + neutral + negative;

    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thought Patterns — 7 days', style: AppTextStyles.titleSmall),
          const SizedBox(height: 14),
          if (total == 0)
            const _EmptyChart(label: 'No thoughts logged')
          else ...[
            _ThoughtRow(
              label: 'Positive',
              count: positive,
              total: total,
              color: AppColors.forest600,
            ),
            const SizedBox(height: 10),
            _ThoughtRow(
              label: 'Neutral',
              count: neutral,
              total: total,
              color: AppColors.stone400,
            ),
            const SizedBox(height: 10),
            _ThoughtRow(
              label: 'Challenging',
              count: negative,
              total: total,
              color: AppColors.blush400,
            ),
          ],
        ],
      ),
    );
  }
}

class _ThoughtRow extends StatelessWidget {
  const _ThoughtRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });
  final String label;
  final int count, total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(label,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.stone600)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.stone100,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            style:
                AppTextStyles.labelMedium.copyWith(color: AppColors.stone600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
