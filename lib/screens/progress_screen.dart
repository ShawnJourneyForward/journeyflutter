import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/craving_insights.dart';
import '../utils/haptic_service.dart';
import 'daily_practice_sheets.dart';

// ─── Milestone definitions ─────────────────────────────────────────────────

const _allMilestones = [
  1, 2, 3, 5, 7, 10, 14, 21, 30, 60, 90, 100, 180, 365, 730, 1095,
];

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
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // soberDaysProvider only rebuilds at midnight — no need for per-second ticks here.
    final stats = ref.watch(soberDaysProvider);

    // Switch to the requested tab when navigating from Settings.
    ref.listen(progressTabProvider, (_, next) {
      if (next != _tabs.index) {
        _tabs.animateTo(next);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(progressTabProvider.notifier).state = 0;
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Header ─────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(l10n.progressTitle,
                            style: AppTextStyles.greetingSerif),
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
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          H.light();
                          context.push('/weekly-care-summary');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.forest700,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.article_outlined,
                                  size: 14, color: AppColors.onForest),
                              const SizedBox(width: 4),
                              Text(
                                l10n.progressSummaryChip,
                                style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.onForest, fontSize: 11),
                              ),
                            ],
                          ),
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
                      _StreakTab(stats: stats),
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
  const _StreakTab({required this.stats});
  final SoberStats? stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final milestoneLabels = {
      1: l10n.progressMilestoneLabel1,
      2: l10n.progressMilestoneLabel2,
      3: l10n.progressMilestoneLabel3,
      5: l10n.progressMilestoneLabel5,
      7: l10n.progressMilestoneLabel7,
      10: l10n.progressMilestoneLabel10,
      14: l10n.progressMilestoneLabel14,
      21: l10n.progressMilestoneLabel21,
      30: l10n.progressMilestoneLabel30,
      60: l10n.progressMilestoneLabel60,
      90: l10n.progressMilestoneLabel90,
      100: l10n.progressMilestoneLabel100,
      180: l10n.progressMilestoneLabel180,
      365: l10n.progressMilestoneLabel365,
      730: l10n.progressMilestoneLabel730,
      1095: l10n.progressMilestoneLabel1095,
    };
    final days = stats?.days ?? 0;

    // Next milestone
    final nextMs = _allMilestones.firstWhere((m) => m > days,
        orElse: () => _allMilestones.last);
    final prevMs = _allMilestones.lastWhere((m) => m <= days, orElse: () => 0);
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
                Text(
                    atMilestone
                        ? l10n.progressMilestoneReached
                        : l10n.progressCurrentJourney,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.forest600, letterSpacing: 1.0)),
                const SizedBox(height: 8),
                // D : H : M : S — ticks every second from soberStatsProvider.
                // Isolated in _LiveDHMSRow so only those digits rebuild each
                // second, not the entire _StreakTab tree.
                RepaintBoundary(child: _LiveDHMSRow(fallback: stats)),
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
                        ? l10n.progressMilestonePrefix(
                            milestoneLabels[days] ?? l10n.progressDaysLabel(days))
                        : l10n.progressNextPrefix(milestoneLabels[nextMs] ??
                            l10n.progressDaysLabel(nextMs)),
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.forest700),
                  ),
                  Text(
                    atMilestone
                        ? l10n.progressPercentComplete(100)
                        : l10n.progressPercentComplete((progress * 100).round()),
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
                    ? l10n.progressThresholdCrossed
                    : l10n.progressDaysOfTarget(days, nextMs),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Inline 28-day cravings heatmap (toggleable) ───────────────
        // Day 1 = first app-use date (NOT sober date) so the heatmap is
        // meaningful even for users who join already weeks-sober. Users
        // further into recovery without frequent cravings can hide the
        // card; the dismiss control swaps to a re-enable button so it's
        // always recoverable without leaving the screen.
        const _CravingsHeatmapSection(),
        const SizedBox(height: 14),

        // ── Milestone achievement grid ─────────────────────────────────────
        SolidCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.progressMilestonesTitle,
                      style: AppTextStyles.titleMedium),
                  GestureDetector(
                    onTap: () => context.push('/milestone'),
                    child: Text(l10n.progressCardsLink,
                        style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.forest600,
                            fontWeight: FontWeight.w600)),
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
                              ? l10n.progressGridYear
                              : ms >= 30
                                  ? l10n.progressGridMonths(ms ~/ 30)
                                  : l10n.progressGridDays(ms),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: achieved
                                ? AppColors.forest700
                                : AppColors.stone300,
                            fontWeight:
                                isCurrent ? FontWeight.w700 : FontWeight.w500,
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

// ─── Live D:H:M:S counter ──────────────────────────────────────────────────
// Isolated ConsumerWidget so only these digits rebuild every second.
// The parent _StreakTab stays static; milestone math uses the slower
// soberDaysProvider (midnight cadence) passed down as [fallback].

class _LiveDHMSRow extends ConsumerWidget {
  const _LiveDHMSRow({required this.fallback});
  final SoberStats? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Pause when this tab is off-stage (TickerMode is false for an inactive
    // IndexedStack branch) so the per-second tick stops rebuilding this row
    // while the user is on another tab. That off-stage churn was landing on
    // Home's scroll frames as a 1 Hz hitch.
    final live = TickerMode.of(context);
    final liveStats =
        (live ? ref.watch(soberStatsProvider) : ref.read(soberStatsProvider)) ??
            fallback;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CounterUnit(value: liveStats?.days ?? 0, label: l10n.progressUnitDays),
        _Colon(),
        _CounterUnit(value: liveStats?.hours ?? 0, label: l10n.progressUnitHrs),
        _Colon(),
        _CounterUnit(value: liveStats?.minutes ?? 0, label: l10n.progressUnitMin),
        _Colon(),
        _CounterUnit(value: liveStats?.seconds ?? 0, label: l10n.progressUnitSec),
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
          Text(label,
              style: AppTextStyles.caption.copyWith(color: AppColors.stone400)),
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
  const _InsightsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final window = _last14();
    final cravings = ref.watch(_cravings14Provider);
    final sleep = ref.watch(_sleep14Provider);
    final activity = ref.watch(_activity14Provider);
    final thoughts = ref.watch(_thoughts14Provider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      children: [
        // ── Recovery capital weekly card — Kelly/White framework ────────
        // Shows the user's score (0-5) for this week, or invites them to
        // do the 30-second check if they haven't. Always sits at the top
        // because the multi-dimensional picture frames everything below.
        const _RecoveryCapitalCard(),
        const SizedBox(height: 14),

        // ── Risk window — "your tender hours" ──────────────────────────
        // Only renders when the user's own logs show real time-of-day
        // clustering (see topRiskWindow's noise guard). Fully on-device.
        const _RiskWindowCard(),

        _InsightTile(
          title: l10n.progressInsightCravingTitle,
          subtitle: l10n.progressInsightCravingSubtitle,
          data: cravings,
          barColor: AppColors.honey500,
          yLabel: l10n.progressYLabelLogs,
          window: window,
          quote: l10n.progressInsightCravingQuote,
        ),
        const SizedBox(height: 14),
        _InsightTile(
          title: l10n.progressInsightSleepTitle,
          subtitle: l10n.progressInsightSleepSubtitle,
          data: sleep,
          barColor: AppColors.forest400,
          yLabel: l10n.progressYLabelHrs,
          window: window,
          quote: l10n.progressInsightSleepQuote,
        ),
        const SizedBox(height: 14),
        _InsightTile(
          title: l10n.progressInsightMovementTitle,
          subtitle: l10n.progressInsightMovementSubtitle,
          data: activity,
          barColor: AppColors.leafGreen,
          yLabel: l10n.progressYLabelMin,
          window: window,
          quote: l10n.progressInsightMovementQuote,
        ),
        const SizedBox(height: 14),
        _InsightTile(
          title: l10n.progressInsightThoughtsTitle,
          subtitle: l10n.progressInsightThoughtsSubtitle,
          data: thoughts,
          barColor: AppColors.stone400,
          yLabel: l10n.progressYLabelLogs,
          window: window,
          quote: l10n.progressInsightThoughtsQuote,
        ),
      ],
    );
  }
}

// ─── Risk window card ────────────────────────────────────────────────────────

class _RiskWindowCard extends ConsumerWidget {
  const _RiskWindowCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cravings = ref.watch(cravingProvider).valueOrNull ?? const [];
    final window = topRiskWindow(cravings);
    if (window == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SolidCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.honey50,
                    borderRadius: AppRadius.sm,
                  ),
                  child: Icon(Icons.nights_stay_outlined,
                      size: 18, color: AppColors.honey600),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l10n.progressTenderHoursTitle,
                      style: AppTextStyles.titleMedium),
                ),
                Text(
                  window.localizedLabel(l10n),
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.honey600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.progressTenderHoursBody(window.count, window.total),
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.stone600, height: 1.5),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push('/pre-craving-plan'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  foregroundColor: AppColors.forest600,
                ),
                icon: const Icon(Icons.checklist_rounded, size: 17),
                label: Text(l10n.progressReviewMyPlan,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.forest600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 14-day window helper ──────────────────────────────────────────────────

List<DateTime> _last14() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekday = today.weekday; // 1 = Mon, 7 = Sun
  final currentMonday = today.subtract(Duration(days: weekday - 1));
  final windowStart = currentMonday.subtract(const Duration(days: 7));
  return List.generate(14, (i) => windowStart.add(Duration(days: i)));
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _fmtNum(double v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

// ─── _Insight14 model ─────────────────────────────────────────────────────

class _Insight14 {
  final List<double> dailyValues;
  final double thisWeek;
  final double lastWeek;
  final String trend;
  const _Insight14({
    required this.dailyValues,
    required this.thisWeek,
    required this.lastWeek,
    required this.trend,
  });
}

String _calcTrend(double tw, double lw) {
  if (tw < lw) return 'Easing';
  if (tw > lw) return 'Rising';
  return 'Stable';
}

// ─── 14-day providers ─────────────────────────────────────────────────────

final _cravings14Provider = Provider<_Insight14>((ref) {
  final window = _last14();
  final all = ref.watch(cravingProvider).valueOrNull ?? [];
  final values = window
      .map((d) => all.where((c) => _sameDay(c.date, d)).length.toDouble())
      .toList();
  final lw = values.sublist(0, 7).fold(0.0, (a, b) => a + b);
  final tw = values.sublist(7).fold(0.0, (a, b) => a + b);
  return _Insight14(
      dailyValues: values,
      thisWeek: tw,
      lastWeek: lw,
      trend: _calcTrend(tw, lw));
});

final _sleep14Provider = Provider<_Insight14>((ref) {
  final window = _last14();
  final all = ref.watch(sleepProvider).valueOrNull ?? [];
  final values = window.map((d) {
    final entries = all.where((s) => _sameDay(s.date, d)).toList();
    if (entries.isEmpty) return 0.0;
    return entries.map((s) => s.hours).reduce((a, b) => a + b) / entries.length;
  }).toList();
  final lw = values.sublist(0, 7).fold(0.0, (a, b) => a + b);
  final tw = values.sublist(7).fold(0.0, (a, b) => a + b);
  return _Insight14(
      dailyValues: values,
      thisWeek: tw,
      lastWeek: lw,
      trend: _calcTrend(tw, lw));
});

final _activity14Provider = Provider<_Insight14>((ref) {
  final window = _last14();
  final all = ref.watch(activityProvider).valueOrNull ?? [];
  final values = window
      .map((d) => all
          .where((a) => _sameDay(a.date, d))
          .fold(0, (sum, a) => sum + a.minutes)
          .toDouble())
      .toList();
  final lw = values.sublist(0, 7).fold(0.0, (a, b) => a + b);
  final tw = values.sublist(7).fold(0.0, (a, b) => a + b);
  return _Insight14(
      dailyValues: values,
      thisWeek: tw,
      lastWeek: lw,
      trend: _calcTrend(tw, lw));
});

final _thoughts14Provider = Provider<_Insight14>((ref) {
  final window = _last14();
  final all = ref.watch(thoughtProvider).valueOrNull ?? [];
  final values = window
      .map((d) => all.where((t) => _sameDay(t.date, d)).length.toDouble())
      .toList();
  final lw = values.sublist(0, 7).fold(0.0, (a, b) => a + b);
  final tw = values.sublist(7).fold(0.0, (a, b) => a + b);
  return _Insight14(
      dailyValues: values,
      thisWeek: tw,
      lastWeek: lw,
      trend: _calcTrend(tw, lw));
});

// ─── _InsightTile ─────────────────────────────────────────────────────────

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.title,
    required this.subtitle,
    required this.data,
    required this.barColor,
    required this.yLabel,
    required this.window,
    required this.quote,
  });
  final String title;
  final String subtitle;
  final _Insight14 data;
  final Color barColor;
  final String yLabel;
  final List<DateTime> window;
  final String quote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row
          Text(
            l10n.progressInsightTitle14Days(title),
            style:
                AppTextStyles.titleSmall.copyWith(color: AppColors.forest700),
          ),
          const SizedBox(height: 4),

          // ── Subtitle
          Text(subtitle,
              style: AppTextStyles.bodySmall
                  .copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 14),

          // ── Summary row — trend column removed; this/last week now share
          // the row evenly so the card stays balanced.
          IntrinsicHeight(
            child: Row(
              children: [
                _SummaryCol(
                    label: l10n.progressThisWeek,
                    value: _fmtNum(data.thisWeek),
                    valueColor: barColor),
                VerticalDivider(
                    thickness: 1, width: 1, color: AppColors.stone100),
                _SummaryCol(
                    label: l10n.progressLastWeek,
                    value: _fmtNum(data.lastWeek),
                    valueColor: AppColors.stone500),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Bar chart (Y-axis units printed as a quiet caption,
          //    not as an arrow-and-label row — feels less clinical).
          Row(
            children: [
              const Spacer(),
              Text(yLabel,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone400, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 170,
            child: _MiniBarChart14(
              values: data.dailyValues,
              barColor: barColor,
              window: window,
            ),
          ),
          const SizedBox(height: 14),

          // ── Motivational quote
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.stone50,
              borderRadius: AppRadius.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.spa_outlined,
                    size: 18, color: AppColors.forest400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(quote,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone500)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCol extends StatelessWidget {
  const _SummaryCol({
    required this.label,
    required this.value,
    required this.valueColor,
  });
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone400)),
              const SizedBox(height: 4),
              Text(value,
                  style: AppTextStyles.labelLarge
                      .copyWith(color: valueColor, fontSize: 22)),
            ],
          ),
        ),
      );
}

// ─── _MiniBarChart14 ──────────────────────────────────────────────────────
//
// Stillwater-aesthetic bar chart:
//   • Soft vertical gradient fill (color at top → tinted lighter at base)
//   • Generously rounded tops
//   • Dashed horizontal grid lines (no full-height background "wall")
//   • Today's bar gets a subtle ring to anchor the user in time
//   • Touch a bar to see its value in a soft pill tooltip — no permanent
//     number-clutter floating above every bar

class _MiniBarChart14 extends StatelessWidget {
  const _MiniBarChart14({
    required this.values,
    required this.barColor,
    required this.window,
  });
  final List<double> values;
  final Color barColor;
  final List<DateTime> window;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dayLetters = [
      l10n.progressDayLetterMon,
      l10n.progressDayLetterTue,
      l10n.progressDayLetterWed,
      l10n.progressDayLetterThu,
      l10n.progressDayLetterFri,
      l10n.progressDayLetterSat,
      l10n.progressDayLetterSun,
    ];
    final maxRaw =
        values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    // Add 25% headroom so the tallest bar doesn't kiss the top edge.
    final maxY = (maxRaw < 1.0 ? 1.0 : maxRaw) * 1.25;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Soft tinted top of the gradient — lighter, more breathable.
    final barTop = Color.lerp(barColor, Colors.white, 0.15) ?? barColor;
    final barBottom = Color.lerp(barColor, Colors.white, 0.55) ?? barColor;

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          // 3 evenly spaced grid lines — enough to read, not enough to clutter.
          horizontalInterval: maxY / 3,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.stone100,
            strokeWidth: 1,
            dashArray: const [4, 6],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY / 3,
              getTitlesWidget: (v, meta) {
                if (v == meta.max || v == meta.min) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    _fmtNum(v),
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 10, color: AppColors.stone400),
                  ),
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
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= window.length) {
                  return const SizedBox.shrink();
                }
                final isToday = _sameDay(window[i], today);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayLetters[window[i].weekday - 1],
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: isToday
                              ? AppColors.forest700
                              : AppColors.stone500,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        window[i].day.toString(),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          color: isToday
                              ? AppColors.forest600
                              : AppColors.stone400,
                          fontWeight:
                              isToday ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: values
            .asMap()
            .entries
            .map(
              (e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value == 0 ? maxY * 0.01 : e.value,
                    width: 12,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                    gradient: e.value == 0
                        ? null
                        : LinearGradient(
                            colors: [barTop, barBottom],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                    color: e.value == 0 ? AppColors.stone100 : null,
                  ),
                ],
              ),
            )
            .toList(),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 10,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            tooltipMargin: 8,
            getTooltipColor: (_) => AppColors.forest700,
            getTooltipItem: (group, _, rod, __) {
              final i = group.x;
              if (i < 0 || i >= values.length) return null;
              final raw = values[i];
              return BarTooltipItem(
                _fmtNum(raw),
                AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Cravings Heatmap section wrapper ───────────────────────────────────────
// Watches the user's show/hide preference and renders either the full mini
// heatmap card or a small "Show cravings heatmap" placeholder so the toggle
// is always recoverable without leaving the screen.

class _CravingsHeatmapSection extends ConsumerWidget {
  const _CravingsHeatmapSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible =
        ref.watch(showCravingsHeatmapProvider).valueOrNull ?? true;
    final startDateAsync = ref.watch(appStartDateProvider);

    if (!visible) {
      return _ShowHeatmapButton(onShow: () async {
        H.light();
        await ref
            .read(showCravingsHeatmapProvider.notifier)
            .setVisible(true);
      });
    }

    // While the start date is loading on cold start, render an empty box of
    // similar height so the layout doesn't pop when the card materialises.
    final startDate = startDateAsync.valueOrNull;
    if (startDate == null) {
      return const SizedBox(height: 220);
    }

    return _MiniHeatmap(
      startDate: startDate,
      onHide: () async {
        H.light();
        await ref
            .read(showCravingsHeatmapProvider.notifier)
            .setVisible(false);
      },
    );
  }
}

// ─── "Show cravings heatmap" placeholder ─────────────────────────────────────
// Shown in place of the heatmap card when the user has dismissed it. Keeps
// the toggle visible on the Progress screen so re-enabling never requires a
// trip to Settings.

class _ShowHeatmapButton extends StatelessWidget {
  const _ShowHeatmapButton({required this.onShow});
  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onShow,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.forest100, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.visibility_outlined,
                size: 18, color: AppColors.forest600),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.progressShowHeatmap,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.forest700),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.stone400),
          ],
        ),
      ),
    );
  }
}

// ─── Mini 28-day Cravings Heatmap ────────────────────────────────────────────
//
// Tracks ONLY cravings logged from the Home screen. Day 1 is the day the
// user first opened the app (appStartDate), NOT their sober date — so
// someone who is already 3 weeks sober on install still sees a meaningful
// 28-day window starting today. Each cell shows the count of cravings
// logged that day so progress is visible at a glance.

class _MiniHeatmap extends ConsumerWidget {
  const _MiniHeatmap({required this.startDate, required this.onHide});
  final DateTime startDate;
  final VoidCallback onHide;

  // Color scales with craving count. 0 = empty (neutral), more = stronger.
  static Color _cellColor(int count) => switch (count) {
        0 => AppColors.stone100,
        1 => const Color(0xFFD1E8D5),
        2 || 3 => const Color(0xFF8FC49A),
        >= 4 && <= 6 => AppColors.forest400,
        _ => AppColors.forest600,
      };

  // Text color flips to white once the cell is dark enough to need contrast.
  static Color _textColor(int count) =>
      count >= 2 ? Colors.white : AppColors.forest700;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cravings = ref.watch(cravingProvider).valueOrNull ?? [];

    final day0 = DateTime(startDate.year, startDate.month, startDate.day);
    final now = DateTime.now();
    final today0 = DateTime(now.year, now.month, now.day);
    final daysSinceStart =
        today0.difference(day0).inDays; // 0-based (0 = day 1)

    // Build craving-count map: dayIndex (0-based) → number of cravings logged.
    // Only counts cravings logged on/after day0 — anything logged before the
    // user opened the app is ignored so the heatmap starts clean at Day 1.
    final Map<int, int> counts = {};
    for (final e in cravings) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      final idx = d.difference(day0).inDays;
      if (idx >= 0 && idx < 28) counts[idx] = (counts[idx] ?? 0) + 1;
    }

    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Decorative band: line ─ circled leaf ─ line
          //   (mirrors the _HeroCardHeader used on home-screen cards so the
          //    progress card visually belongs to the same family).
          const _CravingsCardBand(),
          const SizedBox(height: 12),
          // ── Header
          Row(
            children: [
              Text(l10n.progressCravingsHeatmapTitle,
                  style: AppTextStyles.titleSmall),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  H.light();
                  context.push('/heatmap');
                },
                child: Text(l10n.progressViewFull,
                    style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.forest600,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              // Hide-card affordance: turns into a "Show cravings heatmap"
              // button via _CravingsHeatmapSection so it's always recoverable.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onHide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2, vertical: 4),
                  child: Icon(Icons.visibility_off_outlined,
                      size: 18, color: AppColors.stone400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.progressHeatmapCaption,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.stone500, fontSize: 11),
          ),
          const SizedBox(height: 14),

          // ── 4 rows × 7 cols = 28 days, each labelled with the day number
          //    and showing the craving count when one or more were logged.
          LayoutBuilder(builder: (ctx, constraints) {
            const labelW = 28.0;
            const gap = 4.0;
            final cellSize = ((constraints.maxWidth - labelW - gap * 6) / 7)
                .clamp(18.0, 40.0);

            return Column(
              children: List.generate(4, (row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: gap),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Row label
                      SizedBox(
                        width: labelW,
                        child: Text(l10n.progressHeatmapWeekLabel(row + 1),
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.stone400, fontSize: 9)),
                      ),
                      // 7 tiles
                      ...List.generate(7, (col) {
                        final idx = row * 7 + col;
                        final isFuture = idx > daysSinceStart;
                        final isToday = idx == daysSinceStart;
                        final count = counts[idx] ?? 0;
                        return Padding(
                          padding: EdgeInsets.only(right: col < 6 ? gap : 0),
                          child: Container(
                            width: cellSize,
                            height: cellSize,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isFuture
                                  ? AppColors.stone100
                                  : _cellColor(count),
                              borderRadius: BorderRadius.circular(6),
                              border: isToday
                                  ? Border.all(
                                      color: AppColors.forest400, width: 1.5)
                                  : null,
                            ),
                            child: (isFuture || count == 0)
                                ? null
                                : Text(
                                    '$count',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _textColor(count),
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            );
          }),

          const SizedBox(height: 10),

          // ── Legend (fewer cravings ← → more cravings)
          Row(
            children: [
              Text(l10n.progressHeatmapLegendFewer,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone400, fontSize: 9)),
              const SizedBox(width: 4),
              for (final c in [
                AppColors.stone100,
                const Color(0xFFD1E8D5),
                const Color(0xFF8FC49A),
                AppColors.forest400,
                AppColors.forest600,
              ])
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                      color: c, borderRadius: BorderRadius.circular(2)),
                ),
              Text(l10n.progressHeatmapLegendMore,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone400, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Decorative band — line ─ circled leaf ─ line ───────────────────────────
//
// Same visual language as _HeroCardHeader on the home-screen Serenity card.
// Sits at the top of the Cravings Heatmap card so the progress surface
// visually echoes the home cards (consistent Stillwater motif: a single line
// broken by a small circled botanical glyph).
class _CravingsCardBand extends StatelessWidget {
  const _CravingsCardBand();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 26),
              color: AppColors.forest200,
            ),
          ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.forest300, width: 1),
            ),
            child: Icon(
              Icons.spa_outlined,
              size: 14,
              color: AppColors.forest600,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 26),
              color: AppColors.forest200,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recovery Capital weekly card ──────────────────────────────────────────
//
// Sits at the top of the Insights tab. Two visual states:
//   • Filled this week → a 5-dot row showing which dimensions the user
//     ticked, plus the score (e.g. "4 of 5 this week").
//   • Not filled yet → an invitation card asking for a 30-second check.
// Either tap opens RecoveryCapitalSheet so the user can edit / fill in.
class _RecoveryCapitalCard extends ConsumerWidget {
  const _RecoveryCapitalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(thisWeekCapitalProvider);

    return GestureDetector(
      onTap: () {
        H.selection();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const RecoveryCapitalSheet(),
        );
      },
      child: SolidCard(
        borderRadius: AppRadius.xl,
        child: week == null
            ? _CapitalEmptyContent()
            : _CapitalFilledContent(week: week),
      ),
    );
  }
}

class _CapitalEmptyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.mintChip,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.auto_graph_rounded,
              color: AppColors.forest600, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.progressRecoveryCapitalTitle,
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.forest700),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.progressRecoveryCapitalEmptySubtitle,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone500, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded,
            color: AppColors.stone400, size: 22),
      ],
    );
  }
}

class _CapitalFilledContent extends StatelessWidget {
  const _CapitalFilledContent({required this.week});
  final RecoveryCapitalWeek week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dots = [
      (week.connected, Icons.people_outline_rounded),
      (week.physical, Icons.directions_walk_rounded),
      (week.slept, Icons.bedtime_outlined),
      (week.helpfulPlace, Icons.park_outlined),
      (week.meaningful, Icons.auto_awesome_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.progressRecoveryCapitalTitle,
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.forest700),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mintChip,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.forest100),
              ),
              child: Text(
                l10n.progressCapitalScore(week.score),
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.forest700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: dots.map((d) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: d.$1
                      ? AppColors.forest600.withOpacity(0.12)
                      : AppColors.stone50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: d.$1 ? AppColors.forest400 : AppColors.stone100,
                  ),
                ),
                child: Icon(
                  d.$2,
                  size: 18,
                  color: d.$1 ? AppColors.forest600 : AppColors.stone300,
                ),
              ),
            );
          }).toList(),
        ),
        if (week.note != null) ...[
          const SizedBox(height: 10),
          Text(
            '"${week.note}"',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.stone600,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          l10n.progressTapToEdit,
          style: AppTextStyles.caption
              .copyWith(color: AppColors.stone400, fontSize: 11),
        ),
      ],
    );
  }
}
