import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readArb(File file) {
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _messageKeys(Map<String, dynamic> arb) {
  return arb.keys.where((key) => !key.startsWith('@')).toSet();
}

Set<String> _placeholdersFor(Map<String, dynamic> arb, String key) {
  final meta = arb['@$key'];
  if (meta is! Map<String, dynamic>) return const {};
  final placeholders = meta['placeholders'];
  if (placeholders is! Map<String, dynamic>) return const {};
  return placeholders.keys.toSet();
}

void main() {
  final l10nDir = Directory('lib/l10n');
  final englishFile = File('lib/l10n/app_en.arb');
  final arbFiles = l10nDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.arb'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  group('localization ARB files', () {
    test('app_en.arb exists', () {
      expect(englishFile.existsSync(), isTrue);
    });

    test('all locale ARB files parse as valid JSON', () {
      for (final file in arbFiles) {
        expect(() => _readArb(file), returnsNormally, reason: file.path);
      }
    });

    test('all locale files share the same message key set', () {
      final english = _readArb(englishFile);
      final englishKeys = _messageKeys(english);

      for (final file in arbFiles.where((f) => f.path != englishFile.path)) {
        final localeKeys = _messageKeys(_readArb(file));
        expect(localeKeys, englishKeys, reason: file.path);
      }
    });

    test('placeholder names match across locale files', () {
      final english = _readArb(englishFile);
      final englishKeys = _messageKeys(english);

      for (final file in arbFiles.where((f) => f.path != englishFile.path)) {
        final locale = _readArb(file);
        for (final key in englishKeys) {
          expect(
            _placeholdersFor(locale, key),
            _placeholdersFor(english, key),
            reason: '${file.path}::$key',
          );
        }
      }
    });

    test(
      'non-English locale files are not exact English clones',
      skip: 'TODO: real translations not yet written — '
          'app ships English-only for now. '
          'Remove skip when translations are added.',
      () {
      final english = _readArb(englishFile);
      final englishValues = Map<String, dynamic>.fromEntries(
        english.entries.where((entry) => !entry.key.startsWith('@')),
      );

      for (final file in arbFiles.where((f) => f.path != englishFile.path)) {
        final locale = _readArb(file);
        final differingValues = englishValues.entries.where((entry) {
          return locale[entry.key] != entry.value;
        }).length;

        expect(
          differingValues,
          greaterThan(0),
          reason: '${file.path} is identical to English across all strings',
        );
      }
    });
  });
}
