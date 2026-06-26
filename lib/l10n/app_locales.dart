import 'package:flutter/widgets.dart';

/// Single source of truth for which languages the app ships.
///
/// Adding a language is intentionally a one-step change:
///   1. Hand the translator the CSV (TRANSLATIONS/journey_forward_strings.csv).
///   2. Drop their finished translation into `lib/l10n/app_<code>.arb`
///      (every key from `app_en.arb`, translated).
///   3. Run `flutter gen-l10n`.
///   4. Add ONE entry to [kSupportedLanguages] below.
///
/// Until a language has a genuine, complete translation it must NOT be listed
/// here — otherwise a user who picks it gets English back, which is worse than
/// not offering it. The Afrikaans/Spanish/Portuguese/Zulu `.arb` stubs that
/// already exist are English mirrors awaiting translation; their entries are
/// kept commented out below, ready to enable.
class AppLanguage {
  final Locale locale;

  /// Name in English — used for logging / fallback, never shown to users.
  final String englishName;

  /// Endonym shown in the in-app language picker (e.g. "Español").
  final String nativeName;

  const AppLanguage(this.locale, this.englishName, this.nativeName);
}

const List<AppLanguage> kSupportedLanguages = [
  AppLanguage(Locale('en'), 'English', 'English'),
  // Enable each line below once lib/l10n/app_<code>.arb holds a real,
  // complete translation (see the steps in this file's doc comment):
  // AppLanguage(Locale('af'), 'Afrikaans', 'Afrikaans'),
  // AppLanguage(Locale('de'), 'German', 'Deutsch'),
  // AppLanguage(Locale('es'), 'Spanish', 'Español'),
  // AppLanguage(Locale('pt'), 'Portuguese', 'Português'),
  // AppLanguage(Locale('zu'), 'Zulu', 'isiZulu'),
];

/// Locales handed to `MaterialApp.supportedLocales`. Derived from
/// [kSupportedLanguages] so the picker and the framework never drift apart.
List<Locale> get kSupportedLocales =>
    kSupportedLanguages.map((l) => l.locale).toList(growable: false);
