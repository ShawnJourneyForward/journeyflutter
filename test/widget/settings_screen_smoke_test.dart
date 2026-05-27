import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(configureTestFonts);

  testWidgets('settings screen renders the loaded profile username',
      (tester) async {
    final profile = testProfile(username: 'Shawn');
    SharedPreferences.setMockInitialValues({
      'profile': profile.toJsonString(),
      'has_profile': '1',
    });

    await tester.pumpWidget(wrapLocalizedScreen(const SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);

    // Username must be projected onto the settings screen - proves the
    // profile reached the UI through the EncryptedStore migration path.
    expect(find.textContaining('Shawn'), findsWidgets,
        reason: 'Settings must surface the stored profile data; if this '
            'fails the profile read pipeline is broken.');
  });

  testWidgets('settings diagnostics are hidden and version tap target exists',
      (tester) async {
    final profile = testProfile(username: 'Shawn');
    SharedPreferences.setMockInitialValues({
      'profile': profile.toJsonString(),
      'has_profile': '1',
    });

    await tester.pumpWidget(wrapLocalizedScreen(const SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);

    expect(find.text('Diagnostics'), findsNothing);

    final scrollable = find.byType(Scrollable).first;
    final versionTapTarget =
        find.byKey(const Key('settings_version_diagnostics_tap_target'));
    await tester.scrollUntilVisible(
      versionTapTarget,
      200,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();

    expect(versionTapTarget, findsOneWidget);
    expect(find.text('Version 5.8.0'), findsOneWidget);
  });
}
