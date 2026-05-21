import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/future_letter.dart';
import 'package:journey_forward/models/hard_day.dart';
import 'package:journey_forward/models/thought_record.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

// Critical flows covered here:
//   • Future-letter unlock semantics (sealed letter cannot be read early)
//   • Hard-day idempotency (one record per calendar day, can't double-count)
//   • Craving pattern detection requires enough data (no spurious patterns)
//   • CognitiveDistortion catalogue lookup is stable

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installSecureStorageMock();
  });
  setUp(resetSecureStorageMock);

  group('FutureLetter', () {
    test('unlockedAt is false before unlockAt and true on/after', () {
      final letter = FutureLetter(
        id: '1',
        writtenAt: DateTime(2026, 1, 1),
        unlockAt: DateTime(2026, 6, 1),
        unlockDay: 152,
        body: 'hi',
      );
      expect(letter.unlockedAt(DateTime(2026, 5, 31)), isFalse);
      expect(letter.unlockedAt(DateTime(2026, 6, 1)), isTrue);
      expect(letter.unlockedAt(DateTime(2026, 6, 2)), isTrue);
    });

    test('toJson / fromJson round-trip preserves all fields', () {
      final letter = FutureLetter(
        id: 'abc',
        writtenAt: DateTime.utc(2026, 1, 1, 10, 30),
        unlockAt: DateTime.utc(2026, 6, 1, 10, 30),
        unlockDay: 152,
        body: 'be brave',
        opened: true,
      );
      final round =
          FutureLetter.fromJson(jsonDecode(jsonEncode(letter.toJson())));
      expect(round.id, letter.id);
      expect(round.writtenAt, letter.writtenAt);
      expect(round.unlockAt, letter.unlockAt);
      expect(round.unlockDay, letter.unlockDay);
      expect(round.body, letter.body);
      expect(round.opened, isTrue);
    });
  });

  group('HardDayNotifier', () {
    test('marking twice on the same day does not create two entries', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(hardDayProvider.future);
      await container.read(hardDayProvider.notifier).mark(note: 'first');
      await container.read(hardDayProvider.notifier).mark(note: 'second');

      final list = container.read(hardDayProvider).valueOrNull ?? [];
      expect(list, hasLength(1),
          reason:
              'Two marks on the same calendar day must collapse — the badge counts battles WON, not button presses.');
      expect(list.first.note, 'second',
          reason: 'Second mark overwrites the note rather than ignoring it.');
    });
  });

  group('CravingPattern detection', () {
    test('returns null when fewer than 5 cravings exist', () async {
      // Seed 4 cravings, all in the same window — still under threshold.
      final cravings = List.generate(
        4,
        (i) => {
          'id': 'c$i',
          'date': DateTime(2026, 5, 1 + i, 18).toIso8601String(),
          'intensity': 5,
        },
      );
      SharedPreferences.setMockInitialValues({
        'cravings': jsonEncode(cravings),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(cravingProvider.future);
      expect(container.read(cravingPatternProvider), isNull,
          reason: '4 data points is not a pattern — would be noise.');
    });

    test('surfaces the dominant weekday + window when data clusters', () async {
      // 6 cravings all on Fridays (weekday 5) between 18:00 and 19:59,
      // plus a few scattered to ensure the bucket actually wins.
      final cravings = [
        for (var i = 0; i < 6; i++)
          {
            'id': 'f$i',
            // Pick known Fridays in 2026: May 1, 8, 15, 22, 29, June 5
            'date': DateTime(2026, 5, 1 + (7 * i), 18, 30).toIso8601String(),
            'intensity': 6,
          },
        // Some noise so the test exercises bucket comparison.
        {
          'id': 'n1',
          'date': DateTime(2026, 5, 4, 9).toIso8601String(),
          'intensity': 3,
        },
        {
          'id': 'n2',
          'date': DateTime(2026, 5, 6, 11).toIso8601String(),
          'intensity': 3,
        },
      ];
      SharedPreferences.setMockInitialValues({
        'cravings': jsonEncode(cravings),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(cravingProvider.future);

      final pat = container.read(cravingPatternProvider);
      expect(pat, isNotNull);
      expect(pat!.weekday, 5, reason: 'May 1 2026 is a Friday → weekday 5');
      expect(pat.startHour, 18, reason: '18:30 → 18:00–20:00 window');
      expect(pat.count, 6);
      expect(pat.weekdayLabel, 'Friday');
      expect(pat.timeLabel, contains('pm'));
    });
  });

  group('CognitiveDistortion catalogue', () {
    test('byCode returns the matching entry for every known code', () {
      for (final d in CognitiveDistortion.all) {
        expect(CognitiveDistortion.byCode(d.code)?.name, d.name);
      }
    });
    test('byCode returns null for unknown codes', () {
      expect(CognitiveDistortion.byCode('not_a_real_code'), isNull);
    });
  });
}
