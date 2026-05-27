// Vision Board — detail view.
//
// Opens when the user taps a vision card. Shows the full picture: photo hero,
// affirmation, milestone progress, "why it matters" prose, target-date
// countdown, and the actions (edit, mark achieved, pin, delete). Milestone
// toggling is inline; everything else routes back through the existing edit
// sheet so persistence stays in one place.

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import 'vision_board_shared.dart';

class VisionDetailScreen extends ConsumerWidget {
  const VisionDetailScreen({
    super.key,
    required this.itemId,
    required this.onEdit,
  });

  /// We watch the provider for the live item rather than holding it directly,
  /// so milestone toggles + edits flow back automatically.
  final String itemId;

  /// Edit handler is injected from the journal screen so it can reuse the
  /// existing bottom sheet rather than the detail screen owning it.
  final void Function(VisionItem item) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(visionBoardProvider).valueOrNull ?? const [];
    final item = items.firstWhere(
      (e) => e.id == itemId,
      // If the item was just deleted (e.g. from the edit sheet) bail out.
      orElse: () =>
          const VisionItem(id: '', title: '', description: '', emoji: 'guide'),
    );
    if (item.id.isEmpty) {
      // Pop on next frame — we can't pop synchronously inside build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(backgroundColor: AppColors.stone50);
    }

    final accent = visionAccent(item);
    final opt = visionOptionFor(item.emoji);
    final hasPhoto =
        item.imagePaths.isNotEmpty && File(item.imagePaths.first).existsSync();

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: CustomScrollView(
        slivers: [
          _DetailAppBar(
            item: item,
            accent: accent,
            opt: opt,
            hasPhoto: hasPhoto,
            onEdit: () => onEdit(item),
            onTogglePin: () async {
              H.medium();
              await ref
                  .read(visionBoardProvider.notifier)
                  .togglePinned(item.id);
              // Pinned cap feedback — if still unpinned after toggling, the
              // cap was hit. Show a quick snack.
              final after = ref
                      .read(visionBoardProvider)
                      .valueOrNull
                      ?.firstWhere((e) => e.id == item.id) ??
                  item;
              if (!context.mounted) return;
              if (!after.pinned && !item.pinned) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: const Text(
                      'You can pin up to 3 dreams — unpin one to make room.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.forest700,
                ));
              }
            },
            onToggleAchieved: () async {
              H.heavy();
              await ref
                  .read(visionBoardProvider.notifier)
                  .toggleAchieved(item.id);
              if (!context.mounted) return;
              final after = ref
                      .read(visionBoardProvider)
                      .valueOrNull
                      ?.firstWhere((e) => e.id == item.id) ??
                  item;
              if (after.achieved) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: const Text('Marked achieved. Beautiful.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.forest700,
                ));
              }
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.achieved) _AchievedBanner(date: item.achievedDate),
                  _CategoryAndDate(item: item, accent: accent),
                  const SizedBox(height: 18),
                  if (item.affirmation.isNotEmpty)
                    _AffirmationCard(text: item.affirmation, accent: accent),
                  if (item.milestones.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _MilestoneCard(
                      item: item,
                      accent: accent,
                      onToggle: (m) async {
                        H.selection();
                        await ref
                            .read(visionBoardProvider.notifier)
                            .toggleMilestone(item.id, m.id);
                      },
                    ),
                  ],
                  if (item.whyItMatters.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _WhyItMattersCard(text: item.whyItMatters),
                  ],
                  if (item.description.isNotEmpty &&
                      item.description != item.whyItMatters) ...[
                    const SizedBox(height: 18),
                    _DescriptionCard(text: item.description),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App bar with photo/icon hero ────────────────────────────────────────────

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({
    required this.item,
    required this.accent,
    required this.opt,
    required this.hasPhoto,
    required this.onEdit,
    required this.onTogglePin,
    required this.onToggleAchieved,
  });

  final VisionItem item;
  final Color accent;
  final VisionIconOption opt;
  final bool hasPhoto;
  final VoidCallback onEdit;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleAchieved;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.stone800,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      actions: [
        IconButton(
          tooltip: item.pinned ? 'Unpin' : 'Pin to home',
          icon: Icon(
            item.pinned ? Icons.push_pin : Icons.push_pin_outlined,
            color: item.pinned ? accent : AppColors.stone600,
          ),
          onPressed: onTogglePin,
        ),
        IconButton(
          tooltip: item.achieved ? 'Move back to active' : 'Mark achieved',
          icon: Icon(
            item.achieved
                ? Icons.check_circle
                : Icons.check_circle_outline_rounded,
            color: item.achieved ? AppColors.forest600 : AppColors.stone600,
          ),
          onPressed: onToggleAchieved,
        ),
        IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        title: LayoutBuilder(builder: (context, c) {
          // Hide the title while expanded (the hero handles it) and reveal
          // when collapsed for context.
          final collapsed = c.maxHeight < 80;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: collapsed ? 1 : 0,
            child: Text(
              item.title,
              style:
                  AppTextStyles.titleMedium.copyWith(color: AppColors.stone800),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
        titlePadding: const EdgeInsets.only(left: 60, bottom: 14, right: 60),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background — photo or accented gradient.
            if (hasPhoto)
              Image.file(File(item.imagePaths.first), fit: BoxFit.cover)
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      // ignore: deprecated_member_use
                      accent.withOpacity(0.18),
                      AppColors.mintChip,
                    ],
                  ),
                ),
              ),
            // Bottom scrim so the title is readable on any photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x99000000)],
                ),
              ),
            ),
            // Hero icon + title overlay.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: hasPhoto
                          ? Colors.white.withOpacity(0.92)
                          : accent.withOpacity(0.14),
                      shape: BoxShape.circle,
                      boxShadow: hasPhoto ? AppShadows.luxury : null,
                    ),
                    child: Icon(opt.icon, size: 28, color: accent),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: AppTextStyles.headlineSerif.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: hasPhoto ? Colors.white : AppColors.forest700,
                      shadows: hasPhoto
                          ? const [
                              Shadow(
                                  color: Color(0x66000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 1)),
                            ]
                          : null,
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

// ─── Achieved banner ─────────────────────────────────────────────────────────

class _AchievedBanner extends StatelessWidget {
  const _AchievedBanner({required this.date});
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.forest500.withOpacity(0.10),
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.forest200),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppColors.forest600, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              date == null
                  ? 'You achieved this. Beautiful.'
                  : 'Achieved on ${DateFormat.yMMMMd().format(date!)}',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.forest700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category chip + target-date countdown ───────────────────────────────────

class _CategoryAndDate extends StatelessWidget {
  const _CategoryAndDate({required this.item, required this.accent});
  final VisionItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final cat = categoryInfoFor(item.category);
    final daysLeft = item.targetDate == null
        ? null
        : item.targetDate!.difference(DateTime.now()).inDays;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (item.category != VisionCategory.none)
          _Chip(
            icon: cat.icon,
            label: cat.label,
            color: cat.color,
          ),
        if (daysLeft != null)
          _Chip(
            icon: Icons.event_rounded,
            label: daysLeft < 0
                ? '${-daysLeft}d past target'
                : daysLeft == 0
                    ? 'Today'
                    : '$daysLeft days to go',
            color: daysLeft < 0 ? AppColors.blush600 : accent,
          ),
        if (item.pinned)
          const _Chip(
            icon: Icons.push_pin,
            label: 'Pinned',
            color: AppColors.honey500,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.10),
        borderRadius: AppRadius.sm,
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.labelMedium
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Affirmation card ────────────────────────────────────────────────────────

class _AffirmationCard extends StatelessWidget {
  const _AffirmationCard({required this.text, required this.accent});
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.softBorder),
        boxShadow: AppShadows.luxury,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, size: 18, color: accent),
              const SizedBox(width: 6),
              Text('Affirmation',
                  style: AppTextStyles.overline.copyWith(color: accent)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.stone800,
              fontStyle: FontStyle.italic,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Milestone card with progress ring ───────────────────────────────────────

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.item,
    required this.accent,
    required this.onToggle,
  });
  final VisionItem item;
  final Color accent;
  final void Function(VisionMilestone) onToggle;

  @override
  Widget build(BuildContext context) {
    final done = item.milestones.where((m) => m.done).length;
    final total = item.milestones.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.softBorder),
        boxShadow: AppShadows.luxury,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(44, 44),
                      painter: _RingPainter(
                        progress: item.progress,
                        accent: accent,
                      ),
                    ),
                    Text(
                      '${(item.progress * 100).round()}%',
                      style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.forest700,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Milestones',
                        style: AppTextStyles.titleSmall
                            .copyWith(color: AppColors.forest700)),
                    Text('$done of $total complete',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...item.milestones.map((m) => _MilestoneRow(
                milestone: m,
                accent: accent,
                onToggle: () => onToggle(m),
              )),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.milestone,
    required this.accent,
    required this.onToggle,
  });
  final VisionMilestone milestone;
  final Color accent;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: AppRadius.md,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: milestone.done ? accent : Colors.transparent,
                border: Border.all(
                  color: milestone.done ? accent : AppColors.stone300,
                  width: 1.6,
                ),
              ),
              child: milestone.done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                milestone.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      milestone.done ? AppColors.stone400 : AppColors.stone800,
                  decoration: milestone.done
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  // ignore: deprecated_member_use
                  decorationColor: AppColors.stone400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.accent});
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 4.5;
    final radius = (size.shortestSide - stroke) / 2;
    final center = size.center(Offset.zero);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      // ignore: deprecated_member_use
      ..color = accent.withOpacity(0.18);
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = accent;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.accent != accent;
}

// ─── Why it matters + description ────────────────────────────────────────────

class _WhyItMattersCard extends StatelessWidget {
  const _WhyItMattersCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return _ProseCard(
      icon: Icons.psychology_outlined,
      heading: 'Why this matters',
      text: text,
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return _ProseCard(
      icon: Icons.notes_rounded,
      heading: 'Notes',
      text: text,
    );
  }
}

class _ProseCard extends StatelessWidget {
  const _ProseCard({
    required this.icon,
    required this.heading,
    required this.text,
  });
  final IconData icon;
  final String heading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.softBorder),
        boxShadow: AppShadows.luxury,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.forest500),
              const SizedBox(width: 6),
              Text(heading,
                  style: AppTextStyles.overline
                      .copyWith(color: AppColors.forest500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.stone700, height: 1.5),
          ),
        ],
      ),
    );
  }
}
