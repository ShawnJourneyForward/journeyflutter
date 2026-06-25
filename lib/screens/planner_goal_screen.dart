import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../components/back_button.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../models/planner_goal.dart';
import '../models/planner_session.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../theme/planner_palette.dart';
import '../utils/haptic_service.dart';
import '../utils/locale_format.dart';
import 'planner_screen.dart' show sessionTypeLabel;
import 'planner_session_sheet.dart';

// ─── Planner goal — create / edit ────────────────────────────────────────────
//
// One screen serves both launch flavours of a [PlannerGoal]:
//
//   EXERCISE → a free-named, DATED campaign you chase with ANY logged activity.
//              Pick how it's measured (distance / active time / sessions), a
//              target, and a start + goal date. An on-track engine (the campaign
//              card) reports the countdown, progress, pace and the per-week rate
//              needed to finish on time. No fixed race list, no preset plans.
//   WEIGHT   → a start → goal body-weight target, plus the same date window and
//              a shortcut into the body-journey screen (the weight detail view).
//
// Distances/weights are stored canonical (km / kg) and shown in the user's unit
// via locale_format; every visible string comes from the l10n getters. Saving
// builds a fresh record for the chosen type so switching type never leaves stale
// fields behind, then sets the goal active so the planner reflects it at once.

class PlannerGoalScreen extends ConsumerStatefulWidget {
  const PlannerGoalScreen({super.key, this.goalId});

  /// Id of the goal to edit. Null → create a brand-new goal. Passed through the
  /// GoRoute `extra` payload by the planner when editing an existing goal.
  final String? goalId;

  @override
  ConsumerState<PlannerGoalScreen> createState() => _PlannerGoalScreenState();
}

class _PlannerGoalScreenState extends ConsumerState<PlannerGoalScreen> {
  GoalType _type = GoalType.exercise;

  final _titleCtrl = TextEditingController();

  // Exercise.
  ExerciseMeasure _measure = ExerciseMeasure.distance;
  final _targetCtrl = TextEditingController();

  // Weight (input strings; canonical KG derived on save).
  final _startWeightCtrl = TextEditingController();
  final _goalWeightCtrl = TextEditingController();

  // Shared date window.
  DateTime? _startDate;
  DateTime? _endDate;

  bool _saving = false;
  bool _loadedExisting = false;
  PlannerGoal? _existing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedExisting || widget.goalId == null) return;
    final goals = ref.read(plannerGoalProvider).valueOrNull ?? const [];
    PlannerGoal? found;
    for (final g in goals) {
      if (g.id == widget.goalId) {
        found = g;
        break;
      }
    }
    if (found == null) return;
    _existing = found;
    _loadedExisting = true;
    _seedFrom(found);
  }

  void _seedFrom(PlannerGoal g) {
    _type = g.type;
    _titleCtrl.text = g.title;
    _startDate = g.startDate;
    _endDate = g.endDate;

    if (g.measure != null) _measure = g.measure!;
    if (g.targetValue != null) {
      _targetCtrl.text = _targetInput(g.targetValue!, g.measure ?? _measure);
    }

    final imperialWeight =
        ref.read(profileProvider).valueOrNull?.useImperialWeight ?? false;
    if (g.startWeightKg != null) {
      _startWeightCtrl.text = _weightInput(g.startWeightKg!, imperialWeight);
    }
    if (g.goalWeightKg != null) {
      _goalWeightCtrl.text = _weightInput(g.goalWeightKg!, imperialWeight);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    _startWeightCtrl.dispose();
    _goalWeightCtrl.dispose();
    super.dispose();
  }

  // ── Number helpers ─────────────────────────────────────────────────────────

  String _trimNumber(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  double? _parseInput(String raw) {
    final cleaned = raw.replaceAll(',', '.').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  bool get _imperialDistance =>
      ref.read(profileProvider).valueOrNull?.useImperial ?? false;

  String _weightInput(double kg, bool imperial) =>
      _trimNumber(imperial ? kg * 2.2046226 : kg);

  double? _weightKgFrom(String raw, bool imperial) {
    final v = _parseInput(raw);
    if (v == null) return null;
    return imperial ? v / 2.2046226 : v;
  }

  /// Canonical target value → editable display text for [measure].
  String _targetInput(double canonical, ExerciseMeasure measure) {
    switch (measure) {
      case ExerciseMeasure.distance:
        return _trimNumber(
            _imperialDistance ? canonical * 0.621371 : canonical);
      case ExerciseMeasure.time:
      case ExerciseMeasure.sessions:
        return _trimNumber(canonical);
    }
  }

  /// Editable display text → canonical target value for [measure].
  double? _targetCanonical(String raw, ExerciseMeasure measure) {
    final v = _parseInput(raw);
    if (v == null) return null;
    switch (measure) {
      case ExerciseMeasure.distance:
        return _imperialDistance ? v / 0.621371 : v;
      case ExerciseMeasure.time:
        return v;
      case ExerciseMeasure.sessions:
        return v.roundToDouble();
    }
  }

  // ── Derived labels ─────────────────────────────────────────────────────────

  String _goalTypeLabel(AppLocalizations l10n, GoalType t) => switch (t) {
        GoalType.exercise => l10n.plannerGoalTypeExercise,
        GoalType.weight => l10n.plannerGoalTypeWeight,
      };

  String _measureLabel(AppLocalizations l10n, ExerciseMeasure m) => switch (m) {
        ExerciseMeasure.distance => l10n.plannerMeasureDistance,
        ExerciseMeasure.time => l10n.plannerMeasureTime,
        ExerciseMeasure.sessions => l10n.plannerMeasureSessions,
      };

  String _targetSuffix(AppLocalizations l10n, ExerciseMeasure m) => switch (m) {
        ExerciseMeasure.distance =>
          _imperialDistance ? l10n.homeUnitMiles : l10n.homeUnitKm,
        ExerciseMeasure.time => l10n.homeUnitMin,
        ExerciseMeasure.sessions => l10n.plannerMeasureSessions.toLowerCase(),
      };

  String _defaultTitle(AppLocalizations l10n) =>
      _type == GoalType.weight ? l10n.plannerGoalTypeWeight : l10n.plannerGoalTypeExercise;

  // ── Date picking ───────────────────────────────────────────────────────────

  Future<DateTime?> _pickDate(DateTime initial) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.forest600,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
  }

  String _formatDate(DateTime d) => DateFormat.yMMMd(Intl.defaultLocale).format(d);

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_saving) return;
    H.medium();
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final imperialWeight =
        ref.read(profileProvider).valueOrNull?.useImperialWeight ?? false;

    final base = _existing;
    final title = _titleCtrl.text.trim().isEmpty
        ? _defaultTitle(l10n)
        : _titleCtrl.text.trim();

    // Build a FRESH record for the chosen type so switching type never carries
    // stale fields from the other flavour (copyWith would null-coalesce them).
    final goal = PlannerGoal(
      id: base?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: base?.createdAt ?? DateTime.now(),
      type: _type,
      title: title,
      notes: base?.notes,
      archived: base?.archived ?? false,
      startDate: _startDate,
      endDate: _endDate,
      measure: _type == GoalType.exercise ? _measure : null,
      targetValue: _type == GoalType.exercise
          ? _targetCanonical(_targetCtrl.text, _measure)
          : null,
      startWeightKg: _type == GoalType.weight
          ? _weightKgFrom(_startWeightCtrl.text, imperialWeight)
          : null,
      goalWeightKg: _type == GoalType.weight
          ? _weightKgFrom(_goalWeightCtrl.text, imperialWeight)
          : null,
    );

    if (base == null) {
      await ref.read(plannerGoalProvider.notifier).add(goal);
    } else {
      await ref.read(plannerGoalProvider.notifier).updateGoal(goal);
    }
    await ref.read(plannerSettingsProvider.notifier).setActiveGoalId(goal.id);
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final goal = _existing;
    if (goal == null) return;
    H.heavy();
    await ref.read(plannerGoalProvider.notifier).delete(goal.id);
    if (mounted) context.pop();
  }

  Future<void> _archive() async {
    final goal = _existing;
    if (goal == null) return;
    H.light();
    await ref
        .read(plannerGoalProvider.notifier)
        .archive(goal.id, archived: !goal.archived);
    if (mounted) context.pop();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = _existing != null;

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
                    child: Text(
                      isEditing ? l10n.plannerMyGoals : l10n.plannerAddGoal,
                      style: AppTextStyles.greetingSerif,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  // Campaign / weight progress (editing only).
                  if (isEditing && _existing!.type == GoalType.exercise) ...[
                    _CampaignCard(goalId: _existing!.id),
                    const SizedBox(height: 18),
                  ] else if (isEditing &&
                      _existing!.type == GoalType.weight) ...[
                    _WeightProgressCard(goalId: _existing!.id),
                    const SizedBox(height: 18),
                  ],

                  // ── Goal type ─────────────────────────────────────────────
                  _SectionLabel(l10n.plannerMyGoals),
                  const SizedBox(height: 10),
                  _ChoiceWrap(
                    options: GoalType.values,
                    isSelected: (t) => t == _type,
                    labelFor: (t) => _goalTypeLabel(l10n, t),
                    onTap: (t) {
                      H.selection();
                      setState(() => _type = t);
                    },
                  ),
                  const SizedBox(height: 22),

                  // ── Goal name (both types) ────────────────────────────────
                  _SectionLabel(l10n.plannerGoalNameLabel),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _titleCtrl,
                    style: AppTextStyles.bodyLarge,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.plannerGoalNameHint,
                      filled: true,
                      fillColor: AppColors.stone50,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Type-specific body ────────────────────────────────────
                  if (_type == GoalType.exercise) ..._exerciseBody(l10n),
                  if (_type == GoalType.weight) ..._weightBody(l10n),

                  const SizedBox(height: 12),

                  // ── Date window (both types) ──────────────────────────────
                  _DateRow(
                    label: l10n.plannerStartDateLabel,
                    value: _startDate == null ? null : _formatDate(_startDate!),
                    onTap: () async {
                      final picked = await _pickDate(_startDate ?? DateTime.now());
                      if (picked != null) setState(() => _startDate = picked);
                    },
                  ),
                  const SizedBox(height: 10),
                  _DateRow(
                    label: l10n.plannerEndDateLabel,
                    value: _endDate == null ? null : _formatDate(_endDate!),
                    onTap: () async {
                      final picked = await _pickDate(
                          _endDate ?? _startDate ?? DateTime.now());
                      if (picked != null) setState(() => _endDate = picked);
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Training sessions — plan THIS goal's own sessions ─────
                  // Edit mode only (a brand-new goal has no id yet to tag them
                  // to — save first, then reopen to plan).
                  if (isEditing) ...[
                    _GoalSessionsSection(
                      goalId: _existing!.id,
                      // Seed new sessions to the training-start date when it's
                      // still ahead, so "plan ahead" lands in the window.
                      seedDate: (_startDate != null &&
                              _startDate!.isAfter(DateTime.now()))
                          ? _startDate
                          : null,
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Save ──────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.forest600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.commonSave),
                    ),
                  ),

                  if (isEditing) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _saving ? null : _archive,
                        child: Text(_existing!.archived
                            ? l10n.plannerUnarchiveGoal
                            : l10n.plannerArchiveGoal),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _saving ? null : _delete,
                        child: Text(
                          l10n.commonDelete,
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.blush600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Exercise body ──────────────────────────────────────────────────────────

  List<Widget> _exerciseBody(AppLocalizations l10n) {
    return [
      _SectionLabel(l10n.plannerMeasureLabel),
      const SizedBox(height: 10),
      _ChoiceWrap(
        options: ExerciseMeasure.values,
        isSelected: (m) => m == _measure,
        labelFor: (m) => _measureLabel(l10n, m),
        onTap: (m) {
          H.selection();
          setState(() => _measure = m);
        },
      ),
      const SizedBox(height: 16),
      _NumberField(
        controller: _targetCtrl,
        label: l10n.plannerTargetLabel,
        suffix: _targetSuffix(l10n, _measure),
      ),
    ];
  }

  // ── Weight body ────────────────────────────────────────────────────────────

  List<Widget> _weightBody(AppLocalizations l10n) {
    final imperialWeight =
        ref.watch(profileProvider).valueOrNull?.useImperialWeight ?? false;
    final unit = imperialWeight ? l10n.plannerUnitLb : l10n.plannerUnitKg;

    return [
      _SectionLabel(l10n.plannerGoalTypeWeight),
      const SizedBox(height: 12),
      _NumberField(
        controller: _startWeightCtrl,
        label: l10n.plannerCurrentWeight,
        suffix: unit,
      ),
      const SizedBox(height: 12),
      _NumberField(
        controller: _goalWeightCtrl,
        label: l10n.plannerGoalWeight,
        suffix: unit,
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            H.light();
            context.push('/planner-body-journey');
          },
          icon: const Icon(Icons.show_chart_rounded, size: 18),
          label: Text(l10n.plannerBodyJourney),
        ),
      ),
    ];
  }
}

// ─── Campaign card — the on-track engine for an exercise goal ──────────────────

class _CampaignCard extends ConsumerWidget {
  const _CampaignCard({required this.goalId});
  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(goalCampaignStatsProvider(goalId));
    if (stats == null) return const SizedBox.shrink();
    final imperial = ref.watch(profileProvider).valueOrNull?.useImperial ?? false;

    final percent = (stats.progress * 100).round();

    // Pace → colour + icon + label.
    final (Color fg, Color bg, IconData icon, String paceLabel) =
        switch (stats.pace) {
      GoalPace.ahead => (
          AppColors.forest700,
          AppColors.mintChip,
          Icons.trending_up_rounded,
          l10n.plannerPaceAhead
        ),
      GoalPace.onTrack => (
          AppColors.forest600,
          AppColors.forest50,
          Icons.check_circle_outline_rounded,
          l10n.plannerPaceOnTrack
        ),
      GoalPace.behind => (
          AppColors.honey600,
          AppColors.honeySoft,
          Icons.schedule_rounded,
          l10n.plannerPaceBehind
        ),
      GoalPace.done => (
          AppColors.forest700,
          AppColors.mintChip,
          Icons.emoji_events_outlined,
          l10n.plannerGoalReached
        ),
      GoalPace.noTarget => (
          AppColors.stone600,
          AppColors.stone100,
          Icons.timelapse_rounded,
          l10n.plannerInProgress
        ),
    };

    final loggedStr = _fmtMeasure(l10n, stats.measure, stats.loggedValue, imperial);
    final targetStr = stats.targetValue == null
        ? null
        : _fmtMeasure(l10n, stats.measure, stats.targetValue!, imperial);

    return LuxuryCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress headline.
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$percent%',
                  style: AppTextStyles.displaySmall
                      .copyWith(color: AppColors.forestDark)),
              const SizedBox(width: 8),
              if (targetStr != null)
                Expanded(
                  child: Text(
                    l10n.plannerLoggedOfTarget(loggedStr, targetStr),
                    style: AppTextStyles.bodySmall,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: stats.progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.stone100,
              valueColor: AlwaysStoppedAnimation(AppColors.forest600),
            ),
          ),
          const SizedBox(height: 14),

          // Pace pill + countdown.
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pill),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 15, color: fg),
                    const SizedBox(width: 5),
                    Text(paceLabel,
                        style: AppTextStyles.labelMedium.copyWith(color: fg)),
                  ],
                ),
              ),
              const Spacer(),
              if (stats.daysLeft != null)
                Text(l10n.plannerDaysLeft(stats.daysLeft!),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.stone500)),
            ],
          ),

          // Adaptive per-week pace.
          if (stats.perWeekToFinish != null && stats.pace != GoalPace.done) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.flag_outlined, size: 16, color: AppColors.forest600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.plannerPerWeekHint(_fmtMeasure(
                        l10n, stats.measure, stats.perWeekToFinish!, imperial)),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.stone600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Format a canonical measure value for display (distance unit-aware; time in
  /// minutes; sessions as a bare count).
  String _fmtMeasure(
      AppLocalizations l10n, ExerciseMeasure m, double v, bool imperial) {
    switch (m) {
      case ExerciseMeasure.distance:
        return formatDistance(v, imperial: imperial, l10n: l10n);
      case ExerciseMeasure.time:
        return l10n.commonMin(v.round());
      case ExerciseMeasure.sessions:
        return '${v.round()}';
    }
  }
}

// ─── Weight progress card (editing a weight goal) ─────────────────────────────

class _WeightProgressCard extends ConsumerWidget {
  const _WeightProgressCard({required this.goalId});
  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(goalProgressForProvider(goalId)).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return LuxuryCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.plannerGoalProgress(percent),
              style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 8,
              backgroundColor: AppColors.stone100,
              valueColor: AlwaysStoppedAnimation(AppColors.forest600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.titleSmall.copyWith(color: AppColors.stone800),
      );
}

// ─── Choice chip / wrap (generic over enum option) ────────────────────────────

class _ChoiceWrap<T> extends StatelessWidget {
  const _ChoiceWrap({
    required this.options,
    required this.isSelected,
    required this.labelFor,
    required this.onTap,
  });

  final List<T> options;
  final bool Function(T option) isSelected;
  final String Function(T option) labelFor;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options
            .map(
              (option) => _ChoiceChip(
                label: labelFor(option),
                selected: isSelected(option),
                onTap: () => onTap(option),
              ),
            )
            .toList(),
      );
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.forest600.withOpacity(.12)
                : AppColors.stone50,
            borderRadius: AppRadius.pill,
            border: Border.all(
              color: selected
                  ? AppColors.forest600.withOpacity(.35)
                  : AppColors.stone100,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: selected ? AppColors.forest600 : AppColors.stone600,
            ),
          ),
        ),
      );
}

// ─── Tappable date row ────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.value, required this.onTap});
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          H.light();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.stone50,
            borderRadius: AppRadius.lg,
            border: Border.all(color: AppColors.stone100),
          ),
          child: Row(
            children: [
              Icon(Icons.event_outlined, size: 20, color: AppColors.forest600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: AppTextStyles.bodyMedium),
              ),
              Text(
                value ?? '—',
                style: AppTextStyles.titleSmall.copyWith(
                  color: value == null ? AppColors.mistGrey : AppColors.stone800,
                ),
              ),
            ],
          ),
        ),
      );
}

// ─── Number field with a unit suffix ──────────────────────────────────────────

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    this.suffix,
  });
  final TextEditingController controller;
  final String label;
  final String? suffix;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          suffixStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.mistGrey),
          filled: true,
          fillColor: AppColors.stone50,
        ),
      );
}

// ─── Goal training sessions — plan THIS goal's own sessions ──────────────────
// Lists the sessions tagged to this goal (runs, long runs, rest days, …) and
// lets the user add more, pre-linked to the goal and seeded into its window.
// They land on the shared planner calendar alongside any other goal's sessions,
// so two goals (e.g. a run plan + a swim plan) can be worked in together.

class _GoalSessionsSection extends ConsumerWidget {
  const _GoalSessionsSection({required this.goalId, required this.seedDate});
  final String goalId;
  final DateTime? seedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(plannerSessionProvider).valueOrNull ?? const [];
    final sessions = all.where((s) => s.goalId == goalId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final imperial =
        ref.watch(profileProvider).valueOrNull?.useImperial ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionLabel(l10n.plannerSessionsSectionLabel)),
            TextButton.icon(
              onPressed: () {
                H.light();
                showPlannerSessionSheet(context, ref,
                    goalId: goalId, date: seedDate);
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.plannerAddSession),
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.forest600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (sessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.stone50,
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.stone100),
            ),
            child: Text(l10n.plannerNoSessionsYet,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.mistGrey)),
          )
        else
          ...sessions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _GoalSessionRow(
                  session: s,
                  imperial: imperial,
                  onTap: () {
                    H.light();
                    showPlannerSessionSheet(context, ref, existing: s);
                  },
                ),
              )),
      ],
    );
  }
}

class _GoalSessionRow extends StatelessWidget {
  const _GoalSessionRow({
    required this.session,
    required this.imperial,
    required this.onTap,
  });
  final PlannerSession session;
  final bool imperial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = sessionTypeLabel(l10n, session.type);
    final dist = session.plannedDistanceKm == null
        ? ''
        : formatDistance(session.plannedDistanceKm!,
            imperial: imperial, l10n: l10n);
    final line = dist.isEmpty ? label : l10n.plannerSessionLine(label, dist);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.stone50,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.stone100),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sessionTypeTint(session.type),
                borderRadius: AppRadius.md,
              ),
              child: Icon(sessionTypeIcon(session.type),
                  size: 16, color: sessionTypeColor(session.type)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: session.skipped
                            ? AppColors.stone400
                            : AppColors.stone800,
                        decoration: session.skipped
                            ? TextDecoration.lineThrough
                            : null,
                      )),
                  const SizedBox(height: 2),
                  Text(DateFormat('EEE, d MMM').format(session.date),
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            // Status glyph: done / skipped / pending (tap to edit).
            session.completed
                ? Icon(Icons.check_circle_rounded,
                    size: 20, color: AppColors.forest600)
                : session.skipped
                    ? Icon(Icons.remove_circle_outline_rounded,
                        size: 20, color: AppColors.stone400)
                    : Icon(Icons.chevron_right_rounded,
                        size: 20, color: AppColors.stone400),
          ],
        ),
      ),
    );
  }
}
