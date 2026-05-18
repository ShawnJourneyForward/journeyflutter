import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/main.dart';

void main() {
  testWidgets('app bootstraps', (tester) async {
    await tester.pumpWidget(
      const JourneyForwardApp(hasProfile: false, lockMethod: 'none'),
    );
    await tester.pump();
    expect(find.text('Journey Forward'), findsNothing);
  });
}
