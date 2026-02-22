import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/settings_controller.dart';
import 'package:aero_sense/core/controllers/location_controller.dart';

class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    // LocationController must be registered before SettingsController because
    // WeatherController's field initializer calls Get.find<LocationController>()
    // at construction time. Registering WeatherController here without ensuring
    // LocationController exists first causes an init ordering crash.
    if (!Get.isRegistered<LocationController>()) {
      Get.lazyPut<LocationController>(() => LocationController());
    }
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
