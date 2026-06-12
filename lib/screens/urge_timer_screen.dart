import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/back_button.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Urge Timer Screen ────────────────────────────────────────────────────────
// "Ride the wave": a calm countdown for sitting with an urge until it passes.
// Reachable while the app is locked (see LockGate) — it exposes no private
// data beyond the lifetime win count. Every recorded ride is a win: tapping
// "I'm steady now" early still counts, because the urge passed sooner.

const _rideDuration = Duration(minutes: 10);

class UrgeTimerScreen extends ConsumerStatefulWidget {
  const UrgeTimerScreen({super.key});

  @override
  ConsumerState<UrgeTimerScreen> createState() => _UrgeTimerScreenState();
}

class _UrgeTimerScreenState extends ConsumerState<UrgeTimerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);

  Timer? _ticker;
  Duration _remaining = _rideDuration;
  bool _finished = false;
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 1) {
        _finish();
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _breath.dispose();
    super.dispose();
  }

  int get _elapsedSeconds => _rideDuration.inSeconds - _remaining.inSeconds;

  Future<void> _finish() async {
    if (_recorded) return;
    _recorded = true;
    _ticker?.cancel();
    H.heavy();
    await ref.read(urgeRideProvider.notifier).record(_elapsedSeconds);
    if (!mounted) return;
    setState(() => _finished = true);
  }

  String _phaseText(AppLocalizations l10n) {
    final fraction = _elapsedSeconds / _rideDuration.inSeconds;
    if (fraction < 1 / 3) return l10n.urgeTimerPhaseRising;
    if (fraction < 2 / 3) return l10n.urgeTimerPhaseCresting;
    return l10n.urgeTimerPhaseFalling;
  }

  String get _clock {
    final m = _remaining.inMinutes;
    final s = _remaining.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wins = ref.watch(urgeRideProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 24, 0),
              child: Row(
                children: [
                  LuxuryBackButton(color: AppColors.forest700),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(l10n.urgeTimerTitle,
                        style: AppTextStyles.greetingSerif),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _finished ? _buildFinished(l10n, wins) : _buildRiding(l10n, wins),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiding(AppLocalizations l10n, int wins) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
      child: Column(
        children: [
          Text(l10n.urgeTimerSubtitle,
              textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
          const Spacer(),

          // ── Breathing wave circle ────────────────────────────────────────
          AnimatedBuilder(
            animation: _breath,
            builder: (_, child) {
              final t = Curves.easeInOut.transform(_breath.value);
              return Transform.scale(scale: 1.0 + 0.12 * t, child: child);
            },
            child: Container(
              width: 210,
              height: 210,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.forest50,
                border: Border.all(color: AppColors.forest400, width: 2),
              ),
              child: Text(_clock, style: AppTextStyles.heroNumber),
            ),
          ),
          const SizedBox(height: 28),
          Text(_phaseText(l10n),
              textAlign: TextAlign.center, style: AppTextStyles.bodySerif),
          const Spacer(),

          // ── Actions ──────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _finish,
              child: Text(l10n.urgeTimerImSteady),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('/pre-craving-plan'),
            child: Text(l10n.urgeTimerOpenPlan),
          ),
          if (wins > 0) ...[
            const SizedBox(height: 8),
            Text(l10n.urgeTimerWins(wins), style: AppTextStyles.labelMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildFinished(AppLocalizations l10n, int wins) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.waves_rounded, color: AppColors.forest600, size: 56),
          const SizedBox(height: 18),
          Text(l10n.urgeTimerCompleteTitle,
              textAlign: TextAlign.center, style: AppTextStyles.headlineSerif),
          const SizedBox(height: 10),
          Text(l10n.urgeTimerCompleteBody,
              textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 10),
          Text(l10n.urgeTimerWins(wins), style: AppTextStyles.labelMedium),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              // Deep-linked from the SOS widget there is nothing to pop —
              // fall through to Home instead of a dead button.
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/home'),
              child: Text(l10n.urgeTimerDone),
            ),
          ),
        ],
      ),
    );
  }
}
