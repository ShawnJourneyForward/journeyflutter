import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../l10n/app_locales.dart';

/// Locale-aware formatting glue.
///
/// `flutter_localizations` localizes the *widget* strings (ARB), but `intl`
/// (every `DateFormat` and `NumberFormat`) formats off its OWN global,
/// `Intl.defaultLocale`. If that global is never set, dates, weekdays, months,
/// AM/PM and money grouping all render `en_US` no matter which language is
/// enabled — which would silently defeat the "just plug in a language" goal.
///
/// We set `Intl.defaultLocale` once at startup and again on every language
/// change (see `applyIntlLocale`), and pre-load the date symbols for every
/// enabled language so synchronous build()-time formatting is always ready.

/// Resolve the effective locale TAG (e.g. `en`, `pt`, `es`) used for `intl`
/// formatting, given the user's explicit choice ([chosen]; null = follow the
/// device). Falls back to the device language only when it's an ENABLED
/// language (so formatting matches the strings the framework actually shows),
/// otherwise English.
String effectiveLocaleTag(Locale? chosen, Locale deviceLocale) {
  final enabled =
      kSupportedLanguages.map((l) => l.locale.languageCode).toSet();
  if (chosen != null && enabled.contains(chosen.languageCode)) {
    return chosen.toLanguageTag();
  }
  return enabled.contains(deviceLocale.languageCode)
      ? deviceLocale.toLanguageTag()
      : 'en';
}

/// Pre-load `intl` date symbols for every enabled language. Call once during
/// startup (before `runApp`) so `DateFormat` works synchronously in build().
Future<void> initIntlDateFormatting() async {
  for (final l in kSupportedLanguages) {
    await initializeDateFormatting(l.locale.toLanguageTag());
  }
}

/// Point `intl` at [tag] for all subsequent date/number formatting. Safe to
/// call synchronously on every rebuild (the symbols are pre-loaded above).
void applyIntlLocale(String tag) {
  Intl.defaultLocale = tag;
}

/// Format a money amount for DISPLAY. Grouping/decimal separators follow the
/// active app locale (`Intl.defaultLocale`); the currency [symbol] stays the
/// user's explicit choice (`profile.currency`) and is placed before the amount.
///
/// Do NOT use this for editable input fields — a localized decimal separator
/// (e.g. `1 234,56`) would break `double.tryParse` on save.
String formatMoney(num amount, {required String symbol, String pattern = '#,##0.00'}) =>
    '$symbol${NumberFormat(pattern, Intl.defaultLocale).format(amount)}';
