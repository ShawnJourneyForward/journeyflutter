import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/providers/app_providers.dart';

void main() {
  group('Check-in entry serialization', () {
    test('CravingEntry preserves severity, triggers, duration, and notes', () {
      final entry = CravingEntry(
        id: 'c1',
        date: DateTime(2026, 5, 18, 8),
        intensity: 7,
        trigger: 'Stress',
        severity: 'Strong',
        triggers: const ['Stress', 'Time of Day'],
        durationMinutes: 12,
        notes: 'After work',
      );

      final decoded = CravingEntry.fromJson(
        jsonDecode(jsonEncode(entry.toJson())) as Map<String, dynamic>,
      );

      expect(decoded.severity, 'Strong');
      expect(decoded.triggers, ['Stress', 'Time of Day']);
      expect(decoded.durationMinutes, 12);
      expect(decoded.notes, 'After work');
    });

    test('legacy craving trigger becomes a trigger list', () {
      final decoded = CravingEntry.fromJson({
        'id': 'legacy',
        'date': '2026-05-18T08:00:00.000',
        'intensity': 5,
        'trigger': 'Boredom',
      });

      expect(decoded.triggers, ['Boredom']);
    });

    test('ThoughtEntry preserves structured context', () {
      final entry = ThoughtEntry(
        id: 't1',
        date: DateTime(2026, 5, 18, 8),
        text: 'I want a drink',
        type: 'negative',
        strength: 'Moderate',
        triggers: const ['Stress'],
        durationMinutes: 5,
        notes: 'Saw an ad',
      );

      final decoded = ThoughtEntry.fromJson(entry.toJson());

      expect(decoded.strength, 'Moderate');
      expect(decoded.triggers, ['Stress']);
      expect(decoded.durationMinutes, 5);
      expect(decoded.notes, 'Saw an ad');
    });

    test('ActivityEntry preserves effort, outcome, and notes', () {
      final entry = ActivityEntry(
        id: 'a1',
        date: DateTime(2026, 5, 18, 8),
        activity: 'walk',
        minutes: 20,
        effort: 'gentle',
        outcome: 'calmer',
        notes: 'Park loop',
      );

      final decoded = ActivityEntry.fromJson(entry.toJson());

      expect(decoded.effort, 'gentle');
      expect(decoded.outcome, 'calmer');
      expect(decoded.notes, 'Park loop');
    });

    test('SleepEntry preserves factors and notes', () {
      final entry = SleepEntry(
        id: 's1',
        date: DateTime(2026, 5, 18, 8),
        hours: 7.5,
        quality: 4,
        factors: const ['Caffeine', 'Stress'],
        notes: 'Woke once',
      );

      final decoded = SleepEntry.fromJson(entry.toJson());

      expect(decoded.hours, 7.5);
      expect(decoded.quality, 4);
      expect(decoded.factors, ['Caffeine', 'Stress']);
      expect(decoded.notes, 'Woke once');
    });
  });
}
