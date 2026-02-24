import 'package:aero_sense/core/controllers/location_controller.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:aero_sense/core/models/geocoding_response.dart';
import 'package:aero_sense/core/models/weather_response.dart';
import 'package:get/get.dart';

class LocationsController extends GetxController {
  final LocationController _locationController = Get.find<LocationController>();
  final WeatherController _weatherController = Get.find<WeatherController>();

  final RxBool isLoadingWeather = false.obs;

  List<GeocodingResult> get savedLocations =>
      _locationController.savedLocations;

  GeocodingResult? get currentLocation =>
      _locationController.currentLocationAsGeocodingResult;

  WeatherResponse? get currentWeather => _weatherController.currentWeather;

  @override
  void onInit() {
    super.onInit();
    _loadSavedWeather();
  }

  Future<void> _loadSavedWeather() async {
    if (_locationController.savedLocations.isEmpty) return;
    isLoadingWeather.value = true;
    await _weatherController.fetchWeatherForSavedLocations();
    isLoadingWeather.value = false;
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
