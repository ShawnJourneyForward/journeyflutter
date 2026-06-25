import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../models/planner_activity.dart';
import '../models/planner_goal.dart';
import '../models/planner_session.dart';
import '../providers/app_providers.dart';
import '../services/strava_config.dart';
import '../theme/app_theme.dart';
import '../theme/planner_palette.dart';
import '../utils/haptic_service.dart';
import '../utils/locale_format.dart';
import 'planner_activity_sheet.dart';
import 'planner_session_sheet.dart';
import 'planner_strava_sheet.dart';

// ─── Date key helper — YYYY-MM-DD (mirrors heatmap_screen) ───────────────────
String _dk(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ─── Session-type label resolver ─────────────────────────────────────────────
// Maps the locked SessionType enum onto its locked l10n getter so all copy
// stays translatable (no hardcoded prose).
String sessionTypeLabel(AppLocalizations l10n, SessionType t) {
  switch (t) {
    case SessionType.easyRun:
      return l10n.plannerSessionEasyRun;
    case SessionType.intervals:
      return l10n.plannerSessionIntervals;
    case SessionType.tempo:
      return l10n.plannerSessionTempo;
    case SessionType.longRun:
      return l10n.plannerSessionLongRun;
    case SessionType.rest:
      return l10n.plannerSessionRest;
    case SessionType.crossTrain:
      return l10n.plannerSessionCrossTrain;
    case SessionType.swim:
      return l10n.plannerSessionSwim;
    case SessionType.other:
      return l10n.plannerSessionOther;
  }
}

// ─── Planner Screen — root tab host ──────────────────────────────────────────

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('planner-screen'),
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (lightweight, no back button) ────────────────────────
            const _PlannerHeader(),

            // ── Tab bar (pill container — cloned from progress_screen) ───────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppRadius.pill,
                  border: Border.all(color: AppColors.softBorder),
                ),
                child: TabBar(
                  controller: _tabs,
                  // 3 labels at labelLarge can crowd 360dp — step the active
                  // label down to labelMedium so all three fit comfortably.
                  labelStyle: AppTextStyles.labelMedium,
                  unselectedLabelStyle: AppTextStyles.bodySmall,
                  labelColor: AppColors.forest700,
                  unselectedLabelColor: AppColors.stone500,
                  indicator: BoxDecoration(
                    color: AppColors.mintChip,
                    borderRadius: AppRadius.pill,
                    boxShadow: AppShadows.card,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: l10n.plannerTabOverview),
                    Tab(text: l10n.plannerTabPlanner),
                    Tab(text: l10n.plannerTabStreaks),
                  ],
                ),
              ),
            ),

            // ── Tab views ────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  _OverviewTab(),
                  _PlannerTab(),
                  _StreaksTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────
// Matches the progress_screen header grammar (serif title + a trailing pill),
// but is a fresh widget — we deliberately do NOT import the private _HomeHeader.

class _PlannerHeader extends StatelessWidget {
  const _PlannerHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(l10n.navPlanner, style: AppTextStyles.greetingSerif),
          ),
          // Trailing compass chip — decorative, on-brand mint icon chip.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mintChip,
              borderRadius: AppRadius.pill,
              border: Border.all(color: AppColors.forest100),
            ),
            child: Icon(Icons.explore_outlined,
                size: 18, color: AppColors.forest600),
          ),
        ],
      ),
    );
  }
}

// ─── OVERVIEW TAB ────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goals = ref.watch(plannerGoalProvider).valueOrNull ?? const [];
    final active = goals.where((g) => !g.archived).toList();
    final weekSessions = ref.watch(currentWeekSessionsProvider);
    final weekDone = weekSessions
        .where((s) => s.completed && s.type != SessionType.rest)
        .length;
    final weekTotal = weekSessions.where((s) => s.type != SessionType.rest).length;
    final weekPct =
        weekTotal == 0 ? 0 : ((weekDone / weekTotal) * 100).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      children: [
        // ── My goals header + add ─────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Text(l10n.plannerMyGoals,
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.forestDark)),
            ),
            _AddPill(
              label: l10n.plannerAddGoal,
              icon: Icons.add_rounded,
              onTap: () {
                H.light();
                context.push('/planner-goal');
              },
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Goals list / empty state ──────────────────────────────────────
        if (active.isEmpty)
          _EmptyState(message: l10n.plannerNoGoals)
        else
          ...active.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GoalCard(
                  goal: g,
                  // Per-goal progress so every card shows its OWN real bar, not
                  // a misleading 0% just because it isn't the active goal.
                  progress: ref.watch(goalProgressForProvider(g.id)),
                ),
              )),

        const SizedBox(height: 8),

        // ── Compact streak + weekly-progress summary ──────────────────────
        SolidCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              _ProgressRing(
                value: weekTotal == 0 ? 0.0 : weekDone / weekTotal,
                size: 76,
                stroke: 8,
                semanticLabel: l10n.plannerA11yProgressRing(weekPct),
                center: Text('$weekPct%',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.forestDark)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.plannerCurrentWeek,
                        style: AppTextStyles.overline),
                    const SizedBox(height: 6),
                    Text(l10n.plannerWeeklyProgress(weekPct),
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.stoneText)),
                    const SizedBox(height: 2),
                    Text(l10n.plannerWorkoutsOfTarget(weekDone, weekTotal),
                        style: AppTextStyles.bodySmall),
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

// ─── PLANNER TAB ─────────────────────────────────────────────────────────────

class _PlannerTab extends ConsumerWidget {
  const _PlannerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allSessions =
        ref.watch(plannerSessionProvider).valueOrNull ?? const [];
    final weekSessions = ref.watch(currentWeekSessionsProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final month = DateTime(now.year, now.month, 1);

    // Index this month's sessions by day-key for the calendar.
    final byDay = <String, PlannerSession>{};
    for (final s in allSessions) {
      if (s.date.year == month.year && s.date.month == month.month) {
        // Last write wins; one cell shows one session's tint/icon.
        byDay[_dk(DateTime(s.date.year, s.date.month, s.date.day))] = s;
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      children: [
        // ── Month calendar ────────────────────────────────────────────────
        _PlannerMonthCard(
          month: month,
          today: today,
          sessionsByDay: byDay,
          // Tapping a day opens its session for edit (or a fresh session seeded
          // to that date), so the calendar isn't a dead read-only grid.
          onTapDay: (date, session) {
            H.light();
            showPlannerSessionSheet(context, ref,
                existing: session, date: session == null ? date : null);
          },
        ),
        const SizedBox(height: 18),

        // ── This-week list header + add ───────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Text(l10n.plannerCurrentWeek,
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.forestDark)),
            ),
            // Log a completed activity (manual entry).
            _GhostIconButton(
              icon: Icons.add_task_rounded,
              semanticLabel: l10n.plannerSourceManual,
              onTap: () {
                H.light();
                showPlannerActivitySheet(context, ref);
              },
            ),
            const SizedBox(width: 8),
            _AddPill(
              label: l10n.plannerAddSession,
              icon: Icons.add_rounded,
              onTap: () {
                H.light();
                showPlannerSessionSheet(context, ref);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Week session rows ─────────────────────────────────────────────
        if (weekSessions.isEmpty)
          _EmptyState(message: l10n.plannerNoGoals)
        else
          ...weekSessions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SessionRow(session: s),
              )),
      ],
    );
  }
}

// ─── PLANNER calendar: month card (reuses heatmap layout math) ───────────────

class _PlannerMonthCard extends StatelessWidget {
  const _PlannerMonthCard({
    required this.month,
    required this.today,
    required this.sessionsByDay,
    required this.onTapDay,
  });

  final DateTime month; // first day of the month
  final DateTime today;
  final Map<String, PlannerSession> sessionsByDay;
  final void Function(DateTime date, PlannerSession? session) onTapDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1; // Mon=0 offset
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final monthLabel = DateFormat('MMMM yyyy').format(month);
    final monthSessions =
        sessionsByDay.values.where((s) => s.type != SessionType.rest);
    final plannedCount = monthSessions.length;
    final doneCount = monthSessions.where((s) => s.completed).length;

    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month title + planned-session count
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(monthLabel,
                    style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.forestDark,
                        fontWeight: FontWeight.w600)),
              ),
              Text(l10n.plannerWorkoutsOfTarget(doneCount, plannedCount),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.forest600)),
            ],
          ),
          const SizedBox(height: 12),
          // Day-of-week headers (Mon-first, mirrors heatmap)
          Row(
            children: [
              _DowLabel(l10n.heatmapDowMon),
              _DowLabel(l10n.heatmapDowTue),
              _DowLabel(l10n.heatmapDowWed),
              _DowLabel(l10n.heatmapDowThu),
              _DowLabel(l10n.heatmapDowFri),
              _DowLabel(l10n.heatmapDowSat),
              _DowLabel(l10n.heatmapDowSun),
            ],
          ),
          const SizedBox(height: 5),
          // Calendar grid
          LayoutBuilder(builder: (context, constraints) {
            const gap = 3.0;
            final cellSize =
                ((constraints.maxWidth - gap * 6) / 7).clamp(28.0, 46.0);

            return Column(
              children: List.generate(rows, (row) {
                return Padding(
                  padding: EdgeInsets.only(bottom: row < rows - 1 ? gap : 0),
                  child: Row(
                    children: List.generate(7, (col) {
                      final idx = row * 7 + col;
                      final dayNum = idx - leadingEmpty + 1;
                      final isEmpty =
                          idx < leadingEmpty || dayNum > daysInMonth;

                      Widget tile;
                      if (isEmpty) {
                        tile = SizedBox(width: cellSize, height: cellSize);
                      } else {
                        final date =
                            DateTime(month.year, month.month, dayNum);
                        final isToday = _dk(date) == _dk(today);
                        final session = sessionsByDay[_dk(date)];

                        tile = _PlannerDayTile(
                          date: date,
                          session: session,
                          isToday: isToday,
                          size: cellSize,
                          onTap: () => onTapDay(date, session),
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.only(right: col < 6 ? gap : 0),
                        child: tile,
                      );
                    }),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class _DowLabel extends StatelessWidget {
  const _DowLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Center(
          child: Text(label,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.stone400)),
        ),
      );
}

// ─── PLANNER calendar: day tile ──────────────────────────────────────────────

class _PlannerDayTile extends StatelessWidget {
  const _PlannerDayTile({
    required this.date,
    required this.session,
    required this.isToday,
    required this.size,
    required this.onTap,
  });

  final DateTime date;
  final PlannerSession? session;
  final bool isToday;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSession = session != null;
    final bg =
        hasSession ? sessionTypeTint(session!.type) : AppColors.stone50;
    final completed = session?.completed ?? false;

    final dateLabel = MaterialLocalizations.of(context).formatFullDate(date);
    final semanticLabel = hasSession
        ? '$dateLabel, ${completed ? l10n.plannerA11yDayDone : l10n.plannerA11yDayTodo}'
        : dateLabel;

    return Semantics(
      label: semanticLabel,
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(7),
          // Forest today-ring (mirrors heatmap's today border).
          border: isToday
              ? Border.all(color: AppColors.forest500, width: 1.5)
              : null,
        ),
        child: Center(
          child: completed
              ? Icon(Icons.check_rounded,
                  size: size * 0.5, color: sessionTypeColor(session!.type))
              : Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: size < 34 ? 10 : 11,
                    fontWeight:
                        hasSession ? FontWeight.w600 : FontWeight.w400,
                    color: hasSession
                        ? sessionTypeColor(session!.type)
                        : AppColors.stone400,
                    height: 1,
                  ),
                ),
        ),
      ),
      ),
    );
  }
}

// ─── PLANNER: a single this-week session row ─────────────────────────────────

class _SessionRow extends ConsumerWidget {
  const _SessionRow({required this.session});
  final PlannerSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(profileProvider).valueOrNull;
    final imperial = profile?.useImperial ?? false;
    final label = sessionTypeLabel(l10n, session.type);
    final distance = session.plannedDistanceKm == null
        ? ''
        : formatDistance(session.plannedDistanceKm!,
            imperial: imperial, l10n: l10n);
    final line = distance.isEmpty
        ? label
        : l10n.plannerSessionLine(label, distance);

    return GestureDetector(
      // Tap the card to edit / delete the session (mirrors the home activity
      // sheet) — only the checkbox toggles completion.
      onTap: () {
        H.light();
        showPlannerSessionSheet(context, ref, existing: session);
      },
      child: SolidCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconChip(
            icon: sessionTypeIcon(session.type),
            backgroundColor: sessionTypeTint(session.type),
            color: sessionTypeColor(session.type),
            size: 38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line,
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.stoneText)),
                const SizedBox(height: 2),
                Text(DateFormat('EEE, d MMM').format(session.date),
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          // Mark-complete checkbox.
          Semantics(
            button: true,
            label: session.completed
                ? l10n.plannerMarkIncomplete
                : l10n.plannerMarkComplete,
            child: GestureDetector(
              onTap: () {
                H.medium();
                _toggleComplete(ref);
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: session.completed
                      ? AppColors.forest600
                      : Colors.transparent,
                  borderRadius: AppRadius.sm,
                  border: Border.all(
                    color: session.completed
                        ? AppColors.forest600
                        : AppColors.stone300,
                    width: 1.5,
                  ),
                ),
                child: session.completed
                    ? Icon(Icons.check_rounded,
                        size: 18, color: AppColors.onForest)
                    : null,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Toggle this week-row's completion. Completing a non-rest session mints a
  /// linked manual PlannerActivity (mirroring the planned distance/minutes) so
  /// it shows up in history and feeds the insights charts; un-completing deletes
  /// the linked activity and clears the stamp. Mirrors the session sheet's
  /// _toggleComplete so both completion paths behave identically.
  Future<void> _toggleComplete(WidgetRef ref) async {
    final sessions = ref.read(plannerSessionProvider.notifier);
    final activities = ref.read(plannerActivityProvider.notifier);
    if (session.completed) {
      // Drop the linked activity (if any), then reset to incomplete.
      final linked = session.completedActivityId;
      if (linked != null) await activities.delete(linked);
      await sessions.setComplete(session.id, false);
      return;
    }
    String? activityId;
    if (session.type != SessionType.rest) {
      final activity = PlannerActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: session.date,
        type: session.type,
        minutes: session.plannedMinutes ?? 0,
        distanceKm: session.plannedDistanceKm,
        source: ActivitySource.manual,
        goalId: session.goalId.isEmpty ? null : session.goalId,
      );
      await activities.add(activity);
      activityId = activity.id;
    }
    await sessions.setComplete(session.id, true, activityId: activityId);
  }
}

// ─── STREAKS TAB ─────────────────────────────────────────────────────────────

class _StreaksTab extends ConsumerWidget {
  const _StreaksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final weekSessions = ref.watch(currentWeekSessionsProvider);
    final done = weekSessions
        .where((s) => s.completed && s.type != SessionType.rest)
        .length;
    final total =
        weekSessions.where((s) => s.type != SessionType.rest).length;
    final value = total == 0 ? 0.0 : done / total;
    final pct = (value * 100).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
      children: [
        // ── Big weekly-progress ring ──────────────────────────────────────
        SolidCard(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Column(
            children: [
              _ProgressRing(
                value: value,
                size: 168,
                stroke: 9,
                semanticLabel: l10n.plannerA11yProgressRing(pct),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$pct%', style: AppTextStyles.displaySmall),
                    Text(l10n.plannerCurrentStreak,
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.plannerWeeklyProgress(pct),
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.stoneText)),
              const SizedBox(height: 4),
              Text(l10n.plannerWorkoutsOfTarget(done, total),
                  style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Trailing actions → history / insights ─────────────────────────
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.history_rounded,
                label: l10n.plannerHistory,
                onTap: () {
                  H.light();
                  context.push('/planner-history');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.insights_rounded,
                label: l10n.plannerInsights,
                onTap: () {
                  H.light();
                  context.push('/planner-insights');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.ios_share_rounded,
          label: l10n.plannerShareProgress,
          onTap: () {
            H.light();
            context.push('/planner-share');
          },
        ),

        // ── Strava connect (only when credentials are configured) ─────────
        if (stravaConfigured) ...[
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.directions_bike_rounded,
            label: l10n.plannerConnectStrava,
            onTap: () {
              H.light();
              showStravaSheet(context, ref);
            },
          ),
        ],
      ],
    );
  }
}

// ─── Shared: progress ring (CustomPaint) ─────────────────────────────────────
// ~9px forest700 stroke over a stone100 track, round cap, centre child.

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.value,
    required this.semanticLabel,
    this.center,
    this.size = 120,
    this.stroke = 9,
  });

  final double value; // 0..1
  final String semanticLabel;
  final Widget? center;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: value.clamp(0.0, 1.0),
            stroke: stroke,
            track: AppColors.stone100,
            progress: AppColors.forest700,
          ),
          child: Center(child: center),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.stroke,
    required this.track,
    required this.progress,
  });

  final double value;
  final double stroke;
  final Color track;
  final Color progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);

    if (value > 0) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = progress;
      // Start at 12 o'clock, sweep clockwise.
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false,
          progressPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.stroke != stroke ||
      old.track != track ||
      old.progress != progress;
}

// ─── Shared small pieces ─────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.progress});
  final PlannerGoal goal;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pct = (progress * 100).round();
    final typeLabel = switch (goal.type) {
      GoalType.exercise => l10n.plannerGoalTypeExercise,
      GoalType.weight => l10n.plannerGoalTypeWeight,
    };

    return GestureDetector(
      onTap: () {
        H.light();
        // Pass the goal id so the editor opens in EDIT mode (no id == create a
        // brand-new goal). Without this, tapping a card always opened a blank
        // create form and saving minted a DUPLICATE goal.
        context.push('/planner-goal', extra: goal.id);
      },
      child: SolidCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(goal.title,
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.forestDark)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forest50,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(typeLabel,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.forest600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: AppRadius.pill,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.stone100,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.forest600),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.plannerGoalProgress(pct),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.forest600,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

class _AddPill extends StatelessWidget {
  const _AddPill(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.forest700,
          borderRadius: AppRadius.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.onForest),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.onForest)),
          ],
        ),
      ),
    );
  }
}

class _GhostIconButton extends StatelessWidget {
  const _GhostIconButton(
      {required this.icon, required this.semanticLabel, required this.onTap});
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.mintChip,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.forest100),
          ),
          child: Icon(icon, size: 18, color: AppColors.forest600),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SolidCard(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        child: Column(
          children: [
            IconChip(icon: icon, size: 42),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.stoneText)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Center(
        child: Text(message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.mistGrey)),
      ),
    );
  }
}
