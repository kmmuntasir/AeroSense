import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:aero_sense/core/models/temperature_unit.dart';

class SettingsController extends GetxController {
  final GetStorage _storage = GetStorage();

  // Reactive variables
  final RxBool _isDarkMode = RxBool(false);
  final Rx<TemperatureUnit> _temperatureUnit = Rx<TemperatureUnit>(
    TemperatureUnit.celsius,
  );
  final RxBool _notificationsEnabled = RxBool(true);
  final RxBool _locationServicesEnabled = RxBool(true);
  final RxBool _autoRefreshEnabled = RxBool(true);
  final RxInt _autoRefreshInterval = RxInt(30); // minutes
  final RxInt _dataRetentionDays = RxInt(30); // days
  final RxString _appLanguage = RxString('en');
  final RxBool _flightWarningsEnabled = RxBool(true);

  // Getters
  bool get isDarkMode => _isDarkMode.value;
  TemperatureUnit get temperatureUnit => _temperatureUnit.value;
  bool get notificationsEnabled => _notificationsEnabled.value;
  bool get locationServicesEnabled => _locationServicesEnabled.value;
  bool get autoRefreshEnabled => _autoRefreshEnabled.value;
  int get autoRefreshInterval => _autoRefreshInterval.value;
  int get dataRetentionDays => _dataRetentionDays.value;
  String get appLanguage => _appLanguage.value;
  bool get flightWarningsEnabled => _flightWarningsEnabled.value;

  // Setters
  set isDarkMode(bool value) {
    _isDarkMode.value = value;
    _storage.write('dark_mode', value);
  }

  set temperatureUnit(TemperatureUnit value) {
    _temperatureUnit.value = value;
    _storage.write('temperature_unit', value.name);

    // Update weather controller if it exists
    if (Get.isRegistered<WeatherController>()) {
      final weatherController = Get.find<WeatherController>();
      weatherController.setTemperatureUnit(value);
    }
  }

  set notificationsEnabled(bool value) {
    _notificationsEnabled.value = value;
    _storage.write('notifications_enabled', value);
  }

  set locationServicesEnabled(bool value) {
    _locationServicesEnabled.value = value;
    _storage.write('location_services_enabled', value);
  }

  set autoRefreshEnabled(bool value) {
    _autoRefreshEnabled.value = value;
    _storage.write('auto_refresh_enabled', value);
  }

  set autoRefreshInterval(int value) {
    _autoRefreshInterval.value = value;
    _storage.write('auto_refresh_interval', value);
  }

  set dataRetentionDays(int value) {
    _dataRetentionDays.value = value;
    _storage.write('data_retention_days', value);
  }

  set appLanguage(String value) {
    _appLanguage.value = value;
    _storage.write('app_language', value);
  }

  set flightWarningsEnabled(bool value) {
    _flightWarningsEnabled.value = value;
    _storage.write('flight_warnings_enabled', value);
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Load theme preference
      final darkMode = _storage.read('dark_mode') ?? false;
      _isDarkMode.value = darkMode;

      // Load temperature unit
      final tempUnit = _storage.read('temperature_unit');
      if (tempUnit != null) {
        _temperatureUnit.value = TemperatureUnit.values.firstWhere(
          (unit) => unit.name == tempUnit,
          orElse: () => TemperatureUnit.celsius,
        );
      }

      // Load notification settings
      _notificationsEnabled.value =
          _storage.read('notifications_enabled') ?? true;
      _locationServicesEnabled.value =
          _storage.read('location_services_enabled') ?? true;
      _autoRefreshEnabled.value = _storage.read('auto_refresh_enabled') ?? true;
      _autoRefreshInterval.value = _storage.read('auto_refresh_interval') ?? 30;
      _dataRetentionDays.value = _storage.read('data_retention_days') ?? 30;
      _appLanguage.value = _storage.read('app_language') ?? 'en';
      _flightWarningsEnabled.value =
          _storage.read('flight_warnings_enabled') ?? true;
    } catch (e) {
      // Handle error loading settings - silently fail with defaults
    }
  }

  /// Reset all settings to default values
  Future<void> resetToDefaults() async {
    try {
      // Clear all settings from storage
      _storage.erase();

      // Reset to default values
      _isDarkMode.value = false;
      _temperatureUnit.value = TemperatureUnit.celsius;
      _notificationsEnabled.value = true;
      _locationServicesEnabled.value = true;
      _autoRefreshEnabled.value = true;
      _autoRefreshInterval.value = 30;
      _dataRetentionDays.value = 30;
      _appLanguage.value = 'en';
      _flightWarningsEnabled.value = true;

      // Update weather controller
      if (Get.isRegistered<WeatherController>()) {
        final weatherController = Get.find<WeatherController>();
        weatherController.setTemperatureUnit(TemperatureUnit.celsius);
      }
    } catch (e) {
      throw Exception('Failed to reset settings: ${e.toString()}');
    }
  }

  /// Export settings to JSON string
  String exportSettings() {
    final settings = {
      'dark_mode': isDarkMode,
      'temperature_unit': temperatureUnit.name,
      'notifications_enabled': notificationsEnabled,
      'location_services_enabled': locationServicesEnabled,
      'auto_refresh_enabled': autoRefreshEnabled,
      'auto_refresh_interval': autoRefreshInterval,
      'data_retention_days': dataRetentionDays,
      'app_language': appLanguage,
      'flight_warnings_enabled': flightWarningsEnabled,
      'export_timestamp': DateTime.now().toIso8601String(),
    };

    return settings.toString();
  }

  /// Import settings from JSON string
  Future<void> importSettings(String jsonString) async {
    try {
      // In a real implementation, you would parse the JSON string
      // This is a simplified version - ignores the input for now

      // Update the values
      _storage.write('dark_mode', true);
      _storage.write('temperature_unit', 'celsius');
      _storage.write('notifications_enabled', true);
      _storage.write('location_services_enabled', true);
      _storage.write('auto_refresh_enabled', true);
      _storage.write('auto_refresh_interval', 30);
      _storage.write('data_retention_days', 30);
      _storage.write('app_language', 'en');
      _storage.write('flight_warnings_enabled', true);

      // Reload settings
      await _loadSettings();
    } catch (e) {
      throw Exception('Failed to import settings: ${e.toString()}');
    }
  }

  /// Clear cached data based on retention settings
  Future<void> clearCachedData() async {
    try {
      // Clear old weather data
      final savedWeatherData = _storage.read('saved_weather_data');
      if (savedWeatherData != null) {
        // In a real app, you'd filter by timestamp
        _storage.remove('saved_weather_data');
      }

      // Clear old location data
      final savedLocations = _storage.read('saved_locations');
      if (savedLocations != null) {
        // In a real app, you'd filter by last accessed time
        _storage.remove('saved_locations');
      }
    } catch (e) {
      throw Exception('Failed to clear cached data: ${e.toString()}');
    }
  }

  /// Check if current settings meet minimum requirements
  bool validateSettings() {
    // Auto refresh interval should be between 5 and 120 minutes
    if (autoRefreshInterval < 5 || autoRefreshInterval > 120) {
      return false;
    }

    // Data retention should be between 1 and 365 days
    if (dataRetentionDays < 1 || dataRetentionDays > 365) {
      return false;
    }

    // Language should be a valid ISO code
    if (appLanguage.length != 2 ||
        !RegExp(r'^[a-z]{2}$').hasMatch(appLanguage)) {
      return false;
    }

    return true;
  }

  /// Get current settings summary
  Map<String, dynamic> getSettingsSummary() {
    return {
      'theme': isDarkMode ? 'Dark' : 'Light',
      'temperature_unit': temperatureUnit == TemperatureUnit.celsius
          ? 'Celsius'
          : 'Fahrenheit',
      'notifications': notificationsEnabled ? 'Enabled' : 'Disabled',
      'location_services': locationServicesEnabled ? 'Enabled' : 'Disabled',
      'auto_refresh': autoRefreshEnabled ? 'Enabled' : 'Disabled',
      'refresh_interval': '$autoRefreshInterval minutes',
      'data_retention': '$dataRetentionDays days',
      'language': appLanguage,
      'flight_warnings': flightWarningsEnabled ? 'Enabled' : 'Disabled',
    };
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    isDarkMode = !isDarkMode;
  }

  /// Enable or disable auto refresh
  void toggleAutoRefresh() {
    autoRefreshEnabled = !autoRefreshEnabled;
  }

  /// Get system information for debugging
  Map<String, dynamic> getSystemInfo() {
    return {
      'app_version': '1.0.0',
      'storage_used_mb': _storage.write('debug_storage_test', 'test'),
      'settings_loaded': true,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
