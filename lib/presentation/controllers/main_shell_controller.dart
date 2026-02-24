import 'package:get/get.dart';

class MainShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  /// Tab indices for bottom navigation
  static const int dashboardIndex = 0;
  static const int locationsIndex = 1;
  static const int alertsIndex = 2;
  static const int forecastIndex = 3;
  static const int settingsIndex = 4;

  /// Change active tab
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Navigate to dashboard
  void goDashboard() => changeTab(dashboardIndex);

  /// Navigate to locations
  void goLocations() => changeTab(locationsIndex);

  /// Navigate to weather alerts
  void goAlerts() => changeTab(alertsIndex);

  /// Navigate to forecast details
  void goForecast() => changeTab(forecastIndex);

  /// Navigate to settings
  void goSettings() => changeTab(settingsIndex);
}
