// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aero_sense/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AeroSenseApp());
    await tester.pump(Duration.zero);

    // App shell loads — MaterialApp is present
    expect(find.byType(MaterialApp), findsOneWidget);
  //testWidgets('Splash screen shows branding text', (WidgetTester tester) async {
    // runAsync avoids pending-timer assertion from SplashPage's Future.delayed
    await tester.runAsync(() async {
      await tester.pumpWidget(const AeroSenseApp());
      await tester.pump();

      expect(find.text('AeroSense'), findsOneWidget);
      expect(find.text('Making sense of the sky'), findsOneWidget);
    });
  });
}
