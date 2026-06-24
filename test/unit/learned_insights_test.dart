import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:journey_forward/utils/craving_insights.dart';

CravingEntry _c({
  int intensity = 5,
  String? trigger,
  List<String> triggers = const [],
  List<String> halt = const [],
  String? responseChosen,
  String? outcome,
}) =>
    CravingEntry(
      id: 'x',
      date: DateTime(2026, 1, 1, 20),
      intensity: intensity,
      trigger: trigger,
      triggers: triggers,
      halt: halt,
      responseChosen: responseChosen,
      outcome: outcome,
    );

void main() {
  group('topTriggers', () {
    test('returns empty for no triggers', () {
      expect(topTriggers([_c(), _c()]), isEmpty);
    });

    test('counts and ranks triggers, most frequent first', () {
      final out = topTriggers([
        _c(triggers: ['Work', 'Stress']),
        _c(triggers: ['work']), // case-insensitive merge
        _c(triggers: ['Loneliness']),
        _c(triggers: ['Work']),
      ]);
      expect(out.first.label, 'Work'); // first-seen casing preserved
      expect(out.first.count, 3);
      expect(out.map((t) => t.label), containsAll(['Work', 'Stress', 'Loneliness']));
    });

    test('falls back to legacy single trigger only when list is empty', () {
      final out = topTriggers([
        _c(trigger: 'Bar'),
        _c(triggers: ['Party'], trigger: 'ignored-when-list-present'),
      ]);
      final labels = out.map((t) => t.label).toList();
      expect(labels, contains('Bar'));
      expect(labels, contains('Party'));
      expect(labels, isNot(contains('ignored-when-list-present')));
    });

    test('ignores blank/whitespace triggers', () {
      expect(topTriggers([_c(triggers: ['  ', ''])]), isEmpty);
    });
  });

  group('outcomeTally', () {
    test('only counts entries that recorded an outcome', () {
      final t = outcomeTally([
        _c(outcome: 'stayed_sober'),
        _c(outcome: 'stayed_sober'),
        _c(outcome: 'slipped'),
        _c(outcome: 'unclear'),
        _c(), // no outcome — excluded everywhere
      ]);
      expect(t.stayedSober, 2);
      expect(t.slipped, 1);
      expect(t.unclear, 1);
      expect(t.totalWithOutcome, 4);
    });

    test('empty input yields all zeros', () {
      final t = outcomeTally(const []);
      expect(t.stayedSober, 0);
      expect(t.slipped, 0);
      expect(t.unclear, 0);
      expect(t.totalWithOutcome, 0);
    });
  });

  group('bestResponses still honours min-sample + sober rate', () {
    test('orders by success rate then sample size, respecting minUses', () {
      final out = bestResponses([
        // walked: 2 uses, 2 sober → rate 1.0
        _c(responseChosen: 'walked', outcome: 'stayed_sober'),
        _c(responseChosen: 'walked', outcome: 'stayed_sober'),
        // called: 3 uses, 1 sober → rate 0.33
        _c(responseChosen: 'called', outcome: 'stayed_sober'),
        _c(responseChosen: 'called', outcome: 'slipped'),
        _c(responseChosen: 'called', outcome: 'slipped'),
        // breathed: 1 use → below minUses, excluded
        _c(responseChosen: 'breathed', outcome: 'stayed_sober'),
      ]);
      expect(out.map((r) => r.slug), ['walked', 'called']);
      expect(out.first.successRate, 1.0);
    });
  });
}
