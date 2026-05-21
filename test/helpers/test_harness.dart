import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/l10n/app_localizations.dart';
import 'package:journey_forward/models/user_profile.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:journey_forward/theme/app_theme.dart';

// google_fonts has been removed in favour of bundled Inter + Fraunces .ttf
// files (assets/fonts/). This shim keeps existing test call sites compiling.
void configureTestFonts() {
  TestWidgetsFlutterBinding.ensureInitialized();
  installSecureStorageMock();
}

/// In-memory mock for `flutter_secure_storage`. Without this the
/// EncryptedStore helper throws "Binding has not yet been initialized"
/// inside tests, which then propagates as EncryptedStoreException after
/// the recent hardening of EncryptedStore.write().
///
/// Backs the plugin's MethodChannel with a Map<String,String?> shared
/// across all tests in the run. Tests that care about isolation can call
/// [resetSecureStorageMock].
final Map<String, String?> _secureStorage = <String, String?>{};

void resetSecureStorageMock() => _secureStorage.clear();

void installSecureStorageMock() {
  const channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    final args = (call.arguments as Map?) ?? const {};
    final key = args['key'] as String?;
    switch (call.method) {
      case 'read':
        return _secureStorage[key];
      case 'write':
        _secureStorage[key!] = args['value'] as String?;
        return null;
      case 'delete':
        _secureStorage.remove(key);
        return null;
      case 'containsKey':
        return _secureStorage.containsKey(key);
      case 'readAll':
        return Map<String, String>.from(
            _secureStorage.map((k, v) => MapEntry(k, v ?? '')));
      case 'deleteAll':
        _secureStorage.clear();
        return null;
      case 'getAllKeys':
        return _secureStorage.keys.toList();
    }
    return null;
  });
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
      // Replace both ticker providers with single-value streams. Letting the
      // Stream.periodic timers run in tests trips the test-binding invariant
      // check ("Timer is still pending after the widget tree was disposed").
      timerProvider.overrideWith(
        (ref) => Stream<DateTime>.value(DateTime(2026, 5, 18, 12)),
      ),
      slowTimerProvider.overrideWith(
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
