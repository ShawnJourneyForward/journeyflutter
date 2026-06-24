import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import 'glass_card.dart';

// ─── Today's strength card ───────────────────────────────────────────────────
//
// Three rotating slots in priority order:
//   1. A ready-to-open future-self letter (highest emotional value)
//   2. A detected craving pattern ("Cravings cluster Fri 6–8pm")
//   3. The hard-day badge button (always available unless already marked today)
//
// Designed to NEVER show all three at once — the slot with the most
// actionable information for THIS user wins. Surfacing four cards in a row
// is noise.

// Localized day-name + time-window for the craving pattern, formatted off the
// active app locale (Intl.defaultLocale) rather than the old English-only
// getters on CravingPattern (which leaked English into the translated card).
// Jan 2024 starts on a Monday, so DateTime(2024,1,weekday) maps 1→Mon … 7→Sun.
String _localizedWeekday(int weekday) =>
    DateFormat.EEEE(Intl.defaultLocale).format(DateTime(2024, 1, weekday));

String _localizedHourWindow(int startHour) {
  String h(int hr) =>
      DateFormat.j(Intl.defaultLocale).format(DateTime(2024, 1, 1, hr % 24));
  return '${h(startHour)}–${h((startHour + 2) % 24)}';
}

class TodaysStrengthCard extends ConsumerWidget {
  const TodaysStrengthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final letters = ref.watch(futureLetterProvider).valueOrNull ?? const [];
    final hardDays = ref.watch(hardDayProvider).valueOrNull ?? const [];
    final pattern = ref.watch(cravingPatternProvider);
    final now = DateTime.now();

    final markedToday = hardDays.any((h) =>
        h.date.year == now.year &&
        h.date.month == now.month &&
        h.date.day == now.day);
    final markedCount = hardDays.length;

    final unopenedReady =
        letters.where((l) => l.unlockedAt(now) && !l.opened).toList();

    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined,
                  size: 18, color: AppColors.forest600),
              const SizedBox(width: 8),
              Text(l10n.strengthCardTitle,
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.forest700)),
              const Spacer(),
              if (markedCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.honey50,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(l10n.strengthHardDays(markedCount),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.honey600, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (unopenedReady.isNotEmpty)
            _StrengthRow(
              icon: Icons.mark_email_unread_outlined,
              colour: AppColors.honey600,
              bg: AppColors.honey50,
              title: l10n.strengthLetterTitle,
              subtitle: l10n.strengthLetterSub(unopenedReady.first.unlockDay),
              actionLabel: l10n.commonRead,
              onTap: () => context.push('/future-letter'),
            )
          else if (pattern != null)
            _StrengthRow(
              icon: Icons.insights_outlined,
              colour: AppColors.forest700,
              bg: AppColors.forest50,
              title: l10n.strengthPatternTitle(
                  _localizedWeekday(pattern.weekday),
                  _localizedHourWindow(pattern.startHour)),
              subtitle: l10n.strengthPatternSub(
                  pattern.count, pattern.totalCravings),
              actionLabel: l10n.commonPlan,
              onTap: () => context.push('/pre-craving-plan'),
            )
          else
            _StrengthRow(
              icon: markedToday
                  ? Icons.check_circle_outline_rounded
                  : Icons.spa_outlined,
              colour: markedToday ? AppColors.forest600 : AppColors.honey600,
              bg: markedToday ? AppColors.forest50 : AppColors.honey50,
              title: markedToday
                  ? l10n.strengthHardRecorded
                  : l10n.strengthHardAsk,
              subtitle: markedToday
                  ? l10n.strengthHardRecordedSub
                  : l10n.strengthHardAskSub,
              actionLabel: markedToday ? l10n.commonUndo : l10n.strengthMarkIt,
              onTap: () async {
                H.medium();
                if (markedToday) {
                  final todayId = hardDays
                      .firstWhere((h) =>
                          h.date.year == now.year &&
                          h.date.month == now.month &&
                          h.date.day == now.day)
                      .id;
                  await ref.read(hardDayProvider.notifier).remove(todayId);
                } else {
                  await ref.read(hardDayProvider.notifier).mark();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          l10n.strengthHardLogged,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white)),
                      backgroundColor: AppColors.forest600,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                }
              },
            ),
          if (unopenedReady.isEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              borderRadius: AppRadius.md,
              onTap: () {
                H.light();
                context.push('/future-letter');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 16, color: AppColors.stone500),
                    const SizedBox(width: 8),
                    Text(
                      letters.isEmpty
                          ? l10n.strengthWriteFirst
                          : l10n.strengthWriteAnother,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone600),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.stone300, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({
    required this.icon,
    required this.colour,
    required this.bg,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });
  final IconData icon;
  final Color colour;
  final Color bg;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: colour, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.stone800)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.stone500, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: colour,
            side: BorderSide(color: colour.withValues(alpha: 0.35)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            minimumSize: const Size(0, 36),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
            textStyle: AppTextStyles.labelMedium,
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
