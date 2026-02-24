import 'package:aero_sense/core/controllers/location_controller.dart';
import 'package:aero_sense/core/models/forecast_response.dart';
import 'package:aero_sense/core/services/forecast_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Tab options for forecast view
enum ForecastTab { hourly, daily, extended }

class ForecastDetailsController extends GetxController {
  // Dependencies
  final ForecastProvider _forecastProvider = ForecastProvider();
  final LocationController _locationController = Get.find<LocationController>();
  final GetStorage _storage = GetStorage();

  // Reactive variables
  final Rx<ForecastResponse?> _forecast = Rx<ForecastResponse?>(null);
  final RxBool _isLoading = RxBool(false);
  final RxString _errorMessage = RxString('');
  final Rx<ForecastTab> _selectedTab = Rx<ForecastTab>(ForecastTab.hourly);
  final RxList<HourlyData> _hourlyForecast = <HourlyData>[].obs;
  final RxList<DailyData> _dailyForecast = <DailyData>[].obs;

  // Cache keys
  static const String _forecastCacheKey = 'forecast_cache';
  static const String _cacheTimestampKey = 'forecast_cache_timestamp';
  static const Duration _cacheDuration = Duration(minutes: 30);

  // Getters
  ForecastResponse? get forecast => _forecast.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  ForecastTab get selectedTab => _selectedTab.value;
  List<HourlyData> get hourlyForecast => _hourlyForecast;
  List<DailyData> get dailyForecast => _dailyForecast;
  CurrentWeather? get currentWeather => _forecast.value?.current;

  @override
  void onInit() {
    super.onInit();
    _initializeForecast();
  }

  /// Initialize forecast on controller load
  Future<void> _initializeForecast() async {
    try {
      final position = _locationController.currentPosition;

      if (position != null) {
        // Try to load from cache first
        await _loadFromCache();
        if (_forecast.value != null) {
          return;
        }
        // If cache miss, fetch from API
        await fetchForecast();
      } else {
        // Get location if not available
        _isLoading.value = true;
        final success = await _locationController.getCurrentLocation();

        if (success && _locationController.currentPosition != null) {
          await fetchForecast();
        } else {
          _errorMessage.value =
              'Unable to get device location. Please enable location services.';
        }
      }
    } catch (e) {
      _errorMessage.value = 'Failed to initialize forecast: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch forecast from API
  Future<void> fetchForecast() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final position = _locationController.currentPosition;

      if (position == null) {
        _errorMessage.value = 'Device location not available';
        return;
      }

      final forecast = await _forecastProvider.getForecast(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _forecast.value = forecast;
      _updateForecastLists();
      _cacheForecast(forecast);
    } catch (e) {
      _errorMessage.value = 'Failed to fetch forecast: ${e.toString()}';
      _forecast.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch extended forecast for 16 days
  Future<void> fetchExtendedForecast() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final position = _locationController.currentPosition;

      if (position == null) {
        _errorMessage.value = 'Device location not available';
        return;
      }

      final forecast = await _forecastProvider.getExtendedForecast(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _forecast.value = forecast;
      _updateForecastLists();
      _cacheForecast(forecast);
    } catch (e) {
      _errorMessage.value =
          'Failed to fetch extended forecast: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh forecast with current location
  Future<void> refreshForecast() async {
    await _locationController.getCurrentLocation();
    await fetchForecast();
  }

  /// Select forecast tab
  void selectTab(ForecastTab tab) {
    _selectedTab.value = tab;
    if (tab == ForecastTab.extended && _dailyForecast.isEmpty) {
      fetchExtendedForecast();
    }
  }

  /// Update hourly and daily forecast lists
  void _updateForecastLists() {
    final forecast = _forecast.value;
    if (forecast != null) {
      _hourlyForecast.value = forecast.hourly.getHoursAhead(24);
      _dailyForecast.value = forecast.daily.getDaysAhead(7);
    }
  }

  /// Cache forecast locally
  void _cacheForecast(ForecastResponse forecast) {
    try {
      _storage.write(_forecastCacheKey, forecast.toJson());
      _storage.write(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Failed to cache forecast: $e');
    }
  }

  /// Load forecast from cache if valid
  Future<void> _loadFromCache() async {
    try {
      final cached = _storage.read<Map>(_forecastCacheKey);
      final timestamp = _storage.read<int>(_cacheTimestampKey);

      if (cached != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final age = DateTime.now().difference(cacheTime);

        if (age < _cacheDuration) {
          _forecast.value = ForecastResponse.fromJson(
            cached.cast<String, dynamic>(),
          );
          _updateForecastLists();
        }
      }
    } catch (e) {
      debugPrint('Failed to load cached forecast: $e');
    }
  }

  /// Get weather condition text from code
  String getWeatherCondition(int weatherCode) {
    const weatherDescriptions = {
      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Foggy',
      48: 'Depositing rime fog',
      51: 'Light drizzle',
      53: 'Moderate drizzle',
      55: 'Dense drizzle',
      61: 'Slight rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      71: 'Slight snow',
      73: 'Moderate snow',
      75: 'Heavy snow',
      77: 'Snow grains',
      80: 'Slight rain showers',
      81: 'Moderate rain showers',
      82: 'Violent rain showers',
      85: 'Slight snow showers',
      86: 'Heavy snow showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with slight hail',
      99: 'Thunderstorm with heavy hail',
    };

    return weatherDescriptions[weatherCode] ?? 'Unknown';
  }
}
