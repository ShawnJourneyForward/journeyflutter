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
  final _paceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  late final _PaceLink _paceLink;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;
  bool get _needsDistance => distanceSessionTypes.contains(_type);
  bool get _isSwim => _type == SessionType.swim;

  bool get _imperial =>
      ref.read(profileProvider).valueOrNull?.useImperial ?? false;

  /// Swim distance entry unit: 0 = raw metres, 25 / 50 = lengths of a 25m / 50m
  /// pool (each length counts as that many metres). Runs ignore this.
  int _swimLapMetres = 0;
  int get _swimMetresPerUnit => _swimLapMetres == 0 ? 1 : _swimLapMetres;

  /// The distance-field value (display unit) → pace segments. Swim pace is per
  /// 100m: metres = value × metres-per-unit, segments = metres / 100. Runs use
  /// one segment per displayed km / mile.
  double _segmentsForDistance(double d) {
    if (_isSwim) return d * _swimMetresPerUnit / 100;
    return d;
  }

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
      // Prefill in the field's display unit; converted back to km on save. Swim
      // defaults to whole metres (e.g. 0.4 km → "400"); runs to km / miles.
      if (e!.type == SessionType.swim) {
        _distanceCtrl.text = (e.plannedDistanceKm! * 1000).round().toString();
      } else {
        final shown =
            _imperial ? e.plannedDistanceKm! * 0.621371 : e.plannedDistanceKm!;
        _distanceCtrl.text =
            shown == shown.roundToDouble() ? shown.toStringAsFixed(0) : '$shown';
      }
    }
    _notesCtrl.text = e?.notes ?? '';
    if (e?.type == SessionType.other) _titleCtrl.text = e?.title ?? '';
    _paceLink = _PaceLink(
      distance: _distanceCtrl,
      duration: _minutesCtrl,
      pace: _paceCtrl,
      segmentsForDistance: _segmentsForDistance,
    );
    // Seed pace from a prefilled plan so editing one field updates the right one.
    if (_distanceCtrl.text.isNotEmpty && _minutesCtrl.text.isNotEmpty) {
      _paceLink.resyncPace();
    }
  }

  /// Switch the swim distance unit, converting the current value so the actual
  /// distance is preserved (e.g. 400 m → 16 lengths of a 25m pool).
  void _setSwimLapMetres(int metres) {
    if (metres == _swimLapMetres) return;
    H.selection();
    final v = double.tryParse(_distanceCtrl.text.trim().replaceAll(',', '.'));
    final oldPer = _swimMetresPerUnit;
    setState(() => _swimLapMetres = metres);
    if (v != null && v > 0) {
      final nv = v * oldPer / _swimMetresPerUnit;
      _distanceCtrl.text =
          nv == nv.roundToDouble() ? nv.round().toString() : nv.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _paceLink.dispose();
    _distanceCtrl.dispose();
    _minutesCtrl.dispose();
    _paceCtrl.dispose();
    _notesCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  /// Pace unit shown in the field label: min/100m for swim, else min per
  /// displayed distance unit.
  String _paceUnit(AppLocalizations l10n, String distanceUnit) =>
      _isSwim ? '${l10n.homeUnitMin}/100m' : '${l10n.homeUnitMin}/$distanceUnit';

  /// Forward-looking workout-plan hint, tuned to the chosen discipline.
  String _notesHint(AppLocalizations l10n) => switch (_type) {
        SessionType.swim => l10n.plannerSessionNotesHintSwim,
        SessionType.crossTrain => l10n.plannerSessionNotesHintCross,
        SessionType.rest => l10n.plannerSessionNotesHintRest,
        SessionType.other => l10n.plannerSessionNotesHintOther,
        _ => l10n.plannerSessionNotesHint,
      };

  String _typeLabel(AppLocalizations l10n, SessionType t) => switch (t) {
        SessionType.easyRun => l10n.plannerSessionEasyRun,
        SessionType.intervals => l10n.plannerSessionIntervals,
        SessionType.tempo => l10n.plannerSessionTempo,
        SessionType.longRun => l10n.plannerSessionLongRun,
        SessionType.rest => l10n.plannerSessionRest,
        SessionType.crossTrain => l10n.plannerSessionCrossTrain,
        SessionType.swim => l10n.plannerSessionSwim,
        // General disciplines reuse the already-translated discipline labels.
        SessionType.ride => l10n.plannerDisciplineRide,
        SessionType.walk => l10n.plannerDisciplineWalk,
        SessionType.hike => l10n.plannerDisciplineHike,
        SessionType.gym => l10n.plannerDisciplineGym,
        SessionType.yoga => l10n.plannerDisciplineYoga,
        SessionType.cardio => l10n.plannerDisciplineCardio,
        SessionType.other => l10n.plannerSessionOther,
      };

  /// Parse the distance field back to canonical km, or null. Swim is entered in
  /// metres (or pool lengths → metres); runs in the user's km / miles.
  double? _distanceKm() {
    final raw = _distanceCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final value = double.tryParse(raw);
    if (value == null) return null;
    if (_isSwim) return value * _swimMetresPerUnit / 1000;
    return _imperial ? value / 0.621371 : value;
  }

  /// Unit shown on the swim distance field: "m" for metres, the localized
  /// "laps" word for a pool mode.
  String _swimDistanceUnit(AppLocalizations l10n) =>
      _swimLapMetres == 0 ? 'm' : l10n.plannerSwimLapsUnit;

  int? _minutes() {
    return parseDurationMinutes(_minutesCtrl.text);
  }

  String? _notes() {
    final t = _notesCtrl.text.trim();
    return t.isEmpty ? null : t;
  }

  /// The free-text name for an "Other" session, or null. Only meaningful when
  /// the type is [SessionType.other]; other types keep their existing title.
  String? _title() {
    final t = _titleCtrl.text.trim();
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
      title: _type == SessionType.other ? _title() : base?.title,
      plannedDistanceKm: distance,
      plannedMinutes: _minutes(),
      notes: _notes(),
      completed: base?.completed ?? false,
      // Preserve a SKIPPED flag across a plain plan edit — editing a skipped
      // session's distance must not silently un-skip it.
      skipped: base?.skipped ?? false,
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

  /// Close off the edited session: persist any plan edits first (so the close-off
  /// sheet seeds from the latest plan and the activity's snapshot is right), then
  /// open the close-off sheet to log actuals or skip. A rest day has nothing to
  /// log, so it just completes in one step.
  Future<void> _closeOff() async {
    final session = _compose();
    setState(() => _saving = true);
    final notifier = ref.read(plannerSessionProvider.notifier);
    try {
      await notifier.updateSession(session);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      return;
    }
    if (!mounted) return;
    if (session.type == SessionType.rest) {
      H.medium();
      await notifier.markComplete(session.id, null);
      if (mounted) Navigator.of(context).pop();
      return;
    }
    // Stack the close-off sheet on top, then dismiss this edit sheet once it's
    // done (whether the user logged, skipped, or backed out).
    await showPlannerSessionCompleteSheet(context, ref, session);
    if (mounted) Navigator.of(context).pop();
  }

  /// Re-open a completed/skipped session back to a pending to-do, dropping any
  /// linked activity so it never dangles on a deleted log.
  Future<void> _reopen() async {
    final session = widget.existing;
    if (session == null) return;
    setState(() => _saving = true);
    H.light();
    try {
      final linked = session.completedActivityId;
      if (linked != null) {
        await ref.read(plannerActivityProvider.notifier).delete(linked);
      }
      await ref.read(plannerSessionProvider.notifier).reopen(session.id);
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
              final disciplineChanged = (t == SessionType.swim) != _isSwim;
              setState(() => _type = t);
              // Pace unit differs by discipline (min/100m vs min/km) — re-derive
              // so a left-over value isn't shown in the wrong unit.
              if (disciplineChanged && distanceSessionTypes.contains(t)) {
                _paceLink.resyncPace();
              }
            },
          ),
          const SizedBox(height: 18),

          // ── Date ─────────────────────────────────────────────────────────
          _PlannerSectionLabel(l10n.plannerPlanStartDate),
          const SizedBox(height: 10),
          _DateField(label: dateLabel, onTap: _pickDate),
          const SizedBox(height: 18),

          // ── Distance (only distance-type sessions) + minutes + pace ──────
          if (_needsDistance) ...[
            // Swim: choose how distance is entered — raw metres or pool lengths.
            if (_isSwim) ...[
              _SwimUnitSelector(
                selected: _swimLapMetres,
                metresLabel: l10n.plannerSwimUnitMetres,
                pool25Label: l10n.plannerSwimUnitPool25,
                pool50Label: l10n.plannerSwimUnitPool50,
                onTap: _setSwimLapMetres,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _LabeledField(
                    label: l10n.homeActivityDistanceLabel(
                        _isSwim ? _swimDistanceUnit(l10n) : distanceUnit),
                    controller: _distanceCtrl,
                    keyboardType: _isSwim
                        ? TextInputType.number
                        : const TextInputType.numberWithOptions(decimal: true),
                    hintText: _isSwim ? '0' : '0.0',
                    suffix: _isSwim ? _swimDistanceUnit(l10n) : distanceUnit,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LabeledField(
                    label: l10n.homeActivityDurationMin,
                    controller: _minutesCtrl,
                    keyboardType: TextInputType.number,
                    suffix: l10n.homeUnitMin,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LabeledField(
                    label: l10n.plannerPaceLabel(_paceUnit(l10n, distanceUnit)),
                    controller: _paceCtrl,
                    keyboardType: TextInputType.datetime,
                    hintText: '0:00',
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

          // ── What is it? (Other only) ─────────────────────────────────────
          if (_type == SessionType.other) ...[
            _PlannerSectionLabel(l10n.plannerSessionOtherNameLabel),
            const SizedBox(height: 10),
            _PlannerTextField(
              controller: _titleCtrl,
              hintText: l10n.plannerSessionOtherNameHint,
            ),
            const SizedBox(height: 18),
          ],

          // ── Notes ────────────────────────────────────────────────────────
          // Planning ahead → a forward-looking workout-plan hint, NOT the
          // home log's after-the-fact reflection example. Tuned to discipline.
          _PlannerNotesField(
            controller: _notesCtrl,
            hintText: _notesHint(l10n),
          ),
          const SizedBox(height: 18),

          // ── Close off / reopen (edit only) ───────────────────────────────
          if (_isEdit) ...[
            Builder(builder: (_) {
              final closed =
                  widget.existing!.completed || widget.existing!.skipped;
              return _OutlineButton(
                icon: closed
                    ? Icons.undo_rounded
                    : Icons.check_circle_outline_rounded,
                label: closed
                    ? l10n.plannerReopenSession
                    : l10n.plannerCloseOffCta,
                onPressed: _saving ? null : (closed ? _reopen : _closeOff),
              );
            }),
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

// ─── Close-off / completion sheet ────────────────────────────────────────────
//
// Opened when the user CLOSES OFF a planned (non-rest) session — the calendar
// week-row check and the edit sheet's button both route here. It pre-fills the
// planned distance/time so the user only adjusts to what they ACTUALLY did, then
// either logs it (minting a linked PlannerActivity that records the actuals AND
// the original plan, so history can show planned-vs-did) or marks the session
// skipped (no activity logged). Rest days never reach here — there's nothing to
// log, so they complete in one tap.

/// Open the close-off sheet for a pending [session]. Reuses the same sheet
/// chrome as the edit sheet. Intended for non-rest, not-yet-closed sessions.
Future<void> showPlannerSessionCompleteSheet(
  BuildContext context,
  WidgetRef ref,
  PlannerSession session,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlannerSessionCompleteSheet(session: session),
  );
}

class _PlannerSessionCompleteSheet extends ConsumerStatefulWidget {
  const _PlannerSessionCompleteSheet({required this.session});
  final PlannerSession session;

  @override
  ConsumerState<_PlannerSessionCompleteSheet> createState() =>
      _PlannerSessionCompleteSheetState();
}

class _PlannerSessionCompleteSheetState
    extends ConsumerState<_PlannerSessionCompleteSheet> {
  final _distanceCtrl = TextEditingController();
  final _minutesCtrl = TextEditingController();
  final _paceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late final _PaceLink _paceLink;
  bool _saving = false;

  SessionType get _type => widget.session.type;
  bool get _needsDistance => distanceSessionTypes.contains(_type);
  bool get _isSwim => _type == SessionType.swim;
  bool get _imperial =>
      ref.read(profileProvider).valueOrNull?.useImperial ?? false;

  /// Swim distance entry unit (see the add-session sheet): 0 = metres, 25 / 50 =
  /// pool lengths.
  int _swimLapMetres = 0;
  int get _swimMetresPerUnit => _swimLapMetres == 0 ? 1 : _swimLapMetres;

  double _segmentsForDistance(double d) {
    if (_isSwim) return d * _swimMetresPerUnit / 100;
    return d;
  }

  String _paceUnit(AppLocalizations l10n, String distanceUnit) =>
      _isSwim ? '${l10n.homeUnitMin}/100m' : '${l10n.homeUnitMin}/$distanceUnit';

  String _swimDistanceUnit(AppLocalizations l10n) =>
      _swimLapMetres == 0 ? 'm' : l10n.plannerSwimLapsUnit;

  void _setSwimLapMetres(int metres) {
    if (metres == _swimLapMetres) return;
    H.selection();
    final v = double.tryParse(_distanceCtrl.text.trim().replaceAll(',', '.'));
    final oldPer = _swimMetresPerUnit;
    setState(() => _swimLapMetres = metres);
    if (v != null && v > 0) {
      final nv = v * oldPer / _swimMetresPerUnit;
      _distanceCtrl.text =
          nv == nv.roundToDouble() ? nv.round().toString() : nv.toStringAsFixed(1);
    }
  }

  @override
  void initState() {
    super.initState();
    // Seed the fields with the PLAN so the user only edits down to actuals.
    final s = widget.session;
    if (s.plannedMinutes != null) _minutesCtrl.text = '${s.plannedMinutes}';
    if (s.plannedDistanceKm != null) {
      // Swim seeds whole metres; runs the km / mile display value.
      if (_isSwim) {
        _distanceCtrl.text = (s.plannedDistanceKm! * 1000).round().toString();
      } else {
        final shown =
            _imperial ? s.plannedDistanceKm! * 0.621371 : s.plannedDistanceKm!;
        _distanceCtrl.text =
            shown == shown.roundToDouble() ? shown.toStringAsFixed(0) : '$shown';
      }
    }
    _notesCtrl.text = s.notes ?? '';
    _paceLink = _PaceLink(
      distance: _distanceCtrl,
      duration: _minutesCtrl,
      pace: _paceCtrl,
      segmentsForDistance: _segmentsForDistance,
    );
    if (_needsDistance &&
        _distanceCtrl.text.isNotEmpty &&
        _minutesCtrl.text.isNotEmpty) {
      _paceLink.resyncPace();
    }
  }

  @override
  void dispose() {
    _paceLink.dispose();
    _distanceCtrl.dispose();
    _minutesCtrl.dispose();
    _paceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double? _distanceKm() {
    final raw = _distanceCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw);
    if (v == null) return null;
    if (_isSwim) return v * _swimMetresPerUnit / 1000;
    return _imperial ? v / 0.621371 : v;
  }

  int? _minutes() {
    return parseDurationMinutes(_minutesCtrl.text);
  }

  String? _notes() {
    final t = _notesCtrl.text.trim();
    return t.isEmpty ? null : t;
  }

  /// "Planned: 10 km · 60 min" reference line from the session plan, or null
  /// when the session carried no planned numbers.
  String? _plannedSummary(AppLocalizations l10n, bool imperial) {
    final parts = <String>[];
    final d = widget.session.plannedDistanceKm;
    if (_needsDistance && d != null && d > 0) {
      parts.add(formatDistance(d, imperial: imperial, l10n: l10n));
    }
    final m = widget.session.plannedMinutes;
    if (m != null && m > 0) parts.add(l10n.commonMin(m));
    if (parts.isEmpty) return null;
    return l10n.plannerPlannedPrefix(parts.join('  ·  '));
  }

  /// Log the session as DONE. When there's something to record we mint a linked
  /// manual activity carrying the actuals + the plan snapshot; otherwise we just
  /// flip the session to complete.
  Future<void> _logSession() async {
    setState(() => _saving = true);
    H.medium();
    final session = widget.session;
    final sessions = ref.read(plannerSessionProvider.notifier);
    try {
      String? activityId;
      final minutes = _minutes();
      final distance = _needsDistance ? _distanceKm() : null;
      final hasActuals =
          (minutes != null && minutes > 0) || (distance != null && distance > 0);
      if (_type != SessionType.rest && hasActuals) {
        final activity = PlannerActivity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: session.date,
          type: _type,
          minutes: minutes ?? 0,
          distanceKm: distance,
          source: ActivitySource.manual,
          goalId: session.goalId.isEmpty ? null : session.goalId,
          notes: _notes(),
          discipline: disciplineFromSessionType(_type),
          // Snapshot the plan so history can show "planned X · did Y".
          plannedDistanceKm: session.plannedDistanceKm,
          plannedMinutes: session.plannedMinutes,
        );
        await ref.read(plannerActivityProvider.notifier).add(activity);
        activityId = activity.id;
      }
      await sessions.markComplete(session.id, activityId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Mark the session SKIPPED — records the miss without logging an activity.
  Future<void> _skip() async {
    setState(() => _saving = true);
    H.light();
    try {
      await ref
          .read(plannerSessionProvider.notifier)
          .markSkipped(widget.session.id);
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
    final planned = _plannedSummary(l10n, imperial);
    final dateLabel = DateFormat('EEEE, d MMMM').format(widget.session.date);

    return _PlannerSheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlannerSheetHeader(
            icon: sessionTypeIcon(_type),
            title: l10n.plannerLogSessionTitle,
            subtitle: planned == null ? dateLabel : '$dateLabel  ·  $planned',
          ),
          const SizedBox(height: 22),

          // ── What you actually did ────────────────────────────────────────
          _PlannerSectionLabel(l10n.plannerLogActualHeader),
          const SizedBox(height: 10),
          if (_needsDistance) ...[
            if (_isSwim) ...[
              _SwimUnitSelector(
                selected: _swimLapMetres,
                metresLabel: l10n.plannerSwimUnitMetres,
                pool25Label: l10n.plannerSwimUnitPool25,
                pool50Label: l10n.plannerSwimUnitPool50,
                onTap: _setSwimLapMetres,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _LabeledField(
                    label: l10n.homeActivityDistanceLabel(
                        _isSwim ? _swimDistanceUnit(l10n) : distanceUnit),
                    controller: _distanceCtrl,
                    keyboardType: _isSwim
                        ? TextInputType.number
                        : const TextInputType.numberWithOptions(decimal: true),
                    hintText: _isSwim ? '0' : '0.0',
                    suffix: _isSwim ? _swimDistanceUnit(l10n) : distanceUnit,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LabeledField(
                    label: l10n.homeActivityDurationMin,
                    controller: _minutesCtrl,
                    keyboardType: TextInputType.number,
                    suffix: l10n.homeUnitMin,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LabeledField(
                    label: l10n.plannerPaceLabel(_paceUnit(l10n, distanceUnit)),
                    controller: _paceCtrl,
                    keyboardType: TextInputType.datetime,
                    hintText: '0:00',
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
          const SizedBox(height: 20),

          // ── Log (primary) + skip (secondary) ─────────────────────────────
          _PlannerSaveButton(
            saving: _saving,
            onPressed: _logSession,
            label: l10n.plannerLogSessionCta,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _saving ? null : _skip,
            icon: const Icon(Icons.do_not_disturb_on_outlined, size: 18),
            label: Text(l10n.plannerSkipSessionCta),
            style: TextButton.styleFrom(foregroundColor: AppColors.stone500),
          ),
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
                    ? AppColors.forest600.withValues(alpha: .12)
                    : AppColors.stone50,
                borderRadius: AppRadius.pill,
                border: Border.all(
                  color: sel
                      ? AppColors.forest600.withValues(alpha: .35)
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

/// Segmented selector for how a swim distance is entered: raw metres, or
/// lengths of a 25m / 50m pool. Mirrors the choice-chip idiom used elsewhere.
class _SwimUnitSelector extends StatelessWidget {
  const _SwimUnitSelector({
    required this.selected,
    required this.metresLabel,
    required this.pool25Label,
    required this.pool50Label,
    required this.onTap,
  });

  final int selected; // 0 = metres, 25, 50
  final String metresLabel;
  final String pool25Label;
  final String pool50Label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final options = <(int, String)>[
      (0, metresLabel),
      (25, pool25Label),
      (50, pool50Label),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final sel = o.$1 == selected;
        return GestureDetector(
          onTap: () => onTap(o.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel
                  ? AppColors.forest600.withValues(alpha: .12)
                  : AppColors.stone50,
              borderRadius: AppRadius.pill,
              border: Border.all(
                color: sel
                    ? AppColors.forest600.withValues(alpha: .35)
                    : AppColors.stone100,
              ),
            ),
            child: Text(
              o.$2,
              style: AppTextStyles.labelLarge.copyWith(
                color: sel ? AppColors.forest600 : AppColors.stone600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.stone500)),
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
                  AppTextStyles.caption.copyWith(color: AppColors.stone500),
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

/// A single-line, left-aligned stone-filled text field — used for the free-text
/// "Other" session name (a label, not a number, so it isn't centred).
class _PlannerTextField extends StatelessWidget {
  const _PlannerTextField({required this.controller, required this.hintText});
  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.forest700),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
          filled: true,
          fillColor: AppColors.stone50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            borderSide: BorderSide(color: AppColors.forest300, width: 1.5),
          ),
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
            side: BorderSide(color: AppColors.forest600.withValues(alpha: .35)),
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

// ── Pace auto-calc ───────────────────────────────────────────────────────────
//
// Pace links Distance, Duration and Pace so any two fill the third. The unit is
// per-display-distance for runs (min/km or min/mi) and per-100m for swim, so
// [_PaceLink] is parameterised with how to turn a display distance into a count
// of "pace segments" (km/mi or 100m units) and back. Pace is a UI convenience —
// it is never persisted; only distance + minutes are stored.

/// Parse a pace string — "m:ss", "mm:ss", or plain decimal minutes — to seconds.
/// Returns null for blank or malformed input.
double? _parsePaceSeconds(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  if (t.contains(':')) {
    final parts = t.split(':');
    if (parts.length != 2) return null;
    final m = int.tryParse(parts[0].trim());
    final s = int.tryParse(parts[1].trim());
    if (m == null || s == null || s < 0 || s >= 60) return null;
    return m * 60.0 + s;
  }
  final dec = double.tryParse(t.replaceAll(',', '.'));
  if (dec == null || dec < 0) return null;
  return dec * 60.0;
}

/// Format seconds-per-unit as "m:ss" (empty for non-positive / non-finite).
String _formatPaceSeconds(double sec) {
  if (!sec.isFinite || sec <= 0) return '';
  final total = sec.round();
  return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
}

/// Ties Distance, Duration and Pace together. Distance is always a user input
/// (never auto-filled): you enter a distance, then whichever of Duration / Pace
/// you type becomes the "driver" and the other is derived. Editing distance
/// re-derives the non-driver. This gives exactly: distance + time → pace, and
/// distance + pace → time. Programmatic writes are suppressed so they don't loop.
class _PaceLink {
  _PaceLink({
    required this.distance,
    required this.duration,
    required this.pace,
    required this.segmentsForDistance,
  }) {
    distance.addListener(_onDistance);
    duration.addListener(_onDuration);
    pace.addListener(_onPace);
  }

  final TextEditingController distance;
  final TextEditingController duration;
  final TextEditingController pace;

  /// distance-field value → number of pace segments (km/mi, or 100m units for
  /// swim). Distance is never auto-filled, so no inverse is needed.
  final double Function(double) segmentsForDistance;

  /// Which of duration / pace the user last typed — the one to hold when the
  /// distance changes. `true` = pace is the driver, `false` = duration.
  bool _paceDriven = false;
  bool _suppress = false;

  void dispose() {
    distance.removeListener(_onDistance);
    duration.removeListener(_onDuration);
    pace.removeListener(_onPace);
  }

  double? _distanceVal() {
    final v = double.tryParse(distance.text.trim().replaceAll(',', '.'));
    return (v != null && v > 0) ? v : null;
  }

  double? _durationVal() {
    final v = double.tryParse(duration.text.trim().replaceAll(',', '.'));
    return (v != null && v > 0) ? v : null;
  }

  void _onDistance() {
    if (_suppress) return;
    // Distance changed — re-derive whichever of duration/pace is NOT the driver.
    if (_paceDriven) {
      _computeDuration();
    } else {
      _computePace();
    }
  }

  void _onDuration() {
    if (_suppress) return;
    _paceDriven = false;
    _computePace();
  }

  void _onPace() {
    if (_suppress) return;
    _paceDriven = true;
    _computeDuration();
  }

  void _computePace() {
    final d = _distanceVal();
    final mins = _durationVal();
    if (d == null || mins == null) return;
    final seg = segmentsForDistance(d);
    if (seg > 0) _write(pace, _formatPaceSeconds(mins * 60 / seg));
  }

  void _computeDuration() {
    final d = _distanceVal();
    final paceSec = _parsePaceSeconds(pace.text);
    if (d == null || paceSec == null || paceSec <= 0) return;
    _write(duration, (paceSec * segmentsForDistance(d) / 60).round().toString());
  }

  /// Re-derive pace from distance + duration — used after a discipline change
  /// (distance & duration are unit-independent; only pace's unit shifts). Clears
  /// pace if either input is missing.
  void resyncPace() {
    _paceDriven = false;
    final d = _distanceVal();
    final mins = _durationVal();
    if (d != null && mins != null) {
      final seg = segmentsForDistance(d);
      _write(pace, seg > 0 ? _formatPaceSeconds(mins * 60 / seg) : '');
    } else {
      _write(pace, '');
    }
  }

  void _write(TextEditingController c, String value) {
    if (c.text == value) return;
    _suppress = true;
    c.text = value;
    c.selection = TextSelection.collapsed(offset: value.length);
    _suppress = false;
  }
}
