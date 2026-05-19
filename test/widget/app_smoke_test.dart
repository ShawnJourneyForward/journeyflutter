import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(configureTestFonts);

  testWidgets('app boots into onboarding when no profile exists', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      wrapTestProviders(
        const JourneyForwardApp(hasProfile: false, lockMethod: 'none'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('A new chapter'), findsOneWidget);
    expect(find.textContaining("Let's begin"), findsOneWidget);
  });

  testWidgets('completed onboarding state boots into the main shell', (tester) async {
    final profile = testProfile();
    SharedPreferences.setMockInitialValues({
      'profile': profile.toJsonString(),
      'lockMethod': 'none',
    });

    await tester.pumpWidget(
      wrapTestProviders(
        const JourneyForwardApp(hasProfile: true, lockMethod: 'none'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
  });
}
