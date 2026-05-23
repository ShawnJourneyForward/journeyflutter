import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import '../utils/secure_window.dart';

// ─── Local entry model ────────────────────────────────────────────────────────

enum _EntryType { journal, gratitude, craving, thought, exercise, sleep, slip }

class _HistoryEntry {
  final _EntryType type;
  final DateTime date;
  final String id;
  final Object data;

  const _HistoryEntry({
    required this.type,
    required this.date,
    required this.id,
    required this.data,
  });
}

// ─── Mood helpers ─────────────────────────────────────────────────────────────

Color _moodColor(String mood) => switch (mood) {
      'great' => AppColors.forest600,
      'good' => AppColors.forest400,
      'okay' => AppColors.honey500,
      'hard' => AppColors.honey600,
      'crisis' => AppColors.blush500,
      _ => AppColors.stone400,
    };

String _moodLabel(String mood) => switch (mood) {
      'great' => 'Great',
      'good' => 'Good',
      'okay' => 'Okay',
      'hard' => 'Hard day',
      'crisis' => 'Crisis',
      _ => mood,
    };

// ─── History Screen ───────────────────────────────────────────────────────────

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filter = 'all';
  String _search = '';
  final Set<String> _expanded = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    SecureWindow.enable();
  }

  @override
  void dispose() {
    SecureWindow.disable();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ─── Date label ─────────────────────────────────────────────────────────────

  String _dateLabel(DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return l10n.historyToday;
    if (d == yesterday) return l10n.historyYesterday;
    if (d.year == now.year) return DateFormat('d MMM').format(date);
    return DateFormat('d MMM yyyy').format(date);
  }

  // ─── Week boundary ───────────────────────────────────────────────────────────

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return date.isAfter(weekAgo);
  }

  // ─── Build unified entry list ────────────────────────────────────────────────

  List<_HistoryEntry> _buildEntries({
    required List<JournalEntry> journal,
    required List<GratitudeEntry> gratitude,
    required List<CravingEntry> cravings,
    required List<ThoughtEntry> thoughts,
    required List<ActivityEntry> activities,
    required List<SleepEntry> sleepEntries,
    required List<Slip> slips,
  }) {
    final entries = <_HistoryEntry>[];

    if (_filter == 'all' || _filter == 'journal') {
      for (final e in journal) {
        if (_search.isNotEmpty &&
            !e.text.toLowerCase().contains(_search.toLowerCase()) &&
            !_moodLabel(e.mood).toLowerCase().contains(_search.toLowerCase())) {
          continue;
        }
        entries.add(_HistoryEntry(
          type: _EntryType.journal,
          date: e.date,
          id: e.id,
          data: e,
        ));
      }
    }

    if (_filter == 'all' || _filter == 'gratitude') {
      for (final e in gratitude) {
        if (_search.isNotEmpty &&
            !e.text.toLowerCase().contains(_search.toLowerCase())) {
          continue;
        }
        final date = DateTime.tryParse(e.date) ?? DateTime.now();
        entries.add(_HistoryEntry(
          type: _EntryType.gratitude,
          date: date,
          id: e.id,
          data: e,
        ));
      }
    }

    if (_filter == 'all' || _filter == 'cravings') {
      for (final e in cravings) {
        final searchable = [
          e.trigger ?? '',
          e.severity ?? '',
          ...e.triggers,
          e.notes ?? '',
        ].join(' ');
        if (_search.isNotEmpty &&
            !searchable.toLowerCase().contains(_search.toLowerCase())) {
          continue;
        }
        entries.add(_HistoryEntry(
          type: _EntryType.craving,
          date: e.date,
          id: e.id,
          data: e,
        ));
      }
    }

    if (_filter == 'all' || _filter == 'thoughts') {
      for (final e in thoughts) {
        final searchable = [
          e.text,
          e.type,
          e.strength ?? '',
          ...e.triggers,
          e.notes ?? '',
        ].join(' ');
        if (_search.isNotEmpty &&
            !searchable.toLowerCase().contains(_search.toLowerCase())) {
          continue;
        }
        entries.add(_HistoryEntry(
          type: _EntryType.thought,
          date: e.date,
          id: e.id,
          data: e,
        ));
      }
    }

    if (_filter == 'all' || _filter == 'exercise') {
      for (final e in activities) {
        final searchable = [
          e.activity,
          e.effort ?? '',
          e.outcome ?? '',
          e.notes ?? '',
        ].join(' ');
        if (_search.isNotEmpty &&
            !searchable.toLowerCase().contains(_search.toLowerCase())) {
          continue;
        }
        entries.add(_HistoryEntry(
          type: _EntryType.exercise,
          date: e.date,
          id: e.id,
          data: e,
        ));
      }
    }

    if (_filter == 'all' || _filter == 'sleep') {
      for (final e in sleepEntries) {
        final searchable = [
          ...e.factors,
          e.notes ?? '',
        ].join(' ');
        if (_search.isNotEmpty &&
            !searchable.toLowerCase().contains(_search.toLowerCase())) {
          continue;
        }
        entries.add(_HistoryEntry(
          type: _EntryType.sleep,
          date: e.date,
          id: e.id,
          data: e,
        ));
      }
    }

    if (_filter == 'all' || _filter == 'slips') {
      for (final e in slips) {
        if (_search.isNotEmpty &&
            !(e.note ?? '').toLowerCase().contains(_search.toLowerCase())) {
          continue;
        }
        entries.add(_HistoryEntry(
          type: _EntryType.slip,
          date: e.date,
          id: e.id,
          data: e,
        ));
      }
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  // ─── Group by date ───────────────────────────────────────────────────────────

  Map<DateTime, List<_HistoryEntry>> _groupByDate(List<_HistoryEntry> entries) {
    final grouped = <DateTime, List<_HistoryEntry>>{};
    for (final e in entries) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      (grouped[key] ??= []).add(e);
    }
    return grouped;
  }

  // ─── Delete confirmation ─────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, String id) {
    H.medium();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
        title: Text('Delete entry?', style: AppTextStyles.titleMedium),
        content: Text(
          'This cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.stone600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(journalProvider.notifier).delete(id);
              _expanded.remove(id);
            },
            child: Text(
              'Delete',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.blush500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter chip row ─────────────────────────────────────────────────────────

  Widget _buildFilterChips({
    required int journalCount,
    required int gratitudeCount,
    required int cravingCount,
    required int thoughtCount,
    required int activityCount,
    required int sleepCount,
    required int slipCount,
  }) {
    final l10n = AppLocalizations.of(context);
    final total = journalCount +
        gratitudeCount +
        cravingCount +
        thoughtCount +
        activityCount +
        sleepCount +
        slipCount;

    final filters = [
      ('all', '${l10n.historyFilterAll} ($total)'),
      ('journal', '${l10n.historyFilterJournal} ($journalCount)'),
      ('gratitude', '${l10n.historyFilterGratitude} ($gratitudeCount)'),
      ('cravings', '${l10n.historyFilterCravings} ($cravingCount)'),
      ('thoughts', '${l10n.historyFilterThoughts} ($thoughtCount)'),
      ('exercise', '${l10n.historyFilterActivity} ($activityCount)'),
      ('sleep', '${l10n.historyFilterSleep} ($sleepCount)'),
      if (slipCount > 0) ('slips', '${l10n.historyFilterSlips} ($slipCount)'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        spacing: 8,
        children: filters.map((f) {
          final isSelected = _filter == f.$1;
          return GestureDetector(
            onTap: () {
              H.selection();
              setState(() => _filter = f.$1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.forest600 : AppColors.stone50,
                borderRadius: AppRadius.pill,
                border: Border.all(
                  color: isSelected ? AppColors.forest600 : AppColors.stone100,
                  width: 1,
                ),
              ),
              child: Text(
                f.$2,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.stone600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Summary stat chip ───────────────────────────────────────────────────────

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.forest50,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.forest100, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(icon, size: 16, color: AppColors.forest600),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.forest700,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Date header ─────────────────────────────────────────────────────────────

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          Text(
            _dateLabel(date).toUpperCase(),
            style: AppTextStyles.overline.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.stone100,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Journal card ────────────────────────────────────────────────────────────

  Widget _buildJournalCard(JournalEntry entry) {
    final l10n = AppLocalizations.of(context);
    final isExpanded = _expanded.contains(entry.id);
    final moodColor = _moodColor(entry.mood);
    final localizedMoodLabel = switch (entry.mood) {
      'great' => l10n.historyMoodGreat,
      'good' => l10n.historyMoodGood,
      'okay' => l10n.historyMoodOkay,
      'hard' => l10n.historyMoodHard,
      'crisis' => l10n.historyMoodCrisis,
      _ => entry.mood,
    };

    return GestureDetector(
      onTap: () {
        H.selection();
        setState(() {
          if (isExpanded) {
            _expanded.remove(entry.id);
          } else {
            _expanded.add(entry.id);
          }
        });
      },
      child: SolidCard(
        padding: const EdgeInsets.all(0),
        borderRadius: AppRadius.xl,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: moodColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              spacing: 6,
                              children: [
                                Icon(
                                  Icons.edit_note_rounded,
                                  size: 14,
                                  color: AppColors.stone400,
                                ),
                                Text(
                                  DateFormat('h:mm a').format(entry.date),
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          // Mood chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: moodColor.withOpacity(0.12),
                              borderRadius: AppRadius.pill,
                            ),
                            child: Text(
                              localizedMoodLabel,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: moodColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 220),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Text(
                          entry.text,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text(
                          entry.text,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => _confirmDelete(context, entry.id),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.blush50,
                                  borderRadius: AppRadius.sm,
                                ),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 16,
                                  color: AppColors.blush400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!isExpanded && entry.text.length > 120) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tap to read more',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.forest500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Gratitude card ──────────────────────────────────────────────────────────

  Widget _buildGratitudeCard(GratitudeEntry entry) {
    final date = DateTime.tryParse(entry.date) ?? DateTime.now();

    return SolidCard(
      padding: const EdgeInsets.all(0),
      borderRadius: AppRadius.xl,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.honey500,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        Icon(
                          Icons.spa_rounded,
                          size: 13,
                          color: AppColors.honey500,
                        ),
                        Text(
                          'Gratitude',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.honey600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('h:mm a').format(date),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(entry.text, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Craving card ────────────────────────────────────────────────────────────

  Widget _metaPill(
    String label, {
    Color background = AppColors.stone50,
    Color foreground = AppColors.stone600,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.pill,
          border: Border.all(color: AppColors.stone100),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(color: foreground),
        ),
      );

  Widget _metaWrap(List<Widget> children) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: children,
      );

  // ??? Craving card ?????????????????????????????????????????????????????????

  Widget _buildCravingCard(CravingEntry e) {
    final intensity = e.intensity;
    final barColor = intensity <= 3
        ? AppColors.forest400
        : intensity <= 6
            ? AppColors.honey500
            : AppColors.forest700;
    final chipBg = intensity <= 3
        ? AppColors.forest50
        : intensity <= 6
            ? AppColors.honey50
            : AppColors.mintChip;
    final chipText = intensity <= 3
        ? AppColors.forest600
        : intensity <= 6
            ? AppColors.honey600
            : AppColors.forest700;
    final triggerLabels = e.triggers.isNotEmpty
        ? e.triggers
        : (e.trigger?.trim().isNotEmpty == true
            ? [e.trigger!]
            : const <String>[]);

    return SolidCard(
      padding: const EdgeInsets.all(0),
      borderRadius: AppRadius.xl,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.spa_outlined,
                            size: 14, color: AppColors.stone400),
                        const SizedBox(width: 6),
                        Text(DateFormat('h:mm a').format(e.date),
                            style: AppTextStyles.caption),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text('$intensity / 10',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: chipText)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _metaWrap([
                      if (e.severity != null) _metaPill(e.severity!),
                      if (e.durationMinutes != null)
                        _metaPill('${e.durationMinutes} min'),
                      ...triggerLabels.map((t) => _metaPill(t)),
                    ]),
                    if (e.notes != null && e.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        e.notes!,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.stone600),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ??? Thought card ??????????????????????????????????????????????????????????

  Widget _buildThoughtCard(ThoughtEntry e) {
    final typeColor = switch (e.type) {
      'positive' => AppColors.forest500,
      'negative' => AppColors.honey600,
      _ => AppColors.stone400,
    };
    final typeBg = switch (e.type) {
      'positive' => AppColors.forest50,
      'negative' => AppColors.honey50,
      _ => AppColors.stone100,
    };

    return SolidCard(
      padding: const EdgeInsets.all(0),
      borderRadius: AppRadius.xl,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            size: 14, color: AppColors.stone400),
                        const SizedBox(width: 6),
                        Text(DateFormat('h:mm a').format(e.date),
                            style: AppTextStyles.caption),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: typeBg,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(e.type,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: typeColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.text,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.stone600),
                    ),
                    const SizedBox(height: 8),
                    _metaWrap([
                      if (e.strength != null) _metaPill(e.strength!),
                      if (e.durationMinutes != null)
                        _metaPill('${e.durationMinutes} min'),
                      ...e.triggers.map((t) => _metaPill(t)),
                    ]),
                    if (e.notes != null && e.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        e.notes!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone500),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ??? Activity card ?????????????????????????????????????????????????????????

  Widget _buildActivityCard(ActivityEntry e) {
    final (icon, label) = switch (e.activity) {
      'walk' => (Icons.directions_walk_rounded, 'Walk'),
      'run' => (Icons.directions_run_rounded, 'Run'),
      'cycle' => (Icons.directions_bike_rounded, 'Cycle'),
      'swim' => (Icons.pool_rounded, 'Swim'),
      'weights' => (Icons.fitness_center_rounded, 'Weights'),
      // legacy value kept for existing records
      'exercise' => (Icons.fitness_center_rounded, 'Exercise'),
      'yoga' => (Icons.self_improvement_outlined, 'Yoga'),
      _ => (Icons.directions_run_rounded, 'Activity'),
    };

    // Sub-label: distance + time for distance activities; just time otherwise.
    final distKm = e.distance;
    final subLabel = distKm != null
        ? '${distKm.toStringAsFixed(2)} km · ${e.minutes} min'
        : '${e.minutes} min';

    return SolidCard(
      padding: const EdgeInsets.all(0),
      borderRadius: AppRadius.xl,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.forest400,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.forest50,
                            borderRadius: AppRadius.md,
                          ),
                          child:
                              Icon(icon, size: 18, color: AppColors.forest600),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: AppTextStyles.titleSmall),
                              Text(subLabel, style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Text(DateFormat('h:mm a').format(e.date),
                            style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _metaWrap([
                      if (e.effort != null) _metaPill(e.effort!),
                      if (e.outcome != null) _metaPill(e.outcome!),
                    ]),
                    if (e.notes != null && e.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        e.notes!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone500),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ??? Sleep card ????????????????????????????????????????????????????????????

  Widget _buildSleepCard(SleepEntry e) {
    const qualityLabels = ['', 'Poor', 'Fair', 'OK', 'Good', 'Great'];
    final qualityColors = [
      AppColors.stone400,
      AppColors.stone400,
      AppColors.honey500,
      AppColors.honey400,
      AppColors.forest400,
      AppColors.forest600,
    ];
    final qColor = qualityColors[e.quality.clamp(0, 5)];
    final qLabel = qualityLabels[e.quality.clamp(0, 5)];

    return SolidCard(
      padding: const EdgeInsets.all(0),
      borderRadius: AppRadius.xl,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: qColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.stone100,
                            borderRadius: AppRadius.md,
                          ),
                          child: const Icon(Icons.bedtime_outlined,
                              size: 18, color: AppColors.stone500),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${e.hours.toStringAsFixed(1)} hours',
                                  style: AppTextStyles.titleSmall),
                              Text('Quality: $qLabel',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: qColor)),
                            ],
                          ),
                        ),
                        Text(DateFormat('h:mm a').format(e.date),
                            style: AppTextStyles.caption),
                      ],
                    ),
                    if (e.factors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _metaWrap(e.factors.map((f) => _metaPill(f)).toList()),
                    ],
                    if (e.notes != null && e.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        e.notes!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone500),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Slip card ───────────────────────────────────────────────────────────────

  Widget _buildSlipCard(Slip e) {
    final streakLabel =
        e.streakDays == 1 ? '1 day sober' : '${e.streakDays} days sober';

    return SolidCard(
      padding: const EdgeInsets.all(0),
      borderRadius: AppRadius.xl,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.honey400,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.refresh_rounded,
                            size: 14, color: AppColors.stone400),
                        const SizedBox(width: 6),
                        Text(DateFormat('h:mm a').format(e.date),
                            style: AppTextStyles.caption),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.honey50,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            'Reset',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.honey600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sober at the time: $streakLabel',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.stone600),
                    ),
                    if (e.note != null && e.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        e.note!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone500),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ??? Empty state ???????????????????????????????????????????????????????????

  Widget _buildEmptyState() {
    final (icon, noun) = switch (_filter) {
      'cravings' => (Icons.local_fire_department_rounded, 'cravings'),
      'thoughts' => (Icons.lightbulb_outline_rounded, 'thoughts'),
      'exercise' => (Icons.directions_walk_rounded, 'exercise'),
      'sleep' => (Icons.bedtime_outlined, 'sleep'),
      'journal' => (Icons.edit_note_rounded, 'journal entries'),
      'gratitude' => (Icons.spa_outlined, 'gratitude notes'),
      'slips' => (Icons.timeline_rounded, 'slips'),
      _ => (Icons.history_rounded, 'entries'),
    };

    if (_filter != 'all') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AppColors.stone200),
            const SizedBox(height: 16),
            Text(
              'No ${noun[0].toUpperCase()}${noun.substring(1)} yet',
              style:
                  AppTextStyles.titleMedium.copyWith(color: AppColors.stone500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Log your $noun from the home screen',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Generic empty state for 'all'
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 52, color: AppColors.stone200),
          const SizedBox(height: 16),
          Text(
            'Nothing here yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.stone500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Your entries will appear here',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalProvider);
    final gratitudeAsync = ref.watch(allGratitudeProvider);
    final cravingsAsync = ref.watch(cravingProvider);
    final thoughtsAsync = ref.watch(thoughtProvider);
    final activitiesAsync = ref.watch(activityProvider);
    final sleepAsync = ref.watch(sleepProvider);
    final slipsAsync = ref.watch(slipProvider);
    // soberDaysProvider only rebuilds at midnight — no need for per-second ticks here.
    final soberStats = ref.watch(soberDaysProvider);

    final journal = journalAsync.valueOrNull ?? [];
    final gratitude = gratitudeAsync.valueOrNull ?? [];
    final cravings = cravingsAsync.valueOrNull ?? [];
    final thoughts = thoughtsAsync.valueOrNull ?? [];
    final activities = activitiesAsync.valueOrNull ?? [];
    final sleepEntries = sleepAsync.valueOrNull ?? [];
    final slips = slipsAsync.valueOrNull ?? [];

    // Weekly counts
    final journalThisWeek = journal.where((e) => _isThisWeek(e.date)).length;
    final gratitudeThisWeek = gratitude.where((e) {
      final d = DateTime.tryParse(e.date);
      return d != null && _isThisWeek(d);
    }).length;

    final entries = _buildEntries(
      journal: journal,
      gratitude: gratitude,
      cravings: cravings,
      thoughts: thoughts,
      activities: activities,
      sleepEntries: sleepEntries,
      slips: slips,
    );

    final grouped = _groupByDate(entries);
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  const LuxuryBackButton(),
                  const SizedBox(width: 4),
                  Text('My History', style: AppTextStyles.titleLarge),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Summary stats strip ─────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                spacing: 10,
                children: [
                  _buildStatChip(
                    icon: Icons.edit_note_rounded,
                    value: journalThisWeek.toString(),
                    label: 'Journal this week',
                  ),
                  _buildStatChip(
                    icon: Icons.spa_rounded,
                    value: gratitudeThisWeek.toString(),
                    label: 'Gratitude this week',
                  ),
                  _buildStatChip(
                    icon: Icons.local_florist_rounded,
                    value: soberStats != null ? '${soberStats.days}d' : '--',
                    label: 'Days sober',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: (v) => setState(() => _search = v),
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).historySearchHint,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.stone400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.stone400,
                    size: 20,
                  ),
                  suffixIcon: _search.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _search = '');
                            _searchFocus.unfocus();
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.stone400,
                            size: 20,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.stone50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                      color: AppColors.forest600,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Filter chips ───────────────────────────────────────────────
            _buildFilterChips(
              journalCount: journal.length,
              gratitudeCount: gratitude.length,
              cravingCount: cravings.length,
              thoughtCount: thoughts.length,
              activityCount: activities.length,
              sleepCount: sleepEntries.length,
              slipCount: slips.length,
            ),

            const SizedBox(height: 4),

            // ── Entry list ─────────────────────────────────────────────────
            Expanded(
              child: (journalAsync.isLoading ||
                      gratitudeAsync.isLoading ||
                      cravingsAsync.isLoading ||
                      thoughtsAsync.isLoading ||
                      activitiesAsync.isLoading ||
                      sleepAsync.isLoading ||
                      slipsAsync.isLoading)
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.forest600,
                        strokeWidth: 2,
                      ),
                    )
                  : sortedDates.isEmpty
                      ? SingleChildScrollView(
                          child: _buildEmptyState(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            32,
                          ),
                          itemCount: sortedDates.length,
                          itemBuilder: (context, dateIndex) {
                            final date = sortedDates[dateIndex];
                            final dayEntries = grouped[date]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDateHeader(date),
                                ...dayEntries.map((entry) {
                                  Widget card;
                                  switch (entry.type) {
                                    case _EntryType.journal:
                                      card = _buildJournalCard(
                                          entry.data as JournalEntry);
                                    case _EntryType.gratitude:
                                      card = _buildGratitudeCard(
                                          entry.data as GratitudeEntry);
                                    case _EntryType.craving:
                                      card = _buildCravingCard(
                                          entry.data as CravingEntry);
                                    case _EntryType.thought:
                                      card = _buildThoughtCard(
                                          entry.data as ThoughtEntry);
                                    case _EntryType.exercise:
                                      card = _buildActivityCard(
                                          entry.data as ActivityEntry);
                                    case _EntryType.sleep:
                                      card = _buildSleepCard(
                                          entry.data as SleepEntry);
                                    case _EntryType.slip:
                                      card = _buildSlipCard(entry.data as Slip);
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: card,
                                  );
                                }),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
