import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../components/back_button.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../theme/share_card_kit.dart';
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
  bool _sharing = false;
  final GlobalKey _cardKey = GlobalKey();

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


  // ── Share as image ──────────────────────────────────────────────────────────
  //
  // Captures the same template card the user sees (rendered at its native
  // 1080x1500 inside a FittedBox) to a PNG and hands it to the system share
  // sheet. Nothing leaves the device until the user picks a target. Mirrors the
  // capture-and-share pattern in planner_share_screen / the 100-day card.
  Future<void> _shareImage(AppLocalizations l10n) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    H.medium();
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final file =
          File('${Directory.systemTemp.path}/journey_weekly_summary.png');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)],
          text: l10n.weeklySummarySubtitle);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.weeklySummaryPdfError)),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final journals = ref.watch(journalProvider).valueOrNull ?? [];
    final cravings = ref.watch(cravingProvider).valueOrNull ?? [];
    final thoughts = ref.watch(thoughtRecordProvider).valueOrNull ?? [];
    final activities = ref.watch(activityProvider).valueOrNull ?? [];
    final plannerActivities =
        ref.watch(plannerActivityProvider).valueOrNull ?? [];
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
    // Planner workouts live in a separate store from the standalone activity
    // log; fold them into the same "Movement" tally (and care-day spread) so the
    // shareable summary reflects training logged in the Planner too. The two
    // stores are disjoint — closing off a planned session mints a
    // PlannerActivity, never an ActivityEntry — so there's no double-count.
    final plannerActivityDates = plannerActivities
        .where((a) => _inRange(a.date, rangeStart, rangeEnd))
        .map((a) => a.date)
        .toList();
    activityCount += plannerActivityDates.length;
    int sleepCount =
        sleeps.where((e) => _inRange(e.date, rangeStart, rangeEnd)).length;
    int gratitudeCount = gratitudes.where((e) {
      final d = DateTime.tryParse(e.date);
      return d != null && _inRange(d, rangeStart, rangeEnd);
    }).length;
    int pledgeCount =
        profile != null ? _pledgeCount(profile, rangeStart, rangeEnd) : 0;

    final totalEntries = journalCount +
        cravingCount +
        thoughtCount +
        activityCount +
        sleepCount +
        gratitudeCount +
        pledgeCount;

    // Unique "days you showed up" across every care practice in range.
    final careDays = <DateTime>{};
    void addDay(DateTime d) {
      if (_inRange(d, rangeStart, rangeEnd)) {
        careDays.add(DateTime(d.year, d.month, d.day));
      }
    }

    for (final e in journals) {
      addDay(e.date);
    }
    for (final e in cravings) {
      addDay(e.date);
    }
    for (final e in thoughts) {
      addDay(e.date);
    }
    for (final e in activities) {
      addDay(e.date);
    }
    for (final d in plannerActivityDates) {
      addDay(d);
    }
    for (final e in sleeps) {
      addDay(e.date);
    }
    for (final e in gratitudes) {
      final d = DateTime.tryParse(e.date);
      if (d != null) addDay(d);
    }
    final showedUp = careDays.length;
    final totalDays = rangeEnd.difference(rangeStart).inDays + 1;

    // Most-used support (short label) for the forest badge.
    final supportCounts = <String, int>{
      l10n.weeklySummarySupportJournal: journalCount,
      l10n.weeklySummarySupportCraving: cravingCount,
      l10n.weeklySummarySupportThought: thoughtCount,
      l10n.weeklySummarySupportMovement: activityCount,
      l10n.weeklySummarySupportSleep: sleepCount,
      l10n.weeklySummarySupportGratitude: gratitudeCount,
      l10n.weeklySummarySupportPledge: pledgeCount,
    };
    String? mostUsed;
    var maxCount = 0;
    supportCounts.forEach((k, v) {
      if (v > maxCount) {
        maxCount = v;
        mostUsed = k;
      }
    });
    final mostUsedLabel = (mostUsed != null && maxCount > 0)
        ? mostUsed!
        : l10n.weeklySummarySupportVarious;

    final rows = <_RowData>[
      _RowData(l10n.weeklySummaryJournalEntries, journalCount, _kDotForest),
      _RowData(l10n.weeklySummaryCravingSupport, cravingCount, _kDotHoney),
      _RowData(l10n.weeklySummaryThoughtExercises, thoughtCount, _kDotStone),
      _RowData(l10n.weeklySummaryMovement, activityCount, _kDotForest),
      _RowData(l10n.weeklySummarySleepLogs, sleepCount, _kDotSlate),
      _RowData(l10n.weeklySummaryDailyGratitude, gratitudeCount, _kDotHoney),
      _RowData(l10n.weeklySummaryDailyPledge, pledgeCount, _kDotForestDeep),
    ];

    final affirmation = totalEntries == 0
        ? l10n.weeklySummaryQuietWeek
        : l10n.weeklySummaryAffirmation;

    final fmt = DateFormat('d MMM yyyy');
    final dateRangeLabel =
        '${DateFormat('d MMM').format(rangeStart)} – ${fmt.format(rangeEnd)}';

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

                    // ── Template card (what you see is what you share) ─────────
                    // Rendered at its native 1080x1500 inside a FittedBox so the
                    // on-screen preview and the captured PNG are the same pixels.
                    LayoutBuilder(
                      builder: (context, c) {
                        final w = c.maxWidth;
                        return SizedBox(
                          width: w,
                          height: w * 1500 / 1080,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: 1080,
                              height: 1500,
                              child: RepaintBoundary(
                                key: _cardKey,
                                child: _WeeklySummaryCard(
                                  title: l10n.weeklySummaryTitle,
                                  brand: l10n.weeklySummaryAppName.toUpperCase(),
                                  dateRange: dateRangeLabel,
                                  showedUp: showedUp,
                                  totalDays: totalDays,
                                  showedUpCaption:
                                      l10n.weeklySummaryDaysShowedUp,
                                  mostUsedCaption:
                                      l10n.weeklySummaryMostUsedLabel.toUpperCase(),
                                  mostUsedValue: mostUsedLabel,
                                  sectionLabel: l10n.weeklySummaryCareRecorded,
                                  rows: rows,
                                  affirmation: affirmation,
                                  footer: l10n.weeklySummaryFooterPrivacy,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Share button ───────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _sharing ? null : () => _shareImage(l10n),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.forest600,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        icon: _sharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.ios_share_rounded, size: 18),
                        label: Text(l10n.weeklySummarySharePdf),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: () async {
                        H.light();
                        await _pickCustomRange();
                      },
                      icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                      label: Text(l10n.weeklySummaryEdit),
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

// ─── Weekly Summary share card (matches the design template 1:1) ─────────────
// Fixed-brand 1080x1500 card. Colours are literal on purpose — this is a pinned
// brand artifact mirroring the mockup, not theme-driven UI.

const Color _kCardCream = Color(0xFFF4F1E9);
const Color _kForest = Color(0xFF2E5642);
const Color _kForestBorderFaint = Color(0x472E5642);
const Color _kTitleGreen = Color(0xFF1C3B29);
const Color _kBrandGreen = Color(0xFF3B6B4D);
const Color _kDateGrey = Color(0xFF6B716A);
const Color _kStatBox = Color(0xFFEAEEE0);
const Color _kStatBoxBorder = Color(0x1F2E5642);
const Color _kShowUpCaption = Color(0xFF545B54);
const Color _kMostUsedLabel = Color(0xFFE9DEB8);
const Color _kMostUsedValue = Color(0xFFFBFAF5);
const Color _kRowLabel = Color(0xFF2C402F);
const Color _kRowValue = Color(0xFF1C3B29);
const Color _kRowValueZero = Color(0xFF9AA39A);
const Color _kRowDivider = Color(0x1F2E5642);
const Color _kAffirmBox = Color(0xFFEFEDE3);
const Color _kHoney = Color(0xFFC2922E);
const Color _kAffirmText = Color(0xFF2C5240);
const Color _kFooterGrey = Color(0xFF8A9088);
const Color _kDotForest = Color(0xFF3B7A57);
const Color _kDotHoney = Color(0xFFC2922E);
const Color _kDotStone = Color(0xFFC9C6BC);
const Color _kDotSlate = Color(0xFF5B7C8A);
const Color _kDotForestDeep = Color(0xFF2E5642);

class _RowData {
  const _RowData(this.label, this.value, this.dot);
  final String label;
  final int value;
  final Color dot;
}

TextStyle _frau(double size, Color color,
        {FontWeight w = FontWeight.w600,
        FontStyle style = FontStyle.normal,
        double? height,
        double? ls}) =>
    TextStyle(
        fontFamily: 'Fraunces',
        fontSize: size,
        fontWeight: w,
        fontStyle: style,
        color: color,
        height: height,
        letterSpacing: ls);

TextStyle _int(double size, Color color,
        {FontWeight w = FontWeight.w400, double? height, double? ls}) =>
    TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: w,
        color: color,
        height: height,
        letterSpacing: ls);

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({
    required this.title,
    required this.brand,
    required this.dateRange,
    required this.showedUp,
    required this.totalDays,
    required this.showedUpCaption,
    required this.mostUsedCaption,
    required this.mostUsedValue,
    required this.sectionLabel,
    required this.rows,
    required this.affirmation,
    required this.footer,
  });

  final String title;
  final String brand;
  final String dateRange;
  final int showedUp;
  final int totalDays;
  final String showedUpCaption;
  final String mostUsedCaption;
  final String mostUsedValue;
  final String sectionLabel;
  final List<_RowData> rows;
  final String affirmation;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1080,
      height: 1500,
      child: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: _kCardCream)),
          // Faint botanical watermark, lower-right.
          const Positioned(
            right: 30,
            bottom: 30,
            child: Opacity(
              opacity: 0.07,
              child: SizedBox(
                width: 520,
                height: 520,
                child:
                    CustomPaint(painter: BotanicalSprig(color: _kForest)),
              ),
            ),
          ),
          // Double border frame.
          Positioned(
            left: 40,
            top: 40,
            right: 40,
            bottom: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: _kForest, width: 2),
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
          Positioned(
            left: 50,
            top: 50,
            right: 50,
            bottom: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: _kForestBorderFaint, width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Content.
          Positioned(
            left: 50,
            top: 50,
            right: 50,
            bottom: 50,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(70, 60, 70, 60),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 74,
                            height: 74,
                            child: CustomPaint(
                                painter: LotusMark(
                                    color: _kForest, includeCircle: true)),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(brand,
                                    style: _int(22, _kBrandGreen,
                                        w: FontWeight.w600,
                                        height: 1.0,
                                        ls: 0.22 * 22)),
                                const SizedBox(height: 6),
                                Text(title,
                                    style: _frau(58, _kTitleGreen,
                                        height: 1.0, ls: -0.015 * 58)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(dateRange, style: _int(27, _kDateGrey, height: 1.1)),
                      const SizedBox(height: 26),
                      Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0x402E5642), Color(0x0A2E5642)]),
                        ),
                      ),
                      const SizedBox(height: 30),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _kStatBox,
                                  border: Border.all(color: _kStatBoxBorder),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 34, vertical: 28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: '$showedUp',
                                          style:
                                              _frau(78, _kForest, height: 1.0)),
                                      TextSpan(
                                          text: ' / $totalDays',
                                          style: _frau(36, _kDateGrey)),
                                    ])),
                                    const SizedBox(height: 10),
                                    Text(showedUpCaption,
                                        style: _int(25, _kShowUpCaption,
                                            height: 1.3)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 26),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _kForest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 34, vertical: 28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(mostUsedCaption,
                                        style: _int(23, _kMostUsedLabel,
                                            w: FontWeight.w600,
                                            height: 1.0,
                                            ls: 0.14 * 23)),
                                    const SizedBox(height: 12),
                                    Text(mostUsedValue,
                                        style: _frau(52, _kMostUsedValue,
                                            height: 1.05)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(sectionLabel.toUpperCase(),
                          style: _int(23, _kBrandGreen,
                              w: FontWeight.w600, height: 1.0, ls: 0.16 * 23)),
                      const SizedBox(height: 12),
                      ...rows.map((r) => Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: _kRowDivider)),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 15),
                            child: Row(
                              children: [
                                Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                      color: r.dot, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                    child: Text(r.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            _int(30, _kRowLabel, height: 1.0))),
                                Text('${r.value}',
                                    style: _frau(
                                        36,
                                        r.value == 0
                                            ? _kRowValueZero
                                            : _kRowValue,
                                        height: 1.0)),
                              ],
                            ),
                          )),
                      const SizedBox(height: 30),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ColoredBox(
                          color: _kAffirmBox,
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(width: 5, color: _kHoney),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 34, vertical: 30),
                                    child: Text(affirmation,
                                        style: _frau(34, _kAffirmText,
                                            w: FontWeight.w500,
                                            style: FontStyle.italic,
                                            height: 1.4)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 4,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(footer,
                              style: _int(21, _kFooterGrey, height: 1.4)),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 34,
                          height: 34,
                          child: CustomPaint(
                              painter: LotusMark(
                                  color: _kForest,
                                  includeCircle: false,
                                  strokeWidth: 4.6)),
                        ),
                        const SizedBox(width: 12),
                        Text('journeyforward.app',
                            style: _int(22, _kBrandGreen, w: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
