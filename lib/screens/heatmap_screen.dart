import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/back_button.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Category filter ──────────────────────────────────────────────────────────

enum _Category { all, journal, cravings, thoughts, movement, sleep }

// ─── Colour helpers ───────────────────────────────────────────────────────────

Color _tileGreen(int count) => switch (count) {
      0 => const Color(0xFFEDE8E1),
      1 => const Color(0xFFD1E8D5),
      2 || 3 => const Color(0xFF8FC49A),
      >= 4 && <= 6 => AppColors.forest400,
      _ => AppColors.forest600,
    };

const _kPreStartColor = Color(0xFFE5DFD8);

// Date key helper — YYYY-MM-DD
String _dk(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ─── Recovery Map Screen ──────────────────────────────────────────────────────

class HeatmapScreen extends ConsumerStatefulWidget {
  const HeatmapScreen({super.key});

  @override
  ConsumerState<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends ConsumerState<HeatmapScreen> {
  _Category _filter = _Category.all;
  bool _showFullYear = false;

  // ── Record-start date ──────────────────────────────────────────────────────
  DateTime _recordStart({
    required UserProfile? profile,
    required List<JournalEntry> journals,
    required List<CravingEntry> cravings,
    required List<ActivityEntry> activities,
    required List<SleepEntry> sleeps,
    required List<ThoughtEntry> thoughts,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (profile != null) {
      final d = DateTime.tryParse(profile.soberDate);
      if (d != null) return DateTime(d.year, d.month, d.day);
    }

    DateTime? earliest;
    void check(DateTime d) {
      final day = DateTime(d.year, d.month, d.day);
      if (earliest == null || day.isBefore(earliest!)) earliest = day;
    }

    for (final e in journals) check(e.date);
    for (final e in cravings) check(e.date);
    for (final e in activities) check(e.date);
    for (final e in sleeps) check(e.date);
    for (final e in thoughts) check(e.date);
    return earliest ?? today;
  }

  // ── Score map: dateKey → count (filtered) ─────────────────────────────────
  Map<String, int> _buildScores({
    required List<JournalEntry> journals,
    required List<CravingEntry> cravings,
    required List<ActivityEntry> activities,
    required List<SleepEntry> sleeps,
    required List<ThoughtEntry> thoughts,
  }) {
    final Map<String, int> s = {};
    void add(DateTime date) {
      final k = _dk(date);
      s[k] = (s[k] ?? 0) + 1;
    }

    if (_filter == _Category.all || _filter == _Category.journal) {
      for (final e in journals) add(e.date);
    }
    if (_filter == _Category.all || _filter == _Category.cravings) {
      for (final e in cravings) add(e.date);
    }
    if (_filter == _Category.all || _filter == _Category.movement) {
      for (final e in activities) add(e.date);
    }
    if (_filter == _Category.all || _filter == _Category.sleep) {
      for (final e in sleeps) add(e.date);
    }
    if (_filter == _Category.all || _filter == _Category.thoughts) {
      for (final e in thoughts) add(e.date);
    }
    return s;
  }

  // ── Summary stats (always all-category) ───────────────────────────────────
  // Returns nullable `mostUsed` so the UI can render "—" when no entries
  // exist (previously defaulted to "Journal", which falsely suggested the
  // user had logged journals when they hadn't).
  ({int careDays, int totalCheckIns, _Category? mostUsed, int thisMonth})
      _stats({
    required DateTime windowStart,
    required DateTime today,
    required List<JournalEntry> journals,
    required List<CravingEntry> cravings,
    required List<ActivityEntry> activities,
    required List<SleepEntry> sleeps,
    required List<ThoughtEntry> thoughts,
  }) {
    bool inWindow(DateTime d) {
      final day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(windowStart) && !day.isAfter(today);
    }

    // Per-day check-in counts within the window (one entry == one tick).
    final Map<String, int> all = {};
    void add(DateTime date) {
      if (!inWindow(date)) return;
      final day = DateTime(date.year, date.month, date.day);
      final k = _dk(day);
      all[k] = (all[k] ?? 0) + 1;
    }

    for (final e in journals) add(e.date);
    for (final e in cravings) add(e.date);
    for (final e in activities) add(e.date);
    for (final e in sleeps) add(e.date);
    for (final e in thoughts) add(e.date);

    final careDays = all.length; // every key in `all` already has value > 0
    final totalCheckIns = all.values.fold(0, (a, b) => a + b);

    // Per-category counts, used to pick the most-used category.
    final counts = {
      _Category.journal: journals.where((e) => inWindow(e.date)).length,
      _Category.cravings: cravings.where((e) => inWindow(e.date)).length,
      _Category.movement: activities.where((e) => inWindow(e.date)).length,
      _Category.sleep: sleeps.where((e) => inWindow(e.date)).length,
      _Category.thoughts: thoughts.where((e) => inWindow(e.date)).length,
    };
    _Category? mostUsed;
    var maxCount = 0;
    counts.forEach((cat, n) {
      if (n > maxCount) {
        maxCount = n;
        mostUsed = cat;
      }
    });

    // "This month" mirrors "Total check-ins" but scoped to the current
    // calendar month — total entries, not unique days. Previously this
    // counted unique-days-with-anything, which both undercounted active
    // months and conflicted with the meaning of the other tiles.
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    int thisMonth = 0;
    for (final entry in all.entries) {
      final d = DateTime.tryParse(entry.key);
      if (d == null) continue;
      if (!d.isBefore(monthStart) && !d.isAfter(monthEnd)) {
        thisMonth += entry.value;
      }
    }

    return (
      careDays: careDays,
      totalCheckIns: totalCheckIns,
      mostUsed: mostUsed,
      thisMonth: thisMonth,
    );
  }

  String _catLabel(_Category cat, AppLocalizations l10n) => switch (cat) {
        _Category.all => 'All',
        _Category.journal => l10n.heatmapCategoryJournal,
        _Category.cravings => 'Cravings',
        _Category.thoughts => 'Thoughts',
        _Category.movement => 'Movement',
        _Category.sleep => l10n.heatmapCategorySleep,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(profileProvider).valueOrNull;
    final journals = ref.watch(journalProvider).valueOrNull ?? [];
    final cravings = ref.watch(cravingProvider).valueOrNull ?? [];
    final activities = ref.watch(activityProvider).valueOrNull ?? [];
    final sleeps = ref.watch(sleepProvider).valueOrNull ?? [];
    final thoughts = ref.watch(thoughtProvider).valueOrNull ?? [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final recordStart = _recordStart(
      profile: profile,
      journals: journals,
      cravings: cravings,
      activities: activities,
      sleeps: sleeps,
      thoughts: thoughts,
    );

    final daysSinceStart = today.difference(recordStart).inDays;
    final isLongUser = daysSinceStart >= 365;
    final windowStart =
        isLongUser ? today.subtract(const Duration(days: 364)) : recordStart;

    final subtitle = isLongUser
        ? 'Last 365 days · A quiet record of the days you showed up.'
        : 'Since you began · A quiet record of the days you showed up.';

    final scores = _buildScores(
      journals: journals,
      cravings: cravings,
      activities: activities,
      sleeps: sleeps,
      thoughts: thoughts,
    );

    final st = _stats(
      windowStart: windowStart,
      today: today,
      journals: journals,
      cravings: cravings,
      activities: activities,
      sleeps: sleeps,
      thoughts: thoughts,
    );

    // Months to display — newest first
    final months = _showFullYear
        ? List.generate(12, (i) => DateTime(now.year, now.month - i, 1))
        : [
            DateTime(now.year, now.month, 1),
            DateTime(now.year, now.month - 1, 1),
          ];

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LuxuryBackButton(),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recovery Map',
                                  style: AppTextStyles.greetingSerif.copyWith(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.forestDark,
                                  )),
                              const SizedBox(height: 6),
                              Text(subtitle,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.stone600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Summary card ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SummaryCard(
                  careDays: st.careDays,
                  totalCheckIns: st.totalCheckIns,
                  mostUsed:
                      st.mostUsed == null ? '—' : _catLabel(st.mostUsed!, l10n),
                  thisMonth: st.thisMonth,
                ),
              ),
            ),

            // ── Filter chips ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 0, 0),
                child: _FilterChips(
                  selected: _filter,
                  onSelect: (cat) {
                    H.selection();
                    setState(() => _filter = cat);
                  },
                  catLabel: (cat) => _catLabel(cat, l10n),
                ),
              ),
            ),

            // ── Monthly cards ─────────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final month = months[i];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, i == 0 ? 16 : 12, 20, 0),
                    child: _MonthCard(
                      month: month,
                      scores: scores,
                      recordStart: recordStart,
                      today: today,
                      onTapDay: (date) {
                        H.selection();
                        _showDaySheet(
                          context,
                          date: date,
                          journals: journals
                              .where((e) => _dk(e.date) == _dk(date))
                              .toList(),
                          cravings: cravings
                              .where((e) => _dk(e.date) == _dk(date))
                              .toList(),
                          activities: activities
                              .where((e) => _dk(e.date) == _dk(date))
                              .toList(),
                          sleeps: sleeps
                              .where((e) => _dk(e.date) == _dk(date))
                              .toList(),
                          thoughts: thoughts
                              .where((e) => _dk(e.date) == _dk(date))
                              .toList(),
                          recordStart: recordStart,
                        );
                      },
                    ),
                  );
                },
                childCount: months.length,
              ),
            ),

            // ── See full year / Show less ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GestureDetector(
                  onTap: () {
                    H.light();
                    setState(() => _showFullYear = !_showFullYear);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showFullYear ? 'Show less' : 'See full year',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.forest600),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showFullYear
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.forest600,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Legend ────────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 48),
                child: _LegendBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.careDays,
    required this.totalCheckIns,
    required this.mostUsed,
    required this.thisMonth,
  });

  final int careDays, totalCheckIns, thisMonth;
  final String mostUsed;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.eco_outlined,
                    label: 'Care days',
                    value: '$careDays',
                  ),
                ),
                VerticalDivider(
                    color: AppColors.stone100, width: 1, thickness: 1),
                Expanded(
                  child: _StatCell(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Total check-ins',
                    value: '$totalCheckIns',
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.stone100, height: 1, thickness: 1),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.spa_outlined,
                    label: 'Most used',
                    value: mostUsed,
                    isText: true,
                  ),
                ),
                VerticalDivider(
                    color: AppColors.stone100, width: 1, thickness: 1),
                Expanded(
                  child: _StatCell(
                    icon: Icons.calendar_today_outlined,
                    label: 'This month',
                    value: '$thisMonth',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
    this.isText = false,
  });

  final IconData icon;
  final String label, value;
  final bool isText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.forest50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AppColors.forest600),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.stone500)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: isText
                      ? AppTextStyles.titleMedium
                          .copyWith(color: AppColors.forestDark)
                      : AppTextStyles.displaySmall.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: AppColors.forestDark,
                          height: 1.1,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onSelect,
    required this.catLabel,
  });

  final _Category selected;
  final ValueChanged<_Category> onSelect;
  final String Function(_Category) catLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        children: _Category.values.map((cat) {
          final active = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(cat),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.forest700 : AppColors.card,
                  borderRadius: AppRadius.pill,
                  border: Border.all(
                    color: active ? AppColors.forest700 : AppColors.stone200,
                  ),
                ),
                child: Text(
                  catLabel(cat),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: active ? Colors.white : AppColors.stone600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Monthly card ─────────────────────────────────────────────────────────────

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.scores,
    required this.recordStart,
    required this.today,
    required this.onTapDay,
  });

  final DateTime month; // first day of the month
  final Map<String, int> scores;
  final DateTime recordStart;
  final DateTime today;
  final ValueChanged<DateTime> onTapDay;

  int _careDaysInMonth() {
    final last = DateTime(month.year, month.month + 1, 0);
    var count = 0;
    for (var d = DateTime(month.year, month.month, 1);
        !d.isAfter(last) && !d.isAfter(today);
        d = d.add(const Duration(days: 1))) {
      if (!d.isBefore(recordStart) && (scores[_dk(d)] ?? 0) > 0) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1; // Mon=0 offset
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final monthLabel = DateFormat('MMMM yyyy').format(month);
    final careDays = _careDaysInMonth();

    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month title + care-days count
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
              Text('$careDays days',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.forest600)),
            ],
          ),
          const SizedBox(height: 12),
          // Day-of-week headers
          const Row(
            children: [
              _DowLabel('M'),
              _DowLabel('T'),
              _DowLabel('W'),
              _DowLabel('T'),
              _DowLabel('F'),
              _DowLabel('S'),
              _DowLabel('S'),
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
                        final date = DateTime(month.year, month.month, dayNum);
                        final isFuture = date.isAfter(today);
                        final isPreStart = date.isBefore(recordStart);
                        final isToday = _dk(date) == _dk(today);
                        final count = scores[_dk(date)] ?? 0;

                        tile = _DayTile(
                          date: date,
                          count: count,
                          isFuture: isFuture,
                          isPreStart: isPreStart,
                          isToday: isToday,
                          size: cellSize,
                          onTap: (!isFuture && !isPreStart)
                              ? () => onTapDay(date)
                              : null,
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
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.stone400)),
      ),
    );
  }
}

// ─── Day tile ─────────────────────────────────────────────────────────────────

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.date,
    required this.count,
    required this.isFuture,
    required this.isPreStart,
    required this.isToday,
    required this.size,
    required this.onTap,
  });

  final DateTime date;
  final int count;
  final bool isFuture, isPreStart, isToday;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    if (isPreStart) {
      bg = _kPreStartColor;
    } else if (isFuture) {
      bg = AppColors.stone50;
    } else {
      bg = _tileGreen(count);
    }

    final textColor = (!isPreStart && !isFuture && count >= 4)
        ? Colors.white
        : isPreStart
            ? AppColors.stone300
            : isFuture
                ? AppColors.stone200
                : AppColors.stone700;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(7),
          border: isToday && !isPreStart && !isFuture
              ? Border.all(color: AppColors.forest500, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: size < 34 ? 10 : 11,
              fontWeight: (!isPreStart && !isFuture && count > 0)
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: textColor,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Legend bar ───────────────────────────────────────────────────────────────

class _LegendBar extends StatelessWidget {
  const _LegendBar();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendSwatch(
            color: _kPreStartColor, label: 'Before you began', bordered: true),
        _LegendSwatch(color: Color(0xFFEDE8E1), label: 'No entry'),
        _LegendSwatch(color: Color(0xFFD1E8D5), label: '1'),
        _LegendSwatch(color: Color(0xFF8FC49A), label: '2–3'),
        _LegendSwatch(color: AppColors.forest400, label: '4–6'),
        _LegendSwatch(color: AppColors.forest600, label: '7+'),
      ],
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch(
      {required this.color, required this.label, this.bordered = false});
  final Color color;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: bordered ? Border.all(color: AppColors.stone300) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.stone500)),
      ],
    );
  }
}

// ─── Day detail bottom sheet ──────────────────────────────────────────────────

void _showDaySheet(
  BuildContext context, {
  required DateTime date,
  required List<JournalEntry> journals,
  required List<CravingEntry> cravings,
  required List<ActivityEntry> activities,
  required List<SleepEntry> sleeps,
  required List<ThoughtEntry> thoughts,
  required DateTime recordStart,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DaySheet(
      date: date,
      journals: journals,
      cravings: cravings,
      activities: activities,
      sleeps: sleeps,
      thoughts: thoughts,
      recordStart: recordStart,
    ),
  );
}

class _DaySheet extends StatelessWidget {
  const _DaySheet({
    required this.date,
    required this.journals,
    required this.cravings,
    required this.activities,
    required this.sleeps,
    required this.thoughts,
    required this.recordStart,
  });

  final DateTime date;
  final List<JournalEntry> journals;
  final List<CravingEntry> cravings;
  final List<ActivityEntry> activities;
  final List<SleepEntry> sleeps;
  final List<ThoughtEntry> thoughts;
  final DateTime recordStart;

  @override
  Widget build(BuildContext context) {
    final hasAnything = journals.isNotEmpty ||
        cravings.isNotEmpty ||
        activities.isNotEmpty ||
        sleeps.isNotEmpty ||
        thoughts.isNotEmpty;

    final dateLabel = DateFormat('EEEE, d MMMM yyyy').format(date);

    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.stone200,
                borderRadius: AppRadius.pill,
              ),
            ),
          ),
          Text(dateLabel,
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.forest700)),
          const SizedBox(height: 16),
          if (!hasAnything) ...[
            Text('No entry recorded.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.forestDark)),
            const SizedBox(height: 4),
            Text('A quiet day still counts.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone500)),
          ] else ...[
            if (journals.isNotEmpty) ...[
              const _SheetSection(
                  icon: Icons.menu_book_outlined, label: 'Journal'),
              ...journals.map((j) => _SheetRow(
                  text: j.text.isNotEmpty ? j.text : '(entry)',
                  sub: j.mood.isNotEmpty ? j.mood : null)),
              const SizedBox(height: 10),
            ],
            if (cravings.isNotEmpty) ...[
              const _SheetSection(
                  icon: Icons.bolt_outlined, label: 'Craving support'),
              ...cravings.map((c) => _SheetRow(
                  text: 'Intensity ${c.intensity}/10', sub: c.trigger)),
              const SizedBox(height: 10),
            ],
            if (thoughts.isNotEmpty) ...[
              const _SheetSection(
                  icon: Icons.psychology_outlined, label: 'Thoughts'),
              ...thoughts.map((t) => _SheetRow(
                  text: t.text.isNotEmpty ? t.text : '(thought — ${t.type})',
                  sub: t.strength)),
              const SizedBox(height: 10),
            ],
            if (activities.isNotEmpty) ...[
              const _SheetSection(
                  icon: Icons.directions_run_outlined, label: 'Movement'),
              ...activities.map((a) => _SheetRow(
                  text: '${a.activity} · ${a.minutes} min', sub: a.effort)),
              const SizedBox(height: 10),
            ],
            if (sleeps.isNotEmpty) ...[
              const _SheetSection(icon: Icons.bedtime_outlined, label: 'Sleep'),
              ...sleeps.map((s) =>
                  _SheetRow(text: '${s.hours}h · quality ${s.quality}/5')),
              const SizedBox(height: 10),
            ],
            Divider(color: AppColors.stone100, height: 20),
            Text(
              'You showed up for yourself today.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.forest600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.forest500),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.forest500, fontSize: 9)),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.text, this.sub});
  final String text;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('· ',
              style: TextStyle(color: AppColors.stone300, fontSize: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.stone700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (sub != null && sub!.isNotEmpty)
                  Text(sub!,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.stone400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
