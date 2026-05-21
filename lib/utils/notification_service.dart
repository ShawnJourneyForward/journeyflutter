import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

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
  static const _channelDesc = 'Daily reminders and milestone alerts';

  static const _androidChannel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDesc,
    importance: Importance.high, // heads-up banner on Android
    playSound: true,
    enableVibration: true,
  );

  // ── Milestone constants ───────────────────────────────────────────────────

  static const _milestoneDays = [1, 7, 14, 30, 60, 90, 180, 365, 730, 1095];
  static const _savingsTiers = [50, 100, 250, 500, 1000, 2500, 5000, 10000];

  static const _milestoneMessages = {
    1: '1 Day Sober. The hardest step is the first. You did it.',
    7: '7 Days Sober. One full week clean — that\'s real strength.',
    14: '14 Days Sober. Two weeks. Your body is already healing.',
    30: '30 Days Sober. One month — you\'re building something real.',
    60: '60 Days Sober. Two months of fighting and winning.',
    90: '90 Days Sober. Three months. This is who you are now.',
    180: '180 Days Sober. Half a year. Unbelievable progress.',
    365: '1 Year Sober. 365 days. You are an inspiration.',
    730: '2 Years Sober. Two years of choosing yourself every single day.',
    1095: '3 Years Sober. Three years. You\'ve transformed your life.',
  };

  // ── Motivational copy ─────────────────────────────────────────────────────

  static const _morningReminders = [
    'Start your day strong — Check in and complete your missions.',
    'Good morning. Your streak is worth protecting today.',
    'One day at a time. You\'ve got this — check in now.',
    'Morning check-in time — Log your mood and set your intentions.',
    'Your sober journey continues today. Open the app and check in.',
  ];

  static const _eveningReminders = [
    'You\'ve made it through another day — Log your progress.',
    'Evening check-in — How did your day go? Log it and reflect.',
    'Don\'t forget to log today before it slips away.',
    'Great job today — Take a moment to reflect and log your day.',
    'Your streak is still going strong — Log tonight before you sleep.',
  ];

  // ── Initialise ───────────────────────────────────────────────────────────

  /// Call once from main() before runApp().
  ///
  /// MUST NOT throw — main() awaits this before runApp(), so any uncaught
  /// exception here results in a permanent blank/white screen on launch.
  /// All failure paths are swallowed; notifications simply won't fire until
  /// the next successful init.
  static Future<void> init() async {
    try {
      const androidInit =
          AndroidInitializationSettings('@drawable/ic_stat_notify');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );

      // Create the Android channel so notifications can be posted.
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(_androidChannel);
    } catch (e, st) {
      debugPrint('[NotificationService] init failed: $e\n$st');
    }
  }

  // ── Permission request ───────────────────────────────────────────────────

  static Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('[NotificationService] requestPermission error: $e');
      return false;
    }
  }

  // ── Schedule daily reminders ─────────────────────────────────────────────

  /// Read saved preferences and (re-)schedule all daily reminders.
  /// Safe to call on every app launch — it cancels then re-creates.
  static Future<void> scheduleFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final morningStr = prefs.getString('notif_morning') ?? '08:00';
      final eveningStr = prefs.getString('notif_evening') ?? '20:00';
      final wantMotiv = prefs.getBool('notif_motivation') ?? true;
      final wantRemind = prefs.getBool('notif_reminders') ?? true;

      // Cancel old scheduled reminders before re-scheduling.
      await _plugin.cancel(1);
      await _plugin.cancel(2);

      if (!wantMotiv && !wantRemind) return; // nothing to schedule

      final morningTime = _parseTime(morningStr);
      final eveningTime = _parseTime(eveningStr);

      // Pick a stable body text based on today's date so repeated
      // launches don't re-roll different text.
      final dayIndex = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
      final morningBody =
          _morningReminders[dayIndex % _morningReminders.length];
      final eveningBody =
          _eveningReminders[dayIndex % _eveningReminders.length];

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/ic_stat_notify',
          color: const Color(0xFF2D6A4F),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
        ),
      );

      // Morning notification (ID 1)
      await _plugin.zonedSchedule(
        1,
        'Journey Forward',
        morningBody,
        _nextInstanceOf(morningTime.hour, morningTime.minute),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Evening notification (ID 2)
      await _plugin.zonedSchedule(
        2,
        'Journey Forward',
        eveningBody,
        _nextInstanceOf(eveningTime.hour, eveningTime.minute),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint(
          '[NotificationService] Scheduled morning @ $morningStr, evening @ $eveningStr');
    } catch (e) {
      debugPrint('[NotificationService] scheduleFromPrefs error: $e');
    }
  }

  // ── Milestone notifications ──────────────────────────────────────────────

  static Future<void> fireDayMilestone(int days) async {
    if (!_milestoneDays.contains(days)) return;
    final msg = _milestoneMessages[days];
    if (msg == null) return;

    try {
      await _plugin.show(
        10000 + days,
        'Milestone Reached',
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
            icon: '@drawable/ic_stat_notify',
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
    if (!_savingsTiers.contains(tier)) return;
    final tierIndex = _savingsTiers.indexOf(tier);
    final fmt = '$currency${tier.toStringAsFixed(0)}';
    final body = 'You\'ve saved $fmt through sobriety. Keep going!';

    try {
      await _plugin.show(
        20000 + tierIndex,
        'Savings Milestone',
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
            icon: '@drawable/ic_stat_notify',
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
      final tzWhen = tz.TZDateTime.from(fireAt.toUtc(), tz.UTC);
      final timeLabel =
          '${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}';
      final body = location == null || location.isEmpty
          ? '$title at $timeLabel'
          : '$title at $timeLabel · $location';
      await _plugin.zonedSchedule(
        id,
        'Meeting reminder',
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
            icon: '@drawable/ic_stat_notify',
            color: const Color(0xFF2D6A4F),
          ),
          iOS: const DarwinNotificationDetails(
              presentAlert: true, presentSound: true),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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

  /// Computes the next UTC instant at which the device's local clock will
  /// show [hour]:[minute].
  ///
  /// Uses [DateTime.now()] (local wall-clock) rather than [tz.local] so that
  /// no native timezone-name plugin is required — the OS offset is baked in
  /// automatically via [DateTime.toUtc()].  The resulting [tz.TZDateTime] is
  /// in UTC, so [matchDateTimeComponents] repeats at the same UTC instant
  /// every day (i.e. the correct local time, stable unless the device moves
  /// to a different timezone, in which case the next [scheduleFromPrefs]
  /// call re-anchors it).
  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = DateTime.now(); // device local time
    var local = DateTime(now.year, now.month, now.day, hour, minute);
    if (local.isBefore(now)) {
      local = local.add(const Duration(days: 1));
    }
    final utc = local.toUtc();
    return tz.TZDateTime(
        tz.UTC, utc.year, utc.month, utc.day, utc.hour, utc.minute);
  }
}
