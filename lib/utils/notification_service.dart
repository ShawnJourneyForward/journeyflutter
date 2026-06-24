import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:flutter/widgets.dart' show Locale, WidgetsBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../l10n/app_locales.dart'; // for kSupportedLanguages (enabled langs)
import '../providers/app_providers.dart'; // for LocaleNotifier.prefsKey

class NotifScheduleResult {
  final bool success;
  final String? error;

  const NotifScheduleResult._({
    required this.success,
    this.error,
  });

  factory NotifScheduleResult.ok() =>
      const NotifScheduleResult._(success: true);

  factory NotifScheduleResult.failed(String e) =>
      NotifScheduleResult._(success: false, error: e);
}

/// Centralised notification helper for Journey Forward.
///
/// Notification ID space (disjoint ranges — must never overlap):
///   1            = morning motivation / reminder (repeating daily)
///   2            = evening motivation / reminder (repeating daily)
///   10000–19999  = day milestones  (10000 + sober-day count, capped at 9999 days)
///   20000–20999  = savings tiers   (20000 + tier index)
///   30000–39999  = scheduled meeting reminders (30000 + slot index)
///
/// History: the previous layout used 500+days and 600+tier, which collided at
/// day 100 (500+100=600 = 600+0=$50-tier), causing one of the two notifications
/// to silently overwrite the other on the user's device.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  // ── Android channel ───────────────────────────────────────────────────────

  static const _channelId = 'journey_forward_main';
  static const _channelName = 'Journey Forward';
  // English fallback for the per-notification channelDescription field (not
  // user-visible once the channel exists — Android shows the CHANNEL's stored
  // description, set at creation in init() in the user's language).
  static const _channelDesc = 'Daily reminders and milestone alerts';

  // ── Milestone constants ───────────────────────────────────────────────────

  static const _milestoneDays = [
    1, 2, 3, 5, 7, 10, 14, 21, 30, 60, 90, 180, 365, 730, 1095,
  ];
  static const _savingsTiers = [50, 100, 250, 500, 1000, 2500, 5000, 10000];

  static Map<int, String> _milestoneMessages(AppLocalizations l) => {
        1: l.notifMilestone1d,
        2: l.notifMilestone2d,
        3: l.notifMilestone3d,
        5: l.notifMilestone5d,
        7: l.notifMilestone7d,
        10: l.notifMilestone10d,
        14: l.notifMilestone14d,
        21: l.notifMilestone21d,
        30: l.notifMilestone30d,
        60: l.notifMilestone60d,
        90: l.notifMilestone90d,
        180: l.notifMilestone180d,
        365: l.notifMilestone365d,
        730: l.notifMilestone730d,
        1095: l.notifMilestone1095d,
      };

  // ── Motivational copy ─────────────────────────────────────────────────────

  static List<String> _morningReminders(AppLocalizations l) => [
        l.notifMorning0,
        l.notifMorning1,
        l.notifMorning2,
        l.notifMorning3,
        l.notifMorning4,
      ];

  static List<String> _eveningReminders(AppLocalizations l) => [
        l.notifEvening0,
        l.notifEvening1,
        l.notifEvening2,
        l.notifEvening3,
        l.notifEvening4,
      ];

  // ── Localization helper (no BuildContext available in a static service) ────
  //
  // Loads AppLocalizations for the user's chosen language. Mirrors the locale
  // resolution used by LocaleNotifier: an explicit 'app_locale' pref overrides
  // the platform locale; falls back to English if loading the chosen locale
  // fails for any reason.
  static Future<AppLocalizations> _l10n() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(LocaleNotifier.prefsKey); // 'app_locale'
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    // Resolve to an ENABLED language only — the same set the UI ships
    // (kSupportedLanguages). Loading off the raw device/pref locale would push
    // notifications in a language whose .arb stub merely exists but isn't yet
    // enabled, so the user would get (say) Spanish alerts under an English UI.
    final enabled =
        kSupportedLanguages.map((l) => l.locale.languageCode).toSet();
    final String langCode;
    if (code != null && code.isNotEmpty && enabled.contains(code)) {
      langCode = code;
    } else if (enabled.contains(device.languageCode)) {
      langCode = device.languageCode;
    } else {
      langCode = 'en';
    }
    try {
      return await AppLocalizations.delegate.load(Locale(langCode));
    } catch (_) {
      return await AppLocalizations.delegate.load(const Locale('en'));
    }
  }

  // ── Initialise ───────────────────────────────────────────────────────────

  /// Call once from main() before runApp().
  ///
  /// MUST NOT throw — main() awaits this before runApp(), so any uncaught
  /// exception here results in a permanent blank/white screen on launch.
  /// All failure paths are swallowed; notifications simply won't fire until
  /// the next successful init.
  static Future<void> init() async {
    try {
      const androidInit = AndroidInitializationSettings('ic_stat_notify');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );

      // Create the Android channel so notifications can be posted. Resolve the
      // description in the user's language (this is the one shown in the system
      // notification settings; Android caches it after first creation).
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      String channelDesc = _channelDesc;
      try {
        channelDesc = (await _l10n()).notifChannelDescription;
      } catch (_) {/* fall back to English const */}
      await androidImpl?.createNotificationChannel(AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: channelDesc,
        importance: Importance.high, // heads-up banner on Android
        playSound: true,
        enableVibration: true,
      ));
    } catch (e, st) {
      debugPrint('[NotificationService] init failed: $e\n$st');
    }
  }

  // ── Milestones toggle (kept in sync by scheduleFromPrefs) ────────────────
  static bool _milestonesEnabled = true;

  // ── Exact-alarm capability ───────────────────────────────────────────────
  //
  // Android 12+ gates SCHEDULE_EXACT_ALARM behind a runtime check. On a fresh
  // Android 14+ install the system may deny it by default; using
  // exactAllowWhileIdle without permission causes zonedSchedule to throw and
  // the user's reminders silently stop firing. Recovery reminders don't need
  // second-precision, so we fall back to inexactAllowWhileIdle when exact
  // alarms aren't available. Cached per process so we don't hit the platform
  // channel on every schedule call.
  static bool? _canScheduleExactCached;

  static Future<AndroidScheduleMode> _bestScheduleMode() async {
    if (_canScheduleExactCached == null) {
      try {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        _canScheduleExactCached =
            await android?.canScheduleExactNotifications() ?? false;
      } catch (_) {
        _canScheduleExactCached = false;
      }
    }
    return _canScheduleExactCached!
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  // ── Permission request ───────────────────────────────────────────────────
  //
  // On Android 13+ (API 33+) POST_NOTIFICATIONS is a runtime permission and
  // requestNotificationsPermission() returns true/false based on the user's
  // response.
  //
  // On Android 12 and below the permission doesn't exist — the plugin call
  // returns null. Treating null as "denied" was the root cause of the
  // launch-blocker: the Settings "Send test notification" button gated the
  // actual show() call on this return value, so older devices got a permanent
  // "Test failed" toast even though their notifications would have fired fine.
  // Fix: a null result means "no permission needed", which is effectively
  // granted. Return true in that case so callers don't short-circuit.
  static Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return true; // iOS or no platform impl
      final granted = await android.requestNotificationsPermission();
      // null = pre-Android-13, no runtime permission required
      return granted ?? true;
    } catch (e) {
      debugPrint('[NotificationService] requestPermission error: $e');
      return false;
    }
  }

  // ── Permission status (non-prompting check) ──────────────────────────────
  //
  // Surfaces the actual OS-level enabled state so Settings can display a
  // truthful "Enabled / Blocked" indicator without re-prompting the user.
  // Returns true on iOS / unknown platforms (assume best-case so the UI
  // doesn't show false alarms).
  static Future<bool> areNotificationsEnabled() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return true;
      final enabled = await android.areNotificationsEnabled();
      return enabled ?? true;
    } catch (e) {
      debugPrint('[NotificationService] areNotificationsEnabled error: $e');
      return false;
    }
  }

  // ── Deep-link to system app-notification settings ────────────────────────
  //
  // Used when permission is denied — Android 13+ won't re-prompt after the
  // first denial, so the only recovery path is for the user to flip the
  // toggle in system settings. The MethodChannel is implemented in
  // MainActivity.kt; if the bridge fails (e.g. iOS), we silently no-op.
  static const _settingsChannel =
      MethodChannel('com.journeyforward/app_settings');
  static const _batteryChannel =
      MethodChannel('com.journeyforward/battery_opt');

  static Future<void> openSystemNotificationSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _settingsChannel.invokeMethod('openNotificationSettings');
    } on PlatformException catch (e) {
      debugPrint(
          '[NotificationService] openNotificationSettings error: ${e.message}');
    } catch (e) {
      debugPrint('[NotificationService] openNotificationSettings error: $e');
    }
  }

  // ── Schedule daily reminders ─────────────────────────────────────────────

  /// Read saved preferences and (re-)schedule all daily reminders.
  /// Safe to call on every app launch ? it cancels then re-creates.
  static Future<NotifScheduleResult> scheduleFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Timezone guard: if main() failed to set tz.local, recover here before
      // scheduling. A silent UTC fallback is worse than no reminder because it
      // fires at the wrong wall-clock time and looks random to the user.
      final localName = localTimezoneNameIfAvailable();
      if (localName == null || localName == 'UTC') {
        try {
          final detected = await FlutterTimezone.getLocalTimezone();
          if (detected.isNotEmpty && detected != 'UTC') {
            tz.setLocalLocation(tz.getLocation(detected));
          }
        } catch (e) {
          return NotifScheduleResult.failed(
            'Timezone recovery failed. Still UTC. Error: $e',
          );
        }

        final recoveredName = localTimezoneNameIfAvailable();
        if (recoveredName == null || recoveredName == 'UTC') {
          return NotifScheduleResult.failed(
            'Timezone is still UTC after recovery attempt.',
          );
        }
      }

      final l = await _l10n();

      final morningStr = prefs.getString('notif_morning') ?? '08:00';
      final eveningStr = prefs.getString('notif_evening') ?? '20:00';
      final wantMotiv = prefs.getBool('notif_motivation') ?? true;
      final wantRemind = prefs.getBool('notif_reminders') ?? true;
      // Milestones toggle ? read here so the Settings pref actually does something.
      // fireDayMilestone / fireSavingsMilestone check this before posting.
      _milestonesEnabled = prefs.getBool('notif_milestones') ?? true;

      // Cancel old scheduled reminders before re-scheduling.
      await _plugin.cancel(1);
      await _plugin.cancel(2);

      if (!wantMotiv && !wantRemind) {
        return NotifScheduleResult.ok(); // nothing to schedule
      }

      final morningTime = _parseTime(morningStr);
      final eveningTime = _parseTime(eveningStr);

      // Pick a stable body text based on today's date so repeated
      // launches don't re-roll different text.
      final dayIndex = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
      final morningList = _morningReminders(l);
      final eveningList = _eveningReminders(l);
      final morningBody = morningList[dayIndex % morningList.length];
      final eveningBody = eveningList[dayIndex % eveningList.length];

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: 'ic_stat_notify',
          color: const Color(0xFF2D6A4F),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
        ),
      );

      final scheduleMode = await _bestScheduleMode();

      if (wantMotiv) {
        // Morning motivation notification (ID 1)
        await _plugin.zonedSchedule(
          1,
          l.appTitle,
          morningBody,
          _nextInstanceOf(morningTime.hour, morningTime.minute),
          details,
          androidScheduleMode: scheduleMode,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      if (wantRemind) {
        // Evening reminder notification (ID 2)
        await _plugin.zonedSchedule(
          2,
          l.appTitle,
          eveningBody,
          _nextInstanceOf(eveningTime.hour, eveningTime.minute),
          details,
          androidScheduleMode: scheduleMode,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      debugPrint(
        '[NotificationService] Scheduled ${wantMotiv ? 'morning @ $morningStr' : 'morning off'}, '
        '${wantRemind ? 'evening @ $eveningStr' : 'evening off'}',
      );
      return NotifScheduleResult.ok();
    } catch (e, st) {
      debugPrint('[NotificationService] scheduleFromPrefs error: $e');
      debugPrint('$st');
      return NotifScheduleResult.failed(e.toString());
    }
  }

  // ── Milestone notifications ──────────────────────────────────────────────

  static Future<void> fireDayMilestone(int days) async {
    if (!_milestonesEnabled) return;
    if (!_milestoneDays.contains(days)) return;
    final l = await _l10n();
    final msg = _milestoneMessages(l)[days];
    if (msg == null) return;

    try {
      await _plugin.show(
        10000 + days,
        l.notifMilestoneTitle,
        msg,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: 'ic_stat_notify',
            color: const Color(0xFF2D6A4F),
          ),
          iOS: const DarwinNotificationDetails(
              presentAlert: true, presentSound: true),
        ),
      );
    } catch (e) {
      debugPrint('[NotificationService] fireDayMilestone error: $e');
    }
  }

  static Future<void> fireSavingsMilestone(int tier, String currency) async {
    if (!_milestonesEnabled) return;
    if (!_savingsTiers.contains(tier)) return;
    final l = await _l10n();
    final tierIndex = _savingsTiers.indexOf(tier);
    final fmt = '$currency${tier.toStringAsFixed(0)}';
    final body = l.notifSavingsBody(fmt);

    try {
      await _plugin.show(
        20000 + tierIndex,
        l.notifSavingsTitle,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: 'ic_stat_notify',
            color: const Color(0xFF2D6A4F),
          ),
          iOS: const DarwinNotificationDetails(
              presentAlert: true, presentSound: true),
        ),
      );
    } catch (e) {
      debugPrint('[NotificationService] fireSavingsMilestone error: $e');
    }
  }

  // ── Meeting reminders (one-shot, scheduled) ──────────────────────────────

  /// Derive a stable 30000-range notification ID from a meeting's string ID
  /// so update/cancel can find the same slot reliably.
  static int meetingNotificationId(String meetingId) {
    // Fold the string into a stable non-negative int in [0, 9999].
    var h = 0;
    for (final code in meetingId.codeUnits) {
      h = ((h * 31) + code) & 0x7fffffff;
    }
    return 30000 + (h % 10000);
  }

  /// Schedule (or re-schedule) a one-shot meeting reminder. Safe to call
  /// repeatedly with the same meetingId — it cancels the prior slot first.
  /// Silently no-ops if the trigger time is in the past or notifications fail.
  static Future<void> scheduleMeetingReminder({
    required String meetingId,
    required String title,
    required DateTime when,
    required int minutesBefore,
    String? location,
  }) async {
    final id = meetingNotificationId(meetingId);
    try {
      await _plugin.cancel(id);
      final fireAt = when.subtract(Duration(minutes: minutesBefore));
      if (!fireAt.isAfter(DateTime.now())) return; // past — nothing to fire
      final l = await _l10n();
      final tzWhen = tz.TZDateTime.from(fireAt, tz.local);
      final timeLabel =
          '${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}';
      final body = location == null || location.isEmpty
          ? l.notifMeetingBody(title, timeLabel)
          : l.notifMeetingBodyLocation(title, timeLabel, location);
      await _plugin.zonedSchedule(
        id,
        l.notifMeetingTitle,
        body,
        tzWhen,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: 'ic_stat_notify',
            color: const Color(0xFF2D6A4F),
          ),
          iOS: const DarwinNotificationDetails(
              presentAlert: true, presentSound: true),
        ),
        androidScheduleMode: await _bestScheduleMode(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('[NotificationService] scheduleMeetingReminder error: $e');
    }
  }

  static Future<void> cancelMeetingReminder(String meetingId) async {
    try {
      await _plugin.cancel(meetingNotificationId(meetingId));
    } catch (e) {
      debugPrint('[NotificationService] cancelMeetingReminder error: $e');
    }
  }

  // ── Travel / DST: re-detect device timezone and re-schedule ──────────────
  //
  // Background:
  //   tz.local is set ONCE from main() at app startup. If the user travels
  //   across timezones (or the OS adjusts the zone for any reason) without
  //   killing the app, the previously-scheduled morning/evening reminders
  //   keep firing at the old wall-clock time. `matchDateTimeComponents.time`
  //   anchors the *original* tz, not the device's current one.
  //
  // Fix:
  //   Call this on AppLifecycleState.resumed. If the detected IANA zone
  //   differs from tz.local.name, switch tz.local and re-run scheduleFromPrefs
  //   so the next 08:00 / 20:00 fires at the new location's wall-clock time.
  //   No-op when the zone hasn't changed, so it's cheap to call on every
  //   resume.
  static Future<void> refreshTimezoneAndReschedule() async {
    try {
      final detected = await FlutterTimezone.getLocalTimezone();
      if (detected.isEmpty) return;
      if (detected == tz.local.name) return; // nothing changed
      tz.setLocalLocation(tz.getLocation(detected));
      debugPrint(
          '[NotificationService] timezone changed → $detected, re-scheduling');
      final result = await scheduleFromPrefs();
      if (!result.success) {
        debugPrint(
          '[NotificationService] timezone refresh schedule failed: ${result.error}',
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] refreshTimezone error: $e');
    }
  }

  // ── Diagnostic: fire a test notification right now ───────────────────────
  //
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('[NotificationService] getPendingNotifications error: $e');
      return [];
    }
  }

  static Future<bool?> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;

    try {
      return await _batteryChannel.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      );
    } catch (e) {
      debugPrint('[NotificationService] battery check error: $e');
      return null;
    }
  }

  static Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;

    try {
      await _batteryChannel.invokeMethod('openBatteryOptimizationSettings');
    } catch (e) {
      debugPrint('[NotificationService] open battery settings error: $e');
    }
  }

  static Future<bool?> areNotificationsAllowedIfAvailable() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return true;
      return await android.areNotificationsEnabled();
    } catch (e) {
      debugPrint(
          '[NotificationService] areNotificationsAllowedIfAvailable error: $e');
      return null;
    }
  }

  static Future<bool?> canScheduleExactAlarmsIfAvailable() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return null;
      return await android.canScheduleExactNotifications();
    } catch (e) {
      debugPrint(
          '[NotificationService] canScheduleExactAlarmsIfAvailable error: $e');
      return null;
    }
  }

  static String? localTimezoneNameIfAvailable() {
    try {
      return tz.local.name;
    } catch (_) {
      return null;
    }
  }

  static String? localTimezoneNowTextIfAvailable() {
    try {
      return tz.TZDateTime.now(tz.local).toString();
    } catch (_) {
      return null;
    }
  }

  // Exposed via Settings → Notifications so the user can verify the whole
  // pipeline (permission → channel → OS scheduler) without waiting until
  // 08:00. Returns false if the OS rejected the post — usually permission
  // denied or the channel is muted at the system level.
  static Future<bool> sendTestNotification() async {
    try {
      final l = await _l10n();
      await _plugin.show(
        99, // dedicated test ID — won't collide with any scheduled range
        l.appTitle,
        l.notifTestBody,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: 'ic_stat_notify',
            color: const Color(0xFF2D6A4F),
          ),
          iOS: const DarwinNotificationDetails(
              presentAlert: true, presentSound: true),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('[NotificationService] sendTestNotification error: $e');
      return false;
    }
  }

  // ── Cancel all ───────────────────────────────────────────────────────────

  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[NotificationService] cancelAll error: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static ({int hour, int minute}) _parseTime(String s) {
    final parts = s.split(':');
    final h = int.tryParse(parts.elementAtOrNull(0) ?? '') ?? 8;
    final m = int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 0;
    return (hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  /// Computes the next occurrence of [hour]:[minute] in the device's local
  /// IANA timezone (tz.local, set from FlutterTimezone at app startup).
  ///
  /// Scheduling in tz.local — not tz.UTC — means [matchDateTimeComponents]
  /// repeats at the correct *wall-clock* time every day. DST transitions are
  /// handled automatically: when clocks spring forward or fall back the OS
  /// adjusts the underlying UTC trigger so the user still sees 08:00.
  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
