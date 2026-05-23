import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import '../utils/pin_hash.dart';
import '../utils/plant_logic.dart';
import '../utils/secure_window.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final _auth = LocalAuthentication();

  String _lockMethod = 'none';
  bool _loading = true;

  // PIN state
  String _entered = '';
  String? _error;

  late final AnimationController _shakeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
  late final Animation<double> _shakeAnim = Tween<double>(begin: 0, end: 1)
      .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut));

  @override
  void initState() {
    super.initState();
    // Block screenshots/recents-thumbnail of the PIN pad.
    SecureWindow.enable();
    _init();
  }

  @override
  void dispose() {
    SecureWindow.disable();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final method = prefs.getString('lockMethod') ?? 'none';

    // ── Integrity check: if PIN is the configured lock but neither the new
    // (v2 salted) nor the legacy hash is present in secure storage, the lock
    // is corrupted. Clear the orphaned lockMethod so the user is treated as
    // having no lock — the next session reflects 'none' and they can re-set
    // a PIN from Settings. This is what closes the "type any 4 digits to
    // bypass" hole that existed before.
    if (method == 'pin') {
      final hasV2 = (await _storage.read(key: PinHash.storageKey)) != null;
      final hasLegacy = (await _storage.read(key: PinHash.legacyKey)) != null;
      if (!hasV2 && !hasLegacy) {
        await prefs.remove('lockMethod');
        if (!mounted) return;
        _unlock();
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _lockMethod = method;
      _loading = false;
    });

    if (method == 'biometric') {
      await _tryBiometric();
    } else if (method == 'none') {
      _unlock();
    }
    // 'pin' falls through to show the PIN pad
  }

  Future<void> _tryBiometric() async {
    final l10n = AppLocalizations.of(context);
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isAvailable = await _auth.isDeviceSupported();

      if (!mounted) return;
      if (!canCheck && !isAvailable) {
        setState(() => _error = l10n.lockBiometricsNotAvailable);
        _fallbackToPin();
        return;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: l10n.lockUnlockReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;
      if (authenticated) {
        _unlock();
      } else {
        setState(() => _error = l10n.lockAuthCancelled);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'NotEnrolled' => l10n.lockNotEnrolled,
        'LockedOut' => l10n.lockTooManyAttempts,
        'PermanentlyLockedOut' => l10n.lockPermanentlyLockedOut,
        'NotAvailable' => l10n.lockBiometricsUnavailable,
        _ => l10n.lockAuthFailed,
      };
      setState(() => _error = msg);
      _fallbackToPin();
    }
  }

  void _fallbackToPin() => setState(() => _lockMethod = 'pin');

  void _unlock() {
    if (mounted) context.go('/home');
  }

  void _onDigit(String digit) {
    if (_entered.length >= 4) return;
    H.selection();
    setState(() {
      _entered += digit;
      _error = null;
    });
    if (_entered.length == 4) _verifyPin();
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    H.selection();
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _verifyPin() async {
    final v2 = await _storage.read(key: PinHash.storageKey);
    final legacy = await _storage.read(key: PinHash.legacyKey);
    if (!mounted) return;

    // No hash at all — refuse to unlock. The startup integrity check handles
    // the normal "lock-broken" case before the PIN pad is shown. Reaching
    // this branch means something cleared secure storage mid-session; the
    // safe response is "incorrect PIN" rather than silent unlock.
    if (v2 == null && legacy == null) {
      _wrongPin();
      return;
    }

    bool ok = false;
    if (v2 != null) {
      ok = PinHash.verify(_entered, v2);
    } else {
      // Legacy unsalted SHA-256 — verify, then transparently migrate to v2.
      final entered = sha256.convert(utf8.encode(_entered)).toString();
      ok = entered == legacy;
      if (ok) {
        await PinHash.writeNew(_storage, _entered);
      }
    }

    if (ok) {
      H.medium();
      _unlock();
    } else {
      _wrongPin();
    }
  }

  void _wrongPin() {
    H.heavy();
    setState(() {
      _error = AppLocalizations.of(context).lockIncorrectPin;
      _entered = '';
    });
    _shakeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.stone50,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.forest600),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Stack(
          children: [
            _lockMethod == 'biometric'
                ? _BiometricView(
                    error: _error,
                    onRetry: _tryBiometric,
                    onFallback: _fallbackToPin,
                  )
                : _PinView(
                    entered: _entered,
                    error: _error,
                    shakeAnim: _shakeAnim,
                    onDigit: _onDigit,
                    onDelete: _onDelete,
                    onBiometric: null, // shown only if biometric also enrolled
                  ),
          ],
        ),
      ),
    );
  }
}

// ─── Biometric view ───────────────────────────────────────────────────────────

class _BiometricView extends StatelessWidget {
  const _BiometricView({
    required this.error,
    required this.onRetry,
    required this.onFallback,
  });
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onFallback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(PlantLogic.getPlantAsset(0),
              height: 140, fit: BoxFit.contain),
          const SizedBox(height: 32),

          Text(l10n.lockAppName,
              style: AppTextStyles.displaySmall
                  .copyWith(color: AppColors.forest700)),
          const SizedBox(height: 8),
          Text(l10n.lockAuthenticateSubtitle,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.stone500)),
          const SizedBox(height: 40),

          // Fingerprint icon
          GestureDetector(
            onTap: onRetry,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.mintChip,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fingerprint_rounded,
                  size: 44, color: AppColors.forest600),
            ),
          ),
          const SizedBox(height: 16),

          Text(l10n.lockTapToAuthenticate,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.stone400)),

          if (error != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.honeySoft,
                borderRadius: AppRadius.xxl,
                border: Border.all(color: AppColors.honey100),
              ),
              child: Text(error!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.honey500),
                  textAlign: TextAlign.center),
            ),
          ],

          const SizedBox(height: 32),
          TextButton(
            onPressed: onFallback,
            child: Text(l10n.lockUsePinInstead,
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.forest600)),
          ),
        ],
      ),
    );
  }
}

// ─── PIN view ─────────────────────────────────────────────────────────────────

class _PinView extends StatelessWidget {
  const _PinView({
    required this.entered,
    required this.error,
    required this.shakeAnim,
    required this.onDigit,
    required this.onDelete,
    required this.onBiometric,
  });
  final String entered;
  final String? error;
  final Animation<double> shakeAnim;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const Spacer(),

        // Logo + plant
        Image.asset(PlantLogic.getPlantAsset(0),
            height: 110, fit: BoxFit.contain),
        const SizedBox(height: 20),
        Text(l10n.lockAppName,
            style: AppTextStyles.displaySmall
                .copyWith(color: AppColors.forest700)),
        const SizedBox(height: 6),
        Text(l10n.lockEnterYourPin,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.stone500)),
        const SizedBox(height: 32),

        // PIN dots with shake animation
        AnimatedBuilder(
          animation: shakeAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(
              (shakeAnim.value * 12) * (shakeAnim.value > 0.5 ? -1 : 1),
              0,
            ),
            child: child,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < entered.length;
              final hasError = error != null;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasError
                      ? AppColors.honey500
                      : filled
                          ? AppColors.forest600
                          : Colors.white,
                  border: Border.all(
                    color: hasError
                        ? AppColors.honey500
                        : filled
                            ? AppColors.forest600
                            : AppColors.stone300,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
        ),

        // Error message
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: error != null
              ? Padding(
                  key: const ValueKey('err'),
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(error!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.honey500)),
                )
              : const SizedBox(key: ValueKey('no-err'), height: 14 + 16.0),
        ),

        const Spacer(),

        // Number pad
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
          child: Column(
            children: [
              for (final row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
                ['bio', '0', '⌫'],
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((d) {
                      if (d == 'bio') {
                        return onBiometric != null
                            ? _PadButton(
                                child: const Icon(Icons.fingerprint_rounded,
                                    size: 26, color: AppColors.stone500),
                                onTap: onBiometric!,
                              )
                            : const SizedBox(width: 80, height: 62);
                      }
                      return _PadButton(
                        child: Text(
                          d,
                          style: d == '⌫'
                              ? AppTextStyles.titleLarge
                                  .copyWith(color: AppColors.stone500)
                              : AppTextStyles.displaySmall.copyWith(
                                  fontSize: 26, color: AppColors.stone800),
                        ),
                        onTap: d == '⌫' ? onDelete : () => onDigit(d),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PadButton extends StatelessWidget {
  const _PadButton({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 62,
      child: Material(
        color: AppColors.card,
        borderRadius: AppRadius.xl,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.xl,
          splashColor: AppColors.forest50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.xl,
              border: Border.all(color: AppColors.softBorder),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
