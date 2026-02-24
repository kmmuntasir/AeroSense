import 'package:flutter_test/flutter_test.dart';

import 'package:aero_sense/main.dart';

void main() {
  testWidgets('Splash screen shows branding text', (WidgetTester tester) async {
    // runAsync avoids pending-timer assertion from SplashPage's Future.delayed
    await tester.runAsync(() async {
      await tester.pumpWidget(const AeroSenseApp());
      await tester.pump();

      expect(find.text('AeroSense'), findsOneWidget);
      expect(find.text('Making sense of the sky'), findsOneWidget);
    });
  });
}