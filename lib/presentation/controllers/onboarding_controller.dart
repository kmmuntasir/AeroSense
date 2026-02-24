import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/controllers/location_controller.dart';

class OnboardingController extends GetxController {
  final LocationController _locationController = Get.find<LocationController>();
  final GetStorage _storage = GetStorage();

  final RxInt currentPage = 0.obs;
  final PageController pageController = PageController();
  bool _locationGranted = false;

  void nextPage() {
    final next = currentPage.value + 1;
    pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    currentPage.value = next;
  }

  Future<void> onEnableLocation() async {
    final granted = await _locationController.requestLocationPermission();
    _locationGranted = granted;
    nextPage();
  }

  void onEnterManually() {
    Get.offAllNamed('/search');
  }

  Future<void> onEnableNotifications() async {
    await Permission.notification.request();
    nextPage();
  }

  void onMaybeLater() {
    nextPage();
  }

  void onGetStarted() {
    _markOnboardingComplete();
    if (_locationGranted) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/search');
    }
  }

  void onSkipSetup() {
    _markOnboardingComplete();
    if (_locationGranted) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/search');
    }
  }

  void _markOnboardingComplete() {
    _storage.write('onboarding_complete', true);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
