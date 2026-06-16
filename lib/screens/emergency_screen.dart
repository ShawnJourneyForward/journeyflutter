import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../components/back_button.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Breathing patterns ───────────────────────────────────────────────────

class _BreathPattern {
  const _BreathPattern(this.name, this.inhale, this.hold1, this.exhale,
      this.hold2, this.description, this.icon);
  final String name, description;
  final int inhale, hold1, exhale, hold2; // seconds
  final IconData icon;
}

List<_BreathPattern> _buildBreathPatterns(AppLocalizations l10n) => [
      _BreathPattern(l10n.breathPatternBoxName, 4, 4, 4, 4,
          l10n.breathPatternBoxDesc, Icons.crop_square_rounded),
      _BreathPattern(l10n.breathPattern478Name, 4, 7, 8, 0,
          l10n.breathPattern478Desc, Icons.nights_stay_outlined),
      _BreathPattern(l10n.breathPatternCalmName, 4, 2, 6, 0,
          l10n.breathPatternCalmDesc, Icons.air_outlined),
      _BreathPattern(l10n.breathPatternPowerName, 6, 0, 2, 0,
          l10n.breathPatternPowerDesc, Icons.bolt_rounded),
      _BreathPattern(l10n.breathPatternResetName, 3, 0, 6, 0,
          l10n.breathPatternResetDesc, Icons.refresh_rounded),
      _BreathPattern(l10n.breathPatternTriangleName, 4, 4, 4, 0,
          l10n.breathPatternTriangleDesc, Icons.change_history_rounded),
      _BreathPattern(l10n.breathPatternAnchorName, 5, 5, 5, 5,
          l10n.breathPatternAnchorDesc, Icons.anchor_outlined),
      _BreathPattern(l10n.breathPatternRescueName, 2, 0, 4, 0,
          l10n.breathPatternRescueDesc, Icons.air_rounded),
      _BreathPattern(l10n.breathPatternOceanName, 4, 0, 6, 2,
          l10n.breathPatternOceanDesc, Icons.waves_rounded),
      _BreathPattern(l10n.breathPatternMorningName, 4, 4, 6, 0,
          l10n.breathPatternMorningDesc, Icons.wb_sunny_outlined),
      _BreathPattern(l10n.breathPatternCoherentName, 5, 0, 5, 0,
          l10n.breathPatternCoherentDesc, Icons.monitor_heart_outlined),
      _BreathPattern(l10n.breathPattern628Name, 6, 2, 8, 0,
          l10n.breathPattern628Desc, Icons.self_improvement_outlined),
      _BreathPattern(l10n.breathPatternSquarePlusName, 5, 5, 5, 5,
          l10n.breathPatternSquarePlusDesc, Icons.dashboard_outlined),
      _BreathPattern(l10n.breathPatternWarriorName, 6, 0, 6, 0,
          l10n.breathPatternWarriorDesc, Icons.fitness_center_outlined),
      _BreathPattern(l10n.breathPatternNightName, 4, 7, 8, 0,
          l10n.breathPatternNightDesc, Icons.bedtime_outlined),
    ];

// ─── CBT guides ───────────────────────────────────────────────────────────

class _CbtGuide {
  const _CbtGuide(this.title, this.icon, this.steps);
  final String title;
  final IconData icon;
  final List<String> steps;
}

List<_CbtGuide> _buildCbtGuides(AppLocalizations l10n) => [
      _CbtGuide(l10n.cbtGuide0Title, Icons.psychology_outlined, [
        l10n.cbtGuide0Step0,
        l10n.cbtGuide0Step1,
        l10n.cbtGuide0Step2,
        l10n.cbtGuide0Step3,
        l10n.cbtGuide0Step4,
        l10n.cbtGuide0Step5,
      ]),
      _CbtGuide(l10n.cbtGuide1Title, Icons.waves_outlined, [
        l10n.cbtGuide1Step0,
        l10n.cbtGuide1Step1,
        l10n.cbtGuide1Step2,
        l10n.cbtGuide1Step3,
        l10n.cbtGuide1Step4,
      ]),
      _CbtGuide(l10n.cbtGuide2Title, Icons.balance_outlined, [
        l10n.cbtGuide2Step0,
        l10n.cbtGuide2Step1,
        l10n.cbtGuide2Step2,
        l10n.cbtGuide2Step3,
        l10n.cbtGuide2Step4,
      ]),
      _CbtGuide(l10n.cbtGuide3Title, Icons.map_outlined, [
        l10n.cbtGuide3Step0,
        l10n.cbtGuide3Step1,
        l10n.cbtGuide3Step2,
        l10n.cbtGuide3Step3,
        l10n.cbtGuide3Step4,
      ]),
      _CbtGuide(l10n.cbtGuide4Title, Icons.self_improvement_outlined, [
        l10n.cbtGuide4Step0,
        l10n.cbtGuide4Step1,
        l10n.cbtGuide4Step2,
        l10n.cbtGuide4Step3,
        l10n.cbtGuide4Step4,
      ]),
    ];

// ─── HALT states ─────────────────────────────────────────────────────────

List<(String, String, String, IconData)> _buildHaltItems(
        AppLocalizations l10n) =>
    [
      (
        l10n.haltH,
        l10n.haltHungry,
        l10n.haltHungryAdvice,
        Icons.restaurant_outlined
      ),
      (
        l10n.haltA,
        l10n.haltAngry,
        l10n.haltAngryAdvice,
        Icons.mood_bad_outlined
      ),
      (
        l10n.haltL,
        l10n.haltLonely,
        l10n.haltLonelyAdvice,
        Icons.people_outline_rounded
      ),
      (
        l10n.haltT,
        l10n.haltTired,
        l10n.haltTiredAdvice,
        Icons.bedtime_outlined
      ),
    ];

// ─── Mindfulness exercises ─────────────────────────────────────────────────

List<(String, String, IconData)> _buildMindfulExercises(
        AppLocalizations l10n) =>
    [
      (l10n.mindful0Title, l10n.mindful0Desc, Icons.visibility_outlined),
      (l10n.mindful1Title, l10n.mindful1Desc, Icons.air_outlined),
      (l10n.mindful2Title, l10n.mindful2Desc, Icons.accessibility_new_outlined),
      (l10n.mindful3Title, l10n.mindful3Desc, Icons.cloud_outlined),
      (l10n.mindful4Title, l10n.mindful4Desc, Icons.label_outline_rounded),
      (l10n.mindful5Title, l10n.mindful5Desc, Icons.anchor_outlined),
    ];

// ─── Emergency Screen ──────────────────────────────────────────────────────

enum _Tab {
  home,
  breathing,
  meditation,
  cbt,
  reasons,
  halt,
  playTape,
  mindfulness,
}

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  _Tab _tab = _Tab.home;

  void _go(_Tab t) => setState(() => _tab = t);
  void _home() => setState(() => _tab = _Tab.home);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(_tab),
                child: switch (_tab) {
                  _Tab.home => _HomeTab(onNav: _go),
                  _Tab.breathing => _BreathingTab(onBack: _home),
                  _Tab.meditation => _MeditationTab(onBack: _home),
                  _Tab.cbt => _CbtTab(onBack: _home),
                  _Tab.reasons => _ReasonsTab(onBack: _home),
                  _Tab.halt => _HaltTab(onBack: _home),
                  _Tab.playTape => _PlayTapeTab(onBack: _home, onNav: _go),
                  _Tab.mindfulness => _MindfulnessTab(onBack: _home),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Back header shared across tabs ───────────────────────────────────────

class _TabHeader extends StatelessWidget {
  const _TabHeader({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 20, 4),
        child: Row(
          children: [
            LuxuryBackButton(onPressed: onBack),
            Text(title,
                style: AppTextStyles.titleLarge
                    .copyWith(color: AppColors.forest700)),
          ],
        ),
      );
}

// ─── Tab 0: Home ──────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.onNav});
  final void Function(_Tab) onNav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(profileProvider).valueOrNull;
    final ec = profile?.emergencyContact;

    // Each tool either switches to an in-screen tab or pushes a route.
    final tools = <(IconData, String, Color, _Tab?, String?)>[
      (
        Icons.air_rounded,
        l10n.emergencyBreathingTitle,
        AppColors.forest400,
        _Tab.breathing,
        null
      ),
      (
        Icons.self_improvement_rounded,
        l10n.emergencyMeditationTitle,
        AppColors.stone400,
        _Tab.meditation,
        null
      ),
      (
        Icons.psychology_rounded,
        l10n.emergencyCBTTitle,
        AppColors.forest600,
        _Tab.cbt,
        null
      ),
      (
        Icons.spa_rounded,
        l10n.emergencyReasonsTitle,
        AppColors.forest600,
        _Tab.reasons,
        null
      ),
      (
        Icons.spa_outlined,
        l10n.emergencyHaltShortLabel,
        AppColors.honey500,
        _Tab.halt,
        null
      ),
      (
        Icons.timer_outlined,
        l10n.emergencyUrgeTimerTitle,
        AppColors.forest400,
        null,
        '/urge-timer'
      ),
      (
        Icons.play_circle_outline,
        l10n.emergencyPlayTapeTitle,
        AppColors.stone500,
        _Tab.playTape,
        null
      ),
      (
        Icons.spa_outlined,
        l10n.emergencyMindfulnessTitle,
        AppColors.forest400,
        _Tab.mindfulness,
        null
      ),
      (
        Icons.extension_outlined,
        l10n.emergencyPuzzleTitle,
        AppColors.stone400,
        null,
        '/puzzle'
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      children: [
        Text(l10n.emergencyToolkitHeading, style: AppTextStyles.greetingSerif),
        const SizedBox(height: 4),
        Text(l10n.emergencyToolkitSubheading, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 16),

        // Emergency call button
        if (ec != null) ...[
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('tel:${ec.phone}')),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: AppRadius.luxury,
              ),
              child: Row(
                children: [
                  Icon(Icons.phone_rounded,
                      color: AppColors.onForest, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.emergencyCallContact(ec.name),
                            style: AppTextStyles.titleMedium
                                .copyWith(color: AppColors.onForest)),
                        Text(ec.phone,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onForest.withOpacity(0.7))),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.onForest.withOpacity(0.7), size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Tool grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: tools.length,
          itemBuilder: (_, i) {
            final (icon, label, color, tab, route) = tools[i];
            return GestureDetector(
              onTap: () {
                H.light();
                if (tab != null) {
                  onNav(tab);
                } else if (route != null) {
                  context.push(route);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppRadius.luxury,
                  border: Border.all(color: AppColors.softBorder),
                  boxShadow: AppShadows.luxury,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 22, color: color),
                    ),
                    const SizedBox(height: 6),
                    Text(label,
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {
            H.light();
            context.push('/weekly-care-summary');
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadius.luxury,
              border: Border.all(color: AppColors.softBorder),
              boxShadow: AppShadows.luxury,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.mintChip,
                    borderRadius: AppRadius.md,
                  ),
                  child: Icon(Icons.article_outlined,
                      size: 22, color: AppColors.forest700),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.weeklySummaryTitle,
                          style: AppTextStyles.titleSmall),
                      Text(
                          l10n.emergencyWeeklyCareSummaryDesc,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.stone300),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tab 1: Breathing ─────────────────────────────────────────────────────

enum _BreathView { select, session, library }

class _BreathingTab extends StatefulWidget {
  const _BreathingTab({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_BreathingTab> createState() => _BreathingTabState();
}

class _BreathingTabState extends State<_BreathingTab>
    with TickerProviderStateMixin {
  late List<_BreathPattern> _patterns;

  // View routing
  _BreathView _view = _BreathView.select;

  // Pattern selection — default to Rescue (index 7)
  int _selectedIndex = 7;

  // Session state
  bool _paused = false;
  bool _sessionStarted = false; // true once user taps Start for the first time
  int _phaseIndex = 0;
  int _phaseRemaining = 0;
  int _totalSeconds = 0;
  static const _sessionDuration = 5 * 60; // 5 minutes

  Timer? _timer;

  late final AnimationController _circleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _patterns = _buildBreathPatterns(AppLocalizations.of(context));
  }

  _BreathPattern get _pattern => _patterns[_selectedIndex];

  // Phase records: (stable code for haptics/animation, localized label, seconds).
  // The code stays in English so the switch logic in [_phaseHaptic] and
  // [_animatePhase] is locale-independent; only [label] is shown to the user.
  List<(String, String, int)> get _phases {
    final p = _pattern;
    final l10n = AppLocalizations.of(context);
    return [
      ('Inhale', l10n.breathPhaseInhale, p.inhale),
      if (p.hold1 > 0) ('Hold', l10n.breathPhaseHold, p.hold1),
      ('Exhale', l10n.breathPhaseExhale, p.exhale),
      if (p.hold2 > 0) ('Hold', l10n.breathPhaseHold, p.hold2),
    ];
  }

  // ── Session control ──────────────────────────────────────────────────────

  /// Distinct haptic pattern per phase so the user can feel the rhythm
  /// without looking. Inhale = strong (heavy impact), Exhale = release
  /// (medium impact), Hold = soft tap (light impact). Respects the global
  /// haptics toggle automatically via [H].
  void _phaseHaptic(String phaseName) {
    switch (phaseName) {
      case 'Inhale':
        H.heavy();
        break;
      case 'Exhale':
        H.medium();
        break;
      case 'Hold':
        H.light();
        break;
    }
  }

  // Enter the session screen without starting the timer — user sees "Start".
  void _enterSession() {
    _timer?.cancel();
    _circleCtrl.stop();
    _circleCtrl.value = 0;
    _phaseIndex = 0;
    _phaseRemaining = _phases[0].$3;
    _totalSeconds = _sessionDuration;
    _paused = false;
    _sessionStarted = false;
    setState(() => _view = _BreathView.session);
  }

  // Called when the user taps "Start" — begin the actual countdown.
  void _beginSession() {
    _sessionStarted = true;
    _paused = false;
    _phaseHaptic(_phases[0].$1);
    _animatePhase();
    _scheduleTimer();
    setState(() {});
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _paused) return;
      _totalSeconds--;
      _phaseRemaining--;

      if (_totalSeconds <= 0) {
        H.heavy();
        _endSession();
        return;
      }

      if (_phaseRemaining <= 0) {
        final phases = _phases;
        _phaseIndex = (_phaseIndex + 1) % phases.length;
        _phaseRemaining = phases[_phaseIndex].$3;
        _phaseHaptic(phases[_phaseIndex].$1);
        _animatePhase();
      }

      setState(() {});
    });
  }

  void _animatePhase() {
    final phase = _phases[_phaseIndex];
    final dur = Duration(seconds: phase.$3);
    // Inhale → expand outward over the phase duration.
    // Exhale → contract inward over the phase duration.
    // Hold → freeze at the current expansion (hold1 freezes expanded,
    //        hold2 freezes contracted) so the visual matches the breath.
    if (phase.$1 == 'Inhale') {
      _circleCtrl.animateTo(1.0, duration: dur, curve: Curves.easeInOut);
    } else if (phase.$1 == 'Exhale') {
      _circleCtrl.animateTo(0.0, duration: dur, curve: Curves.easeInOut);
    } else {
      _circleCtrl.stop();
    }
  }

  void _pauseSession() {
    H.light();
    _timer?.cancel();
    _circleCtrl.stop();
    setState(() => _paused = true);
  }

  void _resumeSession() {
    H.light();
    setState(() => _paused = false);
    _animatePhase();
    _scheduleTimer();
  }

  void _endSession() {
    _timer?.cancel();
    _circleCtrl.stop();
    _circleCtrl.value = 0;
    setState(() {
      _paused = false;
      _sessionStarted = false;
      _view = _BreathView.select;
      _phaseIndex = 0;
      _phaseRemaining = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _circleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => switch (_view) {
        _BreathView.select => _buildSelectScreen(),
        _BreathView.session => _buildSessionScreen(),
        _BreathView.library => _buildLibraryScreen(),
      };

  // ── SELECT SCREEN ────────────────────────────────────────────────────────

  Widget _buildSelectScreen() {
    final l10n = AppLocalizations.of(context);
    // Featured indices in _buildBreathPatterns order:
    // 0=Box, 7=Rescue, 8=Ocean, 10=Coherent, 14=Night
    const rescueIdx = 7;
    const featuredGrid = [0, 14, 10, 8]; // Box, Night, Coherent, Ocean

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Transform.translate(
              offset: const Offset(-16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: LuxuryBackButton(onPressed: widget.onBack),
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.emergencyCalmToolkitOverline,
                style: AppTextStyles.overline),
            const SizedBox(height: 4),
            Text(l10n.breathChooseTitle,
                style: AppTextStyles.greetingSerif
                    .copyWith(fontSize: 32, color: AppColors.forestDark)),
            const SizedBox(height: 4),
            Text(l10n.breathChooseSubtitle,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone500)),
            const SizedBox(height: 20),
            // Recommended card
            _RecommendedCard(
              pattern: _patterns[rescueIdx],
              onBegin: () {
                setState(() => _selectedIndex = rescueIdx);
                _enterSession();
              },
            ),
            const SizedBox(height: 24),
            Text(l10n.breathLibraryTitle,
                style: AppTextStyles.displaySmall.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.forestDark)),
            const SizedBox(height: 12),
            // 2×2 grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: featuredGrid
                  .map((idx) => _LibraryCard(
                        pattern: _patterns[idx],
                        onTap: () {
                          setState(() => _selectedIndex = idx);
                          _enterSession();
                        },
                      ))
                  .toList(),
            ),
            // More link
            GestureDetector(
              onTap: () {
                H.light();
                setState(() => _view = _BreathView.library);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.breathMorePatterns,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.forest600)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.forest600),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── SESSION SCREEN ───────────────────────────────────────────────────────

  Widget _buildSessionScreen() {
    final l10n = AppLocalizations.of(context);
    final phases = _phases;
    final currentName = phases[_phaseIndex].$2;
    final mm = _totalSeconds ~/ 60;
    final ss = (_totalSeconds % 60).toString().padLeft(2, '0');
    final progress =
        ((_sessionDuration - _totalSeconds) / _sessionDuration).clamp(0.0, 1.0);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(-16, 0),
                    child: LuxuryBackButton(onPressed: _endSession),
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.emergencyCalmToolkitOverline,
                      style: AppTextStyles.overline),
                  const SizedBox(height: 4),
                  Text(l10n.breathSessionTitle,
                      style: AppTextStyles.greetingSerif
                          .copyWith(fontSize: 32, color: AppColors.forestDark)),
                  const SizedBox(height: 2),
                  Text(l10n.breathSessionSubtitle,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.stone500)),
                ],
              ),
            ),
            // Breathing ring
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _circleCtrl,
                  builder: (_, __) {
                    final t = _circleCtrl.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer halo
                        Container(
                          width: 240 + 60 * t,
                          height: 240 + 60 * t,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.forest400
                                .withOpacity(0.04 + 0.04 * t),
                          ),
                        ),
                        // Mid ring
                        Container(
                          width: 196 + 46 * t,
                          height: 196 + 46 * t,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.forest400
                                .withOpacity(0.07 + 0.06 * t),
                          ),
                        ),
                        // Inner ring with border
                        Container(
                          width: 158 + 34 * t,
                          height: 158 + 34 * t,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.forest200
                                .withOpacity(0.18 + 0.14 * t),
                            border: Border.all(
                              color: AppColors.forest300
                                  .withOpacity(0.25 + 0.18 * t),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Core — cream circle with phase info
                        Container(
                          width: 126,
                          height: 126,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.cream,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _sessionStarted
                                    ? currentName
                                    : l10n.breathReady,
                                style: AppTextStyles.titleSmall.copyWith(
                                    color: AppColors.forest700,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                _sessionStarted ? '$_phaseRemaining' : '·',
                                style: AppTextStyles.heroNumber.copyWith(
                                    fontSize: 40,
                                    color: AppColors.forestDark,
                                    height: 1.0),
                              ),
                              Text(_pattern.name,
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.stone500)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Phase pills
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: phases.asMap().entries.expand((e) {
                  final active = e.key == _phaseIndex;
                  final name = e.value.$2;
                  return [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            active ? AppColors.forest100 : Colors.transparent,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (active)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.forest600),
                            ),
                          Text(name,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: active
                                    ? AppColors.forest700
                                    : AppColors.stone400,
                                fontWeight:
                                    active ? FontWeight.w600 : FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                    if (e.key < phases.length - 1)
                      Text(' • ',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.stone300)),
                  ];
                }).toList(),
              ),
            ),
            // Session card
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppRadius.luxury,
                  border: Border.all(color: AppColors.softBorder),
                  boxShadow: AppShadows.luxury,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.eco_outlined,
                            size: 18, color: AppColors.forest300),
                        const Spacer(),
                        Column(
                          children: [
                            Text('$mm:$ss',
                                style: AppTextStyles.displaySmall.copyWith(
                                    fontSize: 28, color: AppColors.forestDark)),
                            Text(l10n.breathRemaining,
                                style: AppTextStyles.caption),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(width: 18),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: AppRadius.pill,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.forest100,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.forest500),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: !_sessionStarted
                                ? _beginSession
                                : _paused
                                    ? _resumeSession
                                    : _pauseSession,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.forest700,
                              minimumSize: const Size.fromHeight(48),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.xl),
                            ),
                            child: Text(!_sessionStarted
                                ? l10n.breathStart
                                : _paused
                                    ? l10n.breathResume
                                    : l10n.breathPause),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _endSession,
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: AppColors.forest300),
                              minimumSize: const Size.fromHeight(48),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.xl),
                            ),
                            child: Text(l10n.breathEndSession,
                                style: TextStyle(color: AppColors.forest700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Safety footer
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: Text(
                  l10n.breathDizzyWarning,
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.stone400),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── LIBRARY SCREEN ───────────────────────────────────────────────────────

  Widget _buildLibraryScreen() {
    final l10n = AppLocalizations.of(context);
    const featured = {0, 7, 8, 10, 14};
    final extra = _patterns
        .asMap()
        .entries
        .where((e) => !featured.contains(e.key))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(-16, 0),
                child: LuxuryBackButton(
                    onPressed: () =>
                        setState(() => _view = _BreathView.select)),
              ),
              const SizedBox(height: 4),
              Text(l10n.emergencyCalmToolkitOverline,
                  style: AppTextStyles.overline),
              const SizedBox(height: 4),
              Text(l10n.breathAllPatternsTitle,
                  style: AppTextStyles.greetingSerif
                      .copyWith(fontSize: 30, color: AppColors.forestDark)),
              const SizedBox(height: 4),
              Text(l10n.breathAllPatternsSubtitle,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.stone500)),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            itemCount: extra.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final idx = extra[i].key;
              final p = extra[i].value;
              return _PatternListTile(
                pattern: p,
                onTap: () {
                  setState(() => _selectedIndex = idx);
                  _enterSession();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Recommended Card ─────────────────────────────────────────────────────

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.pattern, required this.onBegin});
  final _BreathPattern pattern;
  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.luxury,
        border: Border.all(color: AppColors.softBorder),
        boxShadow: AppShadows.luxury,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.forest50, shape: BoxShape.circle),
                child: Icon(Icons.air_rounded,
                    size: 26, color: AppColors.forest600),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.breathRecommendedNow,
                        style: AppTextStyles.overline.copyWith(
                            color: AppColors.honey500, letterSpacing: 1.1)),
                    const SizedBox(height: 2),
                    Text(pattern.name,
                        style: AppTextStyles.displaySmall.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: AppColors.forestDark)),
                    const SizedBox(height: 2),
                    Text(pattern.description,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.stone100, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _RhythmChip(label: l10n.breathRhythmIn, value: pattern.inhale),
              if (pattern.hold1 > 0) ...[
                const SizedBox(width: 8),
                _RhythmChip(
                    label: l10n.breathRhythmHold, value: pattern.hold1),
              ],
              if (pattern.exhale > 0) ...[
                const SizedBox(width: 8),
                _RhythmChip(label: l10n.breathRhythmOut, value: pattern.exhale),
              ],
              if (pattern.hold2 > 0) ...[
                const SizedBox(width: 8),
                _RhythmChip(
                    label: l10n.breathRhythmHold, value: pattern.hold2),
              ],
              const Spacer(),
              SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: onBegin,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest700,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.xl),
                  ),
                  child: Text(l10n.breathBegin,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RhythmChip extends StatelessWidget {
  const _RhythmChip({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.stone50,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.stone100),
        ),
        child: Text('$label  $value',
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.forest700,
                fontWeight: FontWeight.w600,
                fontSize: 12)),
      );
}

// ─── Library Grid Card ────────────────────────────────────────────────────

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.pattern, required this.onTap});
  final _BreathPattern pattern;
  final VoidCallback onTap;

  String _rhythmLabel() {
    final p = pattern;
    final parts = <String>['${p.inhale}'];
    if (p.hold1 > 0) parts.add('${p.hold1}');
    if (p.exhale > 0) parts.add('${p.exhale}');
    if (p.hold2 > 0) parts.add('${p.hold2}');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final icon = pattern.icon;
    return GestureDetector(
      onTap: () {
        H.selection();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.luxury,
          border: Border.all(color: AppColors.softBorder),
          boxShadow: AppShadows.luxury,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: AppColors.forest50, shape: BoxShape.circle),
              child: Icon(icon, size: 24, color: AppColors.forest600),
            ),
            const SizedBox(height: 8),
            Text(pattern.name,
                style: AppTextStyles.displaySmall.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.forestDark)),
            const SizedBox(height: 4),
            // Expanded so the description takes remaining space and the
            // rhythm pill always anchors to the same bottom position across
            // all 4 tiles, regardless of how many lines the description uses.
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  pattern.description,
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Rhythm pill — FittedBox prevents wrapping on narrow phones.
            Container(
              height: 24,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.stone50,
                borderRadius: AppRadius.pill,
                border: Border.all(color: AppColors.stone100),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _rhythmLabel(),
                  maxLines: 1,
                  softWrap: false,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.forest600, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Library List Tile ────────────────────────────────────────────────────

class _PatternListTile extends StatelessWidget {
  const _PatternListTile({required this.pattern, required this.onTap});
  final _BreathPattern pattern;
  final VoidCallback onTap;

  String _rhythmLabel() {
    final p = pattern;
    final parts = <String>['${p.inhale}'];
    if (p.hold1 > 0) parts.add('${p.hold1}');
    if (p.exhale > 0) parts.add('${p.exhale}');
    if (p.hold2 > 0) parts.add('${p.hold2}');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          H.selection();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.lg,
            border: Border.all(color: AppColors.softBorder),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pattern.name,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.forestDark)),
                    const SizedBox(height: 2),
                    Text(pattern.description,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone500)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.stone50,
                  borderRadius: AppRadius.pill,
                  border: Border.all(color: AppColors.stone100),
                ),
                child: Text(_rhythmLabel(),
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.forest600,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.stone400),
            ],
          ),
        ),
      );
}

// ─── Tab 2: Meditation ────────────────────────────────────────────────────

class _MeditationGuide {
  const _MeditationGuide(this.title, this.duration, this.steps);
  final String title, duration;
  final List<String> steps;
}

List<_MeditationGuide> _buildMeditations(AppLocalizations l10n) => [
      _MeditationGuide(
          l10n.meditationUrgeSurfingTitle, l10n.meditationDuration10min, [
        l10n.meditationUrgeSurfingStep0,
        l10n.meditationUrgeSurfingStep1,
        l10n.meditationUrgeSurfingStep2,
        l10n.meditationUrgeSurfingStep3,
        l10n.meditationUrgeSurfingStep4,
        l10n.meditationUrgeSurfingStep5,
        l10n.meditationUrgeSurfingStep6,
      ]),
      _MeditationGuide(
          l10n.meditationBodyScanTitle, l10n.meditationDuration15min, [
        l10n.meditationBodyScanStep0,
        l10n.meditationBodyScanStep1,
        l10n.meditationBodyScanStep2,
        l10n.meditationBodyScanStep3,
        l10n.meditationBodyScanStep4,
        l10n.meditationBodyScanStep5,
        l10n.meditationBodyScanStep6,
      ]),
      _MeditationGuide(
          l10n.meditationGratitudeResetTitle, l10n.meditationDuration8min, [
        l10n.meditationGratitudeResetStep0,
        l10n.meditationGratitudeResetStep1,
        l10n.meditationGratitudeResetStep2,
        l10n.meditationGratitudeResetStep3,
        l10n.meditationGratitudeResetStep4,
        l10n.meditationGratitudeResetStep5,
        l10n.meditationGratitudeResetStep6,
      ]),
      _MeditationGuide(
          l10n.meditationSafePlaceTitle, l10n.meditationDuration10min, [
        l10n.meditationSafePlaceStep0,
        l10n.meditationSafePlaceStep1,
        l10n.meditationSafePlaceStep2,
        l10n.meditationSafePlaceStep3,
        l10n.meditationSafePlaceStep4,
        l10n.meditationSafePlaceStep5,
        l10n.meditationSafePlaceStep6,
      ]),
      _MeditationGuide(
          l10n.meditationSelfCompassionTitle, l10n.meditationDuration12min, [
        l10n.meditationSelfCompassionStep0,
        l10n.meditationSelfCompassionStep1,
        l10n.meditationSelfCompassionStep2,
        l10n.meditationSelfCompassionStep3,
        l10n.meditationSelfCompassionStep4,
        l10n.meditationSelfCompassionStep5,
        l10n.meditationSelfCompassionStep6,
      ]),
    ];

class _MeditationTab extends StatefulWidget {
  const _MeditationTab({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_MeditationTab> createState() => _MeditationTabState();
}

class _MeditationTabState extends State<_MeditationTab>
    with TickerProviderStateMixin {
  int _selected = 0;
  int _step = 0;

  // ── Urge Surfing audio player ──────────────────────────────────────────────
  final _player = AudioPlayer();
  bool _audioReady = false;
  bool _audioError = false;

  // Pulse animation for the waveform rings when playing
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final Animation<double> _pulse = Tween<double>(begin: 0.85, end: 1.15)
      .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _initAudio();
    _player.playingStream.listen((playing) {
      if (!mounted) return;
      if (playing) {
        _pulseCtrl.repeat(reverse: true);
      } else {
        _pulseCtrl.stop();
        _pulseCtrl.animateTo(0);
      }
    });
  }

  Future<void> _initAudio() async {
    try {
      await _player.setAsset('assets/audio/urge_surfing.mp3');
      if (mounted) setState(() => _audioReady = true);
    } catch (_) {
      if (mounted) setState(() => _audioError = true);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  String _formatDur(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meditations = _buildMeditations(l10n);
    final guide = meditations[_selected];
    return Column(
      children: [
        _TabHeader(title: l10n.emergencyMeditationTitle, onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              // ── Urge Surfing audio card ────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.forest900, Color(0xFF1A3D2B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.xl,
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: AppColors.honey400.withOpacity(0.35),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: AppColors.honey400.withOpacity(0.18),
                            borderRadius: AppRadius.pill,
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: AppColors.honey400.withOpacity(0.45),
                            ),
                          ),
                          child: Text(l10n.meditationGuidedAudioLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.honey300,
                                letterSpacing: 1.2,
                                fontSize: 10,
                              )),
                        ),
                        const Spacer(),
                        StreamBuilder<Duration>(
                          stream: _player.durationStream
                              .where((d) => d != null)
                              .map((d) => d!),
                          builder: (_, snap) {
                            final total = snap.data ?? Duration.zero;
                            return Text(
                              _formatDur(total),
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.stone400, fontSize: 11),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(l10n.meditationUrgeSurfingTitle,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontFamily: 'Fraunces',
                          height: 1.1,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      l10n.meditationUrgeSurfingTagline,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone400),
                    ),

                    const SizedBox(height: 20),

                    // Waveform rings + play button
                    Center(
                      child: ScaleTransition(
                        scale: _pulse,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ring
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  // ignore: deprecated_member_use
                                  color: AppColors.honey400.withOpacity(0.18),
                                  width: 12,
                                ),
                              ),
                            ),
                            // Play/pause button
                            GestureDetector(
                              onTap: _audioReady
                                  ? () async {
                                      H.medium();
                                      if (_player.playing) {
                                        await _player.pause();
                                      } else {
                                        // If at end, restart from beginning
                                        if ((_player.position) >=
                                            (_player.duration ??
                                                Duration.zero)) {
                                          await _player.seek(Duration.zero);
                                        }
                                        await _player.play();
                                      }
                                    }
                                  : null,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.honey400,
                                  shape: BoxShape.circle,
                                ),
                                child: _audioError
                                    ? const Icon(Icons.error_outline,
                                        color: Colors.white, size: 22)
                                    : !_audioReady
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2),
                                          )
                                        : StreamBuilder<bool>(
                                            stream: _player.playingStream,
                                            builder: (_, snap) {
                                              final playing =
                                                  snap.data ?? false;
                                              return Icon(
                                                playing
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              );
                                            },
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress bar + time
                    StreamBuilder<Duration>(
                      stream: _player.positionStream,
                      builder: (_, snap) {
                        final pos = snap.data ?? Duration.zero;
                        final total = _player.duration ?? Duration.zero;
                        final frac = total.inMilliseconds > 0
                            ? (pos.inMilliseconds / total.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0;
                        return Column(
                          children: [
                            GestureDetector(
                              onHorizontalDragUpdate: _audioReady
                                  ? (d) {
                                      final box = context.findRenderObject()
                                          as RenderBox?;
                                      if (box == null) return;
                                      final w = box.size.width - 40;
                                      final dx = (d.localPosition.dx / w)
                                          .clamp(0.0, 1.0);
                                      final seekMs =
                                          (dx * total.inMilliseconds).round();
                                      _player
                                          .seek(Duration(milliseconds: seekMs));
                                    }
                                  : null,
                              child: ClipRRect(
                                borderRadius: AppRadius.pill,
                                child: LinearProgressIndicator(
                                  value: frac,
                                  minHeight: 4,
                                  backgroundColor:
                                      // ignore: deprecated_member_use
                                      Colors.white.withOpacity(0.12),
                                  valueColor: AlwaysStoppedAnimation(
                                      AppColors.honey400),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDur(pos),
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.stone500,
                                        fontSize: 10)),
                                Text(_formatDur(total),
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.stone500,
                                        fontSize: 10)),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    // What is urge surfing?
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: AppRadius.md,
                      ),
                      child: Text(
                        l10n.meditationUrgeSurfingExplainer,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.stone400,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Divider ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Expanded(child: Divider(color: AppColors.stone100)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l10n.meditationGuidedScripts,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.stone400)),
                  ),
                  Expanded(child: Divider(color: AppColors.stone100)),
                ]),
              ),

              const SizedBox(height: 8),

              // ── Text meditation guides ─────────────────────────────────────
              ...List.generate(meditations.length, (i) {
                final g = meditations[i];
                final selected = i == _selected;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selected = i;
                    _step = 0;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.forest50 : AppColors.card,
                      borderRadius: AppRadius.lg,
                      border: Border.all(
                        color:
                            selected ? AppColors.forest600 : AppColors.stone100,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.title,
                                  style: AppTextStyles.titleSmall.copyWith(
                                      color: selected
                                          ? AppColors.forest700
                                          : AppColors.stone800)),
                              Text(g.duration, style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: selected
                              ? AppColors.forest600
                              : AppColors.stone300,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 14),

              // Step viewer
              SolidCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(guide.title, style: AppTextStyles.titleMedium),
                        Text('${_step + 1} / ${guide.steps.length}',
                            style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: AppRadius.pill,
                      child: LinearProgressIndicator(
                        value: (_step + 1) / guide.steps.length,
                        minHeight: 4,
                        backgroundColor: AppColors.stone100,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.forest600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(guide.steps[_step],
                        style: AppTextStyles.bodySerif.copyWith(
                            color: AppColors.forest700,
                            fontStyle: FontStyle.italic)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (_step > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _step--),
                              child: Text(l10n.commonBack),
                            ),
                          ),
                        if (_step > 0) const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: _step < guide.steps.length - 1
                                ? () => setState(() => _step++)
                                : null,
                            style: FilledButton.styleFrom(
                                backgroundColor: AppColors.forest600),
                            child: Text(_step < guide.steps.length - 1
                                ? l10n.commonNext
                                : l10n.emergencyComplete),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tab 3: CBT Guides ────────────────────────────────────────────────────

class _CbtTab extends StatefulWidget {
  const _CbtTab({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_CbtTab> createState() => _CbtTabState();
}

class _CbtTabState extends State<_CbtTab> {
  int? _active;
  int _step = 0;
  final _inputCtrl = TextEditingController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cbtGuides = _buildCbtGuides(l10n);
    return Column(
      children: [
        _TabHeader(title: l10n.emergencyCBTTitle, onBack: widget.onBack),
        Expanded(
          child: _active == null
              ? _GuideList(
                  onSelect: (i) => setState(() {
                        _active = i;
                        _step = 0;
                        _inputCtrl.clear();
                      }))
              : _GuideWalkthrough(
                  guide: cbtGuides[_active!],
                  step: _step,
                  ctrl: _inputCtrl,
                  onNext: _step < cbtGuides[_active!].steps.length - 1
                      ? () => setState(() {
                            _step++;
                            _inputCtrl.clear();
                          })
                      : null,
                  onBack: _step > 0
                      ? () => setState(() {
                            _step--;
                            _inputCtrl.clear();
                          })
                      : null,
                  onClose: () => setState(() => _active = null),
                ),
        ),
      ],
    );
  }
}

class _GuideList extends StatelessWidget {
  const _GuideList({required this.onSelect});
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final guides = _buildCbtGuides(l10n);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: guides.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final g = guides[i];
        return GestureDetector(
          onTap: () {
            H.light();
            onSelect(i);
          },
          child: SolidCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.forest50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(g.icon, size: 20, color: AppColors.forest600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.title, style: AppTextStyles.titleSmall),
                      Text(l10n.cbtGuideStepCount(g.steps.length),
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.stone300),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GuideWalkthrough extends StatelessWidget {
  const _GuideWalkthrough({
    required this.guide,
    required this.step,
    required this.ctrl,
    required this.onNext,
    required this.onBack,
    required this.onClose,
  });
  final _CbtGuide guide;
  final int step;
  final TextEditingController ctrl;
  final VoidCallback? onNext, onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
                child: Text(guide.title, style: AppTextStyles.titleMedium)),
            TextButton(onPressed: onClose, child: Text(l10n.emergencyCloseGuide)),
          ],
        ),
        ClipRRect(
          borderRadius: AppRadius.pill,
          child: LinearProgressIndicator(
            value: (step + 1) / guide.steps.length,
            minHeight: 6,
            backgroundColor: AppColors.stone100,
            valueColor: AlwaysStoppedAnimation(AppColors.forest600),
          ),
        ),
        const SizedBox(height: 4),
        Text(l10n.onbStepIndicator(step + 1, guide.steps.length),
            style: AppTextStyles.caption),
        const SizedBox(height: 16),
        ForestCard(
          child: Text(guide.steps[step],
              style:
                  AppTextStyles.bodySerif.copyWith(color: AppColors.forest700)),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.cbtGuideThoughtsHint,
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
          ),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            if (onBack != null) ...[
              Expanded(
                child: OutlinedButton(
                    onPressed: onBack, child: Text(l10n.commonBack)),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: FilledButton(
                onPressed: onNext ?? onClose,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest600),
                child: Text(onNext != null ? l10n.commonNext : l10n.emergencyComplete),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Tab 4: My Reasons ────────────────────────────────────────────────────

class _ReasonsTab extends ConsumerStatefulWidget {
  const _ReasonsTab({required this.onBack});
  final VoidCallback onBack;

  @override
  ConsumerState<_ReasonsTab> createState() => _ReasonsTabState();
}

class _ReasonsTabState extends ConsumerState<_ReasonsTab> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(profileProvider).valueOrNull;
    // myReasons is the canonical field; fall back to weeklyGoals for users who
    // saved reasons before the field was renamed.
    final reasons = (profile?.myReasons.isNotEmpty == true)
        ? profile!.myReasons
        : (profile?.weeklyGoals ?? []);

    return Column(
      children: [
        _TabHeader(title: l10n.emergencyReasonsTitle, onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(l10n.reasonsWhyHeading,
                  style: AppTextStyles.bodySerif.copyWith(
                      color: AppColors.forest600, fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
              if (reasons.isEmpty)
                ForestCard(
                  child: Text(
                    l10n.reasonsEmptyHint,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.forest700),
                  ),
                )
              else
                ...reasons.asMap().entries.map((entry) {
                  final i = entry.key;
                  final r = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.forest50,
                      borderRadius: AppRadius.lg,
                      border: Border.all(color: AppColors.forest100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.forest600,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            r,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.forest700),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tab 5: H.A.L.T. ─────────────────────────────────────────────────────

class _HaltTab extends StatefulWidget {
  const _HaltTab({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_HaltTab> createState() => _HaltTabState();
}

class _HaltTabState extends State<_HaltTab> {
  final Set<int> _checked = {};
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final haltItems = _buildHaltItems(l10n);
    return Column(
      children: [
        _TabHeader(title: l10n.emergencyHALTTitle, onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(l10n.haltCheckInPrompt,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.stone600)),
              const SizedBox(height: 16),
              ...haltItems.asMap().entries.map((e) {
                final i = e.key;
                final (letter, label, tip, icon) = e.value;
                final checked = _checked.contains(i);
                final expanded = _expanded == i;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        H.selection();
                        setState(() => _expanded = expanded ? null : i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: checked ? AppColors.honey50 : AppColors.card,
                          borderRadius: AppRadius.lg,
                          border: Border.all(
                            color: checked
                                ? AppColors.honey500
                                : AppColors.stone100,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: checked
                                        ? AppColors.honey500
                                        : AppColors.stone50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(letter,
                                        style: AppTextStyles.titleLarge
                                            .copyWith(
                                                color: checked
                                                    ? Colors.white
                                                    : AppColors.stone600)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(label,
                                      style: AppTextStyles.titleSmall),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    H.selection();
                                    setState(() => checked
                                        ? _checked.remove(i)
                                        : _checked.add(i));
                                  },
                                  child: Icon(
                                    checked
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: checked
                                        ? AppColors.honey500
                                        : AppColors.stone300,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                            if (expanded) ...[
                              const SizedBox(height: 10),
                              Text(tip,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.stone600)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tab 7: Play the Tape ─────────────────────────────────────────────────

class _PlayTapeTab extends StatelessWidget {
  const _PlayTapeTab({required this.onBack, required this.onNav});
  final VoidCallback onBack;
  final void Function(_Tab) onNav;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _TabHeader(title: l10n.emergencyPlayTapeTitle, onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              // ── Hero heading
              Text(
                l10n.playTapeHeroHeading,
                style: AppTextStyles.greetingSerif
                    .copyWith(color: AppColors.forest800, fontSize: 26),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.playTapeIntro,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone600),
              ),
              const SizedBox(height: 20),

              // ── "If I drink now" card
              _TapeCard(
                title: l10n.playTapeDrinkTitle,
                titleColor: AppColors.honey500,
                bgColor: AppColors.honey50,
                borderColor: AppColors.honey200,
                arrowUp: false,
                rows: [
                  _TapeRow(
                    icon: Icons.access_time_rounded,
                    label: l10n.playTapePhaseRightNow,
                    bullets: [
                      l10n.playTapeDrinkNow0,
                      l10n.playTapeDrinkNow1,
                    ],
                  ),
                  _TapeRow(
                    icon: Icons.nightlight_round,
                    label: l10n.playTapePhaseTonight,
                    bullets: [
                      l10n.playTapeDrinkTonight0,
                      l10n.playTapeDrinkTonight1,
                      l10n.playTapeDrinkTonight2,
                    ],
                  ),
                  _TapeRow(
                    icon: Icons.wb_twilight_rounded,
                    label: l10n.playTapePhaseTomorrow,
                    bullets: [
                      l10n.playTapeDrinkTomorrow0,
                      l10n.playTapeDrinkTomorrow1,
                      l10n.playTapeDrinkTomorrow2,
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── "If I stay sober" card
              _TapeCard(
                title: l10n.playTapeSoberTitle,
                titleColor: AppColors.forest700,
                bgColor: AppColors.forest50,
                borderColor: AppColors.forest200,
                arrowUp: true,
                rows: [
                  _TapeRow(
                    icon: Icons.access_time_rounded,
                    label: l10n.playTapePhaseRightNow,
                    bullets: [
                      l10n.playTapeSoberNow0,
                      l10n.playTapeSoberNow1,
                    ],
                  ),
                  _TapeRow(
                    icon: Icons.nightlight_round,
                    label: l10n.playTapePhaseTonight,
                    bullets: [
                      l10n.playTapeSoberTonight0,
                      l10n.playTapeSoberTonight1,
                      l10n.playTapeSoberTonight2,
                    ],
                  ),
                  _TapeRow(
                    icon: Icons.wb_twilight_rounded,
                    label: l10n.playTapePhaseTomorrow,
                    bullets: [
                      l10n.playTapeSoberTomorrow0,
                      l10n.playTapeSoberTomorrow1,
                      l10n.playTapeSoberTomorrow2,
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── "What would help right now?" card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppRadius.luxury,
                  border: Border.all(color: AppColors.softBorder),
                  boxShadow: AppShadows.luxury,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.forest100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.spa_outlined,
                              size: 16, color: AppColors.forest700),
                        ),
                        const SizedBox(width: 10),
                        Text(l10n.playTapeWhatHelpsTitle,
                            style: AppTextStyles.titleSmall
                                .copyWith(color: AppColors.forest700)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _ActionButton(
                          icon: Icons.air_rounded,
                          label: l10n.playTapeActionBreathe,
                          onTap: () => onNav(_Tab.breathing),
                        ),
                        const SizedBox(width: 10),
                        _ActionButton(
                          icon: Icons.menu_book_rounded,
                          label: l10n.playTapeActionJournal,
                          onTap: () => context.push('/journal'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _ActionButton(
                          icon: Icons.spa_rounded,
                          label: l10n.playTapeActionReason,
                          onTap: () => onNav(_Tab.reasons),
                        ),
                        const SizedBox(width: 10),
                        _ActionButton(
                          icon: Icons.timer_outlined,
                          label: l10n.playTapeActionRideWave,
                          onTap: () => context.push('/urge-timer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── _TapeRow data class ──────────────────────────────────────────────────

class _TapeRow {
  const _TapeRow({
    required this.icon,
    required this.label,
    required this.bullets,
  });
  final IconData icon;
  final String label;
  final List<String> bullets;
}

// ─── _TapeCard ────────────────────────────────────────────────────────────

class _TapeCard extends StatelessWidget {
  const _TapeCard({
    required this.title,
    required this.titleColor,
    required this.bgColor,
    required this.borderColor,
    required this.arrowUp,
    required this.rows,
  });
  final String title;
  final Color titleColor, bgColor, borderColor;
  final bool arrowUp;
  final List<_TapeRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.luxury,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: titleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    arrowUp
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                      color: titleColor,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          // ── Timeline rows
          ...rows.asMap().entries.map((e) {
            final row = e.value;
            final isLast = e.key == rows.length - 1;
            return Column(
              children: [
                const Divider(
                    height: 1, thickness: 1, color: Color(0x1A000000)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon circle
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: Icon(row.icon, size: 16, color: titleColor),
                      ),
                      const SizedBox(width: 12),
                      // Label + bullets
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(row.label,
                                style: AppTextStyles.labelLarge
                                    .copyWith(color: AppColors.stone800)),
                            const SizedBox(height: 4),
                            ...row.bullets.map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('• ',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                  color: AppColors.stone500)),
                                      Expanded(
                                        child: Text(b,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                    color: AppColors.stone600,
                                                    height: 1.4)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLast) const SizedBox(height: 2),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── _ActionButton ────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: () {
            H.light();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.stone50,
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.softBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: AppColors.forest600),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone700),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      );
}

// ─── Tab 8: Mindfulness ───────────────────────────────────────────────────

class _MindfulnessTab extends StatefulWidget {
  const _MindfulnessTab({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_MindfulnessTab> createState() => _MindfulnessTabState();
}

class _MindfulnessTabState extends State<_MindfulnessTab> {
  int? _active;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mindfulExercises = _buildMindfulExercises(l10n);
    return Column(
      children: [
        _TabHeader(
            title: l10n.emergencyMindfulnessTitle, onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (_active == null) ...[
                ...mindfulExercises.asMap().entries.map((e) {
                  final (name, desc, icon) = e.value;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _active = e.key;
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppRadius.xxl,
                        border: Border.all(color: AppColors.softBorder),
                        boxShadow: AppShadows.luxury,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.forest50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon,
                                size: 20, color: AppColors.forest600),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: AppTextStyles.titleSmall),
                                Text(desc,
                                    style: AppTextStyles.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.stone300),
                        ],
                      ),
                    ),
                  );
                }),
              ] else ...[
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _active = null;
                      }),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 14),
                      label: Text(l10n.commonBack),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.forest600),
                    ),
                  ],
                ),
                ForestCard(
                  child: Text(
                    mindfulExercises[_active!].$2,
                    style: AppTextStyles.bodySerif.copyWith(
                        color: AppColors.forest700,
                        fontStyle: FontStyle.italic,
                        height: 1.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
