import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_harness.dart';

// Reproduction probe: on a fresh install with a multi-week streak and no
// export ever made, Home should surface the "Protect your progress" backup
// reminder card (backupOverdueProvider == true). This mirrors exactly what the
// emulator walkthrough set up (21 days sober, no last_backup_date).
void main() {
  setUpAll(configureTestFonts);

  testWidgets('backup reminder shows: 21 days sober, never backed up',
      (tester) async {
    final profile = testProfile(
      username: 'Sam',
      soberDate: DateTime.now().subtract(const Duration(days: 21)),
      dailySpend: 50,
    );
    SharedPreferences.setMockInitialValues({
      'profile': profile.toJsonString(),
      'has_profile': '1',
      // deliberately NO 'last_backup_date' → overdue should be true
    });

    await tester.pumpWidget(wrapLocalizedScreen(const HomeScreen()));
    // Let profileProvider migrate + prefsProvider + backupOverdueProvider settle.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    expect(
      find.textContaining('Protect your progress'),
      findsWidgets,
      reason: 'Backup reminder card must appear when the user has a streak '
          'but has never exported a backup.',
    );
  });
}
