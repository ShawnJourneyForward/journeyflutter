import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Note: the frosted `GlassCard` was removed as dead code (the Stillwater system
// settled on the solid cards below). This file's public surface is now
// [SolidCard] / [ForestCard] / [HoneyCard] / [BlushCard].

/// Solid white card — for surfaces where blur is unnecessary or
/// the background is already plain cream (stone-50).
///
/// Matches the Stillwater "clean card" language: white fill,
/// stone-100 border, soft two-layer shadow.
class SolidCard extends StatelessWidget {
  const SolidCard({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.luxury,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
    this.shadows = AppShadows.luxury,
  });

  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: borderRadius,
        border:
            Border.all(color: borderColor ?? AppColors.softBorder, width: 1.0),
        boxShadow: shadows,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Forest-tinted surface — used for the "lifetime sober days" banner
/// and other emphasis blocks. Maps to forest-50 / forest-100 in the palette.
class ForestCard extends StatelessWidget {
  const ForestCard({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.luxury,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.mintChip,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.forest100, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Honey-tinted surface — Daily Gratitude, savings goals, warm accents.
class HoneyCard extends StatelessWidget {
  const HoneyCard({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.luxury,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.honeySoft,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.honey100, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Blush-tinted surface — slip indicators, delete confirmations, danger zones.
class BlushCard extends StatelessWidget {
  const BlushCard({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.xxl,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.blush50,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.blush100, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
