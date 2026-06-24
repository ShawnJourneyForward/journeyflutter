import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import '../utils/notification_service.dart';
import '../utils/pin_hash.dart';
import '../utils/plant_logic.dart';
import '../components/back_button.dart';
import '../l10n/app_localizations.dart';

// ─── Step enum ────────────────────────────────────────────────────────────────

enum _Step { welcome, name, date, spend, security, pin, notifications, finish }

// ─── Onboarding Screen ────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // ── Form state ──────────────────────────────────────────────────────────────
  String _username = '';
  DateTime _soberDate = DateTime.now();
  double _dailySpend = 0;
  String _currency = '\$';
  String _lockMethod = 'none'; // 'none' | 'biometric' | 'pin'

  // PIN entry
  String _pin = '';
  String _pinConfirm = '';
  bool _pinConfirming = false;
  String? _pinError;

  // Notifications
  bool _notifMotivation = true;
  bool _notifReminders = true;
  bool _notifMilestones = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);

  // ── Navigation state ────────────────────────────────────────────────────────
  _Step _step = _Step.welcome;
  bool _goingForward = true;
  bool _saving = false;

  List<_Step> get _steps {
    final all = [
      _Step.welcome,
      _Step.name,
      _Step.date,
      _Step.spend,
      _Step.security,
      if (_lockMethod == 'pin') _Step.pin,
      _Step.notifications,
      _Step.finish,
    ];
    return all;
  }

  int get _currentIndex => _steps.indexOf(_step);
  bool get _isFirst => _currentIndex == 0;
  bool get _isLast => _currentIndex == _steps.length - 1;

  @override
  void initState() {
    super.initState();
  }

  void _navigateTo(_Step next, {bool forward = true}) {
    setState(() {
      _goingForward = forward;
      _step = next;
      // Entering the PIN step always starts a clean create→confirm cycle. Without
      // this, navigating BACK onto the step can re-show the confirm screen
      // pre-filled and let the user finish, skipping re-confirmation.
      if (next == _Step.pin) {
        _pinConfirming = false;
        _pin = '';
        _pinConfirm = '';
        _pinError = null;
      }
    });
  }

  void _next() {
    final idx = _currentIndex;
    if (idx >= _steps.length - 1) return;

    // Validate current step before advancing
    final l10n = AppLocalizations.of(context);
    if (_step == _Step.name && _username.trim().isEmpty) {
      _showError(l10n.onbNameError);
      return;
    }
    if (_step == _Step.pin) {
      if (!_pinConfirming) {
        if (_pin.length < 4) {
          _showError(l10n.onbPinDigitsError);
          return;
        }
        setState(() {
          _pinConfirming = true;
          _pinConfirm = '';
          _pinError = null;
        });
        return;
      } else {
        if (_pinConfirm != _pin) {
          setState(() {
            _pinError = l10n.onbPinMismatchError;
            _pinConfirming = false;
            _pin = '';
            _pinConfirm = '';
          });
          H.heavy();
          return;
        }
      }
    }

    _navigateTo(_steps[idx + 1], forward: true);
  }

  void _back() {
    final idx = _currentIndex;
    if (idx == 0) return;
    _navigateTo(_steps[idx - 1], forward: false);
  }

  void _onPinDigit(String digit) {
    H.selection();
    setState(() {
      if (_pinConfirming) {
        if (_pinConfirm.length < 4) _pinConfirm += digit;
      } else {
        if (_pin.length < 4) _pin += digit;
      }
    });
  }

  void _onPinDelete() {
    H.selection();
    setState(() {
      if (_pinConfirming) {
        if (_pinConfirm.isNotEmpty)
          _pinConfirm = _pinConfirm.substring(0, _pinConfirm.length - 1);
      } else {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  // ── Security selection ──────────────────────────────────────────────────────
  // Tapping "biometric" runs an actual authenticate() prompt right then so
  // we don't quietly save lockMethod='biometric' on a device with no
  // fingerprint/face enrolled (the previous bug — users would pick it,
  // finish onboarding, and find the lock screen unable to authenticate).
  Future<void> _onSecurityChanged(String v) async {
    if (v == _lockMethod) return;
    final l10n = AppLocalizations.of(context);

    if (v == 'biometric') {
      final auth = LocalAuthentication();
      try {
        final supported = await auth.isDeviceSupported();
        final canCheck = await auth.canCheckBiometrics;
        if (!supported || !canCheck) {
          if (!mounted) return;
          _showError(l10n.onbBiometricNotEnrolledError);
          return;
        }
        final ok = await auth.authenticate(
          localizedReason: l10n.onbBiometricConfirmReason,
          options: const AuthenticationOptions(
              biometricOnly: false, stickyAuth: true),
        );
        if (!ok) return; // user cancelled — keep previous selection
      } on PlatformException catch (e) {
        if (!mounted) return;
        _showError(l10n.onbBiometricSetupFailed(e.message ?? e.code));
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _lockMethod = v;
      _pin = '';
      _pinConfirm = '';
      _pinConfirming = false;
    });
  }

  // ── Save everything and enter the app ───────────────────────────────────────
  Future<void> _finish() async {
    setState(() => _saving = true);
    H.medium();
    final l10n = AppLocalizations.of(context);

    final _fmt = (TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    try {
      // ── Step 1: Save PIN hash to secure storage (PBKDF2 + 128-bit salt) ─────
      if (_lockMethod == 'pin' && _pin.isNotEmpty) {
        const storage = FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );
        await PinHash.writeNew(storage, _pin);
      }

      // ── Step 2: Build profile ────────────────────────────────────────────────
      final profile = UserProfile(
        username: _username.trim(),
        soberDate: _soberDate.toIso8601String(),
        dailySpend: _dailySpend,
        currency: _currency,
        timezone: DateTime.now().timeZoneName,
        lockMethod: _lockMethod,
        weeklyGoals: const [],
      );

      // ── Step 3: Persist ALL prefs synchronously to disk ──────────────────────
      // Use the Riverpod notifier (which writes profile + sets state)
      // then write the extra keys, then force a reload so the on-disk file
      // is consistent before any OS-dialog-induced activity recreation.
      await ref.read(profileProvider.notifier).save(profile);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lockMethod', _lockMethod);
      await prefs.setBool('notif_motivation', _notifMotivation);
      await prefs.setBool('notif_reminders', _notifReminders);
      await prefs.setBool('notif_milestones', _notifMilestones);
      await prefs.setString('notif_morning', _fmt(_morningTime));
      await prefs.setString('notif_evening', _fmt(_eveningTime));

      // CRITICAL: reload() blocks until the SharedPreferences XML on disk
      // is re-read into memory — this is the closest thing to a sync commit
      // available via the shared_preferences plugin. Without this, apply()
      // writes can still be pending in the Android plugin queue when the
      // notification-permission or exact-alarm system dialog pauses the
      // activity, and a recreate then reads stale (empty) prefs.
      await prefs.reload();

      // ── Step 4: Request notification permission (safe — router has redirect) ─
      // The router-level redirect in main.dart now re-checks profile existence
      // on every navigation, so even if the OS dialog causes an activity
      // recreate, the router will route to /home (profile is on disk).
      if (_notifMotivation || _notifReminders || _notifMilestones) {
        await NotificationService.requestPermission();
      }

      // ── Step 5: Schedule daily notifications ─────────────────────────────────
      if (_notifMotivation || _notifReminders) {
        final scheduleResult = await NotificationService.scheduleFromPrefs();
        if (!scheduleResult.success) {
          debugPrint(
            '[Onboarding] notification scheduling failed: ${scheduleResult.error}',
          );
        }
      }

      // ── Step 6: Navigate to home ─────────────────────────────────────────────
      if (mounted) context.go('/home');
    } catch (e) {
      debugPrint('[Onboarding] _finish failed: $e');
      if (mounted) {
        setState(() => _saving = false);
        _showError(l10n.onbSetupFailed(e.toString()));
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.honey500,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = _steps.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      // Stable test anchor — proves the router landed on /onboarding.
      key: const Key('onboarding-screen'),
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Top bar: back + progress ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                  child: Row(
                    children: [
                      if (!_isFirst)
                        LuxuryBackButton(onPressed: _back)
                      else
                        const SizedBox(width: 48),
                      Expanded(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadius.pill,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: AppColors.mintChip,
                                  valueColor: AlwaysStoppedAnimation(
                                      AppColors.forest600),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.onbStepIndicator(_currentIndex + 1, total),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Step content ───────────────────────────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: Offset(_goingForward ? 1.0 : -1.0, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: animation, curve: Curves.easeOutCubic));
                      return SlideTransition(
                        position: slide,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildStep(),
                    ),
                  ),
                ),

                // ── Bottom CTA ─────────────────────────────────────────────────
                if (_step != _Step.welcome &&
                    _step != _Step.pin &&
                    _step != _Step.finish)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _step == _Step.welcome ? _next : _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.forest600,
                          minimumSize: const Size.fromHeight(54),
                          shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.luxury),
                          textStyle: AppTextStyles.labelLarge,
                        ),
                        child: Text(_isLast
                            ? l10n.onbBeginMyJourney
                            : l10n.onbContinue),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      _Step.welcome => _WelcomeStep(onBegin: _next),
      _Step.name => _NameStep(
          value: _username,
          onChanged: (v) => setState(() => _username = v),
          onSubmit: _next,
        ),
      _Step.date => _DateStep(
          date: _soberDate,
          onChanged: (d) => setState(() => _soberDate = d),
        ),
      _Step.spend => _SpendStep(
          spend: _dailySpend,
          currency: _currency,
          onSpendChanged: (v) => setState(() => _dailySpend = v),
          onCurrencyChanged: (v) => setState(() => _currency = v),
        ),
      _Step.security => _SecurityStep(
          selected: _lockMethod,
          onChanged: _onSecurityChanged,
        ),
      _Step.pin => _PinStep(
          pin: _pinConfirming ? _pinConfirm : _pin,
          confirming: _pinConfirming,
          error: _pinError,
          onDigit: _onPinDigit,
          onDelete: _onPinDelete,
          onNext: _next,
        ),
      _Step.notifications => _NotificationsStep(
          motivation: _notifMotivation,
          reminders: _notifReminders,
          milestones: _notifMilestones,
          morningTime: _morningTime,
          eveningTime: _eveningTime,
          onMotivation: (v) => setState(() => _notifMotivation = v),
          onReminders: (v) => setState(() => _notifReminders = v),
          onMilestones: (v) => setState(() => _notifMilestones = v),
          onMorningChanged: (t) => setState(() => _morningTime = t),
          onEveningChanged: (t) => setState(() => _eveningTime = t),
        ),
      _Step.finish => _FinishStep(
          username: _username,
          soberDate: _soberDate,
          saving: _saving,
          onFinish: _finish,
        ),
    };
  }
}

// ─── Step 1: Welcome ──────────────────────────────────────────────────────────
// Single-screen design — no scrolling. Plant card sits in soft warm radial
// halo so the image dissolves into the cream surface rather than reading as a
// pasted-on rectangle. Vertical rhythm flexes via Spacers so the layout holds
// up on phones from ~640dp to large devices.

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onBegin});
  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final tight = c.maxHeight < 720;
        final plantSize = (c.maxHeight * (tight ? 0.34 : 0.38))
            .clamp(220.0, 320.0);

        // Wrap in a scroll view that only kicks in if the content does not
        // fit (very small viewports / accessibility text scaling). On a
        // normal phone (720dp+) the ConstrainedBox forces the Column to the
        // exact viewport height so the Spacers expand and the layout still
        // reads as a centred, non-scrolling welcome screen.
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    24, tight ? 4 : 10, 24, tight ? 14 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 1),

                    // ── Plant hero card ────────────────────────────────────
                    Center(
                      child: _OnboardingPlantCard(days: 0, size: plantSize),
                    ),

                    SizedBox(height: tight ? 22 : 30),

                    // ── Eyebrow ────────────────────────────────────────────
                    Center(
                      child: Text(
                        l10n.onbWelcomeEyebrow,
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.forest700,
                          fontSize: 11,
                          letterSpacing: 2.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Headline (serif) ───────────────────────────────────
                    Text(
                      l10n.onbWelcomeHeadline,
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: tight ? 30 : 34,
                        fontWeight: FontWeight.w600,
                        height: 1.08,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // ── Subtitle ───────────────────────────────────────────
                    Text(
                      l10n.onbWelcomeBody,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.stone600,
                        height: 1.5,
                        fontSize: 14.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(flex: 2),

                    // ── Feature pills ──────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _FeaturePill(
                            icon: Icons.wifi_off_rounded,
                            title: l10n.onbPrivacy100OnDevice.toUpperCase(),
                            sub: l10n.onbWelcomePillOnDeviceSub,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _FeaturePill(
                            icon: Icons.lock_outline_rounded,
                            title: l10n.onbWelcomePillNoAccountTitle,
                            sub: l10n.onbWelcomePillNoAccountSub,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _FeaturePill(
                            icon: Icons.shield_outlined,
                            title: l10n.onbWelcomePillZeroTrackingTitle,
                            sub: l10n.onbWelcomePillZeroTrackingSub,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: tight ? 16 : 22),

                    // ── Primary CTA ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onBegin,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.forest700,
                          foregroundColor: AppColors.onForest,
                          minimumSize: const Size.fromHeight(58),
                          shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.xl),
                          textStyle: AppTextStyles.titleMedium.copyWith(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                        child: Text(l10n.onbWelcomeBeginButton),
                      ),
                    ),

                    SizedBox(height: tight ? 8 : 12),

                    // ── Disclaimer ─────────────────────────────────────────
                    Center(
                      child: Text(
                        l10n.onbWelcomeDisclaimer,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.stone500,
                          fontSize: 11.5,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Feature pill (small icon-card) ──────────────────────────────────────────

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.title,
    required this.sub,
  });
  final IconData icon;
  final String title, sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.forest100, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1F4D38),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.mintChip,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: AppColors.forest700),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.forest700,
              fontSize: 10,
              letterSpacing: 0.9,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            sub,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.stone600,
              fontSize: 11,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Name ─────────────────────────────────────────────────────────────

class _NameStep extends StatefulWidget {
  const _NameStep({
    required this.value,
    required this.onChanged,
    required this.onSubmit,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.value);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _StepShell(
      headline: l10n.onbNameHeadline,
      sub: l10n.onbNameSub,
      child: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSubmit(),
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.stone800),
        decoration: _inputDecor(l10n.onbNameHint, Icons.person_outline_rounded),
      ),
    );
  }
}

// ─── Step 3: Sober Date ───────────────────────────────────────────────────────

class _DateStep extends StatefulWidget {
  const _DateStep({required this.date, required this.onChanged});
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  State<_DateStep> createState() => _DateStepState();
}

class _DateStepState extends State<_DateStep> {
  ThemeData _pickerTheme(BuildContext ctx) => Theme.of(ctx).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.forest600,
          onPrimary: Colors.white,
          surface: AppColors.card,
          onSurface: AppColors.stone800,
        ),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.date,
      firstDate: DateTime(2000),
      // Allow a future date so users can set "I'll quit on X" and get a
      // countdown to day one (up to a year out).
      lastDate: DateTime.now().add(const Duration(days: 366)),
      helpText: AppLocalizations.of(context).onbDatePickerHelp,
      builder: (ctx, child) => Theme(data: _pickerTheme(ctx), child: child!),
    );
    if (picked != null) {
      // Preserve existing time component
      widget.onChanged(DateTime(
        picked.year,
        picked.month,
        picked.day,
        widget.date.hour,
        widget.date.minute,
      ));
    }
  }

  Future<void> _pickTime() async {
    final d = widget.date;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: d.hour, minute: d.minute),
      builder: (ctx, child) => Theme(data: _pickerTheme(ctx), child: child!),
    );
    if (picked != null) {
      widget.onChanged(DateTime(
        d.year,
        d.month,
        d.day,
        picked.hour,
        picked.minute,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = widget.date;
    final isFuture = date.isAfter(DateTime.now());
    final timeLabel =
        TimeOfDay(hour: date.hour, minute: date.minute).format(context);

    return _StepShell(
      headline: l10n.onbDateHeadline,
      sub: l10n.onbDateSub,
      child: Column(
        children: [
          // ── Date tile ────────────────────────────────────────────────────
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppRadius.xl,
                border: Border.all(color: AppColors.stone100),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.forest50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.calendar_today_rounded,
                        color: AppColors.forest600, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isFuture ? l10n.onbQuitDateLabel : l10n.onbSoberSince,
                            style: AppTextStyles.caption),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(date),
                          style: AppTextStyles.titleMedium
                              .copyWith(color: AppColors.forest700),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.stone400),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Time tile ────────────────────────────────────────────────────
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppRadius.xl,
                border: Border.all(color: AppColors.stone100),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.forest50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.access_time_rounded,
                        color: AppColors.forest600, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.onbTimeOfDayLabel, style: AppTextStyles.caption),
                        const SizedBox(height: 2),
                        Text(
                          timeLabel,
                          style: AppTextStyles.titleMedium
                              .copyWith(color: AppColors.forest700),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.stone400),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Days count preview ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.mintChip,
              borderRadius: AppRadius.xxl,
              border: Border.all(color: AppColors.softBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isFuture
                      ? '${date.difference(DateTime.now()).inDays + 1}'
                      : '${DateTime.now().difference(date).inDays.clamp(0, 99999)}',
                  style: AppTextStyles.displaySmall
                      .copyWith(color: AppColors.forest700),
                ),
                const SizedBox(width: 8),
                Text(isFuture ? l10n.onbDaysUntilDayOneLabel : l10n.onbDaysOfCourageLabel,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.forest600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 4: Daily Spend ──────────────────────────────────────────────────────

class _SpendStep extends StatefulWidget {
  const _SpendStep({
    required this.spend,
    required this.currency,
    required this.onSpendChanged,
    required this.onCurrencyChanged,
  });
  final double spend;
  final String currency;
  final ValueChanged<double> onSpendChanged;
  final ValueChanged<String> onCurrencyChanged;

  @override
  State<_SpendStep> createState() => _SpendStepState();
}

class _SpendStepState extends State<_SpendStep> {
  late final TextEditingController _ctrl = TextEditingController(
      text: widget.spend > 0 ? widget.spend.toStringAsFixed(0) : '');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _StepShell(
      headline: l10n.onbSpendHeadline,
      sub: l10n.onbSpendSub,
      child: Column(
        children: [
          Row(
            children: [
              // Currency selector
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border.all(color: AppColors.softBorder),
                  borderRadius: AppRadius.xxl,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.currency,
                    items: [
                      'R',
                      '\$',
                      '£',
                      '€',
                      '¥',
                      'A\$',
                      'C\$',
                      'NZ\$',
                      'HK\$',
                      'S\$',
                      'CHF',
                      'kr',
                      '₹',
                      '₩',
                      '₺',
                      '₱',
                      'RM',
                      '₦',
                      'GH₵',
                      'Ksh',
                      '₫',
                      '฿',
                      'лв',
                      'zł'
                    ]
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style: AppTextStyles.titleMedium
                                      .copyWith(color: AppColors.forest700)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        widget.onCurrencyChanged(v ?? widget.currency),
                    borderRadius: AppRadius.lg,
                    icon: Icon(Icons.expand_more_rounded,
                        color: AppColors.stone400, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  onChanged: (v) =>
                      widget.onSpendChanged(double.tryParse(v) ?? 0),
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.stone800),
                  decoration: _inputDecor(
                      l10n.onbSpendAmountHint, Icons.savings_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Savings preview (if amount entered)
          if (widget.spend > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.honey50,
                borderRadius: AppRadius.lg,
                border: Border.all(color: AppColors.honey100),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up_rounded,
                      color: AppColors.honey500, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.onbSpendSavingsPreview(widget.currency,
                          (widget.spend * 30).toStringAsFixed(0)),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.honey600),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppRadius.xxl,
                border: Border.all(color: AppColors.softBorder),
              ),
              child: Text(
                l10n.onbSpendSkipNote,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Step 5: Security ─────────────────────────────────────────────────────────

class _SecurityStep extends StatelessWidget {
  const _SecurityStep({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      (
        value: 'none',
        icon: Icons.lock_open_outlined,
        label: l10n.onbSecurityNoLockLabel,
        sub: l10n.onbSecurityNoLockSub,
      ),
      (
        value: 'biometric',
        icon: Icons.fingerprint_rounded,
        label: l10n.onbSecurityBiometricLabel,
        sub: l10n.onbSecurityBiometricSub,
      ),
      (
        value: 'pin',
        icon: Icons.pin_outlined,
        label: l10n.onbSecurityPinLabel,
        sub: l10n.onbSecurityPinSub,
      ),
    ];

    return _StepShell(
      headline: l10n.onbSecurityHeadline,
      sub: l10n.onbSecuritySub,
      child: Column(
        children: [
          ...options.map((o) => _SecurityOption(
                value: o.value,
                icon: o.icon,
                label: o.label,
                sub: o.sub,
                selected: selected == o.value,
                onTap: () => onChanged(o.value),
              )),
          // Data-recovery warning — appears as soon as the user picks any
          // lock. The app stores everything locally and encrypted; if the
          // PIN is forgotten or biometrics are reset, there is no recovery
          // path other than a backup file (Profile → Backup).
          if (selected == 'pin' || selected == 'biometric') ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.honeySoft,
                borderRadius: AppRadius.xxl,
                border: Border.all(color: AppColors.honey100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 18, color: AppColors.honey500),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selected == 'pin'
                          ? l10n.onbSecurityPinRecoveryWarning
                          : l10n.onbSecurityBiometricRecoveryWarning,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.honey500, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SecurityOption extends StatelessWidget {
  const _SecurityOption({
    required this.value,
    required this.icon,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });
  final String value, label, sub;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        H.selection();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.mintChip : AppColors.card,
          borderRadius: AppRadius.xxl,
          border: Border.all(
            color: selected ? AppColors.forest600 : AppColors.softBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected ? AppShadows.card : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.forest100 : AppColors.stone50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 20,
                  color: selected ? AppColors.forest600 : AppColors.stone400),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.titleSmall.copyWith(
                          color: selected
                              ? AppColors.forest700
                              : AppColors.stone800)),
                  Text(sub, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.forest600 : Colors.white,
                border: Border.all(
                  color: selected ? AppColors.forest600 : AppColors.stone200,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 6: PIN Entry ────────────────────────────────────────────────────────

class _PinStep extends StatelessWidget {
  const _PinStep({
    required this.pin,
    required this.confirming,
    required this.error,
    required this.onDigit,
    required this.onDelete,
    required this.onNext,
  });
  final String pin;
  final bool confirming;
  final String? error;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: _StepShell(
            headline: confirming
                ? l10n.onbPinConfirmHeadline
                : l10n.onbPinCreateHeadline,
            sub: confirming ? l10n.onbPinConfirmSub : l10n.onbPinCreateSub,
            child: Column(
              children: [
                // 4 dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? AppColors.forest600 : Colors.white,
                        border: Border.all(
                          color:
                              filled ? AppColors.forest600 : AppColors.stone300,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.honey500),
                      textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),

        // Number pad
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            children: [
              for (final row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
                ['', '0', '⌫'],
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row
                        .map((d) => d.isEmpty
                            ? const SizedBox(width: 80)
                            : _PinButton(
                                label: d,
                                onTap: d == '⌫' ? onDelete : () => onDigit(d),
                              ))
                        .toList(),
                  ),
                ),
              // Next when 4 digits entered
              if (pin.length == 4)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest600,
                      minimumSize: const Size.fromHeight(54),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.xl),
                    ),
                    child: Text(confirming
                        ? l10n.onbPinConfirmButton
                        : l10n.commonNext),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PinButton extends StatelessWidget {
  const _PinButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDelete = label == '⌫';
    return SizedBox(
      width: 80,
      height: 62,
      child: Material(
        color: isDelete ? Colors.transparent : AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.xl,
          splashColor: AppColors.forest50,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.xl,
              border: Border.all(
                  color: isDelete ? Colors.transparent : AppColors.softBorder),
            ),
            child: Center(
              child: Text(
                label,
                style: isDelete
                    ? AppTextStyles.titleLarge
                        .copyWith(color: AppColors.stone500)
                    : AppTextStyles.displaySmall
                        .copyWith(fontSize: 24, color: AppColors.stone800),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step 7: Notifications ────────────────────────────────────────────────────

class _NotificationsStep extends StatelessWidget {
  const _NotificationsStep({
    required this.motivation,
    required this.reminders,
    required this.milestones,
    required this.morningTime,
    required this.eveningTime,
    required this.onMotivation,
    required this.onReminders,
    required this.onMilestones,
    required this.onMorningChanged,
    required this.onEveningChanged,
  });
  final bool motivation, reminders, milestones;
  final TimeOfDay morningTime, eveningTime;
  final ValueChanged<bool> onMotivation, onReminders, onMilestones;
  final ValueChanged<TimeOfDay> onMorningChanged, onEveningChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _StepShell(
      headline: l10n.onbNotifHeadline,
      sub: l10n.onbNotifSub,
      child: Column(
        children: [
          // Privacy note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mintChip,
              borderRadius: AppRadius.xxl,
              border: Border.all(color: AppColors.softBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 16, color: AppColors.forest600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.onbNotifPrivacyNote,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.forest700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _NotifToggle(
            icon: Icons.wb_sunny_outlined,
            label: l10n.onbNotifMorningLabel,
            sub: l10n.onbNotifMorningSub,
            value: motivation,
            onChanged: onMotivation,
          ),
          if (motivation) ...[
            _TimePicker(
              label: l10n.onbNotifMorningTime,
              time: morningTime,
              onChanged: onMorningChanged,
            ),
            const SizedBox(height: 8),
          ],

          _NotifToggle(
            icon: Icons.bedtime_outlined,
            label: l10n.onbNotifEveningLabel,
            sub: l10n.onbNotifEveningSub,
            value: reminders,
            onChanged: onReminders,
          ),
          if (reminders) ...[
            _TimePicker(
              label: l10n.onbNotifEveningTime,
              time: eveningTime,
              onChanged: onEveningChanged,
            ),
            const SizedBox(height: 8),
          ],

          _NotifToggle(
            icon: Icons.star_outline_rounded,
            label: l10n.onbNotifMilestonesLabel,
            sub: l10n.onbNotifMilestonesSub,
            value: milestones,
            onChanged: onMilestones,
          ),

          const SizedBox(height: 12),
          Text(
            l10n.onbNotifChangeAnytime,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  const _NotifToggle({
    required this.icon,
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label, sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.xxl,
          border: Border.all(color: AppColors.softBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.forest400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.titleSmall),
                  Text(sub, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: (v) {
                H.selection();
                onChanged(v);
              },
              activeColor: AppColors.forest600,
              activeTrackColor: AppColors.forest100,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.label,
    required this.time,
    required this.onChanged,
  });
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(
                  primary: AppColors.forest600,
                  onPrimary: Colors.white,
                  surface: AppColors.card,
                  onSurface: AppColors.stone800),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.xxl,
          border: Border.all(color: AppColors.softBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded,
                size: 16, color: AppColors.stone400),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.bodySmall),
            const Spacer(),
            Text(time.format(context),
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.forest600)),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined,
                size: 14, color: AppColors.stone400),
          ],
        ),
      ),
    );
  }
}

// ─── Step 8: Finish ───────────────────────────────────────────────────────────

class _FinishStep extends StatefulWidget {
  const _FinishStep({
    required this.username,
    required this.soberDate,
    required this.saving,
    required this.onFinish,
  });
  final String username;
  final DateTime soberDate;
  final bool saving;
  final VoidCallback onFinish;

  @override
  State<_FinishStep> createState() => _FinishStepState();
}

class _FinishStepState extends State<_FinishStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  late final Animation<double> _scale = CurvedAnimation(
      parent: _ctrl, curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.2, 1.0));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFuture = widget.soberDate.isAfter(DateTime.now());
    final days =
        DateTime.now().difference(widget.soberDate).inDays.clamp(0, 99999);
    final countdownDays =
        isFuture ? widget.soberDate.difference(DateTime.now()).inDays + 1 : 0;
    final name = widget.username.trim();
    final headline = name.isNotEmpty
        ? l10n.onbFinishHeadlineWithName(name)
        : l10n.onbFinishHeadline;

    return LayoutBuilder(
      builder: (context, c) {
        final tight = c.maxHeight < 720;
        final plantSize = (c.maxHeight * (tight ? 0.34 : 0.38))
            .clamp(220.0, 320.0);

        // Same overflow-safe wrapping as _WelcomeStep — normal phones get
        // the no-scroll centred layout via the ConstrainedBox; very small
        // viewports / large text scaling get a silent fallback to scroll
        // instead of a RenderFlex overflow.
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    24, tight ? 4 : 10, 24, tight ? 14 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 1),

                    // ── Animated plant card ────────────────────────────────
                    Center(
                      child: ScaleTransition(
                        scale: _scale,
                        child: _OnboardingPlantCard(
                            days: days, size: plantSize),
                      ),
                    ),

                    SizedBox(height: tight ? 22 : 30),

                    // ── Eyebrow ────────────────────────────────────────────
                    FadeTransition(
                      opacity: _fade,
                      child: Center(
                        child: Text(
                          isFuture
                              ? l10n.onbFinishEyebrowCountdown(countdownDays)
                              : days > 0
                                  ? l10n.onbFinishEyebrowContinuing(days + 1)
                                  : l10n.onbFinishEyebrowDayOne,
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.forest700,
                            fontSize: 11,
                            letterSpacing: 2.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Headline ───────────────────────────────────────────
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        headline,
                        style: AppTextStyles.displayMedium.copyWith(
                          fontSize: tight ? 30 : 34,
                          fontWeight: FontWeight.w600,
                          height: 1.08,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Subtitle ───────────────────────────────────────────
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        isFuture
                            ? l10n.onbFinishBodyFuture
                            : days > 0
                                ? l10n.onbFinishBodyDays(days)
                                : l10n.onbFinishBodyToday,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.stone600,
                          height: 1.5,
                          fontSize: 14.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ── Privacy confirmation chip ──────────────────────────
                    FadeTransition(
                      opacity: _fade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.forest50,
                          borderRadius: AppRadius.xl,
                          border: Border.all(color: AppColors.forest100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user_outlined,
                                color: AppColors.forest600, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.onbFinishPrivacyNote,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.forest700,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: tight ? 14 : 18),

                    // ── Primary CTA ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.saving ? null : widget.onFinish,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.forest700,
                          foregroundColor: AppColors.onForest,
                          minimumSize: const Size.fromHeight(58),
                          shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.xl),
                          textStyle: AppTextStyles.titleMedium.copyWith(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                        child: widget.saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(l10n.onbBeginMyJourney),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Plant hero card — onboarding screens 1 & 7 ──────────────────────────────
// Designed so the plant feels painted-into the surface, not pasted-on:
//   1. A warm radial halo (off-white → cream → dusty stone) sits behind the
//      plant. The halo center is biased slightly above the visual middle so
//      it reads like sunlight catching the leaves from above-front.
//   2. The plant image itself is masked with an EXTENDED radial fade
//      (60% solid → 100% transparent at the edge) so its native background
//      dissolves into the halo rather than terminating at a hard rectangle.
//   3. A soft elliptical "ground shadow" anchors the plant to the card.
//   4. Four minimal L-bracket corner marks reference the brand's botanical
//      framing without the previous lotus/diamond/leaf clutter.

class _OnboardingPlantCard extends StatelessWidget {
  const _OnboardingPlantCard({required this.days, required this.size});
  final int days;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Card surface: warm radial halo ─────────────────────────────
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppRadius.xxl,
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xA8DCE8DC), width: 1),
                ),
                gradient: RadialGradient(
                  center: Alignment(0, -0.18),
                  radius: 1.05,
                  colors: [
                    Color(0xFFFCF8EE), // bright sun-warm centre
                    Color(0xFFF7F1E1), // soft cream mid
                    Color(0xFFEDE5D1), // dustier outer edge
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x141F4D38),
                    blurRadius: 30,
                    offset: Offset(0, 14),
                    spreadRadius: -8,
                  ),
                ],
              ),
            ),
          ),

          // ── Inner ambient glow (mimics light wrap on leaves) ───────────
          const Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: AppRadius.xxl,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.35),
                      radius: 0.6,
                      colors: [
                        Color(0x40FFFFFF),
                        Color(0x00FFFFFF),
                      ],
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Ground shadow (soft elliptical anchor) ─────────────────────
          Positioned(
            left: size * 0.18,
            right: size * 0.18,
            bottom: size * 0.12,
            height: size * 0.08,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.elliptical(
                      size * 0.32, size * 0.04)),
                  gradient: const RadialGradient(
                    center: Alignment.center,
                    radius: 0.7,
                    colors: [
                      Color(0x252E5844),
                      Color(0x002E5844),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Plant image with extended soft fade ───────────────────────
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(size * 0.09),
              child: ShaderMask(
                shaderCallback: (rect) => const RadialGradient(
                  center: Alignment.center,
                  radius: 0.95,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Color(0x00FFFFFF),
                  ],
                  stops: [0.0, 0.52, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  PlantLogic.getPlantAsset(days),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  semanticLabel: PlantLogic.getStageLabel(days),
                  filterQuality: FilterQuality.high,
                  // The artwork ships on a white ground; multiplying by the
                  // card's centre colour turns that ground into the card
                  // surface itself, so the picture reads as painted on the
                  // card rather than pasted over it.
                  color: const Color(0xFFFCF8EE),
                  colorBlendMode: BlendMode.multiply,
                ),
              ),
            ),
          ),

          // ── Corner brackets (minimal botanical reference) ─────────────
          const Positioned(
            top: 14, left: 14,
            child: _CornerBracket(corner: _BracketCorner.tl),
          ),
          const Positioned(
            top: 14, right: 14,
            child: _CornerBracket(corner: _BracketCorner.tr),
          ),
          const Positioned(
            bottom: 14, left: 14,
            child: _CornerBracket(corner: _BracketCorner.bl),
          ),
          const Positioned(
            bottom: 14, right: 14,
            child: _CornerBracket(corner: _BracketCorner.br),
          ),
        ],
      ),
    );
  }
}

enum _BracketCorner { tl, tr, bl, br }

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.corner});
  final _BracketCorner corner;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 16),
      painter: _CornerBracketPainter(corner: corner),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter({required this.corner});
  final _BracketCorner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.forest300
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final w = size.width;
    final h = size.height;
    switch (corner) {
      case _BracketCorner.tl:
        canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint);
        canvas.drawLine(const Offset(0, 0), Offset(0, h), paint);
        break;
      case _BracketCorner.tr:
        canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint);
        canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
        break;
      case _BracketCorner.bl:
        canvas.drawLine(Offset(0, h), Offset(w, h), paint);
        canvas.drawLine(const Offset(0, 0), Offset(0, h), paint);
        break;
      case _BracketCorner.br:
        canvas.drawLine(Offset(0, h), Offset(w, h), paint);
        canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter old) =>
      old.corner != corner;
}

// ─── Shared shell for steps ───────────────────────────────────────────────────

class _StepShell extends StatelessWidget {
  const _StepShell({
    required this.headline,
    required this.sub,
    required this.child,
  });
  final String headline, sub;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline,
              style: AppTextStyles.displaySmall.copyWith(height: 1.2)),
          const SizedBox(height: 8),
          Text(sub,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.stone500, height: 1.6)),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

// ─── Shared input decoration ──────────────────────────────────────────────────

InputDecoration _inputDecor(String hint, IconData icon) => InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.stone400),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: AppRadius.xxl,
        borderSide: BorderSide(color: AppColors.softBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.xxl,
        borderSide: BorderSide(color: AppColors.softBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.xxl,
        borderSide: BorderSide(color: AppColors.forest600, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
