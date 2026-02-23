import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/settings_controller.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:aero_sense/core/controllers/location_controller.dart';

class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
    // Ensure other controllers are available
    if (!Get.isRegistered<LocationController>()) {
      Get.put(LocationController());
    }
    if (!Get.isRegistered<WeatherController>()) {
      Get.put(WeatherController());
    }
  }
}
