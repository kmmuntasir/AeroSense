import 'dart:math' as math;

import 'package:aero_sense/core/controllers/location_controller.dart';
import 'package:aero_sense/core/models/air_quality_response.dart';
import 'package:aero_sense/core/models/temperature_unit.dart';
import 'package:aero_sense/core/models/weather_response.dart';
import 'package:aero_sense/core/services/air_quality_provider.dart';
import 'package:aero_sense/core/services/weather_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WeatherController extends GetxController {
  // Dependencies
  final WeatherProvider _weatherProvider = WeatherProvider();
  final AirQualityProvider _airQualityProvider = AirQualityProvider();
  final LocationController _locationController = Get.find<LocationController>();
  final GetStorage _storage = GetStorage();

  // Reactive variables
  final Rx<WeatherResponse?> _currentWeather = Rx<WeatherResponse?>(null);
  final Rx<Map<String, WeatherResponse>> _savedWeatherData =
      Rx<Map<String, WeatherResponse>>({});
  final RxBool _isLoading = RxBool(false);
  final RxString _errorMessage = RxString('');
  final RxString _meaningInsights = RxString('');
  final Rx<int?> _currentAqi = Rx<int?>(null);

  // Temperature units
  final Rx<TemperatureUnit> _temperatureUnit = Rx<TemperatureUnit>(
    TemperatureUnit.celsius,
  );

  // ── Getters ────────────────────────────────────────────────────────────────

  WeatherResponse? get currentWeather => _currentWeather.value;
  Map<String, WeatherResponse> get savedWeatherData => _savedWeatherData.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get meaningInsights => _meaningInsights.value;
  TemperatureUnit get temperatureUnit => _temperatureUnit.value;
  int? get currentAqi => _currentAqi.value;

  double get currentTemperature =>
      _currentWeather.value?.current.temperature2M ?? 0.0;

  String get currentLocation => _currentWeather.value != null
      ? '${_currentWeather.value!.latitude.toStringAsFixed(2)}, ${_currentWeather.value!.longitude.toStringAsFixed(2)}'
      : 'Unknown';

  // ── AQI helpers ────────────────────────────────────────────────────────────

  String get aqiLabel {
    final aqi = _currentAqi.value;
    if (aqi == null) return '';
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  String get aqiDescription {
    final aqi = _currentAqi.value;
    if (aqi == null) return '';
    if (aqi <= 50) return 'Air is clean and perfect for outdoor activities.';
    if (aqi <= 100) {
      return 'Acceptable air quality. Sensitive individuals should limit prolonged outdoor exertion.';
    }
    if (aqi <= 150) {
      return 'Sensitive groups may experience health effects. The general public is unlikely to be affected.';
    }
    if (aqi <= 200) {
      return 'Everyone may begin to experience health effects. Limit outdoor activities.';
    }
    if (aqi <= 300) {
      return 'Health alert: serious effects possible for everyone. Avoid prolonged outdoor exertion.';
    }
    return 'Hazardous conditions. Avoid all outdoor activities.';
  }

  // ── Wind helpers ───────────────────────────────────────────────────────────

  /// Wind condition label based on speed in m/s.
  String get windCondition {
    final speed = _currentWeather.value?.current.windSpeed10M ?? 0;
    if (speed < 2) return 'Calm';
    if (speed < 5) return 'Light';
    if (speed < 8) return 'Breezy';
    if (speed < 15) return 'Windy';
    return 'Strong';
  }

  // ── Humidity / dew point ───────────────────────────────────────────────────

  /// Dew point in °C computed via the Magnus formula.
  double? get currentDewPoint {
    final weather = _currentWeather.value;
    if (weather == null) return null;
    final temp = weather.current.temperature2M;
    final rh = weather.current.relativeHumidity2M;
    if (temp == null || rh == null || rh <= 0) return null;

    const double a = 17.625;
    const double b = 243.04;
    final gamma = math.log(rh / 100) + a * temp / (b + temp);
    return b * gamma / (a - gamma);
  }

  String get humidityDescription {
    final rh = _currentWeather.value?.current.relativeHumidity2M ?? 0;
    if (rh < 30) return 'Very dry conditions. Stay hydrated.';
    if (rh < 50) return 'Normal for this time of day.';
    if (rh < 70) return 'Comfortable humidity levels.';
    if (rh < 85) return 'Slightly humid. May feel warmer than it is.';
    return 'High humidity. Outdoor activities may feel uncomfortable.';
  }

  // ── Activity insight helpers ───────────────────────────────────────────────

  String get activityTitle {
    final weather = _currentWeather.value;
    if (weather == null) return '';
    final code = weather.current.weatherCode ?? 0;
    final temp = weather.current.temperature2M ?? 20.0;
    final windSpeed = weather.current.windSpeed10M ?? 0.0;

    if (code >= 95) return 'Stay safe indoors';
    if (code >= 71 && code <= 86) return 'Dress warm for snowy conditions';
    if (code >= 80 && code <= 82) return 'Showers expected today';
    if (code >= 51 && code <= 67) return 'Keep an umbrella handy';
    if (code == 45 || code == 48) return 'Drive with caution today';
    if (temp > 32) return 'Stay hydrated outdoors';
    if (temp < 2) return 'Bundle up for the cold';
    if (windSpeed > 10) return 'Windy conditions outside';
    if (temp >= 15 && temp <= 28) return 'Perfect day for a walk';
    return 'Enjoy the outdoors today';
  }

  String get activityDescription {
    final weather = _currentWeather.value;
    if (weather == null) return '';
    final code = weather.current.weatherCode ?? 0;
    final temp = weather.current.temperature2M ?? 20.0;
    final windSpeed = weather.current.windSpeed10M ?? 0.0;

    if (code >= 95) {
      return 'Thunderstorms in the forecast. Stay inside and keep safe.';
    }
    if (code >= 71 && code <= 86) {
      return 'Snowy conditions. Layer up and watch your step outside.';
    }
    if (code >= 80 && code <= 82) {
      return 'Intermittent showers throughout the day. Carry an umbrella.';
    }
    if (code >= 51 && code <= 67) {
      return 'Rain expected. A waterproof jacket will come in handy.';
    }
    if (code == 45 || code == 48) {
      return 'Low visibility due to fog. Drive carefully today.';
    }
    if (temp > 32) {
      return 'Very warm today. Keep water handy and avoid peak sun hours.';
    }
    if (temp < 2) {
      return 'Near-freezing temperatures. Dress in warm layers before heading out.';
    }
    if (windSpeed > 10) {
      return 'Strong gusts possible. Secure loose items and hold onto your hat.';
    }
    if (temp >= 15 && temp <= 28) {
      return "Conditions are ideal. It's a great time to enjoy a stroll in the park.";
    }
    return 'Comfortable conditions for most outdoor activities.';
  }

  // ── Forecast helpers ───────────────────────────────────────────────────────

  /// 5-day daily forecast.
  List<DailyWeather> get dailyForecast {
    return _currentWeather.value?.daily.take(5).toList() ?? [];
  }

  /// 24-hour forecast starting from the current hour.
  List<HourlyWeather> get hourlyForecast {
    final hourly = _currentWeather.value?.hourly ?? [];
    if (hourly.isEmpty) return [];

    final now = DateTime.now();
    final startIndex = hourly.indexWhere(
      (h) => !h.time.isBefore(DateTime(now.year, now.month, now.day, now.hour)),
    );

    if (startIndex == -1) return hourly.take(24).toList();
    return hourly.skip(startIndex).take(24).toList();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initializeWeatherData();
    _updateMeaningInsights();

    ever(_temperatureUnit, (TemperatureUnit unit) {
      _updateMeaningInsights();
      if (currentWeather != null) _applyTemperatureUnit();
    });
  }

  // ── Public fetch methods ───────────────────────────────────────────────────

  /// Fetch weather (and AQI) for the current GPS position.
  Future<void> _initializeWeatherData() async {
    try {
      // Load saved weather data from storage
      final savedWeatherDataJson = _storage.read('saved_weather_data');
      if (savedWeatherDataJson != null) {
        final weatherMap = Map<String, dynamic>.from(savedWeatherDataJson);
        _savedWeatherData.value = weatherMap.map(
          (key, value) => MapEntry(key, WeatherResponse.fromJson(value)),
        );
      }

      // Load temperature unit preference
      final savedUnit = _storage.read('temperature_unit');
      if (savedUnit != null) {
        _temperatureUnit.value = TemperatureUnit.values.firstWhere(
          (unit) => unit.name == savedUnit,
          orElse: () => TemperatureUnit.celsius,
        );
      }
    } catch (e) {
      _errorMessage.value =
          'Failed to initialize weather data: ${e.toString()}';
    }
  }

  /// Fetch current weather for the current location
  Future<bool> fetchCurrentWeather() async {
    try {
      if (_locationController.currentPosition == null) {
        final located = await _locationController.getCurrentLocation();
        if (!located || _locationController.currentPosition == null) {
          _errorMessage.value =
              _locationController.errorMessage.isNotEmpty
                  ? _locationController.errorMessage
                  : 'Please enable location services first';
          return false;
        }
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      final position = _locationController.currentPosition!;
      await _fetchWeatherAndAqi(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _updateMeaningInsights();
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to fetch weather: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch weather (and AQI) for explicit coordinates (e.g. from city search).
  Future<bool> fetchWeatherForLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await _fetchWeatherAndAqi(latitude: latitude, longitude: longitude);

      // Also persist in saved-weather map
      final locationKey =
          locationName ??
          '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';
      _savedWeatherData.value = {
        ..._savedWeatherData.value,
        locationKey: _currentWeather.value!,
      };
      _saveWeatherDataToStorage();

      _updateMeaningInsights();
      _errorMessage.value = '';
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to fetch weather: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch weather for multiple saved locations.
  Future<void> fetchWeatherForSavedLocations() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final locations = _locationController.savedLocations;
      final results = await _weatherProvider.getMultipleWeatherLocations(
        locationNames: locations.map((loc) => loc.formattedLocation).toList(),
      );

      for (int i = 0; i < locations.length; i++) {
        if (i < results.length) {
          final locationKey = locations[i].formattedLocation;
          _savedWeatherData.value = {
            ..._savedWeatherData.value,
            locationKey: results[i],
          };
        }
      }

      _saveWeatherDataToStorage();
      _errorMessage.value = '';
    } catch (e) {
      _errorMessage.value =
          'Failed to fetch weather for saved locations: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh the currently displayed weather.
  Future<bool> refreshWeather() async {
    final position = _locationController.currentPosition;
    if (position != null) {
      return fetchCurrentWeather();
    }
    // No GPS — re-fetch using the last known coordinates
    final weather = _currentWeather.value;
    if (weather != null) {
      return fetchWeatherForLocation(
        latitude: weather.latitude,
        longitude: weather.longitude,
      );
    }
    return false;
  }

  // ── Temperature helpers ────────────────────────────────────────────────────

  void setTemperatureUnit(TemperatureUnit unit) {
    _temperatureUnit.value = unit;
    _storage.write('temperature_unit', unit.name);
    _applyTemperatureUnit();
  }

  double convertTemperature(double tempCelsius) {
    switch (_temperatureUnit.value) {
      case TemperatureUnit.celsius:
        return tempCelsius;
      case TemperatureUnit.fahrenheit:
        return (tempCelsius * 9 / 5) + 32;
    }
  }

  String getTemperatureWithUnit(double tempCelsius) {
    final temp = convertTemperature(tempCelsius);
    final unit = _temperatureUnit.value == TemperatureUnit.celsius
        ? '°C'
        : '°F';
    return '${temp.toStringAsFixed(0)}$unit';
  }

  /// Just the numeric part + degree symbol (no unit letter), e.g. "22°".
  String getTemperatureDisplay(double tempCelsius) {
    return '${convertTemperature(tempCelsius).toStringAsFixed(0)}°';
  }

  // ── Weather code / wind helpers ────────────────────────────────────────────

  String getWeatherCondition(int? code) {
    return _weatherProvider.getWeatherCodeDescription(code ?? 0);
  }

  String getWindDirection(double degrees) {
    return _weatherProvider.getWindDirection(degrees);
  }

  // ── Flight suitability ─────────────────────────────────────────────────────

  String get flightSuitabilityMessage {
    if (!isSuitableForFlight) {
      return 'Current conditions are not suitable for drone flight';
    }
    return 'Conditions are suitable for drone flight';
  }

  /// Check if current weather is suitable for drone flight
  bool get isSuitableForFlight {
    if (_currentWeather.value == null) return false;

    final weather = _currentWeather.value!;
    final temp = weather.current.temperature2M ?? 0.0;
    final windSpeed = weather.current.windSpeed10M ?? 0.0;
    const precipitationThreshold = 2.0; // mm
    const maxWindSpeed = 15.0; // m/s
    const tempRangeMin = -10.0; // °C
    const tempRangeMax = 40.0; // °C

    // Check temperature range
    if (temp < tempRangeMin || temp > tempRangeMax) {
      return false;
    }

    // Check wind speed
    if (windSpeed > maxWindSpeed) {
      return false;
    }

    // Check precipitation
    if ((weather.current.precipitation ?? 0) > precipitationThreshold) {
      return false;
    }

    return true;
  }

  // ── Misc public ───────────────────────────────────────────────────────────

  void clearCurrentWeather() {
    _currentWeather.value = null;
    _errorMessage.value = '';
    _currentAqi.value = null;
    _meaningInsights.value = 'No weather data available';
  }

  void removeSavedWeather(String locationKey) {
    _savedWeatherData.value = Map.from(_savedWeatherData.value)
      ..remove(locationKey);
    _saveWeatherDataToStorage();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Fetch weather and AQI concurrently; updates reactive state.
  Future<void> _fetchWeatherAndAqi({
    required double latitude,
    required double longitude,
  }) async {
    final results = await Future.wait([
      _weatherProvider.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      ),
      _airQualityProvider
          .getAirQuality(latitude: latitude, longitude: longitude)
          .catchError((_) => AirQualityResponse()),
    ]);

    _currentWeather.value = results[0] as WeatherResponse;
    _currentAqi.value = (results[1] as AirQualityResponse).usAqi;
  }

  void _updateMeaningInsights() {
    if (_currentWeather.value == null) {
      _meaningInsights.value = 'No weather data available';
      return;
    }

    final weather = _currentWeather.value!;
    final temp = weather.current.temperature2M ?? 0.0;
    final humidity = weather.current.relativeHumidity2M ?? 0.0;
    final windSpeed = weather.current.windSpeed10M ?? 0.0;
    final weatherCode = weather.current.weatherCode;

    String insights = '';

    if (temp < 0) {
      insights += 'Freezing conditions detected. ';
    } else if (temp < 10) {
      insights += 'Cold weather. ';
    } else if (temp < 20) {
      insights += 'Mild temperature. ';
    } else if (temp < 30) {
      insights += 'Warm weather. ';
    } else {
      insights += 'Hot weather. ';
    }

    if (humidity > 80) {
      insights += 'High humidity — feels more humid. ';
    } else if (humidity < 30) {
      insights += 'Low humidity — dry conditions. ';
    }

    if (windSpeed > 15) {
      insights += 'Strong winds detected. ';
    } else if (windSpeed > 8) {
      insights += 'Moderate winds. ';
    }

    // Weather condition insights
    final condition = _weatherProvider.getWeatherCodeDescription(
      weatherCode ?? 0,
    );
    insights += 'Conditions: $condition';

    _meaningInsights.value = insights;
  }

  // Private helper methods
  void _applyTemperatureUnit() {
    _updateMeaningInsights();
  }

  void _saveWeatherDataToStorage() {
    try {
      final weatherMap = _savedWeatherData.value.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      _storage.write('saved_weather_data', weatherMap);
    } catch (e) {
      _errorMessage.value = 'Failed to save weather data: ${e.toString()}';
    }
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
