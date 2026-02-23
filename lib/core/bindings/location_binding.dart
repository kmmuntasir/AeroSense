import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/location_controller.dart';

class LocationBinding implements Bindings {
  @override
  void dependencies() {
    // permanent: true — persists when navigating from search to dashboard.
    Get.put<LocationController>(LocationController(), permanent: true);
  }
}
