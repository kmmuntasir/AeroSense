import 'package:get/get.dart';
import '../../core/controllers/location_controller.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationController>(() => LocationController());
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
