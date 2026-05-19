import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(configureTestFonts);

  testWidgets('settings screen renders with a stored profile', (tester) async {
    final profile = testProfile();
    SharedPreferences.setMockInitialValues({
      'profile': profile.toJsonString(),
    });

    await tester.pumpWidget(wrapLocalizedScreen(const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Shawn'), findsWidgets);
  });
}
