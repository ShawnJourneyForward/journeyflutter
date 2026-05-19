import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Heatmap Screen ───────────────────────────────────────────────────────────

class HeatmapScreen extends ConsumerStatefulWidget {
  const HeatmapScreen({super.key});

  @override
  ConsumerState<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends ConsumerState<HeatmapScreen> {
  DateTime? _selected;

  // Grid shape is fixed for the lifetime of this screen (computed once).
  late final DateTime _today;
  late final String _todayKey;
  late final List<List<DateTime>> _weeks;
  static const _totalDays = 91;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _todayKey = _key(_today);
    final weekday = _today.weekday % 7; // Sunday=0
    final gridStart = _dateOnly(_today.subtract(Duration(days: weekday + 12 * 7)));
    _weeks = List.generate(13, (w) =>
        List.generate(7, (d) => gridStart.add(Duration(days: w * 7 + d))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final journals   = ref.watch(journalProvider).valueOrNull      ?? [];
    final cravings   = ref.watch(cravingProvider).valueOrNull      ?? [];
    final activities = ref.watch(activityProvider).valueOrNull     ?? [];
    final sleeps     = ref.watch(sleepProvider).valueOrNull        ?? [];
    final thoughts   = ref.watch(thoughtProvider).valueOrNull      ?? [];
    final gratitudes = ref.watch(allGratitudeProvider).valueOrNull ?? [];

    // Build a day-keyed map: 'YYYY-MM-DD' → total number of entries logged
    final Map<String, int> scores = {};
    for (final e in journals)   { _inc(scores, e.date); }
    for (final e in cravings)   { _inc(scores, e.date); }
    for (final e in activities) { _inc(scores, e.date); }
    for (final e in sleeps)     { _inc(scores, e.date); }
    for (final e in thoughts)   { _inc(scores, e.date); }
    // Gratitude entries are a meaningful wellness signal — include in the score.
    for (final e in gratitudes) {
      final d = DateTime.tryParse(e.date);
      if (d != null) _inc(scores, d);
    }

    // Detail for the selected day
    final selKey = _selected == null ? null : _key(_selected!);
    final selJournals   = selKey == null ? <JournalEntry>[]  : journals.where((e) => _key(e.date) == selKey).toList();
    final selCravings   = selKey == null ? <CravingEntry>[]  : cravings.where((e) => _key(e.date) == selKey).toList();
    final selActivities = selKey == null ? <ActivityEntry>[] : activities.where((e) => _key(e.date) == selKey).toList();
    final selSleeps     = selKey == null ? <SleepEntry>[]    : sleeps.where((e) => _key(e.date) == selKey).toList();
    final selThoughts   = selKey == null ? <ThoughtEntry>[]  : thoughts.where((e) => _key(e.date) == selKey).toList();

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
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
                        H.light();
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
                child: _LegendRow(scores: scores, totalDays: _totalDays),
              ),
            ),

            // ── Grid ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _HeatmapGrid(
                  weeks: _weeks,
                  scores: scores,
                  todayKey: _todayKey,
                  selectedKey: selKey,
                  onTap: (day) {
                    H.selection();
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
                    thoughts: selThoughts,
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

  void _inc(Map<String, int> scores, DateTime date) {
    final k = _key(date);
    scores[k] = (scores[k] ?? 0) + 1;
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
  static const _gap = 3.0;
  static const _dayLabelW = 12.0;
  static const _dayLabelGap = 4.0;

  // Format key without calling DateTime allocation
  static String _k(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      // LayoutBuilder gives us the post-padding inner width so we can size
      // cells to fill exactly — no horizontal SingleChildScrollView needed.
      child: LayoutBuilder(builder: (context, constraints) {
        final numCols = weeks.length;
        // Include a trailing gap for every column so the total exactly
        // equals: dayLabelW + dayLabelGap + numCols*stride (no overflow).
        final cellSize = ((constraints.maxWidth -
                    _dayLabelW -
                    _dayLabelGap -
                    _gap * numCols) /
                numCols)
            .clamp(14.0, 28.0);
        final stride = cellSize + _gap;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MonthLabels(
              weeks: weeks,
              stride: stride,
              offset: _dayLabelW + _dayLabelGap,
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day-of-week label column
                Column(
                  children: List.generate(7, (d) {
                    return SizedBox(
                      width: _dayLabelW,
                      height: cellSize + _gap,
                      child: Center(
                        child: Text(_days[d],
                            style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.stone400, fontSize: 9)),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: _dayLabelGap),
                // Week columns — fixed width, no horizontal scroll
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: weeks.map((week) {
                    return SizedBox(
                      width: stride,
                      child: Column(
                        children: week.map((day) {
                          final k = _k(day);
                          final score = scores[k] ?? 0;
                          final isToday = k == todayKey;
                          final isSelected = k == selectedKey;
                          final isFuture = day.isAfter(DateTime.now());

                          return GestureDetector(
                            onTap: isFuture ? null : () => onTap(day),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: _gap),
                              child: Container(
                                width: cellSize,
                                height: cellSize,
                                decoration: BoxDecoration(
                                  color: isFuture
                                      ? AppColors.stone100
                                      : _cellColor(score),
                                  borderRadius: BorderRadius.circular(4),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.honey500, width: 2)
                                      : isToday
                                          ? Border.all(
                                              color: AppColors.forest400,
                                              width: 2)
                                          : null,
                                ),
                                child: score > 0 && !isFuture
                                    ? Center(
                                        child: Text(
                                          score > 9 ? '9+' : '$score',
                                          style: TextStyle(
                                            fontSize: cellSize < 20 ? 7 : 9,
                                            fontWeight: FontWeight.w700,
                                            color: score >= 4
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
              ],
            ),
          ],
        );
      }),
    );
  }

  static Color _cellColor(int count) {
    return switch (count) {
      0            => AppColors.stone100,
      1            => const Color(0xFFD1E8D5),
      2 || 3       => const Color(0xFF8FC49A),
      >= 4 && <= 6 => AppColors.forest400,
      _            => AppColors.forest600,
    };
  }
}

// ─── Month labels ─────────────────────────────────────────────────────────────

class _MonthLabels extends StatelessWidget {
  const _MonthLabels({
    required this.weeks,
    required this.stride,
    required this.offset,
  });

  final List<List<DateTime>> weeks;
  final double stride; // cellSize + gap — matches each week column's width
  final double offset; // day-label area to skip before the first week column

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: offset),
        ...weeks.map((week) {
          final first = week.first;
          final showLabel = first.day <= 7;
          return SizedBox(
            width: stride,
            child: showLabel
                ? Text(
                    DateFormat('MMM').format(first),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.forest500, fontSize: 9),
                    overflow: TextOverflow.clip,
                  )
                : const SizedBox.shrink(),
          );
        }),
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
      (Icons.psychology_outlined,     'Thoughts',                    AppColors.forest600),
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
              _Swatch(color: AppColors.stone100, label: '0'),
              SizedBox(width: 10),
              _Swatch(color: Color(0xFFD1E8D5), label: '1'),
              SizedBox(width: 10),
              _Swatch(color: Color(0xFF8FC49A), label: '2–3'),
              SizedBox(width: 10),
              _Swatch(color: AppColors.forest400, label: '4–6'),
              SizedBox(width: 10),
              _Swatch(color: AppColors.forest600, label: '7+'),
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
    required this.thoughts,
  });

  final DateTime date;
  final List<JournalEntry> journals;
  final List<CravingEntry> cravings;
  final List<ActivityEntry> activities;
  final List<SleepEntry> sleeps;
  final List<ThoughtEntry> thoughts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasAnything =
        journals.isNotEmpty || cravings.isNotEmpty ||
        activities.isNotEmpty || sleeps.isNotEmpty || thoughts.isNotEmpty;

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
            const SizedBox(height: 8),
          ],

          if (thoughts.isNotEmpty) ...[
            const _SectionLabel(Icons.chat_bubble_outline_rounded, 'Thoughts'),
            ...thoughts.map((t) => _DetailRow(
                  text: t.text,
                  sub: t.strength,
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
