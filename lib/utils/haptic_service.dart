import 'package:flutter/services.dart';

/// Centralised haptic wrapper.
///
/// Call [H.sync] once whenever the profile loads or changes.
/// Every screen uses [H.light], [H.medium], [H.selection], [H.heavy]
/// instead of calling [HapticFeedback] directly — so the global
/// "haptics enabled" toggle takes effect everywhere automatically.
class H {
  H._();

  static bool _enabled = true;

  /// Sync the enabled state from the user profile. Called in the
  /// root ConsumerWidget whenever profileProvider emits a new value.
  static void sync(bool enabled) => _enabled = enabled;

  /// Selection change — filter chips, toggles, sliders stepping,
  /// picker items, tab switches.
  static void selection() {
    if (_enabled) HapticFeedback.selectionClick();
  }

  /// Light — navigation taps, opening bottom sheets, back button,
  /// dismissing dialogs, card taps.
  static void light() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  /// Medium — saving data, completing a mission, pledge confirmation,
  /// craving logged, thought saved.
  static void medium() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  /// Heavy — destructive confirmations (delete, slip record).
  static void heavy() {
    if (_enabled) HapticFeedback.heavyImpact();
  }
}
