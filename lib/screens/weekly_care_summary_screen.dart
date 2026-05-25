import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../models/thought_record.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Weekly Care Summary Screen ───────────────────────────────────────────────

enum _WeekRange { thisWeek, lastWeek, custom }

class WeeklyCareSummaryScreen extends ConsumerStatefulWidget {
  const WeeklyCareSummaryScreen({super.key});

  @override
  ConsumerState<WeeklyCareSummaryScreen> createState() =>
      _WeeklyCareSummaryScreenState();
}

class _WeeklyCareSummaryScreenState
    extends ConsumerState<WeeklyCareSummaryScreen> {
  _WeekRange _range = _WeekRange.thisWeek;
  DateTimeRange? _customRange;
  bool _generatingPdf = false;

  // ── Date range helpers ──────────────────────────────────────────────────────

  DateTimeRange _resolveRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_range) {
      case _WeekRange.thisWeek:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        final end = sunday.isBefore(today) ? sunday : today;
        return DateTimeRange(start: monday, end: end);
      case _WeekRange.lastWeek:
        final thisMonday = today.subtract(Duration(days: today.weekday - 1));
        final lastMonday = thisMonday.subtract(const Duration(days: 7));
        final lastSunday = lastMonday.add(const Duration(days: 6));
        return DateTimeRange(start: lastMonday, end: lastSunday);
      case _WeekRange.custom:
        return _customRange ??
            DateTimeRange(
              start: today.subtract(const Duration(days: 6)),
              end: today,
            );
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
      initialDateRange: _customRange ??
          DateTimeRange(
            start: today.subtract(const Duration(days: 6)),
            end: today,
          ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.forest600,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _range = _WeekRange.custom;
      });
    }
  }

  // ── Count helpers ───────────────────────────────────────────────────────────

  bool _inRange(DateTime date, DateTime start, DateTime end) {
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  int _pledgeCount(
      UserProfile profile, DateTime rangeStart, DateTime rangeEnd) {
    final lastPledge = _parseYMD(profile.lastPledgeDate);
    if (lastPledge == null || profile.pledgeStreak == 0) return 0;
    final streakStart =
        lastPledge.subtract(Duration(days: profile.pledgeStreak - 1));
    final overlapStart =
        rangeStart.isAfter(streakStart) ? rangeStart : streakStart;
    final overlapEnd = rangeEnd.isBefore(lastPledge) ? rangeEnd : lastPledge;
    if (overlapStart.isAfter(overlapEnd)) return 0;
    return overlapEnd.difference(overlapStart).inDays + 1;
  }

  DateTime? _parseYMD(String s) => s.isEmpty ? null : DateTime.tryParse(s);

  // ── Reflection text ─────────────────────────────────────────────────────────

  String _reflection({
    required int journalCount,
    required int cravingCount,
    required int thoughtCount,
    required int activityCount,
    required int sleepCount,
    required int gratitudeCount,
    required int pledgeCount,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required List<JournalEntry> journals,
    required List<CravingEntry> cravings,
    required List<ThoughtRecord> thoughts,
    required List<ActivityEntry> activities,
    required List<SleepEntry> sleeps,
    required List<GratitudeEntry> gratitudes,
  }) {
    final totalEntries = journalCount +
        cravingCount +
        thoughtCount +
        activityCount +
        sleepCount +
        gratitudeCount +
        pledgeCount;

    if (totalEntries == 0) {
      return 'No care entries were recorded for this period. A quiet week still counts.';
    }

    // Count unique care days
    final careDays = <DateTime>{};
    void addDates<T>(List<T> list, DateTime Function(T) getDate) {
      for (final e in list) {
        final d = getDate(e);
        if (_inRange(d, rangeStart, rangeEnd)) {
          careDays.add(DateTime(d.year, d.month, d.day));
        }
      }
    }

    addDates(journals, (e) => e.date);
    addDates(cravings, (e) => e.date);
    addDates(thoughts, (e) => e.date);
    addDates(activities, (e) => e.date);
    addDates(sleeps, (e) => e.date);
    for (final g in gratitudes) {
      final d = DateTime.tryParse(g.date);
      if (d != null && _inRange(d, rangeStart, rangeEnd)) {
        careDays.add(DateTime(d.year, d.month, d.day));
      }
    }

    final counts = {
      'Journal': journalCount,
      'Craving support': cravingCount,
      'Thought exercises': thoughtCount,
      'Movement': activityCount,
      'Sleep log': sleepCount,
      'Gratitude': gratitudeCount,
      'Daily pledge': pledgeCount,
    };

    String? mostUsed;
    int maxCount = 0;
    counts.forEach((k, v) {
      if (v > maxCount) {
        maxCount = v;
        mostUsed = k;
      }
    });

    final n = careDays.length;
    return 'You returned to your care practices on $n ${n == 1 ? 'day' : 'days'} this week.\n'
        'Most used support: ${mostUsed ?? 'Various'}\n'
        'A quiet week of showing up still counts.';
  }

  // ── PDF generation ──────────────────────────────────────────────────────────

  Future<void> _sharePdf({
    required DateTimeRange range,
    required int journalCount,
    required int cravingCount,
    required int thoughtCount,
    required int activityCount,
    required int sleepCount,
    required int gratitudeCount,
    required int pledgeCount,
    required String reflectionText,
  }) async {
    final pdf = pw.Document();

    final forestGreen = PdfColor(0.18, 0.345, 0.267);
    final cream = PdfColor(0.961, 0.949, 0.933);
    final darkInk = PdfColor(0.149, 0.200, 0.184);
    final muted = PdfColor(0.416, 0.451, 0.435);
    final divider = PdfColor(0.839, 0.816, 0.784);

    final fmt = DateFormat('dd MMM yyyy');
    final startLabel = fmt.format(range.start);
    final endLabel = fmt.format(range.end);

    final rows = [
      ('Journal entries', journalCount),
      ('Craving support used', cravingCount),
      ('Thought exercises', thoughtCount),
      ('Movement / activity', activityCount),
      ('Sleep logs', sleepCount),
      ('Daily gratitude', gratitudeCount),
      ('Daily pledge', pledgeCount),
    ];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: cream,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────────
                pw.Text(
                  'Weekly Care Summary',
                  style: pw.TextStyle(
                    font: pw.Font.timesBold(),
                    fontSize: 26,
                    color: forestGreen,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Journey Forward  •  $startLabel – $endLabel',
                  style: pw.TextStyle(
                    font: pw.Font.helvetica(),
                    fontSize: 11,
                    color: muted,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: divider, thickness: 1),
                pw.SizedBox(height: 12),

                // ── Care recorded ───────────────────────────────────────────
                pw.Text(
                  'Care recorded',
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 13,
                    color: forestGreen,
                  ),
                ),
                pw.SizedBox(height: 8),

                ...rows.map((row) {
                  final (label, count) = row;
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          label,
                          style: pw.TextStyle(
                            font: pw.Font.helvetica(),
                            fontSize: 12,
                            color: darkInk,
                          ),
                        ),
                        pw.Text(
                          '$count',
                          style: pw.TextStyle(
                            font: pw.Font.helveticaBold(),
                            fontSize: 12,
                            color: count > 0 ? forestGreen : muted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                pw.SizedBox(height: 12),
                pw.Divider(color: divider, thickness: 1),
                pw.SizedBox(height: 12),

                // ── Reflection ──────────────────────────────────────────────
                pw.Text(
                  'Reflection',
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 13,
                    color: forestGreen,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  reflectionText,
                  style: pw.TextStyle(
                    font: pw.Font.helvetica(),
                    fontSize: 12,
                    color: darkInk,
                    lineSpacing: 4,
                  ),
                ),

                pw.SizedBox(height: 12),
                pw.Divider(color: divider, thickness: 1),
                pw.SizedBox(height: 12),

                // ── Privacy note ────────────────────────────────────────────
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor(0.933, 0.941, 0.933),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Privacy note',
                        style: pw.TextStyle(
                          font: pw.Font.helveticaBold(),
                          fontSize: 11,
                          color: forestGreen,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'This summary was created locally on the user\'s device. '
                        'Journey Forward does not upload, send, or store shared reports.',
                        style: pw.TextStyle(
                          font: pw.Font.helvetica(),
                          fontSize: 10,
                          color: muted,
                          lineSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final startStr = DateFormat('yyyyMMdd').format(range.start);
    final endStr = DateFormat('yyyyMMdd').format(range.end);
    final fileName =
        'journey_forward_weekly_care_summary_${startStr}_to_$endStr.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Weekly Care Summary',
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final journals = ref.watch(journalProvider).valueOrNull ?? [];
    final cravings = ref.watch(cravingProvider).valueOrNull ?? [];
    final thoughts = ref.watch(thoughtRecordProvider).valueOrNull ?? [];
    final activities = ref.watch(activityProvider).valueOrNull ?? [];
    final sleeps = ref.watch(sleepProvider).valueOrNull ?? [];
    final gratitudes = ref.watch(allGratitudeProvider).valueOrNull ?? [];
    final profile = ref.watch(profileProvider).valueOrNull;

    final range = _resolveRange();
    final rangeStart = range.start;
    final rangeEnd = range.end;

    // Filter counts
    int journalCount =
        journals.where((e) => _inRange(e.date, rangeStart, rangeEnd)).length;
    int cravingCount =
        cravings.where((e) => _inRange(e.date, rangeStart, rangeEnd)).length;
    int thoughtCount =
        thoughts.where((e) => _inRange(e.date, rangeStart, rangeEnd)).length;
    int activityCount =
        activities.where((e) => _inRange(e.date, rangeStart, rangeEnd)).length;
    int sleepCount =
        sleeps.where((e) => _inRange(e.date, rangeStart, rangeEnd)).length;
    int gratitudeCount = gratitudes.where((e) {
      final d = DateTime.tryParse(e.date);
      return d != null && _inRange(d, rangeStart, rangeEnd);
    }).length;
    int pledgeCount =
        profile != null ? _pledgeCount(profile, rangeStart, rangeEnd) : 0;

    final reflectionText = _reflection(
      journalCount: journalCount,
      cravingCount: cravingCount,
      thoughtCount: thoughtCount,
      activityCount: activityCount,
      sleepCount: sleepCount,
      gratitudeCount: gratitudeCount,
      pledgeCount: pledgeCount,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      journals: journals,
      cravings: cravings,
      thoughts: thoughts,
      activities: activities,
      sleeps: sleeps,
      gratitudes: gratitudes,
    );

    final fmt = DateFormat('d MMM');
    final dateRangeLabel =
        '${fmt.format(rangeStart)} – ${fmt.format(rangeEnd)}';

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const LuxuryBackButton(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.weeklySummaryTitle,
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.forest700),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    Text(
                      l10n.weeklySummarySubtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // ── Date range chips ───────────────────────────────────────
                    Row(
                      children: [
                        _RangeChip(
                          label: l10n.weeklySummaryThisWeek,
                          selected: _range == _WeekRange.thisWeek,
                          onTap: () {
                            H.light();
                            setState(() => _range = _WeekRange.thisWeek);
                          },
                        ),
                        const SizedBox(width: 8),
                        _RangeChip(
                          label: l10n.weeklySummaryLastWeek,
                          selected: _range == _WeekRange.lastWeek,
                          onTap: () {
                            H.light();
                            setState(() => _range = _WeekRange.lastWeek);
                          },
                        ),
                        const SizedBox(width: 8),
                        _RangeChip(
                          label: l10n.weeklySummaryCustomRange,
                          selected: _range == _WeekRange.custom,
                          onTap: () async {
                            H.light();
                            await _pickCustomRange();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateRangeLabel,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 16),

                    // ── In-app preview card ────────────────────────────────────
                    SolidCard(
                      borderRadius: AppRadius.xl,
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header band
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: const BoxDecoration(
                              color: AppColors.mintChip,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.eco_outlined,
                                        size: 18, color: AppColors.forest700),
                                    const SizedBox(width: 8),
                                    Text(l10n.weeklySummaryTitle,
                                        style: AppTextStyles.titleMedium
                                            .copyWith(
                                                color: AppColors.forest700)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${l10n.weeklySummaryAppName}  •  $dateRangeLabel',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),

                          // Care recorded section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: Row(
                              children: [
                                const Icon(Icons.eco_outlined,
                                    size: 15, color: AppColors.forest600),
                                const SizedBox(width: 6),
                                Text(l10n.weeklySummaryCareRecorded,
                                    style: AppTextStyles.titleSmall
                                        .copyWith(color: AppColors.forest700)),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child:
                                Divider(height: 16, color: AppColors.stone100),
                          ),

                          _SummaryRow(
                              icon: Icons.menu_book_outlined,
                              label: l10n.weeklySummaryJournalEntries,
                              count: journalCount),
                          _SummaryRow(
                              icon: Icons.favorite_border_rounded,
                              label: l10n.weeklySummaryCravingSupport,
                              count: cravingCount),
                          _SummaryRow(
                              icon: Icons.psychology_outlined,
                              label: l10n.weeklySummaryThoughtExercises,
                              count: thoughtCount),
                          _SummaryRow(
                              icon: Icons.directions_walk_outlined,
                              label: l10n.weeklySummaryMovement,
                              count: activityCount),
                          _SummaryRow(
                              icon: Icons.bedtime_outlined,
                              label: l10n.weeklySummarySleepLogs,
                              count: sleepCount),
                          _SummaryRow(
                              icon: Icons.wb_sunny_outlined,
                              label: l10n.weeklySummaryDailyGratitude,
                              count: gratitudeCount),
                          _SummaryRow(
                              icon: Icons.shield_outlined,
                              label: l10n.weeklySummaryDailyPledge,
                              count: pledgeCount),

                          // Reflection section
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child:
                                Divider(height: 24, color: AppColors.stone100),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(Icons.eco_outlined,
                                    size: 15, color: AppColors.forest600),
                                const SizedBox(width: 6),
                                Text(l10n.weeklySummaryReflection,
                                    style: AppTextStyles.titleSmall
                                        .copyWith(color: AppColors.forest700)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Text(
                              reflectionText,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.stone700, height: 1.6),
                            ),
                          ),

                          // Privacy note section
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child:
                                Divider(height: 24, color: AppColors.stone100),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.lock_outline,
                                        size: 15, color: AppColors.forest600),
                                    const SizedBox(width: 6),
                                    Text(l10n.weeklySummaryPrivacyNote,
                                        style: AppTextStyles.titleSmall
                                            .copyWith(
                                                color: AppColors.forest700)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.weeklySummaryPrivacyNoteBody,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Privacy warning footer ─────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.honey50,
                        borderRadius: AppRadius.md,
                        border: Border.all(color: AppColors.honey100),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: AppColors.honey600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.weeklySummaryShareWarning,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.stone700),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Action buttons ─────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              H.light();
                              await _pickCustomRange();
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(l10n.weeklySummaryEdit),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _generatingPdf
                                ? null
                                : () async {
                                    H.light();
                                    setState(() => _generatingPdf = true);
                                    try {
                                      await _sharePdf(
                                        range: range,
                                        journalCount: journalCount,
                                        cravingCount: cravingCount,
                                        thoughtCount: thoughtCount,
                                        activityCount: activityCount,
                                        sleepCount: sleepCount,
                                        gratitudeCount: gratitudeCount,
                                        pledgeCount: pledgeCount,
                                        reflectionText: reflectionText,
                                      );
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                l10n.weeklySummaryPdfError),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() => _generatingPdf = false);
                                      }
                                    }
                                  },
                            icon: _generatingPdf
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.picture_as_pdf_outlined,
                                    size: 18),
                            label: Text(l10n.weeklySummarySharePdf),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Range chip ───────────────────────────────────────────────────────────────

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.forest700 : AppColors.card,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: selected ? AppColors.forest700 : AppColors.softBorder,
          ),
          boxShadow: selected ? null : AppShadows.card,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.stone600,
          ),
        ),
      ),
    );
  }
}

// ─── Summary row ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.forest600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone700)),
          ),
          Text(
            '$count',
            style: AppTextStyles.titleSmall.copyWith(
              color: count > 0 ? AppColors.forest700 : AppColors.stone300,
            ),
          ),
        ],
      ),
    );
  }
}
