import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../models/planner_goal.dart';
import '../models/planner_session.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../theme/planner_palette.dart';
import '../utils/haptic_service.dart';
import '../utils/locale_format.dart';
import 'planner_activity_sheet.dart';
import 'planner_session_sheet.dart';

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
    // General disciplines reuse the already-translated discipline labels.
    case SessionType.ride:
      return l10n.plannerDisciplineRide;
    case SessionType.walk:
      return l10n.plannerDisciplineWalk;
    case SessionType.hike:
      return l10n.plannerDisciplineHike;
    case SessionType.gym:
      return l10n.plannerDisciplineGym;
    case SessionType.yoga:
      return l10n.plannerDisciplineYoga;
    case SessionType.cardio:
      return l10n.plannerDisciplineCardio;
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

        // ── Health & safety note ──────────────────────────────────────────
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded,
                size: 16, color: AppColors.stone400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.plannerHealthDisclaimer,
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.stone500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── PLANNER TAB ─────────────────────────────────────────────────────────────

class _PlannerTab extends ConsumerStatefulWidget {
  const _PlannerTab();

  @override
  ConsumerState<_PlannerTab> createState() => _PlannerTabState();
}

class _PlannerTabState extends ConsumerState<_PlannerTab> {
  late DateTime _month; // first day of the browsed month

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  void _shiftMonth(int delta) {
    H.selection();
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allSessions =
        ref.watch(plannerSessionProvider).valueOrNull ?? const [];
    final weekSessions = ref.watch(currentWeekSessionsProvider);
    final goals = ref.watch(plannerGoalProvider).valueOrNull ?? const [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Goal/event days in the browsed month: the target (end) date of ANY live
    // goal gets a calendar flag so "set a goal → see it on the calendar" holds.
    // We keep two sets so the flag and a11y label can tell a dated *event*
    // (race/competition) apart from a plain goal deadline.
    final eventDays = <String>{};
    final goalDays = <String>{};
    for (final g in goals) {
      final d = g.endDate;
      if (g.archived ||
          d == null ||
          d.year != _month.year ||
          d.month != _month.month) {
        continue;
      }
      final key = _dk(DateTime(d.year, d.month, d.day));
      (g.isEvent ? eventDays : goalDays).add(key);
    }

    // Index the BROWSED month's sessions by day-key. A day can hold SEVERAL
    // sessions (e.g. a running goal and a swimming goal both scheduling it), so
    // each cell maps to a list — nothing gets silently hidden.
    final byDay = <String, List<PlannerSession>>{};
    for (final s in allSessions) {
      if (s.date.year == _month.year && s.date.month == _month.month) {
        byDay
            .putIfAbsent(
                _dk(DateTime(s.date.year, s.date.month, s.date.day)),
                () => <PlannerSession>[])
            .add(s);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      children: [
        // ── Month calendar (now navigable) ────────────────────────────────
        _PlannerMonthCard(
          month: _month,
          today: today,
          sessionsByDay: byDay,
          eventDays: eventDays,
          goalDays: goalDays,
          onPrev: () => _shiftMonth(-1),
          onNext: () => _shiftMonth(1),
          // Tap a day: empty → new session seeded to that date; one → edit it;
          // many → a day sheet listing them all (so two goals can co-exist).
          onTapDay: (date, daySessions) {
            H.light();
            if (daySessions.isEmpty) {
              showPlannerSessionSheet(context, ref, date: date);
            } else if (daySessions.length == 1) {
              showPlannerSessionSheet(context, ref, existing: daySessions.first);
            } else {
              _showDaySessions(context, ref, date);
            }
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

        // ── Reset plan (clears all planned sessions; history is kept) ─────
        if (allSessions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => _confirmResetPlan(context, ref, l10n),
              icon: Icon(Icons.restart_alt_rounded,
                  size: 18, color: AppColors.blush600),
              label: Text(l10n.plannerResetPlan,
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.blush600)),
            ),
          ),
        ],
      ],
    );
  }
}

/// Confirm-gated wipe of every planned session. Logged activities (history) and
/// goals are left intact — only the plan is cleared. See
/// [PlannerSessionNotifier.clearAll].
Future<void> _confirmResetPlan(
    BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
  H.light();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(l10n.plannerResetPlanTitle),
      content: Text(l10n.plannerResetPlanBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.plannerResetPlanCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.plannerResetPlanConfirm,
              style: TextStyle(color: AppColors.blush600)),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    H.heavy();
    await ref.read(plannerSessionProvider.notifier).clearAll();
  }
}

// ─── PLANNER calendar: month card (reuses heatmap layout math) ───────────────

class _PlannerMonthCard extends StatelessWidget {
  const _PlannerMonthCard({
    required this.month,
    required this.today,
    required this.sessionsByDay,
    required this.eventDays,
    required this.goalDays,
    required this.onPrev,
    required this.onNext,
    required this.onTapDay,
  });

  final DateTime month; // first day of the month
  final DateTime today;
  final Map<String, List<PlannerSession>> sessionsByDay;
  final Set<String> eventDays; // day-keys with a dated *event* goal
  final Set<String> goalDays; // day-keys with a plain dated goal (non-event)
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final void Function(DateTime date, List<PlannerSession> sessions) onTapDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1; // Mon=0 offset
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final monthLabel = DateFormat('MMMM yyyy').format(month);
    final monthSessions = sessionsByDay.values
        .expand((l) => l)
        .where((s) => s.type != SessionType.rest);
    final plannedCount = monthSessions.length;
    final doneCount = monthSessions.where((s) => s.completed).length;

    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month title with prev/next navigation (plan any month ahead).
          Row(
            children: [
              _GhostIconButton(
                icon: Icons.chevron_left_rounded,
                semanticLabel: l10n.plannerPrevMonth,
                onTap: onPrev,
              ),
              Expanded(
                child: Center(
                  child: Text(monthLabel,
                      style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.forestDark,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              _GhostIconButton(
                icon: Icons.chevron_right_rounded,
                semanticLabel: l10n.plannerNextMonth,
                onTap: onNext,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(l10n.plannerWorkoutsOfTarget(doneCount, plannedCount),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.forest600)),
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
                ((constraints.maxWidth - gap * 6) / 7).clamp(32.0, 48.0);

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
                        final daySessions = sessionsByDay[_dk(date)] ??
                            const <PlannerSession>[];

                        tile = _PlannerDayTile(
                          date: date,
                          sessions: daySessions,
                          isToday: isToday,
                          isEvent: eventDays.contains(_dk(date)),
                          isGoalTarget: goalDays.contains(_dk(date)),
                          size: cellSize,
                          onTap: () => onTapDay(date, daySessions),
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
              // stone500 (not stone400) for WCAG AA contrast on the calendar.
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.stone500)),
        ),
      );
}

// ─── PLANNER calendar: day tile ──────────────────────────────────────────────

class _PlannerDayTile extends StatelessWidget {
  const _PlannerDayTile({
    required this.date,
    required this.sessions,
    required this.isToday,
    required this.isEvent,
    required this.isGoalTarget,
    required this.size,
    required this.onTap,
  });

  final DateTime date;
  final List<PlannerSession> sessions;
  final bool isToday;
  final bool isEvent;
  final bool isGoalTarget;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSession = sessions.isNotEmpty;
    final multi = sessions.length > 1;
    // The primary session drives the cell's colour/glyph — prefer the first
    // non-rest one so a real workout wins over a rest day sharing the cell.
    final primary = hasSession
        ? sessions.firstWhere((s) => s.type != SessionType.rest,
            orElse: () => sessions.first)
        : null;
    // Empty days are stone; an empty TODAY gets a soft forest fill (on top of
    // its ring) so the current day is easy to spot at a glance. A day that has a
    // session keeps its session tint — the ring alone marks it as today.
    final bg = primary != null
        ? sessionTypeTint(primary.type)
        : isToday
            ? AppColors.forest50
            : AppColors.stone50;
    // Single-session days get a check/dash glyph; a multi-session day always
    // shows the day number (a check there would wrongly imply ALL are done).
    final completed = !multi && (primary?.completed ?? false);
    final skipped = !multi && (primary?.skipped ?? false);

    final dateLabel = MaterialLocalizations.of(context).formatFullDate(date);
    final statusText = multi
        ? l10n.plannerSessionsCount(sessions.length)
        : completed
            ? l10n.plannerA11yDayDone
            : skipped
                ? l10n.plannerA11yDaySkipped
                : l10n.plannerA11yDayTodo;
    final baseLabel = hasSession ? '$dateLabel, $statusText' : dateLabel;
    // Both an event and a plain goal show a flag; the screen-reader suffix tells
    // them apart ("Event day" vs the existing "A goal" label — no new string).
    final semanticLabel = isEvent
        ? '$baseLabel, ${l10n.plannerEventDayLabel}'
        : isGoalTarget
            ? '$baseLabel, ${l10n.plannerGoalKindGoal}'
            : baseLabel;

    return Semantics(
      label: semanticLabel,
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // Visual cell stays `size`, but the tap area is at least 46dp tall so
        // the day is comfortable to hit (a11y min target) without widening the
        // 7-column grid.
        child: SizedBox(
          width: size,
          height: size < 46 ? 46 : size,
          child: Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
            children: [
              Positioned.fill(
                child: Container(
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
                            size: size * 0.5,
                            color: sessionTypeColor(primary!.type))
                        : skipped
                            ? Icon(Icons.remove_rounded,
                                size: size * 0.5, color: AppColors.stone400)
                            : Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: size < 34 ? 10 : 11,
                                  fontWeight: hasSession
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: primary != null
                                      ? sessionTypeColor(primary.type)
                                      : AppColors.stone500,
                                  height: 1,
                                ),
                              ),
                  ),
                ),
              ),
              // Multi-session marker — a small dot meaning "more than one here,
              // tap to see them all".
              if (multi)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.forest600,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              // Goal flag — the target day of any goal. Honey for a dated event
              // (race/competition), forest for a plain goal deadline, so the
              // two read apart at a glance.
              if (isEvent || isGoalTarget)
                Positioned(
                  top: 2,
                  left: 2,
                  child: Icon(
                    Icons.flag_rounded,
                    size: size < 34 ? 9 : 11,
                    color: isEvent ? AppColors.honey600 : AppColors.forest600,
                  ),
                ),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── PLANNER: day sheet for a date holding several sessions ──────────────────
// When two goals (say a run plan and a swim plan) both schedule the same day,
// one tiny cell can't show them all — tapping opens this sheet so every session
// is reachable. Reactive: re-derives the day's sessions from the provider so
// edits/deletes reflect live.

void _showDaySessions(BuildContext context, WidgetRef ref, DateTime date) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DaySessionsSheet(date: date),
  );
}

class _DaySessionsSheet extends ConsumerWidget {
  const _DaySessionsSheet({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(plannerSessionProvider).valueOrNull ?? const [];
    final key = _dk(date);
    final daySessions = all.where((s) => _dk(s.date) == key).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .8,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xxl,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.stone200,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              Text(DateFormat('EEEE, d MMMM').format(date),
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.forestDark)),
              const SizedBox(height: 14),
              if (daySessions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(l10n.plannerNoSessionsYet,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.mistGrey)),
                )
              else
                ...daySessions.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SessionRow(session: s),
                    )),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    H.light();
                    showPlannerSessionSheet(context, ref, date: date);
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.plannerAddSession),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.forest600,
                    side:
                        BorderSide(color: AppColors.forest600.withValues(alpha: .35)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
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
                    style: AppTextStyles.titleSmall.copyWith(
                      // A skipped session reads as struck-through + muted.
                      color: session.skipped
                          ? AppColors.stone400
                          : AppColors.stoneText,
                      decoration: session.skipped
                          ? TextDecoration.lineThrough
                          : null,
                    )),
                const SizedBox(height: 2),
                Text(
                  session.skipped
                      ? '${l10n.plannerSkippedLabel}  ·  ${DateFormat('EEE, d MMM').format(session.date)}'
                      : DateFormat('EEE, d MMM').format(session.date),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          // Status control — 3-state: pending (empty box → close-off popup),
          // completed (forest check), skipped (muted dash). Tap reopens a
          // closed-off session.
          Semantics(
            button: true,
            label: session.completed
                ? l10n.plannerMarkIncomplete
                : session.skipped
                    ? l10n.plannerReopenSession
                    : l10n.plannerMarkComplete,
            child: GestureDetector(
              onTap: () => _onTapStatus(context, ref),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: session.completed
                      ? AppColors.forest600
                      : session.skipped
                          ? AppColors.stone100
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
                    : session.skipped
                        ? Icon(Icons.remove_rounded,
                            size: 18, color: AppColors.stone400)
                        : null,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Handle a tap on the status control. The session is CLOSED OFF through the
  /// completion popup (never auto-logged from the plan): pending non-rest → open
  /// the close-off sheet (log actuals / skip); pending rest → mark done directly
  /// (nothing to log); completed → reopen + drop the linked activity; skipped →
  /// reopen.
  Future<void> _onTapStatus(BuildContext context, WidgetRef ref) async {
    final sessions = ref.read(plannerSessionProvider.notifier);
    if (session.completed) {
      H.light();
      final linked = session.completedActivityId;
      if (linked != null) {
        await ref.read(plannerActivityProvider.notifier).delete(linked);
      }
      await sessions.reopen(session.id);
      return;
    }
    if (session.skipped) {
      H.light();
      await sessions.reopen(session.id);
      return;
    }
    if (session.type == SessionType.rest) {
      H.medium();
      await sessions.markComplete(session.id, null);
      return;
    }
    H.medium();
    await showPlannerSessionCompleteSheet(context, ref, session);
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
    // Countdown window (null when the goal has no goal/end date).
    final timeline = goalTimelineFor(goal, DateTime.now());
    // Whether a target/volume bar is meaningful (a race goal can be date-only).
    final hasTarget = switch (goal.type) {
      GoalType.exercise => goal.targetValue != null && goal.targetValue! > 0,
      GoalType.weight =>
        goal.startWeightKg != null && goal.goalWeightKg != null,
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
            // ── Title + type chip ────────────────────────────────────────
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

            // ── Countdown (the lead for a dated goal) ────────────────────
            if (timeline != null) ...[
              const SizedBox(height: 14),
              _GoalTimelineSection(timeline: timeline),
            ],

            // ── Target / volume progress — only when a target is set ─────
            if (hasTarget) ...[
              SizedBox(height: timeline != null ? 16 : 12),
              if (timeline != null) ...[
                Text(l10n.plannerTargetCaption, style: AppTextStyles.overline),
                const SizedBox(height: 6),
              ],
              ClipRRect(
                borderRadius: AppRadius.pill,
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: AppColors.stone100,
                  // Lighter shade when it sits below the (forest600) time bar so
                  // the two bars stay distinct; full forest when it's the only
                  // bar (preserves the legacy single-bar look).
                  valueColor: AlwaysStoppedAnimation<Color>(
                      timeline != null ? AppColors.forest300 : AppColors.forest600),
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

            // ── No window AND no target: a quiet in-progress hint ────────
            if (timeline == null && !hasTarget) ...[
              const SizedBox(height: 10),
              Text(l10n.plannerInProgress,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.stone500)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Goal countdown — training-start → goal-date window with a time-left bar ──
// The headline of a dated goal card: a "Training <start> → Goal <date>" line, a
// bar that creeps as the goal date nears, and an "X days left" readout (with
// 0/1-day and not-started edges). Pure presentation over a [GoalTimeline].

class _GoalTimelineSection extends StatelessWidget {
  const _GoalTimelineSection({required this.timeline});
  final GoalTimeline timeline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = DateFormat.MMMd(Intl.defaultLocale);
    final goalStr = fmt.format(timeline.end);
    final rangeText = timeline.start != null
        ? l10n.plannerTimelineRange(fmt.format(timeline.start!), goalStr)
        : l10n.plannerTimelineGoalOnly(goalStr);

    final daysText = timeline.passed
        ? l10n.plannerGoalDatePassed
        : timeline.daysToGoal == 0
            ? l10n.plannerGoalDayToday
            : timeline.daysToGoal == 1
                ? l10n.plannerOneDayLeft
                : l10n.plannerDaysLeft(timeline.daysToGoal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Window line.
        Row(
          children: [
            Icon(Icons.flag_outlined, size: 15, color: AppColors.forest600),
            const SizedBox(width: 6),
            Expanded(
              child: Text(rangeText,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.stone600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Time-left bar (fills as the goal date approaches).
        ClipRRect(
          borderRadius: AppRadius.pill,
          child: LinearProgressIndicator(
            value: timeline.fraction,
            backgroundColor: AppColors.stone100,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.forest600),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        // Days-left readout (+ a quiet "not started" hint when applicable).
        Row(
          children: [
            Icon(Icons.schedule_rounded, size: 14, color: AppColors.forest600),
            const SizedBox(width: 5),
            Flexible(
              child: Text(daysText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.forest600,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            if (timeline.notStarted) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '· ${l10n.plannerTrainingNotStarted}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
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
