import 'package:get/get.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/onboarding/onboarding_page.dart';
import '../presentation/pages/search/search_page.dart';
import '../presentation/pages/dashboard/dashboard_page.dart';
import '../presentation/bindings/onboarding_binding.dart';
import '../presentation/bindings/dashboard_binding.dart';
import '../core/bindings/location_binding.dart';

class AppPages {
  static const initial = '/splash';

  static final routes = [
    // Splash - in-app animated loader, determines first launch vs returning
    GetPage(
      name: '/splash',
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Onboarding - 3-step PageView for first-launch experience
    GetPage(
      name: '/onboarding',
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Search - fallback when location denied or manual search
    GetPage(
      name: '/search',
      page: () => const SearchPage(),
      binding: LocationBinding(),
      transition: Transition.cupertino,
    ),

    // Dashboard - main weather view
    GetPage(
      name: '/dashboard',
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
