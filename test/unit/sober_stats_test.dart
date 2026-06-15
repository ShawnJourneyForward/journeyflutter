import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/user_profile.dart';

UserProfile _profile(DateTime soberDate) => UserProfile(
      username: 'Shawn',
      soberDate: soberDate.toIso8601String(),
    );

void main() {
  group('SoberStats.compute', () {
    final now = DateTime(2026, 5, 18, 12);

    test('start time now returns 0 days and is not a countdown', () {
      final stats = SoberStats.compute(_profile(now), now);

      expect(stats.days, 0);
      expect(stats.hours, 0);
      expect(stats.minutes, 0);
      expect(stats.seconds, 0);
      expect(stats.isCountdown, isFalse);
    });

    test('1 day ago returns 1 day', () {
      final stats = SoberStats.compute(
        _profile(now.subtract(const Duration(days: 1))),
        now,
      );

      expect(stats.days, 1);
    });

    test('7 days ago returns 7 days', () {
      final stats = SoberStats.compute(
        _profile(now.subtract(const Duration(days: 7))),
        now,
      );

      expect(stats.days, 7);
    });

    test('future quit date counts down to day one', () {
      final stats = SoberStats.compute(
        _profile(now.add(const Duration(days: 2, hours: 3))),
        now,
      );

      // Count-up fields stay clamped to 0 — sobriety hasn't started yet.
      expect(stats.days, 0);
      expect(stats.hours, 0);
      expect(stats.minutes, 0);
      expect(stats.seconds, 0);
      expect(stats.moneySaved, 0);

      // The countdown reflects the time remaining until the quit date.
      expect(stats.isCountdown, isTrue);
      expect(stats.untilDays, 2);
      expect(stats.untilHours, 3);
      expect(stats.untilMinutes, 0);
    });

    test('invalid sober date falls back safely', () {
      const profile = UserProfile(username: 'Shawn', soberDate: 'not-a-date');

      final stats = SoberStats.compute(profile, now);

      expect(stats.days, 0);
      expect(stats.hours, 0);
      expect(stats.minutes, 0);
      expect(stats.seconds, 0);
    });

    test('very old start date does not crash and day count is capped', () {
      final stats = SoberStats.compute(_profile(DateTime(1)), now);

      expect(stats.days, 99999);
      expect(stats.heartbeats, greaterThan(0));
      expect(stats.breaths, greaterThan(0));
    });
  });
}
