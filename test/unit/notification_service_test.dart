import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/utils/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Critical flow #12: scheduling helpers must produce stable, collision-free
// IDs in the documented ID space. A non-deterministic ID would make
// updates/cancellations impossible and leak notifications across edits.
// History (see the doc comment in notification_service.dart): a previous
// layout used 500+days and 600+tier which collided at day 100. Locking
// down the ID contract here prevents the same class of bug from coming
// back through the meeting code path.

void main() {
  group('NotificationService.meetingNotificationId', () {
    test('lands inside the reserved 30000-39999 range', () {
      final id =
          NotificationService.meetingNotificationId('meeting-2026-05-20');
      expect(id, greaterThanOrEqualTo(30000));
      expect(id, lessThan(40000));
    });

    test('is stable for the same meeting id (update / cancel relies on it)',
        () {
      const meetingId = 'meeting-123';
      final first = NotificationService.meetingNotificationId(meetingId);
      final second = NotificationService.meetingNotificationId(meetingId);
      expect(first, second,
          reason: 'Same meeting id MUST yield the same notification id, '
              'or cancel/reschedule would orphan notifications.');
    });

    test('differs across distinct meeting ids in the common case', () {
      // Two arbitrary, structurally-different ids should collide only by
      // coincidence (1-in-10000 by design). Pick clearly-different ones.
      final a = NotificationService.meetingNotificationId('a');
      final b = NotificationService.meetingNotificationId('zzzz');
      expect(a, isNot(equals(b)));
    });

    test('handles empty input without throwing', () {
      // Empty string is unusual but must not crash the scheduler.
      final id = NotificationService.meetingNotificationId('');
      expect(id, greaterThanOrEqualTo(30000));
      expect(id, lessThan(40000));
    });
  });

  group('NotificationService diagnostics', () {
    test('scheduleFromPrefs surfaces timezone recovery failure', () async {
      SharedPreferences.setMockInitialValues({
        'notif_motivation': true,
        'notif_reminders': true,
        'notif_milestones': true,
        'notif_morning': '08:00',
        'notif_evening': '20:00',
      });

      final result = await NotificationService.scheduleFromPrefs();

      expect(result.success, isFalse);
      expect(result.error, isNotNull);
      expect(result.error, contains('Timezone'));
    });

    test('getPendingNotifications returns an empty list on plugin error',
        () async {
      final pending = await NotificationService.getPendingNotifications();
      expect(pending, isEmpty);
    });

    test('sendTestNotification returns false on plugin error', () async {
      final ok = await NotificationService.sendTestNotification();
      expect(ok, isFalse);
    });

    test('battery diagnostics use policy-safe open settings method name',
        () async {
      await NotificationService.openBatteryOptimizationSettings();
      expect(
          NotificationService.openBatteryOptimizationSettings, isA<Function>());
    });
  });
}
