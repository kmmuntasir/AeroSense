import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:aero_sense/core/controllers/location_controller.dart';

class WeatherBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeatherController>(() => WeatherController());
    // Location controller should be available before weather controller
    if (!Get.isRegistered<LocationController>()) {
      Get.put(LocationController());
    }
  }
}