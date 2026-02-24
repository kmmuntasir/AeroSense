import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aero_sense/presentation/controllers/main_shell_controller.dart';
import '../dashboard/dashboard_page.dart';
import '../weather_alerts/weather_alerts_page.dart';
import '../forecast_details/forecast_details_page.dart';
import '../settings/settings_page.dart';
import '../locations/locations_page.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainShellController>();

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            DashboardPage(),
            LocationsPage(),
            WeatherAlertsPage(),
            ForecastDetailsPage(),
            SettingsPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on),
              label: 'Locations',
            ),
            NavigationDestination(
              icon: Icon(Icons.warning_outlined),
              selectedIcon: Icon(Icons.warning),
              label: 'Alerts',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Forecast',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
