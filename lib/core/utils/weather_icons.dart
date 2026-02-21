import 'package:flutter/material.dart';

/// Utility class for mapping WMO weather codes to Material Icons.
///
/// This provides a temporary icon mapping using Material Design icons.
/// In the future, these can be replaced with custom SVG icons.
class WeatherIcons {
  /// Returns the appropriate Material Icon for a given WMO weather code.
  ///
  /// WMO weather codes range from 0-99 and represent different weather conditions.
  /// See: https://open-meteo.com/en/docs
  static IconData getIcon(int weatherCode) {
    switch (weatherCode) {
      // Clear sky
      case 0:
      case 1:
        return Icons.wb_sunny;

      // Partly cloudy and overcast
      case 2:
      case 3:
        return Icons.cloud;

      // Fog
      case 45:
      case 48:
        return Icons.cloud;

      // Drizzle
      case 51:
      case 53:
      case 55:
        return Icons.water_drop;

      // Freezing drizzle
      case 56:
      case 57:
        return Icons.ac_unit;

      // Rain
      case 61:
      case 63:
      case 65:
        return Icons.umbrella;

      // Freezing rain
      case 66:
      case 67:
        return Icons.ac_unit;

      // Snow
      case 71:
      case 73:
      case 75:
      case 77:
        return Icons.ac_unit;

      // Rain showers
      case 80:
      case 81:
      case 82:
        return Icons.grain;

      // Snow showers
      case 85:
      case 86:
        return Icons.ac_unit;

      // Thunderstorm
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm;

      // Unknown weather code
      default:
        return Icons.help_outline;
    }
  }
}
