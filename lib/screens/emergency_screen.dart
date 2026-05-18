import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

// ─── Breathing patterns ───────────────────────────────────────────────────

class _BreathPattern {
  const _BreathPattern(this.name, this.inhale, this.hold1, this.exhale,
      this.hold2, this.description);
  final String name, description;
  final int inhale, hold1, exhale, hold2; // seconds
}

List<_BreathPattern> _buildBreathPatterns(AppLocalizations l10n) => [
  _BreathPattern(l10n.breathPatternBoxName,        4, 4, 4, 4, l10n.breathPatternBoxDesc),
  _BreathPattern(l10n.breathPattern478Name,        4, 7, 8, 0, l10n.breathPattern478Desc),
  _BreathPattern(l10n.breathPatternCalmName,       4, 2, 6, 0, l10n.breathPatternCalmDesc),
  _BreathPattern(l10n.breathPatternPowerName,      6, 0, 2, 0, l10n.breathPatternPowerDesc),
  _BreathPattern(l10n.breathPatternResetName,      3, 0, 6, 0, l10n.breathPatternResetDesc),
  _BreathPattern(l10n.breathPatternTriangleName,   4, 4, 4, 0, l10n.breathPatternTriangleDesc),
  _BreathPattern(l10n.breathPatternAnchorName,     5, 5, 5, 5, l10n.breathPatternAnchorDesc),
  _BreathPattern(l10n.breathPatternRescueName,     2, 0, 4, 0, l10n.breathPatternRescueDesc),
  _BreathPattern(l10n.breathPatternOceanName,      4, 0, 6, 2, l10n.breathPatternOceanDesc),
  _BreathPattern(l10n.breathPatternMorningName,    4, 4, 6, 0, l10n.breathPatternMorningDesc),
  _BreathPattern(l10n.breathPatternCoherentName,   5, 0, 5, 0, l10n.breathPatternCoherentDesc),
  _BreathPattern(l10n.breathPattern628Name,        6, 2, 8, 0, l10n.breathPattern628Desc),
  _BreathPattern(l10n.breathPatternSquarePlusName, 5, 5, 5, 5, l10n.breathPatternSquarePlusDesc),
  _BreathPattern(l10n.breathPatternWarriorName,    6, 0, 6, 0, l10n.breathPatternWarriorDesc),
  _BreathPattern(l10n.breathPatternNightName,      4, 7, 8, 0, l10n.breathPatternNightDesc),
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

List<(String, String, String, IconData)> _buildHaltItems(AppLocalizations l10n) => [
  (l10n.haltH, l10n.haltHungry, l10n.haltHungryAdvice, Icons.restaurant_outlined),
  (l10n.haltA, l10n.haltAngry,  l10n.haltAngryAdvice,  Icons.mood_bad_outlined),
  (l10n.haltL, l10n.haltLonely, l10n.haltLonelyAdvice, Icons.people_outline_rounded),
  (l10n.haltT, l10n.haltTired,  l10n.haltTiredAdvice,  Icons.bedtime_outlined),
];

// ─── Mindfulness exercises ─────────────────────────────────────────────────

List<(String, String, IconData)> _buildMindfulExercises(AppLocalizations l10n) => [
  (l10n.mindful0Title, l10n.mindful0Desc, Icons.visibility_outlined),
  (l10n.mindful1Title, l10n.mindful1Desc, Icons.air_outlined),
  (l10n.mindful2Title, l10n.mindful2Desc, Icons.accessibility_new_outlined),
  (l10n.mindful3Title, l10n.mindful3Desc, Icons.cloud_outlined),
  (l10n.mindful4Title, l10n.mindful4Desc, Icons.label_outline_rounded),
  (l10n.mindful5Title, l10n.mindful5Desc, Icons.anchor_outlined),
];

// ─── Emergency Screen ──────────────────────────────────────────────────────

enum _Tab {
  home, breathing, meditation, cbt, reasons, halt, urgeTimer,
  playTape, mindfulness,
}

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  _Tab _tab = _Tab.home;

  void _go(_Tab t) => setState(() => _tab = t);
  void _home()     => setState(() => _tab = _Tab.home);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -6,
              right: -18,
              child: IgnorePointer(
                child: BotanicalBackground(width: 150, height: 92),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(_tab),
                child: switch (_tab) {
                  _Tab.home        => _HomeTab(onNav: _go),
                  _Tab.breathing   => _BreathingTab(onBack: _home),
                  _Tab.meditation  => _MeditationTab(onBack: _home),
                  _Tab.cbt         => _CbtTab(onBack: _home),
                  _Tab.reasons     => _ReasonsTab(onBack: _home),
                  _Tab.halt        => _HaltTab(onBack: _home),
                  _Tab.urgeTimer   => _UrgeTimerTab(onBack: _home),
                  _Tab.playTape    => _PlayTapeTab(onBack: _home),
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
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.stone600),
          onPressed: onBack,
        ),
        Text(title, style: AppTextStyles.titleLarge
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
    final profile = ref.watch(profileProvider).valueOrNull;
    final ec = profile?.emergencyContact;

    final tools = [
      (Icons.air_rounded,          'Breathing',   AppColors.forest400,  _Tab.breathing),
      (Icons.self_improvement_rounded,'Meditation',AppColors.stone400,   _Tab.meditation),
      (Icons.psychology_rounded,   'CBT Guides',  AppColors.forest600,  _Tab.cbt),
      (Icons.favorite_rounded,     'My Reasons',  AppColors.forest600,  _Tab.reasons),
      (Icons.favorite_border_rounded,'H.A.L.T.',    AppColors.honey500,   _Tab.halt),
      (Icons.timer_outlined,       'Urge Timer',  AppColors.forest400,  _Tab.urgeTimer),
      (Icons.play_circle_outline,  'Play the Tape',AppColors.stone500,  _Tab.playTape),
      (Icons.spa_outlined,         'Mindfulness', AppColors.forest400,  _Tab.mindfulness),
      (Icons.extension_outlined,   'Puzzle',      AppColors.stone400,   null),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      children: [
        Text('Calm Toolkit', style: AppTextStyles.greetingSerif),
        const SizedBox(height: 4),
        Text('Choose the gentlest next step.', style: AppTextStyles.bodyLarge),
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
                  const Icon(Icons.phone_rounded,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Call ${ec.name}',
                            style: AppTextStyles.titleMedium
                                .copyWith(color: Colors.white)),
                        Text(ec.phone,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70, size: 16),
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
            final (icon, label, color, tab) = tools[i];
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (tab != null) onNav(tab);
                else context.push('/puzzle');
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
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 22, color: color),
                    ),
                    const SizedBox(height: 6),
                    Text(label, style: AppTextStyles.caption,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          },
        ),

        // Quiet slip note — intentionally unobtrusive
        const SizedBox(height: 28),
        GestureDetector(
          onTap: () => _showSlipNote(context, ref),
          child: Center(
            child: Text(
              'Need a softer reset?',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.stone300,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.stone300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Slip note helpers ────────────────────────────────────────────────────────

Future<void> _showSlipNote(BuildContext context, WidgetRef ref) async {
  final ctrl = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => _SlipNoteDialog(controller: ctrl),
  );

  final note = ctrl.text.trim();
  ctrl.dispose();

  if (confirmed != true) return;
  final profile = ref.read(profileProvider).valueOrNull;
  if (profile == null) return;

  await ref.read(slipProvider.notifier).record(
    current: profile,
    note: note.isEmpty ? null : note,
  );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Noted. Every day is a new beginning.',
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      ),
      backgroundColor: AppColors.stone700,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    ));
  }
}

class _SlipNoteDialog extends StatelessWidget {
  const _SlipNoteDialog({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
      title: Text('A note to yourself', style: AppTextStyles.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Slips are part of many journeys. '
            'This is just information — not a verdict.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.stone500, height: 1.5),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'A thought for yourself, if you\'d like…',
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.stone300),
              filled: true,
              fillColor: AppColors.stone50,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide: const BorderSide(color: AppColors.stone100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide: const BorderSide(color: AppColors.stone100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide: const BorderSide(
                    color: AppColors.forest600, width: 1.5),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Not now',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.stone400)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Note it and continue',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.forest600)),
        ),
      ],
    );
  }
}

// ─── Tab 1: Breathing ─────────────────────────────────────────────────────

class _BreathingTab extends StatefulWidget {
  const _BreathingTab({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_BreathingTab> createState() => _BreathingTabState();
}

class _BreathingTabState extends State<_BreathingTab>
    with TickerProviderStateMixin {

  int _selectedIndex = 0;
  bool _running = false;
  String _phase = 'Inhale';
  int _phaseSeconds = 0;
  int _totalSeconds = 0;
  int _durationMinutes = 5;
  Timer? _timer;
  late List<_BreathPattern> _patterns;

  late final AnimationController _circleCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 1));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _patterns = _buildBreathPatterns(AppLocalizations.of(context));
  }

  _BreathPattern get _pattern => _patterns[_selectedIndex];

  List<(String, int)> get _phases {
    final p = _pattern;
    return [
      ('Inhale', p.inhale),
      if (p.hold1 > 0) ('Hold', p.hold1),
      ('Exhale', p.exhale),
      if (p.hold2 > 0) ('Hold', p.hold2),
    ];
  }

  int _phaseIndex = 0;
  int _phaseRemaining = 0;

  void _start() {
    final phases = _phases;
    _phaseIndex = 0;
    _phaseRemaining = phases[0].$2;
    _totalSeconds = _durationMinutes * 60;
    _phase = phases[0].$1;

    setState(() { _running = true; _phaseSeconds = _phaseRemaining; });
    _animatePhase();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _totalSeconds--;
      _phaseRemaining--;

      if (_totalSeconds <= 0) { _stop(); return; }

      if (_phaseRemaining <= 0) {
        _phaseIndex = (_phaseIndex + 1) % phases.length;
        _phaseRemaining = phases[_phaseIndex].$2;
        _animatePhase();
      }

      setState(() {
        _phase = phases[_phaseIndex].$1;
        _phaseSeconds = _phaseRemaining;
      });
    });
  }

  void _animatePhase() {
    final phase = _phases[_phaseIndex];
    _circleCtrl.duration = Duration(seconds: phase.$2);
    if (phase.$1 == 'Inhale') {
      _circleCtrl.forward(from: 0);
    } else if (phase.$1 == 'Exhale') {
      _circleCtrl.reverse(from: 1);
    }
  }

  void _stop() {
    _timer?.cancel();
    _circleCtrl.stop();
    setState(() { _running = false; _phase = 'Inhale'; _phaseSeconds = 0; });
  }

  @override
  void dispose() { _timer?.cancel(); _circleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TabHeader(title: 'Breathing', onBack: widget.onBack),
        // Pattern selector
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _patterns.length,
            itemBuilder: (_, i) {
              final selected = i == _selectedIndex;
              return GestureDetector(
                onTap: _running ? null : () =>
                    setState(() => _selectedIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.forest600 : Colors.white,
                    borderRadius: AppRadius.pill,
                    border: Border.all(
                      color: selected
                          ? AppColors.forest600 : AppColors.stone100,
                    ),
                  ),
                  child: Text(_patterns[i].name,
                      style: AppTextStyles.labelLarge.copyWith(
                          color: selected
                              ? Colors.white : AppColors.stone600,
                          fontSize: 12)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(_pattern.description,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center),

        // Breathing circle
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: _circleCtrl,
              builder: (_, __) {
                final scale = 0.6 + _circleCtrl.value * 0.4;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 220 * scale, height: 220 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.forest600.withOpacity(0.08),
                      ),
                    ),
                    Container(
                      width: 160 * scale, height: 160 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.forest600.withOpacity(0.15),
                      ),
                    ),
                    Container(
                      width: 110, height: 110,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.forest600,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_running ? _phase : 'Ready',
                              style: AppTextStyles.titleSmall
                                  .copyWith(color: Colors.white)),
                          if (_running)
                            Text('$_phaseSeconds',
                                style: AppTextStyles.displaySmall
                                    .copyWith(color: Colors.white,
                                        fontSize: 26)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Duration + controls
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            children: [
              if (!_running) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Duration: '),
                    DropdownButton<int>(
                      value: _durationMinutes,
                      items: [1,2,3,5,10].map((m) =>
                          DropdownMenuItem(value: m,
                              child: Text('$m min'))).toList(),
                      onChanged: (v) =>
                          setState(() => _durationMinutes = v ?? 5),
                      underline: const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ] else ...[
                Text(
                  '${_totalSeconds ~/ 60}:${(_totalSeconds % 60).toString().padLeft(2,'0')} remaining',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _running ? _stop : _start,
                  style: FilledButton.styleFrom(
                    backgroundColor: _running
                        ? AppColors.honey500 : AppColors.forest600,
                    minimumSize: const Size.fromHeight(50),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.xl),
                  ),
                  child: Text(_running ? 'Stop' : 'Start'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tab 2: Meditation ────────────────────────────────────────────────────

class _MeditationGuide {
  const _MeditationGuide(this.title, this.duration, this.steps);
  final String title, duration;
  final List<String> steps;
}

const _meditations = [
  _MeditationGuide('Urge Surfing', '10 min', [
    'Close your eyes and take three slow breaths.',
    'Notice the craving. Where do you feel it in your body?',
    'Imagine it as a wave in the ocean — rising slowly.',
    'You are a surfer. You don\'t fight the wave. You ride it.',
    'Watch the wave peak. It cannot go higher than it already is.',
    'Now watch it begin to fall. Urges always fade.',
    'You did not drink. The wave passed. You surfed it.',
  ]),
  _MeditationGuide('Body Scan', '15 min', [
    'Lie down or sit comfortably. Close your eyes.',
    'Bring attention to your feet. Notice any sensation — warmth, tingling.',
    'Slowly move up to your calves, then knees, then thighs.',
    'Notice your belly rising and falling with each breath.',
    'Scan your chest, shoulders, arms, and hands.',
    'Finally, relax your jaw, eyes, and forehead.',
    'Rest here for a moment. You are safe. You are whole.',
  ]),
  _MeditationGuide('Gratitude Reset', '8 min', [
    'Sit quietly. Take three slow breaths.',
    'Think of one person in your life you\'re grateful for.',
    'What did they do or say that mattered to you?',
    'Think of one moment from today, however small, that was good.',
    'Think of something about your body or health you appreciate.',
    'Let gratitude fill your chest like warmth.',
    'Carry this feeling into your next hour.',
  ]),
  _MeditationGuide('Safe Place', '10 min', [
    'Close your eyes. Take three slow, deep breaths.',
    'Imagine a place where you feel completely safe.',
    'It can be real or imagined — a beach, a forest, a room.',
    'Notice what you see, hear, smell in this place.',
    'Feel the ground beneath you. You are supported.',
    'Breathe here for a while. Nothing can harm you.',
    'When you\'re ready, slowly return, carrying this calm.',
  ]),
  _MeditationGuide('Self-Compassion', '12 min', [
    'Place your hand on your heart. Feel its warmth.',
    'Say: "This is a moment of difficulty."',
    'Say: "Difficulty is part of life. I am not alone in this."',
    'Say: "May I be kind to myself right now."',
    'Think of something you\'ve been critical of yourself about.',
    'Ask: what would I say to a dear friend in this situation?',
    'Say those words to yourself. You deserve them too.',
  ]),
];

class _MeditationTab extends StatefulWidget {
  const _MeditationTab({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_MeditationTab> createState() => _MeditationTabState();
}

class _MeditationTabState extends State<_MeditationTab> {
  int _selected = 0;
  int _step = 0;

  _MeditationGuide get _guide => _meditations[_selected];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TabHeader(title: 'Meditation', onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              // Guide selector
              ...List.generate(_meditations.length, (i) {
                final g = _meditations[i];
                final selected = i == _selected;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selected = i; _step = 0;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.forest50 : Colors.white,
                      borderRadius: AppRadius.lg,
                      border: Border.all(
                        color: selected
                            ? AppColors.forest600 : AppColors.stone100,
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
                              Text(g.duration,
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: selected
                              ? AppColors.forest600 : AppColors.stone300,
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
                        Text(_guide.title,
                            style: AppTextStyles.titleMedium),
                        Text('${_step + 1} / ${_guide.steps.length}',
                            style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: AppRadius.pill,
                      child: LinearProgressIndicator(
                        value: (_step + 1) / _guide.steps.length,
                        minHeight: 4,
                        backgroundColor: AppColors.stone100,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.forest600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_guide.steps[_step],
                        style: AppTextStyles.bodySerif
                            .copyWith(color: AppColors.forest700,
                                fontStyle: FontStyle.italic)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (_step > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _step--),
                              child: const Text('Back'),
                            ),
                          ),
                        if (_step > 0) const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: _step < _guide.steps.length - 1
                                ? () => setState(() => _step++)
                                : null,
                            style: FilledButton.styleFrom(
                                backgroundColor: AppColors.forest600),
                            child: Text(_step < _guide.steps.length - 1
                                ? 'Next' : 'Complete ✓'),
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
  void dispose() { _inputCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cbtGuides = _buildCbtGuides(l10n);
    return Column(
      children: [
        _TabHeader(title: l10n.emergencyCBTTitle, onBack: widget.onBack),
        Expanded(
          child: _active == null
              ? _GuideList(onSelect: (i) =>
                  setState(() { _active = i; _step = 0; _inputCtrl.clear(); }))
              : _GuideWalkthrough(
                  guide: cbtGuides[_active!],
                  step: _step,
                  ctrl: _inputCtrl,
                  onNext: _step < cbtGuides[_active!].steps.length - 1
                      ? () => setState(() { _step++; _inputCtrl.clear(); })
                      : null,
                  onBack: _step > 0
                      ? () => setState(() { _step--; _inputCtrl.clear(); })
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
    final guides = _buildCbtGuides(AppLocalizations.of(context));
    return ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
    itemCount: guides.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (_, i) {
      final g = guides[i];
      return GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onSelect(i); },
        child: SolidCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.forest50, shape: BoxShape.circle,
                ),
                child: Icon(g.icon, size: 20, color: AppColors.forest600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.title, style: AppTextStyles.titleSmall),
                    Text('${g.steps.length} steps',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
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
    required this.guide, required this.step, required this.ctrl,
    required this.onNext, required this.onBack, required this.onClose,
  });
  final _CbtGuide guide;
  final int step;
  final TextEditingController ctrl;
  final VoidCallback? onNext, onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          children: [
            Expanded(child: Text(guide.title,
                style: AppTextStyles.titleMedium)),
            TextButton(onPressed: onClose,
                child: const Text('✕ Close')),
          ],
        ),
        ClipRRect(
          borderRadius: AppRadius.pill,
          child: LinearProgressIndicator(
            value: (step + 1) / guide.steps.length,
            minHeight: 6,
            backgroundColor: AppColors.stone100,
            valueColor: const AlwaysStoppedAnimation(AppColors.forest600),
          ),
        ),
        const SizedBox(height: 4),
        Text('Step ${step + 1} of ${guide.steps.length}',
            style: AppTextStyles.caption),
        const SizedBox(height: 16),
        ForestCard(
          child: Text(guide.steps[step],
              style: AppTextStyles.bodySerif
                  .copyWith(color: AppColors.forest700)),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Your thoughts…',
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.stone400),
          ),
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.stone800),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            if (onBack != null) ...[
              Expanded(
                child: OutlinedButton(
                    onPressed: onBack,
                    child: const Text('Back')),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: FilledButton(
                onPressed: onNext ?? onClose,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest600),
                child: Text(onNext != null ? 'Next' : 'Complete ✓'),
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
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final reasons = profile?.weeklyGoals ?? []; // reuse weeklyGoals as reasons for now

    return Column(
      children: [
        _TabHeader(title: 'My Reasons', onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text('Why I\'m doing this.',
                  style: AppTextStyles.bodySerif
                      .copyWith(color: AppColors.forest600,
                          fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
              if (reasons.isEmpty)
                ForestCard(
                  child: Text(
                    'Add your reasons in Settings → My Motivation. '
                    'Reading them during a craving can be powerful.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.forest700),
                  ),
                )
              else
                ...reasons.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.forest50,
                    borderRadius: AppRadius.lg,
                    border: Border.all(color: AppColors.forest100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded,
                          size: 16, color: AppColors.forest600),
                      const SizedBox(width: 10),
                      Expanded(child: Text(r,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.forest700))),
                    ],
                  ),
                )),
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
              Text('Before acting on a craving, check in:',
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
                        HapticFeedback.selectionClick();
                        setState(() =>
                            _expanded = expanded ? null : i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: checked
                              ? AppColors.honey50 : Colors.white,
                          borderRadius: AppRadius.lg,
                          border: Border.all(
                            color: checked
                                ? AppColors.honey500 : AppColors.stone100,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
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
                                    HapticFeedback.selectionClick();
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
                              Text(tip, style: AppTextStyles.bodySmall
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

// ─── Tab 6: Urge Timer ────────────────────────────────────────────────────

class _UrgeTimerTab extends StatefulWidget {
  const _UrgeTimerTab({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_UrgeTimerTab> createState() => _UrgeTimerTabState();
}

class _UrgeTimerTabState extends State<_UrgeTimerTab> {
  static const _totalSeconds = 15 * 60;
  int _remaining = _totalSeconds;
  bool _running = false;
  bool _done = false;
  Timer? _timer;

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _timer?.cancel();
          _running = false;
          _done = true;
          HapticFeedback.mediumImpact();
        }
      });
    });
    setState(() { _running = true; _done = false; });
  }

  void _pause() { _timer?.cancel(); setState(() => _running = false); }
  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false; _done = false; _remaining = _totalSeconds;
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  String get _timeStr {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  double get _progress => 1 - (_remaining / _totalSeconds);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TabHeader(title: 'Urge Timer', onBack: widget.onBack),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _done
                      ? 'You did it! 🎉'
                      : 'Cravings peak and pass.\nThis one will too.',
                  style: AppTextStyles.bodySerif
                      .copyWith(color: AppColors.forest700,
                          fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Circular progress
                SizedBox(
                  width: 200, height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200, height: 200,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 10,
                          backgroundColor: AppColors.stone100,
                          valueColor: AlwaysStoppedAnimation(
                              _done ? AppColors.honey500
                                  : AppColors.forest600),
                        ),
                      ),
                      Text(_done ? '✓' : _timeStr,
                          style: AppTextStyles.displayMedium
                              .copyWith(
                              color: _done
                                  ? AppColors.honey500
                                  : AppColors.forest700)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                if (!_done) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _running ? _pause : _start,
                          child: Text(_running ? 'Pause' : 'Start'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: _reset,
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.stone400),
                          child: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  FilledButton(
                    onPressed: _reset,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.forest600),
                    child: const Text('Start Again'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tab 7: Play the Tape ─────────────────────────────────────────────────

class _PlayTapeTab extends StatelessWidget {
  const _PlayTapeTab({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TabHeader(title: 'Play the Tape', onBack: onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              children: [
                Text(
                  'Before you act, play the full tape forward.',
                  style: AppTextStyles.bodySerif
                      .copyWith(color: AppColors.forest600,
                          fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _TapeColumn(
                      label: 'If I drink',
                      color: AppColors.honey500,
                      icon: Icons.arrow_downward_rounded,
                      items: const [
                        'Relief lasts 20–60 minutes',
                        'The difficult feelings return',
                        'Sleep is disrupted',
                        'Tomorrow is harder',
                        'I interrupt my momentum',
                        'The next day asks more of me',
                      ],
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _TapeColumn(
                      label: 'If I stay sober',
                      color: AppColors.forest600,
                      icon: Icons.arrow_upward_rounded,
                      items: const [
                        'The craving passes in 20 min',
                        'I wake up clear-headed',
                        'My momentum grows',
                        'I build self-trust',
                        'Tomorrow is better',
                        'I am proud of myself',
                      ],
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TapeColumn extends StatelessWidget {
  const _TapeColumn({
    required this.label, required this.color,
    required this.icon, required this.items,
  });
  final String label;
  final Color color;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: AppRadius.xl,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.titleSmall
                  .copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('• $t', style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.stone700, height: 1.5)),
          )),
        ],
      ),
    );
  }
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
        _TabHeader(title: l10n.emergencyMindfulnessTitle, onBack: widget.onBack),
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
                            width: 40, height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.forest50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 20,
                                color: AppColors.forest600),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: AppTextStyles.titleSmall),
                                Text(desc,
                                    style: AppTextStyles.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
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
                      onPressed: () =>
                          setState(() { _active = null; }),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 14),
                      label: const Text('Back'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.forest600),
                    ),
                  ],
                ),
                ForestCard(
                  child: Text(
                    mindfulExercises[_active!].$2,
                    style: AppTextStyles.bodySerif
                        .copyWith(color: AppColors.forest700,
                            fontStyle: FontStyle.italic, height: 1.8),
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
