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

  // Reference count so overlapping callers compose safely: the per-tab Journal
  // toggle, each SecureScreen wrapper, and the app-wide background blank can all
  // request FLAG_SECURE independently. The native flag is set when the count
  // goes 0→1 and cleared only when it returns to 0 — so leaving one secure
  // screen while another is still active (or while backgrounded) never clears
  // protection prematurely.
  static int _refs = 0;

  static Future<void> enable() async {
    _refs++;
    if (_refs != 1) return; // already secured
    await _invoke('enable');
  }

  static Future<void> disable() async {
    if (_refs == 0) return; // nothing to release
    _refs--;
    if (_refs != 0) return; // still held by another caller
    await _invoke('disable');
  }

  static Future<void> _invoke(String method) async {
    if (!defaultTargetPlatform.toString().contains('android')) return;
    try {
      await _channel.invokeMethod(method);
    } catch (e) {
      debugPrint('[SecureWindow] $method failed: $e');
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
