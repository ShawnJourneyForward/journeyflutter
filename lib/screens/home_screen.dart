import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import '../utils/notification_service.dart';
import '../utils/plant_logic.dart';
import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';

// ─── Daily quotes (indexed by day-of-year mod pool size) ─────────────────────

List<String> _buildQuotes(AppLocalizations l10n) => [
      l10n.homeQuote0,
      l10n.homeQuote1,
      l10n.homeQuote2,
      l10n.homeQuote3,
      l10n.homeQuote4,
      l10n.homeQuote5,
      l10n.homeQuote6,
      l10n.homeQuote7,
      l10n.homeQuote8,
      l10n.homeQuote9,
      l10n.homeQuote10,
      l10n.homeQuote11,
      l10n.homeQuote12,
      l10n.homeQuote13,
      l10n.homeQuote14,
      l10n.homeQuote15,
      l10n.homeQuote16,
      l10n.homeQuote17,
      l10n.homeQuote18,
      l10n.homeQuote19,
      l10n.homeQuote20,
      l10n.homeQuote21,
      l10n.homeQuote22,
      l10n.homeQuote23,
      l10n.homeQuote24,
      l10n.homeQuote25,
      l10n.homeQuote26,
      l10n.homeQuote27,
      l10n.homeQuote28,
      l10n.homeQuote29,
      l10n.homeQuote30,
      l10n.homeQuote31,
      l10n.homeQuote32,
      l10n.homeQuote33,
      l10n.homeQuote34,
      l10n.homeQuote35,
      l10n.homeQuote36,
      l10n.homeQuote37,
      l10n.homeQuote38,
      l10n.homeQuote39,
      l10n.homeQuote40,
      l10n.homeQuote41,
      l10n.homeQuote42,
      l10n.homeQuote43,
      l10n.homeQuote44,
      l10n.homeQuote45,
      l10n.homeQuote46,
      l10n.homeQuote47,
      l10n.homeQuote48,
      l10n.homeQuote49,
    ];

String _dailyQuote(AppLocalizations l10n) {
  final quotes = _buildQuotes(l10n);
  final now = DateTime.now();
  final doy = now.difference(DateTime(now.year)).inDays;
  return quotes[doy % quotes.length];
}

// ─── Daily missions pool ──────────────────────────────────────────────────────

List<String> _buildMissionPool(AppLocalizations l10n) => [
      l10n.homeMission0,
      l10n.homeMission1,
      l10n.homeMission2,
      l10n.homeMission3,
      l10n.homeMission4,
      l10n.homeMission5,
      l10n.homeMission6,
      l10n.homeMission7,
      l10n.homeMission8,
      l10n.homeMission9,
      l10n.homeMission10,
      l10n.homeMission11,
      l10n.homeMission12,
      l10n.homeMission13,
      l10n.homeMission14,
      l10n.homeMission15,
      l10n.homeMission16,
      l10n.homeMission17,
      l10n.homeMission18,
      l10n.homeMission19,
      l10n.homeMission20,
      l10n.homeMission21,
      l10n.homeMission22,
      l10n.homeMission23,
      l10n.homeMission24,
      l10n.homeMission25,
      l10n.homeMission26,
      l10n.homeMission27,
      l10n.homeMission28,
      l10n.homeMission29,
      l10n.homeMission30,
      l10n.homeMission31,
      l10n.homeMission32,
      l10n.homeMission33,
      l10n.homeMission34,
      l10n.homeMission35,
      l10n.homeMission36,
      l10n.homeMission37,
      l10n.homeMission38,
      l10n.homeMission39,
      l10n.homeMission40,
      l10n.homeMission41,
      l10n.homeMission42,
      l10n.homeMission43,
      l10n.homeMission44,
      l10n.homeMission45,
      l10n.homeMission46,
      l10n.homeMission47,
      l10n.homeMission48,
      l10n.homeMission49,
      l10n.homeMission50,
      l10n.homeMission51,
      l10n.homeMission52,
      l10n.homeMission53,
      l10n.homeMission54,
      l10n.homeMission55,
      l10n.homeMission56,
      l10n.homeMission57,
      l10n.homeMission58,
      l10n.homeMission59,
    ];

List<String> _dailyMissions(AppLocalizations l10n) {
  final pool = _buildMissionPool(l10n);
  final seed = DateTime.now().difference(DateTime(2024)).inDays;
  final indices = [
    seed % pool.length,
    (seed + 7) % pool.length,
    (seed + 13) % pool.length
  ];
  return indices.map((i) => pool[i]).toList();
}

// ─── Recovery progress helper ─────────────────────────────────────────────────

class _RecoveryProgress {
  const _RecoveryProgress({
    required this.currentLabel,
    required this.currentBody,
    required this.progress,
    this.nextLabel,
    this.nextIn,
  });

  final String currentLabel;
  final String currentBody;
  final double progress; // 0.0–1.0 between current and next milestone
  final String? nextLabel;
  final String? nextIn;

  static const _milestoneMinutes = [
    720,
    1440,
    2880,
    4320,
    10080,
    20160,
    43200,
    129600,
    259200,
    525960,
    1051920,
  ];

  static const _milestoneLabels = [
    '12 Hours',
    '24 Hours',
    '48 Hours',
    '3 Days',
    '1 Week',
    '2 Weeks',
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year',
    '2 Years & Beyond',
  ];

  static const _milestoneBodies = [
    'Your body begins adjusting. Hydration and rest are your allies right now.',
    'Heart rate and sleep patterns may begin to shift as your body finds its rhythm.',
    'A significant window — be gentle with yourself. Seek support if anything feels unsafe.',
    'The most intense early adjustment may begin to ease. A small window of calm can emerge.',
    'Restorative sleep often begins to return. Vivid dreams can be a sign of deep repair.',
    'Physical stamina may begin to return. Concentration and memory are beginning to sharpen.',
    'Your liver and vital organs may be experiencing meaningful relief.',
    'Dopamine pathways are gradually adjusting. Satisfaction in daily life may begin to return.',
    'Many people notice a steadier baseline. Urges may become less frequent and easier to move through.',
    'The long-term strain on heart, liver, sleep, and mood is meaningfully reduced for many people.',
    'The benefits of reduced alcohol strain can continue to deepen over time.',
  ];

  static _RecoveryProgress compute(Duration elapsed) {
    final mins = elapsed.inMinutes.clamp(0, 999999999);

    if (mins < _milestoneMinutes.first) {
      final frac = (mins / _milestoneMinutes.first).clamp(0.0, 1.0);
      return _RecoveryProgress(
        currentLabel: 'Just Starting',
        currentBody: 'Your body begins healing the moment you stop.',
        progress: frac,
        nextLabel: _milestoneLabels.first,
        nextIn: _formatRemaining(_milestoneMinutes.first - mins),
      );
    }

    int idx = 0;
    for (int i = _milestoneMinutes.length - 1; i >= 0; i--) {
      if (mins >= _milestoneMinutes[i]) {
        idx = i;
        break;
      }
    }

    if (idx == _milestoneMinutes.length - 1) {
      return _RecoveryProgress(
        currentLabel: _milestoneLabels[idx],
        currentBody: _milestoneBodies[idx],
        progress: 1.0,
      );
    }

    final from = _milestoneMinutes[idx];
    final to = _milestoneMinutes[idx + 1];
    final frac = ((mins - from) / (to - from)).clamp(0.0, 1.0);

    return _RecoveryProgress(
      currentLabel: _milestoneLabels[idx],
      currentBody: _milestoneBodies[idx],
      progress: frac,
      nextLabel: _milestoneLabels[idx + 1],
      nextIn: _formatRemaining(to - mins),
    );
  }

  static String _formatRemaining(int mins) {
    if (mins <= 0) return 'now';
    if (mins < 60) return 'in $mins min';
    if (mins < 1440) return 'in ${(mins / 60).round()} hrs';
    final days = (mins / 1440).round();
    return 'in $days ${days == 1 ? "day" : "days"}';
  }
}

// ─── Journey milestone nodes ───────────────────────────────────────────────────

class _MilestoneNode {
  const _MilestoneNode(this.days, this.label, this.icon);
  final int days;
  final String label;
  final IconData icon;
}

List<_MilestoneNode> _buildMilestones(AppLocalizations l10n) => [
      _MilestoneNode(0, l10n.homeMilestoneNode0Label, Icons.eco_outlined),
      _MilestoneNode(
          7, l10n.homeMilestoneNode2Label, Icons.energy_savings_leaf_outlined),
      _MilestoneNode(30, l10n.homeMilestoneNode3Label, Icons.terrain_outlined),
      _MilestoneNode(90, l10n.homeMilestoneNode4Label, Icons.park_outlined),
      _MilestoneNode(180, 'Six months', Icons.local_florist_outlined),
      _MilestoneNode(365, 'One year', Icons.star_outline_rounded),
    ];

// ─── Home Screen ──────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _pledgeController = TextEditingController();
  final _gratitudeController = TextEditingController();
  bool _pledgeSaving = false;
  bool _gratitudeSaving = false;
  bool _isFirstLaunch = false;
  bool _milestonesChecked = false;
  bool _redirectingToOnboarding = false;

  // Edit-override flags: let user tap a saved card to re-enter input mode.
  bool _editingPledge = false;
  bool _editingGratitude = false;

  // Fires at local midnight to clear today's saved state from the screen.
  Timer? _midnightTimer;

  static const _homeVisitedKey = 'home_visited';

  @override
  void initState() {
    super.initState();
    _loadInitialState();
    _scheduleMidnightReset();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final homeVisited = prefs.getBool(_homeVisitedKey) ?? false;
    if (!homeVisited) await prefs.setBool(_homeVisitedKey, true);
    if (mounted) {
      setState(() {
        _isFirstLaunch = !homeVisited;
      });
    }
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    _pledgeController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  /// Schedules a one-shot timer that fires at the next local midnight,
  /// invalidates today's gratitude/pledge so the UI clears automatically,
  /// then re-schedules itself for the following midnight.
  void _scheduleMidnightReset() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final delay = nextMidnight.difference(now);
    _midnightTimer?.cancel();
    _midnightTimer = Timer(delay, () {
      if (!mounted) return;
      ref.invalidate(gratitudeProvider);
      setState(() {
        _editingPledge = false;
        _editingGratitude = false;
      });
      _scheduleMidnightReset(); // re-arm for the next midnight
    });
  }

  /// Ensures the first visible character of [text] is uppercase.
  String _capitalizeFirst(String text) {
    final t = text.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1);
  }

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<void> _savePledge(UserProfile profile) async {
    final text = _capitalizeFirst(_pledgeController.text);
    if (text.isEmpty) return;
    setState(() => _pledgeSaving = true);
    H.light();
    await ref.read(profileProvider.notifier).patch((p) => p.copyWith(
          lastPledgeText: text,
          lastPledgeDate: _today(),
          pledgeStreak:
              p.lastPledgeDate == _yesterday() ? p.pledgeStreak + 1 : 1,
        ));
    if (!mounted) return;
    _pledgeController.clear();
    setState(() {
      _pledgeSaving = false;
      _editingPledge = false;
    });
  }

  Future<void> _saveGratitude() async {
    final text = _capitalizeFirst(_gratitudeController.text);
    if (text.isEmpty) return;
    setState(() => _gratitudeSaving = true);
    H.light();
    await ref.read(gratitudeProvider.notifier).add(text);
    if (!mounted) return;
    _gratitudeController.clear();
    setState(() {
      _gratitudeSaving = false;
      _editingGratitude = false;
    });
  }

  String _yesterday() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(profileProvider);
    final stats = ref.watch(soberDaysProvider);
    final todayGratitude = ref.watch(gratitudeProvider).valueOrNull;
    final goalToggles = ref.watch(weeklyGoalTogglesProvider);
    final missionToggles = ref.watch(missionTogglesProvider);
    final missions = _dailyMissions(l10n);

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.stone50,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.forest600)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.stone50,
        body: Center(child: Text(l10n.homeErrorPrefix(e.toString()))),
      ),
      data: (profile) {
        // Router-level redirect (main.dart) sends profile-less users to
        // /onboarding before this screen mounts. The only way we land here
        // with profile==null is if the provider rebuilt mid-session (e.g.
        // recovery from a corrupted encrypted blob cleared the data). When
        // that happens, the prefs sentinel has already been cleared inside
        // ProfileNotifier.build(), so a one-shot navigation to /onboarding
        // is safe — the router redirect will keep us there. The post-frame
        // callback is single-shot (guarded by _redirectingToOnboarding) to
        // avoid the rebuild-loop that the previous guard caused.
        if (profile == null) {
          if (!_redirectingToOnboarding) {
            _redirectingToOnboarding = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/onboarding');
            });
          }
          return const Scaffold(
            backgroundColor: AppColors.stone50,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.forest600),
            ),
          );
        }
        _redirectingToOnboarding = false;

        // Fire milestone notifications once per app session.
        if (!_milestonesChecked) {
          _milestonesChecked = true;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _checkMilestones(profile));
        }

        final pledgedToday = profile.lastPledgeDate == _today();
        return Scaffold(
          backgroundColor: AppColors.stone50,
          body: SafeArea(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              cacheExtent: 500,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──────────────────────────────────────────
                        _HomeHeader(
                          username: profile.username,
                          isFirstLaunch: _isFirstLaunch,
                          onAvatarTap: () {
                            H.light();
                            context.go('/settings');
                          },
                        ),
                        const SizedBox(height: 24),

                        // ── Serenity Card (hero) ─────────────────────────────
                        RepaintBoundary(child: _SerenityCard(profile: profile)),
                        const SizedBox(height: 14),

                        // ── Money + My Reason ────────────────────────────────
                        if (profile.dailySpend > 0) ...[
                          RepaintBoundary(child: _MoneyCard(profile: profile)),
                          const SizedBox(height: 14),
                        ],

                        // ── Journey milestone nodes ──────────────────────────
                        _JourneyCard(
                          days: stats?.days ?? 0,
                          onTap: () => context.push('/milestone'),
                        ),
                        const SizedBox(height: 14),

                        // ── Daily Pledge ──────────────────────────────────────
                        _PledgeCard(
                          pledgedToday: pledgedToday && !_editingPledge,
                          pledgeText: profile.lastPledgeText,
                          controller: _pledgeController,
                          saving: _pledgeSaving,
                          onSave: () => _savePledge(profile),
                          onEdit: () {
                            _pledgeController.text =
                                profile.lastPledgeText ?? '';
                            setState(() => _editingPledge = true);
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Daily Gratitude ───────────────────────────────────
                        _GratitudeCard(
                          todayEntry: _editingGratitude ? null : todayGratitude,
                          controller: _gratitudeController,
                          saving: _gratitudeSaving,
                          onSave: _saveGratitude,
                          onEdit: () {
                            _gratitudeController.text = todayGratitude ?? '';
                            setState(() => _editingGratitude = true);
                          },
                        ),
                        const SizedBox(height: 14),
                        _MyReasonCard(profile: profile),
                        const SizedBox(height: 14),

                        // ── Weekly Goals ─────────────────────────────────────
                        if (profile.weeklyGoals.isNotEmpty) ...[
                          _WeeklyGoalsCard(
                            goals: profile.weeklyGoals,
                            toggles: goalToggles,
                            onToggle: (i) {
                              ref
                                  .read(weeklyGoalTogglesProvider.notifier)
                                  .toggle(i);
                              H.selection();
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                        // ── Daily Missions ───────────────────────────────────
                        _DailyMissionsCard(
                          missions: missions,
                          toggles: missionToggles,
                          onToggle: (i) {
                            ref.read(missionTogglesProvider.notifier).toggle(i);
                            H.selection();
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Daily Check-In ───────────────────────────────────
                        _CheckInCard(
                          onCraving: () => _showCravingSheet(context, ref),
                          onThought: () => _showThoughtSheet(context, ref),
                          onActivity: () => _showActivitySheet(context, ref),
                          onSleep: () => _showSleepSheet(context, ref),
                        ),
                        const SizedBox(height: 14),

                        // ── Today's Reminder ─────────────────────────────────
                        _TodaysReminderCard(quote: _dailyQuote(l10n)),
                        const SizedBox(height: 14),

                        // ── Recovery Timeline Banner ─────────────────────────
                        _RecoveryBanner(
                          elapsed: stats?.elapsed ?? Duration.zero,
                          onTap: () => context.push('/recovery'),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCravingSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CravingSheet(),
    );
  }

  void _showThoughtSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ThoughtSheet(),
    );
  }

  void _showActivitySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ActivitySheet(),
    );
  }

  void _showSleepSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SleepSheet(),
    );
  }

  // ── Milestone checker ────────────────────────────────────────────────────
  // Called once per HomeScreen lifecycle (flag prevents re-firing on rebuild).

  Future<void> _checkMilestones(UserProfile profile) async {
    const milestoneDays = [1, 7, 14, 30, 60, 90, 180, 365, 730, 1095];
    final now = DateTime.now();
    final days = SoberStats.compute(profile, now).days;

    // ── Day milestones ──────────────────────────────────────────────────────
    if (milestoneDays.contains(days) &&
        !profile.firedMilestoneDays.contains(days)) {
      await NotificationService.fireDayMilestone(days);
      H.heavy();
      if (mounted) {
        await ref.read(profileProvider.notifier).patch(
              (p) => p.copyWith(
                firedMilestoneDays: [...p.firedMilestoneDays, days],
              ),
            );
      }
    }

    // ── Savings milestones ──────────────────────────────────────────────────
    if (profile.dailySpend > 0) {
      const tiers = [50, 100, 250, 500, 1000, 2500, 5000, 10000];
      final saved = SoberStats.compute(profile, now).moneySaved;
      for (final tier in tiers) {
        final tierD = tier.toDouble();
        if (saved >= tierD && !profile.firedSavingsTiers.contains(tierD)) {
          await NotificationService.fireSavingsMilestone(
              tier, profile.currency);
          if (mounted) {
            await ref.read(profileProvider.notifier).patch(
                  (p) => p.copyWith(
                    firedSavingsTiers: [...p.firedSavingsTiers, tierD],
                  ),
                );
          }
        }
      }
    }
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.username,
    required this.isFirstLaunch,
    required this.onAvatarTap,
  });

  final String username;
  final bool isFirstLaunch;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateStr = DateFormat('EEEE, d MMMM').format(DateTime.now());
    final name = username.isEmpty ? l10n.homeFriendFallback : username;
    final firstName = name.split(' ').first;
    final greetingText = 'Hi, $firstName';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Text block ────────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(dateStr,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.stoneText)),
              const SizedBox(height: 6),
              Text(greetingText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.greetingSerif),
              const SizedBox(height: 6),
              Text(l10n.homeTagline, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // ── Avatar ───────────────────────────────────────────────────
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.softBorder),
              boxShadow: AppShadows.luxury,
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: AppColors.forest, size: 27),
          ),
        ),
      ],
    );
  }
}

class _SerenityCard extends ConsumerWidget {
  const _SerenityCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use daily provider — plant image & day count only need midnight refresh.
    // The live HH:MM:SS clock is isolated in _LiveClock below.
    final stats = ref.watch(soberDaysProvider);
    final days = stats?.days ?? 0;
    final elapsed = stats?.elapsed ?? Duration.zero;

    return LuxuryCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: SizedBox(
        height: 294,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.card,
                      AppColors.card,
                      AppColors.mintChip.withOpacity(.34),
                    ],
                    stops: const [0, .46, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -12,
              top: 6,
              bottom: -2,
              width: 258,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.white, Colors.white],
                  stops: [0, .18, 1],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  PlantLogic.getPlantAssetForElapsed(elapsed),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  semanticLabel: PlantLogic.getStageLabel(days),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 240,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.card,
                      AppColors.card.withOpacity(.62),
                      AppColors.card.withOpacity(.02),
                    ],
                    stops: const [0, .24, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 22,
              top: 20,
              right: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('DAYS SOBER', style: AppTextStyles.overline),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$days', style: AppTextStyles.heroNumber),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text('days',
                            style: AppTextStyles.displaySmall.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -0.4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 180,
                    child: Text(
                      'A clearer mind. A stronger you.',
                      style: AppTextStyles.bodyLarge.copyWith(height: 1.35),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SoftDivider(),
                  const SizedBox(height: 10),
                  // Isolated per-second clock — only this tiny widget rebuilds.
                  const _LiveClock(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// \u2500\u2500\u2500 Live HH:MM:SS clock \u2014 only widget that watches the per-second ticker \u2500\u2500\u2500\u2500\u2500\u2500
// Kept deliberately tiny so the expensive SerenityCard stack never rebuilds.

class _LiveClock extends ConsumerWidget {
  const _LiveClock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(soberStatsProvider);
    final hours = stats?.hours ?? 0;
    final minutes = stats?.minutes ?? 0;
    final seconds = stats?.seconds ?? 0;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.82),
          borderRadius: AppRadius.pill,
          border: Border.all(color: AppColors.softBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.leafGreen, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Text(
              '${hours.toString().padLeft(2, '0')}h '
              '${minutes.toString().padLeft(2, '0')}m '
              '${seconds.toString().padLeft(2, '0')}s',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// \u2500\u2500\u2500 Money Reclaimed card \u2014 full-width, real-time, with optional savings goal \u2500\u2500

class _MoneyCard extends ConsumerWidget {
  const _MoneyCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // 10-second provider — money ticks live without causing scroll jitter.
    final stats = ref.watch(soberMoneyProvider);
    final money = stats?.moneySaved ?? 0.0;
    final currency = profile.currency;
    final formatted = _formatMoney(currency, money);

    final goal = profile.savingsGoal;
    final double? progressFraction = (goal != null && goal > 0)
        ? (money / goal).clamp(0.0, 1.0).toDouble()
        : null;

    return GestureDetector(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _GoalSheet(profile: profile),
      ),
      child: LuxuryCard(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Botanical leaves \u2014 top-right decoration
            const Positioned(
              right: 0,
              top: 0,
              child: BotanicalBackground(width: 160, height: 130),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: icon + label
                  Row(
                    children: [
                      const IconChip(
                          icon: Icons.account_balance_wallet_outlined,
                          size: 46),
                      const SizedBox(width: 14),
                      Text(
                        l10n.homeMoneyReclaimed,
                        style: AppTextStyles.overline.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Real-time counter \u2014 ticks every second via soberStatsProvider
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatted,
                      maxLines: 1,
                      softWrap: false,
                      style: AppTextStyles.moneyNumber.copyWith(fontSize: 46),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.homeMoneyAllTime,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.mistGrey),
                  ),
                  const SizedBox(height: 14),
                  const SoftDivider(),
                  const SizedBox(height: 14),
                  Text(
                    l10n.homeMoneyInvesting,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.35),
                  ),
                  // Savings goal progress bar (hidden when no goal is set)
                  if (progressFraction != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressFraction,
                        backgroundColor: AppColors.mintChip,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.forest),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.homeMoneyGoalSavedOf(
                                formatted, _formatMoney(currency, goal!)),
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.homeMoneyGoalPercent(
                              (progressFraction * 100).round()),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.forest,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Set savings goal CTA
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.mintChip,
                      borderRadius: AppRadius.lg,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.track_changes_outlined,
                            color: AppColors.forest, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.settingsSavingsGoalLabel,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.forest),
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.forest, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatMoney(String currency, double amount) {
    if (currency == 'R') {
      return NumberFormat.currency(
              locale: 'en_ZA', symbol: 'R', decimalDigits: 2)
          .format(amount);
    }
    return '$currency${NumberFormat('#,##0.00').format(amount)}';
  }
}

// \u2500\u2500\u2500 Savings goal bottom sheet \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

class _GoalSheet extends ConsumerStatefulWidget {
  const _GoalSheet({required this.profile});
  final UserProfile profile;

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _nameCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final goal = widget.profile.savingsGoal;
    _amountCtrl = TextEditingController(
      text: goal != null ? NumberFormat('#,##0.00').format(goal) : '',
    );
    _nameCtrl = TextEditingController(
      text: widget.profile.savingsGoalName ?? '',
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final raw = _amountCtrl.text.replaceAll(',', '').replaceAll(' ', '').trim();
    final amount = double.tryParse(raw);
    final name = _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim();
    await ref.read(profileProvider.notifier).patchGoal(
          amount: (amount != null && amount > 0) ? amount : null,
          name: name,
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _clear() async {
    if (_saving) return;
    setState(() => _saving = true);
    await ref
        .read(profileProvider.notifier)
        .patchGoal(amount: null, name: null);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasGoal = widget.profile.savingsGoal != null;
    final insets = MediaQuery.of(context).viewInsets.bottom;

    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.softBorder),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.forest, width: 1.5),
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + insets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.softBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.settingsSavingsGoalDialogTitle,
            style: AppTextStyles.overline.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Goal name (optional)
          TextField(
            controller: _nameCtrl,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: l10n.settingsGoalNameHint,
              hintStyle:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.mistGrey),
              border: border,
              enabledBorder: border,
              focusedBorder: focusBorder,
              filled: true,
              fillColor: AppColors.stone50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          // Goal amount
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: l10n.settingsTargetAmountHint,
              hintStyle:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.mistGrey),
              prefixText: '${widget.profile.currency} ',
              prefixStyle:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.forest),
              border: border,
              enabledBorder: border,
              focusedBorder: focusBorder,
              filled: true,
              fillColor: AppColors.stone50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.commonSave,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (hasGoal) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _saving ? null : _clear,
                child: Text(
                  l10n.homeMoneyGoalClear,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.mistGrey),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MyReasonCard extends StatelessWidget {
  const _MyReasonCard({required this.profile});
  final UserProfile profile;

  String? _reason() {
    // Prefer dedicated reasons; fall back to weekly goals as source
    final pool =
        profile.myReasons.isNotEmpty ? profile.myReasons : profile.weeklyGoals;
    if (pool.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return pool[dayOfYear % pool.length];
  }

  @override
  Widget build(BuildContext context) {
    final reason = _reason();
    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.favorite_rounded,
                size: 14, color: AppColors.forest600),
            const SizedBox(width: 6),
            Text('My Reason',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.forest700)),
          ]),
          const SizedBox(height: 10),
          if (reason != null) ...[
            Text(
              '“$reason”',
              style: AppTextStyles.bodySerif.copyWith(
                  color: AppColors.stone700,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.45),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text('rotates daily',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.stone400)),
          ] else ...[
            const SizedBox(height: 8),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_circle_outline_rounded,
                      size: 26, color: AppColors.stone300),
                  const SizedBox(height: 6),
                  Text('Add your reasons\nin Profile',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.stone400),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ─── Journey Card (milestone timeline) ───────────────────────────────────────

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.days, required this.onTap});

  final int days;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final milestones = _buildMilestones(l10n);
    return GestureDetector(
      onTap: onTap,
      child: LuxuryCard(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.homeYourJourney,
                style: AppTextStyles.overline.copyWith(fontSize: 12)),
            const SizedBox(height: 6),
            Text(l10n.homeJourneySubtitle, style: AppTextStyles.bodyLarge),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(milestones.length * 2 - 1, (i) {
                if (i.isOdd) {
                  final achieved = days >= milestones[i ~/ 2].days;
                  return Expanded(
                    child: Container(
                      height: 2,
                      color:
                          achieved ? AppColors.leafGreen : AppColors.softBorder,
                    ),
                  );
                }
                final index = i ~/ 2;
                final node = milestones[index];
                final achieved = days >= node.days;
                final current = achieved &&
                    (index == milestones.length - 1 ||
                        days < milestones[index + 1].days);
                return _MilestoneNodeWidget(
                    node: node, achieved: achieved, isCurrent: current);
              }),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: milestones.map((node) {
                final achieved = days >= node.days;
                final String timing;
                if (achieved) {
                  timing = node.days == 0 ? 'start' : 'done';
                } else if (node.days < 365) {
                  timing = 'Day ${node.days}';
                } else {
                  timing =
                      node.days == 365 ? '1 year' : '${node.days ~/ 365} yr';
                }
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        node.label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color:
                              achieved ? AppColors.forest : AppColors.stoneText,
                          fontSize: 11,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timing,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: achieved
                              ? AppColors.leafGreen
                              : AppColors.mistGrey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _JourneyProgressBar(days: days, milestones: milestones),
          ],
        ),
      ),
    );
  }
}

class _JourneyProgressBar extends StatelessWidget {
  const _JourneyProgressBar({required this.days, required this.milestones});

  final int days;
  final List<_MilestoneNode> milestones;

  @override
  Widget build(BuildContext context) {
    int idx = 0;
    for (int i = milestones.length - 1; i >= 0; i--) {
      if (days >= milestones[i].days) {
        idx = i;
        break;
      }
    }

    final bool isLast = idx == milestones.length - 1;
    final double progress = isLast
        ? 1.0
        : ((days - milestones[idx].days) /
                (milestones[idx + 1].days - milestones[idx].days))
            .clamp(0.0, 1.0);
    final int remaining = isLast ? 0 : milestones[idx + 1].days - days;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Text(
            milestones[idx].label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.forest, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (!isLast)
            Text(
              milestones[idx + 1].label,
              style: AppTextStyles.caption.copyWith(color: AppColors.stoneText),
            ),
        ]),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          key: ValueKey(idx),
          tween: Tween(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOutCubic,
          builder: (_, value, __) => ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: AppColors.softBorder,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.forest),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          isLast
              ? 'One year of sobriety — remarkable.'
              : '$remaining ${remaining == 1 ? 'day' : 'days'} to ${milestones[idx + 1].label.toLowerCase()}',
          style: AppTextStyles.caption
              .copyWith(color: AppColors.mistGrey, fontSize: 10),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _MilestoneNodeWidget extends StatelessWidget {
  const _MilestoneNodeWidget(
      {required this.node, required this.achieved, required this.isCurrent});

  final _MilestoneNode node;
  final bool achieved;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.card,
        border: Border.all(
          color: isCurrent ? AppColors.forest100 : AppColors.softBorder,
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: isCurrent
            ? const [
                BoxShadow(
                  color: Color(0x263F7A5A),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Icon(node.icon,
          size: 18, color: achieved ? AppColors.forest : AppColors.mistGrey),
    );
  }
}

class _PledgeCard extends StatelessWidget {
  const _PledgeCard({
    required this.pledgedToday,
    required this.pledgeText,
    required this.controller,
    required this.saving,
    required this.onSave,
    required this.onEdit,
  });

  final bool pledgedToday;
  final String? pledgeText;
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _EditorialInputCard(
      title: 'DAILY PLEDGE',
      chipIcon: Icons.shield_outlined,
      chipColor: AppColors.forest,
      chipBackground: AppColors.mintChip,
      borderColor: AppColors.softBorder,
      inputTint: AppColors.card,
      buttonColor: AppColors.forest,
      controller: controller,
      saving: saving,
      onSave: onSave,
      onEdit: onEdit,
      hintText: 'e.g., Today I choose clarity.',
      savedText: pledgedToday ? pledgeText : null,
    );
  }
}

class _GratitudeCard extends StatelessWidget {
  const _GratitudeCard({
    required this.todayEntry,
    required this.controller,
    required this.saving,
    required this.onSave,
    required this.onEdit,
  });

  final String? todayEntry;
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _EditorialInputCard(
      title: 'DAILY GRATITUDE',
      chipIcon: Icons.favorite_border_rounded,
      chipColor: AppColors.honey,
      chipBackground: AppColors.honeySoft,
      borderColor: AppColors.honey100,
      inputTint: AppColors.card,
      buttonColor: AppColors.honey,
      controller: controller,
      saving: saving,
      onSave: onSave,
      onEdit: onEdit,
      hintText: 'e.g., I\u2019m grateful for\nanother fresh start.',
      savedText: todayEntry,
    );
  }
}

class _EditorialInputCard extends StatelessWidget {
  const _EditorialInputCard({
    required this.title,
    required this.chipIcon,
    required this.chipColor,
    required this.chipBackground,
    required this.borderColor,
    required this.inputTint,
    required this.buttonColor,
    required this.controller,
    required this.saving,
    required this.onSave,
    required this.hintText,
    required this.onEdit,
    this.savedText,
  });

  final String title;
  final IconData chipIcon;
  final Color chipColor;
  final Color chipBackground;
  final Color borderColor;
  final Color inputTint;
  final Color buttonColor;
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSave;
  final String hintText;
  final VoidCallback onEdit;
  final String? savedText;

  @override
  Widget build(BuildContext context) {
    final isSaved = savedText != null && savedText!.isNotEmpty;

    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      borderColor: isSaved ? AppColors.softBorder : borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + title row (always visible) ─────────────────────────
          Row(
            children: [
              IconChip(
                  icon: chipIcon,
                  color: chipColor,
                  backgroundColor: chipBackground,
                  size: 38),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style:
                          AppTextStyles.overline.copyWith(color: chipColor))),
            ],
          ),
          if (isSaved) ...[
            // ── Saved / read-only state ────────────────────────────────
            // Matches the calm editorial feel of _MyReasonCard.
            // Tap anywhere on the text to switch back to edit mode.
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: Text(
                savedText!,
                style: AppTextStyles.bodySerif.copyWith(
                  color: AppColors.stone700,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ] else ...[
            // ── Input state ────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: inputTint,
                borderRadius: AppRadius.xl,
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    minLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.mistGrey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 98,
                      height: 44,
                      child: FilledButton(
                        onPressed: saving ? null : onSave,
                        style: FilledButton.styleFrom(
                          backgroundColor: buttonColor,
                          shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.lg),
                          textStyle:
                              AppTextStyles.labelLarge.copyWith(fontSize: 15),
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyGoalsCard extends StatelessWidget {
  const _WeeklyGoalsCard({
    required this.goals,
    required this.toggles,
    required this.onToggle,
  });
  final List<String> goals;
  final Set<int> toggles;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Goals', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ...goals.asMap().entries.map((e) {
            final done = toggles.contains(e.key);
            return GestureDetector(
              onTap: () => onToggle(e.key),
              behavior: HitTestBehavior.opaque,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: done ? AppColors.forest600 : Colors.white,
                          border: Border.all(
                            color:
                                done ? AppColors.forest600 : AppColors.stone200,
                            width: 1.5,
                          ),
                          borderRadius: AppRadius.sm,
                        ),
                        child: done
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(e.value,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: done
                                    ? AppColors.stone400
                                    : AppColors.stone700,
                                decoration:
                                    done ? TextDecoration.lineThrough : null)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Daily Missions Card ──────────────────────────────────────────────────────

class _DailyMissionsCard extends StatelessWidget {
  const _DailyMissionsCard({
    required this.missions,
    required this.toggles,
    required this.onToggle,
  });
  final List<String> missions;
  final Set<int> toggles;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final done = toggles.length;
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.homeDailyMissions, style: AppTextStyles.overline),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                  child: Text(l10n.homeMissionsSubtitle,
                      style: AppTextStyles.bodyMedium)),
              Text(l10n.homeMissionsProgress(done, missions.length),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.mistGrey)),
            ],
          ),
          const SizedBox(height: 12),
          ...missions.asMap().entries.map((e) {
            final isDone = toggles.contains(e.key);
            return GestureDetector(
              onTap: () => onToggle(e.key),
              behavior: HitTestBehavior.opaque,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.mintChip : Colors.white,
                          border: Border.all(
                            color: isDone
                                ? AppColors.leafGreen
                                : AppColors.softBorder,
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: isDone
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: AppColors.leafGreen)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(e.value,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: isDone
                                    ? AppColors.stone400
                                    : AppColors.stone700)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Daily Check-In Card ──────────────────────────────────────────────────────

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({
    required this.onCraving,
    required this.onThought,
    required this.onActivity,
    required this.onSleep,
  });
  final VoidCallback onCraving, onThought, onActivity, onSleep;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      (Icons.bolt_rounded, 'Craving', AppColors.honey, onCraving),
      (Icons.psychology_outlined, 'Thought', AppColors.stone400, onThought),
      (
        Icons.directions_run_rounded,
        'Activity',
        AppColors.forest400,
        onActivity
      ),
      (Icons.bedtime_outlined, 'Sleep', AppColors.stone500, onSleep),
    ];

    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DAILY CHECK-IN', style: AppTextStyles.overline),
          const SizedBox(height: 12),
          Row(
            children: buttons.map((b) {
              final (icon, label, color, action) = b;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () {
                      H.light();
                      action();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.stone50,
                        border: Border.all(color: AppColors.stone100),
                        borderRadius: AppRadius.lg,
                      ),
                      child: Column(
                        children: [
                          Icon(icon, size: 22, color: color),
                          const SizedBox(height: 4),
                          Text(label, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Today's Reminder Card ────────────────────────────────────────────────────

class _TodaysReminderCard extends StatelessWidget {
  const _TodaysReminderCard({required this.quote});
  final String quote;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      backgroundColor: AppColors.mintChip,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded,
              color: AppColors.forest400, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(quote,
                style: AppTextStyles.bodySerif.copyWith(
                    color: AppColors.forest700,
                    fontStyle: FontStyle.italic,
                    fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// ─── Recovery Timeline Banner ─────────────────────────────────────────────────

class _RecoveryBanner extends StatelessWidget {
  const _RecoveryBanner({required this.elapsed, required this.onTap});
  final Duration elapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rp = _RecoveryProgress.compute(elapsed);

    return GestureDetector(
      onTap: onTap,
      child: LuxuryCard(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                const IconChip(icon: Icons.timeline_rounded, size: 38),
                const SizedBox(width: 12),
                Text('THE HEALING TIMELINE', style: AppTextStyles.overline),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.mistGrey, size: 20),
              ],
            ),
            const SizedBox(height: 14),

            // ── Current milestone ────────────────────────────────────────
            Text(
              rp.currentLabel,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.forestDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rp.currentBody,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.stoneText.withValues(alpha: 0.78),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // ── Progress bar ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: rp.progress,
                backgroundColor: AppColors.stone100,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.forest),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),

            // ── Next milestone or completion ─────────────────────────────
            if (rp.nextLabel != null)
              Row(
                children: [
                  Text(
                    'Next: ${rp.nextLabel}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '· ${rp.nextIn}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mistGrey,
                    ),
                  ),
                ],
              )
            else
              Text(
                'You have reached every milestone. Remarkable.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.forest,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Check-in bottom sheets ───────────────────────────────────────────────────

Widget _sheetShell({
  required BuildContext context,
  required Widget child,
}) {
  final bottomInset = MediaQuery.of(context).viewInsets.bottom;
  return Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * .92,
    ),
    decoration: const BoxDecoration(
      color: AppColors.card,
      borderRadius: AppRadius.xxl,
    ),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 18),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.stone200,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    ),
  );
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconChip(icon: icon, size: 40),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppTextStyles.titleLarge)),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.mistGrey,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.bodySmall),
        ],
      );
}

class _SheetSectionLabel extends StatelessWidget {
  const _SheetSectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.titleSmall.copyWith(color: AppColors.stone800),
      );
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.forest600.withOpacity(.12)
                : AppColors.stone50,
            borderRadius: AppRadius.pill,
            border: Border.all(
              color: selected
                  ? AppColors.forest600.withOpacity(.35)
                  : AppColors.stone100,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: selected ? AppColors.forest600 : AppColors.stone600,
            ),
          ),
        ),
      );
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.options,
    required this.isSelected,
    required this.onTap,
  });

  final List<String> options;
  final bool Function(String option) isSelected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options
            .map(
              (option) => _ChoiceChip(
                label: option,
                selected: isSelected(option),
                onTap: () => onTap(option),
              ),
            )
            .toList(),
      );
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: 3,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
          filled: true,
          fillColor: AppColors.stone50,
        ),
      );
}

Widget _saveButton({
  required bool saving,
  required VoidCallback onPressed,
  required String label,
  Color color = AppColors.forest600,
}) =>
    SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: saving ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(label),
      ),
    );

const _commonTriggers = [
  'Stress',
  'Social',
  'Boredom',
  'Time of day',
  'Celebration',
  'Sadness',
  'Location',
  'Memory',
  'Hungry',
  'Angry',
  'Tired',
];

const _severityOptions = [
  'Brief',
  'Mild',
  'Moderate',
  'Strong',
  'Consuming',
];

// ?? Craving sheet ???????????????????????????????????????????????????????????

class _CravingSheet extends ConsumerStatefulWidget {
  const _CravingSheet();

  @override
  ConsumerState<_CravingSheet> createState() => _CravingSheetState();
}

class _CravingSheetState extends ConsumerState<_CravingSheet> {
  double _intensity = 5;
  String _severity = 'Moderate';
  double _duration = 5;
  final Set<String> _triggers = {};
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    H.light();
    try {
      await ref.read(cravingProvider.notifier).add(
            _intensity.round(),
            severity: _severity,
            triggers: _triggers.toList(),
            durationMinutes: _duration.round(),
            notes: _notesCtrl.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _sheetShell(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(
              icon: Icons.spa_outlined,
              title: 'Log a craving',
              subtitle:
                  'Noticing the shape of a craving helps you understand the pattern without obeying it.',
            ),
            const SizedBox(height: 22),
            const _SheetSectionLabel('How strong was the craving?'),
            const SizedBox(height: 10),
            _ChoiceWrap(
              options: _severityOptions,
              isSelected: (option) => _severity == option,
              onTap: (option) {
                H.selection();
                setState(() => _severity = option);
              },
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const _SheetSectionLabel('Intensity'),
                const Spacer(),
                Text(
                  '${_intensity.round()} / 10',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.forest600),
                ),
              ],
            ),
            Slider(
              value: _intensity,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) {
                H.selection();
                setState(() => _intensity = v);
              },
              activeColor: AppColors.forest600,
              inactiveColor: AppColors.stone100,
            ),
            const SizedBox(height: 10),
            const _SheetSectionLabel('What triggered it?'),
            const SizedBox(height: 10),
            _ChoiceWrap(
              options: _commonTriggers,
              isSelected: _triggers.contains,
              onTap: (option) {
                H.selection();
                setState(() {
                  if (_triggers.contains(option)) {
                    _triggers.remove(option);
                  } else {
                    _triggers.add(option);
                  }
                });
              },
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const _SheetSectionLabel('How long did it last?'),
                const Spacer(),
                Text(
                  '${_duration.round()} minutes',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.forest600),
                ),
              ],
            ),
            Slider(
              value: _duration,
              min: 1,
              max: 60,
              divisions: 59,
              onChanged: (v) {
                H.selection();
                setState(() => _duration = v);
              },
              activeColor: AppColors.forest600,
              inactiveColor: AppColors.stone100,
            ),
            const SizedBox(height: 12),
            _NotesField(
              controller: _notesCtrl,
              hintText:
                  'Notes (optional) - e.g., passed a bar on the way home.',
            ),
            const SizedBox(height: 18),
            _saveButton(
              saving: _saving,
              onPressed: _save,
              label: 'Save craving',
            ),
          ],
        ),
      );
}

// ?? Thought sheet ????????????????????????????????????????????????????????????

class _ThoughtSheet extends ConsumerStatefulWidget {
  const _ThoughtSheet();

  @override
  ConsumerState<_ThoughtSheet> createState() => _ThoughtSheetState();
}

class _ThoughtSheetState extends ConsumerState<_ThoughtSheet> {
  final _thoughtCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _type = 'neutral';
  String _strength = 'Moderate';
  double _duration = 5;
  final Set<String> _triggers = {};
  bool _saving = false;

  @override
  void dispose() {
    _thoughtCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Text is fully optional — tone, strength and triggers alone are enough.
    final text = _thoughtCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    // Capture context-sensitive objects BEFORE any await — modal contexts
    // can become stale after async gaps causing silent pop/snackbar failures.
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() => _saving = true);
    H.light();
    try {
      await ref.read(thoughtProvider.notifier).add(
            text,
            _type,
            strength: _strength,
            triggers: _triggers.toList(),
            durationMinutes: _duration.round(),
            notes: notes.isEmpty ? null : notes,
          );
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Thought saved privately'),
          backgroundColor: AppColors.forest700,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      nav.pop();
    } catch (e) {
      debugPrint('[ThoughtSheet] save failed: $e');
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not save: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => _sheetShell(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Log a thought',
              subtitle:
                  'Noticing thoughts about alcohol is normal. Logging them helps reveal the pattern.',
            ),
            const SizedBox(height: 22),
            const _SheetSectionLabel('What was the thought?'),
            const SizedBox(height: 10),
            TextField(
              controller: _thoughtCtrl,
              maxLines: 3,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Write the thought in your own words (optional).',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone400),
              ),
            ),
            const SizedBox(height: 18),
            const _SheetSectionLabel('How strong was the thought?'),
            const SizedBox(height: 10),
            _ChoiceWrap(
              options: _severityOptions,
              isSelected: (option) => _strength == option,
              onTap: (option) {
                H.selection();
                setState(() => _strength = option);
              },
            ),
            const SizedBox(height: 18),
            const _SheetSectionLabel('What triggered the thought?'),
            const SizedBox(height: 10),
            _ChoiceWrap(
              options: _commonTriggers,
              isSelected: _triggers.contains,
              onTap: (option) {
                H.selection();
                setState(() {
                  if (_triggers.contains(option)) {
                    _triggers.remove(option);
                  } else {
                    _triggers.add(option);
                  }
                });
              },
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const _SheetSectionLabel('How long did it last?'),
                const Spacer(),
                Text(
                  '${_duration.round()} minutes',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.forest600),
                ),
              ],
            ),
            Slider(
              value: _duration,
              min: 1,
              max: 60,
              divisions: 59,
              onChanged: (v) {
                H.selection();
                setState(() => _duration = v);
              },
              activeColor: AppColors.forest600,
              inactiveColor: AppColors.stone100,
            ),
            const SizedBox(height: 8),
            const _SheetSectionLabel('Tone'),
            const SizedBox(height: 10),
            _ChoiceWrap(
              options: const ['Negative', 'Neutral', 'Positive'],
              isSelected: (option) => _type == option.toLowerCase(),
              onTap: (option) {
                H.selection();
                setState(() => _type = option.toLowerCase());
              },
            ),
            const SizedBox(height: 18),
            _NotesField(
              controller: _notesCtrl,
              hintText:
                  'Notes (optional) - e.g., saw an ad and noticed the thought arrive.',
            ),
            const SizedBox(height: 18),
            _saveButton(
              saving: _saving,
              onPressed: _save,
              label: 'Save thought',
            ),
          ],
        ),
      );
}

// ── Activity sheet ────────────────────────────────────────────────────────────

class _ActivitySheet extends ConsumerStatefulWidget {
  const _ActivitySheet();

  @override
  ConsumerState<_ActivitySheet> createState() => _ActivitySheetState();
}

class _ActivitySheetState extends ConsumerState<_ActivitySheet> {
  String _activity = 'walk';
  double _minutes = 30; // slider value — used for non-distance activities
  final _minutesCtrl = TextEditingController(text: '30'); // exact entry
  final _distanceCtrl = TextEditingController(); // km
  String _effort = 'Gentle';
  String _outcome = 'Calmer';
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  // Row 1: walk, run, cycle, swim   Row 2: weights, yoga, other
  static const _types = [
    ('walk', 'Walk', Icons.directions_walk_rounded),
    ('run', 'Run', Icons.directions_run_rounded),
    ('cycle', 'Cycle', Icons.directions_bike_rounded),
    ('swim', 'Swim', Icons.pool_rounded),
    ('weights', 'Weights', Icons.fitness_center_rounded),
    ('yoga', 'Yoga', Icons.self_improvement_outlined),
    ('other', 'Other', Icons.more_horiz_rounded),
  ];

  // Activities that log distance + exact time instead of the slider.
  static const _distanceActivities = {'run', 'cycle', 'swim'};
  bool get _needsDistance => _distanceActivities.contains(_activity);

  @override
  void dispose() {
    _minutesCtrl.dispose();
    _distanceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    int minutes;
    double? distance;
    if (_needsDistance) {
      minutes = int.tryParse(_minutesCtrl.text.trim()) ?? 30;
      final raw = _distanceCtrl.text.trim().replaceAll(',', '.');
      distance = raw.isEmpty ? null : double.tryParse(raw);
    } else {
      minutes = _minutes.round();
    }
    setState(() => _saving = true);
    H.light();
    try {
      await ref.read(activityProvider.notifier).add(
            _activity,
            minutes,
            effort: _effort,
            outcome: _outcome,
            distance: distance,
            notes: _notesCtrl.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _typeGrid(BuildContext context) {
    const row1 = ['walk', 'run', 'cycle', 'swim'];
    const row2 = ['weights', 'yoga', 'other'];

    Widget chip(({String id, String label, IconData icon}) t) {
      final sel = _activity == t.id;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () {
              H.selection();
              setState(() => _activity = t.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppColors.forest50 : AppColors.stone50,
                borderRadius: AppRadius.lg,
                border: Border.all(
                  color: sel ? AppColors.forest300 : AppColors.stone100,
                ),
              ),
              child: Column(
                children: [
                  Icon(t.icon,
                      size: 20,
                      color: sel ? AppColors.forest600 : AppColors.stone400),
                  const SizedBox(height: 4),
                  Text(
                    t.label,
                    style: AppTextStyles.caption.copyWith(
                      color: sel ? AppColors.forest700 : AppColors.stone400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Build typed record list for each row
    final all = _types.map((t) => (id: t.$1, label: t.$2, icon: t.$3)).toList();
    final r1 = all.where((t) => row1.contains(t.id)).toList();
    final r2 = all.where((t) => row2.contains(t.id)).toList();

    return Column(
      children: [
        Row(children: r1.map(chip).toList()),
        const SizedBox(height: 8),
        Row(
          children: [
            ...r2.map(chip),
            // Spacer filler so the 3-chip row aligns left like the 4-chip row.
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => _sheetShell(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(
              icon: Icons.directions_run_rounded,
              title: 'Log activity',
              subtitle:
                  'Movement can shift the nervous system. Capture enough detail to see what truly helps.',
            ),
            const SizedBox(height: 22),
            const _SheetSectionLabel('What did you do?'),
            const SizedBox(height: 10),
            _typeGrid(context),
            const SizedBox(height: 18),

            // ── Duration + Distance ──────────────────────────────────────────
            if (_needsDistance) ...[
              const _SheetSectionLabel('Time & distance'),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Exact time in minutes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duration (min)',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.stone400)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _minutesCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.forest700),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.stone50,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.lg,
                              borderSide:
                                  const BorderSide(color: AppColors.stone100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.lg,
                              borderSide:
                                  const BorderSide(color: AppColors.stone100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.lg,
                              borderSide: const BorderSide(
                                  color: AppColors.forest300, width: 1.5),
                            ),
                            suffixText: 'min',
                            suffixStyle: AppTextStyles.caption
                                .copyWith(color: AppColors.stone400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Distance in km
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Distance (km)',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.stone400)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _distanceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.forest700),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.stone50,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.lg,
                              borderSide:
                                  const BorderSide(color: AppColors.stone100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.lg,
                              borderSide:
                                  const BorderSide(color: AppColors.stone100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.lg,
                              borderSide: const BorderSide(
                                  color: AppColors.forest300, width: 1.5),
                            ),
                            hintText: '0.0',
                            hintStyle: AppTextStyles.titleSmall
                                .copyWith(color: AppColors.stone200),
                            suffixText: 'km',
                            suffixStyle: AppTextStyles.caption
                                .copyWith(color: AppColors.stone400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  const _SheetSectionLabel('Duration'),
                  const Spacer(),
                  Text(
                    '${_minutes.round()} min',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.forest600),
                  ),
                ],
              ),
              Slider(
                value: _minutes,
                min: 5,
                max: 120,
                divisions: 23,
                onChanged: (v) {
                  H.selection();
                  setState(() => _minutes = v);
                },
                activeColor: AppColors.forest600,
                inactiveColor: AppColors.stone100,
              ),
            ],
            const SizedBox(height: 18),

            // ── Effort ───────────────────────────────────────────────────────
            const _SheetSectionLabel('How much effort did it take?'),
            const SizedBox(height: 10),
            _ChoiceWrap(
              options: const ['Gentle', 'Moderate', 'Strong'],
              isSelected: (option) => _effort == option,
              onTap: (option) {
                H.selection();
                setState(() => _effort = option);
              },
            ),
            const SizedBox(height: 18),

            // ── Outcome ──────────────────────────────────────────────────────
            const _SheetSectionLabel('How did you feel after?'),
            const SizedBox(height: 10),
            _ChoiceWrap(
              options: const ['Calmer', 'Clearer', 'Energized', 'Same'],
              isSelected: (option) => _outcome == option,
              onTap: (option) {
                H.selection();
                setState(() => _outcome = option);
              },
            ),
            const SizedBox(height: 18),

            // ── Notes + save ─────────────────────────────────────────────────
            _NotesField(
              controller: _notesCtrl,
              hintText:
                  'Notes (optional) — e.g., walked after dinner and felt steadier.',
            ),
            const SizedBox(height: 18),
            _saveButton(
              saving: _saving,
              onPressed: _save,
              label: 'Save activity',
            ),
          ],
        ),
      );
}

// ?? Sleep sheet ??????????????????????????????????????????????????????????????

class _SleepSheet extends ConsumerStatefulWidget {
  const _SleepSheet();

  @override
  ConsumerState<_SleepSheet> createState() => _SleepSheetState();
}

class _SleepSheetState extends ConsumerState<_SleepSheet> {
  double _hours = 7;
  int _quality = 3;
  final Set<String> _factors = {};
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  static const _qualityLabels = ['Poor', 'Fair', 'OK', 'Good', 'Great'];
  static const _factorOptions = [
    'Restless',
    'Woke often',
    'Dreams',
    'Stress',
    'Cravings',
    'Late caffeine',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    H.light();
    try {
      await ref.read(sleepProvider.notifier).add(
            _hours,
            _quality,
            factors: _factors.toList(),
            notes: _notesCtrl.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _sheetShell(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(
              icon: Icons.bedtime_outlined,
              title: 'Log sleep',
              subtitle:
                  'Sleep is one of the clearest signals in recovery. Small details help reveal the trend.',
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const _SheetSectionLabel('Hours slept'),
                const Spacer(),
                Text(
                  '${_hours.toStringAsFixed(1)} hrs',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.forest600),
                ),
              ],
            ),
            Slider(
              value: _hours,
              min: 1,
              max: 12,
              divisions: 22,
              onChanged: (v) {
                H.selection();
                setState(() => _hours = v);
              },
              activeColor: AppColors.forest600,
              inactiveColor: AppColors.stone100,
            ),
            const SizedBox(height: 8),
            const _SheetSectionLabel('Sleep quality'),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) {
                final selected = _quality == i + 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        H.selection();
                        setState(() => _quality = i + 1);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              selected ? AppColors.forest50 : AppColors.stone50,
                          borderRadius: AppRadius.lg,
                          border: Border.all(
                            color: selected
                                ? AppColors.forest300
                                : AppColors.stone100,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${i + 1}',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: selected
                                    ? AppColors.forest600
                                    : AppColors.stone400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _qualityLabels[i],
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            const _SheetSectionLabel('What affected sleep?'),
            const SizedBox(height: 10),
            _ChoiceWrap(
              options: _factorOptions,
              isSelected: _factors.contains,
              onTap: (option) {
                H.selection();
                setState(() {
                  if (_factors.contains(option)) {
                    _factors.remove(option);
                  } else {
                    _factors.add(option);
                  }
                });
              },
            ),
            const SizedBox(height: 18),
            _NotesField(
              controller: _notesCtrl,
              hintText:
                  'Notes (optional) - e.g., woke once, settled again quickly.',
            ),
            const SizedBox(height: 18),
            _saveButton(
              saving: _saving,
              onPressed: _save,
              label: 'Save sleep',
            ),
          ],
        ),
      );
}

