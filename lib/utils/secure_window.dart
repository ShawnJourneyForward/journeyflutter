import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Toggles Android's `WindowManager.LayoutParams.FLAG_SECURE` for the current
/// activity. When FLAG_SECURE is set, Android:
///   • blocks screenshots and screen recording
///   • blocks rendering of the window's contents in the Recents thumbnail
///     (the user sees a blank tile instead of the journal/PIN/slip log)
///   • prevents the contents from appearing in casts to external displays
///
/// Sensitive screens (lock entry, PIN setup, journal, slip log, history,
/// CBT, slip support) should `enable()` in their `initState` and `disable()`
/// in their `dispose`. iOS has no equivalent screenshot-prevention API
/// (Apple doesn't expose one), so this is a no-op on iOS.
class SecureWindow {
  SecureWindow._();

  static const _channel = MethodChannel('com.journeyforward/secure_window');

  static Future<void> enable() async {
    if (!defaultTargetPlatform.toString().contains('android')) return;
    try {
      await _channel.invokeMethod('enable');
    } catch (e) {
      debugPrint('[SecureWindow] enable failed: $e');
    }
  }

  static Future<void> disable() async {
    if (!defaultTargetPlatform.toString().contains('android')) return;
    try {
      await _channel.invokeMethod('disable');
    } catch (e) {
      debugPrint('[SecureWindow] disable failed: $e');
    }
  }
}

/// Convenience wrapper for stateless screens. Drop the screen's body inside
/// this and FLAG_SECURE is automatically enabled while the screen is mounted.
///
/// Example:
/// ```dart
/// class SlipLogScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return SecureScreen(child: Scaffold(...));
///   }
/// }
/// ```
class SecureScreen extends StatefulWidget {
  const SecureScreen({super.key, required this.child});
  final Widget child;

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  @override
  void initState() {
    super.initState();
    SecureWindow.enable();
  }

  @override
  void dispose() {
    SecureWindow.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
