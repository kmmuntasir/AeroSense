import 'package:get/get.dart';

/// Controller for the Forecast Details page.
/// Currently uses static mock data matching the design.
/// TODO: Accept DailyWeather + WeatherController data when integrated.
class ForecastDetailsController extends GetxController {
  final String formattedDate = 'Monday, Oct 24';
  final int temperature = 72;
  final String condition = 'Partly Cloudy';
  final String weatherEmoji = '⛅';
  final int highTemp = 78;
  final int lowTemp = 65;
  final int feelsLike = 75;
  final String weatherInsight =
      'Expect a mix of sun and clouds with a slight '
      'breeze in the afternoon. Perfect conditions for '
      'flight visibility.';

  final int humidity = 45;
  final int dewPoint = 58;

  final int uvIndex = 4;
  final String uvLabel = 'Moderate';
  final double uvFraction = 4 / 11;

  final int visibility = 10;
  final String visibilityLabel = 'Clear view';

  final int pressure = 1012;
  final String pressureLabel = 'Stable';

  final int peakPercent = 30;

  /// 24-hour precipitation probability (0.0–1.0) — bell curve peaking ~30%.
  final List<double> hourlyPrecip = const [
    0.02,
    0.03,
    0.04,
    0.06,
    0.08,
    0.10,
    0.14,
    0.19,
    0.25,
    0.29,
    0.30,
    0.28,
    0.24,
    0.20,
    0.16,
    0.13,
    0.11,
    0.09,
    0.07,
    0.06,
    0.05,
    0.04,
    0.04,
    0.03,
  ];
}
