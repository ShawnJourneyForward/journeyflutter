import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/providers/app_providers.dart';

void main() {
  group('ChallengeState.fromJson', () {
    test('empty / missing days → empty state', () {
      expect(ChallengeState.fromJson(const {}).completed, 0);
      expect(ChallengeState.fromJson(const {'days': {}}).startedAt, isNull);
    });

    test('parses string day keys into ints and keeps stickers', () {
      final s = ChallengeState.fromJson({
        'days': {'1': '✅', '7': '🔥', '100': '🏆'},
        'startedAt': DateTime(2026, 1, 1).toIso8601String(),
      });
      expect(s.completed, 3);
      expect(s.days[1], '✅');
      expect(s.days[7], '🔥');
      expect(s.days[100], '🏆');
      expect(s.startedAt, isNotNull);
    });

    test('drops out-of-range days, non-numeric keys and empty stickers', () {
      final s = ChallengeState.fromJson({
        'days': {
          '0': '✅', // below range
          '101': '✅', // above range
          'abc': '🔥', // non-numeric
          '5': '', // empty sticker
          '6': '🌱', // valid
        },
      });
      expect(s.completed, 1);
      expect(s.days.keys.single, 6);
    });

    test('tolerates a malformed days value without throwing', () {
      expect(ChallengeState.fromJson(const {'days': 'not a map'}).completed, 0);
      expect(ChallengeState.fromJson(const {'days': 42}).completed, 0);
    });

    test('round-trips through toJson', () {
      final original = ChallengeState(
        days: const {1: '✅', 50: '⭐'},
        startedAt: DateTime(2026, 2, 3, 4, 5, 6),
      );
      final back = ChallengeState.fromJson(original.toJson());
      expect(back.days, original.days);
      expect(back.startedAt, original.startedAt);
    });

    test('omits startedAt from json when null', () {
      final json = const ChallengeState(days: {1: '✅'}).toJson();
      expect(json.containsKey('startedAt'), isFalse);
      expect((json['days'] as Map)['1'], '✅');
    });
  });

  group('ChallengeState derived', () {
    test('progress and isComplete track completed / total', () {
      expect(const ChallengeState().progress, 0.0);
      expect(const ChallengeState().isComplete, isFalse);

      final half = ChallengeState(
          days: {for (var d = 1; d <= 50; d++) d: '✅'});
      expect(half.progress, closeTo(0.5, 1e-9));
      expect(half.isComplete, isFalse);

      final full = ChallengeState(
          days: {for (var d = 1; d <= 100; d++) d: '✅'});
      expect(full.progress, 1.0);
      expect(full.isComplete, isTrue);
    });
  });
}
