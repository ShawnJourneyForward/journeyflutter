import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/craving_insights.dart';
import '../utils/haptic_service.dart';

// ─── "What I've Learned" — personal safety plan ───────────────────────────────
//
// A plain-language relapse-prevention plan synthesised entirely from the
// user's OWN on-device logs (cravings, urge rides, their reasons + pre-craving
// plan). No charts — this is the narrative artefact a person can read back to
// themselves (or hand to a sponsor / therapist) the way a Marlatt-style plan
// is meant to be used. Read-only over existing data: it writes nothing and
// adds no storage keys.

class LearnedScreen extends ConsumerWidget {
  const LearnedScreen({super.key});

  /// At least one section has something to show. Below this we render the
  /// gentle empty state instead of a page of blank cards.
  bool _hasContent({
    required List<ResponseStat> worked,
    required RiskWindow? risk,
    required Map<String, int> halts,
    required List<TriggerStat> triggers,
    required int urgeWins,
    required OutcomeTally tally,
    required List<String> reasons,
    required List<String> plan,
  }) {
    return worked.isNotEmpty ||
        risk != null ||
        halts.isNotEmpty ||
        triggers.isNotEmpty ||
        urgeWins > 0 ||
        tally.stayedSober > 0 ||
        reasons.isNotEmpty ||
        plan.any((s) => s.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cravings = ref.watch(cravingProvider).valueOrNull ?? const [];
    final urgeWins = ref.watch(urgeRideProvider).valueOrNull?.length ?? 0;
    final profile = ref.watch(profileProvider).valueOrNull;

    // Compose the on-device aggregations (all pure functions).
    final worked =
        bestResponses(cravings).where((r) => r.soberOutcomes > 0).toList();
    final risk = topRiskWindow(cravings);
    final halts = haltPrevalence(cravings);
    final triggers = topTriggers(cravings);
    final tally = outcomeTally(cravings);
    final reasons = profile?.myReasons ?? const <String>[];
    final plan = (profile?.preCravingPlan ?? const <String>[])
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final hasContent = _hasContent(
      worked: worked,
      risk: risk,
      halts: halts,
      triggers: triggers,
      urgeWins: urgeWins,
      tally: tally,
      reasons: reasons,
      plan: plan,
    );

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  const LuxuryBackButton(),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(l10n.learnedTitle,
                        style: AppTextStyles.greetingSerif),
                  ),
                  if (hasContent)
                    IconButton(
                      tooltip: l10n.learnedShareButton,
                      onPressed: () => _share(context, l10n,
                          worked: worked,
                          risk: risk,
                          halts: halts,
                          triggers: triggers,
                          urgeWins: urgeWins,
                          tally: tally,
                          reasons: reasons,
                          plan: plan),
                      icon: Icon(Icons.ios_share_rounded,
                          size: 20, color: AppColors.forest600),
                    ),
                ],
              ),
            ),
            Expanded(
              child: hasContent
                  ? _Body(
                      worked: worked,
                      risk: risk,
                      halts: halts,
                      triggers: triggers,
                      urgeWins: urgeWins,
                      tally: tally,
                      reasons: reasons,
                      plan: plan,
                    )
                  : const _EmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Plain-text share composition ──────────────────────────────────────────
  void _share(
    BuildContext context,
    AppLocalizations l10n, {
    required List<ResponseStat> worked,
    required RiskWindow? risk,
    required Map<String, int> halts,
    required List<TriggerStat> triggers,
    required int urgeWins,
    required OutcomeTally tally,
    required List<String> reasons,
    required List<String> plan,
  }) {
    H.light();
    final b = StringBuffer();
    b.writeln(l10n.learnedShareHeading);
    b.writeln();

    if (worked.isNotEmpty) {
      b.writeln(l10n.learnedWorkedHeader);
      for (final r in worked.take(3)) {
        b.writeln('• ${r.localizedLabel(l10n)} — '
            '${l10n.learnedWorkedStat(r.soberOutcomes, r.totalUses)}');
      }
      b.writeln();
    }
    if (risk != null) {
      b.writeln(l10n.learnedRiskHeader);
      b.writeln('• ${risk.localizedLabel(l10n)}');
      b.writeln();
    }
    if (triggers.isNotEmpty) {
      b.writeln(l10n.learnedTriggersHeader);
      for (final t in triggers.take(3)) {
        b.writeln('• ${t.label}');
      }
      b.writeln();
    }
    if (plan.isNotEmpty) {
      b.writeln(l10n.learnedPlanHeader);
      for (final step in plan) {
        b.writeln('• $step');
      }
      b.writeln();
    }
    if (reasons.isNotEmpty) {
      b.writeln(l10n.learnedReasonsHeader);
      for (final r in reasons) {
        b.writeln('• $r');
      }
      b.writeln();
    }
    b.writeln(l10n.learnedFooter);

    Share.share(b.toString(), subject: l10n.learnedShareHeading);
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.forest50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.forest100),
              ),
              child: Icon(Icons.eco_outlined,
                  size: 36, color: AppColors.forest400),
            ),
            const SizedBox(height: 20),
            Text(l10n.learnedEmptyTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSerif),
            const SizedBox(height: 10),
            Text(
              l10n.learnedEmptyBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.stone500, height: 1.55),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () {
                H.light();
                context.push('/slip');
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest600,
                foregroundColor: AppColors.onForest,
              ),
              icon: const Icon(Icons.favorite_outline_rounded, size: 18),
              label: Text(l10n.learnedEmptyCta),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.worked,
    required this.risk,
    required this.halts,
    required this.triggers,
    required this.urgeWins,
    required this.tally,
    required this.reasons,
    required this.plan,
  });

  final List<ResponseStat> worked;
  final RiskWindow? risk;
  final Map<String, int> halts;
  final List<TriggerStat> triggers;
  final int urgeWins;
  final OutcomeTally tally;
  final List<String> reasons;
  final List<String> plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Local copy so the `risk != null` check promotes it — a public field on
    // the widget can't be promoted through a null-check on its own.
    final risk = this.risk;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        Text(
          l10n.learnedSubtitle,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.stone500, height: 1.45),
        ),
        const SizedBox(height: 18),

        // ── What's worked ───────────────────────────────────────────────────
        if (worked.isNotEmpty) ...[
          _SectionLabel(l10n.learnedWorkedHeader),
          const SizedBox(height: 10),
          SolidCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.learnedWorkedIntro,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.stone600, height: 1.5)),
                const SizedBox(height: 14),
                for (final r in worked.take(3))
                  _StatRow(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.forest600,
                    label: r.localizedLabel(l10n),
                    trailing:
                        l10n.learnedWorkedStat(r.soberOutcomes, r.totalUses),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Tender hours ────────────────────────────────────────────────────
        if (risk != null) ...[
          _SectionLabel(l10n.learnedRiskHeader),
          const SizedBox(height: 10),
          SolidCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.honey50,
                    borderRadius: AppRadius.sm,
                  ),
                  child: Icon(Icons.nights_stay_outlined,
                      size: 20, color: AppColors.honey600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.learnedRiskBody(
                        risk.count, risk.total, risk.localizedLabel(l10n)),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.stone700, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── What's underneath (HALT) ────────────────────────────────────────
        if (halts.isNotEmpty) ...[
          _SectionLabel(l10n.learnedHaltHeader),
          const SizedBox(height: 10),
          SolidCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.learnedHaltBody,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.stone600, height: 1.5)),
                const SizedBox(height: 12),
                for (final e in halts.entries.take(4))
                  _StatRow(
                    icon: Icons.spa_outlined,
                    iconColor: AppColors.forest500,
                    label: localizedHaltLabel(l10n, e.key),
                    trailing: l10n.learnedTimesCount(e.value),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Common triggers ─────────────────────────────────────────────────
        if (triggers.isNotEmpty) ...[
          _SectionLabel(l10n.learnedTriggersHeader),
          const SizedBox(height: 10),
          SolidCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.learnedTriggersIntro,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.stone600, height: 1.5)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in triggers.take(8))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.stone50,
                          borderRadius: AppRadius.pill,
                          border: Border.all(color: AppColors.stone100),
                        ),
                        child: Text(
                          t.count > 1
                              ? l10n.learnedTriggerChip(t.label, t.count)
                              : t.label,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.stone700),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Wins ────────────────────────────────────────────────────────────
        if (urgeWins > 0 || tally.stayedSober > 0) ...[
          _SectionLabel(l10n.learnedWinsHeader),
          const SizedBox(height: 10),
          SolidCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (urgeWins > 0)
                  _StatRow(
                    icon: Icons.waves_rounded,
                    iconColor: AppColors.forest600,
                    label: l10n.learnedWinsRidden(urgeWins),
                  ),
                if (tally.stayedSober > 0)
                  _StatRow(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.forest600,
                    label: l10n.learnedWinsSober(tally.stayedSober),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── My plan ─────────────────────────────────────────────────────────
        _SectionLabel(l10n.learnedPlanHeader),
        const SizedBox(height: 10),
        SolidCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (plan.isEmpty)
                Text(l10n.learnedPlanEmpty,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.stone500, height: 1.5))
              else
                for (var i = 0; i < plan.length; i++)
                  Padding(
                    padding:
                        EdgeInsets.only(bottom: i == plan.length - 1 ? 0 : 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.forest50,
                            shape: BoxShape.circle,
                          ),
                          child: Text('${i + 1}',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.forest700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(plan[i],
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.stone700, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    H.light();
                    context.push('/pre-craving-plan');
                  },
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      foregroundColor: AppColors.forest600),
                  icon: Icon(plan.isEmpty
                      ? Icons.add_rounded
                      : Icons.edit_outlined),
                  label: Text(plan.isEmpty
                      ? l10n.learnedPlanCreate
                      : l10n.learnedPlanEdit),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Reasons ─────────────────────────────────────────────────────────
        if (reasons.isNotEmpty) ...[
          _SectionLabel(l10n.learnedReasonsHeader),
          const SizedBox(height: 10),
          SolidCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < reasons.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: i == reasons.length - 1 ? 0 : 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.favorite_outline_rounded,
                            size: 16, color: AppColors.blush400),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(reasons[i],
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.stone700, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Footer ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.mintChip,
            borderRadius: AppRadius.lg,
            border: Border.all(color: AppColors.softBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded,
                  size: 18, color: AppColors.forest400),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.learnedFooter,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.forest700,
                        height: 1.55,
                        fontStyle: FontStyle.italic)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared bits ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.overline);
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.trailing,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone700)),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(trailing!,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.forest600)),
          ],
        ],
      ),
    );
  }
}
