import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/screens/recovery_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(configureTestFonts);

  testWidgets('recovery screen renders the quitting timeline', (tester) async {
    final profile = testProfile();
    SharedPreferences.setMockInitialValues({
      'profile': profile.toJsonString(),
    });

    await tester.pumpWidget(wrapLocalizedScreen(const RecoveryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Quitting Timeline'), findsOneWidget);
    expect(find.textContaining('milestones reached'), findsOneWidget);
  });
}
