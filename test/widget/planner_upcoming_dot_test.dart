import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/planner_session.dart';
import 'package:journey_forward/screens/planner_screen.dart';
import 'package:journey_forward/theme/planner_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

/// Verifies the new "upcoming session" calendar marker: a single planned session
/// that is neither completed nor skipped now shows a small accent dot on its day
/// cell (previously it carried only a soft tint and read as empty). A completed
/// session shows a check glyph instead — never the dot — so the two are mutually
/// exclusive.
void main() {
  setUpAll(configureTestFonts);
  setUp(resetSecureStorageMock);

  testWidgets('upcoming single session renders an accent dot', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final now = DateTime.now();
    // Two fixed in-month days so both fall inside the planner's default month.
    final upcoming = DateTime(now.year, now.month, 15);
    final done = DateTime(now.year, now.month, 16);

    seedSecureStorage({
      'planner_sessions': jsonEncode([
        PlannerSession(
          id: 'todo1',
          date: upcoming,
          type: SessionType.easyRun,
          plannedDistanceKm: 4.2,
        ).toJson(),
        PlannerSession(
          id: 'done1',
          date: done,
          type: SessionType.easyRun,
          completed: true,
        ).toJson(),
      ]),
    });

    await tester.pumpWidget(wrapLocalizedScreen(const PlannerScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    // The calendar lives on the second tab ("Planner"); the default tab is
    // "Overview", so switch before asserting on calendar cells.
    await tester.tap(find.text('Planner'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull);

    // The new upcoming dot: a small circular Container in the session's accent.
    final dotColor = sessionTypeColor(SessionType.easyRun);
    final dots = tester.widgetList<Container>(find.byType(Container)).where((c) {
      final d = c.decoration;
      return d is BoxDecoration &&
          d.shape == BoxShape.circle &&
          d.color == dotColor;
    });

    // Exactly one upcoming session → exactly one upcoming dot. The completed
    // day shows a check icon, not a dot, so it must not add a second one.
    expect(dots.length, 1,
        reason: 'expected exactly one upcoming-session accent dot');
    expect(find.byIcon(Icons.check_rounded), findsOneWidget,
        reason: 'completed day should show a check, not the dot');
  });
}
