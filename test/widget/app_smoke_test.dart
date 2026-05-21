import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

// Router-redirect coverage.
// Critical flow #2: the router must show /onboarding when no profile
// exists, and the main shell when a profile is present.
// Tests anchor on stable widget keys (Key('onboarding-screen'),
// Key('app-shell')) so they don't break when onboarding copy or shell
// nav labels change.

void main() {
  setUpAll(configureTestFonts);

  testWidgets('router lands on onboarding when no profile is saved',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      wrapTestProviders(
        const JourneyForwardApp(hasProfile: false, lockMethod: 'none'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    expect(find.byKey(const Key('onboarding-screen')), findsOneWidget,
        reason: 'Fresh install must land on /onboarding.');
    expect(find.byKey(const Key('app-shell')), findsNothing,
        reason: 'Shell must not render before onboarding completes.');
  });

  testWidgets('router lands on the main shell when a profile exists',
      (tester) async {
    final profile = testProfile();
    SharedPreferences.setMockInitialValues({
      'profile': profile.toJsonString(),
      'has_profile': '1',
      'lockMethod': 'none',
    });

    await tester.pumpWidget(
      wrapTestProviders(
        const JourneyForwardApp(hasProfile: true, lockMethod: 'none'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    expect(find.byKey(const Key('app-shell')), findsOneWidget,
        reason: 'Profile present must route into the main shell.');
    expect(find.byKey(const Key('onboarding-screen')), findsNothing,
        reason: 'Existing profile must never bounce back to onboarding.');
  });
}
