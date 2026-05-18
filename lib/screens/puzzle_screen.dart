import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// ─── Activity definitions ─────────────────────────────────────────────────────

enum _Activity {
  home,
  countdown,
  gratitudeShuffle,
  memoryMatch,
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
    id: _Activity.memoryMatch,
    label: l10n.puzzleActivity2Label,
    description: l10n.puzzleActivity2Desc,
    icon: Icons.grid_view_rounded,
    color: AppColors.forest500,
    duration: l10n.puzzleActivity2Duration,
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
    label: 'Colour Calm',
    description: 'Tap the expanding circles and let your mind follow.',
    icon: Icons.circle_outlined,
    color: AppColors.forest400,
    duration: '3 min',
  ),
];

// ─── Puzzle Screen ────────────────────────────────────────────────────────────

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
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
              _Activity.home           => _HomeView(onSelect: _go),
              _Activity.countdown      => _CountdownView(onBack: _home),
              _Activity.gratitudeShuffle => _GratitudeShuffleView(onBack: _home),
              _Activity.memoryMatch    => _MemoryMatchView(onBack: _home),
              _Activity.strengthCompass => _StrengthCompassView(onBack: _home),
              _Activity.nowMoment      => _NowMomentView(onBack: _home),
              _Activity.colorCalm      => _ColorCalmView(onBack: _home),
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
      IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: AppColors.stone600),
        onPressed: onBack,
      ),
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
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: AppColors.stone700),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mindful Activities',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.forest700)),
                  Text('Short exercises to calm and refocus',
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
                HapticFeedback.lightImpact();
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
                        color: a.color.withOpacity(0.12),
                        borderRadius: AppRadius.md,
                      ),
                      child: Icon(a.icon, color: a.color, size: 22),
                    ),
                    const Spacer(),
                    Text(a.label,
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 4),
                    Text(a.description,
                        style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(a.duration,
                        style: AppTextStyles.labelSmall.copyWith(
                            color: a.color, letterSpacing: 0.4)),
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
    HapticFeedback.lightImpact();
    if (_done) {
      setState(() { _value = 300; _done = false; });
      return;
    }
    final next = _value - 3;
    if (next <= 0) {
      setState(() { _value = 0; _done = true; });
    } else {
      setState(() => _value = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: 'Slow Count', onBack: widget.onBack),
        const SizedBox(height: 12),
        LuxuryCard(
          backgroundColor: AppColors.forest800,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Counting backwards by 3 interrupts anxiety\nand brings you into the present.',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.forest200, height: 1.5),
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
                            const Icon(Icons.check_rounded,
                                color: AppColors.honey400, size: 36),
                            const SizedBox(height: 6),
                            Text('Done!',
                                style: AppTextStyles.titleMedium
                                    .copyWith(color: AppColors.honey300)),
                          ])
                        : Text('$_value',
                            style: AppTextStyles.heroNumber.copyWith(
                                color: Colors.white, fontSize: 64)),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _done ? 'Tap to restart' : 'Tap to subtract 3',
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

const _gratitudePrompts = [
  'Something in nature I noticed today…',
  'A person who has shown me kindness…',
  'A simple pleasure I often overlook…',
  'Something my body does for me every day…',
  'A memory that still makes me smile…',
  'Something I\'ve learned in the past year…',
  'A challenge that made me stronger…',
  'A small comfort that I appreciate…',
  'Someone who believed in me when I didn\'t…',
  'A moment of peace I\'ve experienced…',
  'A skill or talent I\'m glad I have…',
  'Something I\'m looking forward to…',
  'A kindness I showed someone recently…',
  'Something that made me laugh recently…',
  'A place that brings me peace…',
];

class _GratitudeShuffleView extends StatefulWidget {
  const _GratitudeShuffleView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_GratitudeShuffleView> createState() =>
      _GratitudeShuffleViewState();
}

class _GratitudeShuffleViewState extends State<_GratitudeShuffleView> {
  final _rng = math.Random();
  int _index = 0;
  final _controller = TextEditingController();

  void _shuffle() {
    HapticFeedback.lightImpact();
    setState(() {
      _index = _rng.nextInt(_gratitudePrompts.length);
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: 'Gratitude Shuffle', onBack: widget.onBack),
        const SizedBox(height: 12),
        LuxuryCard(
          backgroundColor: AppColors.honeySoft,
          borderColor: AppColors.honey100,
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Icon(Icons.shuffle_rounded,
                color: AppColors.honey600, size: 28),
            const SizedBox(height: 16),
            Text(
              _gratitudePrompts[_index],
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
                hintText: 'Write your reflection here…',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: AppRadius.lg,
                    borderSide: const BorderSide(color: AppColors.honey200)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.lg,
                    borderSide: const BorderSide(color: AppColors.honey200)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.lg,
                    borderSide: const BorderSide(
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
                label: const Text('Shuffle prompt'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.honey600,
                  side: const BorderSide(color: AppColors.honey300),
                  minimumSize: const Size.fromHeight(46),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.lg),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

// ─── 3. Memory Match ──────────────────────────────────────────────────────────

const _cardEmojis = ['🌱', '💧', '☀️', '🌿', '🦋', '🌸', '⭐', '🌊'];

class _MemoryMatchView extends StatefulWidget {
  const _MemoryMatchView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_MemoryMatchView> createState() => _MemoryMatchViewState();
}

class _MemoryMatchViewState extends State<_MemoryMatchView> {
  late List<String> _deck;
  final List<bool> _flipped = List.filled(16, false);
  final List<bool> _matched = List.filled(16, false);
  int? _firstIndex;
  bool _checking = false;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    final pairs = [..._cardEmojis, ..._cardEmojis]..shuffle(math.Random());
    _deck = pairs;
    for (int i = 0; i < 16; i++) {
      _flipped[i] = false;
      _matched[i] = false;
    }
    _firstIndex = null;
    _checking = false;
    _moves = 0;
  }

  bool get _won => _matched.every((m) => m);

  void _tap(int i) {
    if (_checking || _flipped[i] || _matched[i]) return;
    HapticFeedback.selectionClick();

    setState(() => _flipped[i] = true);

    if (_firstIndex == null) {
      _firstIndex = i;
    } else {
      _moves++;
      _checking = true;
      final first = _firstIndex!;
      _firstIndex = null;

      if (_deck[first] == _deck[i]) {
        setState(() {
          _matched[first] = true;
          _matched[i] = true;
          _checking = false;
        });
      } else {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            setState(() {
              _flipped[first] = false;
              _flipped[i] = false;
              _checking = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: 'Memory Match', onBack: widget.onBack),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(children: [
            Text('Moves: $_moves',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone500)),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(_newGame);
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('New game'),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.forest600,
                  textStyle: AppTextStyles.labelMedium),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        if (_won) ...[
          LuxuryCard(
            backgroundColor: AppColors.forest50,
            borderColor: AppColors.forest100,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Text('🎉', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text('Well done!',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.forest700)),
              const SizedBox(height: 4),
              Text('Completed in $_moves moves',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => setState(_newGame),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest600),
                child: const Text('Play again'),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 16,
          itemBuilder: (_, i) {
            final revealed = _flipped[i] || _matched[i];
            return GestureDetector(
              onTap: () => _tap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: _matched[i]
                      ? AppColors.forest50
                      : (revealed ? Colors.white : AppColors.forest700),
                  borderRadius: AppRadius.lg,
                  border: Border.all(
                    color: _matched[i]
                        ? AppColors.forest200
                        : (revealed
                            ? AppColors.stone100
                            : AppColors.forest600),
                  ),
                ),
                child: Center(
                  child: Text(
                    revealed ? _deck[i] : '?',
                    style: TextStyle(
                      fontSize: revealed ? 26 : 20,
                      color: revealed ? null : AppColors.forest400,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── 4. Strength Compass ──────────────────────────────────────────────────────

const _strengths = [
  ('Courage', Icons.bolt_outlined),
  ('Patience', Icons.hourglass_empty_outlined),
  ('Honesty', Icons.verified_outlined),
  ('Resilience', Icons.autorenew_rounded),
  ('Gratitude', Icons.favorite_outline_rounded),
  ('Hope', Icons.wb_sunny_outlined),
  ('Connection', Icons.people_outline_rounded),
  ('Purpose', Icons.flag_outlined),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: 'Strength Compass', onBack: widget.onBack),
        const SizedBox(height: 8),
        Text('How strong does each feel today? '
            'This is just for you — there\'s no right answer.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.stone600)),
        const SizedBox(height: 16),
        for (int i = 0; i < _strengths.length; i++) ...[
          SolidCard(
            borderRadius: AppRadius.xl,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(_strengths[i].$2,
                      size: 18, color: AppColors.forest600),
                  const SizedBox(width: 8),
                  Text(_strengths[i].$1, style: AppTextStyles.titleSmall),
                  const Spacer(),
                  Text('${_ratings[i].round()}/5',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.forest600)),
                ]),
                Slider(
                  value: _ratings[i],
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
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
            'Wherever you rated yourself today — you showed up. '
            'That alone is strength.',
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

// ─── 5. Now Moment ────────────────────────────────────────────────────────────

const _nowSteps = [
  (
    'Notice',
    'Look around you right now. Name 3 things you can see without judging them. '
        'Just see them as they are.',
    Icons.visibility_outlined,
  ),
  (
    'Feel',
    'Place both feet flat on the floor. Feel the weight of your body. '
        'Notice one sensation in your body right now — warmth, tension, breath.',
    Icons.accessibility_new_outlined,
  ),
  (
    'Choose',
    'You have arrived in this moment. '
        'What is one small, kind thing you can do for yourself in the next 10 minutes?',
    Icons.touch_app_outlined,
  ),
];

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
    final step = _nowSteps[_step];
    final isLast = _step == _nowSteps.length - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: 'Now Moment', onBack: widget.onBack),
        const SizedBox(height: 20),
        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_nowSteps.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == _step ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i == _step ? AppColors.forest600 : AppColors.stone200,
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
                child: Icon(step.$3, color: AppColors.forest300, size: 28),
              ),
              const SizedBox(height: 20),
              Text(step.$1,
                  style: AppTextStyles.overline.copyWith(
                      color: AppColors.honey400, letterSpacing: 2)),
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
                    HapticFeedback.lightImpact();
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
                  child: Text(isLast ? 'Complete' : 'Continue',
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

// ─── 6. Colour Calm ───────────────────────────────────────────────────────────

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
    HapticFeedback.lightImpact();
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
    ctrl.forward().then((_) {
      if (mounted) {
        setState(() => _ripples.remove(ripple));
        ctrl.dispose();
      }
    });
  }

  @override
  void dispose() {
    for (final r in _ripples) r.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BackHeader(title: 'Colour Calm', onBack: widget.onBack),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Tap anywhere. Breathe with the circles.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.stone500),
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
                    // Ambient text
                    Center(
                      child: _ripples.isEmpty
                          ? Text('Tap anywhere',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.forest600))
                          : const SizedBox.shrink(),
                    ),
                    // Ripples
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
                                  border: Border.all(
                                      color: r.color, width: 2.5),
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
