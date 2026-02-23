import 'package:get/get.dart';
import '../../core/controllers/location_controller.dart';

/// OnboardingBinding initializes the LocationController
/// before showing the OnboardingPage.
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // permanent: true — location data (GPS position) must survive route
    // replacement (Get.offAllNamed) so the dashboard can read currentPosition.
    Get.put<LocationController>(LocationController(), permanent: true);
  }
}
