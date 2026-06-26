// Diagnostic + regression guard for the home live-counter "jitter": renders the
// REAL HomeScreen at several second values and asserts the seconds value does
// not move horizontally as it ticks. If this passes, the counter geometry is
// provably stable and any on-device jitter is environmental (e.g. a stale
// install), not this code.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/l10n/app_localizations.dart';
import 'package:journey_forward/providers/app_providers.dart';
import 'package:journey_forward/screens/home_screen.dart';
import 'package:journey_forward/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

Widget _homeAt(DateTime now) => ProviderScope(
      overrides: [
        timerProvider.overrideWith((ref) => Stream<DateTime>.value(now)),
        slowTimerProvider.overrideWith((ref) => Stream<DateTime>.value(now)),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    );

/// Union rect (left edge, width) of the seconds VALUE digits — the thing that
/// visually jitters. Scoped to the seconds tile via its "SECONDS" label.
({double left, double width}) _secondsValueBox(WidgetTester tester) {
  final label = find.text('SECONDS');
  expect(label, findsOneWidget, reason: 'seconds tile label must be present');
  final tile = find.ancestor(of: label, matching: find.byType(Column)).first;
  final digits = find.descendant(
    of: tile,
    matching: find.byWidgetPredicate((w) =>
        w is Text &&
        w.data != null &&
        w.data!.length == 1 &&
        '0123456789'.contains(w.data!)),
  );
  final n = digits.evaluate().length;
  expect(n, greaterThan(0), reason: 'seconds value must render digit glyphs');
  var left = double.infinity;
  var right = -double.infinity;
  for (var i = 0; i < n; i++) {
    final r = tester.getRect(digits.at(i));
    left = math.min(left, r.left);
    right = math.max(right, r.right);
  }
  return (left: left, width: right - left);
}

void main() {
  setUpAll(configureTestFonts);

  testWidgets('seconds value does not shift horizontally as it ticks',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'profile': testProfile(soberDate: DateTime(2026, 5, 17)).toJsonString(),
      'has_profile': '1',
    });

    // soberDate 2026-05-17 00:00; now 2026-05-18 12:00:SS -> seconds == SS.
    final samples = <int, ({double left, double width})>{};
    for (final s in [5, 8, 11, 38, 59]) {
      await tester.pumpWidget(_homeAt(DateTime(2026, 5, 18, 12, 0, s)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      samples[s] = _secondsValueBox(tester);
    }

    final base = samples[5]!;
    for (final entry in samples.entries) {
      expect((entry.value.left - base.left).abs(), lessThan(0.5),
          reason: 'seconds value LEFT edge moved at s=${entry.key}: '
              '${entry.value.left} vs ${base.left} — this IS the jitter');
      expect((entry.value.width - base.width).abs(), lessThan(0.5),
          reason: 'seconds value WIDTH changed at s=${entry.key}: '
              '${entry.value.width} vs ${base.width}');
    }
    // Print the measured geometry so the diagnosis is visible in test output.
    // ignore: avoid_print
    print('SECONDS VALUE BOXES: $samples');
  });
}
