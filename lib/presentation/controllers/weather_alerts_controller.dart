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
/// Uses static mock data matching the design.
class WeatherAlertsController extends GetxController {
  // Active alert
  final String alertType = 'ACTIVE WARNING';
  final String alertTitle = 'Severe Thunderstorm';
  final String alertLocation = 'San Francisco, CA';
  final String alertUntil = 'Until 6:00 PM';
  final String alertDescription =
      'Expect high winds, heavy rain, and possible hail. '
      'Seek shelter immediately and stay away from windows.';
  final String nwsSource = 'NATIONAL WEATHER SERVICE';
  final String nwsPreview =
      'A line of severe thunderstorms will move east at '
      '45 mph. Wind gusts up to 60 mph are likely...';

  // Alert location coordinates (San Francisco, CA)
  final double alertLatitude = 37.7749;
  final double alertLongitude = -122.4194;

  final RxBool isExpanded = false.obs;

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
