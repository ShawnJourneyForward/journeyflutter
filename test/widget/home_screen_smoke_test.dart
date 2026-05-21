import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(configureTestFonts);

  testWidgets('home screen loads the stored profile (username appears)',
      (tester) async {
    // Seed both the legacy plaintext profile (which the ProfileNotifier
    // will migrate into EncryptedStore) and the synchronous sentinel.
    final profile = testProfile(username: 'Shawn');
    SharedPreferences.setMockInitialValues({
      'profile': profile.toJsonString(),
      'has_profile': '1',
    });

    await tester.pumpWidget(wrapLocalizedScreen(const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);

    // Username sourced from the profile is stable across redesigns —
    // if it doesn't appear, profileProvider didn't resolve, which is
    // the actual regression we care about.
    expect(find.textContaining('Shawn'), findsWidgets,
        reason: 'Profile must be readable through ProfileNotifier and '
            'projected into the home screen header.');
  });
}
