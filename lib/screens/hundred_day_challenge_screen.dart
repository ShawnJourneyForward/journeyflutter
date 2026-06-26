import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── 100-Day Sober Challenge ──────────────────────────────────────────────────
//
// A self-directed grid of 100 days. The user taps a day to tick it off, presses
// and holds to drop a custom emoji "sticker" (or clear it), and can share a
// rendered card of their filled-in grid. All progress lives in
// `hundredDayChallengeProvider` (EncryptedStore, additive key). This screen
// only reads/writes that one provider — it never touches the sober streak or any
// other data, so reset is genuinely scoped to the challenge alone.

// Sticker choices offered in the long-press sheet. First is the plain tick so a
// quick "mark done" is always one tap away inside the sheet too.
const List<String> _stickerPalette = [
  '✅', '⭐', '🔥', '💪', '🌱', '🌿', '❤️', '🙏',
  '😌', '🧘', '🏆', '✨', '☀️', '🌈', '💚', '🎉',
];

class HundredDayChallengeScreen extends ConsumerStatefulWidget {
  const HundredDayChallengeScreen({super.key});

  @override
  ConsumerState<HundredDayChallengeScreen> createState() =>
      _HundredDayChallengeScreenState();
}

class _HundredDayChallengeScreenState
    extends ConsumerState<HundredDayChallengeScreen> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  static const _total = HundredDayChallengeNotifier.total;

  // ── Mark / sticker / clear actions ──────────────────────────────────────────

  void _quickTick(int day, bool alreadyDone) {
    if (alreadyDone) {
      _openStickerSheet(day, alreadyDone: true);
    } else {
      H.medium();
      ref.read(hundredDayChallengeProvider.notifier).setSticker(day);
    }
  }

  Future<void> _openStickerSheet(int day, {required bool alreadyDone}) async {
    H.light();
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(hundredDayChallengeProvider.notifier);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.challengeStickerSheetTitle(day),
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.forest700)),
            const SizedBox(height: 2),
            Text(l10n.challengePickSticker, style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final emoji in _stickerPalette)
                  GestureDetector(
                    onTap: () {
                      H.medium();
                      notifier.setSticker(day, emoji: emoji);
                      Navigator.of(sheetCtx).pop();
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.stone50,
                        borderRadius: AppRadius.lg,
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
              ],
            ),
            if (alreadyDone) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    H.light();
                    notifier.clearDay(day);
                    Navigator.of(sheetCtx).pop();
                  },
                  icon: Icon(Icons.backspace_outlined,
                      size: 18, color: AppColors.stone500),
                  label: Text(l10n.challengeClearDay,
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.stone500)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Reset (scoped to the challenge only) ────────────────────────────────────

  Future<void> _confirmReset() async {
    final l10n = AppLocalizations.of(context);
    H.light();
    final yes = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
            const RoundedRectangleBorder(borderRadius: AppRadius.luxury),
        title: Text(l10n.challengeResetTitle, style: AppTextStyles.titleMedium),
        content: Text(l10n.challengeResetBody,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: Text(l10n.challengeResetCancel,
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.forest600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            child: Text(l10n.challengeResetConfirm,
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.blush600)),
          ),
        ],
      ),
    );
    if (yes == true) {
      H.heavy();
      await ref.read(hundredDayChallengeProvider.notifier).reset();
    }
  }

  // ── Share ───────────────────────────────────────────────────────────────────

  Future<void> _share(int completed) async {
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
      final file = File('${Directory.systemTemp.path}/journey_challenge.png');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.challengeShareText(completed),
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
    final challenge =
        ref.watch(hundredDayChallengeProvider).valueOrNull ??
            const ChallengeState();
    final profile = ref.watch(profileProvider).valueOrNull;
    // Sober-day count gives a gentle "you're on day N" anchor + a highlight on
    // the current cell. Day-tick provider, not the per-second one.
    final soberDays = ref.watch(soberDaysProvider)?.days ?? 0;
    final todayDay = (soberDays >= 1 && soberDays <= _total) ? soberDays : null;

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Row(
              children: [
                const LuxuryBackButton(),
                Expanded(
                  child: Text(l10n.challengeTitle,
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.forest700)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Progress summary ─────────────────────────────────────────────
            _SummaryCard(
              completed: challenge.completed,
              total: _total,
              progress: challenge.progress,
              isComplete: challenge.isComplete,
              todayDay: todayDay,
            ),
            const SizedBox(height: 14),

            // ── Hint ─────────────────────────────────────────────────────────
            Text(l10n.challengeHint,
                style: AppTextStyles.caption.copyWith(color: AppColors.stone500)),
            const SizedBox(height: 14),

            // ── Day grid ─────────────────────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
              itemCount: _total,
              itemBuilder: (_, i) {
                final day = i + 1;
                final sticker = challenge.days[day];
                final done = sticker != null;
                // Semantics wraps the gesture detector and carries the actions
                // so a screen-reader double-tap actually fires them.
                return Semantics(
                  button: true,
                  label: done
                      ? l10n.challengeA11yDayDone(day)
                      : l10n.challengeA11yDayTodo(day),
                  onTap: () => _quickTick(day, done),
                  onLongPress: () => _openStickerSheet(day, alreadyDone: done),
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () => _quickTick(day, done),
                    onLongPress: () =>
                        _openStickerSheet(day, alreadyDone: done),
                    child: _DayCell(
                      day: day,
                      sticker: sticker,
                      isToday: day == todayDay,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 26),

            // ── Shareable card ───────────────────────────────────────────────
            Text(l10n.challengeShareSectionLabel, style: AppTextStyles.overline),
            const SizedBox(height: 10),
            RepaintBoundary(
              key: _cardKey,
              child: _ShareCard(
                days: challenge.days,
                completed: challenge.completed,
                total: _total,
                username: profile?.username ?? '',
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sharing ? null : () => _share(challenge.completed),
                icon: _sharing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.share_rounded, size: 18),
                label: Text(l10n.challengeShareButton,
                    style:
                        AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest600,
                  foregroundColor: AppColors.onForest,
                  minimumSize: const Size.fromHeight(50),
                  shape:
                      const RoundedRectangleBorder(borderRadius: AppRadius.lg),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // ── Reset ────────────────────────────────────────────────────────
            Center(
              child: TextButton(
                onPressed: challenge.completed == 0 ? null : _confirmReset,
                child: Text(l10n.challengeReset,
                    style: AppTextStyles.labelMedium.copyWith(
                        color: challenge.completed == 0
                            ? AppColors.stone300
                            : AppColors.stone500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress summary card ────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.completed,
    required this.total,
    required this.progress,
    required this.isComplete,
    required this.todayDay,
  });

  final int completed;
  final int total;
  final double progress;
  final bool isComplete;
  final int? todayDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$completed',
                  style: AppTextStyles.displaySmall
                      .copyWith(fontSize: 40, color: AppColors.forest700)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(l10n.challengeCountLabel(completed, total),
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.stone500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.stone100,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.forest500),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isComplete
                ? l10n.challengeComplete
                : (todayDay != null
                    ? l10n.challengeOnDay(todayDay!)
                    : l10n.challengeSubtitle),
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.forest600, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─── Day cell ─────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.sticker,
    required this.isToday,
  });

  final int day;
  final String? sticker;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final done = sticker != null;
    final Color bg;
    final Color border;
    if (done) {
      bg = AppColors.forest50;
      border = AppColors.forest200;
    } else if (isToday) {
      bg = AppColors.honey50;
      border = AppColors.honey400;
    } else {
      bg = AppColors.card;
      border = AppColors.softBorder;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.sm,
        border: Border.all(
          color: border,
          width: isToday && !done ? 1.6 : 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: done
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(sticker!, style: const TextStyle(fontSize: 16)),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('$day',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    color: isToday ? AppColors.honey600 : AppColors.stone400,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  )),
            ),
    );
  }
}

// ─── Shareable card ───────────────────────────────────────────────────────────
//
// Deep-forest card with the live grid rendered as the hero — completed days show
// their sticker, the rest show as faint cells. Mirrors the milestone share card
// styling (honey rule + brand + footer) for a consistent shared look.
class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.days,
    required this.completed,
    required this.total,
    required this.username,
  });

  final Map<int, String> days;
  final int completed;
  final int total;
  final String username;

  String _displayName(AppLocalizations l10n) {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return l10n.milestoneShareCardFallbackName;
    return trimmed.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.forest900,
        borderRadius: AppRadius.xxl,
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Brand + count ───────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.eco_rounded,
                    size: 13,
                    // ignore: deprecated_member_use
                    color: AppColors.honey300.withValues(alpha: 0.85)),
                const SizedBox(width: 6),
                Text(
                  l10n.challengeShareCardBrand,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.forest200,
                    letterSpacing: 2.4,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '$completed/$total',
                  style: AppTextStyles.headlineSerif.copyWith(
                    color: AppColors.cream,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 0.8,
              // ignore: deprecated_member_use
              color: AppColors.honey400.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),

            // ── Grid ────────────────────────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.0,
              ),
              itemCount: total,
              itemBuilder: (_, i) {
                final sticker = days[i + 1];
                final done = sticker != null;
                return Container(
                  decoration: BoxDecoration(
                    color: done
                        ? AppColors.forest700
                        // ignore: deprecated_member_use
                        : AppColors.forest800.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: AppColors.forest600.withValues(alpha: done ? 0.9 : 0.4),
                      width: 0.6,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: done
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(sticker,
                              style: const TextStyle(fontSize: 13)),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 16),

            // ── Footer ──────────────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.account_circle_outlined,
                    size: 14,
                    // ignore: deprecated_member_use
                    color: AppColors.honey300.withValues(alpha: 0.85)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _displayName(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.honey300, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 14,
                  // ignore: deprecated_member_use
                  color: AppColors.honey400.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 12),
                Text(
                  'journeyforward.app',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.honey300, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
