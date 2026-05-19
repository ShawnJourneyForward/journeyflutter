import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // ─── Journal ───────────────────────────────────────────────────────────────

  group('JournalNotifier', () {
    test('add() stores entry and updates state', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(journalProvider.future);
      await container.read(journalProvider.notifier).add('Feeling good today', 'great');

      final entries = await container.read(journalProvider.future);
      expect(entries, hasLength(1));
      expect(entries.first.text, 'Feeling good today');
      expect(entries.first.mood, 'great');
    });

    test('add() persists across container restart', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(journalProvider.future);
      await c1.read(journalProvider.notifier).add('Persisted entry', 'okay');

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final entries = await c2.read(journalProvider.future);
      expect(entries.first.text, 'Persisted entry');
    });

    test('delete() removes entry by id', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(journalProvider.future);
      await container.read(journalProvider.notifier).add('To delete', 'hard');
      final id = (await container.read(journalProvider.future)).first.id;
      await container.read(journalProvider.notifier).delete(id);

      expect(await container.read(journalProvider.future), isEmpty);
    });

    test('multiple entries are sorted newest first', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(journalProvider.future);
      await container.read(journalProvider.notifier).add('First', 'okay');
      await container.read(journalProvider.notifier).add('Second', 'good');

      final entries = await container.read(journalProvider.future);
      expect(entries.first.text, 'Second');
    });
  });

  // ─── Gratitude ─────────────────────────────────────────────────────────────

  group('GratitudeNotifier', () {
    test('add() stores entry and is readable as today', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(gratitudeProvider.future);
      await container.read(gratitudeProvider.notifier).add('Grateful for today');

      final text = await container.read(gratitudeProvider.future);
      expect(text, 'Grateful for today');
    });

    test('add() persists across container restart', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(gratitudeProvider.future);
      await c1.read(gratitudeProvider.notifier).add('Persisted gratitude');

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final text = await c2.read(gratitudeProvider.future);
      expect(text, 'Persisted gratitude');
    });
  });

  // ─── Affirmations ──────────────────────────────────────────────────────────

  group('AffirmationNotifier', () {
    test('add() stores affirmation', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(affirmationProvider.future);
      await container.read(affirmationProvider.notifier).add('I am enough');

      final entries = await container.read(affirmationProvider.future);
      expect(entries, contains('I am enough'));
    });

    test('add() prevents duplicates', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(affirmationProvider.future);
      await container.read(affirmationProvider.notifier).add('Same');
      await container.read(affirmationProvider.notifier).add('Same');

      final entries = await container.read(affirmationProvider.future);
      expect(entries.where((e) => e == 'Same'), hasLength(1));
    });

    test('remove() deletes affirmation', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(affirmationProvider.future);
      await container.read(affirmationProvider.notifier).add('To remove');
      await container.read(affirmationProvider.notifier).remove('To remove');

      final entries = await container.read(affirmationProvider.future);
      expect(entries, isNot(contains('To remove')));
    });
  });

  // ─── Vision board ──────────────────────────────────────────────────────────

  group('VisionBoardNotifier', () {
    test('add() stores item', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(visionBoardProvider.future);
      await container.read(visionBoardProvider.notifier).add(
        const VisionItem(id: 'v1', title: 'Travel', description: 'See the world', emoji: '✈️'),
      );

      final items = await container.read(visionBoardProvider.future);
      expect(items, hasLength(1));
      expect(items.first.title, 'Travel');
    });

    test('remove() deletes item by id', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(visionBoardProvider.future);
      await container.read(visionBoardProvider.notifier).add(
        const VisionItem(id: 'v1', title: 'Travel', description: '', emoji: '✈️'),
      );
      await container.read(visionBoardProvider.notifier).remove('v1');

      expect(await container.read(visionBoardProvider.future), isEmpty);
    });
  });

  // ─── Craving ───────────────────────────────────────────────────────────────

  group('CravingNotifier', () {
    test('add() stores entry with intensity and triggers', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(cravingProvider.future);
      await container.read(cravingProvider.notifier).add(
        7,
        severity: 'Strong',
        triggers: ['Stress', 'Boredom'],
        durationMinutes: 10,
        notes: 'Passed a bar',
      );

      final entries = await container.read(cravingProvider.future);
      expect(entries, hasLength(1));
      expect(entries.first.intensity, 7);
      expect(entries.first.triggers, ['Stress', 'Boredom']);
      expect(entries.first.notes, 'Passed a bar');
    });

    test('add() with no triggers stores empty list', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(cravingProvider.future);
      await container.read(cravingProvider.notifier).add(3);

      final entries = await container.read(cravingProvider.future);
      expect(entries.first.triggers, isEmpty);
    });

    test('add() trims whitespace from notes', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(cravingProvider.future);
      await container.read(cravingProvider.notifier).add(5, notes: '  note  ');

      expect((await container.read(cravingProvider.future)).first.notes, 'note');
    });

    test('add() treats whitespace-only notes as null', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(cravingProvider.future);
      await container.read(cravingProvider.notifier).add(5, notes: '   ');

      expect((await container.read(cravingProvider.future)).first.notes, isNull);
    });

    test('add() persists across container restart', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(cravingProvider.future);
      await c1.read(cravingProvider.notifier).add(6, severity: 'Moderate');

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final entries = await c2.read(cravingProvider.future);
      expect(entries.first.intensity, 6);
    });
  });

  // ─── Thought ───────────────────────────────────────────────────────────────

  group('ThoughtNotifier', () {
    test('add() stores entry', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(thoughtProvider.future);
      await container.read(thoughtProvider.notifier).add(
        'I noticed a craving',
        'negative',
        strength: 'Moderate',
        triggers: ['Stress'],
        durationMinutes: 5,
      );

      final entries = await container.read(thoughtProvider.future);
      expect(entries, hasLength(1));
      expect(entries.first.text, 'I noticed a craving');
      expect(entries.first.type, 'negative');
      expect(entries.first.strength, 'Moderate');
    });

    test('add() persists across container restart', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(thoughtProvider.future);
      await c1.read(thoughtProvider.notifier).add('Persisted thought', 'neutral');

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final entries = await c2.read(thoughtProvider.future);
      expect(entries.first.text, 'Persisted thought');
    });

    test('whitespace-only notes stored as null', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(thoughtProvider.future);
      await container.read(thoughtProvider.notifier).add('Text', 'neutral', notes: '   ');

      expect((await container.read(thoughtProvider.future)).first.notes, isNull);
    });
  });

  // ─── Activity ──────────────────────────────────────────────────────────────

  group('ActivityNotifier', () {
    test('add() stores entry', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(activityProvider.future);
      await container.read(activityProvider.notifier).add(
        'walk',
        30,
        effort: 'Gentle',
        outcome: 'Calmer',
        notes: 'Park loop',
      );

      final entries = await container.read(activityProvider.future);
      expect(entries, hasLength(1));
      expect(entries.first.activity, 'walk');
      expect(entries.first.minutes, 30);
      expect(entries.first.effort, 'Gentle');
      expect(entries.first.notes, 'Park loop');
    });

    test('add() persists across container restart', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(activityProvider.future);
      await c1.read(activityProvider.notifier).add('yoga', 20);

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final entries = await c2.read(activityProvider.future);
      expect(entries.first.activity, 'yoga');
    });
  });

  // ─── Sleep ─────────────────────────────────────────────────────────────────

  group('SleepNotifier', () {
    test('add() stores entry', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sleepProvider.future);
      await container.read(sleepProvider.notifier).add(
        7.5,
        4,
        factors: ['Stress'],
        notes: 'Woke once',
      );

      final entries = await container.read(sleepProvider.future);
      expect(entries, hasLength(1));
      expect(entries.first.hours, 7.5);
      expect(entries.first.quality, 4);
      expect(entries.first.factors, ['Stress']);
    });

    test('add() persists across container restart', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);

      await c1.read(sleepProvider.future);
      await c1.read(sleepProvider.notifier).add(6.0, 3);

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final entries = await c2.read(sleepProvider.future);
      expect(entries.first.hours, 6.0);
    });
  });

  // ─── Corrupt data recovery ─────────────────────────────────────────────────

  group('Corrupt stored data recovery', () {
    test('corrupt craving JSON returns empty list', () async {
      SharedPreferences.setMockInitialValues({'cravings': '{bad json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(cravingProvider.future), isEmpty);
    });

    test('corrupt thought JSON returns empty list', () async {
      SharedPreferences.setMockInitialValues({'thoughts': '{bad json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(thoughtProvider.future), isEmpty);
    });

    test('corrupt activity JSON returns empty list', () async {
      SharedPreferences.setMockInitialValues({'activities': '{bad json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(activityProvider.future), isEmpty);
    });

    test('corrupt sleep JSON returns empty list', () async {
      SharedPreferences.setMockInitialValues({'sleep_logs': '{bad json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(sleepProvider.future), isEmpty);
    });
  });
}
