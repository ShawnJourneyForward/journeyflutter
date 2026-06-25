import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/l10n/app_locales.dart';

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

    test('translator CSV covers every app_en.arb key', () {
      // Guards the recurring "CSV fell behind the ARB" bug: a community
      // translator works from TRANSLATIONS/journey_forward_strings.csv, so it
      // must contain every current key. Regenerate with
      //   python tool/gen_translation_csv.py
      // whenever this fails. Robust to multi-line quoted English values: each
      // DATA row begins "<Section>,<Key>," and neither column contains a comma,
      // so a row-anchored match finds the keys without a full CSV parse.
      final csv = File('TRANSLATIONS/journey_forward_strings.csv');
      if (!csv.existsSync()) return; // doc not present in this checkout — skip
      final present = RegExp(r'(?:^|\n)[A-Za-z0-9]+,([A-Za-z0-9_]+),')
          .allMatches(csv.readAsStringSync())
          .map((m) => m.group(1)!)
          .toSet();
      final missing = _messageKeys(_readArb(englishFile)).difference(present);
      expect(missing, isEmpty,
          reason: 'These app_en.arb keys are missing from the translator CSV — '
              'run: python tool/gen_translation_csv.py\nMissing: '
              '${missing.take(12).toList()}');
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

    test('ENABLED non-English locales are genuinely translated, not English '
        'clones', () {
      // Only languages actually listed in kSupportedLanguages ship to users.
      // Stub ARBs (af/es/pt/zu) that are still English mirrors are intentionally
      // NOT enabled, so they are excluded here. This test is dormant while the
      // app is English-only and activates the moment a language is enabled —
      // catching a half-translated (English-clone) ARB before it can ship.
      final enabledCodes = kSupportedLanguages
          .map((l) => l.locale.languageCode)
          .where((c) => c != 'en')
          .toSet();
      if (enabledCodes.isEmpty) return;

      final english = _readArb(englishFile);
      final englishValues = Map<String, dynamic>.fromEntries(
        english.entries.where((entry) => !entry.key.startsWith('@')),
      );

      for (final code in enabledCodes) {
        final file = File('lib/l10n/app_$code.arb');
        expect(file.existsSync(), isTrue,
            reason: 'enabled locale "$code" has no app_$code.arb');
        final locale = _readArb(file);
        final differing = englishValues.entries
            .where((entry) => locale[entry.key] != entry.value)
            .length;
        final translatedRatio = differing / englishValues.length;
        expect(
          translatedRatio,
          greaterThan(0.5),
          reason: 'app_$code.arb is >50% identical to English across strings '
              '— it looks untranslated; do not enable it until translated.',
        );
      }
    });
  });
}
