import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Slip Support Screen ──────────────────────────────────────────────────────
// This screen is a calm companion for moments of craving or urge.
// It is not a lecture. It does not judge. It just helps get through the moment.

class SlipSupportScreen extends ConsumerStatefulWidget {
  const SlipSupportScreen({super.key});

  @override
  ConsumerState<SlipSupportScreen> createState() => _SlipSupportScreenState();
}

class _SlipSupportScreenState extends ConsumerState<SlipSupportScreen> {
  // HALT check state
  final Set<String> _haltSelected = {};

  // Craving log state
  int _cravingIntensity = 5;
  bool _loggingCraving = false;
  bool _cravingLogged = false;

  Future<void> _logCraving() async {
    setState(() => _loggingCraving = true);
    H.medium();
    await ref.read(cravingProvider.notifier).add(_cravingIntensity);
    setState(() {
      _loggingCraving = false;
      _cravingLogged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final distractions = [
      (Icons.water_drop_outlined,     l10n.slipSupportDistraction0),
      (Icons.directions_walk_rounded, l10n.slipSupportDistraction1),
      (Icons.phone_outlined,          l10n.slipSupportDistraction2),
      (Icons.music_note_outlined,     l10n.slipSupportDistraction3),
      (Icons.edit_outlined,           l10n.slipSupportDistraction4),
    ];
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -6,
              right: -18,
              child: IgnorePointer(
                child: BotanicalBackground(width: 150, height: 92),
              ),
            ),
            Column(
              children: [

                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 14, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: AppColors.forest700),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(l10n.slipSupportTitle,
                            style: AppTextStyles.greetingSerif),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    children: [

                      // ── Compassionate opener ────────────────────────────
                      LuxuryCard(
                        backgroundColor: AppColors.forest800,
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.waves_rounded,
                                color: AppColors.forest300, size: 26),
                            const SizedBox(height: 12),
                            Text(
                              l10n.slipSupportTemporary,
                              style: AppTextStyles.headlineSerif.copyWith(
                                color: Colors.white, fontSize: 20),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.slipSupportCravingWaves,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.forest200, height: 1.55),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── HALT check ──────────────────────────────────────
                      Text(l10n.slipSupportHaltHeader, style: AppTextStyles.overline),
                      const SizedBox(height: 10),
                      Text(
                        l10n.slipSupportHaltQuestion,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.stone600),
                      ),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.6,
                        children: [
                          _HaltCard(
                            label: l10n.slipSupportHaltHungry,
                            icon: Icons.restaurant_outlined,
                            selected: _haltSelected.contains('hungry'),
                            onTap: () => setState(() =>
                                _haltSelected.contains('hungry')
                                    ? _haltSelected.remove('hungry')
                                    : _haltSelected.add('hungry')),
                          ),
                          _HaltCard(
                            label: l10n.slipSupportHaltAngry,
                            icon: Icons.sentiment_very_dissatisfied_outlined,
                            selected: _haltSelected.contains('angry'),
                            onTap: () => setState(() =>
                                _haltSelected.contains('angry')
                                    ? _haltSelected.remove('angry')
                                    : _haltSelected.add('angry')),
                          ),
                          _HaltCard(
                            label: l10n.slipSupportHaltLonely,
                            icon: Icons.person_outline_rounded,
                            selected: _haltSelected.contains('lonely'),
                            onTap: () => setState(() =>
                                _haltSelected.contains('lonely')
                                    ? _haltSelected.remove('lonely')
                                    : _haltSelected.add('lonely')),
                          ),
                          _HaltCard(
                            label: l10n.slipSupportHaltTired,
                            icon: Icons.bedtime_outlined,
                            selected: _haltSelected.contains('tired'),
                            onTap: () => setState(() =>
                                _haltSelected.contains('tired')
                                    ? _haltSelected.remove('tired')
                                    : _haltSelected.add('tired')),
                          ),
                        ],
                      ),
                      if (_haltSelected.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _HaltAdvice(selected: _haltSelected),
                      ],
                      const SizedBox(height: 20),

                      // ── Urge surfing ────────────────────────────────────
                      Text(l10n.slipSupportRideItOutHeader, style: AppTextStyles.overline),
                      const SizedBox(height: 10),
                      SolidCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.slipSupportUrgeSurfingTitle,
                                style: AppTextStyles.titleSmall),
                            const SizedBox(height: 8),
                            Text(
                              l10n.slipSupportUrgeSurfingDesc,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.stone600, height: 1.55),
                            ),
                            const SizedBox(height: 16),
                            const _BreathingPrompt(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Distraction toolkit ─────────────────────────────
                      Text(l10n.slipSupportRightNowHeader, style: AppTextStyles.overline),
                      const SizedBox(height: 10),
                      SolidCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.slipSupportThingsYouCanDo,
                                style: AppTextStyles.titleSmall),
                            const SizedBox(height: 14),
                            for (final item in distractions)
                              _DistractionRow(
                                  icon: item.$1,
                                  text: item.$2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Log craving ─────────────────────────────────────
                      Text(l10n.slipSupportLogHeader, style: AppTextStyles.overline),
                      const SizedBox(height: 10),
                      SolidCard(
                        child: _cravingLogged
                            ? const _CravingLoggedConfirmation()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.slipSupportRateCravingTitle,
                                      style: AppTextStyles.titleSmall),
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.slipSupportRateCravingDesc,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Text(l10n.slipSupportIntensityMild,
                                          style: AppTextStyles.caption),
                                      Expanded(
                                        child: Slider(
                                          value: _cravingIntensity.toDouble(),
                                          min: 1,
                                          max: 10,
                                          divisions: 9,
                                          onChanged: (v) => setState(
                                              () => _cravingIntensity =
                                                  v.round()),
                                        ),
                                      ),
                                      Text(l10n.slipSupportIntensityIntense,
                                          style: AppTextStyles.caption),
                                    ],
                                  ),
                                  Center(
                                    child: Text(
                                      l10n.slipSupportCravingIntensityFormat(_cravingIntensity),
                                      style: AppTextStyles.titleMedium.copyWith(
                                          color: AppColors.forest700),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: _loggingCraving
                                          ? null
                                          : _logCraving,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.forest600,
                                        minimumSize:
                                            const Size.fromHeight(48),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: AppRadius.lg),
                                      ),
                                      child: _loggingCraving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2))
                                          : Text(l10n.slipSupportLogCravingButton,
                                              style: AppTextStyles.labelLarge
                                                  .copyWith(
                                                      color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 20),

                      // ── Crisis support ──────────────────────────────────
                      LuxuryCard(
                        backgroundColor: AppColors.stone100,
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            const Icon(Icons.support_agent_rounded,
                                size: 22, color: AppColors.stone500),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.slipSupportNeedToTalk,
                                      style: AppTextStyles.titleSmall),
                                  const SizedBox(height: 4),
                                  Text(l10n.slipSupportCrisisLinesAvailable,
                                      style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/crisis'),
                              child: Text(l10n.slipSupportViewLinesButton,
                                  style: AppTextStyles.labelLarge
                                      .copyWith(color: AppColors.forest600)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HALT card ────────────────────────────────────────────────────────────────

class _HaltCard extends StatelessWidget {
  const _HaltCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        H.selection();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? AppColors.mintChip : AppColors.card,
          borderRadius: AppRadius.xl,
          border: Border.all(
            color: selected ? AppColors.forest400 : AppColors.stone100,
            width: selected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: selected
                    ? AppColors.forest600
                    : AppColors.stone400),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: selected
                    ? AppColors.forest700
                    : AppColors.stone600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HALT advice ─────────────────────────────────────────────────────────────

class _HaltAdvice extends StatelessWidget {
  const _HaltAdvice({required this.selected});
  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final advice = {
      'hungry': (l10n.slipSupportHaltAdviceHungry, Icons.restaurant_outlined),
      'angry':  (l10n.slipSupportHaltAdviceAngry,  Icons.directions_walk_outlined),
      'lonely': (l10n.slipSupportHaltAdviceLonely, Icons.chat_bubble_outline_rounded),
      'tired':  (l10n.slipSupportHaltAdviceTired,  Icons.bedtime_outlined),
    };
    return Column(
      children: selected.map((key) {
        final (text, icon) = advice[key]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: LuxuryCard(
            backgroundColor: AppColors.mintChip,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.forest600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(text,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.forest700)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Breathing prompt ─────────────────────────────────────────────────────────

class _BreathingPrompt extends StatelessWidget {
  const _BreathingPrompt();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mintChip,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.forest100),
      ),
      child: Row(
        children: [
          const Icon(Icons.air_outlined,
              size: 20, color: AppColors.forest600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.slipSupportBoxBreathingTitle,
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.forest700)),
                const SizedBox(height: 4),
                Text(
                  l10n.slipSupportBoxBreathingInstructions,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.forest600, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Distraction row ──────────────────────────────────────────────────────────

class _DistractionRow extends StatelessWidget {
  const _DistractionRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.mintChip,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.forest600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone700)),
          ),
        ],
      ),
    );
  }
}

// ─── Craving logged confirmation ──────────────────────────────────────────────

class _CravingLoggedConfirmation extends StatelessWidget {
  const _CravingLoggedConfirmation();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const Icon(Icons.check_circle_rounded,
            color: AppColors.forest600, size: 36),
        const SizedBox(height: 10),
        Text(l10n.slipSupportCravingLoggedTitle,
            style: AppTextStyles.titleSmall
                .copyWith(color: AppColors.forest700)),
        const SizedBox(height: 6),
        Text(
          l10n.slipSupportCravingLoggedMessage,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.stone600),
        ),
      ],
    );
  }
}
