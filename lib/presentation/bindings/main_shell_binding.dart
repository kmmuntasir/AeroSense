import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/location_controller.dart';
import 'package:aero_sense/core/controllers/settings_controller.dart';
import 'package:aero_sense/presentation/controllers/main_shell_controller.dart';

class MainShellBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainShellController>(() => MainShellController());
    Get.lazyPut<SettingsController>(() => SettingsController());
    if (!Get.isRegistered<LocationController>()) {
      Get.lazyPut<LocationController>(() => LocationController());
    }
  }
}
