import 'package:get/get.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/onboarding/onboarding_page.dart';
import '../presentation/pages/search/search_page.dart';
import '../presentation/pages/dashboard/dashboard_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/pages/shell/main_shell_page.dart';
import '../presentation/pages/forecast_details/forecast_details_page.dart';
import '../presentation/pages/weather_alerts/weather_alerts_page.dart';
import '../presentation/controllers/forecast_details_controller.dart';
import '../presentation/controllers/weather_alerts_controller.dart';
import '../presentation/bindings/onboarding_binding.dart';
import '../presentation/bindings/main_shell_binding.dart';
import '../presentation/bindings/dashboard_binding.dart';
import '../core/bindings/location_binding.dart';
import '../core/bindings/settings_binding.dart';

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
    // Weather Alerts - standalone for development/testing
    GetPage(
      name: '/weather-alerts',
      page: () => const WeatherAlertsPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => WeatherAlertsController()),
      ),
      transition: Transition.cupertino,
    ),

    // Forecast Details - standalone for development/testing
    GetPage(
      name: '/forecast-details',
      page: () => const ForecastDetailsPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ForecastDetailsController()),
      ),
      transition: Transition.cupertino,
    ),

    // Settings - standalone settings page (for testing)
    GetPage(
      name: '/settings',
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Onboarding - handles permission check and routing
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

    // Main shell - wraps dashboard and settings with bottom nav
    GetPage(
      name: '/main',
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
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
