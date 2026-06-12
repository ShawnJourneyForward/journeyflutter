import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Frosted-glass surface card — Stillwater Aesthetic System.
///
/// Uses [BackdropFilter] + [ImageFilter.blur] at sigma 24 for the blur,
/// a translucent white background, a 1 px solid white rim, and soft
/// diffuse shadows. No heavy Material elevation is applied.
///
/// Usage:
/// ```dart
/// GlassCard(
///   child: Text('Hello'),
/// )
/// // With custom tint (e.g. honey for gratitude sections):
/// GlassCard(
///   tintColor: AppColors.honey50.withOpacity(0.6),
///   child: Text('Gratitude'),
/// )
/// ```
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.tintColor,
    this.borderRadius = AppRadius.xxl,
    this.padding = const EdgeInsets.all(20),
    this.blurSigma = 24.0,
    this.rimOpacity = 0.65,
    this.shadows = AppShadows.glass,
  });

  final Widget child;

  /// Fill tint layered over the blur. Defaults to 45 % white — adjust
  /// per-surface for coloured variants (honey, forest, blush).
  final Color? tintColor;

  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final double blurSigma;

  /// Opacity of the 1 px white rim border (0 – 1).
  final double rimOpacity;

  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    final fill = tintColor ?? const Color(0x73FFFFFF); // ~45 % white

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: borderRadius,
              border: Border.all(
                color: Colors.white.withOpacity(rimOpacity),
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

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
