import 'package:aero_sense/core/controllers/location_controller.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:aero_sense/core/models/geocoding_response.dart';
import 'package:aero_sense/core/models/weather_response.dart';
import 'package:get/get.dart';

class LocationsController extends GetxController {
  final LocationController _locationController = Get.find<LocationController>();
  final WeatherController _weatherController = Get.find<WeatherController>();

  final RxBool isLoadingWeather = false.obs;
  final RxBool isFetchingCurrentPosition = false.obs;
  final Rx<WeatherResponse?> _currentLocationWeather = Rx<WeatherResponse?>(
    null,
  );

  bool get hasLocationPermission => _locationController.hasPermission;

  List<GeocodingResult> get savedLocations =>
      _locationController.savedLocations;

  GeocodingResult? get currentLocation =>
      _locationController.currentLocationAsGeocodingResult;

  /// Weather for the GPS current location — fetched independently so it
  /// is never overwritten by a city-search dashboard fetch.
  WeatherResponse? get currentLocationWeather =>
      _currentLocationWeather.value ?? _weatherController.currentWeather;

  @override
  void onInit() {
    super.onInit();
    ever(_locationController.savedLocations, _onSavedLocationsChanged);
  }

  @override
  void onReady() {
    super.onReady();
    _ensureCurrentLocation();
    _loadSavedWeather();
  }

  void _onSavedLocationsChanged(List<GeocodingResult> locations) {
    if (isLoadingWeather.value && locations.isNotEmpty) return;
    if (locations.isEmpty) {
      isLoadingWeather.value = false;
      return;
    }
    _loadSavedWeather();
  }

  /// Fetch GPS position if not yet available so the current-location card
  /// has data to display as soon as the Locations tab is opened.
  Future<void> _ensureCurrentLocation() async {
    if (_locationController.currentPosition == null) {
      if (!_locationController.hasPermission) return;
      isFetchingCurrentPosition.value = true;
      await _locationController.getCurrentLocation();
      isFetchingCurrentPosition.value = false;
    }
    await _fetchCurrentLocationWeather();
  }

  Future<void> _fetchCurrentLocationWeather() async {
    final position = _locationController.currentPosition;
    if (position == null) return;
    final weather = await _weatherController.fetchWeatherForCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    if (weather != null) _currentLocationWeather.value = weather;
  }

  Future<void> _loadSavedWeather() async {
    if (_locationController.savedLocations.isEmpty) {
      isLoadingWeather.value = false;
      return;
    }
    try {
      isLoadingWeather.value = true;
      await _weatherController.fetchWeatherForSavedLocations();
    } finally {
      isLoadingWeather.value = false;
    }
  }

  WeatherResponse? weatherFor(GeocodingResult location) =>
      _weatherController.savedWeatherData[location.formattedLocation];

  String temperatureDisplay(double? tempC) {
    if (tempC == null) return '--°';
    return _weatherController.getTemperatureDisplay(tempC);
  }

  Future<void> removeLocation(GeocodingResult location) async {
    await _locationController.removeLocation(location);
    _weatherController.removeSavedWeather(location.formattedLocation);
  }

  void navigateToCitySearch() => Get.toNamed('/search');

  void navigateToLocation(GeocodingResult loc) =>
      Get.toNamed('/dashboard', arguments: loc);

  void navigateToCurrentLocation() => Get.toNamed('/dashboard');
}
