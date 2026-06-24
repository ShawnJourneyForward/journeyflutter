import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    required AppLocalizations l10n,
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
      return l10n.weeklySummaryNoActivity;
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

    // Each bucket maps its localized display label → count, so the winning
    // label is already translated when shown in "Most used support: …".
    final counts = {
      l10n.weeklySummarySupportJournal: journalCount,
      l10n.weeklySummarySupportCraving: cravingCount,
      l10n.weeklySummarySupportThought: thoughtCount,
      l10n.weeklySummarySupportMovement: activityCount,
      l10n.weeklySummarySupportSleep: sleepCount,
      l10n.weeklySummarySupportGratitude: gratitudeCount,
      l10n.weeklySummarySupportPledge: pledgeCount,
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
    return '${l10n.weeklySummaryCareDays(n)}\n'
        '${l10n.weeklySummaryMostUsed(mostUsed ?? l10n.weeklySummarySupportVarious)}\n'
        '${l10n.weeklySummaryQuietWeek}';
  }

  // ── PDF generation ──────────────────────────────────────────────────────────
  //
  // Mirrors the in-app preview card 1:1 so a recipient (therapist, sponsor,
  // partner) sees the same document the user does. Same palette, same logo,
  // same section layout. The row "icon badges" in the PDF are intentionally
  // plain mint circles — bundling the Material Icons OTF just for these
  // would add ~370 KB to the app bundle for what is decoration. The label
  // text carries the meaning either way.

  Future<void> _sharePdf({
    required AppLocalizations l10n,
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

    // Palette mirrors lib/theme/app_theme.dart values so PDF + screen match.
    const forest700 = PdfColor.fromInt(0xFF2E5844);
    const forest100 = PdfColor.fromInt(0xFFDCE8DC);
    const mintChip = PdfColor.fromInt(0xFFE8F1E8);
    const stone700 = PdfColor.fromInt(0xFF3F4B46);
    const stone500 = PdfColor.fromInt(0xFF69736F);
    const stone300 = PdfColor.fromInt(0xFFB8AFA3);
    const stone200 = PdfColor.fromInt(0xFFD6CFC5);
    const stone100 = PdfColor.fromInt(0xFFEDE8E1);
    const cardWhite = PdfColor.fromInt(0xFFFFFFFF);

    final fmt = DateFormat('dd MMM yyyy');
    final startLabel = fmt.format(range.start);
    final endLabel = fmt.format(range.end);
    final dateRangeLabel = '$startLabel – $endLabel';

    final rows = [
      (l10n.weeklySummaryJournalEntries, journalCount),
      (l10n.weeklySummaryCravingSupport, cravingCount),
      (l10n.weeklySummaryThoughtExercises, thoughtCount),
      (l10n.weeklySummaryMovement, activityCount),
      (l10n.weeklySummarySleepLogs, sleepCount),
      (l10n.weeklySummaryDailyGratitude, gratitudeCount),
      (l10n.weeklySummaryDailyPledge, pledgeCount),
    ];

    // ── Reusable widget builders ────────────────────────────────────────────

    pw.Widget circleBadge({double size = 22}) => pw.Container(
          width: size,
          height: size,
          decoration: pw.BoxDecoration(
            color: mintChip,
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: forest100, width: 0.6),
          ),
        );

    pw.Widget sectionHeader(String label) => pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            circleBadge(size: 22),
            pw.SizedBox(width: 10),
            pw.Text(
              label,
              style: pw.TextStyle(
                font: pw.Font.helveticaBold(),
                fontSize: 13,
                color: forest700,
              ),
            ),
          ],
        );

    pw.Widget softDivider() =>
        pw.Container(height: 0.6, color: stone100);

    pw.Widget summaryRow(String label, int count) {
      final hasCount = count > 0;
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            circleBadge(size: 22),
            pw.SizedBox(width: 10),
            pw.Text(
              label,
              style: pw.TextStyle(
                font: pw.Font.helvetica(),
                fontSize: 11,
                color: stone700,
              ),
            ),
            pw.SizedBox(width: 8),
            // Dotted leader fills remaining space, ending just before the count.
            pw.Expanded(
              child: pw.Container(
                height: 6,
                child: pw.CustomPaint(
                  painter: (PdfGraphics canvas, PdfPoint size) {
                    canvas
                      ..setStrokeColor(stone200)
                      ..setLineWidth(0.8);
                    // Dot every 3pt across the band.
                    final y = size.y / 2;
                    for (double x = 0; x < size.x; x += 3) {
                      canvas
                        ..moveTo(x, y)
                        ..lineTo(x + 0.1, y);
                    }
                    canvas.strokePath();
                  },
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.SizedBox(
              width: 22,
              child: pw.Text(
                '$count',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: pw.Font.helveticaBold(),
                  fontSize: 12,
                  color: hasCount ? forest700 : stone300,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Page build ──────────────────────────────────────────────────────────

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: cardWhite,
              borderRadius: pw.BorderRadius.circular(14),
              border: pw.Border.all(color: stone200, width: 0.6),
            ),
            padding: const pw.EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ── Header: logo + title block ────────────────────────────
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 56,
                      height: 56,
                      child: pw.CustomPaint(
                        painter: (PdfGraphics canvas, PdfPoint size) {
                          _paintPdfMountainLogo(canvas, size, forest700);
                        },
                      ),
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            l10n.weeklySummaryTitle,
                            style: pw.TextStyle(
                              font: pw.Font.timesBold(),
                              fontSize: 24,
                              color: forest700,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            l10n.weeklySummaryPdfHeaderLine(
                                l10n.weeklySummaryAppName, dateRangeLabel),
                            style: pw.TextStyle(
                              font: pw.Font.helvetica(),
                              fontSize: 11,
                              color: stone500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                softDivider(),
                pw.SizedBox(height: 14),

                // ── Care recorded section ─────────────────────────────────
                sectionHeader(l10n.weeklySummaryCareRecorded),
                pw.SizedBox(height: 8),
                ...rows.map((r) => summaryRow(r.$1, r.$2)),

                pw.SizedBox(height: 14),
                softDivider(),
                pw.SizedBox(height: 14),

                // ── Reflection ─────────────────────────────────────────────
                sectionHeader(l10n.weeklySummaryReflection),
                pw.SizedBox(height: 8),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 32),
                  child: pw.Text(
                    reflectionText,
                    style: pw.TextStyle(
                      font: pw.Font.helvetica(),
                      fontSize: 11,
                      color: stone700,
                      lineSpacing: 4,
                    ),
                  ),
                ),

                pw.SizedBox(height: 14),
                softDivider(),
                pw.SizedBox(height: 14),

                // ── Privacy note ──────────────────────────────────────────
                // Body intentionally matches l10n.weeklySummaryPrivacyNoteBody
                // so PDF and on-screen read the same to the recipient.
                sectionHeader(l10n.weeklySummaryPrivacyNote),
                pw.SizedBox(height: 8),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 32),
                  child: pw.Text(
                    l10n.weeklySummaryPrivacyNoteBody,
                    style: pw.TextStyle(
                      font: pw.Font.helvetica(),
                      fontSize: 11,
                      color: stone700,
                      lineSpacing: 4,
                    ),
                  ),
                ),

                pw.SizedBox(height: 8),
                pw.Spacer(),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    l10n.weeklySummaryPdfGeneratedBy,
                    style: pw.TextStyle(
                      font: pw.Font.helveticaOblique(),
                      fontSize: 9,
                      color: stone500,
                    ),
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
      subject: l10n.weeklySummaryTitle,
    );
  }

  // ── PDF mountain-logo painter ──────────────────────────────────────────────
  //
  // Mirrors _MountainLogoPainter (Flutter Canvas) on the PDF graphics
  // context. PdfGraphics uses bottom-left origin (PDF convention), so all
  // Y values are computed as (size.y - <flutter-y>) when porting from the
  // Flutter version.

  void _paintPdfMountainLogo(
      PdfGraphics canvas, PdfPoint size, PdfColor ink) {
    final w = size.x;
    final h = size.y;
    // Convert Flutter-style top-down y → PDF bottom-up y.
    double py(double topDownY) => h - topDownY;

    canvas
      ..setStrokeColor(ink)
      ..setFillColor(ink)
      ..setLineWidth(0.9);

    // Outer circle frame
    canvas.drawEllipse(w / 2, h / 2, (w / 2) - 1, (h / 2) - 1);
    canvas.strokePath();

    // Sun + rays
    final sunX = w * 0.50;
    final sunY = py(h * 0.36);
    final sunR = w * 0.090;
    canvas.drawEllipse(sunX, sunY, sunR, sunR);
    canvas.strokePath();

    const rayCount = 7;
    final rayInner = sunR + w * 0.025;
    final rayOuter = sunR + w * 0.085;
    for (int i = 0; i < rayCount; i++) {
      final t = i / (rayCount - 1);
      // Angles fan over the upper arc of the sun.
      final ang = math.pi * (1 / 6 + (2 / 3) * t) + math.pi / 2;
      final x1 = sunX + math.cos(ang) * rayInner;
      final y1 = sunY + math.sin(ang) * rayInner;
      final x2 = sunX + math.cos(ang) * rayOuter;
      final y2 = sunY + math.sin(ang) * rayOuter;
      canvas
        ..moveTo(x1, y1)
        ..lineTo(x2, y2);
    }
    canvas.strokePath();

    // Right (back) mountain — outline only.
    final groundY = py(h * 0.74);
    final rightPeakX = w * 0.62;
    final rightPeakY = py(h * 0.46);
    canvas
      ..moveTo(w * 0.34, groundY)
      ..lineTo(rightPeakX, rightPeakY)
      ..lineTo(w * 0.88, groundY)
      ..closePath();
    canvas.strokePath();

    // Left (front) mountain — fill with white first to mask the right
    // mountain behind it, then stroke the outline.
    final leftPeakX = w * 0.36;
    final leftPeakY = py(h * 0.56);
    canvas
      ..setFillColor(PdfColor.fromInt(0xFFFFFFFF))
      ..moveTo(w * 0.16, groundY)
      ..lineTo(leftPeakX, leftPeakY)
      ..lineTo(w * 0.58, groundY)
      ..closePath()
      ..fillPath();
    canvas
      ..setFillColor(ink)
      ..moveTo(w * 0.16, groundY)
      ..lineTo(leftPeakX, leftPeakY)
      ..lineTo(w * 0.58, groundY)
      ..closePath()
      ..strokePath();

    // Ground line
    canvas
      ..moveTo(w * 0.14, groundY)
      ..lineTo(w * 0.88, groundY);
    canvas.strokePath();

    // Path/road accent (single curve segment approximated as a short line
    // — PdfGraphics quadratic helpers are limited, and a straight tick
    // reads clean at this size).
    canvas
      ..moveTo(w * 0.50, py(h * 0.82))
      ..lineTo(w * 0.40, py(h * 0.72));
    canvas.strokePath();

    // Hand-drawn dot at the start of the path.
    canvas.drawEllipse(w * 0.50, py(h * 0.82), 1.0, 1.0);
    canvas.fillPath();
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
      l10n: l10n,
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
                    // Layout matches the shared-PDF rendering (see _sharePdf):
                    //  ┌───────────────────────────────────────────────┐
                    //  │ [logo]  Weekly Care Summary                   │
                    //  │         Journey Forward                       │
                    //  ├───────────────────────────────────────────────┤
                    //  │ [badge] Care recorded                         │
                    //  │  [b]  Journal entries  · · · · · · ·    4    │
                    //  │  ...                                          │
                    //  ├───────────────────────────────────────────────┤
                    //  │ [badge] Reflection                            │
                    //  │  body copy …                                  │
                    //  ├───────────────────────────────────────────────┤
                    //  │ [badge] Privacy note                          │
                    //  │  body copy …                                  │
                    //  └───────────────────────────────────────────────┘
                    SolidCard(
                      borderRadius: AppRadius.xl,
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header band: logo + title block ───────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const _MountainLogo(size: 60),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.weeklySummaryTitle,
                                        style: AppTextStyles.displaySmall
                                            .copyWith(
                                          fontSize: 22,
                                          color: AppColors.forest700,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.weeklySummaryAppName,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(color: AppColors.stone500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const _SoftDivider(),

                          // ── Care recorded section ─────────────────────────
                          const SizedBox(height: 14),
                          _SectionHeader(
                            icon: Icons.eco_outlined,
                            label: l10n.weeklySummaryCareRecorded,
                          ),
                          const SizedBox(height: 6),

                          _SummaryRow(
                              icon: Icons.menu_book_outlined,
                              label: l10n.weeklySummaryJournalEntries,
                              count: journalCount),
                          _SummaryRow(
                              icon: Icons.volunteer_activism_outlined,
                              label: l10n.weeklySummaryCravingSupport,
                              count: cravingCount),
                          _SummaryRow(
                              icon: Icons.psychology_outlined,
                              label: l10n.weeklySummaryThoughtExercises,
                              count: thoughtCount),
                          _SummaryRow(
                              icon: Icons.directions_run_outlined,
                              label: l10n.weeklySummaryMovement,
                              count: activityCount),
                          _SummaryRow(
                              icon: Icons.nights_stay_outlined,
                              label: l10n.weeklySummarySleepLogs,
                              count: sleepCount),
                          _SummaryRow(
                              icon: Icons.favorite_border_rounded,
                              label: l10n.weeklySummaryDailyGratitude,
                              count: gratitudeCount),
                          _SummaryRow(
                              icon: Icons.shield_outlined,
                              label: l10n.weeklySummaryDailyPledge,
                              count: pledgeCount),

                          // ── Reflection section ────────────────────────────
                          const SizedBox(height: 14),
                          const _SoftDivider(),
                          const SizedBox(height: 14),
                          _SectionHeader(
                            icon: Icons.eco_outlined,
                            label: l10n.weeklySummaryReflection,
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                            child: Text(
                              reflectionText,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.stone700, height: 1.5),
                            ),
                          ),

                          // ── Privacy note section ──────────────────────────
                          const SizedBox(height: 14),
                          const _SoftDivider(),
                          const SizedBox(height: 14),
                          _SectionHeader(
                            icon: Icons.lock_outline,
                            label: l10n.weeklySummaryPrivacyNote,
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                            child: Text(
                              l10n.weeklySummaryPrivacyNoteBody,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.stone700, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Privacy warning footer ─────────────────────────────────
                    // Honey-tinted reminder with a circular lock badge on the
                    // left and a soft botanical sprig fading off the right edge.
                    // The sprig is `Positioned` inside a `ClipRRect` so the
                    // leaves can run right up to the border without overflow.
                    ClipRRect(
                      borderRadius: AppRadius.md,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        decoration: BoxDecoration(
                          color: AppColors.honey50,
                          borderRadius: AppRadius.md,
                          border: Border.all(color: AppColors.honey100),
                        ),
                        child: Stack(
                          children: [
                            // Faint botanical accent on the right edge
                            Positioned(
                              right: -10,
                              top: -4,
                              bottom: -4,
                              child: Opacity(
                                opacity: 0.35,
                                child: SizedBox(
                                  width: 78,
                                  child: CustomPaint(
                                    painter: _BotanicalSprigPainter(),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.honey100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.lock_outline,
                                    size: 18,
                                    color: AppColors.honey600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.weeklySummaryShareWarning,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: AppColors.stone700),
                                  ),
                                ),
                                // Reserve space so text never sits under the sprig
                                const SizedBox(width: 64),
                              ],
                            ),
                          ],
                        ),
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
                                        l10n: l10n,
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

/// One entry in the "Care recorded" list — mint-tinted icon badge, label,
/// dotted leader line out to a right-aligned count. The dotted leader is
/// laid out with an [Expanded] so the count column always lines up regardless
/// of label length, and the dots fill whatever space is left.
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
    final hasCount = count > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 5, 18, 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CircleBadge(icon: icon, size: 30, iconSize: 16),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.stone700,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: _DottedLine(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: AppTextStyles.titleSmall.copyWith(
                color: hasCount ? AppColors.forest700 : AppColors.stone300,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section header (badge + label) ──────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        children: [
          _CircleBadge(icon: icon, size: 30, iconSize: 16),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.forest700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Circular icon badge ────────────────────────────────────────────────────
// Soft mint fill + faint forest border. Used by both _SummaryRow and
// _SectionHeader so every icon in the card reads as the same family.

class _CircleBadge extends StatelessWidget {
  const _CircleBadge({
    required this.icon,
    this.size = 30,
    this.iconSize = 16,
  });
  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.mintChip,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.forest100, width: 1),
      ),
      child: Icon(icon, size: iconSize, color: AppColors.forest600),
    );
  }
}

// ─── Soft full-width divider ────────────────────────────────────────────────

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(height: 1, color: AppColors.stone100),
    );
  }
}

// ─── Dotted leader line ─────────────────────────────────────────────────────
// CustomPainter rather than a Row of dots so it scales with the available
// width without re-laying out a variable number of children.

class _DottedLine extends StatelessWidget {
  const _DottedLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      width: double.infinity,
      child: CustomPaint(painter: _DottedLinePainter()),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.stone200
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    const dotSpacing = 4.0;
    final y = size.height / 2;
    for (double x = 0; x < size.width; x += dotSpacing) {
      canvas.drawLine(Offset(x, y), Offset(x + 0.1, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Mountain + sun logo ────────────────────────────────────────────────────
// Hand-drawn-style mark used at the top of both the in-app preview card and
// the shared PDF. Pure CustomPaint so there's no asset dependency — the
// same vectors translate cleanly to the PDF's painter API in _sharePdf.

class _MountainLogo extends StatelessWidget {
  const _MountainLogo({this.size = 60});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MountainLogoPainter()),
    );
  }
}

class _MountainLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centre = Offset(w / 2, h / 2);
    final r = (w / 2) - 1;

    final inkColor = AppColors.forest700;
    final stroke = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = inkColor
      ..style = PaintingStyle.fill;

    // ── Outer circle frame ──────────────────────────────────────────────
    canvas.drawCircle(centre, r, stroke);

    // ── Sun + rays (upper third) ────────────────────────────────────────
    final sunCentre = Offset(w * 0.50, h * 0.36);
    final sunR = w * 0.085;
    canvas.drawCircle(sunCentre, sunR, stroke);
    // 7 short rays fanning out from the sun's upper arc
    const rayCount = 7;
    final rayInner = sunR + w * 0.025;
    final rayOuter = sunR + w * 0.085;
    for (int i = 0; i < rayCount; i++) {
      // angles from ~-120° to ~-60° (upper arc) in radians
      final t = i / (rayCount - 1);
      final ang = -math.pi * (1 / 6 + (2 / 3) * t) - math.pi / 2;
      final p1 = sunCentre + Offset(math.cos(ang), math.sin(ang)) * rayInner;
      final p2 = sunCentre + Offset(math.cos(ang), math.sin(ang)) * rayOuter;
      canvas.drawLine(p1, p2, stroke);
    }

    // ── Mountains (two overlapping triangles, lower two-thirds) ──────────
    // Right peak (taller, behind)
    final rightPeak = Offset(w * 0.62, h * 0.46);
    final mountainsBase = h * 0.74;
    final rightPath = Path()
      ..moveTo(w * 0.34, mountainsBase)
      ..lineTo(rightPeak.dx, rightPeak.dy)
      ..lineTo(w * 0.88, mountainsBase)
      ..close();
    canvas.drawPath(rightPath, stroke);

    // Left peak (shorter, in front)
    final leftPeak = Offset(w * 0.36, h * 0.56);
    final leftPath = Path()
      ..moveTo(w * 0.16, mountainsBase)
      ..lineTo(leftPeak.dx, leftPeak.dy)
      ..lineTo(w * 0.58, mountainsBase)
      ..close();
    // Fill so the left mountain visually sits in front of the right
    canvas.drawPath(
      leftPath,
      Paint()
        ..color = const Color(0xFFF5F0E8) // card cream — same as outer fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(leftPath, stroke);

    // ── Path/road leading to the mountains ──────────────────────────────
    final pathPath = Path()
      ..moveTo(w * 0.50, h * 0.82)
      ..quadraticBezierTo(w * 0.46, h * 0.74, w * 0.40, h * 0.72);
    canvas.drawPath(pathPath, stroke);

    // ── Ground line ─────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(w * 0.14, mountainsBase),
      Offset(w * 0.88, mountainsBase),
      stroke,
    );

    // Tiny accent dot at the start of the path for a hand-drawn feel
    canvas.drawCircle(Offset(w * 0.50, h * 0.82), 1.0, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Botanical sprig (right-edge decoration on the warning footer) ─────────
// A small stylised twig with leaves fanning out, painted at low opacity so
// the warning copy still reads cleanly. Strokes only — keeps it cheap.

class _BotanicalSprigPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.honey600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Main stem: gentle S-curve from bottom-left up to top-right.
    final stem = Path()
      ..moveTo(w * 0.15, h * 0.95)
      ..cubicTo(
        w * 0.30, h * 0.70,
        w * 0.55, h * 0.45,
        w * 0.85, h * 0.10,
      );
    canvas.drawPath(stem, stroke);

    // Leaves: 5 elongated almond shapes branching off the stem at varying
    // angles. Each is drawn with two quadratic curves so the silhouette
    // tapers to a point at both ends — the visual signature of a leaf.
    void drawLeaf(double tx, double ty, double angle, double leafLen) {
      canvas.save();
      canvas.translate(tx, ty);
      canvas.rotate(angle);
      final lw = leafLen * 0.42; // leaf width = ~42% of length
      final p = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(leafLen * 0.5, -lw, leafLen, 0)
        ..quadraticBezierTo(leafLen * 0.5, lw, 0, 0);
      canvas.drawPath(p, stroke);
      canvas.restore();
    }

    drawLeaf(w * 0.22, h * 0.82, -0.95, w * 0.32);
    drawLeaf(w * 0.32, h * 0.66, 0.55, w * 0.30);
    drawLeaf(w * 0.46, h * 0.52, -1.10, w * 0.34);
    drawLeaf(w * 0.58, h * 0.38, 0.40, w * 0.30);
    drawLeaf(w * 0.72, h * 0.22, -1.20, w * 0.28);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
