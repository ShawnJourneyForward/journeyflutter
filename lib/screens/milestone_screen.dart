import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../components/back_button.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Milestone definitions ────────────────────────────────────────────────────

class _Milestone {
  const _Milestone({
    required this.days,
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.benefit,
    required this.emoji,
  });
  final int days;
  final String label;
  final String shortLabel;
  final IconData icon;
  final String benefit;
  final String emoji;
}

List<_Milestone> _buildMilestones(AppLocalizations l10n) => [
      _Milestone(
        days: 1,
        label: l10n.milestoneOneDay,
        shortLabel: l10n.milestoneOneDayShort,
        icon: Icons.eco_outlined,
        emoji: '🌱',
        benefit: l10n.milestoneOneDayBenefit,
      ),
      _Milestone(
        days: 3,
        label: l10n.milestoneThreeDays,
        shortLabel: l10n.milestoneThreeDaysShort,
        icon: Icons.spa_outlined,
        emoji: '🌿',
        benefit: l10n.milestoneThreeDaysBenefit,
      ),
      _Milestone(
        days: 7,
        label: l10n.milestoneOneWeek,
        shortLabel: l10n.milestoneOneWeekShort,
        icon: Icons.wb_sunny_outlined,
        emoji: '☀️',
        benefit: l10n.milestoneOneWeekBenefit,
      ),
      _Milestone(
        days: 14,
        label: l10n.milestoneTwoWeeks,
        shortLabel: l10n.milestoneTwoWeeksShort,
        icon: Icons.energy_savings_leaf_outlined,
        emoji: '🍃',
        benefit: l10n.milestoneTwoWeeksBenefit,
      ),
      _Milestone(
        days: 30,
        label: l10n.milestoneOneMonth,
        shortLabel: l10n.milestoneOneMonthShort,
        icon: Icons.terrain_outlined,
        emoji: '🏔️',
        benefit: l10n.milestoneOneMonthBenefit,
      ),
      _Milestone(
        days: 60,
        label: l10n.milestoneTwoMonths,
        shortLabel: l10n.milestoneTwoMonthsShort,
        icon: Icons.forest_outlined,
        emoji: '🌲',
        benefit: l10n.milestoneTwoMonthsBenefit,
      ),
      _Milestone(
        days: 90,
        label: l10n.milestoneThreeMonths,
        shortLabel: l10n.milestoneThreeMonthsShort,
        icon: Icons.park_outlined,
        emoji: '🌳',
        benefit: l10n.milestoneThreeMonthsBenefit,
      ),
      _Milestone(
        days: 100,
        label: l10n.milestoneHundredDays,
        shortLabel: l10n.milestoneHundredDaysShort,
        icon: Icons.star_border_rounded,
        emoji: '⭐',
        benefit: l10n.milestoneHundredDaysBenefit,
      ),
      _Milestone(
        days: 180,
        label: l10n.milestoneSixMonths,
        shortLabel: l10n.milestoneSixMonthsShort,
        icon: Icons.diamond_outlined,
        emoji: '💎',
        benefit: l10n.milestoneSixMonthsBenefit,
      ),
      _Milestone(
        days: 365,
        label: l10n.milestoneOneYear,
        shortLabel: l10n.milestoneOneYearShort,
        icon: Icons.auto_awesome_outlined,
        emoji: '✨',
        benefit: l10n.milestoneOneYearBenefit,
      ),
    ];

// ─── Helpers ──────────────────────────────────────────────────────────────────

int _currentMilestoneIndex(int days, List<_Milestone> milestones) {
  int idx = -1;
  for (int i = 0; i < milestones.length; i++) {
    if (days >= milestones[i].days) idx = i;
  }
  return idx;
}

double _progressToNext(int days, List<_Milestone> milestones) {
  final current = _currentMilestoneIndex(days, milestones);
  if (current >= milestones.length - 1) return 1.0;
  final from = current < 0 ? 0 : milestones[current].days;
  final to = milestones[current + 1].days;
  return ((days - from) / (to - from)).clamp(0.0, 1.0);
}

// ─── Milestone Screen ─────────────────────────────────────────────────────────

class MilestoneScreen extends ConsumerStatefulWidget {
  const MilestoneScreen({super.key});

  @override
  ConsumerState<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends ConsumerState<MilestoneScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final Animation<double> _progressAnim = CurvedAnimation(
    parent: _progressCtrl,
    curve: Curves.easeOutCubic,
  );

  final _cardKey = GlobalKey();
  int _selectedIndex = 0;
  bool _sharing = false;
  List<_Milestone> _milestones = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressCtrl.forward();
      // Default selection to the current milestone
      final stats = ref.read(soberStatsProvider);
      if (stats != null && mounted) {
        final l10n = AppLocalizations.of(context);
        final milestones = _buildMilestones(l10n);
        final idx = _currentMilestoneIndex(stats.days, milestones);
        if (idx >= 0) setState(() => _selectedIndex = idx);
      }
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    H.medium();

    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final file = File('${Directory.systemTemp.path}/journey_milestone.png');
      await file.writeAsBytes(bytes);

      final l10n = AppLocalizations.of(context);
      final profile = ref.read(profileProvider).valueOrNull;
      final name = profile?.username ?? l10n.appTitle;
      final milestone = _milestones[_selectedIndex];

      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.milestoneShareText(milestone.emoji, name, milestone.label),
      );
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.milestoneCardGenerateError,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.stone700,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final milestones = _buildMilestones(l10n);
    _milestones = milestones;
    // Use the day-tick provider rather than the 1-second one — the entire
    // milestone timeline doesn't need to rebuild 60×/min, only when the
    // sober-day count crosses midnight or when the profile changes.
    final stats = ref.watch(soberDaysProvider);
    final profile = ref.watch(profileProvider).valueOrNull;

    final days = stats?.days ?? 0;
    final currentIdx = _currentMilestoneIndex(days, milestones);
    final progress = _progressToNext(days, milestones);
    final nextMilestone =
        currentIdx < milestones.length - 1 ? milestones[currentIdx + 1] : null;
    final selected = milestones[_selectedIndex];
    final isAchieved = days >= selected.days;
    final moneySaved = stats?.moneySaved ?? 0;

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Back header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 20, 0),
                child: Row(
                  children: [
                    const LuxuryBackButton(),
                    Text(l10n.milestoneScreenTitle,
                        style: AppTextStyles.titleLarge
                            .copyWith(color: AppColors.forest700)),
                  ],
                ),
              ),
            ),

            // ── Hero card ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _HeroCard(
                  days: days,
                  progress: progress,
                  progressAnim: _progressAnim,
                  currentIdx: currentIdx,
                  nextMilestone: nextMilestone,
                  username: profile?.username ?? '',
                  milestones: milestones,
                ),
              ),
            ),

            // ── Achievement spotlight ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _AchievementCard(
                  milestone: selected,
                  achieved: isAchieved,
                  days: days,
                ),
              ),
            ),

            // ── Shareable card ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.milestoneShareCardLabel,
                        style: AppTextStyles.overline),
                    const SizedBox(height: 10),
                    RepaintBoundary(
                      key: _cardKey,
                      child: _ShareCard(
                        milestone: selected,
                        username: profile?.username ?? l10n.appTitle,
                        days: days,
                        achieved: isAchieved,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isAchieved ? _share : null,
                        icon: _sharing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          isAchieved
                              ? l10n.milestoneShareButton
                              : l10n.milestoneNotYetAchieved,
                          style: AppTextStyles.labelLarge
                              .copyWith(color: Colors.white),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: isAchieved
                              ? AppColors.forest600
                              : AppColors.stone200,
                          foregroundColor: AppColors.onForest,
                          minimumSize: const Size.fromHeight(50),
                          shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.lg),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── All milestones ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(l10n.milestoneAllMilestonesLabel,
                    style: AppTextStyles.overline),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final m = milestones[i];
                    final achieved = days >= m.days;
                    final isCurrent = i == currentIdx;
                    final isSelected = i == _selectedIndex;
                    return GestureDetector(
                      onTap: () {
                        H.selection();
                        setState(() => _selectedIndex = i);
                      },
                      child: _MilestoneTile(
                        milestone: m,
                        achieved: achieved,
                        isCurrent: isCurrent,
                        isSelected: isSelected,
                      ),
                    );
                  },
                  childCount: milestones.length,
                ),
              ),
            ),

            // ── Stats row ───────────────────────────────────────────────────
            if (profile != null && (profile.dailySpend > 0 || currentIdx >= 0))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: _StatsRow(
                    days: days,
                    moneySaved: moneySaved,
                    currency: profile.currency,
                    showMoney: profile.dailySpend > 0,
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

          ],
        ),
      ),
    );
  }
}

// ─── Hero card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.days,
    required this.progress,
    required this.progressAnim,
    required this.currentIdx,
    required this.nextMilestone,
    required this.username,
    required this.milestones,
  });

  final int days;
  final double progress;
  final Animation<double> progressAnim;
  final int currentIdx;
  final _Milestone? nextMilestone;
  final String username;
  final List<_Milestone> milestones;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final greeting = username.isNotEmpty
        ? l10n.milestoneHeroGreetingNamed(username.split(' ').first)
        : l10n.milestoneHeroGreeting;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.forest800,
        borderRadius: AppRadius.xxl,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Botanical decoration
          Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.07,
              child: SizedBox(
                width: 160,
                height: 130,
                child: CustomPaint(painter: _BotanicalPainter()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.forest200)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$days',
                        style: AppTextStyles.heroNumber
                            .copyWith(color: Colors.white)),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        days == 1
                            ? l10n.milestoneHeroDaySober
                            : l10n.milestoneHeroDaysSober,
                        style: AppTextStyles.titleSmall
                            .copyWith(color: AppColors.forest200, height: 1.3),
                      ),
                    ),
                  ],
                ),
                if (currentIdx >= 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    milestones[currentIdx].emoji +
                        '  ' +
                        milestones[currentIdx].label,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.honey300),
                  ),
                ],
                if (nextMilestone != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.milestoneHeroNext(nextMilestone!.label),
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.forest300)),
                      AnimatedBuilder(
                        animation: progressAnim,
                        builder: (_, __) => Text(
                          '${(progressAnim.value * progress * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.forest300),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppRadius.pill,
                    child: AnimatedBuilder(
                      animation: progressAnim,
                      builder: (_, __) => LinearProgressIndicator(
                        value: progressAnim.value * progress,
                        minHeight: 6,
                        backgroundColor: AppColors.forest700,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.honey400),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedBuilder(
                    animation: progressAnim,
                    builder: (_, __) => Text(
                      l10n.milestoneHeroProgressDays(days, nextMilestone!.days),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.forest400),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.honey500.withValues(alpha: 0.2),
                      borderRadius: AppRadius.pill,
                      border: Border.all(
                          color: AppColors.honey400.withValues(alpha: 0.4)),
                    ),
                    child: Text(l10n.milestoneEveryReached,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.honey300)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Achievement card ─────────────────────────────────────────────────────────

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.milestone,
    required this.achieved,
    required this.days,
  });
  final _Milestone milestone;
  final bool achieved;
  final int days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: achieved ? AppColors.forest50 : AppColors.stone50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: achieved ? AppColors.forest200 : AppColors.stone100,
                  ),
                ),
                child: Icon(
                  milestone.icon,
                  size: 26,
                  color: achieved ? AppColors.forest600 : AppColors.stone300,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.label,
                      style: AppTextStyles.titleMedium.copyWith(
                        color:
                            achieved ? AppColors.forest700 : AppColors.stone400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            achieved ? AppColors.forest50 : AppColors.stone50,
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                          color: achieved
                              ? AppColors.forest100
                              : AppColors.stone100,
                        ),
                      ),
                      child: Text(
                        achieved
                            ? l10n.milestoneAchievedBadge
                            : l10n.milestoneDaysToGo(milestone.days),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: achieved
                              ? AppColors.forest600
                              : AppColors.stone400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: AppColors.stone100),
          const SizedBox(height: 18),
          Text(
            achieved
                ? l10n.milestoneWhatHappenedLabel
                : l10n.milestoneWhatWillHappenLabel,
            style: AppTextStyles.overline,
          ),
          const SizedBox(height: 10),
          Text(
            milestone.benefit,
            style: AppTextStyles.bodySerif.copyWith(
              color: achieved ? AppColors.stoneText : AppColors.stone400,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Share card ───────────────────────────────────────────────────────────────
//
// Premium dark-forest share card. 16:9 so it embeds cleanly on Instagram /
// X / WhatsApp without being cropped by their previewers. Layout:
//
//   ┌── thin honey border ─────────────────────────────────────────┐
//   │  🌱 JOURNEY FORWARD                                          │
//   │                                                              │
//   │   1   day                            ╲   ⟍ branch          │
//   │       sober                              ⟍ illustration     │
//   │   ─── honey rule ───                                         │
//   │   (🌱) One Day                                               │
//   │                                                              │
//   │  ⊙ Shawn   │   journeyforward.app  🌿                        │
//   └──────────────────────────────────────────────────────────────┘
//
// Everything driven by the live profile.username + selected milestone.
class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.milestone,
    required this.username,
    required this.days,
    required this.achieved,
  });
  final _Milestone milestone;
  final String username;
  final int days;
  final bool achieved;

  // Big number shown on the card (the milestone target, not the live count,
  // so a "One Year" share card always shows "365" even if the user is on day
  // 400). Unachieved fallback is "?" hidden behind the lock overlay anyway.
  String get _heroNumber {
    if (!achieved) return '?';
    // 365 → "1", 730 → "2", 1095 → "3" (years read better as small numbers
    // when paired with the "One Year / Two Years" subtitle).
    const yearMap = {365: '1', 730: '2', 1095: '3'};
    return yearMap[milestone.days] ?? '${milestone.days}';
  }

  // First-name display: keep the share card clean even if the user typed a
  // full name in onboarding. Falls back to a friendly default when no name is
  // set.
  String _displayName(AppLocalizations l10n) {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return l10n.milestoneShareCardFallbackName;
    return trimmed.split(' ').first;
  }

  // Unit word under the hero number. Years milestones invert: the 365-day
  // card reads "1 / year / sober" rather than "365 / day / sober".
  ({String top, String bottom}) _unitLines(AppLocalizations l10n) {
    if (!achieved) {
      return (top: l10n.milestoneUnitDays, bottom: l10n.milestoneUnitSober);
    }
    if (milestone.days >= 365) {
      final years = milestone.days ~/ 365;
      return (
        top: years == 1 ? l10n.milestoneUnitYear : l10n.milestoneUnitYears,
        bottom: l10n.milestoneUnitSober,
      );
    }
    return (
      top: milestone.days == 1
          ? l10n.milestoneUnitDay
          : l10n.milestoneUnitDays,
      bottom: l10n.milestoneUnitSober,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final units = _unitLines(l10n);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          // Deep forest — almost black-green, matches the reference exactly.
          color: AppColors.forest900,
          borderRadius: AppRadius.xxl,
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // ── Right-side branch illustration (subtle relief) ────────────
            Positioned(
              right: -18,
              top: -8,
              bottom: -8,
              width: 220,
              child: Opacity(
                opacity: 0.18,
                child: CustomPaint(painter: _BotanicalPainter()),
              ),
            ),

            // ── Inset honey border ────────────────────────────────────────
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: AppColors.honey400.withOpacity(0.55),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Brand row ───────────────────────────────────────────
                  Row(
                    children: [
                      Icon(Icons.eco_rounded,
                          size: 13,
                          // ignore: deprecated_member_use
                          color: AppColors.honey300.withOpacity(0.85)),
                      const SizedBox(width: 6),
                      Text(
                        l10n.milestoneShareCardBrand,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.forest200,
                          letterSpacing: 2.4,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Hero number + day/sober stack ───────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _heroNumber,
                        style: AppTextStyles.headlineSerif.copyWith(
                          color: AppColors.cream,
                          fontSize: 84,
                          height: 0.95,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              units.top,
                              style: AppTextStyles.headlineSerif.copyWith(
                                color: AppColors.cream,
                                fontSize: 22,
                                height: 1.1,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              units.bottom,
                              style: AppTextStyles.headlineSerif.copyWith(
                                color: AppColors.cream,
                                fontSize: 22,
                                height: 1.1,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ── Honey rule under the hero block ─────────────────────
                  Container(
                    width: 140,
                    height: 0.8,
                    // ignore: deprecated_member_use
                    color: AppColors.honey400.withOpacity(0.55),
                  ),
                  const SizedBox(height: 10),

                  // ── Sprout chip + serif milestone label ─────────────────
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: AppColors.honey400.withOpacity(0.55),
                            width: 0.9,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.eco_rounded,
                            size: 16, color: AppColors.forest400),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          milestone.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headlineSerif.copyWith(
                            color: AppColors.honey300,
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Footer: user · journeyforward.app ───────────────────
                  Row(
                    children: [
                      Icon(Icons.account_circle_outlined,
                          size: 14,
                          // ignore: deprecated_member_use
                          color: AppColors.honey300.withOpacity(0.85)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _displayName(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.honey300,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 1,
                        height: 14,
                        // ignore: deprecated_member_use
                        color: AppColors.honey400.withOpacity(0.45),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'journeyforward.app',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.honey300,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: AppColors.honey400.withOpacity(0.55),
                            width: 0.8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.energy_savings_leaf_outlined,
                            size: 11, color: AppColors.honey300),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Lock overlay for unachieved milestones ────────────────────
            if (!achieved)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppColors.forest900.withOpacity(0.62),
                    borderRadius: AppRadius.xxl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          color: AppColors.honey300, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        l10n.milestoneDaysToUnlock(milestone.days - days),
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.honey200),
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

// ─── Milestone tile ───────────────────────────────────────────────────────────

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.milestone,
    required this.achieved,
    required this.isCurrent,
    required this.isSelected,
  });
  final _Milestone milestone;
  final bool achieved;
  final bool isCurrent;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color iconColor;
    final Color textColor;
    final Color borderColor;

    if (isSelected && isCurrent) {
      bg = AppColors.honey50;
      iconColor = AppColors.honey600;
      textColor = AppColors.forest700;
      borderColor = AppColors.honey300;
    } else if (isSelected) {
      bg = achieved ? AppColors.forest50 : AppColors.stone50;
      iconColor = achieved ? AppColors.forest600 : AppColors.stone400;
      textColor = achieved ? AppColors.forest700 : AppColors.stone400;
      borderColor = achieved ? AppColors.forest400 : AppColors.stone300;
    } else if (isCurrent) {
      bg = AppColors.honey50;
      iconColor = AppColors.honey500;
      textColor = AppColors.forest700;
      borderColor = AppColors.honey200;
    } else if (achieved) {
      bg = AppColors.forest50;
      iconColor = AppColors.forest600;
      textColor = AppColors.forest700;
      borderColor = AppColors.forest100;
    } else {
      bg = Colors.white;
      iconColor = AppColors.stone200;
      textColor = AppColors.stone300;
      borderColor = AppColors.stone100;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: borderColor,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: isSelected ? AppShadows.card : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(milestone.icon, size: 22, color: iconColor),
              if (achieved)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: AppColors.forest600,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, size: 9, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            milestone.shortLabel,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontSize: 9,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.days,
    required this.moneySaved,
    required this.currency,
    required this.showMoney,
  });
  final int days;
  final double moneySaved;
  final String currency;
  final bool showMoney;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SolidCard(
      borderRadius: AppRadius.xl,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('$days',
                    style: AppTextStyles.displaySmall.copyWith(fontSize: 28)),
                const SizedBox(height: 2),
                Text(l10n.milestoneStatsTotalDaysSober,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (showMoney) ...[
            Container(width: 1, height: 40, color: AppColors.stone100),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$currency${NumberFormat('#,##0').format(moneySaved)}',
                    style: AppTextStyles.moneyNumber.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 2),
                  Text(l10n.milestoneStatsMoneyReclaimed,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Botanical painter (shared decorative element) ────────────────────────────
// One large brand leaf — the same vesica mark as the launcher icon — gently
// rotated and cropped by the card edge so it reads as a debossed watermark
// rather than a literal branch illustration. Geometry mirrors the icon:
// pointed-oval body, two thin slit lenses as even-odd holes, stem through
// the axis. Both call sites clip (Clip.hardEdge) and set their own Opacity.

class _BotanicalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final l = size.height * 1.05; // leaf length — oversized, card clips it
    final a = l / 2;

    canvas.save();
    canvas.translate(size.width * 0.72, size.height * 0.55);
    canvas.rotate(0.42);

    // Stem capsule through the axis, poking past both tips.
    final stemW = l * 0.033;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: stemW, height: l * 1.18),
        Radius.circular(stemW / 2),
      ),
      paint,
    );

    // Vesica body — circular arcs through tip/apex/tip, same as the icon.
    final b = l * 0.29;
    final r = (a * a + b * b) / (2 * b);
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(0, -a)
      ..arcToPoint(Offset(0, a), radius: Radius.circular(r))
      ..arcToPoint(Offset(0, -a), radius: Radius.circular(r));

    // Slit lenses dividing the leaf into three lobes.
    final sa = a * 0.785;
    for (final side in [1.0, -1.0]) {
      final x0 = side * l * 0.05;
      final bOut = l * 0.099;
      final bIn = l * 0.066;
      final rOut = (sa * sa + bOut * bOut) / (2 * bOut);
      final rIn = (sa * sa + bIn * bIn) / (2 * bIn);
      path
        ..moveTo(x0, -sa)
        ..arcToPoint(Offset(x0, sa),
            radius: Radius.circular(rOut), clockwise: side > 0)
        ..arcToPoint(Offset(x0, -sa),
            radius: Radius.circular(rIn), clockwise: side < 0);
    }
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
