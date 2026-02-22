import 'package:get/get.dart';
import '../presentation/pages/onboarding/onboarding_page.dart';
import '../presentation/pages/search/search_page.dart';
import '../presentation/pages/dashboard/dashboard_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/bindings/onboarding_binding.dart';
import '../core/bindings/location_binding.dart';
import '../core/bindings/settings_binding.dart';

class AppPages {
  static const initial = '/onboarding';

  static final routes = [
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

    // Dashboard - main weather view
    GetPage(
      name: '/dashboard',
      page: () => const DashboardPage(),
      binding: LocationBinding(),
      transition: Transition.cupertino,
    ),

    // Settings
    GetPage(
      name: '/settings',
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
