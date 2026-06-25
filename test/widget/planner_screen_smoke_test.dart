import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/screens/planner_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(configureTestFonts);

  testWidgets('planner screen mounts without exceptions', (tester) async {
    // Empty SharedPreferences so the planner AsyncNotifiers resolve to their
    // documented defaults (no goals, no sessions, no weight logs). Seeding the
    // same way as the other smoke tests keeps the read pipeline realistic.
    SharedPreferences.setMockInitialValues(const {});

    // wrapLocalizedScreen supplies MaterialApp (Localizations), the
    // ProviderScope, and the timer overrides; PlannerScreen brings its own
    // TickerProvider via SingleTickerProviderStateMixin.
    await tester.pumpWidget(wrapLocalizedScreen(const PlannerScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('planner-screen')), findsOneWidget);
  });
}
