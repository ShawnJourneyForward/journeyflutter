import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/screens/recovery_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(configureTestFonts);

  testWidgets('recovery screen renders a scaffold with a back action',
      (tester) async {
    final profile = testProfile();
    SharedPreferences.setMockInitialValues({
      'profile': profile.toJsonString(),
      'has_profile': '1',
    });

    await tester.pumpWidget(wrapLocalizedScreen(const RecoveryScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);

    // Stable structure assertions — surface area is a Scaffold with a
    // back button (LuxuryBackButton wraps an IconButton). These don't
    // depend on copy wording.
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget,
        reason: 'Every sub-screen must expose a back affordance.');
  });
}
