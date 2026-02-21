import 'package:get/get.dart';
import 'package:aero_sense/core/models/weather_response.dart';
import 'package:aero_sense/core/services/weather_provider.dart';
import 'package:aero_sense/core/controllers/location_controller.dart';
import 'package:aero_sense/core/models/temperature_unit.dart';
import 'package:get_storage/get_storage.dart';

class WeatherController extends GetxController {
  // Dependencies
  final WeatherProvider _weatherProvider = WeatherProvider();
  final LocationController _locationController = Get.find<LocationController>();
  final GetStorage _storage = GetStorage();

  // Reactive variables
  final Rx<WeatherResponse?> _currentWeather = Rx<WeatherResponse?>(null);
  final Rx<Map<String, WeatherResponse>> _savedWeatherData = Rx<Map<String, WeatherResponse>>({});
  final RxBool _isLoading = RxBool(false);
  final RxString _errorMessage = RxString('');
  final RxString _meaningInsights = RxString('');

  // Temperature units
  final Rx<TemperatureUnit> _temperatureUnit = Rx<TemperatureUnit>(TemperatureUnit.celsius);

  // Getters
  WeatherResponse? get currentWeather => _currentWeather.value;
  Map<String, WeatherResponse> get savedWeatherData => _savedWeatherData.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get meaningInsights => _meaningInsights.value;
  TemperatureUnit get temperatureUnit => _temperatureUnit.value;
  double get currentTemperature => _currentWeather.value?.current.temperature2M ?? 0.0;
  String get currentLocation => _currentWeather.value != null
      ? '${_currentWeather.value!.latitude.toStringAsFixed(2)}, ${_currentWeather.value!.longitude.toStringAsFixed(2)}'
      : 'Unknown';

  
  @override
  void onInit() {
    super.onInit();
    _initializeWeatherData();
    _updateMeaningInsights();

    // Listen to temperature unit changes
    ever(_temperatureUnit, (TemperatureUnit unit) {
      _updateMeaningInsights();
      if (currentWeather != null) {
        _applyTemperatureUnit();
      }
    });
  }

  Future<void> _initializeWeatherData() async {
    try {
      // Load saved weather data from storage
      final savedWeatherDataJson = _storage.read('saved_weather_data');
      if (savedWeatherDataJson != null) {
        final weatherMap = Map<String, dynamic>.from(savedWeatherDataJson);
        _savedWeatherData.value = weatherMap.map((key, value) =>
          MapEntry(key, WeatherResponse.fromJson(value))
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
      _errorMessage.value = 'Failed to initialize weather data: ${e.toString()}';
    }
  }

  /// Fetch current weather for the current location
  Future<bool> fetchCurrentWeather() async {
    try {
      if (_locationController.currentPosition == null) {
        _errorMessage.value = 'Please enable location services first';
        return false;
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      final position = _locationController.currentPosition!;
      final weather = await _weatherProvider.getCurrentWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _currentWeather.value = weather;
      _errorMessage.value = '';

      // Generate insights
      _updateMeaningInsights();

      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to fetch weather: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch weather for a specific location
  Future<bool> fetchWeatherForLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final weather = await _weatherProvider.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );

      // Store weather data
      final locationKey = locationName ?? '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';
      _savedWeatherData.value = {..._savedWeatherData.value, locationKey: weather};
      _saveWeatherDataToStorage();

      // If this is the current location, update it
      if (_locationController.currentPosition != null &&
          _locationController.currentPosition!.latitude == latitude &&
          _locationController.currentPosition!.longitude == longitude) {
        _currentWeather.value = weather;
        _updateMeaningInsights();
      }

      _errorMessage.value = '';
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to fetch weather: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch weather for multiple saved locations
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
          _savedWeatherData.value = {..._savedWeatherData.value, locationKey: results[i]};
        }
      }

      _saveWeatherDataToStorage();
      _errorMessage.value = '';
    } catch (e) {
      _errorMessage.value = 'Failed to fetch weather for saved locations: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update temperature unit preference
  void setTemperatureUnit(TemperatureUnit unit) {
    _temperatureUnit.value = unit;
    _storage.write('temperature_unit', unit.name);
    _applyTemperatureUnit();
  }

  /// Convert temperature based on current unit
  double convertTemperature(double tempCelsius) {
    switch (_temperatureUnit.value) {
      case TemperatureUnit.celsius:
        return tempCelsius;
      case TemperatureUnit.fahrenheit:
        return (tempCelsius * 9/5) + 32;
    }
  }

  /// Get temperature with unit suffix
  String getTemperatureWithUnit(double tempCelsius) {
    final temp = convertTemperature(tempCelsius);
    final unit = _temperatureUnit.value == TemperatureUnit.celsius ? '°C' : '°F';
    return '${temp.toStringAsFixed(1)}$unit';
  }

  /// Get weather insights and meaning
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

    // Temperature insights
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

    // Humidity insights
    if (humidity > 80) {
      insights += 'High humidity - feels more humid. ';
    } else if (humidity < 30) {
      insights += 'Low humidity - dry conditions. ';
    }

    // Wind insights
    if (windSpeed > 15) {
      insights += 'Strong winds detected. ';
    } else if (windSpeed > 8) {
      insights += 'Moderate winds. ';
    }

    // Weather condition insights
    final condition = _weatherProvider.getWeatherCodeDescription(weatherCode ?? 0);
    insights += 'Conditions: $condition';

    _meaningInsights.value = insights;
  }

  /// Refresh current weather data
  Future<bool> refreshWeather() async {
    return await fetchCurrentWeather();
  }

  /// Clear current weather data
  void clearCurrentWeather() {
    _currentWeather.value = null;
    _errorMessage.value = '';
    _meaningInsights.value = 'No weather data available';
  }

  /// Remove saved weather data for a location
  void removeSavedWeather(String locationKey) {
    _savedWeatherData.value = Map.from(_savedWeatherData.value)..remove(locationKey);
    _saveWeatherDataToStorage();
  }

  /// Get weather forecast for the next 7 days
  List<DailyWeather> get dailyForecast {
    return _currentWeather.value?.daily ?? [];
  }

  /// Get hourly forecast for the next 24 hours
  List<HourlyWeather> get hourlyForecast {
    return _currentWeather.value?.hourly.take(24).toList() ?? [];
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

  /// Get flight suitability message
  String get flightSuitabilityMessage {
    if (!isSuitableForFlight) {
      return 'Current conditions are not suitable for drone flight';
    }
    return 'Conditions are suitable for drone flight';
  }

  // Private helper methods
  void _applyTemperatureUnit() {
    // This method can be extended to update UI when temperature unit changes
    _updateMeaningInsights();
  }

  void _saveWeatherDataToStorage() {
    try {
      final weatherMap = _savedWeatherData.value.map((key, value) =>
        MapEntry(key, value.toJson())
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