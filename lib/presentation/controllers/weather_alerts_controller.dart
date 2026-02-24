import 'package:aero_sense/core/controllers/location_controller.dart';
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
/// Manages weather alerts fetched from device location using network.
class WeatherAlertsController extends GetxController {
  // Dependencies
  final AlertsProvider _alertsProvider = AlertsProvider();
  final LocationController _locationController = Get.find<LocationController>();

  // Reactive variables
  final Rx<WeatherAlert?> _activeAlert = Rx<WeatherAlert?>(null);
  final RxList<WeatherAlert> _allAlerts = <WeatherAlert>[].obs;
  final RxBool _isLoading = RxBool(false);
  final RxString _errorMessage = RxString('');
  final RxBool isExpanded = RxBool(false);

  // Location coordinates (will be updated from device location)
  late double alertLatitude;
  late double alertLongitude;

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
  String get nwsSource =>
      _activeAlert.value?.source ?? 'NATIONAL WEATHER SERVICE';
  String get nwsPreview => _activeAlert.value?.description ?? '';

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  /// Initialize location and fetch alerts
  Future<void> _initializeLocation() async {
    try {
      final position = _locationController.currentPosition;

      if (position != null) {
        alertLatitude = position.latitude;
        alertLongitude = position.longitude;
        await fetchAlerts();
      } else {
        // Get location if not already available
        _isLoading.value = true;
        final success = await _locationController.getCurrentLocation();

        if (success && _locationController.currentPosition != null) {
          final pos = _locationController.currentPosition!;
          alertLatitude = pos.latitude;
          alertLongitude = pos.longitude;
          await fetchAlerts();
        } else {
          _errorMessage.value =
              'Unable to get device location. Please enable location services.';
        }
      }
    } catch (e) {
      _errorMessage.value = 'Failed to initialize location: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch alerts from network using device location
  Future<void> fetchAlerts() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      // Get current device location
      final position = _locationController.currentPosition;

      if (position == null) {
        _errorMessage.value = 'Device location not available';
        return;
      }

      // Fetch alerts for current location
      final alerts = await _alertsProvider.getMockAlerts(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (alerts.isEmpty) {
        _activeAlert.value = null;
        _allAlerts.value = [];
        _errorMessage.value = 'No alerts available for your location';
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

  /// Refresh alerts with current location
  Future<void> refreshAlerts() async {
    await _locationController.getCurrentLocation();
    await fetchAlerts();
  }

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
