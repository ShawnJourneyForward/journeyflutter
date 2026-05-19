import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Slip Log Screen ──────────────────────────────────────────────────────────

class SlipLogScreen extends ConsumerWidget {
  const SlipLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final slipsAsync = ref.watch(slipProvider);

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.stone700),
                    onPressed: () {
                      H.light();
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.slipLogTitle,
                            style: AppTextStyles.titleLarge
                                .copyWith(color: AppColors.forest700)),
                        Text(l10n.slipLogSubtitle,
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Compassionate note ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LuxuryCard(
                backgroundColor: AppColors.mintChip,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        color: AppColors.forest400, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.slipLogInfoText,
                        style: AppTextStyles.bodySerif.copyWith(
                          color: AppColors.forest700,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Slip list ─────────────────────────────────────────────────
            Expanded(
              child: slipsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.forest600, strokeWidth: 2),
                ),
                error: (e, _) =>
                    Center(child: Text('Error: $e')),
                data: (slips) {
                  if (slips.isEmpty) {
                    return _EmptyState();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    itemCount: slips.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _SlipCard(slip: slips[i]),
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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.forest50,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.forest100),
          ),
          child: const Icon(Icons.timeline_rounded,
              size: 34, color: AppColors.forest400),
        ),
        const SizedBox(height: 18),
        Text(AppLocalizations.of(context).slipLogEmpty,
            style: AppTextStyles.titleSmall
                .copyWith(color: AppColors.stone500)),
        const SizedBox(height: 6),
        Text(AppLocalizations.of(context).slipLogEmptySubtitle,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.stone400)),
      ],
    ),
  );
}

// ─── Slip card ────────────────────────────────────────────────────────────────

class _SlipCard extends StatelessWidget {
  const _SlipCard({required this.slip});
  final Slip slip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel = DateFormat('d MMM yyyy · HH:mm').format(slip.date);

    return SolidCard(
      borderRadius: AppRadius.xl,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header bar
          Container(
            decoration: const BoxDecoration(
              color: AppColors.blush50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.blush400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(dateLabel,
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.stone700)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forest50,
                    borderRadius: AppRadius.pill,
                    border: Border.all(color: AppColors.forest100),
                  ),
                  child: Text(
                    l10n.slipLogStreakBadge(slip.streakDays),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.forest600),
                  ),
                ),
              ],
            ),
          ),

          // Note body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: slip.note != null && slip.note!.isNotEmpty
                ? Text(slip.note!,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.stone600, height: 1.5))
                : Text(l10n.slipLogNoNote,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.stone300)),
          ),
        ],
      ),
    );
  }
}
