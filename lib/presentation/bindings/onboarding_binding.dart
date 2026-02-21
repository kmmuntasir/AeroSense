import 'package:get/get.dart';
import '../../core/controllers/location_controller.dart';

/// OnboardingBinding initializes the LocationController
/// before showing the OnboardingPage.
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationController>(() => LocationController());
  }
}
