import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/user_profile.dart';

UserProfile _profile(DateTime soberDate, double dailySpend) => UserProfile(
      username: 'Shawn',
      soberDate: soberDate.toIso8601String(),
      dailySpend: dailySpend,
      currency: '\$',
    );

void main() {
  group('SoberStats moneySaved', () {
    final now = DateTime(2026, 5, 18, 12);

    test('daily spend 120 and 1 day elapsed equals 120 saved', () {
      final stats = SoberStats.compute(
        _profile(now.subtract(const Duration(days: 1)), 120),
        now,
      );

      expect(stats.moneySaved, closeTo(120, 0.0001));
    });

    test('daily spend 120 and 7 days elapsed equals 840 saved', () {
      final stats = SoberStats.compute(
        _profile(now.subtract(const Duration(days: 7)), 120),
        now,
      );

      expect(stats.moneySaved, closeTo(840, 0.0001));
    });

    test('daily spend 120 and 1 hour elapsed equals 5 saved', () {
      final stats = SoberStats.compute(
        _profile(now.subtract(const Duration(hours: 1)), 120),
        now,
      );

      expect(stats.moneySaved, closeTo(5, 0.0001));
    });

    test('zero daily spend returns 0 saved', () {
      final stats = SoberStats.compute(
        _profile(now.subtract(const Duration(days: 3)), 0),
        now,
      );

      expect(stats.moneySaved, 0);
    });

    test('future start date never returns negative saved amount', () {
      final stats = SoberStats.compute(
        _profile(now.add(const Duration(days: 1)), 120),
        now,
      );

      expect(stats.moneySaved, 0);
    });

    test('negative daily spend never returns negative saved amount', () {
      final stats = SoberStats.compute(
        _profile(now.subtract(const Duration(days: 1)), -120),
        now,
      );

      expect(stats.moneySaved, greaterThanOrEqualTo(0));
    });

    test('very large spend value does not crash', () {
      final stats = SoberStats.compute(
        _profile(now.subtract(const Duration(days: 365)), 999999999),
        now,
      );

      expect(stats.moneySaved, isA<double>());
      expect(stats.moneySaved.isFinite, isTrue);
    });

    test('decimal spend values keep cents safely', () {
      final stats = SoberStats.compute(
        _profile(now.subtract(const Duration(hours: 12)), 99.99),
        now,
      );

      expect(stats.moneySaved, closeTo(49.995, 0.0001));
    });
  });
}
