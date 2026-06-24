import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../utils/locale_format.dart';
import 'package:local_auth/local_auth.dart';

import 'package:url_launcher/url_launcher.dart';

import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_locales.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import '../utils/notification_service.dart';
import '../utils/pin_hash.dart';

// ─── Settings Screen ──────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final _auth = LocalAuthentication();

  int _versionTapCount = 0;
  bool _showDiagnostics = false;

  // ── Edit profile dialog ───────────────────────────────────────────────────

  Future<void> _editUsername(UserProfile p) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: p.username);
    final result = await _textDialog(
      title: l10n.settingsYourName,
      controller: ctrl,
      hint: l10n.settingsNameHint,
      keyboardType: TextInputType.name,
      capitalization: TextCapitalization.words,
    );
    ctrl.dispose();
    if (result == null || result.isEmpty) return;
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(username: result));
  }

  Future<void> _editSoberDate(UserProfile p) async {
    final current = DateTime.tryParse(p.soberDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      // Future dates allowed: a user can set "I'll quit on X" and the home
      // screen counts down to it, then flips to the sober count-up.
      lastDate: DateTime.now().add(const Duration(days: 366)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.forest600,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    // Preserve the existing time-of-day so editing only the date doesn't
    // silently reset hours/minutes/seconds to midnight.
    final existingTime = DateTime.tryParse(p.soberDate) ?? DateTime.now();
    final merged = DateTime(
      picked.year,
      picked.month,
      picked.day,
      existingTime.hour,
      existingTime.minute,
      existingTime.second,
    );
    await ref.read(profileProvider.notifier).patch(
          (p) => p.copyWith(
            soberDate: merged.toIso8601String(),
            firedMilestoneDays: [],
            firedSavingsTiers: [],
          ),
        );
  }

  Future<void> _editDailySpend(UserProfile p) async {
    final ctrl = TextEditingController(
      text: p.dailySpend > 0 ? p.dailySpend.toStringAsFixed(2) : '',
    );
    String currency = p.currency;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _SpendDialog(
        controller: ctrl,
        initialCurrency: currency,
      ),
    );
    ctrl.dispose();
    if (result == null) return;
    final spend = double.tryParse(result['spend'] as String) ?? 0;
    await ref.read(profileProvider.notifier).patch(
          (p) => p.copyWith(
            dailySpend: spend,
            currency: result['currency'] as String,
          ),
        );
  }

  Future<void> _editSavingsGoal(UserProfile p) async {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: p.savingsGoalName ?? '');
    final amtCtrl = TextEditingController(
      text: p.savingsGoal != null ? p.savingsGoal!.toStringAsFixed(2) : '',
    );

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
        title: Text(l10n.settingsSavingsGoalDialogTitle,
            style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecor(l10n.settingsGoalNameHint),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amtCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecor(l10n.settingsTargetAmountHint),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.stone500)),
          ),
          if (p.savingsGoal != null)
            TextButton(
              onPressed: () => Navigator.pop(ctx, {'clear': true}),
              child: Text(l10n.commonClear,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.blush500)),
            ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.forest600),
            onPressed: () => Navigator.pop(ctx, {
              'name': nameCtrl.text.trim(),
              'amount': amtCtrl.text.trim(),
            }),
            child: Text(l10n.commonSave,
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    amtCtrl.dispose();

    if (result == null) return;
    if (result['clear'] == true) {
      await ref
          .read(profileProvider.notifier)
          .patchGoal(amount: null, name: null);
      return;
    }
    final amt = double.tryParse(result['amount'] as String);
    // Coerce a non-positive amount to null (a dead goal that can never
    // progress) so this dialog agrees with the home goal sheet, which already
    // does `amount > 0 ? amount : null`.
    final goal = (amt != null && amt > 0) ? amt : null;
    final goalName = (result['name'] as String).isEmpty
        ? null
        : result['name'] as String;
    await ref.read(profileProvider.notifier).patch(
          (p) => p.copyWith(
            savingsGoalName: goal == null ? null : goalName,
            savingsGoal: goal,
          ),
        );
  }

  Future<void> _editEmergencyContact(UserProfile p) async {
    final l10n = AppLocalizations.of(context);
    final nameCtrl =
        TextEditingController(text: p.emergencyContact?.name ?? '');
    final phoneCtrl =
        TextEditingController(text: p.emergencyContact?.phone ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
        title: Text(l10n.settingsEmergencyContactDialogTitle,
            style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecor(l10n.settingsContactNameHint),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: _inputDecor(l10n.settingsContactPhoneHint),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.stone500)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.forest600),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonSave,
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result != true) {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      return;
    }

    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    nameCtrl.dispose();
    phoneCtrl.dispose();

    await ref.read(profileProvider.notifier).patch(
          (p) => p.copyWith(
            emergencyContact: name.isEmpty && phone.isEmpty
                ? null
                : EmergencyContact(name: name, phone: phone),
          ),
        );
  }

  // ── Reason / goal editors ─────────────────────────────────────────────────

  Future<void> _addReason(UserProfile p, String text) async {
    if (text.isEmpty) return;
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(myReasons: [...p.myReasons, text]));
  }

  Future<void> _removeReasonAt(UserProfile p, int index) async {
    final updated = [...p.myReasons]..removeAt(index);
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(myReasons: updated));
  }

  Future<void> _addPro(UserProfile p, String text) async {
    if (text.isEmpty) return;
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(pros: [...p.pros, text]));
  }

  Future<void> _removeProAt(UserProfile p, int index) async {
    final updated = [...p.pros]..removeAt(index);
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(pros: updated));
  }

  Future<void> _addCon(UserProfile p, String text) async {
    if (text.isEmpty) return;
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(cons: [...p.cons, text]));
  }

  Future<void> _removeConAt(UserProfile p, int index) async {
    final updated = [...p.cons]..removeAt(index);
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(cons: updated));
  }

  Future<void> _addWeeklyGoal(UserProfile p) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final result = await _textDialog(
      title: l10n.settingsAddWeeklyGoalTitle,
      controller: ctrl,
      hint: l10n.settingsWeeklyGoalHint,
      capitalization: TextCapitalization.sentences,
    );
    ctrl.dispose();
    if (result == null || result.isEmpty) return;
    final updated = [...p.weeklyGoals, result];
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(weeklyGoals: updated));
  }

  Future<void> _removeWeeklyGoal(UserProfile p, String goal) async {
    final updated = p.weeklyGoals.where((g) => g != goal).toList();
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(weeklyGoals: updated));
  }

  // ── Lock method ───────────────────────────────────────────────────────────

  Future<void> _setLockNone(UserProfile p) async {
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString('lockMethod', 'none');
    // Delete both the modern (v2 salted) and legacy unsalted PIN hashes.
    await _storage.delete(key: PinHash.storageKey);
    await _storage.delete(key: PinHash.legacyKey);
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(lockMethod: 'none'));
    H.light();
  }

  Future<void> _setLockBiometric(UserProfile p) async {
    final l10n = AppLocalizations.of(context);
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final available = await _auth.getAvailableBiometrics();
      if (!supported || !canCheck || available.isEmpty) {
        if (mounted) {
          _showSnack(l10n.settingsBiometricNotSetUp);
        }
        return;
      }
      final authenticated = await _auth.authenticate(
        localizedReason: l10n.settingsBiometricConfirmReason,
        options:
            const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (!authenticated) return;
      final prefs = await ref.read(prefsProvider.future);
      await prefs.setString('lockMethod', 'biometric');
      await _storage.delete(key: PinHash.storageKey);
      await _storage.delete(key: PinHash.legacyKey);
      await ref
          .read(profileProvider.notifier)
          .patch((p) => p.copyWith(lockMethod: 'biometric'));
      H.light();
    } on PlatformException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'NotEnrolled' => l10n.settingsBiometricNotEnrolled,
        'NotAvailable' => l10n.settingsBiometricUnavailable,
        'LockedOut' => l10n.settingsBiometricLockedOut,
        'PermanentlyLockedOut' => l10n.settingsBiometricPermanentlyLockedOut,
        _ => l10n.settingsBiometricAuthFailed(e.message ?? e.code),
      };
      _showSnack(msg);
    }
  }

  Future<void> _setLockPin(UserProfile p) async {
    final pin = await _showPinSetup();
    if (pin == null) return;
    // PBKDF2-HMAC-SHA256 with 128-bit random salt and 150k iterations.
    // This is what makes a 4-digit PIN's hash impractical to brute-force
    // even if the secure-storage blob ever leaks.
    await PinHash.writeNew(_storage, pin);
    final prefs = await ref.read(prefsProvider.future);
    await prefs.setString('lockMethod', 'pin');
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(lockMethod: 'pin'));
    H.medium();
  }

  Future<String?> _showPinSetup() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _PinSetupDialog(),
    );
  }

  // ── Notification settings ─────────────────────────────────────────────────

  Future<void> _editNotifications() async {
    H.light();
    final l10n = AppLocalizations.of(context);
    final prefs = await ref.read(prefsProvider.future);
    // Tolerant parse: a malformed stored value (empty, missing colon, restored
    // from a partial backup) must not throw an unhandled future that leaves the
    // reminders sheet unable to open. Falls back to the supplied default.
    TimeOfDay parseTime(String s, TimeOfDay fallback) {
      final parts = s.split(':');
      if (parts.length != 2) return fallback;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) return fallback;
      return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
    }

    final morning = parseTime(
        prefs.getString('notif_morning') ?? '08:00', const TimeOfDay(hour: 8, minute: 0));
    final evening = parseTime(
        prefs.getString('notif_evening') ?? '20:00', const TimeOfDay(hour: 20, minute: 0));
    final motiv = prefs.getBool('notif_motivation') ?? true;
    final remind = prefs.getBool('notif_reminders') ?? true;
    final mileston = prefs.getBool('notif_milestones') ?? true;

    if (!mounted) return;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationsSheet(
        morningTime: morning,
        eveningTime: evening,
        motivation: motiv,
        reminders: remind,
        milestones: mileston,
      ),
    );
    if (result == null) return;

    final fmt = (TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    await prefs.setString('notif_morning', fmt(result['morning'] as TimeOfDay));
    await prefs.setString('notif_evening', fmt(result['evening'] as TimeOfDay));
    await prefs.setBool('notif_motivation', result['motivation'] as bool);
    await prefs.setBool('notif_reminders', result['reminders'] as bool);
    await prefs.setBool('notif_milestones', result['milestones'] as bool);

    // Re-request POST_NOTIFICATIONS before scheduling. On Android 13+ the
    // system prompt is only shown the first time; subsequent calls return
    // the current grant state without re-prompting. We then ask the OS for
    // the *actual* enabled state via areNotificationsEnabled() — this is the
    // truthful check (covers system-level mute as well as denied permission).
    final wantAny = (result['motivation'] as bool) ||
        (result['reminders'] as bool) ||
        (result['milestones'] as bool);
    if (wantAny) {
      await NotificationService.requestPermission();
    }
    final enabled = await NotificationService.areNotificationsEnabled();

    // Schedule regardless — even if the OS reports "blocked" right now, the
    // schedules sit dormant and start firing the moment the user re-enables
    // notifications in system settings.
    final scheduleResult = await NotificationService.scheduleFromPrefs();

    if (!mounted) return;
    if (!scheduleResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          content: Text(
            l10n.settingsReminderScheduleFailed,
          ),
          backgroundColor: AppColors.honey500,
        ),
      );
    } else if (wantAny && !enabled) {
      // Permission is denied — offer a one-tap deep link to system settings,
      // since on Android 13+ the in-app prompt won't re-show after the first
      // denial.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        content: Text(l10n.settingsNotificationsBlockedSaved),
        action: SnackBarAction(
          label: l10n.settingsOpenSettingsAction,
          onPressed: NotificationService.openSystemNotificationSettings,
        ),
      ));
    } else {
      _showSnack(l10n.settingsNotificationSettingsSaved);
    }
  }

  void _handleVersionTap() {
    _versionTapCount++;
    if (_versionTapCount < 5 || _showDiagnostics) return;

    setState(() => _showDiagnostics = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).settingsDiagnosticsEnabled),
        backgroundColor: AppColors.forest700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      ),
    );
  }

  Future<void> _showScheduledNotifDiagnostic(BuildContext context) async {
    final result = await NotificationService.scheduleFromPrefs();
    final pending = await NotificationService.getPendingNotifications();
    final notificationsAllowed =
        await NotificationService.areNotificationsAllowedIfAvailable();
    final exactAlarmAllowed =
        await NotificationService.canScheduleExactAlarmsIfAvailable();
    final batteryStatus =
        await NotificationService.isIgnoringBatteryOptimizations();
    final timezoneName = NotificationService.localTimezoneNameIfAvailable();
    final timezoneNow = NotificationService.localTimezoneNowTextIfAvailable();

    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);

    String describeId(int id) {
      if (id == 1) return l10n.settingsDiagMorningReminder;
      if (id == 2) return l10n.settingsDiagEveningReminder;
      if (id == 99) return l10n.settingsDiagTestNotification;
      if (id >= 10000 && id < 20000) {
        return l10n.settingsDiagMilestoneDay(id - 10000);
      }
      if (id >= 20000 && id < 30000) return l10n.settingsDiagSavingsMilestone;
      if (id >= 30000) return l10n.settingsDiagMeetingReminder;
      return l10n.settingsDiagUnknownId(id);
    }

    final hasMorning = pending.any((n) => n.id == 1);
    final hasEvening = pending.any((n) => n.id == 2);

    String yesNoUnknown(bool? value) {
      if (value == true) return l10n.settingsDiagYes;
      if (value == false) return l10n.settingsDiagNo;
      return l10n.settingsDiagUnknown;
    }

    String batteryLabel(bool? value) {
      if (value == true) return l10n.settingsDiagNotRestricted;
      if (value == false) return l10n.settingsDiagRestricted;
      return l10n.settingsDiagUnknown;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsDiagScheduledNotificationsTitle,
                style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                result.success
                    ? l10n.settingsDiagSchedulerRanOk
                    : l10n.settingsDiagSchedulerError(result.error.toString()),
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      result.success ? AppColors.forest700 : AppColors.blush700,
                ),
              ),
              const SizedBox(height: 16),
              _DiagnosticLine(
                label: l10n.settingsDiagNotificationsAllowed,
                value: yesNoUnknown(notificationsAllowed),
              ),
              _DiagnosticLine(
                label: l10n.settingsDiagBatteryOptimization,
                value: batteryLabel(batteryStatus),
              ),
              _DiagnosticLine(
                label: l10n.settingsDiagExactAlarms,
                value: exactAlarmAllowed == true
                    ? l10n.settingsDiagAvailable
                    : exactAlarmAllowed == false
                        ? l10n.settingsDiagUnavailable
                        : l10n.settingsDiagUnknownNotApplicable,
              ),
              _DiagnosticLine(
                label: l10n.settingsDiagTimezone,
                value: timezoneName ?? l10n.settingsDiagUnknown,
              ),
              _DiagnosticLine(
                label: l10n.settingsDiagTimezoneNow,
                value: timezoneNow ?? l10n.settingsDiagUnknown,
              ),
              _DiagnosticLine(
                label: l10n.settingsDiagPendingCount,
                value: pending.length.toString(),
              ),
              _DiagnosticLine(
                label: l10n.settingsDiagMorningQueued,
                value: hasMorning ? l10n.settingsDiagYes : l10n.settingsDiagNo,
              ),
              _DiagnosticLine(
                label: l10n.settingsDiagEveningQueued,
                value: hasEvening ? l10n.settingsDiagYes : l10n.settingsDiagNo,
              ),
              const SizedBox(height: 16),
              if (pending.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.honey50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.honey200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.honey600,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.settingsDiagNoneScheduled,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.stone700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...pending.map(
                  (n) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.forest700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                describeId(n.id),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (n.body != null)
                                Text(
                                  n.body!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.mistGrey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: Text(l10n.settingsDiagSendTestNow),
                  onPressed: () async {
                    Navigator.pop(context);
                    final ok = await NotificationService.sendTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? l10n.settingsDiagTestSent
                                : l10n.settingsDiagTestFailed,
                          ),
                          backgroundColor:
                              ok ? AppColors.forest700 : AppColors.blush600,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.battery_alert_outlined, size: 18),
                  label: Text(l10n.settingsDiagOpenBatterySettings),
                  onPressed: () {
                    NotificationService.openBatteryOptimizationSettings();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<String?> _textDialog({
    required String title,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    final l10n = AppLocalizations.of(context);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
        title: Text(title, style: AppTextStyles.titleMedium),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          decoration: _inputDecor(hint),
          style: AppTextStyles.bodyMedium,
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.stone500)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.forest600),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.commonSave,
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone300),
        filled: true,
        fillColor: AppColors.stone50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.stone100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.stone100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.forest600, width: 1.5),
        ),
      );

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
      backgroundColor: AppColors.stone700,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    // Same 10-second provider as home screen so money always matches.
    final stats = ref.watch(soberMoneyProvider);

    return profileAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.stone50,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.forest600)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.stone50,
        body: Center(
            child: Text(AppLocalizations.of(context).homeErrorPrefix('$e'))),
      ),
      data: (profile) {
        // Router-level redirect handles null-profile (see main.dart).
        // Show a spinner if we somehow land here without one rather than
        // racing the router with our own context.go call.
        if (profile == null) {
          return Scaffold(
            backgroundColor: AppColors.stone50,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.forest600),
            ),
          );
        }
        return _buildContent(profile, stats);
      },
    );
  }

  Widget _buildContent(UserProfile profile, SoberStats? stats) {
    final l10n = AppLocalizations.of(context);
    final soberDate = DateTime.tryParse(profile.soberDate);
    final dateLabel =
        soberDate != null ? DateFormat('d MMMM yyyy').format(soberDate) : '—';
    final moneySaved = stats?.moneySaved ?? 0;
    final moneyLabel = profile.dailySpend > 0
        ? formatMoney(moneySaved, symbol: profile.currency)
        : null;

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          cacheExtent: 500,
          slivers: [
            // ── Top bar ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(l10n.settingsTitle,
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.forest700)),
              ),
            ),

            // ── Profile header card ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _ProfileHeader(
                  profile: profile,
                  dateLabel: dateLabel,
                  moneyLabel: moneyLabel,
                  pledgeStreak: profile.pledgeStreak,
                  onEditName: () => _editUsername(profile),
                  onEditDate: () => _editSoberDate(profile),
                  onEditSpend: () => _editDailySpend(profile),
                ),
              ),
            ),

            // ── Savings goal ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SectionLabel(l10n.settingsSavingsGoalLabel),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _SavingsGoalCard(
                  profile: profile,
                  stats: stats,
                  onEdit: () => _editSavingsGoal(profile),
                ),
              ),
            ),

            // ── Emergency contact ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SectionLabel(l10n.settingsEmergencyContactLabel),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _EmergencyContactCard(
                  profile: profile,
                  onEdit: () => _editEmergencyContact(profile),
                ),
              ),
            ),

            // ── My motivation ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SectionLabel(l10n.settingsMyMotivationLabel),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _MotivationSection(
                  icon: Icons.spa_outlined,
                  title: l10n.settingsReasonsToQuitTitle,
                  placeholder: l10n.settingsReasonsToQuitHint,
                  items: profile.myReasons,
                  onAdd: (v) => _addReason(profile, v),
                  onRemove: (i) => _removeReasonAt(profile, i),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _MotivationSection(
                  icon: Icons.thumb_up_alt_outlined,
                  title: l10n.settingsProsTitle,
                  placeholder: l10n.settingsProsHint,
                  items: profile.pros,
                  onAdd: (v) => _addPro(profile, v),
                  onRemove: (i) => _removeProAt(profile, i),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _MotivationSection(
                  icon: Icons.thumb_down_alt_outlined,
                  title: l10n.settingsConsTitle,
                  placeholder: l10n.settingsConsHint,
                  items: profile.cons,
                  onAdd: (v) => _addCon(profile, v),
                  onRemove: (i) => _removeConAt(profile, i),
                ),
              ),
            ),

            // ── Weekly goals ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SectionLabel(l10n.settingsWeeklyGoalsLabel),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _WeeklyGoalsCard(
                  goals: profile.weeklyGoals,
                  onAdd: () => _addWeeklyGoal(profile),
                  onRemove: (g) => _removeWeeklyGoal(profile, g),
                ),
              ),
            ),

            // ── App security ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SectionLabel(l10n.settingsAppSecurityLabel),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _SecurityCard(
                  current: profile.lockMethod,
                  onNone: () => _setLockNone(profile),
                  onBiometric: () => _setLockBiometric(profile),
                  onPin: () => _setLockPin(profile),
                ),
              ),
            ),

            // ── Notifications ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SectionLabel(l10n.settingsNotificationsLabel),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _NotificationsCard(
                  profile: profile,
                  onEditReminders: _editNotifications,
                ),
              ),
            ),
            if (_showDiagnostics) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _SectionLabel(l10n.settingsDiagnosticsLabel),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: SolidCard(
                    borderRadius: AppRadius.xl,
                    padding: EdgeInsets.zero,
                    child: _SettingsRow(
                      icon: Icons.schedule_outlined,
                      label: l10n.settingsCheckScheduledReminders,
                      value: l10n.settingsCheckScheduledRemindersSub,
                      onTap: () => _showScheduledNotifDiagnostic(context),
                    ),
                  ),
                ),
              ),
            ],

            // ── More (Records + Tools & App) ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _MoreCard(),
              ),
            ),

            // ── About ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: _SectionLabel(l10n.settingsAboutLabel),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: const _AboutCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Center(
                  child: TextButton(
                    key: const Key('settings_version_diagnostics_tap_target'),
                    onPressed: _handleVersionTap,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.stone400,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.settingsVersionLabel('6.1.0'),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.stone400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile header card ──────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.dateLabel,
    required this.moneyLabel,
    required this.pledgeStreak,
    required this.onEditName,
    required this.onEditDate,
    required this.onEditSpend,
  });

  final UserProfile profile;
  final String dateLabel;
  final String? moneyLabel;
  final int pledgeStreak;
  final VoidCallback onEditName;
  final VoidCallback onEditDate;
  final VoidCallback onEditSpend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Split on ANY whitespace run and drop empties: a plain split(' ') yields
    // '' for internal double-spaces (common on mobile keyboards), and ''[0]
    // throws RangeError — which would red-screen the whole Settings screen and
    // lock the user out of editing their name / sober date / lock setup.
    final nameWords = profile.username
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final initials = nameWords.isNotEmpty
        ? nameWords.take(2).map((w) => w[0].toUpperCase()).join()
        : '?';

    // Full-bleed forest banner — rows removed, all four corners round.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.forest700,
        borderRadius: AppRadius.luxury,
        border: Border.all(color: AppColors.forest600.withValues(alpha: 0.4)),
        boxShadow: AppShadows.luxury,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          GestureDetector(
            onTap: onEditName,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.forest500,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.forest400, width: 2),
              ),
              child: Center(
                child: Text(initials,
                    style:
                        AppTextStyles.titleLarge.copyWith(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // ── Name · date · spend chip · pledge streak ─────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onEditName,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.username.isNotEmpty
                              ? profile.username
                              : l10n.settingsYourName,
                          style: AppTextStyles.titleLarge
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      Icon(Icons.edit_outlined,
                          size: 14, color: AppColors.forest300),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Sober date — tappable to edit
                GestureDetector(
                  onTap: onEditDate,
                  child: Text(
                    l10n.settingsSoberSinceDate(dateLabel),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.forest200),
                  ),
                ),
                // Daily spend chip — tappable to edit
                if (profile.dailySpend > 0) ...[
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: onEditSpend,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.forest600.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.settingsDailySpendChip(
                          '${profile.currency}${profile.dailySpend.toStringAsFixed(0)}',
                        ),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.forest100),
                      ),
                    ),
                  ),
                ],
                // Pledge streak badge
                if (pledgeStreak > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.honey500.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.honey400.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            size: 12, color: AppColors.honey300),
                        const SizedBox(width: 4),
                        Text(
                          l10n.settingsPledgeStreakBadge(pledgeStreak),
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.honey200),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ── Money saved ──────────────────────────────────────────────
          if (moneyLabel != null) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(moneyLabel!,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.honey300)),
                Text(l10n.settingsSavedLabel,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.forest200)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Savings goal card ────────────────────────────────────────────────────────

class _SavingsGoalCard extends StatelessWidget {
  const _SavingsGoalCard({
    required this.profile,
    required this.stats,
    required this.onEdit,
  });
  final UserProfile profile;
  final SoberStats? stats;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasGoal = profile.savingsGoal != null && profile.savingsGoal! > 0;
    final saved = stats?.moneySaved ?? 0;
    final progress =
        hasGoal ? (saved / profile.savingsGoal!).clamp(0.0, 1.0) : 0.0;

    return SolidCard(
      borderRadius: AppRadius.xl,
      padding: EdgeInsets.zero,
      child: hasGoal
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              profile.savingsGoalName ??
                                  l10n.settingsSavingsGoalLabel,
                              style: AppTextStyles.titleSmall,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.forest600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: AppRadius.pill,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: AppColors.stone100,
                          color: AppColors.forest600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.settingsSavingsProgress(
                          formatMoney(saved, symbol: profile.currency),
                          formatMoney(profile.savingsGoal!,
                              symbol: profile.currency),
                        ),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppColors.stone100),
                _SettingsRow(
                  icon: Icons.edit_outlined,
                  label: l10n.settingsEditGoal,
                  onTap: onEdit,
                ),
              ],
            )
          : _SettingsRow(
              icon: Icons.flag_outlined,
              label: l10n.settingsSetSavingsGoal,
              value: l10n.settingsSetSavingsGoalSub,
              onTap: onEdit,
            ),
    );
  }
}

// ─── Emergency contact card ───────────────────────────────────────────────────

class _EmergencyContactCard extends StatelessWidget {
  const _EmergencyContactCard({required this.profile, required this.onEdit});
  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ec = profile.emergencyContact;

    return SolidCard(
      borderRadius: AppRadius.xl,
      padding: EdgeInsets.zero,
      child: ec != null
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.forest50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_outline_rounded,
                            color: AppColors.forest600, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ec.name, style: AppTextStyles.titleSmall),
                            Text(ec.phone,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.stone500)),
                          ],
                        ),
                      ),
                      // Call button
                      GestureDetector(
                        onTap: () => _call(ec.phone),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.forest600,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_rounded,
                              size: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Edit button
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.stone100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_outlined,
                              size: 16, color: AppColors.stone500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : _SettingsRow(
              icon: Icons.contact_emergency_outlined,
              label: l10n.settingsAddEmergencyContact,
              value: l10n.settingsAddEmergencyContactSub,
              onTap: onEdit,
            ),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ─── Motivation section (Reasons / Pros / Cons) ───────────────────────────────

class _MotivationSection extends StatefulWidget {
  const _MotivationSection({
    required this.icon,
    required this.title,
    required this.placeholder,
    required this.items,
    required this.onAdd,
    required this.onRemove,
  });
  final IconData icon;
  final String title;
  final String placeholder;
  final List<String> items;
  final void Function(String) onAdd;
  final void Function(int) onRemove;

  @override
  State<_MotivationSection> createState() => _MotivationSectionState();
}

class _MotivationSectionState extends State<_MotivationSection> {
  final _ctrl = TextEditingController();
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    // Start expanded when empty (so the add field is discoverable),
    // collapsed when the user already has items.
    _expanded = widget.items.isEmpty;
  }

  @override
  void didUpdateWidget(_MotivationSection old) {
    super.didUpdateWidget(old);
    // If items were just added from empty, keep expanded.
    if (old.items.isEmpty && widget.items.isNotEmpty) _expanded = true;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _ctrl.clear();
    H.light();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.items.length;

    return SolidCard(
      borderRadius: AppRadius.xl,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Collapsible header ──────────────────────────────────────────
          InkWell(
            onTap: () {
              H.selection();
              setState(() => _expanded = !_expanded);
            },
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : AppRadius.xl,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Icon(widget.icon, size: 16, color: AppColors.forest600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.title,
                        style: AppTextStyles.titleSmall
                            .copyWith(color: AppColors.forest700)),
                  ),
                  if (count > 0 && !_expanded) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.forest50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$count',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.forest600,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 6),
                  ],
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.stone400),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable body ─────────────────────────────────────────────
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            sizeCurve: Curves.easeInOutCubic,
            duration: const Duration(milliseconds: 260),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: AppColors.stone100),

                // Empty state
                if (widget.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                        AppLocalizations.of(context).settingsNoItemsYet,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.stone400,
                            fontStyle: FontStyle.italic)),
                  ),

                // Item rows
                for (int i = 0; i < widget.items.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: i < widget.items.length - 1
                        ? BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: AppColors.stone100)))
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.forest600,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(widget.items[i],
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.stone700)),
                        ),
                        GestureDetector(
                          onTap: () {
                            H.selection();
                            widget.onRemove(i);
                          },
                          child: Icon(Icons.close_rounded,
                              size: 16, color: AppColors.stone300),
                        ),
                      ],
                    ),
                  ),

                // Add row
                Divider(height: 1, color: AppColors.stone100),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          style: AppTextStyles.bodyMedium,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: widget.placeholder,
                            hintStyle: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.stone300),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _submit,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.forest600,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weekly goals card ────────────────────────────────────────────────────────

class _WeeklyGoalsCard extends StatelessWidget {
  const _WeeklyGoalsCard({
    required this.goals,
    required this.onAdd,
    required this.onRemove,
  });
  final List<String> goals;
  final VoidCallback onAdd;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SolidCard(
      borderRadius: AppRadius.xl,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < goals.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 18, color: AppColors.forest600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(goals[i], style: AppTextStyles.bodyMedium),
                  ),
                  GestureDetector(
                    onTap: () => onRemove(goals[i]),
                    child: Icon(Icons.close,
                        size: 16, color: AppColors.stone300),
                  ),
                ],
              ),
            ),
            if (i < goals.length - 1)
              Divider(
                  height: 1,
                  color: AppColors.stone100,
                  indent: 20,
                  endIndent: 20),
          ],
          if (goals.isNotEmpty)
            Divider(height: 1, color: AppColors.stone100),
          _SettingsRow(
            icon: Icons.add_circle_outline,
            iconColor: AppColors.forest600,
            label: l10n.settingsAddWeeklyGoalTitle,
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}

// ─── Security card ────────────────────────────────────────────────────────────

class _SecurityCard extends StatefulWidget {
  const _SecurityCard({
    required this.current,
    required this.onNone,
    required this.onBiometric,
    required this.onPin,
  });
  final String current;
  final VoidCallback onNone;
  final VoidCallback onBiometric;
  final VoidCallback onPin;

  @override
  State<_SecurityCard> createState() => _SecurityCardState();
}

class _SecurityCardState extends State<_SecurityCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SolidCard(
      borderRadius: AppRadius.xl,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Collapsible header
          InkWell(
            onTap: () {
              H.selection();
              setState(() => _expanded = !_expanded);
            },
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : AppRadius.xl,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 16, color: AppColors.forest600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.settingsLockMethodLabel,
                            style: AppTextStyles.titleSmall
                                .copyWith(color: AppColors.forest700)),
                        Text(
                          widget.current == 'none'
                              ? l10n.settingsLockNoneLabel
                              : widget.current == 'biometric'
                                  ? l10n.settingsLockBiometricLabel
                                  : l10n.settingsLockPinLabel,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.stone500),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.stone400),
                  ),
                ],
              ),
            ),
          ),
          // Expandable body
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            sizeCurve: Curves.easeInOutCubic,
            duration: const Duration(milliseconds: 260),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: Column(
              children: [
                Divider(height: 1, color: AppColors.stone100),
                _LockOption(
                  icon: Icons.lock_open_outlined,
                  label: l10n.settingsLockNoneLabel,
                  subtitle: l10n.settingsLockNoneSub,
                  selected: widget.current == 'none',
                  onTap: widget.onNone,
                  borderBottom: true,
                ),
                _LockOption(
                  icon: Icons.fingerprint_rounded,
                  label: l10n.settingsLockBiometricLabel,
                  subtitle: l10n.settingsLockBiometricSub,
                  selected: widget.current == 'biometric',
                  onTap: widget.onBiometric,
                  borderBottom: true,
                ),
                _LockOption(
                  icon: Icons.pin_outlined,
                  label: l10n.settingsLockPinLabel,
                  subtitle: l10n.settingsLockPinSub,
                  selected: widget.current == 'pin',
                  onTap: widget.onPin,
                ),
                // Data-recovery warning
                if (widget.current == 'pin' ||
                    widget.current == 'biometric') ...[
                  Divider(height: 1, color: AppColors.stone100),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 18, color: AppColors.honey500),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.current == 'pin'
                                ? l10n.settingsLockPinRecoveryWarning
                                : l10n.settingsLockBiometricRecoveryWarning,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.honey500, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockOption extends StatelessWidget {
  const _LockOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.borderBottom = false,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool borderBottom;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderBottom
          ? BorderRadius.zero
          : const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: borderBottom
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.stone100)),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.forest50 : AppColors.stone50,
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
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.forest600 : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.forest600 : AppColors.stone200,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── More links card ──────────────────────────────────────────────────────────

class _MoreCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Records group ──────────────────────────────────────────────────
        _SectionLabel(l10n.settingsRecordsGroupLabel),
        const SizedBox(height: 8),
        SolidCard(
          borderRadius: AppRadius.xl,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.bar_chart_outlined,
                label: l10n.settingsMyHistory,
                onTap: () => context.push('/history'),
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.grid_view_rounded,
                label: l10n.settingsHeatmapLabel,
                onTap: () => context.push('/heatmap'),
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.insights_outlined,
                label: l10n.settingsMoodCravingInsights,
                onTap: () {
                  ref.read(progressTabProvider.notifier).state = 1;
                  context.go('/progress');
                },
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.emoji_events_outlined,
                label: l10n.settingsMilestoneCards,
                onTap: () => context.push('/milestone'),
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.article_outlined,
                label: l10n.weeklySummaryTitle,
                value: l10n.settingsWeeklyCareSummarySub,
                onTap: () => context.push('/weekly-care-summary'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ── Tools & App group ──────────────────────────────────────────────
        _SectionLabel(l10n.settingsToolsAppGroupLabel),
        const SizedBox(height: 8),
        SolidCard(
          borderRadius: AppRadius.xl,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.psychology_outlined,
                label: l10n.settingsCbtThoughtTools,
                onTap: () => context.push('/cbt'),
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.mail_outline_rounded,
                label: l10n.letterTitle,
                onTap: () => context.push('/future-letter'),
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.checklist_rounded,
                label: l10n.settingsPreCravingPlan,
                onTap: () => context.push('/pre-craving-plan'),
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.people_outline_rounded,
                label: l10n.settingsRecoveryGroups,
                onTap: () => context.push('/groups'),
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.event_available_outlined,
                label: l10n.settingsMeetingPlanner,
                onTap: () => context.push('/meetings'),
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.phone_in_talk_outlined,
                iconColor: AppColors.blush500,
                label: l10n.crisisTitle,
                onTap: () => context.push('/crisis'),
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.backup_outlined,
                label: l10n.settingsBackupLabel,
                onTap: () => context.push('/backup'),
                borderBottom: true,
              ),
              _SettingsRow(
                icon: Icons.privacy_tip_outlined,
                label: l10n.settingsPrivacyLabel,
                onTap: () => context.push('/privacy'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Notifications card (collapsible) ────────────────────────────────────────

class _NotificationsCard extends ConsumerStatefulWidget {
  const _NotificationsCard({
    required this.profile,
    required this.onEditReminders,
  });
  final UserProfile profile;
  final VoidCallback onEditReminders;

  @override
  ConsumerState<_NotificationsCard> createState() => _NotificationsCardState();
}

class _NotificationsCardState extends ConsumerState<_NotificationsCard>
    with WidgetsBindingObserver {
  bool _expanded = false;

  // Tri-state: null = not yet checked, true = OS reports enabled,
  // false = OS reports blocked. Refreshed when the card expands and when
  // the app comes back to the foreground (covers the user toggling the
  // system switch and returning).
  bool? _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotificationStatus();
    }
  }

  Future<void> _refreshNotificationStatus() async {
    final enabled = await NotificationService.areNotificationsEnabled();
    if (!mounted) return;
    setState(() => _notificationsEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = widget.profile;
    return SolidCard(
      borderRadius: AppRadius.xl,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Collapsible header
          InkWell(
            onTap: () {
              H.selection();
              setState(() => _expanded = !_expanded);
            },
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : AppRadius.xl,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Icon(Icons.notifications_outlined,
                      size: 16, color: AppColors.forest600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.settingsNotificationsLabel,
                        style: AppTextStyles.titleSmall
                            .copyWith(color: AppColors.forest700)),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.stone400),
                  ),
                ],
              ),
            ),
          ),
          // Expandable body
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            sizeCurve: Curves.easeInOutCubic,
            duration: const Duration(milliseconds: 260),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: Column(
              children: [
                Divider(height: 1, color: AppColors.stone100),
                // ── Live status indicator ─────────────────────────────────
                // Shows the OS-level enabled state at a glance so the user
                // doesn't have to fire a test notification to find out their
                // reminders are blocked. Tapping the "Fix it" pill deep-links
                // straight to system → app → notifications.
                if (_notificationsEnabled != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(color: AppColors.stone100, width: 1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _notificationsEnabled!
                                ? AppColors.forest50
                                : AppColors.blush50,
                            borderRadius: AppRadius.sm,
                          ),
                          child: Icon(
                            _notificationsEnabled!
                                ? Icons.check_circle_outline_rounded
                                : Icons.notifications_off_outlined,
                            size: 18,
                            color: _notificationsEnabled!
                                ? AppColors.forest700
                                : AppColors.blush700,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _notificationsEnabled!
                                    ? l10n.settingsSystemNotifsEnabled
                                    : l10n.settingsSystemNotifsBlocked,
                                style: AppTextStyles.bodyMedium,
                              ),
                              Text(
                                _notificationsEnabled!
                                    ? l10n.settingsSystemNotifsEnabledSub
                                    : l10n.settingsSystemNotifsBlockedSub,
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.stone500),
                              ),
                            ],
                          ),
                        ),
                        if (!_notificationsEnabled!) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              H.selection();
                              await NotificationService
                                  .openSystemNotificationSettings();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.forest700,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.lg),
                              backgroundColor: AppColors.forest50,
                            ),
                            child: Text(
                              l10n.settingsFixItAction,
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.forest700,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                _SettingsRow(
                  icon: Icons.notifications_outlined,
                  label: l10n.settingsCheckInReminders,
                  value: l10n.settingsMorningEveningTimes,
                  onTap: widget.onEditReminders,
                  borderBottom: true,
                ),
                _SettingsRow(
                  icon: Icons.dark_mode_outlined,
                  label: l10n.settingsAppearance,
                  value: switch (ref.watch(themeModeProvider)) {
                    ThemeMode.light => l10n.settingsThemeLight,
                    ThemeMode.dark => l10n.settingsThemeDark,
                    ThemeMode.system => l10n.settingsThemeSystem,
                  },
                  onTap: _editAppearance,
                  borderBottom: true,
                ),
                // Language row. Hidden until a second language is enabled in
                // kSupportedLanguages — a one-option picker is pointless. It
                // lights up automatically the moment a real translation lands.
                if (kSupportedLanguages.length > 1)
                  _SettingsRow(
                    icon: Icons.language_outlined,
                    label: AppLocalizations.of(context).settingsLanguage,
                    value: _languageValueLabel(),
                    onTap: _editLanguage,
                    borderBottom: true,
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: AppColors.stone100, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.forest50,
                          borderRadius: AppRadius.sm,
                        ),
                        child: Icon(Icons.vibration_rounded,
                            size: 18, color: AppColors.forest700),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(l10n.settingsHapticFeedback,
                            style: AppTextStyles.bodyMedium),
                      ),
                      Switch(
                        value: profile.hapticsEnabled,
                        onChanged: (val) {
                          H.sync(val);
                          ref.read(profileProvider.notifier).patch(
                                (p) => p.copyWith(hapticsEnabled: val),
                              );
                        },
                        activeColor: AppColors.forest600,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.forest50,
                          borderRadius: AppRadius.sm,
                        ),
                        child: Icon(Icons.straighten_rounded,
                            size: 18, color: AppColors.forest700),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.settingsImperialUnits,
                                style: AppTextStyles.bodyMedium),
                            Text(
                              l10n.settingsImperialUnitsSub,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.stone500),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: profile.useImperial,
                        onChanged: (val) {
                          H.selection();
                          ref.read(profileProvider.notifier).patch(
                                (p) => p.copyWith(useImperial: val),
                              );
                        },
                        activeColor: AppColors.forest600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editAppearance() async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(themeModeProvider);
    final picked = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
        title: Text(l10n.settingsAppearance, style: AppTextStyles.titleMedium),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (mode, label, hint) in [
              (
                ThemeMode.light,
                l10n.settingsThemeLight,
                l10n.settingsThemeLightHint
              ),
              (
                ThemeMode.dark,
                l10n.settingsThemeDark,
                l10n.settingsThemeDarkHint
              ),
              (
                ThemeMode.system,
                l10n.settingsThemeSystem,
                l10n.settingsThemeSystemHint
              ),
            ])
              RadioListTile<ThemeMode>(
                value: mode,
                groupValue: current,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: Text(label, style: AppTextStyles.bodyMedium),
                subtitle: Text(hint,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.stone500)),
                activeColor: AppColors.forest600,
                dense: true,
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      H.selection();
      await ref.read(themeModeProvider.notifier).set(picked);
    }
  }

  /// Display value for the Language settings row — the chosen language's
  /// endonym, or "System default" when following the device.
  String _languageValueLabel() {
    final code = ref.watch(localeProvider)?.languageCode;
    if (code != null) {
      for (final lang in kSupportedLanguages) {
        if (lang.locale.languageCode == code) return lang.nativeName;
      }
    }
    return AppLocalizations.of(context).settingsLanguageSystem;
  }

  Future<void> _editLanguage() async {
    final l10n = AppLocalizations.of(context);
    // '' represents "follow the device language" (null locale).
    final current = ref.read(localeProvider)?.languageCode ?? '';
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
        title: Text(l10n.settingsLanguage, style: AppTextStyles.titleMedium),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: '',
              groupValue: current,
              onChanged: (v) => Navigator.pop(ctx, v),
              title: Text(l10n.settingsLanguageSystem,
                  style: AppTextStyles.bodyMedium),
              activeColor: AppColors.forest600,
              dense: true,
            ),
            for (final lang in kSupportedLanguages)
              RadioListTile<String>(
                value: lang.locale.languageCode,
                groupValue: current,
                onChanged: (v) => Navigator.pop(ctx, v),
                title: Text(lang.nativeName, style: AppTextStyles.bodyMedium),
                activeColor: AppColors.forest600,
                dense: true,
              ),
          ],
        ),
      ),
    );
    if (picked != null && picked != current) {
      H.selection();
      await ref
          .read(localeProvider.notifier)
          .set(picked.isEmpty ? null : Locale(picked));
    }
  }
}

// ─── Notifications bottom sheet ──────────────────────────────────────────────

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet({
    required this.morningTime,
    required this.eveningTime,
    required this.motivation,
    required this.reminders,
    required this.milestones,
  });
  final TimeOfDay morningTime;
  final TimeOfDay eveningTime;
  final bool motivation;
  final bool reminders;
  final bool milestones;

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  late TimeOfDay _morning;
  late TimeOfDay _evening;
  late bool _motivation;
  late bool _reminders;
  late bool _milestones;

  @override
  void initState() {
    super.initState();
    _morning = widget.morningTime;
    _evening = widget.eveningTime;
    _motivation = widget.motivation;
    _reminders = widget.reminders;
    _milestones = widget.milestones;
  }

  Future<void> _pickTime(bool isMorning) async {
    H.selection();
    final picked = await showTimePicker(
      context: context,
      initialTime: isMorning ? _morning : _evening,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.forest600,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isMorning)
        _morning = picked;
      else
        _evening = picked;
    });
  }

  String _fmt(TimeOfDay t) {
    // Clock format + meridiem follow the device/locale (24-hour where that's
    // the convention) instead of a hardcoded English 12-hour "AM/PM".
    return MaterialLocalizations.of(context).formatTimeOfDay(
      t,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.stone50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.stone200, borderRadius: AppRadius.pill),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.settingsNotificationsLabel,
              style: AppTextStyles.titleMedium),
          const SizedBox(height: 2),
          Text(l10n.settingsCheckInReminderSchedule,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.stone500)),
          const SizedBox(height: 20),

          // Times
          SolidCard(
            borderRadius: AppRadius.xl,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SheetTimeRow(
                  icon: Icons.wb_sunny_outlined,
                  label: l10n.settingsMorningCheckIn,
                  value: _fmt(_morning),
                  onTap: () => _pickTime(true),
                  borderBottom: true,
                ),
                _SheetTimeRow(
                  icon: Icons.nights_stay_outlined,
                  label: l10n.settingsEveningReminder,
                  value: _fmt(_evening),
                  onTap: () => _pickTime(false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Toggles
          SolidCard(
            borderRadius: AppRadius.xl,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SheetToggleRow(
                  label: l10n.settingsMotivationMessages,
                  value: _motivation,
                  onChanged: (v) => setState(() => _motivation = v),
                  borderBottom: true,
                ),
                _SheetToggleRow(
                  label: l10n.settingsDailyReminders,
                  value: _reminders,
                  onChanged: (v) => setState(() => _reminders = v),
                  borderBottom: true,
                ),
                _SheetToggleRow(
                  label: l10n.settingsMilestoneAlerts,
                  value: _milestones,
                  onChanged: (v) => setState(() => _milestones = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Diagnostic: fire a test notification right now ───────────────
          // Lets the user verify the OS pipeline is actually live without
          // waiting until 08:00. If nothing pops up after pressing this,
          // the cause is almost always (a) POST_NOTIFICATIONS denied,
          // (b) Journey Forward muted in system notification settings, or
          // (c) an aggressive battery manager (Xiaomi/Samsung/Huawei)
          // killing background alarms.
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forest700,
                side: BorderSide(color: AppColors.forest300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
              ),
              onPressed: () async {
                H.selection();
                // Prompt for POST_NOTIFICATIONS first (Android 13+). On older
                // Android versions this is a no-op that returns true. We then
                // ALWAYS attempt show() — never gate on the prompt result,
                // because OEMs occasionally return false even when the post
                // succeeds, and the pre-Android-13 plugin returns null which
                // historically caused this button to never fire on legacy
                // devices.
                await NotificationService.requestPermission();
                final ok = await NotificationService.sendTestNotification();
                // The truthful permission state — used to decide whether to
                // offer the "Open Settings" recovery action when the test
                // doesn't appear.
                final enabled =
                    await NotificationService.areNotificationsEnabled();
                if (!context.mounted) return;
                if (ok && enabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(l10n.settingsTestSentShade),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 6),
                      content: Text(l10n.settingsTestCouldNotPost),
                      action: SnackBarAction(
                        label: l10n.settingsOpenSettingsAction,
                        onPressed:
                            NotificationService.openSystemNotificationSettings,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_outlined, size: 18),
              label: Text(
                l10n.settingsSendTestNotification,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.forest700),
              ),
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
              ),
              onPressed: () {
                H.medium();
                Navigator.pop(context, {
                  'morning': _morning,
                  'evening': _evening,
                  'motivation': _motivation,
                  'reminders': _reminders,
                  'milestones': _milestones,
                });
              },
              child: Text(AppLocalizations.of(context).commonSave,
                  style:
                      AppTextStyles.labelMedium.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTimeRow extends StatelessWidget {
  const _SheetTimeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.borderBottom = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool borderBottom;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: borderBottom
              ? BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.stone100)))
              : null,
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.forest600),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: AppTextStyles.titleSmall)),
              Text(value,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.forest600)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.stone300),
            ],
          ),
        ),
      );
}

class _SheetToggleRow extends StatelessWidget {
  const _SheetToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.borderBottom = false,
  });
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  final bool borderBottom;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: borderBottom
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.stone100)))
            : null,
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.stone700)),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.forest600,
            ),
          ],
        ),
      );
}

// ─── Shared row widget ────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.iconColor,
    this.value,
    this.onTap,
    this.borderBottom = false,
  });

  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool borderBottom;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: borderBottom
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.stone100)))
            : null,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.mintChip,
                borderRadius: AppRadius.md,
              ),
              child: Icon(icon, size: 18, color: iconColor ?? AppColors.forest700),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.titleSmall),
                  if (value != null)
                    Text(value!,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.stone300),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticLine extends StatelessWidget {
  const _DiagnosticLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mistGrey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.forest700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── About card ───────────────────────────────────────────────────────────────

class _AboutCard extends StatefulWidget {
  const _AboutCard();

  @override
  State<_AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<_AboutCard> {
  bool _expanded = false;

  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.journeyforward.journey_forward';

  Future<void> _shareApp() async {
    final uri = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SolidCard(
      borderRadius: AppRadius.xl,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Collapsible header
          InkWell(
            onTap: () {
              H.selection();
              setState(() => _expanded = !_expanded);
            },
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : AppRadius.xl,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.forest600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.settingsAboutTitle,
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.forest700),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.stone400),
                  ),
                ],
              ),
            ),
          ),
          // Expandable body
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            sizeCurve: Curves.easeInOutCubic,
            duration: const Duration(milliseconds: 260),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: AppColors.stone100),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsAboutBody,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.stone700,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () async {
                                final uri = Uri(
                                    scheme: 'mailto',
                                    path: 'shawn@journeyforward.app');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              child: Text(
                                'shawn@journeyforward.app',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.forest600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.forest600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              H.light();
                              await Clipboard.setData(const ClipboardData(
                                  text: 'shawn@journeyforward.app'));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                  content: Text(l10n.settingsEmailCopied),
                                  backgroundColor: AppColors.forest600,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.md),
                                ));
                            },
                            borderRadius: AppRadius.pill,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.forest50,
                                borderRadius: AppRadius.pill,
                                border: Border.all(color: AppColors.forest100),
                              ),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 14,
                                color: AppColors.forest600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.forest700,
                            side: BorderSide(
                                color: AppColors.forest200, width: 1.5),
                            backgroundColor: AppColors.forest50,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.xl),
                          ),
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: Text(
                            l10n.settingsShareApp,
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.forest700),
                          ),
                          onPressed: _shareApp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTextStyles.overline,
      );
}

// ─── Daily spend + currency dialog ───────────────────────────────────────────

class _SpendDialog extends StatefulWidget {
  const _SpendDialog({required this.controller, required this.initialCurrency});
  final TextEditingController controller;
  final String initialCurrency;

  @override
  State<_SpendDialog> createState() => _SpendDialogState();
}

class _SpendDialogState extends State<_SpendDialog> {
  late String _currency;

  static const _currencies = [
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
  ];

  @override
  void initState() {
    super.initState();
    _currency = widget.initialCurrency;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
      title: Text(l10n.settingsDailySpendLabel,
          style: AppTextStyles.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settingsSpendPerDayQuestion,
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: widget.controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '$_currency ',
              hintStyle:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.stone300),
              filled: true,
              fillColor: AppColors.stone50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide: BorderSide(color: AppColors.stone100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide: BorderSide(color: AppColors.stone100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide:
                    BorderSide(color: AppColors.forest600, width: 1.5),
              ),
            ),
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 14),
          Text(l10n.settingsCurrencyLabel, style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _currencies.map((c) {
              final sel = c == _currency;
              return GestureDetector(
                onTap: () => setState(() => _currency = c),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.forest600 : AppColors.stone50,
                    borderRadius: AppRadius.pill,
                    border: Border.all(
                        color: sel ? AppColors.forest600 : AppColors.stone100),
                  ),
                  child: Text(c,
                      style: AppTextStyles.labelMedium.copyWith(
                          color: sel ? Colors.white : AppColors.stone600)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).commonCancel,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.stone500)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.forest600),
          onPressed: () => Navigator.pop(context, {
            'spend': widget.controller.text.trim(),
            'currency': _currency,
          }),
          child: Text(AppLocalizations.of(context).commonSave,
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}

// ─── PIN setup dialog ─────────────────────────────────────────────────────────

class _PinSetupDialog extends StatefulWidget {
  const _PinSetupDialog();

  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  int _step = 0; // 0 = enter, 1 = confirm
  String _first = '';
  String _entered = '';
  String? _error;

  void _onDigit(String d) {
    if (_entered.length >= 4) return;
    H.selection();
    setState(() {
      _entered += d;
      _error = null;
    });
    if (_entered.length == 4) _onComplete();
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    H.selection();
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  void _onComplete() {
    if (_step == 0) {
      setState(() {
        _first = _entered;
        _entered = '';
        _step = 1;
      });
    } else {
      if (_entered == _first) {
        Navigator.pop(context, _entered);
      } else {
        H.heavy();
        setState(() {
          _entered = '';
          _error = AppLocalizations.of(context).onbPinMismatchError;
          _step = 0;
          _first = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
      title: Text(
          _step == 0 ? l10n.settingsSetAPin : l10n.onbPinConfirmButton,
          style: AppTextStyles.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              _step == 0
                  ? l10n.settingsEnter4DigitPin
                  : l10n.settingsEnterPinAgain,
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 20),
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                4,
                (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _entered.length
                            ? AppColors.forest600
                            : AppColors.stone100,
                      ),
                    )),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.blush500)),
          ],
          const SizedBox(height: 20),
          // Numpad
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', '⌫']
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row
                    .map((d) => _PinKey(
                        digit: d,
                        onTap: d == '⌫'
                            ? _onDelete
                            : d.isEmpty
                                ? null
                                : () => _onDigit(d)))
                    .toList(),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).commonCancel,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.stone500)),
        ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.digit, required this.onTap});
  final String digit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.stone50 : Colors.transparent,
          borderRadius: AppRadius.md,
          border: onTap != null ? Border.all(color: AppColors.stone100) : null,
        ),
        child: Center(
          child: Text(digit,
              style: AppTextStyles.titleMedium.copyWith(
                  color:
                      digit == '⌫' ? AppColors.blush400 : AppColors.stone800)),
        ),
      ),
    );
  }
}
