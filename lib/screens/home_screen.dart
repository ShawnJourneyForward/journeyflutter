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
import '../utils/craving_insights.dart';
import '../utils/haptic_service.dart';
import '../utils/notification_service.dart';
import 'daily_practice_sheets.dart';
import '../utils/plant_logic.dart';
import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';

/// True while the Home list is actively scrolling (drag or fling-settle). The
/// live seconds counter (_LiveCounter) watches this and stops subscribing to
/// the per-second soberStatsProvider while it's true, so its once-a-second
/// rebuild can never land on a scroll frame — the cause of the slow-drag
/// jitter. Flipped exactly once at scroll start and once at scroll end (never
/// per frame), so the flag itself costs nothing.
final _homeScrollingProvider = StateProvider<bool>((ref) => false);

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

// ─── Hero card daily line ────────────────────────────────────────────────────
//
// Rotates the serif line under the Serenity card header. Same visual style as
// the original "Every day forward is a win." — short, declarative, present
// tense, about progress. No softening language ("gentle", "ease", "breathe").
// 50 entries; cycles by day-of-year so the same line shows from midnight
// to midnight without flicker, and the cycle repeats every ~7 weeks.
List<String> _buildHeroQuotes(AppLocalizations l10n) => [
      l10n.homeHeroQuote0,
      l10n.homeHeroQuote1,
      l10n.homeHeroQuote2,
      l10n.homeHeroQuote3,
      l10n.homeHeroQuote4,
      l10n.homeHeroQuote5,
      l10n.homeHeroQuote6,
      l10n.homeHeroQuote7,
      l10n.homeHeroQuote8,
      l10n.homeHeroQuote9,
      l10n.homeHeroQuote10,
      l10n.homeHeroQuote11,
      l10n.homeHeroQuote12,
      l10n.homeHeroQuote13,
      l10n.homeHeroQuote14,
      l10n.homeHeroQuote15,
      l10n.homeHeroQuote16,
      l10n.homeHeroQuote17,
      l10n.homeHeroQuote18,
      l10n.homeHeroQuote19,
      l10n.homeHeroQuote20,
      l10n.homeHeroQuote21,
      l10n.homeHeroQuote22,
      l10n.homeHeroQuote23,
      l10n.homeHeroQuote24,
      l10n.homeHeroQuote25,
      l10n.homeHeroQuote26,
      l10n.homeHeroQuote27,
      l10n.homeHeroQuote28,
      l10n.homeHeroQuote29,
      l10n.homeHeroQuote30,
      l10n.homeHeroQuote31,
      l10n.homeHeroQuote32,
      l10n.homeHeroQuote33,
      l10n.homeHeroQuote34,
      l10n.homeHeroQuote35,
      l10n.homeHeroQuote36,
      l10n.homeHeroQuote37,
      l10n.homeHeroQuote38,
      l10n.homeHeroQuote39,
      l10n.homeHeroQuote40,
      l10n.homeHeroQuote41,
      l10n.homeHeroQuote42,
      l10n.homeHeroQuote43,
      l10n.homeHeroQuote44,
      l10n.homeHeroQuote45,
      l10n.homeHeroQuote46,
      l10n.homeHeroQuote47,
      l10n.homeHeroQuote48,
      l10n.homeHeroQuote49,
    ];

String _heroDailyLine(AppLocalizations l10n) {
  final quotes = _buildHeroQuotes(l10n);
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

  static List<String> _milestoneLabels(AppLocalizations l10n) => [
        l10n.recoveryM1Label,
        l10n.recoveryM2Label,
        l10n.recoveryM3Label,
        l10n.recoveryM4Label,
        l10n.recoveryM5Label,
        l10n.recoveryM6Label,
        l10n.recoveryM7Label,
        l10n.recoveryM8Label,
        l10n.recoveryM9Label,
        l10n.recoveryM10Label,
        l10n.recoveryM11Label,
      ];

  static List<String> _milestoneBodies(AppLocalizations l10n) => [
        l10n.homeRecoveryBody0,
        l10n.homeRecoveryBody1,
        l10n.homeRecoveryBody2,
        l10n.homeRecoveryBody3,
        l10n.homeRecoveryBody4,
        l10n.homeRecoveryBody5,
        l10n.homeRecoveryBody6,
        l10n.homeRecoveryBody7,
        l10n.homeRecoveryBody8,
        l10n.homeRecoveryBody9,
        l10n.homeRecoveryBody10,
      ];

  static _RecoveryProgress compute(AppLocalizations l10n, Duration elapsed) {
    final labels = _milestoneLabels(l10n);
    final bodies = _milestoneBodies(l10n);
    final mins = elapsed.inMinutes.clamp(0, 999999999);

    if (mins < _milestoneMinutes.first) {
      final frac = (mins / _milestoneMinutes.first).clamp(0.0, 1.0);
      return _RecoveryProgress(
        currentLabel: l10n.homeRecoveryJustStarting,
        currentBody: l10n.homeRecoveryJustStartingBody,
        progress: frac,
        nextLabel: labels.first,
        nextIn: _formatRemaining(l10n, _milestoneMinutes.first - mins),
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
        currentLabel: labels[idx],
        currentBody: bodies[idx],
        progress: 1.0,
      );
    }

    final from = _milestoneMinutes[idx];
    final to = _milestoneMinutes[idx + 1];
    final frac = ((mins - from) / (to - from)).clamp(0.0, 1.0);

    return _RecoveryProgress(
      currentLabel: labels[idx],
      currentBody: bodies[idx],
      progress: frac,
      nextLabel: labels[idx + 1],
      nextIn: _formatRemaining(l10n, to - mins),
    );
  }

  static String _formatRemaining(AppLocalizations l10n, int mins) {
    if (mins <= 0) return l10n.homeRecoveryNow;
    if (mins < 60) return l10n.homeRecoveryInMin(mins);
    if (mins < 1440) return l10n.homeRecoveryInHrs((mins / 60).round());
    final days = (mins / 1440).round();
    return l10n.homeRecoveryInDays(days);
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
      _MilestoneNode(
          180, l10n.homeMilestoneNode5Label, Icons.local_florist_outlined),
      _MilestoneNode(
          365, l10n.homeMilestoneNode6Label, Icons.star_outline_rounded),
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
  bool _safetyModalChecked = false;
  bool _plantPrecached = false;
  bool _redirectingToOnboarding = false;

  // Edit-override flags: let user tap a saved card to re-enter input mode.
  bool _editingPledge = false;
  bool _editingGratitude = false;

  // Per-session caches: quote and missions are deterministic for a given day,
  // so there is no need to re-allocate their backing lists on every build.
  String? _cachedQuote;
  List<String>? _cachedMissions;

  // Fires at local midnight to clear today's saved state from the screen.
  Timer? _midnightTimer;

  static const _homeVisitedKey = 'home_visited';
  static const _safetyModalSeenKey = 'safety_modal_seen';

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
    final missions = _cachedMissions ??= _dailyMissions(l10n);

    return profileAsync.when(
      loading: () => Scaffold(
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
          return Scaffold(
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

        // One-time safety note + medical disclaimer (first Home visit ever).
        if (!_safetyModalChecked) {
          _safetyModalChecked = true;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _maybeShowSafetyModal());
        }

        // Pre-decode the hero plant at display size so the first scroll/paint
        // isn't blocked on an image decode. ResizeImage form + width match the
        // on-screen decode in _BlendedPlant so the cache key is identical.
        if (!_plantPrecached) {
          _plantPrecached = true;
          final plantAsset = PlantLogic.getPlantAssetForElapsed(
              stats?.elapsed ?? Duration.zero);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            precacheImage(
              ResizeImage(AssetImage(plantAsset),
                  width: _plantCacheWidth(context)),
              context,
            );
          });
        }

        final pledgedToday = profile.lastPledgeDate == _today();

        // Build the card list once so the SliverList delegate can index it.
        // Each entry is wrapped in a RepaintBoundary → its own compositor
        // layer → scroll becomes a pure GPU translation. SliverList culls
        // entries outside cacheExtent, so off-screen cards skip layout
        // entirely instead of all rendering eagerly in a single sliver.
        final cards = <Widget>[
          RepaintBoundary(child: _SerenityCard(profile: profile)),
          if (profile.dailySpend > 0)
            RepaintBoundary(child: _MoneyCard(profile: profile)),
          RepaintBoundary(
            child: _JourneyCard(
              days: stats?.days ?? 0,
              onTap: () => context.push('/milestone'),
            ),
          ),
          RepaintBoundary(
            child: _PledgeCard(
              pledgedToday: pledgedToday && !_editingPledge,
              pledgeText: profile.lastPledgeText,
              controller: _pledgeController,
              saving: _pledgeSaving,
              onSave: () => _savePledge(profile),
              onEdit: () {
                _pledgeController.text = profile.lastPledgeText ?? '';
                setState(() => _editingPledge = true);
              },
            ),
          ),
          const RepaintBoundary(child: _IntentionCard()),
          RepaintBoundary(
            child: _GratitudeCard(
              todayEntry: _editingGratitude ? null : todayGratitude,
              controller: _gratitudeController,
              saving: _gratitudeSaving,
              onSave: _saveGratitude,
              onEdit: () {
                _gratitudeController.text = todayGratitude ?? '';
                setState(() => _editingGratitude = true);
              },
            ),
          ),
          RepaintBoundary(child: _MyReasonCard(profile: profile)),
          if (profile.weeklyGoals.isNotEmpty)
            RepaintBoundary(
              child: _WeeklyGoalsCard(
                goals: profile.weeklyGoals,
                toggles: goalToggles,
                onToggle: (i) {
                  ref.read(weeklyGoalTogglesProvider.notifier).toggle(i);
                  H.selection();
                },
              ),
            ),
          RepaintBoundary(
            child: _DailyMissionsCard(
              missions: missions,
              toggles: missionToggles,
              onToggle: (i) {
                ref.read(missionTogglesProvider.notifier).toggle(i);
                H.selection();
              },
            ),
          ),
          RepaintBoundary(
            child: _CheckInCard(
              onCraving: () => _showCravingSheet(context, ref),
              onThought: () => _showThoughtSheet(context, ref),
              onActivity: () => _showActivitySheet(context, ref),
              onSleep: () => _showSleepSheet(context, ref),
            ),
          ),
          RepaintBoundary(
            child: _TodaysReminderCard(quote: _cachedQuote ??= _dailyQuote(l10n)),
          ),
          RepaintBoundary(
            child: _RecoveryBanner(
              elapsed: stats?.elapsed ?? Duration.zero,
              onTap: () => context.push('/recovery'),
            ),
          ),
        ];

        return Scaffold(
          backgroundColor: AppColors.stone50,
          body: SafeArea(
            // Freeze the live counter while the list is actively scrolling so
            // its once-a-second rebuild can't land on a scroll frame (the
            // slow-drag jitter). One flag flip at scroll start, one at scroll
            // end — nothing happens per frame.
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollStartNotification) {
                  ref.read(_homeScrollingProvider.notifier).state = true;
                } else if (n is ScrollEndNotification) {
                  ref.read(_homeScrollingProvider.notifier).state = false;
                }
                return false;
              },
              child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              // Generous cache so the 470px hero + the cards just past it stay
              // warm on short flicks/reversals — avoids re-rasterizing the
              // hero and ~12 card shadows every time they re-enter view.
              cacheExtent: 1400,
              slivers: [
                // Header pins in its own sliver so the avatar tap target is
                // always cheap to hit-test and the header never participates
                // in card list re-layout.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                    child: _HomeHeader(
                      username: profile.username,
                      isFirstLaunch: _isFirstLaunch,
                      onAvatarTap: () {
                        H.light();
                        context.go('/settings');
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: EdgeInsets.only(
                            bottom: i == cards.length - 1 ? 0 : 14),
                        child: cards[i],
                      ),
                      childCount: cards.length,
                      // We already wrap every card in a RepaintBoundary above.
                      addRepaintBoundaries: false,
                      // Default semantic indexes are fine; turning them off
                      // saves a tiny per-item cost during scroll.
                      addSemanticIndexes: false,
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCravingSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
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
    const milestoneDays = [
      1, 2, 3, 5, 7, 10, 14, 21, 30, 60, 90, 180, 365, 730, 1095,
    ];
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
      // A milestone is when the streak feels most precious — if there's no
      // recent backup, this is the one moment a gentle nudge lands.
      await _maybeNudgeBackup();
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

  // ── Backup nudge ──────────────────────────────────────────────────────────
  // Shown only right after a milestone fires, and only when the user has
  // never exported a backup (or not within 14 days). last_backup_date is
  // stamped by the backup screen on successful export.

  Future<void> _maybeNudgeBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('last_backup_date');
    final last = raw == null ? null : DateTime.tryParse(raw);
    final stale = last == null || DateTime.now().difference(last).inDays >= 14;
    if (!stale || !mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        l10n.homeBackupNudge,
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      ),
      backgroundColor: AppColors.stone700,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 7),
      action: SnackBarAction(
        label: l10n.homeBackupNudgeAction,
        textColor: AppColors.honey500,
        onPressed: () => context.push('/backup'),
      ),
    ));
  }

  // ── First-launch safety note ─────────────────────────────────────────────
  // One-time medical disclaimer + crisis signpost (Play health-app policy
  // expects the disclaimer in-app, not only in the store listing).

  Future<void> _maybeShowSafetyModal() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_safetyModalSeenKey) ?? false) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
        title: Row(
          children: [
            Icon(Icons.favorite_outline,
                color: AppColors.forest600, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child:
                  Text(l10n.safetyModalTitle, style: AppTextStyles.titleMedium),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.safetyModalBody, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 12),
              Text(l10n.safetyModalWithdrawal, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 12),
              Text(l10n.safetyModalCrisis, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/crisis');
            },
            child: Text(l10n.safetyModalCrisisButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.safetyModalDismiss),
          ),
        ],
      ),
    );
    await prefs.setBool(_safetyModalSeenKey, true);
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
    final greetingText = l10n.homeGreetingName(firstName);

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
              // Tagline removed — same line now lives inside the hero card
              // so the greeting stays compact and the card sits higher.
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
            child: Icon(Icons.person_outline_rounded,
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
    final l10n = AppLocalizations.of(context);
    // Daily provider — plant image only needs midnight refresh.
    // The live counter is isolated in _LiveCounter below.
    final stats = ref.watch(soberDaysProvider);
    final days = stats?.days ?? 0;
    final elapsed = stats?.elapsed ?? Duration.zero;

    return LuxuryCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: SizedBox(
        height: 470,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              child: Column(
                children: [
                  const _HeroCardHeader(),
                  const SizedBox(height: 16),
                  Text(
                    _heroDailyLine(l10n),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displaySmall.copyWith(
                      fontSize: 22,
                      height: 1.15,
                      color: AppColors.forest700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _FramedPlant(
                      asset: PlantLogic.getPlantAssetForElapsed(elapsed),
                      label: PlantLogic.getStageLabel(days),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const _LiveCounter(),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomFlourish(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Decorative header band — line ─ circled leaf ─ line ────────────────────
class _HeroCardHeader extends StatelessWidget {
  const _HeroCardHeader();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 26),
              color: AppColors.forest200,
            ),
          ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.forest300, width: 1),
            ),
            child: Icon(
              Icons.spa_outlined,
              size: 14,
              color: AppColors.forest600,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 26),
              color: AppColors.forest200,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── "TIME SOBER" / "STARTS IN" caption with leaf flourishes ────────────────
// `countdown` is true while the user's quit date is still in the future — the
// counter below it then shows time remaining instead of time elapsed.
class _TimeSoberLabel extends StatelessWidget {
  const _TimeSoberLabel({required this.countdown});
  final bool countdown;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 26, height: 1, color: AppColors.forest100),
        const SizedBox(width: 6),
        Icon(Icons.eco_outlined, size: 11, color: AppColors.forest400),
        const SizedBox(width: 8),
        Text(
          countdown ? l10n.homeStartsIn : l10n.homeTimeSober,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.stone500,
            letterSpacing: 2.4,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.eco_outlined, size: 11, color: AppColors.forest400),
        const SizedBox(width: 6),
        Container(width: 26, height: 1, color: AppColors.forest100),
      ],
    );
  }
}

// ─── Plant image with seamless radial-fade edge blend ────────────────────────
//
// The growth_stages art assets have a soft watercolor background that
// otherwise reads as a hard rectangle pasted onto the card. A card-coloured
// radial vignette painted OVER the image feathers every edge so the plant
// melts into the card. On the flat card surface this is visually identical
// to the previous ShaderMask, but it avoids the saveLayer a ShaderMask
// forces — that saveLayer was the biggest raster cost on the home screen
// when the hero card rasterized mid-scroll.
/// Decode width for the hero plant. The plant displays inside the arch at
/// roughly 320 logical px, so decoding the 720×883 source down to this size
/// shrinks the GPU texture and the raster-cache entry — the hero's first
/// raster mid-flick is the single most expensive paint on the home screen.
/// Shared by the on-screen decode (_BlendedPlant) and the precache in
/// _HomeScreenState so their image-cache keys match (no double decode).
int _plantCacheWidth(BuildContext context) =>
    (320 * MediaQuery.devicePixelRatioOf(context)).round();

class _BlendedPlant extends StatelessWidget {
  const _BlendedPlant({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    final card = AppColors.card;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Image.asset(
          asset,
          fit: BoxFit.contain,
          semanticLabel: label,
          cacheWidth: _plantCacheWidth(context),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.78,
                  // Clear in the middle, fully card-coloured past 95% of the
                  // radius — mirrors the old mask's stops exactly.
                  colors: [
                    card.withOpacity(0.0),
                    card.withOpacity(0.0),
                    card.withOpacity(0.6),
                    card,
                  ],
                  stops: const [0.0, 0.55, 0.85, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Plant inside a botanical arch frame ─────────────────────────────────────
//
// Draws a tombstone/shrine arch border (CustomPaint) around the blended plant.
// Decorative elements mirror the card's existing language: lotus circle at the
// arch peak, diamond accents on the sides, small leaf ornaments at the base.
class _FramedPlant extends StatelessWidget {
  const _FramedPlant({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      // Arch radius: ~half the width creates a gentle dome at the top.
      final archR = w * 0.48;
      // Vertical midpoint of the straight sides (below arch) for side diamonds.
      final sideMidY = archR + (h - archR) * 0.5;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Arch border (CustomPaint) ──────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _TombstoneFramePainter(archRadius: archR),
            ),
          ),

          // ── Plant image, inset to sit comfortably inside the arch ────────
          // Minimal horizontal inset so width grows proportionally with height.
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: _BlendedPlant(asset: asset, label: label),
          ),

          // ── Left-side mid diamond ──────────────────────────────────────
          Positioned(
            left: -3,
            top: sideMidY - 3,
            child: Transform.rotate(
              angle: 0.7854,
              child: Container(width: 6, height: 6, color: AppColors.forest300),
            ),
          ),

          // ── Right-side mid diamond ─────────────────────────────────────
          Positioned(
            right: -3,
            top: sideMidY - 3,
            child: Transform.rotate(
              angle: 0.7854,
              child: Container(width: 6, height: 6, color: AppColors.forest300),
            ),
          ),

          // ── Bottom-left leaf ornament ──────────────────────────────────
          const Positioned(
            left: 10,
            bottom: 10,
            child: _LeafOrnament(mirrored: false),
          ),

          // ── Bottom-right leaf ornament ─────────────────────────────────
          const Positioned(
            right: 10,
            bottom: 10,
            child: _LeafOrnament(mirrored: true),
          ),

          // ── Bottom-centre dot trio ─────────────────────────────────────
          // FittedBox keeps the decoration from triggering a RenderFlex
          // overflow when the parent LayoutBuilder gets a very narrow
          // width (e.g. during the first layout pass on small test
          // surfaces). Row renders at its natural 19px when there's
          // room and scales down gracefully otherwise.
          Positioned(
            bottom: -5,
            left: 0,
            right: 0,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: 0.7854,
                      child: Container(
                          width: 3, height: 3, color: AppColors.forest300),
                    ),
                    const SizedBox(width: 4),
                    Transform.rotate(
                      angle: 0.7854,
                      child: Container(
                          width: 5, height: 5, color: AppColors.forest400),
                    ),
                    const SizedBox(width: 4),
                    Transform.rotate(
                      angle: 0.7854,
                      child: Container(
                          width: 3, height: 3, color: AppColors.forest300),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ─── CustomPainter: tombstone/arch border ─────────────────────────────────────
//
// Draws: flat bottom → right side up → right arch base → semicircle arc →
//        left arch base → left side down → flat bottom (closed).
// The arch radius equals archRadius so the dome peak sits at y=0.
class _TombstoneFramePainter extends CustomPainter {
  const _TombstoneFramePainter({required this.archRadius});
  final double archRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.forest300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final r = archRadius;
    const cr = 5.0; // corner radius at bottom corners

    final path = Path()
      // bottom-left, small corner chamfer
      ..moveTo(cr, h)
      ..lineTo(w - cr, h)
      ..quadraticBezierTo(w, h, w, h - cr)
      // right straight side up to arch base
      ..lineTo(w, r)
      // arch: right → over the top → left  (anticlockwise = dome facing up)
      ..arcToPoint(
        Offset(0, r),
        radius: Radius.circular(r),
        clockwise: false,
      )
      // left straight side down
      ..lineTo(0, h - cr)
      ..quadraticBezierTo(0, h, cr, h);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TombstoneFramePainter old) =>
      old.archRadius != archRadius;
}

// ─── Small leaf ornament drawn at each bottom corner of the frame ─────────────
class _LeafOrnament extends StatelessWidget {
  const _LeafOrnament({required this.mirrored});
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: mirrored ? -1.0 : 1.0,
      child: SizedBox(
        width: 28,
        height: 22,
        child: Stack(
          children: [
            // Lower leaf (larger, rotated out)
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(
                angle: -0.4,
                child: Icon(
                  Icons.energy_savings_leaf_outlined,
                  size: 15,
                  color: AppColors.forest200,
                ),
              ),
            ),
            // Upper leaf (smaller, angled inward)
            Positioned(
              top: 0,
              right: 2,
              child: Transform.rotate(
                angle: 0.9,
                child: Icon(
                  Icons.energy_savings_leaf_outlined,
                  size: 11,
                  color: AppColors.forest200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom decorative band — forest strip with circled leaf badge ─────────
class _BottomFlourish extends StatelessWidget {
  const _BottomFlourish();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 8,
              color: AppColors.forest600,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -2,
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: AppColors.forest600, width: 1.2),
                ),
                child: Icon(
                  Icons.spa,
                  size: 11,
                  color: AppColors.forest600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// \u2500\u2500\u2500 Live 4-column counter \u2014 only widget that watches the per-second ticker \u2500\u2500\u2500\u2500
// Kept deliberately tiny so the expensive SerenityCard stack never rebuilds.

class _LiveCounter extends ConsumerWidget {
  const _LiveCounter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Tick only when this counter is on the active tab (TickerMode is false for
    // an off-stage IndexedStack branch) AND the Home list isn't mid-scroll.
    // When paused, read the last value without subscribing — no rebuild fires
    // until we're visible and still again.
    final live = TickerMode.of(context) && !ref.watch(_homeScrollingProvider);
    final stats =
        live ? ref.watch(soberStatsProvider) : ref.read(soberStatsProvider);
    // Before the quit date arrives we count DOWN to day one; after, we count
    // UP. The label flips with us — both are rendered here so the flip lands on
    // the same per-second frame as the digits (and pauses together on scroll).
    final countdown = stats?.isCountdown ?? false;
    final days = countdown ? (stats?.untilDays ?? 0) : (stats?.days ?? 0);
    final hours = countdown ? (stats?.untilHours ?? 0) : (stats?.hours ?? 0);
    final minutes =
        countdown ? (stats?.untilMinutes ?? 0) : (stats?.minutes ?? 0);
    final seconds =
        countdown ? (stats?.untilSeconds ?? 0) : (stats?.seconds ?? 0);

    return RepaintBoundary(
      child: Column(
        children: [
          _TimeSoberLabel(countdown: countdown),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CounterTile(
                  value: '$days',
                  label: l10n.homeCounterDays(days),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CounterTile(
                  value: '$hours',
                  label: l10n.homeCounterHours(hours),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CounterTile(
                  value: '$minutes',
                  label: l10n.homeCounterMinutes(minutes),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CounterTile(
                  value: '$seconds',
                  label: l10n.homeCounterSeconds(seconds),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Single counter tile: large serif digit + tiny caption.
// FittedBox on the digit lets values up to 9999 days shrink within the tile
// instead of overflowing; values 1–999 render at the full 30px size.
class _CounterTile extends StatelessWidget {
  const _CounterTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.forest100, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 32,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppTextStyles.displaySmall.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forest700,
                  letterSpacing: -0.5,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.stone500,
              letterSpacing: 1.2,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

    return LuxuryCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Stack(
        children: [
          Padding(
            // Extra 42 px bottom so content clears the _BottomFlourish band.
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: icon + label
                Row(
                  children: [
                    const IconChip(
                        icon: Icons.account_balance_wallet_outlined, size: 46),
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
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomFlourish(),
          ),
        ],
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

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.softBorder),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.forest, width: 1.5),
    );

    return Container(
      decoration: BoxDecoration(
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
                foregroundColor: AppColors.onForest,
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
    final l10n = AppLocalizations.of(context);
    final reason = _reason();
    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.spa_rounded, size: 14, color: AppColors.forest600),
            const SizedBox(width: 6),
            Text(l10n.homeMyReasonTitle,
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
            Text(l10n.homeMyReasonRotates,
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.stone400)),
          ] else ...[
            const SizedBox(height: 8),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      size: 26, color: AppColors.stone300),
                  const SizedBox(height: 6),
                  Text(l10n.homeMyReasonAddPrompt,
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
        clip: true,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Padding(
              // Extra bottom clears the _BottomFlourish band.
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.homeYourJourney,
                      style: AppTextStyles.overline.copyWith(fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(l10n.homeJourneySubtitle,
                      style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(milestones.length * 2 - 1, (i) {
                      if (i.isOdd) {
                        final achieved = days >= milestones[i ~/ 2].days;
                        return Expanded(
                          child: Container(
                            height: 2,
                            color: achieved
                                ? AppColors.leafGreen
                                : AppColors.softBorder,
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
                        timing = node.days == 0
                            ? l10n.homeMilestoneTimingStart
                            : l10n.homeMilestoneTimingDone;
                      } else if (node.days < 365) {
                        timing = l10n.homeMilestoneTimingDay(node.days);
                      } else {
                        timing = node.days == 365
                            ? l10n.homeMilestoneTimingOneYear
                            : l10n.homeMilestoneTimingYears(node.days ~/ 365);
                      }
                      return Expanded(
                        child: Column(
                          children: [
                            Text(
                              node.label,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: achieved
                                    ? AppColors.forest
                                    : AppColors.stoneText,
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
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomFlourish(),
            ),
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
    final l10n = AppLocalizations.of(context);
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
              ? l10n.homeJourneyProgressComplete
              : l10n.homeJourneyDaysTo(
                  remaining, milestones[idx + 1].label.toLowerCase()),
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
    final l10n = AppLocalizations.of(context);
    return _EditorialInputCard(
      title: l10n.homeDailyPledge,
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
      hintText: l10n.homePledgeHint,
      savedText: pledgedToday ? pledgeText : null,
    );
  }
}

// ─── Daily Intention card ───────────────────────────────────────────────────
//
// Three visual states driven by todaysIntentionProvider:
//   1. No intention set yet → invite to set today's intention.
//   2. Intention set, not reviewed, before 16:00 → show the intention.
//   3. Intention set, after 16:00, not reviewed → prompt the evening review.
//   4. Intention set + reviewed → show the outcome with a quiet confirmation.
// Tapping anywhere opens IntentionSheet which knows which pane to show.
class _IntentionCard extends ConsumerWidget {
  const _IntentionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todaysIntentionProvider);
    final now = DateTime.now();
    final readyForReview =
        today != null && today.outcome == null && now.hour >= 16;

    return GestureDetector(
      onTap: () {
        H.selection();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const IntentionSheet(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.xl,
          border: Border.all(color: AppColors.softBorder),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: readyForReview ? AppColors.honey50 : AppColors.mintChip,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                readyForReview
                    ? Icons.wb_twilight_rounded
                    : Icons.wb_sunny_outlined,
                color:
                    readyForReview ? AppColors.honey600 : AppColors.forest600,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: today == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeIntentionTitle,
                          style: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.forest700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.homeIntentionPrompt,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.stone500, height: 1.4),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          readyForReview
                              ? l10n.homeIntentionReviewPrompt
                              : l10n.homeIntentionTitle,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: readyForReview
                                ? AppColors.honey600
                                : AppColors.forest500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${today.text}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.stone800,
                            fontStyle: FontStyle.italic,
                            height: 1.35,
                          ),
                        ),
                        if (today.outcome != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _outcomeBlurb(l10n, today.outcome!),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.forest600,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.stone400, size: 22),
          ],
        ),
      ),
    );
  }

  String _outcomeBlurb(AppLocalizations l10n, String o) => switch (o) {
        'did' => l10n.homeIntentionOutcomeDid,
        'partly' => l10n.homeIntentionOutcomePartly,
        'not_yet' => l10n.homeIntentionOutcomeNotYet,
        _ => '',
      };
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
    final l10n = AppLocalizations.of(context);
    return _EditorialInputCard(
      title: l10n.homeDailyGratitude,
      chipIcon: Icons.spa_outlined,
      chipColor: AppColors.honey,
      chipBackground: AppColors.honeySoft,
      borderColor: AppColors.honey100,
      inputTint: AppColors.card,
      buttonColor: AppColors.honey,
      controller: controller,
      saving: saving,
      onSave: onSave,
      onEdit: onEdit,
      hintText: l10n.homeGratitudeHint,
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
    final l10n = AppLocalizations.of(context);
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
                            : Text(l10n.commonSave),
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
    final l10n = AppLocalizations.of(context);
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.homeWeeklyGoals, style: AppTextStyles.titleMedium),
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
    return LuxuryCard(
      clip: true,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            // Extra bottom clears the _BottomFlourish band.
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
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
                                color:
                                    isDone ? AppColors.mintChip : Colors.white,
                                border: Border.all(
                                  color: isDone
                                      ? AppColors.leafGreen
                                      : AppColors.softBorder,
                                  width: 1.5,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: isDone
                                  ? Icon(Icons.check_rounded,
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
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomFlourish(),
          ),
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
    final l10n = AppLocalizations.of(context);
    final buttons = [
      (Icons.bolt_rounded, l10n.homeCheckInCraving, AppColors.honey, onCraving),
      (
        Icons.psychology_outlined,
        l10n.homeCheckInThought,
        AppColors.stone400,
        onThought
      ),
      (
        Icons.directions_run_rounded,
        l10n.homeCheckInActivity,
        AppColors.forest400,
        onActivity
      ),
      (Icons.bedtime_outlined, l10n.homeCheckInSleep, AppColors.stone500,
          onSleep),
    ];

    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.homeDailyCheckIn, style: AppTextStyles.overline),
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
          Icon(Icons.format_quote_rounded,
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
    final l10n = AppLocalizations.of(context);
    final rp = _RecoveryProgress.compute(l10n, elapsed);

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
                Text(l10n.homeHealingTimelineHeader,
                    style: AppTextStyles.overline),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
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
                    AlwaysStoppedAnimation<Color>(AppColors.forest),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),

            // ── Next milestone or completion ─────────────────────────────
            if (rp.nextLabel != null)
              Row(
                children: [
                  Text(
                    l10n.homeRecoveryNext(rp.nextLabel!),
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
                l10n.homeRecoveryAllMilestones,
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
    decoration: BoxDecoration(
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
    this.labelFor,
  });

  final List<String> options;
  final bool Function(String option) isSelected;
  final ValueChanged<String> onTap;

  /// Optional resolver: maps a canonical (stored) option to its localized
  /// display label. Selection/storage logic still uses the raw [option]; only
  /// the visible chip text is translated. When null the option is shown as-is.
  final String Function(String option)? labelFor;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options
            .map(
              (option) => _ChoiceChip(
                label: labelFor?.call(option) ?? option,
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
  Color? color,
}) =>
    SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: saving ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color ?? AppColors.forest600,
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

// ─── Canonical-value → localized-label resolvers ────────────────────────────
// The check-in sheets STORE the canonical English value (so logged data stays
// stable across languages and history/insights can read it back). These
// helpers translate that stored value to a localized label purely for display
// inside the picker chips.

String _severityLabel(AppLocalizations l10n, String value) => switch (value) {
      'Brief' => l10n.homeSeverityBrief,
      'Mild' => l10n.homeSeverityMild,
      'Moderate' => l10n.homeSeverityModerate,
      'Strong' => l10n.homeSeverityStrong,
      'Consuming' => l10n.homeSeverityConsuming,
      _ => value,
    };

String _triggerLabel(AppLocalizations l10n, String value) => switch (value) {
      'Stress' => l10n.homeTriggerStress,
      'Social' => l10n.homeTriggerSocial,
      'Boredom' => l10n.homeTriggerBoredom,
      'Time of day' => l10n.homeTriggerTimeOfDay,
      'Celebration' => l10n.homeTriggerCelebration,
      'Sadness' => l10n.homeTriggerSadness,
      'Location' => l10n.homeTriggerLocation,
      'Memory' => l10n.homeTriggerMemory,
      'Hungry' => l10n.homeTriggerHungry,
      'Angry' => l10n.homeTriggerAngry,
      'Tired' => l10n.homeTriggerTired,
      _ => value,
    };

String _effortLabel(AppLocalizations l10n, String value) => switch (value) {
      'Light' => l10n.homeEffortGentle,
      'Moderate' => l10n.homeEffortModerate,
      'Strong' => l10n.homeEffortStrong,
      _ => value,
    };

String _outcomeLabel(AppLocalizations l10n, String value) => switch (value) {
      'Calmer' => l10n.homeOutcomeCalmer,
      'Clearer' => l10n.homeOutcomeClearer,
      'Energized' => l10n.homeOutcomeEnergized,
      'Same' => l10n.homeOutcomeSame,
      _ => value,
    };

String _sleepFactorLabel(AppLocalizations l10n, String value) => switch (value) {
      'Restless' => l10n.homeSleepFactorRestless,
      'Woke often' => l10n.homeSleepFactorWokeOften,
      'Dreams' => l10n.homeSleepFactorDreams,
      'Stress' => l10n.homeSleepFactorStress,
      'Cravings' => l10n.homeSleepFactorCravings,
      'Late caffeine' => l10n.homeSleepFactorLateCaffeine,
      _ => value,
    };

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

  // ── v2 clinical fields ──────────────────────────────────────────────────
  // HALT pre-check: which underlying states were present. We pre-render
  // these chips at the TOP of the sheet so the user names the state
  // before they get to the slider — that interrupt is the whole point.
  final Set<String> _halt = {};
  // Functional-analysis: what did you do, and how did it turn out? These
  // feed the "what worked last time" engine on every future craving.
  String? _response;
  String? _outcome;

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
            halt: _halt.toList(),
            responseChosen: _response,
            outcome: _outcome,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Personal "last time" hint ─────────────────────────────────────────
    // Pulled live from the user's own craving history, filtered to entries
    // at roughly this intensity (±2) that have a recorded response + outcome.
    // No prompt, no model — just the user's own pattern, surfaced when they
    // most need it.
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(cravingProvider).valueOrNull ?? const [];
    final similar = lastSimilar(all, _intensity.round());

    return _sheetShell(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHeader(
            icon: Icons.spa_outlined,
            title: l10n.homeCravingSheetTitle,
            subtitle: l10n.homeCravingSheetSubtitle,
          ),
          const SizedBox(height: 22),

          // ── HALT pre-check (placed first deliberately) ──────────────────
          _SheetSectionLabel(l10n.homeCravingHaltQuestion),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kHaltOptions.map((opt) {
              final selected = _halt.contains(opt.$1);
              return GestureDetector(
                onTap: () {
                  H.selection();
                  setState(() {
                    if (selected) {
                      _halt.remove(opt.$1);
                    } else {
                      _halt.add(opt.$1);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: selected
                        ? AppColors.honey500.withOpacity(0.15)
                        : AppColors.stone50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.honey500 : AppColors.stone200,
                      width: selected ? 1.4 : 1.0,
                    ),
                  ),
                  child: Text(
                    opt.$2,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: selected ? AppColors.honey600 : AppColors.stone600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.homeCravingHaltBlurb,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.stone400, fontSize: 11),
          ),
          const SizedBox(height: 18),

          _SheetSectionLabel(l10n.homeCravingStrengthQuestion),
          const SizedBox(height: 10),
          _ChoiceWrap(
            options: _severityOptions,
            labelFor: (option) => _severityLabel(l10n, option),
            isSelected: (option) => _severity == option,
            onTap: (option) {
              H.selection();
              setState(() => _severity = option);
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _SheetSectionLabel(l10n.homeCravingIntensityLabel),
              const Spacer(),
              Text(
                l10n.homeCravingIntensityValue(_intensity.round()),
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

          // ── Personal "last time" hint ─────────────────────────────────
          if (similar != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.mintChip,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.forest100),
              ),
              child: Row(
                children: [
                  Icon(Icons.history_rounded,
                      size: 14, color: AppColors.forest500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _lastTimeBlurb(l10n, similar),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.forest700, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          _SheetSectionLabel(l10n.homeCravingTriggerQuestion),
          const SizedBox(height: 10),
          _ChoiceWrap(
            options: _commonTriggers,
            labelFor: (option) => _triggerLabel(l10n, option),
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
              _SheetSectionLabel(l10n.homeCravingDurationQuestion),
              const Spacer(),
              Text(
                l10n.homeCravingDurationValue(_duration.round()),
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

          // ── Response chosen (the A → B in ABC analysis) ───────────────
          const SizedBox(height: 14),
          _SheetSectionLabel(l10n.homeActivityTypeQuestion),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kCravingResponses.map((r) {
              final selected = _response == r.slug;
              return GestureDetector(
                onTap: () {
                  H.selection();
                  setState(() => _response = selected ? null : r.slug);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: selected
                        ? AppColors.forest600.withOpacity(0.12)
                        : AppColors.stone50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          selected ? AppColors.forest600 : AppColors.stone200,
                      width: selected ? 1.4 : 1.0,
                    ),
                  ),
                  child: Text(
                    r.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color:
                          selected ? AppColors.forest700 : AppColors.stone600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // ── Outcome (the C in ABC) ────────────────────────────────────
          const SizedBox(height: 18),
          _SheetSectionLabel(l10n.homeCravingOutcomeQuestion),
          const SizedBox(height: 10),
          Row(
            children: [
              _OutcomePill(
                slug: 'stayed_sober',
                label: l10n.homeCravingOutcomeStayedSober,
                icon: Icons.eco_rounded,
                color: AppColors.forest600,
                selected: _outcome == 'stayed_sober',
                onTap: () {
                  H.selection();
                  setState(() => _outcome =
                      _outcome == 'stayed_sober' ? null : 'stayed_sober');
                },
              ),
              const SizedBox(width: 8),
              _OutcomePill(
                slug: 'unclear',
                label: l10n.homeCravingOutcomeUnclear,
                icon: Icons.help_outline_rounded,
                color: AppColors.stone500,
                selected: _outcome == 'unclear',
                onTap: () {
                  H.selection();
                  setState(() =>
                      _outcome = _outcome == 'unclear' ? null : 'unclear');
                },
              ),
              const SizedBox(width: 8),
              _OutcomePill(
                slug: 'slipped',
                label: l10n.homeCravingOutcomeSlipped,
                icon: Icons.water_drop_outlined,
                color: AppColors.blush500,
                selected: _outcome == 'slipped',
                onTap: () {
                  H.selection();
                  setState(() =>
                      _outcome = _outcome == 'slipped' ? null : 'slipped');
                },
              ),
            ],
          ),

          const SizedBox(height: 14),
          _NotesField(
            controller: _notesCtrl,
            hintText: l10n.homeCravingNotesHint,
          ),
          const SizedBox(height: 18),
          _saveButton(
            saving: _saving,
            onPressed: _save,
            label: l10n.homeSaveCraving,
          ),
        ],
      ),
    );
  }

  /// Compose a calm one-liner referencing the user's own most-recent
  /// similar-intensity craving. We deliberately avoid prescriptive phrasing
  /// ("you should…") — it's a memory, not a lecture.
  String _lastTimeBlurb(AppLocalizations l10n, CravingEntry e) {
    final responseLabel = kCravingResponses
        .firstWhere((r) => r.slug == e.responseChosen,
            orElse: () => CravingResponse(e.responseChosen!, e.responseChosen!))
        .label
        .toLowerCase();
    final outcomePart = e.outcome == 'stayed_sober'
        ? l10n.homeLastTimeOutcomeSober
        : e.outcome == 'slipped'
            ? l10n.homeLastTimeOutcomeSlipped
            : '';
    final duration = e.durationMinutes != null
        ? l10n.homeLastTimeDuration(e.durationMinutes!)
        : '';
    return l10n.homeLastTimeBlurb(responseLabel, duration, outcomePart);
  }
}

// Outcome chip used by _CravingSheet for stayed-sober / unclear / slipped.
class _OutcomePill extends StatelessWidget {
  const _OutcomePill({
    required this.slug,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String slug;
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: selected ? color.withOpacity(0.14) : AppColors.stone50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : AppColors.stone200,
              width: selected ? 1.4 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18, color: selected ? color : AppColors.stone400),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: selected ? color : AppColors.stone500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    final l10n = AppLocalizations.of(context);

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
          content: Text(l10n.homeThoughtSavedPrivately),
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
          content: Text(l10n.homeThoughtSaveError(e.toString())),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _sheetShell(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHeader(
            icon: Icons.chat_bubble_outline_rounded,
            title: l10n.homeThoughtSheetTitle,
            subtitle: l10n.homeThoughtSheetSubtitle,
          ),
          const SizedBox(height: 22),
          _SheetSectionLabel(l10n.homeThoughtWhatQuestion),
          const SizedBox(height: 10),
          TextField(
            controller: _thoughtCtrl,
            maxLines: 3,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: l10n.homeThoughtWriteHintOptional,
              hintStyle:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
            ),
          ),
          const SizedBox(height: 18),
          _SheetSectionLabel(l10n.homeThoughtStrengthQuestion),
          const SizedBox(height: 10),
          _ChoiceWrap(
            options: _severityOptions,
            labelFor: (option) => _severityLabel(l10n, option),
            isSelected: (option) => _strength == option,
            onTap: (option) {
              H.selection();
              setState(() => _strength = option);
            },
          ),
          const SizedBox(height: 18),
          _SheetSectionLabel(l10n.homeThoughtTriggerQuestion),
          const SizedBox(height: 10),
          _ChoiceWrap(
            options: _commonTriggers,
            labelFor: (option) => _triggerLabel(l10n, option),
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
              _SheetSectionLabel(l10n.homeThoughtDurationQuestion),
              const Spacer(),
              Text(
                l10n.homeCravingDurationValue(_duration.round()),
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
          _SheetSectionLabel(l10n.homeThoughtToneLabel),
          const SizedBox(height: 10),
          _ChoiceWrap(
            options: const ['Negative', 'Neutral', 'Positive'],
            labelFor: (option) => switch (option) {
              'Negative' => l10n.homeToneNegative,
              'Neutral' => l10n.homeToneNeutral,
              'Positive' => l10n.homeTonePositive,
              _ => option,
            },
            isSelected: (option) => _type == option.toLowerCase(),
            onTap: (option) {
              H.selection();
              setState(() => _type = option.toLowerCase());
            },
          ),
          const SizedBox(height: 18),
          _NotesField(
            controller: _notesCtrl,
            hintText: l10n.homeThoughtNotesHint,
          ),
          const SizedBox(height: 18),
          _saveButton(
            saving: _saving,
            onPressed: _save,
            label: l10n.homeSaveThought,
          ),
        ],
      ),
    );
  }
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
  String _effort = 'Light';
  String _outcome = 'Calmer';
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  // Row 1: walk, run, cycle, swim   Row 2: gym, yoga, other
  static const _types = [
    ('walk', 'Walk', Icons.directions_walk_rounded),
    ('run', 'Run', Icons.directions_run_rounded),
    ('cycle', 'Cycle', Icons.directions_bike_rounded),
    ('swim', 'Swim', Icons.pool_rounded),
    ('gym', 'Gym', Icons.fitness_center_rounded),
    ('yoga', 'Yoga', Icons.self_improvement_outlined),
    ('other', 'Other', Icons.more_horiz_rounded),
  ];

  // Activities that log distance + exact time instead of a plain duration field.
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

  String _activityTypeLabel(AppLocalizations l10n, String id) => switch (id) {
        'walk' => l10n.homeActivityTypeWalk,
        'run' => l10n.homeActivityTypeRun,
        'cycle' => l10n.homeActivityTypeCycle,
        'swim' => l10n.homeActivityTypeSwim,
        'gym' => l10n.homeActivityTypeGym,
        'yoga' => l10n.homeActivityTypeYoga,
        'other' => l10n.homeActivityTypeOther,
        _ => id,
      };

  Widget _typeGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const row1 = ['walk', 'run', 'cycle', 'swim'];
    const row2 = ['gym', 'yoga', 'other'];

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
                    _activityTypeLabel(l10n, t.id),
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final useImperial =
        ref.watch(profileProvider).valueOrNull?.useImperial ?? false;
    final distanceUnit =
        useImperial ? l10n.homeUnitMiles : l10n.homeUnitKm;

    return _sheetShell(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHeader(
            icon: Icons.directions_run_rounded,
            title: l10n.homeActivitySheetTitle,
            subtitle: l10n.homeActivitySheetSubtitle,
          ),
          const SizedBox(height: 22),
          _SheetSectionLabel(l10n.homeActivityTypeQuestion),
          const SizedBox(height: 10),
          _typeGrid(context),
          const SizedBox(height: 18),

          // ── Duration + Distance ──────────────────────────────────────────
          if (_needsDistance) ...[
            _SheetSectionLabel(l10n.homeActivityTimeDistance),
            const SizedBox(height: 10),
            Row(
              children: [
                // Exact time in minutes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.homeActivityDurationMin,
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
                                BorderSide(color: AppColors.stone100),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.lg,
                            borderSide:
                                BorderSide(color: AppColors.stone100),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.lg,
                            borderSide: BorderSide(
                                color: AppColors.forest300, width: 1.5),
                          ),
                          suffixText: l10n.homeUnitMin,
                          suffixStyle: AppTextStyles.caption
                              .copyWith(color: AppColors.stone400),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Distance field — unit label reflects imperial/metric setting
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.homeActivityDistanceLabel(distanceUnit),
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
                                BorderSide(color: AppColors.stone100),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.lg,
                            borderSide:
                                BorderSide(color: AppColors.stone100),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.lg,
                            borderSide: BorderSide(
                                color: AppColors.forest300, width: 1.5),
                          ),
                          hintText: '0.0',
                          hintStyle: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.stone200),
                          suffixText: distanceUnit,
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
            _SheetSectionLabel(l10n.homeActivityDurationLabel),
            const SizedBox(height: 10),
            TextField(
              controller: _minutesCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.titleSmall.copyWith(color: AppColors.forest700),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.stone50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.lg,
                  borderSide: BorderSide(color: AppColors.stone100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lg,
                  borderSide: BorderSide(color: AppColors.stone100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lg,
                  borderSide:
                      BorderSide(color: AppColors.forest300, width: 1.5),
                ),
                suffixText: l10n.homeUnitMin,
                suffixStyle:
                    AppTextStyles.caption.copyWith(color: AppColors.stone400),
              ),
            ),
          ],
          const SizedBox(height: 18),

          // ── Effort ───────────────────────────────────────────────────────
          _SheetSectionLabel(l10n.homeActivityEffortQuestion),
          const SizedBox(height: 10),
          _ChoiceWrap(
            options: const ['Light', 'Moderate', 'Strong'],
            labelFor: (option) => _effortLabel(l10n, option),
            isSelected: (option) => _effort == option,
            onTap: (option) {
              H.selection();
              setState(() => _effort = option);
            },
          ),
          const SizedBox(height: 18),

          // ── Outcome ──────────────────────────────────────────────────────
          _SheetSectionLabel(l10n.homeActivityOutcomeQuestion),
          const SizedBox(height: 10),
          _ChoiceWrap(
            options: const ['Calmer', 'Clearer', 'Energized', 'Same'],
            labelFor: (option) => _outcomeLabel(l10n, option),
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
            hintText: l10n.homeActivityNotesHint,
          ),
          const SizedBox(height: 18),
          _saveButton(
            saving: _saving,
            onPressed: _save,
            label: l10n.homeSaveActivity,
          ),
        ],
      ),
    );
  }
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

  static const _factorOptions = [
    'Restless',
    'Woke often',
    'Dreams',
    'Stress',
    'Cravings',
    'Late caffeine',
  ];

  List<String> _qualityLabels(AppLocalizations l10n) => [
        l10n.homeSleepQualityPoor,
        l10n.homeSleepQualityFair,
        l10n.homeSleepQualityOK,
        l10n.homeSleepQualityGood,
        l10n.homeSleepQualityGreat,
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final qualityLabels = _qualityLabels(l10n);
    return _sheetShell(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHeader(
            icon: Icons.bedtime_outlined,
            title: l10n.homeSleepSheetTitle,
            subtitle: l10n.homeSleepSheetSubtitle,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _SheetSectionLabel(l10n.homeSleepHoursLabel),
              const Spacer(),
              Text(
                l10n.homeSleepHoursValue(_hours.toStringAsFixed(1)),
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
          _SheetSectionLabel(l10n.homeSleepQualityLabel),
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
                            qualityLabels[i],
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
          _SheetSectionLabel(l10n.homeSleepFactorsShortQuestion),
          const SizedBox(height: 10),
          _ChoiceWrap(
            options: _factorOptions,
            labelFor: (option) => _sleepFactorLabel(l10n, option),
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
            hintText: l10n.homeSleepNotesHintShort,
          ),
          const SizedBox(height: 18),
          _saveButton(
            saving: _saving,
            onPressed: _save,
            label: l10n.homeSaveSleep,
          ),
        ],
      ),
    );
  }
}
