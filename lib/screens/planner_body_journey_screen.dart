import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../models/planner_goal.dart';
import '../models/planner_weight_log.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import '../utils/locale_format.dart';

// ─── Your Body Journey ─────────────────────────────────────────────────────────
//
// The weight-tracking screen of the planner. Reads the body-weight timeline
// (plannerWeightProvider, oldest→newest) and the active WEIGHT goal (if any) to
// render:
//   • a hero card — latest weight, signed change since the first entry (handles
//     loss AND gain), the goal weight, and a progress bar toward it;
//   • a trend chart — weightKg over time (mirrors insights_screen's
//     _SimpleLineChart: curved, ~2.5 forest line, ~8% fill);
//   • a milestone / reflection list built from each log's milestoneLabel + note;
//   • an "add weight entry" sheet that parses the user's input in their display
//     unit (lb when profile.useImperialWeight) back to canonical KG before save.
//
// Weights are stored canonical KG; every value shown passes through
// [formatWeight] so it converts to lb only at display time and follows the
// active locale's number formatting.

class PlannerBodyJourneyScreen extends ConsumerStatefulWidget {
  const PlannerBodyJourneyScreen({super.key});

  @override
  ConsumerState<PlannerBodyJourneyScreen> createState() =>
      _PlannerBodyJourneyScreenState();
}

class _PlannerBodyJourneyScreenState
    extends ConsumerState<PlannerBodyJourneyScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final imperial =
        ref.watch(profileProvider).valueOrNull?.useImperialWeight ?? false;

    // Logs are stored oldest-first (the notifier keeps them date-sorted).
    final logs = ref.watch(plannerWeightProvider).valueOrNull ?? const [];

    // The active weight goal (if the active goal happens to be a weight goal)
    // gives us the goal weight + start weight for the progress bar.
    final goal = _activeWeightGoal(ref);

    final hasLogs = logs.isNotEmpty;
    final latest = hasLogs ? logs.last : null;
    final first = hasLogs ? logs.first : null;

    return Scaffold(
      backgroundColor: AppColors.stone50,
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.forest700,
          foregroundColor: AppColors.onForest,
          elevation: 2,
          onPressed: () => _openAddSheet(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.plannerAddWeightEntry),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          children: [
            // ── Header ──────────────────────────────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: LuxuryBackButton(),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                l10n.plannerBodyJourney,
                style: AppTextStyles.greetingSerif.copyWith(
                  fontSize: 30,
                  color: AppColors.forestDark,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (!hasLogs)
              _EmptyState(onAdd: () => _openAddSheet(context))
            else ...[
              // ── Hero card ─────────────────────────────────────────────────
              _HeroCard(
                latest: latest!,
                first: first!,
                goal: goal,
                imperial: imperial,
              ),
              const SizedBox(height: 16),

              // ── Trend chart ───────────────────────────────────────────────
              _ChartCard(
                title: l10n.plannerWeightTrend,
                child: logs.length < 2
                    ? _EmptyChart(label: l10n.plannerWeightTrend)
                    : _WeightTrendChart(logs: logs, imperial: imperial),
              ),
              const SizedBox(height: 16),

              // ── Milestones / reflections ──────────────────────────────────
              _MilestoneList(logs: logs, imperial: imperial),
            ],
          ],
        ),
      ),
    );
  }

  /// Resolve the active goal IF it is a weight goal — otherwise null. The hero
  /// card's "goal weight" + progress bar only make sense for a weight goal.
  PlannerGoal? _activeWeightGoal(WidgetRef ref) {
    final id = ref.watch(activeGoalIdProvider);
    if (id == null) return null;
    final goals = ref.watch(plannerGoalProvider).valueOrNull ?? const [];
    for (final g in goals) {
      if (g.id == id && g.type == GoalType.weight && g.goalWeightKg != null) {
        return g;
      }
    }
    return null;
  }

  Future<void> _openAddSheet(BuildContext context) async {
    H.light();
    final imperial =
        ref.read(profileProvider).valueOrNull?.useImperialWeight ?? false;
    final lastKg =
        (ref.read(plannerWeightProvider).valueOrNull ?? const <PlannerWeightLog>[])
            .lastOrNull
            ?.weightKg;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddWeightSheet(imperial: imperial, seedKg: lastKg),
    );
  }
}

// ─── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.latest,
    required this.first,
    required this.goal,
    required this.imperial,
  });

  final PlannerWeightLog latest;
  final PlannerWeightLog first;
  final PlannerGoal? goal;
  final bool imperial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Signed change since the very first entry. Positive = gain, negative =
    // loss; we keep the sign so a user training to GAIN weight reads correctly.
    final deltaKg = latest.weightKg - first.weightKg;
    final gained = deltaKg > 0;
    // Use the goal's start weight when available so the bar reflects the plan's
    // own baseline; otherwise anchor to the first logged entry.
    final startKg = goal?.startWeightKg ?? first.weightKg;
    final goalKg = goal?.goalWeightKg;

    double? progress;
    if (goalKg != null && startKg != goalKg) {
      progress =
          ((latest.weightKg - startKg) / (goalKg - startKg)).clamp(0.0, 1.0);
    }

    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.plannerCurrentWeight,
            style: AppTextStyles.caption.copyWith(color: AppColors.stone500),
          ),
          const SizedBox(height: 6),
          Text(
            formatWeight(latest.weightKg, imperial: imperial, l10n: l10n),
            style: AppTextStyles.moneyNumber.copyWith(fontSize: 44),
          ),
          const SizedBox(height: 10),

          // ── Signed change since start ───────────────────────────────────
          Row(
            children: [
              Icon(
                gained
                    ? Icons.north_east_rounded
                    : deltaKg < 0
                        ? Icons.south_east_rounded
                        : Icons.remove_rounded,
                size: 16,
                color: gained ? AppColors.honey600 : AppColors.forest600,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${l10n.plannerChangeSinceStart} · '
                  '${gained ? '+' : ''}'
                  '${formatWeight(deltaKg, imperial: imperial, l10n: l10n)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: gained ? AppColors.honey600 : AppColors.forest600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // ── Goal weight + progress bar (weight goal only) ──────────────
          if (goalKg != null) ...[
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.plannerGoalWeight,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.stone500),
                ),
                Text(
                  formatWeight(goalKg, imperial: imperial, l10n: l10n),
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.forest700),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: AppRadius.pill,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.stone100,
                  valueColor:
                      AlwaysStoppedAnimation(AppColors.forest600),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.plannerGoalProgress((progress * 100).round()),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone500),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ─── Trend chart ───────────────────────────────────────────────────────────────
//
// Mirrors insights_screen's _SimpleLineChart: curved forest line at width 2.5
// over a soft 8 % forest fill, hairline horizontal grid, x-axis labelled with
// the first / middle / last dates so the timeline reads without crowding.

class _WeightTrendChart extends StatelessWidget {
  const _WeightTrendChart({required this.logs, required this.imperial});

  final List<PlannerWeightLog> logs;
  final bool imperial;

  @override
  Widget build(BuildContext context) {
    final values =
        logs.map((l) => imperial ? l.weightKg * 2.2046226 : l.weightKg).toList();
    final spots = values
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    // A little headroom so the line never kisses the card edges; guard the
    // flat-line case (all entries equal) so min != max.
    final pad = (maxV - minV) == 0 ? 1.0 : (maxV - minV) * 0.15;

    // Label only the first, middle and last points so dense histories stay
    // readable.
    final lastIndex = logs.length - 1;
    final midIndex = lastIndex ~/ 2;
    final df = DateFormat.MMMd();

    return LineChart(
      LineChartData(
        minY: minV - pad,
        maxY: maxV + pad,
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
                if (i != 0 && i != midIndex && i != lastIndex) {
                  return const SizedBox.shrink();
                }
                if (i < 0 || i >= logs.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(df.format(logs[i].date),
                      style: AppTextStyles.caption),
                );
              },
              reservedSize: 22,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.forest600,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.forest600.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Milestone / reflection list ───────────────────────────────────────────────

class _MilestoneList extends StatelessWidget {
  const _MilestoneList({required this.logs, required this.imperial});

  final List<PlannerWeightLog> logs;
  final bool imperial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Newest first; keep only entries that carry a milestone tag or a written
    // reflection — a bare weight number doesn't belong in the story list.
    final entries = logs.reversed
        .where((l) =>
            (l.milestoneLabel != null && l.milestoneLabel!.trim().isNotEmpty) ||
            (l.note != null && l.note!.trim().isNotEmpty))
        .toList();

    if (entries.isEmpty) {
      return SolidCard(
        borderRadius: AppRadius.xxl,
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_outlined,
                color: AppColors.stone300, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.plannerWeightReflection,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone500),
              ),
            ),
          ],
        ),
      );
    }

    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.plannerWeightMilestone,
                style: AppTextStyles.titleSmall),
          ),
          const SizedBox(height: 6),
          ...entries.map((e) => _MilestoneRow(log: e, imperial: imperial)),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.log, required this.imperial});

  final PlannerWeightLog log;
  final bool imperial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMilestone =
        log.milestoneLabel != null && log.milestoneLabel!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isMilestone ? AppColors.honeySoft : AppColors.forest50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMilestone
                  ? Icons.emoji_events_outlined
                  : Icons.edit_note_outlined,
              size: 18,
              color: isMilestone ? AppColors.honey600 : AppColors.forest600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMilestone)
                  Text(
                    log.milestoneLabel!.trim(),
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.honey600),
                  ),
                if (log.note != null && log.note!.trim().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: isMilestone ? 2 : 0),
                    child: Text(
                      log.note!.trim(),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.stone700),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.plannerWeightSince(DateFormat.yMMMd().format(log.date))}'
                  ' · '
                  '${formatWeight(log.weightKg, imperial: imperial, l10n: l10n)}',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.stone400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: AppColors.forest50, shape: BoxShape.circle),
            child: Icon(Icons.monitor_weight_outlined,
                size: 32, color: AppColors.forest600),
          ),
          const SizedBox(height: 16),
          Text(l10n.plannerWeightReflection,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.stone500, height: 1.4)),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l10n.plannerAddWeightEntry),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.forest700,
              foregroundColor: AppColors.onForest,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chart card + empty chart (mirrors insights_screen) ────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SolidCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: AppTextStyles.titleSmall),
            ),
            const SizedBox(height: 14),
            SizedBox(height: 160, child: child),
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
            Icon(Icons.show_chart_rounded,
                color: AppColors.stone200, size: 32),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      );
}

// ─── Add weight entry sheet ────────────────────────────────────────────────────

class _AddWeightSheet extends ConsumerStatefulWidget {
  const _AddWeightSheet({required this.imperial, this.seedKg});

  /// Whether the user enters / sees weight in pounds. Drives the field unit
  /// label and the lb→kg conversion on save.
  final bool imperial;

  /// The most recent logged weight (canonical KG), used to pre-fill the field
  /// so a small day-to-day change is a quick edit rather than a fresh type.
  final double? seedKg;

  @override
  ConsumerState<_AddWeightSheet> createState() => _AddWeightSheetState();
}

class _AddWeightSheetState extends ConsumerState<_AddWeightSheet> {
  late final TextEditingController _weight;
  final _note = TextEditingController();
  final _milestone = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final seed = widget.seedKg;
    final display =
        seed == null ? '' : (widget.imperial ? seed * 2.2046226 : seed);
    _weight = TextEditingController(
      text: display == '' ? '' : (display as double).toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _weight.dispose();
    _note.dispose();
    _milestone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    // Parse in the user's display unit, then convert back to canonical KG. We
    // deliberately use double.parse on a plain '.'-decimal field (the keyboard
    // is numeric) rather than a localized parser, matching the app's
    // editable-input convention (see locale_format.dart's formatMoney note).
    final raw = _weight.text.trim().replaceAll(',', '.');
    final entered = double.tryParse(raw);
    if (entered == null || entered <= 0) {
      setState(() => _error = l10n.plannerCurrentWeight);
      return;
    }
    final kg = widget.imperial ? entered / 2.2046226 : entered;

    setState(() {
      _saving = true;
      _error = null;
    });
    H.medium();
    final note = _note.text.trim();
    final milestone = _milestone.text.trim();
    await ref.read(plannerWeightProvider.notifier).add(PlannerWeightLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          weightKg: kg,
          note: note.isEmpty ? null : note,
          milestoneLabel: milestone.isEmpty ? null : milestone,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unit = widget.imperial ? l10n.plannerUnitLb : l10n.plannerUnitKg;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.stone200,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              Text(l10n.plannerAddWeightEntry,
                  style: AppTextStyles.titleLarge),
              const SizedBox(height: 18),

              // ── Weight field (in the user's display unit) ─────────────────
              _FieldLabel(l10n.plannerCurrentWeight),
              const SizedBox(height: 6),
              TextField(
                controller: _weight,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                style: AppTextStyles.titleLarge,
                decoration: InputDecoration(
                  suffixText: unit,
                  suffixStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.stone500),
                  errorText: _error,
                  hintText: '0.0',
                ),
              ),
              const SizedBox(height: 16),

              // ── Optional milestone ────────────────────────────────────────
              _FieldLabel(l10n.plannerWeightMilestone),
              const SizedBox(height: 6),
              TextField(
                controller: _milestone,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),

              // ── Optional reflection ──────────────────────────────────────
              _FieldLabel(l10n.plannerWeightReflection),
              const SizedBox(height: 6),
              TextField(
                controller: _note,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () {
                              H.light();
                              Navigator.of(context).maybePop();
                            },
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.forest700,
                        foregroundColor: AppColors.onForest,
                        minimumSize: const Size.fromHeight(50),
                        shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.lg),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(l10n.commonSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.stone500,
          letterSpacing: 0.4,
        ),
      );
}
