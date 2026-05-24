import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

// Critical flow #11: the daily reset behaviour must clear stale state
// silently — it must NOT crash, and it must NOT carry yesterday's data
// forward as if it were today's.

String _today() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

String _yesterday() {
  final d = DateTime.now().subtract(const Duration(days: 1));
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

void main() {
  group('MissionToggles daily reset', () {
    test('does not surface yesterday\'s completions as today\'s', () async {
      // Seed a stale "yesterday" mission_toggles record.
      SharedPreferences.setMockInitialValues({
        'mission_toggles':
            jsonEncode({'date': _yesterday(), 'done': [0, 1, 2]}),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Reading the provider is synchronous (build() returns const {}).
      // Wait briefly for the async _load() to run and clear stale data.
      container.read(missionTogglesProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // State must be empty — yesterday's data discarded, today starts clean.
      expect(container.read(missionTogglesProvider), isEmpty,
          reason: 'Stale day data must NOT roll forward into today.');

      // And the stored key must have been removed (not silently kept).
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mission_toggles'), isNull,
          reason: 'The stale day record should be wiped on load.');
    });

    test('today\'s completions are retained across container restart',
        () async {
      SharedPreferences.setMockInitialValues({
        'mission_toggles': jsonEncode({'date': _today(), 'done': [1, 2]}),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(missionTogglesProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(container.read(missionTogglesProvider), {1, 2},
          reason: 'Same-day data must be loaded back, not wiped.');
    });

    test('corrupt mission_toggles JSON does not crash startup', () async {
      SharedPreferences.setMockInitialValues({
        'mission_toggles': '{this is not json',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Should not throw.
      container.read(missionTogglesProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(missionTogglesProvider), isEmpty);
    });
  });

  group('Gratitude daily lookup', () {
    // Gratitude now reads from EncryptedStore (Android Keystore-backed)
    // rather than plain SharedPreferences — seed via seedSecureStorage().
    test('returns today\'s entry when one exists', () async {
      SharedPreferences.setMockInitialValues({});
      seedSecureStorage({
        'gratitude': jsonEncode([
          {'id': '1', 'date': _yesterday(), 'text': 'yesterday'},
          {'id': '2', 'date': _today(), 'text': 'today'},
        ]),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(await container.read(gratitudeProvider.future), 'today');
    });

    test('returns null when no entry exists for today', () async {
      SharedPreferences.setMockInitialValues({});
      seedSecureStorage({
        'gratitude': jsonEncode([
          {'id': '1', 'date': _yesterday(), 'text': 'yesterday'},
        ]),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(await container.read(gratitudeProvider.future), isNull,
          reason: 'Yesterday\'s gratitude must NOT display as today\'s.');
    });

    test('add() makes the new value visible on a re-read', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(gratitudeProvider.future);
      await container.read(gratitudeProvider.notifier).add('I am grateful');

      // Re-read via a fresh container — confirms it actually persisted.
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      expect(await c2.read(gratitudeProvider.future), 'I am grateful');
    });
  });
}
