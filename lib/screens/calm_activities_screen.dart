import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Calm Activities ──────────────────────────────────────────────────────────
// The gentle, mindfulness-flavoured exercises that used to live (confusingly)
// inside the "Puzzle" tile. Split out into their own Toolkit tile so the Puzzle
// tile can be actual games. The Memory Match game stayed behind in
// puzzle_screen.dart. All l10n keys are unchanged (puzzleActivity0/1/3/4/5 + the
// per-activity detail keys) — only the home/host moved.

enum _Activity {
  home,
  countdown,
  gratitudeShuffle,
  strengthCompass,
  nowMoment,
  colorCalm,
}

class _ActivityDef {
  _ActivityDef({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.duration,
  });
  final _Activity id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final String duration;
}

List<_ActivityDef> _buildActivities(AppLocalizations l10n) => [
      _ActivityDef(
        id: _Activity.countdown,
        label: l10n.puzzleActivity0Label,
        description: l10n.puzzleActivity0Desc,
        icon: Icons.pin_outlined,
        color: AppColors.forest600,
        duration: l10n.puzzleActivity0Duration,
      ),
      _ActivityDef(
        id: _Activity.gratitudeShuffle,
        label: l10n.puzzleActivity1Label,
        description: l10n.puzzleActivity1Desc,
        icon: Icons.shuffle_rounded,
        color: AppColors.honey500,
        duration: l10n.puzzleActivity1Duration,
      ),
      _ActivityDef(
        id: _Activity.strengthCompass,
        label: l10n.puzzleActivity3Label,
        description: l10n.puzzleActivity3Desc,
        icon: Icons.explore_outlined,
        color: AppColors.forest700,
        duration: l10n.puzzleActivity3Duration,
      ),
      _ActivityDef(
        id: _Activity.nowMoment,
        label: l10n.puzzleActivity4Label,
        description: l10n.puzzleActivity4Desc,
        icon: Icons.center_focus_strong_outlined,
        color: AppColors.honey600,
        duration: l10n.puzzleActivity4Duration,
      ),
      _ActivityDef(
        id: _Activity.colorCalm,
        label: l10n.puzzleActivity5Label,
        description: l10n.puzzleActivity5Desc,
        icon: Icons.circle_outlined,
        color: AppColors.forest400,
        duration: l10n.puzzleActivity5Duration,
      ),
    ];

// ─── Screen ───────────────────────────────────────────────────────────────────

class CalmActivitiesScreen extends StatefulWidget {
  const CalmActivitiesScreen({super.key});

  @override
  State<CalmActivitiesScreen> createState() => _CalmActivitiesScreenState();
}

class _CalmActivitiesScreenState extends State<CalmActivitiesScreen> {
  _Activity _current = _Activity.home;

  void _go(_Activity a) => setState(() => _current = a);
  void _home() => setState(() => _current = _Activity.home);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: KeyedSubtree(
            key: ValueKey(_current),
            child: switch (_current) {
              _Activity.home => _HomeView(onSelect: _go),
              _Activity.countdown => _CountdownView(onBack: _home),
              _Activity.gratitudeShuffle =>
                _GratitudeShuffleView(onBack: _home),
              _Activity.strengthCompass => _StrengthCompassView(onBack: _home),
              _Activity.nowMoment => _NowMomentView(onBack: _home),
              _Activity.colorCalm => _ColorCalmView(onBack: _home),
            },
          ),
        ),
      ),
    );
  }
}

// ─── Shared back header ───────────────────────────────────────────────────────

class _BackHeader extends StatelessWidget {
  const _BackHeader({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 20, 4),
        child: Row(children: [
          LuxuryBackButton(onPressed: onBack),
          Text(title,
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.forest700)),
        ]),
      );
}

// ─── Home view ────────────────────────────────────────────────────────────────

class _HomeView extends StatelessWidget {
  const _HomeView({required this.onSelect});
  final void Function(_Activity) onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activities = _buildActivities(l10n);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(-12, 12, 0, 0),
          child: Row(children: [
            const LuxuryBackButton(),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.puzzleHomeTitle,
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.forest700)),
                  Text(l10n.puzzleHomeSubtitle,
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: activities.length,
          itemBuilder: (_, i) {
            final a = activities[i];
            return GestureDetector(
              onTap: () {
                H.light();
                onSelect(a.id);
              },
              child: SolidCard(
                borderRadius: AppRadius.xl,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: a.color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.md,
                      ),
                      child: Icon(a.icon, color: a.color, size: 22),
                    ),
                    const Spacer(),
                    Text(a.label, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 4),
                    Text(a.description,
                        style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(a.duration,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: a.color, letterSpacing: 0.4)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── 1. Slow Count ────────────────────────────────────────────────────────────
// Count backwards from 300 by 3s. Interrupts anxious thought loops.

class _CountdownView extends StatefulWidget {
  const _CountdownView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_CountdownView> createState() => _CountdownViewState();
}

class _CountdownViewState extends State<_CountdownView> {
  int _value = 300;
  bool _done = false;

  void _tap() {
    H.light();
    if (_done) {
      setState(() {
        _value = 300;
        _done = false;
      });
      return;
    }
    final next = _value - 3;
    if (next <= 0) {
      setState(() {
        _value = 0;
        _done = true;
      });
    } else {
      setState(() => _value = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: l10n.puzzleActivity0Label, onBack: widget.onBack),
        const SizedBox(height: 12),
        LuxuryCard(
          backgroundColor: AppColors.forest800,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                l10n.puzzleCountdownIntro,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.forest200, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _tap,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.forest700,
                    border: Border.all(
                        color: _done ? AppColors.honey400 : AppColors.forest500,
                        width: 2),
                  ),
                  child: Center(
                    child: _done
                        ? Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.check_rounded,
                                color: AppColors.honey400, size: 36),
                            const SizedBox(height: 6),
                            Text(l10n.puzzleCountdownDone,
                                style: AppTextStyles.titleMedium
                                    .copyWith(color: AppColors.honey300)),
                          ])
                        : Text('$_value',
                            style: AppTextStyles.heroNumber
                                .copyWith(color: Colors.white, fontSize: 64)),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _done ? l10n.puzzleCountdownRestart : l10n.puzzleCountdownSubtract,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.forest300),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1 - (_value / 300),
                backgroundColor: AppColors.forest700,
                color: AppColors.honey400,
                minHeight: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 2. Gratitude Shuffle ─────────────────────────────────────────────────────

List<String> _gratitudePrompts(AppLocalizations l10n) => [
      l10n.puzzleGratitudePrompt0,
      l10n.puzzleGratitudePrompt1,
      l10n.puzzleGratitudePrompt2,
      l10n.puzzleGratitudePrompt3,
      l10n.puzzleGratitudePrompt4,
      l10n.puzzleGratitudePrompt5,
      l10n.puzzleGratitudePrompt6,
      l10n.puzzleGratitudePrompt7,
      l10n.puzzleGratitudePrompt8,
      l10n.puzzleGratitudePrompt9,
      l10n.puzzleGratitudePrompt10,
      l10n.puzzleGratitudePrompt11,
      l10n.puzzleGratitudePrompt12,
      l10n.puzzleGratitudePrompt13,
      l10n.puzzleGratitudePrompt14,
    ];

const _gratitudePromptCount = 15;

class _GratitudeShuffleView extends StatefulWidget {
  const _GratitudeShuffleView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_GratitudeShuffleView> createState() => _GratitudeShuffleViewState();
}

class _GratitudeShuffleViewState extends State<_GratitudeShuffleView> {
  final _rng = math.Random();
  int _index = 0;
  final _controller = TextEditingController();

  void _shuffle() {
    H.light();
    setState(() {
      _index = _rng.nextInt(_gratitudePromptCount);
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: l10n.puzzleActivity1Label, onBack: widget.onBack),
        const SizedBox(height: 12),
        LuxuryCard(
          backgroundColor: AppColors.honeySoft,
          borderColor: AppColors.honey100,
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Icon(Icons.shuffle_rounded,
                color: AppColors.honey600, size: 28),
            const SizedBox(height: 16),
            Text(
              _gratitudePrompts(l10n)[_index],
              style: AppTextStyles.headlineSerif.copyWith(
                  color: AppColors.stone800, fontSize: 19, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: 4,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: l10n.puzzleReflectionHint,
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: AppRadius.lg,
                    borderSide: BorderSide(color: AppColors.honey200)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.lg,
                    borderSide: BorderSide(color: AppColors.honey200)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.lg,
                    borderSide: BorderSide(
                        color: AppColors.honey500, width: 1.5)),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _shuffle,
                icon: const Icon(Icons.shuffle_rounded, size: 18),
                label: Text(l10n.puzzleShufflePrompt),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.honey600,
                  side: BorderSide(color: AppColors.honey300),
                  minimumSize: const Size.fromHeight(46),
                  shape:
                      const RoundedRectangleBorder(borderRadius: AppRadius.lg),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

// ─── 3. Strength Compass ──────────────────────────────────────────────────────

const _strengthIcons = [
  Icons.bolt_outlined,
  Icons.hourglass_empty_outlined,
  Icons.verified_outlined,
  Icons.autorenew_rounded,
  Icons.spa_outlined,
  Icons.wb_sunny_outlined,
  Icons.people_outline_rounded,
  Icons.flag_outlined,
];

List<String> _strengthLabels(AppLocalizations l10n) => [
      l10n.puzzleStrength0,
      l10n.puzzleStrength1,
      l10n.puzzleStrength2,
      l10n.puzzleStrength3,
      l10n.puzzleStrength4,
      l10n.puzzleStrength5,
      l10n.puzzleStrength6,
      l10n.puzzleStrength7,
    ];

class _StrengthCompassView extends StatefulWidget {
  const _StrengthCompassView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_StrengthCompassView> createState() => _StrengthCompassViewState();
}

class _StrengthCompassViewState extends State<_StrengthCompassView> {
  final _ratings = List<double>.filled(8, 3);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final strengthLabels = _strengthLabels(l10n);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: l10n.puzzleActivity3Label, onBack: widget.onBack),
        const SizedBox(height: 8),
        Text(l10n.puzzleStrengthIntro,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.stone600)),
        const SizedBox(height: 16),
        for (int i = 0; i < strengthLabels.length; i++) ...[
          SolidCard(
            borderRadius: AppRadius.xl,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(_strengthIcons[i], size: 18, color: AppColors.forest600),
                  const SizedBox(width: 8),
                  Text(strengthLabels[i], style: AppTextStyles.titleSmall),
                  const Spacer(),
                  Text(l10n.puzzleStrengthRating(_ratings[i].round()),
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.forest600)),
                ]),
                Slider(
                  value: _ratings[i],
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (v) {
                    H.selection();
                    setState(() => _ratings[i] = v);
                  },
                  activeColor: AppColors.forest600,
                  inactiveColor: AppColors.stone100,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        LuxuryCard(
          backgroundColor: AppColors.mintChip,
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.puzzleStrengthAffirmation,
            style: AppTextStyles.bodySerif.copyWith(
                color: AppColors.forest700,
                fontStyle: FontStyle.italic,
                fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ─── 4. Now Moment ────────────────────────────────────────────────────────────

const _nowStepIcons = [
  Icons.visibility_outlined,
  Icons.accessibility_new_outlined,
  Icons.touch_app_outlined,
];

List<(String, String)> _nowSteps(AppLocalizations l10n) => [
      (l10n.puzzleNowStep0Title, l10n.puzzleNowStep0Body),
      (l10n.puzzleNowStep1Title, l10n.puzzleNowStep1Body),
      (l10n.puzzleNowStep2Title, l10n.puzzleNowStep2Body),
    ];

const _nowStepCount = 3;

class _NowMomentView extends StatefulWidget {
  const _NowMomentView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_NowMomentView> createState() => _NowMomentViewState();
}

class _NowMomentViewState extends State<_NowMomentView> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = _nowSteps(l10n);
    final step = steps[_step];
    final isLast = _step == steps.length - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: l10n.puzzleActivity4Label, onBack: widget.onBack),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              _nowStepCount,
              (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _step ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color:
                          i == _step ? AppColors.forest600 : AppColors.stone200,
                      borderRadius: AppRadius.pill,
                    ),
                  )),
        ),
        const SizedBox(height: 28),
        LuxuryCard(
          backgroundColor: AppColors.forest800,
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.forest700,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.forest500),
                ),
                child: Icon(_nowStepIcons[_step],
                    color: AppColors.forest300, size: 28),
              ),
              const SizedBox(height: 20),
              Text(step.$1,
                  style: AppTextStyles.overline
                      .copyWith(color: AppColors.honey400, letterSpacing: 2)),
              const SizedBox(height: 12),
              Text(step.$2,
                  style: AppTextStyles.bodySerif.copyWith(
                      color: Colors.white, fontSize: 16, height: 1.65),
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    H.light();
                    if (isLast) {
                      widget.onBack();
                    } else {
                      setState(() => _step++);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest600,
                    minimumSize: const Size.fromHeight(50),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.lg),
                  ),
                  child: Text(isLast ? l10n.puzzleComplete : l10n.commonContinue,
                      style: AppTextStyles.labelLarge
                          .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 5. Colour Calm ───────────────────────────────────────────────────────────

class _ColorCalmView extends StatefulWidget {
  const _ColorCalmView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_ColorCalmView> createState() => _ColorCalmViewState();
}

class _ColorCalmViewState extends State<_ColorCalmView>
    with TickerProviderStateMixin {
  final List<_Ripple> _ripples = [];
  int _tapCount = 0;

  final _colors = [
    AppColors.forest300,
    AppColors.forest500,
    AppColors.honey300,
    AppColors.forest400,
    AppColors.honey400,
    AppColors.forest200,
  ];

  void _onTap(TapDownDetails details) {
    H.light();
    final color = _colors[_tapCount % _colors.length];
    _tapCount++;
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    final ripple = _Ripple(
      pos: details.localPosition,
      color: color,
      controller: ctrl,
    );
    setState(() => _ripples.add(ripple));
    ctrl.forward().whenComplete(() {
      ctrl.dispose();
      if (!mounted) return;
      setState(() => _ripples.remove(ripple));
    });
  }

  @override
  void dispose() {
    for (final r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _BackHeader(title: l10n.puzzleActivity5Label, onBack: widget.onBack),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.puzzleColorIntro,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone500),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GestureDetector(
            onTapDown: _onTap,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.forest800,
                borderRadius: AppRadius.luxury,
              ),
              child: ClipRRect(
                borderRadius: AppRadius.luxury,
                child: Stack(
                  children: [
                    Center(
                      child: _ripples.isEmpty
                          ? Text(l10n.puzzleColorTapAnywhere,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.forest600))
                          : const SizedBox.shrink(),
                    ),
                    for (final r in _ripples)
                      AnimatedBuilder(
                        animation: r.controller,
                        builder: (_, __) {
                          final v = CurvedAnimation(
                            parent: r.controller,
                            curve: Curves.easeOut,
                          ).value;
                          final radius = v * 220;
                          final opacity = (1 - v) * 0.45;
                          return Positioned(
                            left: r.pos.dx - radius,
                            top: r.pos.dy - radius,
                            child: Opacity(
                              opacity: opacity.clamp(0, 1),
                              child: Container(
                                width: radius * 2,
                                height: radius * 2,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: r.color, width: 2.5),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Ripple {
  _Ripple({required this.pos, required this.color, required this.controller});
  final Offset pos;
  final Color color;
  final AnimationController controller;
}
