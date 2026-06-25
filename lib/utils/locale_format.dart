import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../l10n/app_locales.dart';
import '../l10n/app_localizations.dart';

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

/// Format a DISTANCE for display. Values are stored canonical in km; convert to
/// miles only here when [imperial]. The numeric part follows the active app
/// locale (`Intl.defaultLocale`, via [NumberFormat] like [formatMoney]); the
/// unit WORD comes from [l10n]. Differs from [formatMoney] by taking [l10n]
/// (precedent: `craving_insights.dart` imports `app_localizations.dart`).
String formatDistance(double km,
    {required bool imperial, required AppLocalizations l10n}) {
  final value = imperial ? km * 0.621371 : km;
  final unit = imperial ? l10n.homeUnitMiles : l10n.homeUnitKm;
  return '${NumberFormat('#,##0.0', Intl.defaultLocale).format(value)} $unit';
}

/// Format a WEIGHT for display. Values are stored canonical in kg; convert to
/// pounds only here when [imperial]. The numeric part follows the active app
/// locale; the unit WORD comes from [l10n]. Differs from [formatMoney] by
/// taking [l10n].
String formatWeight(double kg,
    {required bool imperial, required AppLocalizations l10n}) {
  final value = imperial ? kg * 2.2046226 : kg;
  final unit = imperial ? l10n.plannerUnitLb : l10n.plannerUnitKg;
  return '${NumberFormat('#,##0.0', Intl.defaultLocale).format(value)} $unit';
}

/// Format a PACE for display as `m:ss` per unit distance. [km] is the canonical
/// distance covered and [minutes] the elapsed minutes; pace is minutes per mile
/// when [imperial], else per km. The unit WORD comes from [l10n]. Differs from
/// [formatMoney] by taking [l10n]. Returns `--:--` for non-positive distance.
String formatPace(double km, int minutes,
    {required bool imperial, required AppLocalizations l10n}) {
  final unit = imperial ? l10n.plannerUnitPaceMi : l10n.plannerUnitPaceKm;
  final distance = imperial ? km * 0.621371 : km;
  if (distance <= 0 || minutes <= 0) return '--:-- $unit';
  final paceMinutes = minutes / distance;
  final totalSeconds = (paceMinutes * 60).round();
  final mm = totalSeconds ~/ 60;
  final ss = totalSeconds % 60;
  return '$mm:${ss.toString().padLeft(2, '0')} $unit';
}

/// Format an average SPEED for display (km/h, or mph when [imperial]). Used for
/// disciplines where speed reads more naturally than pace — cycling. [km] is the
/// canonical distance and [minutes] the elapsed minutes. Returns `— unit` for a
/// non-positive distance/time.
String formatSpeed(double km, int minutes,
    {required bool imperial, required AppLocalizations l10n}) {
  final unit = imperial ? l10n.plannerUnitSpeedMph : l10n.plannerUnitSpeedKmh;
  if (km <= 0 || minutes <= 0) return '— $unit';
  final speedKmh = km / (minutes / 60.0);
  final value = imperial ? speedKmh * 0.621371 : speedKmh;
  return '${NumberFormat('#,##0.0', Intl.defaultLocale).format(value)} $unit';
}

/// Format a SWIM pace for display as `m:ss` per 100 metres (the swimming
/// convention). Always metric. Returns `--:-- /100m` for a non-positive
/// distance/time.
String formatSwimPace(double km, int minutes,
    {required AppLocalizations l10n}) {
  final unit = l10n.plannerUnitPace100m;
  final meters = km * 1000.0;
  if (meters <= 0 || minutes <= 0) return '--:-- $unit';
  final per100 = minutes / (meters / 100.0);
  final totalSeconds = (per100 * 60).round();
  final mm = totalSeconds ~/ 60;
  final ss = totalSeconds % 60;
  return '$mm:${ss.toString().padLeft(2, '0')} $unit';
}
