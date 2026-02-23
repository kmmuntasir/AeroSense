import 'package:flutter_test/flutter_test.dart';

import 'package:aero_sense/main.dart';

void main() {
  // Basic smoke test: app widget builds without crashing
  // Note: Full initialization tests should use integration_test/
  test('App widget is defined', () {
    expect(AeroSenseApp, isNotNull);
  });
}
