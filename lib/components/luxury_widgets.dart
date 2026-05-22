import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LuxuryCard extends StatelessWidget {
  const LuxuryCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = AppColors.card,
    this.borderColor = AppColors.softBorder,
    this.clip = false,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  // Only enable when a child overflows the card bounds (e.g. full-bleed images).
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final inner = Padding(padding: padding, child: child);
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.luxury,
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.luxury,
      ),
      child: clip
          ? ClipRRect(borderRadius: AppRadius.luxury, child: inner)
          : inner,
    );
  }
}

// ─── Botanical corner decoration ─────────────────────────────────────────────
// A real watercolor leaf asset rendered at low opacity with a shader mask that
// fades the edges into the screen background — no rectangle border, no harsh
// crop. Same visual language as the home hero card backdrop, applied to every
// screen via this widget so the corner reads as part of the page texture
// rather than a pasted-in shape.
class BotanicalBackground extends StatelessWidget {
  const BotanicalBackground({super.key, this.width = 180, this.height = 110});

  final double width;
  final double height;

  // Reuses an existing growth_stages WebP — no new asset to bundle. Stage 30
  // has a balanced multi-leaf composition that reads well at small sizes.
  static const _asset = 'assets/images/growth_stages/stage_30.webp';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Opacity(
        opacity: 0.28,
        child: ShaderMask(
          shaderCallback: (rect) => const RadialGradient(
            center: Alignment(0.4, -0.2),
            radius: 0.95,
            colors: [
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.45, 1.0],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: Image.asset(
            _asset,
            fit: BoxFit.cover,
            alignment: Alignment.topRight,
          ),
        ),
      ),
    );
  }
}

class IconChip extends StatelessWidget {
  const IconChip({
    super.key,
    required this.icon,
    this.color = AppColors.forest,
    this.backgroundColor = AppColors.mintChip,
    this.size = 42,
  });
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration:
            BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size * 0.46),
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(
      {super.key, required this.title, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: AppTextStyles.overline),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTextStyles.bodyMedium),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
}

class SoftDivider extends StatelessWidget {
  const SoftDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Divider(color: AppColors.softBorder, height: 1);
}

class SoftInput extends StatelessWidget {
  const SoftInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.tint = AppColors.mintChip,
  });
  final TextEditingController controller;
  final String hintText;
  final Color tint;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: 3,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stoneText),
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: tint.withOpacity(0.55),
        ),
      );
}

class StatNumber extends StatelessWidget {
  const StatNumber({super.key, required this.value, this.suffix});
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(value, style: AppTextStyles.displayLarge),
          if (suffix != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(suffix!, style: AppTextStyles.bodyMedium),
            ),
          ],
        ],
      );
}
