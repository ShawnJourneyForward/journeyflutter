import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/screens/privacy_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(configureTestFonts);

  testWidgets('privacy screen renders its commitment and sections',
      (tester) async {
    await tester.pumpWidget(wrapLocalizedScreen(const PrivacyScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Your privacy is absolute.'), findsOneWidget);
    expect(find.text('All data stays on your device'), findsOneWidget);
  });
}
