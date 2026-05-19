import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:journey_forward/l10n/app_localizations.dart';
import 'package:journey_forward/models/user_profile.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:journey_forward/theme/app_theme.dart';

void configureTestFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

Widget wrapLocalizedScreen(Widget child) {
  return wrapTestProviders(
    MaterialApp(
      theme: buildAppTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

Widget wrapTestProviders(Widget child) {
  return ProviderScope(
    overrides: [
      timerProvider.overrideWith(
        (ref) => Stream<DateTime>.value(DateTime(2026, 5, 18, 12)),
      ),
    ],
    child: child,
  );
}

UserProfile testProfile({
  String username = 'Shawn',
  DateTime? soberDate,
  double dailySpend = 120,
  String currency = '\$',
  String lockMethod = 'none',
}) {
  return UserProfile(
    username: username,
    soberDate: (soberDate ?? DateTime(2026, 5, 17)).toIso8601String(),
    dailySpend: dailySpend,
    currency: currency,
    lockMethod: lockMethod,
  );
}
