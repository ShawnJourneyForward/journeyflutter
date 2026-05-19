import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_harness.dart';

void main() {
  setUpAll(configureTestFonts);

  testWidgets('root app bootstraps into onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      wrapTestProviders(
        const JourneyForwardApp(hasProfile: false, lockMethod: 'none'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('A new chapter'), findsOneWidget);
  });
}
