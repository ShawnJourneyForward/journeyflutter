import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(configureTestFonts);

  testWidgets('home screen renders key sections from mocked storage', (tester) async {
    final profile = testProfile();
    SharedPreferences.setMockInitialValues({
      'profile': profile.toJsonString(),
    });

    await tester.pumpWidget(wrapLocalizedScreen(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Shawn'), findsWidgets);
    expect(find.text('YOUR JOURNEY'), findsOneWidget);
    expect(find.textContaining('MONEY'), findsWidgets);
    expect(find.text('DAILY MISSIONS'), findsOneWidget);
  });
}
