import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/utils/locale_format.dart';

void main() {
  group('parseDurationMinutes', () {
    test('plain integer minutes', () {
      expect(parseDurationMinutes('26'), 26);
      expect(parseDurationMinutes(' 5 '), 5);
      expect(parseDurationMinutes('0'), 0);
    });

    test('decimal minutes round to nearest whole minute', () {
      // The exact bug report: 4.03 km in "26.22" min was dropped by int.tryParse.
      expect(parseDurationMinutes('26.22'), 26);
      expect(parseDurationMinutes('26.6'), 27);
      expect(parseDurationMinutes('26,22'), 26); // comma decimal
    });

    test('mm:ss rounds to the nearest minute', () {
      expect(parseDurationMinutes('26:22'), 26); // 1582s → 26.4 → 26
      expect(parseDurationMinutes('26:40'), 27); // 1600s → 26.7 → 27
      expect(parseDurationMinutes('1:30'), 2); //   90s → 1.5  → 2 (round-half-up)
      expect(parseDurationMinutes('0:20'), 0);
    });

    test('empty / unparseable input returns null (treated as no time)', () {
      expect(parseDurationMinutes(''), isNull);
      expect(parseDurationMinutes('   '), isNull);
      expect(parseDurationMinutes('abc'), isNull);
      expect(parseDurationMinutes('26:'), isNull);
      expect(parseDurationMinutes('26:99'), isNull); // seconds out of range
      expect(parseDurationMinutes('1:2:3'), isNull); // not mm:ss
      expect(parseDurationMinutes('-5'), isNull);
    });
  });
}
