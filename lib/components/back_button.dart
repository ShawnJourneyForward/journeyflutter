import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

/// Standard back button used across every screen in the app.
///
/// Single source of truth for back-arrow size, color, hit area, and haptic.
/// Previously each screen rolled its own combination of [IconButton] /
/// [GestureDetector] with icon sizes ranging from 18 to 24 and inconsistent
/// hit targets — some screens used a bare [GestureDetector] with no minimum
/// tap area, which felt unresponsive on touch.
///
/// Defaults:
///   • 22pt icon (Material recommended)
///   • [AppColors.stone700] tint (overridable for dark backgrounds)
///   • 48×48 minimum hit area
///   • Light haptic on tap
///   • Calls [Navigator.pop] unless [onPressed] is overridden
class LuxuryBackButton extends StatelessWidget {
  const LuxuryBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.tooltip,
  });

  /// Override the default pop behaviour. If null, calls
  /// [Navigator.of(context).maybePop()].
  final VoidCallback? onPressed;

  /// Icon tint. Defaults to [AppColors.stone700]; override for darker /
  /// tinted screens.
  final Color? color;

  /// Optional accessibility tooltip.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        H.light();
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.of(context).maybePop();
        }
      },
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      splashRadius: 24,
      tooltip: tooltip ?? 'Back',
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 22,
        color: color ?? AppColors.stone700,
      ),
    );
  }
}
