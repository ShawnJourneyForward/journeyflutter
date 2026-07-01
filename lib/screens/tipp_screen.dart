import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── TIPP — DBT fast-reset crisis-survival skills ─────────────────────────────
//
// Temperature · Intense movement · Paced breathing · Paired muscle relaxation.
// When distress spikes past the point of clear thinking, these four shift body
// chemistry in minutes. This screen is a pure guide — it reads and writes no
// user data, which is also why it's safe to allow while the app is locked
// (see LockGate in main.dart). One skill is expanded at a time; paced breathing
// carries a live animated pacer, the others an optional 30-second timer.

enum _Skill { temperature, intense, paced, pmr }

class TippScreen extends StatefulWidget {
  const TippScreen({super.key});

  @override
  State<TippScreen> createState() => _TippScreenState();
}

class _TippScreenState extends State<TippScreen>
    with SingleTickerProviderStateMixin {
  // Paced-breathing pacer: 4s in · 4s hold · 6s out = 14s cycle. Longer exhale
  // is what actually engages the parasympathetic ("calming") response.
  static const _inhale = 4, _hold = 4, _exhale = 6;
  static const _cycle = _inhale + _hold + _exhale; // 14s

  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: _cycle),
  )..repeat();

  _Skill? _expanded;

  // Optional countdown shared by the non-breathing skills.
  Timer? _countdown;
  int _countdownLeft = 0;
  _Skill? _countdownFor;

  @override
  void dispose() {
    _countdown?.cancel();
    _breath.dispose();
    super.dispose();
  }

  void _toggle(_Skill s) {
    H.selection();
    setState(() {
      if (_expanded == s) {
        _expanded = null;
      } else {
        _expanded = s;
      }
      // Collapsing a card cancels its timer.
      if (_countdownFor != null && _countdownFor != _expanded) {
        _stopCountdown();
      }
    });
  }

  void _startCountdown(_Skill s) {
    H.medium();
    _countdown?.cancel();
    setState(() {
      _countdownFor = s;
      _countdownLeft = 30;
    });
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdownLeft <= 1) {
        H.heavy();
        _stopCountdown();
      } else {
        setState(() => _countdownLeft -= 1);
      }
    });
  }

  void _stopCountdown() {
    _countdown?.cancel();
    _countdown = null;
    if (mounted) {
      setState(() {
        _countdownFor = null;
        _countdownLeft = 0;
      });
    } else {
      _countdownFor = null;
      _countdownLeft = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  LuxuryBackButton(color: AppColors.forest700),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(l10n.tippTitle,
                        style: AppTextStyles.greetingSerif),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  // ── Intro ─────────────────────────────────────────────────
                  LuxuryCard(
                    backgroundColor: AppColors.forest800,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: AppColors.forest300, size: 26),
                        const SizedBox(height: 12),
                        Text(l10n.tippIntroTitle,
                            style: AppTextStyles.headlineSerif
                                .copyWith(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 8),
                        Text(l10n.tippIntro,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.forest200, height: 1.55)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  _SkillCard(
                    skill: _Skill.temperature,
                    icon: Icons.ac_unit_rounded,
                    color: AppColors.forest500,
                    label: l10n.tippTempLabel,
                    why: l10n.tippTempWhy,
                    expanded: _expanded == _Skill.temperature,
                    onTap: () => _toggle(_Skill.temperature),
                    steps: [
                      l10n.tippTempStep1,
                      l10n.tippTempStep2,
                      l10n.tippTempStep3,
                    ],
                    caution: l10n.tippTempCaution,
                    countdownChild: _countdownButton(_Skill.temperature, l10n),
                  ),
                  const SizedBox(height: 10),

                  _SkillCard(
                    skill: _Skill.intense,
                    icon: Icons.directions_run_rounded,
                    color: AppColors.forest600,
                    label: l10n.tippIntenseLabel,
                    why: l10n.tippIntenseWhy,
                    expanded: _expanded == _Skill.intense,
                    onTap: () => _toggle(_Skill.intense),
                    steps: [
                      l10n.tippIntenseStep1,
                      l10n.tippIntenseStep2,
                      l10n.tippIntenseStep3,
                    ],
                    caution: l10n.tippIntenseCaution,
                    countdownChild: _countdownButton(_Skill.intense, l10n),
                  ),
                  const SizedBox(height: 10),

                  _SkillCard(
                    skill: _Skill.paced,
                    icon: Icons.air_rounded,
                    color: AppColors.forest400,
                    label: l10n.tippPacedLabel,
                    why: l10n.tippPacedWhy,
                    expanded: _expanded == _Skill.paced,
                    onTap: () => _toggle(_Skill.paced),
                    customBody: _PacedBreathing(
                      controller: _breath,
                      inhale: _inhale,
                      hold: _hold,
                      exhale: _exhale,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _SkillCard(
                    skill: _Skill.pmr,
                    icon: Icons.self_improvement_rounded,
                    color: AppColors.forest500,
                    label: l10n.tippPmrLabel,
                    why: l10n.tippPmrWhy,
                    expanded: _expanded == _Skill.pmr,
                    onTap: () => _toggle(_Skill.pmr),
                    steps: [
                      l10n.tippPmrStep1,
                      l10n.tippPmrStep2,
                      l10n.tippPmrStep3,
                    ],
                    countdownChild: _countdownButton(_Skill.pmr, l10n),
                  ),
                  const SizedBox(height: 20),

                  // ── Crisis fallback ───────────────────────────────────────
                  LuxuryCard(
                    backgroundColor: AppColors.stone100,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(Icons.support_agent_rounded,
                            size: 22, color: AppColors.stone500),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(l10n.tippNeedMore,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.stone700)),
                        ),
                        TextButton(
                          onPressed: () => context.push('/crisis'),
                          child: Text(l10n.tippCrisisButton,
                              style: AppTextStyles.labelLarge
                                  .copyWith(color: AppColors.forest600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countdownButton(_Skill s, AppLocalizations l10n) {
    final running = _countdownFor == s;
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () => running ? _stopCountdown() : _startCountdown(s),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 40),
          foregroundColor: AppColors.forest600,
          side: BorderSide(color: AppColors.forest200, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: Icon(running ? Icons.stop_rounded : Icons.timer_outlined,
            size: 18),
        label: Text(running
            ? l10n.tippTimerRemaining(_countdownLeft)
            : l10n.tippStartTimer),
      ),
    );
  }
}

// ─── Skill card ───────────────────────────────────────────────────────────────

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.skill,
    required this.icon,
    required this.color,
    required this.label,
    required this.why,
    required this.expanded,
    required this.onTap,
    this.steps,
    this.countdownChild,
    this.customBody,
    this.caution,
  });

  final _Skill skill;
  final IconData icon;
  final Color color;
  final String label;
  final String why;
  final bool expanded;
  final VoidCallback onTap;
  final List<String>? steps;
  final Widget? countdownChild;
  final Widget? customBody;

  /// Optional medical safety caveat shown at the top of the expanded body —
  /// the cold-water diving reflex and all-out exertion are contraindicated in
  /// cardiac conditions, pregnancy and eating disorders, all common in this
  /// audience. Non-alarming, but always visible before the steps.
  final String? caution;

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      padding: EdgeInsets.zero,
      borderColor: expanded ? AppColors.forest200 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: AppRadius.luxury,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 22, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: AppTextStyles.titleSmall),
                        const SizedBox(height: 2),
                        Text(why,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.stone500, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.stone400),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: AppColors.stone100, height: 18),
                        if (caution != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.honey50,
                              borderRadius: AppRadius.md,
                              border: Border.all(color: AppColors.honey200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: 18, color: AppColors.honey600),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(caution!,
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.stone700,
                                          height: 1.4)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (customBody != null) customBody!,
                        if (steps != null)
                          for (var i = 0; i < steps!.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: i == steps!.length - 1 ? 0 : 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.forest50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text('${i + 1}',
                                        style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.forest700)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(steps![i],
                                        style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.stone700,
                                            height: 1.45)),
                                  ),
                                ],
                              ),
                            ),
                        if (countdownChild != null) ...[
                          const SizedBox(height: 14),
                          countdownChild!,
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Paced breathing pacer ────────────────────────────────────────────────────
//
// One repeating controller drives the whole 14-second cycle. The value maps to
// inhale → hold → exhale by fraction of the cycle; the circle scales up on the
// in-breath, holds, then eases down on the (longer) out-breath.

class _PacedBreathing extends StatelessWidget {
  const _PacedBreathing({
    required this.controller,
    required this.inhale,
    required this.hold,
    required this.exhale,
  });

  final AnimationController controller;
  final int inhale, hold, exhale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = inhale + hold + exhale;
    final inEnd = inhale / total;
    final holdEnd = (inhale + hold) / total;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Center(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final v = controller.value;
                double scale;
                String phase;
                if (v < inEnd) {
                  // inhale: 0.7 → 1.1
                  final t = Curves.easeInOut.transform(v / inEnd);
                  scale = 0.7 + 0.4 * t;
                  phase = l10n.tippBreatheIn;
                } else if (v < holdEnd) {
                  scale = 1.1;
                  phase = l10n.tippHold;
                } else {
                  // exhale: 1.1 → 0.7
                  final t = Curves.easeInOut
                      .transform((v - holdEnd) / (1 - holdEnd));
                  scale = 1.1 - 0.4 * t;
                  phase = l10n.tippBreatheOut;
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.forest50,
                          border: Border.all(
                              color: AppColors.forest400, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(phase,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.forest700)),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.tippPacedHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.stone500, height: 1.4)),
        const SizedBox(height: 4),
      ],
    );
  }
}
