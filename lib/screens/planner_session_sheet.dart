// Add / edit a planned training session (PlannerSession). Visually a sibling of
// the home-screen activity sheet: same _sheetShell scaffold (re-implemented here
// privately so this screen stays self-contained), the same SessionType choice
// chips, the same stone/forest field idiom and H.* haptics.
//
// Save / update / delete go through plannerSessionProvider.notifier. When the
// user taps "mark complete" we optionally create a linked manual PlannerActivity
// (mirroring the planned distance/minutes) and stamp the session via
// markComplete(id, activityId) so the plan and the log stay tied together.
//
// All copy comes from the l10n getters (sentence case). Distances are stored
// canonical KM; the input suffix and any prefilled value are unit-aware via the
// profile + locale_format helpers.

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
import '../utils/locale_format.dart';

/// Open the add / edit session sheet. Pass [existing] to edit (delete + mark
/// complete become available), or leave it null to add a new session. [goalId]
/// seeds the goal link on a new session; [date] seeds the date on a new session.
Future<void> showPlannerSessionSheet(
  BuildContext context,
  WidgetRef ref, {
  PlannerSession? existing,
  String? goalId,
  DateTime? date,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlannerSessionSheet(
      existing: existing,
      goalId: goalId,
      date: date,
    ),
  );
}

class _PlannerSessionSheet extends ConsumerStatefulWidget {
  const _PlannerSessionSheet({this.existing, this.goalId, this.date});

  final PlannerSession? existing;
  final String? goalId;
  final DateTime? date;

  @override
  ConsumerState<_PlannerSessionSheet> createState() =>
      _PlannerSessionSheetState();
}

class _PlannerSessionSheetState extends ConsumerState<_PlannerSessionSheet> {
  late SessionType _type;
  late DateTime _date;
  final _distanceCtrl = TextEditingController();
  final _minutesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  bool get _isEdit => widget.existing != null;
  bool get _needsDistance => distanceSessionTypes.contains(_type);

  bool get _imperial =>
      ref.read(profileProvider).valueOrNull?.useImperial ?? false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? SessionType.easyRun;
    _date = e?.date ?? widget.date ?? DateTime.now();
    if (e?.plannedMinutes != null) {
      _minutesCtrl.text = e!.plannedMinutes.toString();
    }
    if (e?.plannedDistanceKm != null) {
      // Prefill in the user's display unit; converted back to km on save.
      final shown =
          _imperial ? e!.plannedDistanceKm! * 0.621371 : e!.plannedDistanceKm!;
      _distanceCtrl.text =
          shown == shown.roundToDouble() ? shown.toStringAsFixed(0) : '$shown';
    }
    _notesCtrl.text = e?.notes ?? '';
  }

  @override
  void dispose() {
    _distanceCtrl.dispose();
    _minutesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _typeLabel(AppLocalizations l10n, SessionType t) => switch (t) {
        SessionType.easyRun => l10n.plannerSessionEasyRun,
        SessionType.intervals => l10n.plannerSessionIntervals,
        SessionType.tempo => l10n.plannerSessionTempo,
        SessionType.longRun => l10n.plannerSessionLongRun,
        SessionType.rest => l10n.plannerSessionRest,
        SessionType.crossTrain => l10n.plannerSessionCrossTrain,
        SessionType.swim => l10n.plannerSessionSwim,
        SessionType.other => l10n.plannerSessionOther,
      };

  /// Parse the distance field (display unit) back to canonical km, or null.
  double? _distanceKm() {
    final raw = _distanceCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final value = double.tryParse(raw);
    if (value == null) return null;
    return _imperial ? value / 0.621371 : value;
  }

  int? _minutes() {
    final raw = _minutesCtrl.text.trim();
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  String? _notes() {
    final t = _notesCtrl.text.trim();
    return t.isEmpty ? null : t;
  }

  PlannerSession _compose() {
    final base = widget.existing;
    final distance = _needsDistance ? _distanceKm() : null;
    return PlannerSession(
      id: base?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      goalId: base?.goalId ?? widget.goalId ?? '',
      date: _date,
      type: _type,
      title: base?.title,
      plannedDistanceKm: distance,
      plannedMinutes: _minutes(),
      notes: _notes(),
      completed: base?.completed ?? false,
      completedActivityId: base?.completedActivityId,
    );
  }

  Future<void> _pickDate() async {
    H.selection();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 366 * 2)),
    );
    if (picked != null && mounted) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    H.medium();
    try {
      final session = _compose();
      final notifier = ref.read(plannerSessionProvider.notifier);
      if (_isEdit) {
        await notifier.updateSession(session);
      } else {
        await notifier.add(session);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final id = widget.existing?.id;
    if (id == null) return;
    setState(() => _saving = true);
    H.heavy();
    try {
      await ref.read(plannerSessionProvider.notifier).delete(id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Mark the edited session complete. For a distance/duration session we mint a
  /// linked manual PlannerActivity that mirrors the plan, then stamp the session
  /// with its id; a rest day (or empty plan) just flips the completed flag.
  Future<void> _toggleComplete() async {
    final session = widget.existing;
    if (session == null) return;
    setState(() => _saving = true);
    final sessions = ref.read(plannerSessionProvider.notifier);
    try {
      if (session.completed) {
        H.light();
        // Un-complete: drop the linked activity (if we minted one) and clear
        // the stamp so it never dangles on a possibly-deleted activity.
        final linked = session.completedActivityId;
        if (linked != null) {
          await ref.read(plannerActivityProvider.notifier).delete(linked);
        }
        await sessions.setComplete(session.id, false);
      } else {
        H.medium();
        String? activityId;
        final minutes = _minutes();
        if (_type != SessionType.rest && minutes != null && minutes > 0) {
          final activity = PlannerActivity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            date: _date,
            type: _type,
            minutes: minutes,
            distanceKm: _needsDistance ? _distanceKm() : null,
            source: ActivitySource.manual,
            goalId: session.goalId.isEmpty ? null : session.goalId,
            notes: _notes(),
          );
          await ref.read(plannerActivityProvider.notifier).add(activity);
          activityId = activity.id;
        }
        await sessions.markComplete(session.id, activityId);
      }
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
    final dateLabel = DateFormat('EEEE, d MMMM').format(_date);

    return _PlannerSheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlannerSheetHeader(
            icon: sessionTypeIcon(_type),
            title: _isEdit ? l10n.plannerEditSession : l10n.plannerAddSession,
            subtitle: l10n.plannerSessionLine(
              _typeLabel(l10n, _type),
              _needsDistance && _distanceKm() != null
                  ? formatDistance(_distanceKm()!,
                      imperial: imperial, l10n: l10n)
                  : '',
            ),
          ),
          const SizedBox(height: 22),

          // ── Session type ─────────────────────────────────────────────────
          _PlannerSectionLabel(l10n.plannerTabPlanner),
          const SizedBox(height: 10),
          _SessionTypeWrap(
            selected: _type,
            labelFor: (t) => _typeLabel(l10n, t),
            onTap: (t) {
              H.selection();
              setState(() => _type = t);
            },
          ),
          const SizedBox(height: 18),

          // ── Date ─────────────────────────────────────────────────────────
          _PlannerSectionLabel(l10n.plannerPlanStartDate),
          const SizedBox(height: 10),
          _DateField(label: dateLabel, onTap: _pickDate),
          const SizedBox(height: 18),

          // ── Distance (only distance-type sessions) + minutes ─────────────
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

          // ── Notes ────────────────────────────────────────────────────────
          _PlannerNotesField(
            controller: _notesCtrl,
            hintText: l10n.homeActivityNotesHint,
          ),
          const SizedBox(height: 18),

          // ── Mark complete (edit only) ────────────────────────────────────
          if (_isEdit) ...[
            _OutlineButton(
              icon: widget.existing!.completed
                  ? Icons.undo_rounded
                  : Icons.check_circle_outline_rounded,
              label: widget.existing!.completed
                  ? l10n.plannerMarkIncomplete
                  : l10n.plannerMarkComplete,
              onPressed: _saving ? null : _toggleComplete,
            ),
            const SizedBox(height: 12),
          ],

          // ── Save ─────────────────────────────────────────────────────────
          _PlannerSaveButton(
            saving: _saving,
            onPressed: _save,
            label: _isEdit ? l10n.plannerEditSession : l10n.plannerAddSession,
          ),

          // ── Delete (edit only) ───────────────────────────────────────────
          if (_isEdit) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.plannerDeleteSession),
              style: TextButton.styleFrom(foregroundColor: AppColors.blush600),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Shared planner-sheet building blocks ─────────────────────────────────────
// Re-implemented privately (mirroring home_screen's _sheetShell / _SheetHeader /
// _SheetSectionLabel / _NotesField / _saveButton) so the planner sheets stay
// self-contained while staying visually identical to the rest of the app.

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

/// Choice-chip wrap over every [SessionType], styled exactly like home_screen's
/// _ChoiceChip but with a leading session-type glyph for at-a-glance scanning.
class _SessionTypeWrap extends StatelessWidget {
  const _SessionTypeWrap({
    required this.selected,
    required this.labelFor,
    required this.onTap,
  });

  final SessionType selected;
  final String Function(SessionType) labelFor;
  final ValueChanged<SessionType> onTap;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: SessionType.values.map((t) {
          final sel = t == selected;
          return GestureDetector(
            onTap: () => onTap(t),
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
                    sessionTypeIcon(t),
                    size: 16,
                    color: sel ? AppColors.forest600 : AppColors.stone400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    labelFor(t),
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
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? suffix;
  final String? hintText;

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
              fillColor: AppColors.stone50,
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

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.forest600,
            side: BorderSide(color: AppColors.forest600.withOpacity(.35)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
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
