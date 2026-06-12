import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:journey_forward/utils/craving_insights.dart';
import 'package:journey_forward/utils/journey_types.dart';

CravingEntry _at(int hour, [int day = 1]) => CravingEntry(
      id: 'c$day-$hour-${DateTime(2026, 1, day, hour).millisecondsSinceEpoch}',
      date: DateTime(2026, 1, day, hour, 15),
      intensity: 5,
    );

void main() {
  group('topRiskWindow', () {
    test('finds an evening cluster', () {
      final entries = [
        // 8 of 10 cravings between 20:00 and 22:59
        _at(20, 1), _at(21, 1), _at(22, 2), _at(20, 3),
        _at(21, 4), _at(22, 5), _at(20, 6), _at(21, 7),
        // noise elsewhere
        _at(9, 2), _at(14, 3),
      ];
      final w = topRiskWindow(entries);
      expect(w, isNotNull);
      expect(w!.startHour, 20);
      expect(w.count, 8);
      expect(w.total, 10);
      expect(w.label, '8 PM–11 PM');
    });

    test('returns null below the minimum sample', () {
      final entries = [_at(20), _at(21), _at(22)];
      expect(topRiskWindow(entries), isNull);
    });

    test('returns null for uniform noise (no real pattern)', () {
      // 12 cravings spread evenly across the day — no 3-hour window can
      // hold 35%, so no pattern should be reported.
      final entries = [
        for (var h = 0; h < 24; h += 2) _at(h, h + 1),
      ];
      expect(entries.length, 12);
      expect(topRiskWindow(entries), isNull);
    });

    test('handles a wrap-around midnight window', () {
      final entries = [
        // 23:00–01:59 cluster (wraps midnight)
        _at(23, 1), _at(0, 2), _at(1, 2), _at(23, 3),
        _at(0, 4), _at(1, 5), _at(23, 6),
        // sparse rest
        _at(12, 3),
      ];
      final w = topRiskWindow(entries);
      expect(w, isNotNull);
      expect(w!.startHour, 23);
      expect(w.label, '11 PM–2 AM');
    });
  });

  group('journeyTypeFor', () {
    test('resolves known slugs', () {
      expect(journeyTypeFor('alcohol').slug, 'alcohol');
      expect(journeyTypeFor('gambling').slug, 'gambling');
    });

    test('falls back to other for unknown/empty/null', () {
      expect(journeyTypeFor('').slug, 'other');
      expect(journeyTypeFor(null).slug, 'other');
      expect(journeyTypeFor('floomp').slug, 'other');
    });

    test('every type has an ascending, non-empty benefit timeline', () {
      for (final t in kJourneyTypes) {
        expect(t.benefits, isNotEmpty, reason: t.slug);
        final days = t.benefits.map((b) => b.day).toList();
        final sorted = [...days]..sort();
        expect(days, sorted, reason: '${t.slug} timeline must be ascending');
      }
    });
  });
}
