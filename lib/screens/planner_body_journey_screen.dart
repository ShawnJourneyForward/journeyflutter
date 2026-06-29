import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../models/body_care_win.dart';
import '../models/planner_goal.dart';
import '../models/planner_weight_log.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../theme/share_card_kit.dart';
import '../utils/haptic_service.dart';
import '../utils/locale_format.dart';
import 'body_care_shared.dart';

// ─── Body Care ──────────────────────────────────────────────────────────────
//
// The recovery-safe weight / body module. Weight is DEMOTED to one quiet,
// optional, fully hideable signal; the hero is a growing plant fed by
// CONSISTENCY of self-care (showing up), and a deck of non-scale victories
// means there is always something kind to log even on a flat-or-up-scale day.
//
// Safety spine (see also the opt-in gate + the hide-the-number escape hatch):
//   • Weighing is opt-in — the 'feelings' mode is a complete, number-free
//     experience; only 'sometimes' mode ever surfaces a scale field/number.
//   • Every weight value passes through [formatWeight] AND the hideWeightNumbers
//     flag, so the user can frost every number app-wide with one tap.
//   • Growth ("weeks tended") is monotonic — a rest week is never a punishment.
//
// (The screen keeps its legacy class/route name to avoid churn; the user-facing
// identity is "Body Care".)

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
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;

    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColors.stone50,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.forest600)),
      );
    }

    final mode = profile.weightTrackingMode;
    final chosen =
        mode == kBodyCareModeFeelings || mode == kBodyCareModeSometimes;
    if (!chosen) {
      return _GateScaffold(onChoose: _chooseMode);
    }

    return _buildModule(context, profile);
  }

  // ── Module ────────────────────────────────────────────────────────────────
  Widget _buildModule(BuildContext context, UserProfile profile) {
    final l10n = AppLocalizations.of(context);
    final imperial = profile.useImperialWeight;
    final hideNumbers = profile.hideWeightNumbers;
    final weighing = profile.weightTrackingMode == kBodyCareModeSometimes;

    final logs = ref.watch(plannerWeightProvider).valueOrNull ?? const [];
    final wins = ref.watch(bodyCareWinProvider).valueOrNull ?? const [];
    final activities =
        ref.watch(plannerActivityProvider).valueOrNull ?? const [];
    final goal = _activeWeightGoal(ref);

    final weeksTended = bodyCareWeeksTended(
        wins: wins, weights: logs, activities: activities);
    final tendedThisWeek = bodyCareTendedThisWeek(
        wins: wins, weights: logs, activities: activities);
    final stage = bodyCarePlantStage(weeksTended);

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: back · title · (hide-the-number toggle) ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
              child: Row(
                children: [
                  const LuxuryBackButton(),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(l10n.bodyCareTitle,
                        style: AppTextStyles.greetingSerif.copyWith(
                          fontSize: 26,
                          color: AppColors.forestDark,
                          fontWeight: FontWeight.w400,
                        )),
                  ),
                  if (weighing)
                    IconButton(
                      tooltip: hideNumbers
                          ? l10n.bodyCareShowNumbers
                          : l10n.bodyCareHideNumbers,
                      icon: Icon(
                        hideNumbers
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.stone500,
                      ),
                      onPressed: () => _toggleHide(),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  // ── Plant hero (consistency, not kg) ──────────────────────
                  _PlantHero(
                    stage: stage,
                    weeksTended: weeksTended,
                    tendedThisWeek: tendedThisWeek,
                  ),
                  const SizedBox(height: 18),

                  // ── Non-scale victories deck ──────────────────────────────
                  _SectionLabel(l10n.bodyCareWinsTitle),
                  const SizedBox(height: 10),
                  _WinDeck(
                    onLog: (slug) => _logWin(slug),
                    onCustom: _openCustomWin,
                  ),
                  const SizedBox(height: 20),

                  // ── Optional weighing (only in 'sometimes' mode) ──────────
                  if (weighing) ...[
                    _WeightCard(
                      logs: logs,
                      goal: goal,
                      imperial: imperial,
                      hideNumbers: hideNumbers,
                      onLog: () => _openAddSheet(context),
                      onReveal: () => _toggleHide(),
                    ),
                    const SizedBox(height: 16),
                    if (!hideNumbers && logs.length >= 2) ...[
                      _ChartCard(
                        title: l10n.bodyCareTrendTitle,
                        child:
                            _WeightTrendChart(logs: logs, imperial: imperial),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          l10n.bodyCareTrendBandHint,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.stone400, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // ── Recent care (wins + weight reflections, newest first) ─
                  _RecentCare(wins: wins, logs: logs, imperial: imperial),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Resolve the active goal IF it is a weight goal — otherwise null.
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

  Future<void> _chooseMode(String mode) async {
    H.medium();
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(weightTrackingMode: mode));
  }

  void _toggleHide() {
    H.selection();
    ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(hideWeightNumbers: !p.hideWeightNumbers));
  }

  Future<void> _logWin(String slug, {String? note}) async {
    H.medium();
    await ref.read(bodyCareWinProvider.notifier).add(BodyCareWin(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          kind: slug,
          note: note,
        ));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.bodyCareWinLogged),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      backgroundColor: AppColors.forest700,
    ));
  }

  Future<void> _openCustomWin() async {
    H.light();
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
        title: Text(l10n.bodyCareCustomWinTitle,
            style: AppTextStyles.titleMedium),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          minLines: 1,
          maxLines: 3,
          maxLength: 120,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: l10n.bodyCareCustomWinHint),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.stone500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.commonSave,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.forest700)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (text != null && text.isNotEmpty) {
      await _logWin('custom', note: text);
    }
  }

  Future<void> _openAddSheet(BuildContext context) async {
    H.light();
    final imperial =
        ref.read(profileProvider).valueOrNull?.useImperialWeight ?? false;
    final lastKg = (ref.read(plannerWeightProvider).valueOrNull ??
            const <PlannerWeightLog>[])
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

// ─── Opt-in gate ──────────────────────────────────────────────────────────────
//
// Shown once, before the module is configured. There is no "right" answer and
// no number-shaming default — the number-free path ('feelings') is a complete,
// rewarding experience.

class _GateScaffold extends StatelessWidget {
  const _GateScaffold({required this.onChoose});
  final void Function(String mode) onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: LuxuryBackButton(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        color: AppColors.forest50, shape: BoxShape.circle),
                    child: Icon(Icons.spa_outlined,
                        size: 32, color: AppColors.forest600),
                  ),
                  const SizedBox(height: 18),
                  Text(l10n.bodyCareGateTitle,
                      style: AppTextStyles.greetingSerif.copyWith(
                          fontSize: 26, color: AppColors.forestDark)),
                  const SizedBox(height: 8),
                  Text(l10n.bodyCareGateBody,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.stone500, height: 1.5)),
                  const SizedBox(height: 24),
                  _GateOption(
                    icon: Icons.favorite_outline_rounded,
                    title: l10n.bodyCareModeFeelings,
                    body: l10n.bodyCareModeFeelingsDesc,
                    onTap: () => onChoose(kBodyCareModeFeelings),
                  ),
                  const SizedBox(height: 14),
                  _GateOption(
                    icon: Icons.monitor_weight_outlined,
                    title: l10n.bodyCareModeSometimes,
                    body: l10n.bodyCareModeSometimesDesc,
                    onTap: () => onChoose(kBodyCareModeSometimes),
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

class _GateOption extends StatelessWidget {
  const _GateOption({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.xxl,
      onTap: onTap,
      child: SolidCard(
        borderRadius: AppRadius.xxl,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.forest50, shape: BoxShape.circle),
              child: Icon(icon, size: 22, color: AppColors.forest600),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.stone800)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone500, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: AppColors.stone300),
          ],
        ),
      ),
    );
  }
}

// ─── Plant hero ────────────────────────────────────────────────────────────────

class _PlantHero extends StatelessWidget {
  const _PlantHero({
    required this.stage,
    required this.weeksTended,
    required this.tendedThisWeek,
  });
  final double stage;
  final int weeksTended;
  final bool tendedThisWeek;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headline = weeksTended <= 0
        ? l10n.bodyCareHeroNew
        : l10n.bodyCareWeeksTended(weeksTended);
    final sub = tendedThisWeek
        ? l10n.bodyCareTendedThisWeek
        : l10n.bodyCareTendThisWeek;

    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            height: 96,
            child: CustomPaint(
              painter: GrowingPlant(color: AppColors.forest600, stage: stage),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.forestDark)),
                const SizedBox(height: 6),
                Text(sub,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.stone500, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Non-scale-victory deck ─────────────────────────────────────────────────────

class _WinDeck extends StatelessWidget {
  const _WinDeck({required this.onLog, required this.onCustom});
  final void Function(String slug) onLog;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final k in kBodyCareWinKinds)
            _WinChip(
              icon: k.icon,
              label: bodyCareWinLabel(l10n, k.slug),
              onTap: () => onLog(k.slug),
            ),
          // "Your own win" — opens the free-text dialog.
          _WinChip(
            icon: Icons.add_rounded,
            label: l10n.bodyCareCustomWinTitle,
            onTap: onCustom,
            accent: true,
          ),
        ],
      ),
    );
  }
}

class _WinChip extends StatelessWidget {
  const _WinChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: AppRadius.lg,
        onTap: onTap,
        child: Container(
          width: 104,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent ? AppColors.honeySoft : AppColors.card,
            borderRadius: AppRadius.lg,
            border: Border.all(
                color: accent ? AppColors.honey200 : AppColors.softBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon,
                  size: 22,
                  color: accent ? AppColors.honey600 : AppColors.forest600),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.stone700, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Weight card (only shown in 'sometimes' mode) ───────────────────────────────
//
// A quiet, secondary card — never the hero. Honours hideWeightNumbers: when
// hidden it shows nothing but a calm "the number is resting" line.

class _WeightCard extends StatelessWidget {
  const _WeightCard({
    required this.logs,
    required this.goal,
    required this.imperial,
    required this.hideNumbers,
    required this.onLog,
    required this.onReveal,
  });
  final List<PlannerWeightLog> logs;
  final PlannerGoal? goal;
  final bool imperial;
  final bool hideNumbers;
  final VoidCallback onLog;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (hideNumbers) {
      return SolidCard(
        borderRadius: AppRadius.xxl,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.visibility_off_outlined,
                size: 20, color: AppColors.stone400),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.bodyCareNumbersHidden,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.stone500, height: 1.4)),
            ),
            TextButton(
              onPressed: onReveal,
              child: Text(l10n.bodyCareShowNumbers,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.forest600)),
            ),
          ],
        ),
      );
    }

    final latest = logs.isNotEmpty ? logs.last : null;
    final goalKg = goal?.goalWeightKg;
    final startKg = goal?.startWeightKg ?? (logs.isNotEmpty ? logs.first.weightKg : null);
    double? progress;
    if (latest != null && goalKg != null && startKg != null && startKg != goalKg) {
      progress =
          ((latest.weightKg - startKg) / (goalKg - startKg)).clamp(0.0, 1.0);
    }

    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  latest == null
                      ? l10n.bodyCareNoWeighIn
                      : l10n.bodyCareWeightCaption(formatWeight(
                          latest.weightKg,
                          imperial: imperial,
                          l10n: l10n)),
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.stone700),
                ),
              ),
              TextButton.icon(
                onPressed: onLog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.bodyCareLogWeighIn),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.forest700),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: AppRadius.pill,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.stone100,
                valueColor: AlwaysStoppedAnimation(AppColors.forest600),
              ),
            ),
            const SizedBox(height: 6),
            Text(l10n.bodyCareTowardGentleGoal,
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.stone400)),
          ],
        ],
      ),
    );
  }
}

// ─── Recent care (wins + weight reflections, newest first) ──────────────────────

class _RecentCare extends StatelessWidget {
  const _RecentCare({
    required this.wins,
    required this.logs,
    required this.imperial,
  });
  final List<BodyCareWin> wins;
  final List<PlannerWeightLog> logs;
  final bool imperial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Merge wins with weight entries that carry a milestone/reflection (a bare
    // weight number isn't a "story" entry), newest first.
    final items = <_CareItem>[
      for (final w in wins)
        _CareItem(
          date: w.date,
          icon: bodyCareWinIcon(w.kind),
          text: bodyCareWinDisplay(l10n, w),
          accent: w.kind == 'showedup',
        ),
      for (final lg in logs)
        if ((lg.milestoneLabel?.trim().isNotEmpty ?? false) ||
            (lg.note?.trim().isNotEmpty ?? false))
          _CareItem(
            date: lg.date,
            icon: (lg.milestoneLabel?.trim().isNotEmpty ?? false)
                ? Icons.emoji_events_outlined
                : Icons.edit_note_outlined,
            text: (lg.milestoneLabel?.trim().isNotEmpty ?? false)
                ? lg.milestoneLabel!.trim()
                : lg.note!.trim(),
            accent: lg.milestoneLabel?.trim().isNotEmpty ?? false,
          ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (items.isEmpty) {
      return SolidCard(
        borderRadius: AppRadius.xxl,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_outlined,
                size: 20, color: AppColors.stone300),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.bodyCareNoWinsYet,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.stone500)),
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
            child: Text(l10n.bodyCareRecentTitle,
                style: AppTextStyles.titleSmall),
          ),
          const SizedBox(height: 10),
          ...items.take(20).map((it) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: it.accent
                            ? AppColors.honeySoft
                            : AppColors.forest50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(it.icon,
                          size: 17,
                          color: it.accent
                              ? AppColors.honey600
                              : AppColors.forest600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.text,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.stone700)),
                          const SizedBox(height: 2),
                          Text(DateFormat.MMMd().format(it.date),
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.stone400)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _CareItem {
  _CareItem({
    required this.date,
    required this.icon,
    required this.text,
    required this.accent,
  });
  final DateTime date;
  final IconData icon;
  final String text;
  final bool accent;
}

// ─── Small shared label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
        header: true,
        child: Text(text, style: AppTextStyles.titleSmall),
      );
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
    final pad = (maxV - minV) == 0 ? 1.0 : (maxV - minV) * 0.15;

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

// ─── Add weight entry sheet ────────────────────────────────────────────────────

class _AddWeightSheet extends ConsumerStatefulWidget {
  const _AddWeightSheet({required this.imperial, this.seedKg});

  final bool imperial;
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
    final raw = _weight.text.trim().replaceAll(',', '.');
    final entered = double.tryParse(raw);
    if (entered == null || entered <= 0) {
      setState(() => _error = l10n.bodyCareEnterWeight);
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
              Text(l10n.bodyCareLogWeighIn, style: AppTextStyles.titleLarge),
              const SizedBox(height: 18),

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

              _FieldLabel(l10n.plannerWeightMilestone),
              const SizedBox(height: 6),
              TextField(
                controller: _milestone,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),

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
