import 'package:flutter_test/flutter_test.dart';
import 'package:aero_sense/core/constants/wmo_icons.dart';

void main() {
  group('WmoIcons.getIconPath', () {
    test('returns clear_day for code 0', () {
      expect(WmoIcons.getIconPath(0), 'assets/icons/weather/clear_day.svg');
    });

    test('returns clear_day for code 1', () {
      expect(WmoIcons.getIconPath(1), 'assets/icons/weather/clear_day.svg');
    });

    test('returns partly_cloudy for code 2', () {
      expect(WmoIcons.getIconPath(2), 'assets/icons/weather/partly_cloudy.svg');
    });

    test('returns cloudy for code 3', () {
      expect(WmoIcons.getIconPath(3), 'assets/icons/weather/cloudy.svg');
    });

    test('returns fog for code 45', () {
      expect(WmoIcons.getIconPath(45), 'assets/icons/weather/fog.svg');
    });

    test('returns fog for code 48', () {
      expect(WmoIcons.getIconPath(48), 'assets/icons/weather/fog.svg');
    });

    test('returns drizzle for code 51', () {
      expect(WmoIcons.getIconPath(51), 'assets/icons/weather/drizzle.svg');
    });

    test('returns drizzle for code 57', () {
      expect(WmoIcons.getIconPath(57), 'assets/icons/weather/drizzle.svg');
    });

    test('returns rain for code 61', () {
      expect(WmoIcons.getIconPath(61), 'assets/icons/weather/rain.svg');
    });

    test('returns rain for code 80', () {
      expect(WmoIcons.getIconPath(80), 'assets/icons/weather/rain.svg');
    });

    test('returns snow for code 71', () {
      expect(WmoIcons.getIconPath(71), 'assets/icons/weather/snow.svg');
    });

    test('returns snow for code 85', () {
      expect(WmoIcons.getIconPath(85), 'assets/icons/weather/snow.svg');
    });

    test('returns thunderstorm for code 95', () {
      expect(WmoIcons.getIconPath(95), 'assets/icons/weather/thunderstorm.svg');
    });

    test('returns thunderstorm for code 99', () {
      expect(WmoIcons.getIconPath(99), 'assets/icons/weather/thunderstorm.svg');
    });

    test('returns cloudy for null code', () {
      expect(WmoIcons.getIconPath(null), 'assets/icons/weather/cloudy.svg');
    });

    test('returns cloudy for unknown code', () {
      expect(WmoIcons.getIconPath(999), 'assets/icons/weather/cloudy.svg');
    });
  });
}
