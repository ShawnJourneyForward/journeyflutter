import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
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
];

String _dailyQuote(AppLocalizations l10n) {
  final quotes = _buildQuotes(l10n);
  final doy = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
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
];

List<String> _dailyMissions(AppLocalizations l10n) {
  final pool = _buildMissionPool(l10n);
  final seed = DateTime.now().difference(DateTime(2024)).inDays;
  final indices = [seed % pool.length,
    (seed + 7) % pool.length,
    (seed + 13) % pool.length];
  return indices.map((i) => pool[i]).toList();
}

// ─── Journey milestone nodes ───────────────────────────────────────────────────

class _MilestoneNode {
  const _MilestoneNode(this.days, this.label, this.icon);
  final int days;
  final String label;
  final IconData icon;
}

List<_MilestoneNode> _buildMilestones(AppLocalizations l10n) => [
  _MilestoneNode(0,   l10n.homeMilestoneNode0Label, Icons.eco_outlined),
  _MilestoneNode(1,   l10n.homeMilestoneNode1Label, Icons.wb_sunny_outlined),
  _MilestoneNode(7,   l10n.homeMilestoneNode2Label, Icons.energy_savings_leaf_outlined),
  _MilestoneNode(30,  l10n.homeMilestoneNode3Label, Icons.terrain_outlined),
  _MilestoneNode(90,  l10n.homeMilestoneNode4Label, Icons.park_outlined),
];

// ─── Home Screen ──────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _pledgeController    = TextEditingController();
  final _gratitudeController = TextEditingController();
  bool _pledgeSaving    = false;
  bool _gratitudeSaving = false;

  @override
  void dispose() {
    _pledgeController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  Future<void> _savePledge(UserProfile profile) async {
    final text = _pledgeController.text.trim();
    if (text.isEmpty) return;
    setState(() => _pledgeSaving = true);
    HapticFeedback.lightImpact();
    await ref.read(profileProvider.notifier).patch((p) => p.copyWith(
      lastPledgeText: text,
      lastPledgeDate: _today(),
      pledgeStreak: p.lastPledgeDate == _yesterday()
          ? p.pledgeStreak + 1
          : 1,
    ));
    _pledgeController.clear();
    setState(() => _pledgeSaving = false);
  }

  Future<void> _saveGratitude() async {
    final text = _gratitudeController.text.trim();
    if (text.isEmpty) return;
    setState(() => _gratitudeSaving = true);
    HapticFeedback.lightImpact();
    await ref.read(gratitudeProvider.notifier).add(text);
    _gratitudeController.clear();
    setState(() => _gratitudeSaving = false);
  }

  String _yesterday() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return '${y.year}-${y.month.toString().padLeft(2,'0')}-${y.day.toString().padLeft(2,'0')}';
  }

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.homeGoodMorning;
    if (h < 17) return l10n.homeGoodAfternoon;
    return l10n.homeGoodEvening;
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
        body: Center(child: CircularProgressIndicator(color: AppColors.forest600)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.stone50,
        body: Center(child: Text(l10n.homeErrorPrefix(e.toString()))),
      ),
      data: (profile) {
        if (profile == null) {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => context.go('/onboarding'));
          return const SizedBox.shrink();
        }

        final pledgedToday = profile.lastPledgeDate == _today();
        return Scaffold(
          backgroundColor: AppColors.stone50,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Header ──────────────────────────────────────────
                        _HomeHeader(
                          greeting: _greeting(l10n),
                          username: profile.username,
                          onAvatarTap: () => _showProfileModal(context, profile),
                        ),
                        const SizedBox(height: 24),

                        // ── Serenity Card (hero) ─────────────────────────────
                        _SerenityCard(profile: profile),
                        const SizedBox(height: 14),

                        // ── Money + My Reason ────────────────────────────────
                        if (profile.dailySpend > 0) ...[
                          _MoneyCard(profile: profile),
                          const SizedBox(height: 14),
                        ],

                        // ── Journey milestone nodes ──────────────────────────
                        _JourneyCard(
                          days: stats?.days ?? 0,
                          onTap: () => context.push('/milestone'),
                        ),
                        const SizedBox(height: 14),

                        // ── Daily Pledge + Gratitude (side by side) ──────────
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _PledgeCard(
                                  pledgedToday: pledgedToday,
                                  pledgeText: profile.lastPledgeText,
                                  pledgeStreak: profile.pledgeStreak,
                                  controller: _pledgeController,
                                  saving: _pledgeSaving,
                                  onSave: () => _savePledge(profile),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _GratitudeCard(
                                  todayEntry: todayGratitude,
                                  controller: _gratitudeController,
                                  saving: _gratitudeSaving,
                                  onSave: _saveGratitude,
                                ),
                              ),
                            ],
                          ),
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
                              final n = Set<int>.from(goalToggles);
                              n.contains(i) ? n.remove(i) : n.add(i);
                              ref.read(weeklyGoalTogglesProvider.notifier).state = n;
                              HapticFeedback.selectionClick();
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                        // ── Daily Missions ───────────────────────────────────
                        _DailyMissionsCard(
                          missions: missions,
                          toggles: missionToggles,
                          onToggle: (i) {
                            final n = Set<int>.from(missionToggles);
                            n.contains(i) ? n.remove(i) : n.add(i);
                            ref.read(missionTogglesProvider.notifier).state = n;
                            HapticFeedback.selectionClick();
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Daily Check-In ───────────────────────────────────
                        _CheckInCard(
                          onCraving:  () => _showCravingSheet(context, ref),
                          onThought:  () => _showThoughtSheet(context, ref),
                          onActivity: () => _showActivitySheet(context, ref),
                          onSleep:    () => _showSleepSheet(context, ref),
                        ),
                        const SizedBox(height: 14),

                        // ── Today's Reminder ─────────────────────────────────
                        _TodaysReminderCard(quote: _dailyQuote(l10n)),
                        const SizedBox(height: 14),

                        // ── Recovery Timeline Banner ─────────────────────────
                        _RecoveryBanner(
                          days: stats?.days ?? 0,
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
      builder: (_) => _CravingSheet(ref: ref),
    );
  }

  void _showThoughtSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThoughtSheet(ref: ref),
    );
  }

  void _showActivitySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivitySheet(ref: ref),
    );
  }

  void _showSleepSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SleepSheet(ref: ref),
    );
  }

  void _showProfileModal(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileModal(profile: profile),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.greeting, required this.username, required this.onAvatarTap});

  final String greeting;
  final String username;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateStr = DateFormat('EEEE, d MMMM').format(DateTime.now());
    final name = username.isEmpty ? l10n.homeFriendFallback : username;

    return SizedBox(
      height: 126,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: -12,
            top: -10,
            child: BotanicalBackground(width: 180, height: 118),
          ),
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.stoneText)),
                      const SizedBox(height: 14),
                      Text('Hi, $name \u{1F44B}', style: AppTextStyles.greetingSerif),
                      const SizedBox(height: 8),
                      Text(l10n.homeTagline, style: AppTextStyles.bodyLarge),
                    ],
                  ),
                ),
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
                    child: const Icon(Icons.person_outline_rounded, color: AppColors.forest, size: 27),
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

class _SerenityCard extends ConsumerWidget {
  const _SerenityCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This card is the only widget that needs the per-second live clock.
    final stats = ref.watch(soberStatsProvider);
    final days = stats?.days ?? 0;
    final hours = stats?.hours ?? 0;
    final minutes = stats?.minutes ?? 0;
    final seconds = stats?.seconds ?? 0;

    return LuxuryCard(
      padding: EdgeInsets.zero,
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
                  PlantLogic.getPlantAsset(days),
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
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const IconChip(icon: Icons.no_drinks_outlined, size: 46),
                      const SizedBox(width: 14),
                      Text('DAYS SOBER', style: AppTextStyles.overline.copyWith(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$days', style: AppTextStyles.heroNumber),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Text('days', style: AppTextStyles.displaySmall.copyWith(fontSize: 24)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
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
                          decoration: const BoxDecoration(color: AppColors.leafGreen, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 168,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SoftDivider(),
                        const SizedBox(height: 14),
                        Text(
                          'A clearer mind.\nA stronger you.',
                          style: AppTextStyles.bodyLarge.copyWith(height: 1.35),
                        ),
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
}

// \u2500\u2500\u2500 Money Reclaimed card \u2014 full-width, real-time, with optional savings goal \u2500\u2500

class _MoneyCard extends ConsumerWidget {
  const _MoneyCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(soberStatsProvider);
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
                      const IconChip(icon: Icons.account_balance_wallet_outlined, size: 46),
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
                      style: AppTextStyles.moneyNumber.copyWith(fontSize: 52),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.homeMoneyAllTime,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mistGrey),
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
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.forest),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.homeMoneyGoalSavedOf(formatted, _formatMoney(currency, goal!)),
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.homeMoneyGoalPercent((progressFraction * 100).round()),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.mintChip,
                      borderRadius: AppRadius.lg,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.track_changes_outlined, color: AppColors.forest, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.settingsSavingsGoalLabel,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.forest),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.forest, size: 20),
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
      return NumberFormat.currency(locale: 'en_ZA', symbol: 'R', decimalDigits: 2)
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
    await ref.read(profileProvider.notifier).patchGoal(amount: null, name: null);
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
              hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.mistGrey),
              border: border,
              enabledBorder: border,
              focusedBorder: focusBorder,
              filled: true,
              fillColor: AppColors.stone50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.mistGrey),
              prefixText: '${widget.profile.currency} ',
              prefixStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.forest),
              border: border,
              enabledBorder: border,
              focusedBorder: focusBorder,
              filled: true,
              fillColor: AppColors.stone50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.mistGrey),
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
    final pool = profile.myReasons.isNotEmpty
        ? profile.myReasons
        : profile.weeklyGoals;
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
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.stone400)),
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
            Text(l10n.homeYourJourney, style: AppTextStyles.overline.copyWith(fontSize: 12)),
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
                      color: achieved ? AppColors.leafGreen : AppColors.softBorder,
                    ),
                  );
                }
                final index = i ~/ 2;
                final node = milestones[index];
                final achieved = days >= node.days;
                final current = achieved &&
                    (index == milestones.length - 1 || days < milestones[index + 1].days);
                return _MilestoneNodeWidget(node: node, achieved: achieved, isCurrent: current);
              }),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: milestones.map((node) {
                final timing = switch (node.days) {
                  0 => days == 0 ? '0%' : 'done',
                  1 => '3 days',
                  7 => '7 days',
                  30 => '30 days',
                  _ => '90 days',
                };
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        node.label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: days >= node.days ? AppColors.forest : AppColors.stoneText,
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timing,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: days >= node.days ? AppColors.leafGreen : AppColors.mistGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneNodeWidget extends StatelessWidget {
  const _MilestoneNodeWidget({required this.node, required this.achieved, required this.isCurrent});

  final _MilestoneNode node;
  final bool achieved;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
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
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Icon(node.icon, size: 22, color: achieved ? AppColors.forest : AppColors.mistGrey),
    );
  }
}

class _PledgeCard extends StatelessWidget {
  const _PledgeCard({
    required this.pledgedToday,
    required this.pledgeText,
    required this.pledgeStreak,
    required this.controller,
    required this.saving,
    required this.onSave,
  });

  final bool pledgedToday;
  final String? pledgeText;
  final int pledgeStreak;
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSave;

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
      hintText: 'e.g., Today I choose clarity.',
      savedText: pledgedToday ? pledgeText : null,
      supportingText: pledgedToday && pledgeStreak > 0 ? '$pledgeStreak calm days kept' : null,
    );
  }
}

class _GratitudeCard extends StatelessWidget {
  const _GratitudeCard({
    required this.todayEntry,
    required this.controller,
    required this.saving,
    required this.onSave,
  });

  final String? todayEntry;
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSave;

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
      hintText: 'e.g., I\u2019m grateful for\nanother fresh start.',
      savedText: todayEntry,
      supportingText: todayEntry != null ? 'Logged today' : null,
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
    this.savedText,
    this.supportingText,
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
  final String? savedText;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconChip(icon: chipIcon, color: chipColor, backgroundColor: chipBackground, size: 38),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppTextStyles.overline.copyWith(color: chipColor))),
            ],
          ),
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
                savedText != null
                    ? Text(savedText!, style: AppTextStyles.bodyMedium.copyWith(height: 1.45))
                    : TextField(
                        controller: controller,
                        maxLines: 3,
                        minLines: 3,
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.mistGrey),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                if (supportingText != null) ...[
                  const SizedBox(height: 6),
                  Text(supportingText!, style: AppTextStyles.caption.copyWith(color: chipColor)),
                ],
                if (savedText == null) ...[
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
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
                          textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 15),
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Save'),
                      ),
                    ),
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

class _WeeklyGoalsCard extends StatelessWidget {
  const _WeeklyGoalsCard({
    required this.goals, required this.toggles, required this.onToggle,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: done ? AppColors.forest600 : Colors.white,
                        border: Border.all(
                          color: done
                              ? AppColors.forest600 : AppColors.stone200,
                          width: 1.5,
                        ),
                        borderRadius: AppRadius.sm,
                      ),
                      child: done
                          ? const Icon(Icons.check_rounded,
                              size: 13, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: done
                                  ? AppColors.stone400
                                  : AppColors.stone700,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null)),
                    ),
                  ],
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
    required this.missions, required this.toggles, required this.onToggle,
  });
  final List<String> missions;
  final Set<int> toggles;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final done = toggles.length;
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DAILY MISSIONS', style: AppTextStyles.overline),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: Text('Gentle steps for today.',
                  style: AppTextStyles.bodyMedium)),
              Text('$done / ${missions.length}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.mistGrey)),
            ],
          ),
          const SizedBox(height: 12),
          ...missions.asMap().entries.map((e) {
            final isDone = toggles.contains(e.key);
            return GestureDetector(
              onTap: () => onToggle(e.key),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.mintChip : Colors.white,
                        border: Border.all(
                          color: isDone
                              ? AppColors.leafGreen : AppColors.softBorder,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: isDone
                          ? const Icon(Icons.check_rounded,
                              size: 12, color: AppColors.leafGreen)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: isDone
                                  ? AppColors.stone400
                                  : AppColors.stone700,
                              decoration: null)),
                    ),
                  ],
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
    required this.onCraving, required this.onThought,
    required this.onActivity, required this.onSleep,
  });
  final VoidCallback onCraving, onThought, onActivity, onSleep;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      (Icons.favorite_border_rounded, 'Craving',  AppColors.honey,  onCraving),
      (Icons.psychology_outlined,   'Thought',  AppColors.stone400,  onThought),
      (Icons.directions_run_rounded,'Activity', AppColors.forest400, onActivity),
      (Icons.bedtime_outlined,      'Sleep',    AppColors.stone500,  onSleep),
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
                      HapticFeedback.lightImpact();
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
            child: Text(quote, style: AppTextStyles.bodySerif
                .copyWith(color: AppColors.forest700,
                    fontStyle: FontStyle.italic, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// ─── Recovery Timeline Banner ─────────────────────────────────────────────────

class _RecoveryBanner extends StatelessWidget {
  const _RecoveryBanner({required this.days, required this.onTap});
  final int days;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = days < 1 ? 'See what\'s happening in your body'
        : days < 3 ? 'Your body is already healing'
        : days < 7 ? 'Your brain chemistry is shifting'
        : days < 30 ? 'Your liver is repairing itself'
        : 'Your risk of disease is dropping';

    return GestureDetector(
      onTap: onTap,
      child: LuxuryCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: AppRadius.pill,
              ),
            ),
            const SizedBox(width: 12),
            const IconChip(icon: Icons.timeline_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QUITTING TIMELINE', style: AppTextStyles.overline),
                  const SizedBox(height: 2),
                  Text(label,
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.forestDark)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.mistGrey, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Modal ────────────────────────────────────────────────────────────

class _ProfileModal extends ConsumerStatefulWidget {
  const _ProfileModal({required this.profile});
  final UserProfile profile;

  @override
  ConsumerState<_ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends ConsumerState<_ProfileModal> {
  late final TextEditingController _username;
  late final TextEditingController _spend;
  late String _currency;
  late DateTime _soberDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _username  = TextEditingController(text: widget.profile.username);
    _spend     = TextEditingController(
        text: widget.profile.dailySpend.toStringAsFixed(0));
    _currency  = widget.profile.currency;
    _soberDate = DateTime.tryParse(widget.profile.soberDate) ?? DateTime.now();
  }

  @override
  void dispose() {
    _username.dispose();
    _spend.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(profileProvider.notifier).patch((p) => p.copyWith(
      username:   _username.text.trim(),
      dailySpend: double.tryParse(_spend.text) ?? p.dailySpend,
      currency:   _currency,
      soberDate:  _soberDate.toIso8601String(),
    ));
    setState(() => _saving = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.stone200, borderRadius: AppRadius.pill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profile', style: AppTextStyles.titleLarge),
                const SizedBox(height: 20),
                _Field(label: 'Name', controller: _username,
                    hint: 'Your name'),
                const SizedBox(height: 12),
                // Sober date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _soberDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.forest600),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => _soberDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.stone50,
                      border: Border.all(color: AppColors.stone100),
                      borderRadius: AppRadius.lg,
                    ),
                    child: Row(children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sober since', style: AppTextStyles.caption),
                          Text(DateFormat('d MMMM yyyy').format(_soberDate),
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.stone800)),
                        ],
                      )),
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: AppColors.stone400),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _Field(label: 'Daily spend',
                      controller: _spend, hint: '0',
                      inputType: TextInputType.number)),
                  const SizedBox(width: 10),
                  // Currency selector
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _currency,
                      items: ['R', '\$', '£', '€', 'A\$']
                          .map((c) => DropdownMenuItem(
                              value: c, child: Text(c,
                                  style: AppTextStyles.bodyMedium)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _currency = v ?? _currency),
                      borderRadius: AppRadius.lg,
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.forest600),
                      child: _saving
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
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
    this.accent = AppColors.forest600,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(.12) : AppColors.stone50,
            borderRadius: AppRadius.pill,
            border: Border.all(
              color: selected ? accent.withOpacity(.35) : AppColors.stone100,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: selected ? accent : AppColors.stone600,
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
    this.accent = AppColors.forest600,
  });

  final List<String> options;
  final bool Function(String option) isSelected;
  final ValueChanged<String> onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options
            .map(
              (option) => _ChoiceChip(
                label: option,
                selected: isSelected(option),
                accent: accent,
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

class _CravingSheet extends StatefulWidget {
  const _CravingSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_CravingSheet> createState() => _CravingSheetState();
}

class _CravingSheetState extends State<_CravingSheet> {
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
    HapticFeedback.lightImpact();
    await widget.ref.read(cravingProvider.notifier).add(
          _intensity.round(),
          severity: _severity,
          triggers: _triggers.toList(),
          durationMinutes: _duration.round(),
          notes: _notesCtrl.text,
        );
    if (mounted) Navigator.of(context).pop();
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
                HapticFeedback.selectionClick();
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
                HapticFeedback.selectionClick();
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
                HapticFeedback.selectionClick();
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
                HapticFeedback.selectionClick();
                setState(() => _duration = v);
              },
              activeColor: AppColors.forest600,
              inactiveColor: AppColors.stone100,
            ),
            const SizedBox(height: 12),
            _NotesField(
              controller: _notesCtrl,
              hintText: 'Notes (optional) - e.g., passed a bar on the way home.',
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

class _ThoughtSheet extends StatefulWidget {
  const _ThoughtSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_ThoughtSheet> createState() => _ThoughtSheetState();
}

class _ThoughtSheetState extends State<_ThoughtSheet> {
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
    final text = _thoughtCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    HapticFeedback.lightImpact();
    await widget.ref.read(thoughtProvider.notifier).add(
          text,
          _type,
          strength: _strength,
          triggers: _triggers.toList(),
          durationMinutes: _duration.round(),
          notes: _notesCtrl.text,
        );
    if (mounted) Navigator.of(context).pop();
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
                hintText: 'Write the thought in your own words.',
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
                HapticFeedback.selectionClick();
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
                HapticFeedback.selectionClick();
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
                HapticFeedback.selectionClick();
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
                HapticFeedback.selectionClick();
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

// ?? Activity sheet ???????????????????????????????????????????????????????????

class _ActivitySheet extends StatefulWidget {
  const _ActivitySheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_ActivitySheet> createState() => _ActivitySheetState();
}

class _ActivitySheetState extends State<_ActivitySheet> {
  String _activity = 'walk';
  double _minutes = 30;
  String _effort = 'Gentle';
  String _outcome = 'Calmer';
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  static const _types = [
    ('walk', 'Walk', Icons.directions_walk_rounded),
    ('exercise', 'Exercise', Icons.fitness_center_rounded),
    ('yoga', 'Yoga', Icons.self_improvement_outlined),
    ('other', 'Other', Icons.more_horiz_rounded),
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    HapticFeedback.lightImpact();
    await widget.ref.read(activityProvider.notifier).add(
          _activity,
          _minutes.round(),
          effort: _effort,
          outcome: _outcome,
          notes: _notesCtrl.text,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => _sheetShell(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(
              icon: Icons.directions_walk_rounded,
              title: 'Log activity',
              subtitle:
                  'Movement can shift the nervous system. Capture enough detail to see what truly helps.',
            ),
            const SizedBox(height: 22),
            const _SheetSectionLabel('What did you do?'),
            const SizedBox(height: 10),
            Row(
              children: _types
                  .map(
                    (t) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _activity = t.$1);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activity == t.$1
                                  ? AppColors.forest50
                                  : AppColors.stone50,
                              borderRadius: AppRadius.lg,
                              border: Border.all(
                                color: _activity == t.$1
                                    ? AppColors.forest300
                                    : AppColors.stone100,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  t.$3,
                                  size: 20,
                                  color: _activity == t.$1
                                      ? AppColors.forest600
                                      : AppColors.stone400,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t.$2,
                                  style: AppTextStyles.caption.copyWith(
                                    color: _activity == t.$1
                                        ? AppColors.forest700
                                        : AppColors.stone400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const _SheetSectionLabel('How much effort did it take?'),
            const SizedBox(height: 10),
            _ChoiceWrap(
              options: const ['Gentle', 'Moderate', 'Strong'],
              isSelected: (option) => _effort == option,
              onTap: (option) {
                HapticFeedback.selectionClick();
                setState(() => _effort = option);
              },
            ),
            const SizedBox(height: 18),
            const _SheetSectionLabel('How did you feel after?'),
            const SizedBox(height: 10),
            _ChoiceWrap(
              options: const ['Calmer', 'Clearer', 'Energized', 'Same'],
              isSelected: (option) => _outcome == option,
              onTap: (option) {
                HapticFeedback.selectionClick();
                setState(() => _outcome = option);
              },
            ),
            const SizedBox(height: 18),
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
                HapticFeedback.selectionClick();
                setState(() => _minutes = v);
              },
              activeColor: AppColors.forest600,
              inactiveColor: AppColors.stone100,
            ),
            const SizedBox(height: 12),
            _NotesField(
              controller: _notesCtrl,
              hintText:
                  'Notes (optional) - e.g., walked after dinner and felt steadier.',
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

class _SleepSheet extends StatefulWidget {
  const _SleepSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_SleepSheet> createState() => _SleepSheetState();
}

class _SleepSheetState extends State<_SleepSheet> {
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
    HapticFeedback.lightImpact();
    await widget.ref.read(sleepProvider.notifier).add(
          _hours,
          _quality,
          factors: _factors.toList(),
          notes: _notesCtrl.text,
        );
    if (mounted) Navigator.of(context).pop();
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
                HapticFeedback.selectionClick();
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
                        HapticFeedback.selectionClick();
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
                HapticFeedback.selectionClick();
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

// ??? _Field ??????????????????????????????????????????????????????????????????

class _Field extends StatelessWidget {
  const _Field({
    required this.label, required this.controller, required this.hint,
    this.inputType = TextInputType.text,
  });
  final String label, hint;
  final TextEditingController controller;
  final TextInputType inputType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: inputType,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
          ),
        ),
      ],
    );
  }
}
