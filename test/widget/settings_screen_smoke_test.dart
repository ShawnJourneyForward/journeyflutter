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

    // Username must be projected onto the settings screen — proves the
    // profile reached the UI through the EncryptedStore migration path.
    expect(find.textContaining('Shawn'), findsWidgets,
        reason: 'Settings must surface the stored profile data; if this '
            'fails the profile read pipeline is broken.');
  });
}
