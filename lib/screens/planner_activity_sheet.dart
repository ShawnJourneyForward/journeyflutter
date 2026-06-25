// Manual activity log (PlannerActivity, source = manual). You pick the
// DISCIPLINE (run / ride / swim / walk / hike / gym / yoga / cardio / other),
// and the sheet shows the metrics that fit "how it went" for that discipline:
//   • distance + elevation for run / ride / walk / hike,
//   • distance + pool length for swim,
//   • a full exercise list (exercise → sets × reps × weight) for gym,
//   • duration + effort + heart rate + notes for everything.
//
// Distances are stored canonical KM, weights canonical KG, elevation/pool length
// canonical METRES — the unit-aware suffixes reflect the user's metric/imperial
// settings and convert on save. All copy comes from the l10n getters.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../models/planner_activity.dart';
import '../models/planner_session.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../theme/planner_palette.dart';
import '../utils/haptic_service.dart';

const double _kgPerLb = 2.2046226;
const double _ftPerM = 3.28084;
const double _miPerKm = 0.621371;

/// Best-effort legacy [SessionType] for a [discipline], stored alongside the
/// discipline so any older code path reading `activity.type` still behaves. The
/// discipline is the source of truth; this mapping is intentionally lossy.
SessionType sessionTypeForDiscipline(ActivityDiscipline d) {
  switch (d) {
    case ActivityDiscipline.run:
      return SessionType.easyRun;
    case ActivityDiscipline.swim:
      return SessionType.swim;
    case ActivityDiscipline.ride:
    case ActivityDiscipline.walk:
    case ActivityDiscipline.hike:
    case ActivityDiscipline.gym:
    case ActivityDiscipline.yoga:
    case ActivityDiscipline.cardio:
      return SessionType.crossTrain;
    case ActivityDiscipline.other:
      return SessionType.other;
  }
}

/// Holds the four text controllers for one gym exercise row.
class _StrengthCtrls {
  final exercise = TextEditingController();
  final sets = TextEditingController();
  final reps = TextEditingController();
  final weight = TextEditingController();

  void dispose() {
    exercise.dispose();
    sets.dispose();
    reps.dispose();
    weight.dispose();
  }
}

/// Open the manual activity log sheet. [goalId] links the logged activity to a
/// goal when provided.
Future<void> showPlannerActivitySheet(
  BuildContext context,
  WidgetRef ref, {
  String? goalId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlannerActivitySheet(goalId: goalId),
  );
}

class _PlannerActivitySheet extends ConsumerStatefulWidget {
  const _PlannerActivitySheet({this.goalId});
  final String? goalId;

  @override
  ConsumerState<_PlannerActivitySheet> createState() =>
      _PlannerActivitySheetState();
}

class _PlannerActivitySheetState extends ConsumerState<_PlannerActivitySheet> {
  ActivityDiscipline _discipline = ActivityDiscipline.run;
  DateTime _date = DateTime.now();
  final _minutesCtrl = TextEditingController(text: '30');
  final _distanceCtrl = TextEditingController();
  final _elevationCtrl = TextEditingController();
  final _poolCtrl = TextEditingController();
  final _hrCtrl = TextEditingController();
  final _rpeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<_StrengthCtrls> _strength = [];
  bool _saving = false;

  bool get _needsDistance => distanceDisciplines.contains(_discipline);
  bool get _needsElevation => elevationDisciplines.contains(_discipline);
  bool get _isSwim => _discipline == ActivityDiscipline.swim;
  bool get _isGym => _discipline == ActivityDiscipline.gym;

  bool get _imperial =>
      ref.read(profileProvider).valueOrNull?.useImperial ?? false;
  bool get _imperialWeight =>
      ref.read(profileProvider).valueOrNull?.useImperialWeight ?? false;

  @override
  void dispose() {
    _minutesCtrl.dispose();
    _distanceCtrl.dispose();
    _elevationCtrl.dispose();
    _poolCtrl.dispose();
    _hrCtrl.dispose();
    _rpeCtrl.dispose();
    _notesCtrl.dispose();
    for (final c in _strength) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parse(TextEditingController c) {
    final raw = c.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  /// Distance field (display unit) → canonical km.
  double? _distanceKm() {
    final v = _parse(_distanceCtrl);
    if (v == null) return null;
    return _imperial ? v / _miPerKm : v;
  }

  /// Elevation field (display unit) → canonical metres.
  double? _elevationM() {
    final v = _parse(_elevationCtrl);
    if (v == null) return null;
    return _imperial ? v / _ftPerM : v;
  }

  /// Effort field → an int clamped to 1–10, or null when blank/invalid.
  int? _rpe() {
    final raw = _rpeCtrl.text.trim();
    if (raw.isEmpty) return null;
    final v = int.tryParse(raw);
    if (v == null) return null;
    return v.clamp(1, 10);
  }

  List<StrengthSet> _strengthSets() {
    final out = <StrengthSet>[];
    for (final c in _strength) {
      final name = c.exercise.text.trim();
      if (name.isEmpty) continue;
      final w = _parse(c.weight);
      out.add(StrengthSet(
        exercise: name,
        sets: int.tryParse(c.sets.text.trim()) ?? 0,
        reps: int.tryParse(c.reps.text.trim()) ?? 0,
        weightKg: w == null ? null : (_imperialWeight ? w / _kgPerLb : w),
      ));
    }
    return out;
  }

  void _addStrengthRow() {
    setState(() => _strength.add(_StrengthCtrls()));
  }

  void _removeStrengthRow(int i) {
    setState(() => _strength.removeAt(i).dispose());
  }

  Future<void> _pickDate() async {
    H.selection();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && mounted) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    H.medium();
    try {
      final minutes = int.tryParse(_minutesCtrl.text.trim()) ?? 0;
      final hrRaw = _hrCtrl.text.trim();
      final notesRaw = _notesCtrl.text.trim();
      final activity = PlannerActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _date,
        type: sessionTypeForDiscipline(_discipline),
        discipline: _discipline,
        minutes: minutes,
        distanceKm: _needsDistance ? _distanceKm() : null,
        avgHeartRate: hrRaw.isEmpty ? null : int.tryParse(hrRaw),
        source: ActivitySource.manual,
        goalId: widget.goalId,
        notes: notesRaw.isEmpty ? null : notesRaw,
        rpe: _rpe(),
        elevationGainM: _needsElevation ? _elevationM() : null,
        poolLengthM: _isSwim ? _parse(_poolCtrl) : null,
        strengthSets: _isGym ? _strengthSets() : const [],
      );
      await ref.read(plannerActivityProvider.notifier).add(activity);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final imperial = _imperial;
    final distanceUnit = imperial ? l10n.homeUnitMiles : l10n.homeUnitKm;
    final elevationUnit =
        imperial ? l10n.plannerUnitFeet : l10n.plannerUnitMeters;
    final weightUnit = _imperialWeight ? l10n.plannerUnitLb : l10n.plannerUnitKg;
    final dateLabel = DateFormat('EEEE, d MMMM').format(_date);

    return _PlannerSheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlannerSheetHeader(
            icon: disciplineIcon(_discipline),
            title: l10n.plannerSourceManual,
            subtitle: disciplineLabel(l10n, _discipline),
          ),
          const SizedBox(height: 22),

          // ── Discipline ───────────────────────────────────────────────────
          _PlannerSectionLabel(l10n.plannerActivityTypeLabel),
          const SizedBox(height: 10),
          _DisciplineWrap(
            selected: _discipline,
            labelFor: (d) => disciplineLabel(l10n, d),
            onTap: (d) {
              H.selection();
              setState(() {
                _discipline = d;
                // Seed an empty exercise row the first time gym is chosen.
                if (d == ActivityDiscipline.gym && _strength.isEmpty) {
                  _strength.add(_StrengthCtrls());
                }
              });
            },
          ),
          const SizedBox(height: 18),

          // ── Date ─────────────────────────────────────────────────────────
          _PlannerSectionLabel(l10n.plannerActivityDateLabel),
          const SizedBox(height: 10),
          _DateField(label: dateLabel, onTap: _pickDate),
          const SizedBox(height: 18),

          // ── Distance + minutes (or just minutes) ─────────────────────────
          if (_needsDistance) ...[
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: l10n.homeActivityDistanceLabel(distanceUnit),
                    controller: _distanceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    hintText: '0.0',
                    suffix: distanceUnit,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: l10n.homeActivityDurationMin,
                    controller: _minutesCtrl,
                    keyboardType: TextInputType.number,
                    suffix: l10n.homeUnitMin,
                  ),
                ),
              ],
            ),
          ] else ...[
            _LabeledField(
              label: l10n.homeActivityDurationMin,
              controller: _minutesCtrl,
              keyboardType: TextInputType.number,
              suffix: l10n.homeUnitMin,
            ),
          ],
          const SizedBox(height: 18),

          // ── Elevation (run / ride / walk / hike) ─────────────────────────
          if (_needsElevation) ...[
            _LabeledField(
              label: l10n.plannerMetricElevation,
              controller: _elevationCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: '0',
              suffix: elevationUnit,
            ),
            const SizedBox(height: 18),
          ],

          // ── Pool length (swim) ───────────────────────────────────────────
          if (_isSwim) ...[
            _LabeledField(
              label: l10n.plannerMetricPoolLength,
              controller: _poolCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: '25',
              suffix: l10n.plannerUnitMeters,
            ),
            const SizedBox(height: 18),
          ],

          // ── Heart rate + effort ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: l10n.plannerAvgHeartRate,
                  controller: _hrCtrl,
                  keyboardType: TextInputType.number,
                  hintText: '0',
                  suffix: 'bpm',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledField(
                  label: l10n.plannerMetricEffort,
                  controller: _rpeCtrl,
                  keyboardType: TextInputType.number,
                  hintText: '0',
                  suffix: '/10',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Strength exercises (gym) ─────────────────────────────────────
          if (_isGym) ...[
            _PlannerSectionLabel(l10n.plannerStrengthExercises),
            const SizedBox(height: 10),
            for (var i = 0; i < _strength.length; i++) ...[
              _StrengthRow(
                ctrls: _strength[i],
                weightUnit: weightUnit,
                onRemove: () => _removeStrengthRow(i),
              ),
              const SizedBox(height: 10),
            ],
            _AddExerciseButton(
              label: l10n.plannerStrengthAddExercise,
              onTap: () {
                H.selection();
                _addStrengthRow();
              },
            ),
            const SizedBox(height: 18),
          ],

          // ── Notes ────────────────────────────────────────────────────────
          _PlannerNotesField(
            controller: _notesCtrl,
            hintText: l10n.homeActivityNotesHint,
          ),
          const SizedBox(height: 18),

          // ── Save ─────────────────────────────────────────────────────────
          _PlannerSaveButton(
            saving: _saving,
            onPressed: _save,
            label: l10n.homeSaveActivity,
          ),
        ],
      ),
    );
  }
}

// ── Strength exercise row ─────────────────────────────────────────────────────

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({
    required this.ctrls,
    required this.weightUnit,
    required this.onRemove,
  });

  final _StrengthCtrls ctrls;
  final String weightUnit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.stone50,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.stone100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrls.exercise,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.stone800),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: l10n.plannerStrengthExerciseHint,
                    hintStyle: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.stone300),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  H.light();
                  onRemove();
                },
                child: Icon(Icons.close_rounded,
                    size: 18, color: AppColors.mistGrey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: l10n.plannerStrengthSets,
                  controller: ctrls.sets,
                  keyboardType: TextInputType.number,
                  hintText: '0',
                  fillColor: AppColors.card,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LabeledField(
                  label: l10n.plannerStrengthReps,
                  controller: ctrls.reps,
                  keyboardType: TextInputType.number,
                  hintText: '0',
                  fillColor: AppColors.card,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LabeledField(
                  label: l10n.plannerStrengthWeight,
                  controller: ctrls.weight,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hintText: '0',
                  suffix: weightUnit,
                  fillColor: AppColors.card,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddExerciseButton extends StatelessWidget {
  const _AddExerciseButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.forest600,
            side: BorderSide(color: AppColors.forest600.withOpacity(.35)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
}

// ── Shared planner-sheet building blocks ─────────────────────────────────────
// Mirrors home_screen's _sheetShell / _SheetHeader / _SheetSectionLabel /
// _NotesField / _saveButton so this sheet is visually identical to the rest of
// the app while staying self-contained.

class _PlannerSheetShell extends StatelessWidget {
  const _PlannerSheetShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .92,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xxl,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.stone200,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _PlannerSheetHeader extends StatelessWidget {
  const _PlannerSheetHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconChip(icon: icon, size: 40),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppTextStyles.titleLarge)),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.mistGrey,
              ),
            ],
          ),
          if (subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ],
      );
}

class _PlannerSectionLabel extends StatelessWidget {
  const _PlannerSectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.titleSmall.copyWith(color: AppColors.stone800),
      );
}

/// Choice-chip wrap over every [ActivityDiscipline] — styled like home_screen's
/// _ChoiceChip with a leading discipline glyph.
class _DisciplineWrap extends StatelessWidget {
  const _DisciplineWrap({
    required this.selected,
    required this.labelFor,
    required this.onTap,
  });

  final ActivityDiscipline selected;
  final String Function(ActivityDiscipline) labelFor;
  final ValueChanged<ActivityDiscipline> onTap;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ActivityDiscipline.values.map((d) {
          final sel = d == selected;
          return GestureDetector(
            onTap: () => onTap(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: sel
                    ? AppColors.forest600.withOpacity(.12)
                    : AppColors.stone50,
                borderRadius: AppRadius.pill,
                border: Border.all(
                  color: sel
                      ? AppColors.forest600.withOpacity(.35)
                      : AppColors.stone100,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    disciplineIcon(d),
                    size: 16,
                    color: sel ? AppColors.forest600 : AppColors.stone400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    labelFor(d),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: sel ? AppColors.forest600 : AppColors.stone600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
}

/// A labelled stone-filled text field — same chrome as the home activity sheet
/// distance/duration inputs.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.suffix,
    this.hintText,
    this.fillColor,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? suffix;
  final String? hintText;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.stone400)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall
                .copyWith(color: AppColors.forest700),
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor ?? AppColors.stone50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide: BorderSide(color: AppColors.stone100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide: BorderSide(color: AppColors.stone100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide:
                    BorderSide(color: AppColors.forest300, width: 1.5),
              ),
              hintText: hintText,
              hintStyle: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.stone200),
              suffixText: suffix,
              suffixStyle:
                  AppTextStyles.caption.copyWith(color: AppColors.stone400),
            ),
          ),
        ],
      );
}

/// A tappable stone-filled field that opens the date picker.
class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.stone50,
            borderRadius: AppRadius.lg,
            border: Border.all(color: AppColors.stone100),
          ),
          child: Row(
            children: [
              Icon(Icons.event_outlined,
                  size: 18, color: AppColors.forest600),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.stone800)),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.stone400),
            ],
          ),
        ),
      );
}

class _PlannerNotesField extends StatelessWidget {
  const _PlannerNotesField({required this.controller, required this.hintText});
  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: 3,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
          filled: true,
          fillColor: AppColors.stone50,
        ),
      );
}

class _PlannerSaveButton extends StatelessWidget {
  const _PlannerSaveButton({
    required this.saving,
    required this.onPressed,
    required this.label,
  });
  final bool saving;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: saving ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.forest600,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(label),
        ),
      );
}
