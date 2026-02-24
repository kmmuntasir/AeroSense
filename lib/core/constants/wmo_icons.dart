class WmoIcons {
  static const String _base = 'assets/icons/weather';

  /// Returns the SVG asset path for a given WMO weather code.
  /// Falls back to [cloudy] for unknown codes.
  static String getIconPath(int? code) {
    if (code == null) return '$_base/cloudy.svg';

    if (code == 0 || code == 1) return '$_base/clear_day.svg';
    if (code == 2) return '$_base/partly_cloudy.svg';
    if (code == 3) return '$_base/cloudy.svg';
    if (code == 45 || code == 48) return '$_base/fog.svg';
    if (code >= 51 && code <= 57) return '$_base/drizzle.svg';
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return '$_base/rain.svg';
    }
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return '$_base/snow.svg';
    }
    if (code >= 95 && code <= 99) return '$_base/thunderstorm.svg';

    return '$_base/cloudy.svg';
  }
}
