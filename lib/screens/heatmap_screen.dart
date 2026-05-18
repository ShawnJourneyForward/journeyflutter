import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

// ─── Heatmap Screen ───────────────────────────────────────────────────────────

class HeatmapScreen extends ConsumerStatefulWidget {
  const HeatmapScreen({super.key});

  @override
  ConsumerState<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends ConsumerState<HeatmapScreen> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final journals   = ref.watch(journalProvider).valueOrNull  ?? [];
    final cravings   = ref.watch(cravingProvider).valueOrNull  ?? [];
    final activities = ref.watch(activityProvider).valueOrNull ?? [];
    final sleeps     = ref.watch(sleepProvider).valueOrNull    ?? [];

    // Build a day-keyed map: 'YYYY-MM-DD' → bitmask of what was logged
    // bit 0 = journal, 1 = craving, 2 = activity, 3 = sleep
    final Map<String, int> scores = {};

    for (final e in journals)   { _set(scores, e.date, 0); }
    for (final e in cravings)   { _set(scores, e.date, 1); }
    for (final e in activities) { _set(scores, e.date, 2); }
    for (final e in sleeps)     { _set(scores, e.date, 3); }

    // Build the 91-day grid (13 weeks, starting from Monday 13 weeks ago)
    final today = DateTime.now();
    final todayKey = _key(today);

    // Align start to the most recent Sunday so grid columns start on Sunday
    final weekday = today.weekday % 7; // Sunday=0, Mon=1, …, Sat=6
    final gridStart = _dateOnly(today.subtract(Duration(days: weekday + 12 * 7)));
    const totalDays = 91;

    // Organise into 13 columns of 7
    final weeks = List.generate(13, (w) {
      return List.generate(7, (d) {
        return gridStart.add(Duration(days: w * 7 + d));
      });
    });

    // Detail for the selected day
    final selKey = _selected == null ? null : _key(_selected!);
    final selJournals   = selKey == null ? <JournalEntry>[]   : journals.where((e) => _key(e.date) == selKey).toList();
    final selCravings   = selKey == null ? <CravingEntry>[]   : cravings.where((e) => _key(e.date) == selKey).toList();
    final selActivities = selKey == null ? <ActivityEntry>[]  : activities.where((e) => _key(e.date) == selKey).toList();
    final selSleeps     = selKey == null ? <SleepEntry>[]     : sleeps.where((e) => _key(e.date) == selKey).toList();

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Header ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: AppColors.stone700),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.heatmapTitle,
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: AppColors.forest700)),
                          Text(l10n.heatmapSubtitle,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Legend ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _LegendRow(scores: scores, totalDays: totalDays),
              ),
            ),

            // ── Grid ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _HeatmapGrid(
                  weeks: weeks,
                  scores: scores,
                  todayKey: todayKey,
                  selectedKey: selKey,
                  onTap: (day) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selected = (_selected != null && _key(_selected!) == _key(day))
                          ? null
                          : day;
                    });
                  },
                ),
              ),
            ),

            // ── Day detail card ───────────────────────────────────────────────
            if (_selected != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _DayDetailCard(
                    date: _selected!,
                    journals: selJournals,
                    cravings: selCravings,
                    activities: selActivities,
                    sleeps: selSleeps,
                  ),
                ),
              ),

            // ── Category key ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                child: _CategoryKey(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _set(Map<String, int> scores, DateTime date, int bit) {
    final k = _key(date);
    scores[k] = (scores[k] ?? 0) | (1 << bit);
  }

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

// ─── Heatmap grid ─────────────────────────────────────────────────────────────

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({
    required this.weeks,
    required this.scores,
    required this.todayKey,
    required this.selectedKey,
    required this.onTap,
  });

  final List<List<DateTime>> weeks;
  final Map<String, int> scores;
  final String todayKey;
  final String? selectedKey;
  final ValueChanged<DateTime> onTap;

  static const _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _cellSize = 28.0;
  static const _gap = 3.0;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month labels
          _MonthLabels(weeks: weeks),
          const SizedBox(height: 6),

          // Grid body: day-of-week labels + cells
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels column
              Column(
                children: List.generate(7, (d) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: _gap),
                    child: SizedBox(
                      width: 14,
                      height: _cellSize,
                      child: Center(
                        child: Text(_days[d],
                            style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.stone400, fontSize: 9)),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 4),

              // Week columns
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: weeks.map((week) {
                      return Padding(
                        padding: const EdgeInsets.only(right: _gap),
                        child: Column(
                          children: week.map((day) {
                            final k = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                            final score = scores[k] ?? 0;
                            final isToday = k == todayKey;
                            final isSelected = k == selectedKey;
                            final isFuture = day.isAfter(DateTime.now());

                            return GestureDetector(
                              onTap: isFuture ? null : () => onTap(day),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: _gap),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: _cellSize,
                                  height: _cellSize,
                                  decoration: BoxDecoration(
                                    color: isFuture
                                        ? AppColors.stone100
                                        : _cellColor(score),
                                    borderRadius: BorderRadius.circular(5),
                                    border: isSelected
                                        ? Border.all(
                                            color: AppColors.honey500,
                                            width: 2,
                                          )
                                        : isToday
                                            ? Border.all(
                                                color: AppColors.forest400,
                                                width: 2,
                                              )
                                            : null,
                                  ),
                                  child: score > 0 && !isFuture
                                      ? Center(
                                          child: Text(
                                            '${_popcount(score)}',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: score >= 0xC
                                                  ? Colors.white
                                                  : AppColors.forest700,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _cellColor(int score) {
    final count = _popcount(score);
    return switch (count) {
      0 => AppColors.stone100,
      1 => const Color(0xFFD1E8D5), // very light forest
      2 => const Color(0xFF8FC49A), // light forest
      3 => AppColors.forest400,
      _ => AppColors.forest600,
    };
  }

  static int _popcount(int n) {
    var count = 0;
    var x = n;
    while (x > 0) { count += x & 1; x >>= 1; }
    return count;
  }
}

// ─── Month labels ─────────────────────────────────────────────────────────────

class _MonthLabels extends StatelessWidget {
  const _MonthLabels({required this.weeks});
  final List<List<DateTime>> weeks;

  @override
  Widget build(BuildContext context) {
    // Show month name at the first week where a new month starts
    return Row(
      children: [
        const SizedBox(width: 18), // align with grid
        Expanded(
          child: Row(
            children: weeks.map((week) {
              final first = week.first;
              final showLabel = first.day <= 7;
              return SizedBox(
                width: 31, // cellSize + gap
                child: showLabel
                    ? Text(
                        DateFormat('MMM').format(first),
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.forest500, fontSize: 9),
                      )
                    : null,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Legend row ───────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.scores, required this.totalDays});
  final Map<String, int> scores;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeDays = scores.entries.where((e) => e.value > 0).length;
    final pct = totalDays > 0 ? (activeDays / totalDays * 100).round() : 0;

    return LuxuryCard(
      backgroundColor: AppColors.forest800,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.heatmapActiveDaysLabel,
                    style: AppTextStyles.overline
                        .copyWith(color: AppColors.forest300, fontSize: 10)),
                const SizedBox(height: 4),
                Text(l10n.heatmapActiveDaysCount(activeDays, totalDays),
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: AppRadius.pill,
                  child: LinearProgressIndicator(
                    value: totalDays > 0 ? activeDays / totalDays : 0,
                    minHeight: 5,
                    backgroundColor: AppColors.forest700,
                    color: AppColors.honey400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.forest700,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.forest600),
            ),
            child: Center(
              child: Text('$pct%',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.honey300)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category key ─────────────────────────────────────────────────────────────

class _CategoryKey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (Icons.menu_book_outlined,      l10n.heatmapCategoryJournal,  AppColors.forest600),
      (Icons.bolt_outlined,           l10n.heatmapCategoryCraving,  AppColors.forest600),
      (Icons.directions_run_outlined, l10n.heatmapCategoryActivity, AppColors.forest600),
      (Icons.bedtime_outlined,        l10n.heatmapCategorySleep,    AppColors.forest600),
    ];

    return LuxuryCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.heatmapWhatCountsLabel,
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.stone400, fontSize: 10)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: items.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.$1, size: 14, color: AppColors.forest500),
                  const SizedBox(width: 5),
                  Text(item.$2,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone600)),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.stone100, height: 1),
          const SizedBox(height: 10),
          const Row(
            children: [
              _Swatch(color: AppColors.stone100, label: 'Nothing'),
              SizedBox(width: 10),
              _Swatch(color: Color(0xFFD1E8D5), label: '1'),
              SizedBox(width: 10),
              _Swatch(color: Color(0xFF8FC49A), label: '2'),
              SizedBox(width: 10),
              _Swatch(color: AppColors.forest400, label: '3'),
              SizedBox(width: 10),
              _Swatch(color: AppColors.forest600, label: '4'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.stone500, fontSize: 10)),
      ],
    );
  }
}

// ─── Day detail card ──────────────────────────────────────────────────────────

class _DayDetailCard extends StatelessWidget {
  const _DayDetailCard({
    required this.date,
    required this.journals,
    required this.cravings,
    required this.activities,
    required this.sleeps,
  });

  final DateTime date;
  final List<JournalEntry> journals;
  final List<CravingEntry> cravings;
  final List<ActivityEntry> activities;
  final List<SleepEntry> sleeps;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasAnything =
        journals.isNotEmpty || cravings.isNotEmpty ||
        activities.isNotEmpty || sleeps.isNotEmpty;

    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMMM d').format(date),
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.forest700),
                ),
              ),
              const Icon(Icons.close_rounded,
                  size: 16, color: AppColors.stone300),
            ],
          ),
          const SizedBox(height: 12),

          if (!hasAnything)
            Text(l10n.heatmapNothingLogged,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone400)),

          if (journals.isNotEmpty) ...[
            _SectionLabel(Icons.menu_book_outlined, l10n.heatmapCategoryJournal),
            ...journals.map((j) => _DetailRow(
                  text: j.text,
                  sub: j.mood,
                )),
            const SizedBox(height: 8),
          ],

          if (cravings.isNotEmpty) ...[
            const _SectionLabel(Icons.bolt_outlined, 'Cravings'),
            ...cravings.map((c) => _DetailRow(
                  text: l10n.heatmapIntensityFormat(c.intensity),
                  sub: c.trigger,
                )),
            const SizedBox(height: 8),
          ],

          if (activities.isNotEmpty) ...[
            _SectionLabel(Icons.directions_run_outlined, l10n.heatmapCategoryActivity),
            ...activities.map((a) => _DetailRow(
                  text: l10n.heatmapActivityFormat(a.activity, a.minutes),
                  sub: a.effort,
                )),
            const SizedBox(height: 8),
          ],

          if (sleeps.isNotEmpty) ...[
            _SectionLabel(Icons.bedtime_outlined, l10n.heatmapCategorySleep),
            ...sleeps.map((s) => _DetailRow(
                  text: l10n.heatmapSleepFormat(s.hours.toString(), s.quality),
                  sub: null,
                )),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.forest500),
          const SizedBox(width: 5),
          Text(label.toUpperCase(),
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.forest500, fontSize: 9)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.text, required this.sub});
  final String text;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('·  ', style: TextStyle(color: AppColors.stone300)),
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
