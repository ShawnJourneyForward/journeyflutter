import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/screens/planner_goal_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

/// The goal-name placeholder used to be hard-coded to a running event
/// ("e.g. Two Oceans Half"), which made no sense once the goal type was Weight.
/// It is now type-aware: the running example only shows for Exercise goals; a
/// Weight goal gets a body-goal example instead.
void main() {
  setUpAll(configureTestFonts);
  setUp(resetSecureStorageMock);

  testWidgets('goal-name hint is type-aware (no running example on Weight)',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    await tester.pumpWidget(wrapLocalizedScreen(const PlannerGoalScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    // Default type is Exercise → the running example is the placeholder.
    expect(find.text('e.g. Two Oceans Half'), findsOneWidget);
    expect(find.text('e.g. Summer reset'), findsNothing);

    // Switch to Weight → the running example must be gone.
    await tester.tap(find.text('Weight'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('e.g. Two Oceans Half'), findsNothing,
        reason: 'a weight goal must not suggest a running event');
    expect(find.text('e.g. Summer reset'), findsOneWidget);
  });
}
