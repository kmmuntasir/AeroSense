import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/location_controller.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:aero_sense/presentation/controllers/locations_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    // Only register LocationController if it hasn't been created yet
    // (e.g. direct deep-link to /dashboard bypassing onboarding/search).
    // When coming from onboarding or search it's already permanent — reuse it.
    if (!Get.isRegistered<LocationController>()) {
      Get.put<LocationController>(LocationController(), permanent: true);
    }
    Get.lazyPut<WeatherController>(() => WeatherController());
    Get.lazyPut<LocationsController>(() => LocationsController());
  }
}
