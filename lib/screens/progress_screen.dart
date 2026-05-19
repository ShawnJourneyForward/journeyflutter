import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Milestone definitions ─────────────────────────────────────────────────

const _allMilestones = [1, 3, 7, 14, 30, 60, 90, 100, 180, 365];

// ─── Progress Screen ───────────────────────────────────────────────────────

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {

  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(profileProvider);
    // soberDaysProvider only rebuilds at midnight — no need for per-second ticks here.
    final stats = ref.watch(soberDaysProvider);

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -4,
              right: -18,
              child: IgnorePointer(
                child: BotanicalBackground(width: 150, height: 92),
              ),
            ),
            Column(
              children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.progressTitle, style: AppTextStyles.greetingSerif),
                  ),
                  if (stats != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.forest50,
                        borderRadius: AppRadius.pill,
                        border: Border.all(color: AppColors.forest100),
                      ),
                      child: Text(
                        l10n.progressDaysChip(stats.days),
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.forest600),
                      ),
                    ),
                ],
              ),
            ),

            // ── Tab bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppRadius.pill,
                  border: Border.all(color: AppColors.softBorder),
                ),
                child: TabBar(
                  controller: _tabs,
                  labelStyle: AppTextStyles.labelLarge,
                  unselectedLabelStyle: AppTextStyles.bodySmall,
                  labelColor: AppColors.forest700,
                  unselectedLabelColor: AppColors.stone500,
                  indicator: BoxDecoration(
                    color: AppColors.mintChip,
                    borderRadius: AppRadius.pill,
                    boxShadow: AppShadows.card,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: l10n.progressTabJourney),
                    Tab(text: l10n.progressTabInsights),
                  ],
                ),
              ),
            ),

            // ── Tab views ──────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _StreakTab(stats: stats, profile:
                      profileAsync.valueOrNull),
                  _InsightsTab(),
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

// ─── Streak Tab ────────────────────────────────────────────────────────────

class _StreakTab extends ConsumerWidget {
  const _StreakTab({required this.stats, required this.profile});
  final SoberStats? stats;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final milestoneLabels = {
      1:   l10n.progressMilestoneLabel1,
      3:   l10n.progressMilestoneLabel3,
      7:   l10n.progressMilestoneLabel7,
      14:  l10n.progressMilestoneLabel14,
      30:  l10n.progressMilestoneLabel30,
      60:  l10n.progressMilestoneLabel60,
      90:  l10n.progressMilestoneLabel90,
      100: l10n.progressMilestoneLabel100,
      180: l10n.progressMilestoneLabel180,
      365: l10n.progressMilestoneLabel365,
    };
    final days = stats?.days ?? 0;

    // Next milestone
    final nextMs = _allMilestones.firstWhere(
        (m) => m > days, orElse: () => _allMilestones.last);
    final prevMs = _allMilestones.lastWhere(
        (m) => m <= days, orElse: () => 0);
    final progress = nextMs == prevMs
        ? 1.0
        : ((days - prevMs) / (nextMs - prevMs)).clamp(0.0, 1.0);
    final atMilestone = _allMilestones.contains(days) && days > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      children: [

        // ── Live counter ────────────────────────────────────────────────
        SolidCard(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(atMilestone
                    ? 'Milestone reached'
                    : 'Current journey',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.forest600,
                            letterSpacing: 1.0)),
                const SizedBox(height: 8),
                // D : H : M : S
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CounterUnit(value: stats?.days ?? 0,    label: 'DAYS'),
                    _Colon(),
                    _CounterUnit(value: stats?.hours ?? 0,   label: 'HRS'),
                    _Colon(),
                    _CounterUnit(value: stats?.minutes ?? 0, label: 'MIN'),
                    _Colon(),
                    _CounterUnit(value: stats?.seconds ?? 0, label: 'SEC'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ── Next milestone progress ──────────────────────────────────────
        SolidCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    atMilestone
                        ? 'Milestone: ${milestoneLabels[days] ?? '$days Days'}'
                        : 'Next: ${milestoneLabels[nextMs] ?? '$nextMs Days'}',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.forest700),
                  ),
                  Text(
                    atMilestone ? '100%' : '${(progress * 100).round()}%',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.forest600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: AppRadius.pill,
                child: LinearProgressIndicator(
                  value: atMilestone ? 1.0 : progress,
                  minHeight: 8,
                  backgroundColor: AppColors.mintChip,
                  valueColor: AlwaysStoppedAnimation(
                      atMilestone ? AppColors.honey500 : AppColors.leafGreen),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                atMilestone
                    ? 'A beautiful threshold crossed.'
                    : '$days / $nextMs days',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Heatmap entry point ──────────────────────────────────────────
        GestureDetector(
          onTap: () {
            H.light();
            context.push('/heatmap');
          },
          child: SolidCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.forest50,
                    borderRadius: AppRadius.md,
                  ),
                  child: const Icon(Icons.grid_view_rounded,
                      size: 20, color: AppColors.forest600),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Activity Heatmap',
                          style: AppTextStyles.titleSmall),
                      Text('See your logged activity over time',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.stone400)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.stone300),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ── Milestone achievement grid ─────────────────────────────────────
        SolidCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Milestones', style: AppTextStyles.titleMedium),
                  GestureDetector(
                    onTap: () => context.push('/milestone'),
                    child: Text('Cards',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.forest600)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _allMilestones.length,
                itemBuilder: (_, i) {
                  final ms = _allMilestones[i];
                  final achieved = days >= ms;
                  final isCurrent = ms == days;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.honey50
                          : achieved
                              ? AppColors.forest50
                              : AppColors.stone50,
                      borderRadius: AppRadius.md,
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.honey500
                            : achieved
                                ? AppColors.forest200
                                : AppColors.stone100,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (achieved)
                          Icon(
                            isCurrent
                                ? Icons.star_rounded
                                : Icons.check_circle_rounded,
                            size: 18,
                            color: isCurrent
                                ? AppColors.honey500
                                : AppColors.forest600,
                          )
                        else
                          Icon(Icons.lock_outline_rounded,
                              size: 14, color: AppColors.stone300),
                        const SizedBox(height: 2),
                        Text(
                          ms >= 365
                              ? '1yr'
                              : ms >= 30
                                  ? '${ms ~/ 30}mo'
                                  : '${ms}d',
                          style: AppTextStyles.caption.copyWith(
                            color: achieved
                                ? AppColors.forest700
                                : AppColors.stone300,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterUnit extends StatelessWidget {
  const _CounterUnit({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value.toString().padLeft(2, '0'),
          style: AppTextStyles.displaySmall
              .copyWith(color: AppColors.forest700, fontSize: 30)),
      Text(label, style: AppTextStyles.caption
          .copyWith(color: AppColors.stone400)),
    ],
  );
}

class _Colon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Text(':',
        style: AppTextStyles.displaySmall
            .copyWith(fontSize: 26, color: AppColors.stone200)),
  );
}


// ─── Insights Tab ──────────────────────────────────────────────────────────

class _InsightsTab extends ConsumerWidget {
  const _InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cravings = ref.watch(_cravingsProvider);
    final sleep    = ref.watch(_sleepProvider);
    final thoughts = ref.watch(_thoughtsProvider);
    final activity = ref.watch(_activityProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      children: [

        // ── 4-stat summary ────────────────────────────────────────────────
        Row(
          children: [
            _StatChip(
                label: 'Cravings',
                value: '${cravings.last7}',
                sub: '7 days',
                color: AppColors.honey500),
            const SizedBox(width: 10),
            _StatChip(
                label: 'Thoughts',
                value: '${thoughts.last7}',
                sub: '7 days',
                color: AppColors.stone400),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatChip(
                label: 'Avg Sleep',
                value: sleep.avgHours > 0
                    ? '${sleep.avgHours.toStringAsFixed(1)}h'
                    : '—',
                sub: '7 days',
                color: AppColors.forest400),
            const SizedBox(width: 10),
            _StatChip(
                label: 'Active Days',
                value: '${activity.activeDays7}',
                sub: '7 days',
                color: AppColors.honey500),
          ],
        ),
        const SizedBox(height: 14),

        // ── Craving trend chart ───────────────────────────────────────────
        _ChartCard(
          title: 'Cravings — 7 days',
          child: cravings.dailyCounts.every((v) => v == 0)
              ? _EmptyChart(label: 'No cravings logged')
              : _LineChart(
                  data: cravings.dailyCounts.map((v) => v.toDouble()).toList(),
                  color: AppColors.honey500,
                ),
        ),
        const SizedBox(height: 14),

        // ── Sleep chart ───────────────────────────────────────────────────
        _ChartCard(
          title: 'Sleep — 7 days',
          child: sleep.dailyHours.every((v) => v == 0)
              ? _EmptyChart(label: 'No sleep logged')
              : _BarChart(
                  data: sleep.dailyHours,
                  color: AppColors.forest400,
                ),
        ),
        const SizedBox(height: 14),

        // ── Exercise chart ─────────────────────────────────────────────────
        _ChartCard(
          title: 'Exercise — 7 days (minutes)',
          child: activity.dailyMinutes.every((v) => v == 0)
              ? _EmptyChart(label: 'No activity logged')
              : _BarChart(
                  data: activity.dailyMinutes.map((v) => v.toDouble()).toList(),
                  color: AppColors.honey500,
                ),
        ),

        const SizedBox(height: 14),
        Center(
          child: TextButton.icon(
            onPressed: () => context.push('/insights'),
            icon: const Icon(Icons.bar_chart_rounded, size: 16),
            label: const Text('Full Insights'),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.forest600,
                textStyle: AppTextStyles.labelLarge),
          ),
        ),
      ],
    );
  }
}

// ─── Insights data providers (lightweight, derived from storage) ────────────

List<DateTime> _last7() {
  final today = DateTime.now();
  return List.generate(7, (i) {
    final d = today.subtract(Duration(days: 6 - i));
    return DateTime(d.year, d.month, d.day);
  });
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _CravingStats {
  final int last7;
  final List<int> dailyCounts;
  const _CravingStats({required this.last7, required this.dailyCounts});
}

class _SleepStats {
  final double avgHours;
  final List<double> dailyHours;
  const _SleepStats({required this.avgHours, required this.dailyHours});
}

class _ThoughtStats {
  final int last7;
  const _ThoughtStats({required this.last7});
}

class _ActivityStats {
  final int activeDays7;
  final List<int> dailyMinutes;
  const _ActivityStats({required this.activeDays7, required this.dailyMinutes});
}

final _cravingsProvider = Provider<_CravingStats>((ref) {
  final window   = _last7();
  final cravings = ref.watch(cravingProvider).valueOrNull ?? [];
  final counts   = window
      .map((day) => cravings.where((c) => _sameDay(c.date, day)).length)
      .toList();
  return _CravingStats(
    last7: counts.fold(0, (a, b) => a + b),
    dailyCounts: counts,
  );
});

final _sleepProvider = Provider<_SleepStats>((ref) {
  final window = _last7();
  final sleeps  = ref.watch(sleepProvider).valueOrNull ?? [];
  final hours   = window.map((day) {
    final entries = sleeps.where((s) => _sameDay(s.date, day)).toList();
    if (entries.isEmpty) return 0.0;
    return entries.map((s) => s.hours).reduce((a, b) => a + b) / entries.length;
  }).toList();
  final valid = hours.where((h) => h > 0).toList();
  return _SleepStats(
    avgHours: valid.isEmpty
        ? 0.0
        : valid.reduce((a, b) => a + b) / valid.length,
    dailyHours: hours,
  );
});

final _thoughtsProvider = Provider<_ThoughtStats>((ref) {
  final window   = _last7();
  final thoughts = ref.watch(thoughtProvider).valueOrNull ?? [];
  final count    = thoughts
      .where((t) => window.any((d) => _sameDay(t.date, d)))
      .length;
  return _ThoughtStats(last7: count);
});

final _activityProvider = Provider<_ActivityStats>((ref) {
  final window     = _last7();
  final activities = ref.watch(activityProvider).valueOrNull ?? [];
  final minutes    = window
      .map((day) => activities
          .where((a) => _sameDay(a.date, day))
          .fold(0, (sum, a) => sum + a.minutes))
      .toList();
  return _ActivityStats(
    activeDays7: minutes.where((m) => m > 0).length,
    dailyMinutes: minutes,
  );
});

// ─── Chart widgets ─────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label, required this.value,
    required this.sub,   required this.color,
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

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SolidCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleSmall),
        const SizedBox(height: 14),
        SizedBox(height: 120, child: child),
      ],
    ),
  );
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.show_chart_rounded,
            color: AppColors.stone200, size: 32),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    ),
  );
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.data, required this.color});
  final List<double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries
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
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const labels = ['M','T','W','T','F','S','S'];
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
              color: color.withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.data, required this.color});
  final List<double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.stone100, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const labels = ['M','T','W','T','F','S','S'];
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Text(labels[i], style: AppTextStyles.caption);
              },
              reservedSize: 20,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) =>
          BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: color,
                width: 14,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: (data.reduce((a, b) => a > b ? a : b) * 1.2)
                      .clamp(1, double.infinity),
                  color: AppColors.stone50,
                ),
              ),
            ],
          ),
        ).toList(),
      ),
    );
  }
}
