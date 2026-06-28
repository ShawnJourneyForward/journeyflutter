import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Puzzles ──────────────────────────────────────────────────────────────────
// A small hub of actual games/puzzles — Memory Match, the classic sliding
// 15-puzzle, and 2048. The mindfulness/grounding exercises that used to share
// this tile now live in calm_activities_screen.dart.

enum _Game { home, memoryMatch, slide15, game2048 }

class _GameDef {
  _GameDef({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.duration,
  });
  final _Game id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final String duration;
}

List<_GameDef> _buildGames(AppLocalizations l10n) => [
      _GameDef(
        id: _Game.memoryMatch,
        label: l10n.puzzleActivity2Label,
        description: l10n.puzzleActivity2Desc,
        icon: Icons.grid_view_rounded,
        color: AppColors.forest500,
        duration: l10n.puzzleActivity2Duration,
      ),
      _GameDef(
        id: _Game.slide15,
        label: l10n.puzzleSlideLabel,
        description: l10n.puzzleSlideDesc,
        icon: Icons.apps_rounded,
        color: AppColors.honey600,
        duration: l10n.puzzleSlideDuration,
      ),
      _GameDef(
        id: _Game.game2048,
        label: l10n.puzzle2048Label,
        description: l10n.puzzle2048Desc,
        icon: Icons.swipe_rounded,
        color: AppColors.forest700,
        duration: l10n.puzzle2048Duration,
      ),
    ];

// ─── Puzzle Screen ────────────────────────────────────────────────────────────

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  _Game _current = _Game.home;

  void _go(_Game a) => setState(() => _current = a);
  void _home() => setState(() => _current = _Game.home);

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
              _Game.home => _HomeView(onSelect: _go),
              _Game.memoryMatch => _MemoryMatchView(onBack: _home),
              _Game.slide15 => _SlidePuzzleView(onBack: _home),
              _Game.game2048 => _Game2048View(onBack: _home),
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
  final void Function(_Game) onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final games = _buildGames(l10n);
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
                  Text(l10n.puzzlesHomeTitle,
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.forest700)),
                  Text(l10n.puzzlesHomeSubtitle,
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
          itemCount: games.length,
          itemBuilder: (_, i) {
            final a = games[i];
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

// ─── 1. Memory Match ──────────────────────────────────────────────────────────

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
    H.selection();

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
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: l10n.puzzleActivity2Label, onBack: widget.onBack),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(children: [
            Text(l10n.puzzleMemoryMoves(_moves),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone500)),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                H.light();
                setState(_newGame);
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(l10n.puzzleNewGame),
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
              Text(l10n.puzzleWellDone,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.forest700)),
              const SizedBox(height: 4),
              Text(l10n.puzzleCompletedInMoves(_moves),
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => setState(_newGame),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest600),
                child: Text(l10n.puzzlePlayAgain),
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
                        : (revealed ? AppColors.stone100 : AppColors.forest600),
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

// ─── 2. Slide Puzzle (classic 15-puzzle) ──────────────────────────────────────
// 4×4 grid of tiles 1–15 plus one gap (0). Tap a tile orthogonally adjacent to
// the gap to slide it in. Shuffled by walking the gap on random legal moves, so
// the start state is ALWAYS solvable.

class _SlidePuzzleView extends StatefulWidget {
  const _SlidePuzzleView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_SlidePuzzleView> createState() => _SlidePuzzleViewState();
}

class _SlidePuzzleViewState extends State<_SlidePuzzleView> {
  static const _n = 4; // grid is _n × _n
  late List<int> _tiles; // 16 cells, 0 = gap
  int _moves = 0;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _tiles = [for (int i = 1; i < _n * _n; i++) i, 0]; // solved, gap last
    _moves = 0;
    // Scramble by sliding the gap on random legal moves — guarantees solvable.
    int gap = _n * _n - 1;
    int lastGap = -1;
    for (int s = 0; s < 200; s++) {
      final nbrs = _neighbours(gap)..removeWhere((c) => c == lastGap);
      final pick = nbrs[_rng.nextInt(nbrs.length)];
      _tiles[gap] = _tiles[pick];
      _tiles[pick] = 0;
      lastGap = gap;
      gap = pick;
    }
    // Avoid the (rare) fully-solved scramble: one more legal gap slide keeps it
    // solvable while guaranteeing the player has at least one move to make.
    if (_isSolved) {
      final nbr = _neighbours(gap).first;
      _tiles[gap] = _tiles[nbr];
      _tiles[nbr] = 0;
    }
  }

  List<int> _neighbours(int idx) {
    final r = idx ~/ _n, c = idx % _n;
    return [
      if (r > 0) idx - _n,
      if (r < _n - 1) idx + _n,
      if (c > 0) idx - 1,
      if (c < _n - 1) idx + 1,
    ];
  }

  bool get _isSolved {
    for (int i = 0; i < _n * _n - 1; i++) {
      if (_tiles[i] != i + 1) return false;
    }
    return _tiles.last == 0;
  }

  void _tap(int idx) {
    if (_isSolved) return;
    final gap = _tiles.indexOf(0);
    if (!_neighbours(idx).contains(gap)) return;
    H.selection();
    setState(() {
      _tiles[gap] = _tiles[idx];
      _tiles[idx] = 0;
      _moves++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final solved = _isSolved;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: l10n.puzzleSlideLabel, onBack: widget.onBack),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(children: [
            Text(l10n.puzzleMemoryMoves(_moves),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone500)),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                H.light();
                setState(_newGame);
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(l10n.puzzleNewGame),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.forest600,
                  textStyle: AppTextStyles.labelMedium),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        if (solved) ...[
          LuxuryCard(
            backgroundColor: AppColors.forest50,
            borderColor: AppColors.forest100,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Text('🎉', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(l10n.puzzleWellDone,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.forest700)),
              const SizedBox(height: 4),
              Text(l10n.puzzleCompletedInMoves(_moves),
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => setState(_newGame),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest600),
                child: Text(l10n.puzzlePlayAgain),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ] else ...[
          Text(l10n.puzzleSlideHint,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500)),
          const SizedBox(height: 10),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _n,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _n * _n,
          itemBuilder: (_, i) {
            final v = _tiles[i];
            if (v == 0) {
              return const SizedBox.shrink();
            }
            final inPlace = v == i + 1;
            return GestureDetector(
              onTap: () => _tap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                decoration: BoxDecoration(
                  color: inPlace ? AppColors.forest600 : AppColors.honey500,
                  borderRadius: AppRadius.lg,
                ),
                child: Center(
                  child: Text('$v',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: Colors.white)),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── 3. 2048 ──────────────────────────────────────────────────────────────────
// Classic 4×4 merge game. Swipe to slide every tile; equal neighbours merge into
// their sum. A new 2 or 4 appears after every move that changed the board.

class _Game2048View extends StatefulWidget {
  const _Game2048View({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_Game2048View> createState() => _Game2048ViewState();
}

class _Game2048ViewState extends State<_Game2048View> {
  static const _n = 4;
  late List<List<int>> _grid;
  int _score = 0;
  bool _won = false; // hit 2048 at least once (banner shown until dismissed)
  bool _keepGoing = false;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _grid = List.generate(_n, (_) => List.filled(_n, 0));
    _score = 0;
    _won = false;
    _keepGoing = false;
    _spawn();
    _spawn();
  }

  void _spawn() {
    final empty = <List<int>>[];
    for (int r = 0; r < _n; r++) {
      for (int c = 0; c < _n; c++) {
        if (_grid[r][c] == 0) empty.add([r, c]);
      }
    }
    if (empty.isEmpty) return;
    final cell = empty[_rng.nextInt(empty.length)];
    _grid[cell[0]][cell[1]] = _rng.nextDouble() < 0.9 ? 2 : 4;
  }

  // Slide+merge one line toward index 0. Returns the new line and adds to score.
  List<int> _collapse(List<int> line) {
    final nums = line.where((v) => v != 0).toList();
    final out = <int>[];
    for (int i = 0; i < nums.length; i++) {
      if (i + 1 < nums.length && nums[i] == nums[i + 1]) {
        final merged = nums[i] * 2;
        out.add(merged);
        _score += merged;
        if (merged == 2048) _won = true;
        i++; // consume the pair
      } else {
        out.add(nums[i]);
      }
    }
    while (out.length < _n) {
      out.add(0);
    }
    return out;
  }

  bool _listEq(List<int> a, List<int> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _move(_Dir dir) {
    bool changed = false;
    final next = List.generate(_n, (_) => List.filled(_n, 0));

    for (int i = 0; i < _n; i++) {
      // Extract the line in the swipe direction, collapse toward the swipe edge.
      final line = <int>[];
      for (int j = 0; j < _n; j++) {
        switch (dir) {
          case _Dir.left:
            line.add(_grid[i][j]);
          case _Dir.right:
            line.add(_grid[i][_n - 1 - j]);
          case _Dir.up:
            line.add(_grid[j][i]);
          case _Dir.down:
            line.add(_grid[_n - 1 - j][i]);
        }
      }
      final collapsed = _collapse(line);
      if (!_listEq(line, collapsed)) changed = true;
      for (int j = 0; j < _n; j++) {
        switch (dir) {
          case _Dir.left:
            next[i][j] = collapsed[j];
          case _Dir.right:
            next[i][_n - 1 - j] = collapsed[j];
          case _Dir.up:
            next[j][i] = collapsed[j];
          case _Dir.down:
            next[_n - 1 - j][i] = collapsed[j];
        }
      }
    }

    if (!changed) return;
    H.selection();
    setState(() {
      _grid = next;
      _spawn();
    });
  }

  bool get _gameOver {
    for (int r = 0; r < _n; r++) {
      for (int c = 0; c < _n; c++) {
        if (_grid[r][c] == 0) return false;
        if (c + 1 < _n && _grid[r][c] == _grid[r][c + 1]) return false;
        if (r + 1 < _n && _grid[r][c] == _grid[r + 1][c]) return false;
      }
    }
    return true;
  }

  void _onSwipe(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond;
    if (v.dx.abs() < 80 && v.dy.abs() < 80) return;
    if (v.dx.abs() > v.dy.abs()) {
      _move(v.dx > 0 ? _Dir.right : _Dir.left);
    } else {
      _move(v.dy > 0 ? _Dir.down : _Dir.up);
    }
  }

  Color _tileColor(int v) {
    switch (v) {
      case 0:
        return AppColors.stone100;
      case 2:
        return AppColors.forest100;
      case 4:
        return AppColors.forest200;
      case 8:
        return AppColors.honey200;
      case 16:
        return AppColors.honey300;
      case 32:
        return AppColors.honey400;
      case 64:
        return AppColors.honey500;
      case 128:
        return AppColors.forest400;
      case 256:
        return AppColors.forest500;
      case 512:
        return AppColors.forest600;
      case 1024:
        return AppColors.forest700;
      default:
        return AppColors.forest800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showWin = _won && !_keepGoing;
    final over = _gameOver;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _BackHeader(title: l10n.puzzle2048Label, onBack: widget.onBack),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(children: [
            Text('${l10n.puzzle2048Score}: $_score',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone500)),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                H.light();
                setState(_newGame);
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(l10n.puzzleNewGame),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.forest600,
                  textStyle: AppTextStyles.labelMedium),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        if (showWin) ...[
          LuxuryCard(
            backgroundColor: AppColors.forest50,
            borderColor: AppColors.forest100,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Text('🎉', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(l10n.puzzle2048Win,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.forest700)),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                OutlinedButton(
                  onPressed: () => setState(() => _keepGoing = true),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forest700,
                      side: BorderSide(color: AppColors.forest300)),
                  child: Text(l10n.puzzle2048KeepGoing),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () => setState(_newGame),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest600),
                  child: Text(l10n.puzzlePlayAgain),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
        ] else if (over) ...[
          LuxuryCard(
            backgroundColor: AppColors.honeySoft,
            borderColor: AppColors.honey100,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Text(l10n.puzzle2048GameOver,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.forest700)),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => setState(_newGame),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest600),
                child: Text(l10n.puzzlePlayAgain),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ] else ...[
          Text(l10n.puzzle2048Hint,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500)),
          const SizedBox(height: 10),
        ],
        GestureDetector(
          onPanEnd: _onSwipe,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.stone200,
              borderRadius: AppRadius.xl,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _n,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _n * _n,
              itemBuilder: (_, i) {
                final v = _grid[i ~/ _n][i % _n];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color: _tileColor(v),
                    borderRadius: AppRadius.md,
                  ),
                  child: Center(
                    child: v == 0
                        ? const SizedBox.shrink()
                        : Text('$v',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: v <= 4
                                  ? AppColors.forest700
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                            )),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

enum _Dir { left, right, up, down }
