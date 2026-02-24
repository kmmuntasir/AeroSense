import 'package:aero_sense/core/models/weather_alert_response.dart';
import 'package:aero_sense/core/services/alerts_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PastAlert {
  final IconData icon;
  final String title;
  final String location;

  const PastAlert({
    required this.icon,
    required this.title,
    required this.location,
  });
}

/// Controller for the Weather Alerts page.
/// Manages weather alerts fetched from network.
class WeatherAlertsController extends GetxController {
  // Dependencies
  final AlertsProvider _alertsProvider = AlertsProvider();

  // Alert location coordinates (San Francisco, CA)
  final double alertLatitude = 37.7749;
  final double alertLongitude = -122.4194;

  // Reactive variables
  final Rx<WeatherAlert?> _activeAlert = Rx<WeatherAlert?>(null);
  final RxList<WeatherAlert> _allAlerts = <WeatherAlert>[].obs;
  final RxBool _isLoading = RxBool(false);
  final RxString _errorMessage = RxString('');
  final RxBool isExpanded = RxBool(false);

  // Getters
  WeatherAlert? get activeAlert => _activeAlert.value;
  List<WeatherAlert> get allAlerts => _allAlerts;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  // Legacy getters for UI compatibility
  String get alertType => _activeAlert.value != null ? 'ACTIVE WARNING' : '';
  String get alertTitle => _activeAlert.value?.title ?? '';
  String get alertLocation => _activeAlert.value?.location ?? '';
  String get alertUntil => _activeAlert.value?.timeRemaining ?? '';
  String get alertDescription => _activeAlert.value?.description ?? '';
  String get nwsSource => _activeAlert.value?.source ?? 'NATIONAL WEATHER SERVICE';
  String get nwsPreview => _activeAlert.value?.description ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchAlerts();
  }

  /// Fetch alerts from network
  Future<void> fetchAlerts() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final alerts = await _alertsProvider.getMockAlerts(
        latitude: alertLatitude,
        longitude: alertLongitude,
        location: 'San Francisco, CA',
      );

      if (alerts.isEmpty) {
        _activeAlert.value = null;
        _allAlerts.value = [];
        _errorMessage.value = 'No alerts available for this location';
      } else {
        _activeAlert.value = alerts.first;
        _allAlerts.value = alerts;
      }
    } catch (e) {
      _errorMessage.value = 'Failed to fetch alerts: ${e.toString()}';
      _activeAlert.value = null;
      _allAlerts.value = [];
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh alerts
  Future<void> refreshAlerts() => fetchAlerts();

  void toggleExpand() => isExpanded.toggle();

  // Past alerts
  final List<PastAlert> pastAlerts = const [
    PastAlert(
      icon: Icons.cloud_outlined,
      title: 'Dense Fog Advisory',
      location: 'San Francisco Bay Area',
    ),
    PastAlert(
      icon: Icons.device_thermostat_outlined,
      title: 'Heat Advisory',
      location: 'Inland Valleys',
    ),
    PastAlert(
      icon: Icons.water_drop_outlined,
      title: 'Small Craft Advisory',
      location: 'Coastal Waters',
    ),
  ];
}
