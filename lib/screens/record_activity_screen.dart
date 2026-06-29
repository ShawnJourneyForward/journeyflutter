// GPS walk / run recorder screen — the offline replacement for Strava. The user
// picks Walk or Run, taps Start, and the screen shows live distance, moving
// time and pace from the device's GPS. There is deliberately NO map: tiles need
// the network and this app ships none. On Finish it hands the distance + minutes
// to the standard activity log sheet (so saving, unit handling and goal linking
// are reused), which writes a PlannerActivity. Nothing about the path is stored
// — only the totalled distance and duration.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../components/back_button.dart';
import '../l10n/app_localizations.dart';
import '../models/planner_activity.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../theme/planner_palette.dart';
import '../utils/gps_recorder.dart';
import '../utils/haptic_service.dart';
import 'planner_activity_sheet.dart';

const double _miPerKm = 0.621371;

class RecordActivityScreen extends ConsumerStatefulWidget {
  const RecordActivityScreen({super.key});

  @override
  ConsumerState<RecordActivityScreen> createState() =>
      _RecordActivityScreenState();
}

class _RecordActivityScreenState extends ConsumerState<RecordActivityScreen> {
  final GpsRecorder _rec = GpsRecorder();

  /// Only Walk and Run are offered here (the request); both are distance
  /// disciplines that the recorder can measure.
  ActivityDiscipline _discipline = ActivityDiscipline.walk;

  LocationGate? _gate;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    _rec.addListener(_onChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prime());
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _rec.removeListener(_onChange);
    _rec.dispose();
    super.dispose();
  }

  bool get _imperial =>
      ref.read(profileProvider).valueOrNull?.useImperial ?? false;

  bool get _isActive =>
      _rec.status == RecorderStatus.recording ||
      _rec.status == RecorderStatus.paused;

  // ── Permission priming ──────────────────────────────────────────────────────

  Future<void> _prime() async {
    final l10n = AppLocalizations.of(context);
    // If location was already granted on a previous visit, skip the rationale
    // sheet and the OS prompt entirely — resolve the gate straight away (this
    // checks services + the existing grant but never shows the system dialog).
    final existing = await Geolocator.checkPermission();
    if (!mounted) return;
    if (existing == LocationPermission.always ||
        existing == LocationPermission.whileInUse) {
      await _requestGate();
      return;
    }
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrimingSheet(
        title: l10n.recordPrimingTitle,
        body: l10n.recordPrimingBody,
        cta: l10n.recordPrimingCta,
        dismiss: l10n.recordPrimingNotNow,
      ),
    );
    if (ok == true) {
      await _requestGate();
    } else if (mounted) {
      context.pop();
    }
  }

  Future<void> _requestGate() async {
    setState(() => _asking = true);
    final gate = await requestLocationGate();
    if (!mounted) return;
    setState(() {
      _gate = gate;
      _asking = false;
    });
    if (gate == LocationGate.ready) _rec.warmUp();
  }

  // ── Controls ────────────────────────────────────────────────────────────────

  void _start() {
    H.medium();
    final l10n = AppLocalizations.of(context);
    _rec.start(
      notifTitle: l10n.recordNotifTitle,
      notifText: l10n.recordNotifText,
    );
  }

  void _pause() {
    H.light();
    _rec.pause();
  }

  void _resume() {
    H.light();
    _rec.resume();
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context);
    // Guard against saving an empty recording (tapped Finish immediately).
    if (_rec.distanceMeters < 20 && _rec.elapsed.inSeconds < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recordTooShort)),
      );
      return;
    }
    H.medium();
    _rec.finish();
    final km = _rec.distanceKm;
    final minutes = (_rec.elapsed.inSeconds / 60).round().clamp(1, 100000);
    await showPlannerActivitySheet(
      context,
      ref,
      initialDiscipline: _discipline,
      initialMinutes: minutes,
      initialDistanceKm: km,
    );
    if (mounted) context.pop();
  }

  Future<bool> _confirmDiscard() async {
    if (!_isActive) return true;
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(l10n.recordDiscardTitle, style: AppTextStyles.titleLarge),
        content: Text(l10n.recordDiscardBody, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.recordKeepRecording),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.honey600),
            child: Text(l10n.recordDiscard),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_isActive,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final discard = await _confirmDiscard();
        if (discard && mounted) router.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.stone50,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 20, 4),
                child: Row(children: [
                  LuxuryBackButton(onPressed: () async {
                    final router = GoRouter.of(context);
                    final discard = await _confirmDiscard();
                    if (discard && mounted) router.pop();
                  }),
                  Text(l10n.recordTitle,
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.forest700)),
                ]),
              ),
              Expanded(child: _buildBody(l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_asking) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_gate != null && _gate != LocationGate.ready) {
      return _GateBlocked(gate: _gate!, onRetry: _requestGate);
    }
    // Ready (or still priming — controls disabled until gate resolves).
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DisciplineToggle(
            selected: _discipline,
            // Locked once recording starts so the saved discipline matches.
            enabled: _rec.status == RecorderStatus.idle ||
                _rec.status == RecorderStatus.acquiring,
            onSelect: (d) {
              H.selection();
              setState(() => _discipline = d);
            },
          ),
          const SizedBox(height: 20),
          _GpsStatusPill(rec: _rec, l10n: l10n),
          const SizedBox(height: 24),
          _BigStat(
            label: l10n.recordStatDistance,
            value: _distanceText(),
            unit: _imperial ? l10n.homeUnitMiles : l10n.homeUnitKm,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MediumStat(
                  label: l10n.recordStatTime,
                  value: _timeText(_rec.elapsed),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MediumStat(
                  label: l10n.recordStatPace,
                  value: _paceText(),
                  unit: _imperial ? l10n.recordPaceUnitMi : l10n.recordPaceUnitKm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          _controls(l10n),
          if (_isActive) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 14, color: AppColors.stone400),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.recordKeepsRecordingHint,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.stone400),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _controls(AppLocalizations l10n) {
    switch (_rec.status) {
      case RecorderStatus.idle:
      case RecorderStatus.acquiring:
      case RecorderStatus.finished:
        return _PrimaryButton(
          label: l10n.recordStart,
          icon: Icons.play_arrow_rounded,
          onPressed: _gate == LocationGate.ready ? _start : null,
        );
      case RecorderStatus.recording:
        return Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                label: l10n.recordPause,
                icon: Icons.pause_rounded,
                onPressed: _pause,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PrimaryButton(
                label: l10n.recordFinish,
                icon: Icons.flag_rounded,
                onPressed: _finish,
              ),
            ),
          ],
        );
      case RecorderStatus.paused:
        return Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                label: l10n.recordResume,
                icon: Icons.play_arrow_rounded,
                onPressed: _resume,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PrimaryButton(
                label: l10n.recordFinish,
                icon: Icons.flag_rounded,
                onPressed: _finish,
              ),
            ),
          ],
        );
    }
  }

  // ── Formatting ────────────────────────────────────────────────────────────

  String _distanceText() {
    final v = _imperial ? _rec.distanceKm * _miPerKm : _rec.distanceKm;
    return v.toStringAsFixed(2);
  }

  String _timeText(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  String _paceText() {
    final secPerKm = _rec.paceSecPerKm;
    if (secPerKm == null) return '--:--';
    final secPerUnit = _imperial ? secPerKm / _miPerKm : secPerKm;
    final total = secPerUnit.round();
    final m = total ~/ 60;
    final s = total.remainder(60);
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// ─── Discipline toggle (Walk / Run) ──────────────────────────────────────────

class _DisciplineToggle extends StatelessWidget {
  const _DisciplineToggle({
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  final ActivityDiscipline selected;
  final bool enabled;
  final ValueChanged<ActivityDiscipline> onSelect;

  static const _options = [ActivityDiscipline.walk, ActivityDiscipline.run];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.stone100,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        children: _options.map((d) {
          final sel = d == selected;
          return Expanded(
            child: GestureDetector(
              onTap: enabled ? () => onSelect(d) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? AppColors.card : Colors.transparent,
                  borderRadius: AppRadius.pill,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(disciplineIcon(d),
                        size: 18,
                        color:
                            sel ? AppColors.forest700 : AppColors.stone500),
                    const SizedBox(width: 8),
                    Text(
                      disciplineLabel(l10n, d),
                      style: AppTextStyles.labelLarge.copyWith(
                        color:
                            sel ? AppColors.forest700 : AppColors.stone500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── GPS status pill ─────────────────────────────────────────────────────────

class _GpsStatusPill extends StatelessWidget {
  const _GpsStatusPill({required this.rec, required this.l10n});
  final GpsRecorder rec;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (String text, Color color, IconData icon) = switch (rec) {
      _ when !rec.hasFix => (
          l10n.recordAcquiring,
          AppColors.stone500,
          Icons.gps_not_fixed_rounded
        ),
      _ when !rec.gpsGood => (
          l10n.recordGpsWeak,
          AppColors.honey600,
          Icons.gps_not_fixed_rounded
        ),
      _ => (l10n.recordGpsReady, AppColors.forest600, Icons.gps_fixed_rounded),
    };
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: AppRadius.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(text,
                style: AppTextStyles.labelMedium.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Stat readouts ───────────────────────────────────────────────────────────

class _BigStat extends StatelessWidget {
  const _BigStat({required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label.toUpperCase(),
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.stone400, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: AppTextStyles.displayLarge
                      .copyWith(color: AppColors.forest700)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(unit,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.stone500)),
              ),
            ],
          ),
        ],
      );
}

class _MediumStat extends StatelessWidget {
  const _MediumStat({required this.label, required this.value, this.unit});
  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.stone100),
        ),
        child: Column(
          children: [
            Text(label.toUpperCase(),
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.stone400, letterSpacing: 1.1)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: AppTextStyles.displaySmall
                        .copyWith(color: AppColors.forest700)),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(unit!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone500)),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
}

// ─── Buttons ─────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton(
      {required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 54,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.forest600,
            disabledBackgroundColor: AppColors.stone200,
            textStyle: AppTextStyles.titleSmall,
          ),
        ),
      );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton(
      {required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 54,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.forest700,
            side: BorderSide(color: AppColors.forest600.withValues(alpha: .35)),
            textStyle: AppTextStyles.titleSmall,
          ),
        ),
      );
}

// ─── Permission-blocked state ────────────────────────────────────────────────

class _GateBlocked extends StatelessWidget {
  const _GateBlocked({required this.gate, required this.onRetry});
  final LocationGate gate;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool servicesOff = gate == LocationGate.serviceDisabled;
    final String title =
        servicesOff ? l10n.recordPermDeniedTitle : l10n.recordPermDeniedTitle;
    final String body =
        servicesOff ? l10n.recordServicesOffBody : l10n.recordPermDeniedBody;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded,
                size: 48, color: AppColors.stone400),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge
                    .copyWith(color: AppColors.forest700)),
            const SizedBox(height: 8),
            Text(body,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone600)),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () {
                if (servicesOff) {
                  Geolocator.openLocationSettings();
                } else if (gate == LocationGate.deniedForever) {
                  Geolocator.openAppSettings();
                } else {
                  onRetry();
                }
              },
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest600),
              child: Text(gate == LocationGate.denied
                  ? l10n.recordPrimingCta
                  : l10n.recordOpenSettings),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── First-run priming sheet ─────────────────────────────────────────────────

class _PrimingSheet extends StatelessWidget {
  const _PrimingSheet({
    required this.title,
    required this.body,
    required this.cta,
    required this.dismiss,
  });
  final String title;
  final String body;
  final String cta;
  final String dismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xxl,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Icon(Icons.my_location_rounded,
                  size: 40, color: AppColors.forest600),
              const SizedBox(height: 14),
              Text(title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.forest700)),
              const SizedBox(height: 10),
              Text(body,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.stone600)),
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest600),
                  child: Text(cta),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.stone500),
                child: Text(dismiss),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
