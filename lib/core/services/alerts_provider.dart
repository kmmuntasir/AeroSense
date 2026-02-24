import 'package:aero_sense/core/models/weather_alert_response.dart';
import 'package:aero_sense/core/services/api_client.dart';

class AlertsProvider {
  final ApiClient _apiClient;
  static const String _alertsPath = '/v1/alerts';

  AlertsProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: 'https://api.weather.gov');

  /// Fetch weather alerts for a given location
  Future<List<WeatherAlert>> getAlertsByLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final queryParameters = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'limit': '10',
      };

      final response = await _apiClient.get(
        _alertsPath,
        queryParameters: queryParameters,
      );

      final data = response.data;
      if (data == null) {
        return [];
      }

      if (data is Map<String, dynamic>) {
        final alerts = data['alerts'] as List?;
        if (alerts == null) return [];

        return alerts
            .map((alert) => WeatherAlert.fromJson(alert as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch weather alerts: ${e.toString()}');
    }
  }

  /// Fetch active alerts only
  Future<List<WeatherAlert>> getActiveAlerts({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final alerts = await getAlertsByLocation(
        latitude: latitude,
        longitude: longitude,
      );
      return alerts.where((alert) => !alert.isExpired).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch active alerts: ${e.toString()}');
    }
  }

  /// Fetch alerts by severity level
  Future<List<WeatherAlert>> getAlertsBySeverity({
    required double latitude,
    required double longitude,
    required String severity,
  }) async {
    try {
      final alerts = await getAlertsByLocation(
        latitude: latitude,
        longitude: longitude,
      );
      return alerts
          .where((alert) => alert.severity.toLowerCase() == severity.toLowerCase())
          .toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch alerts by severity: ${e.toString()}');
    }
  }

  /// Get mock alerts for testing/demo (simulates API call)
  Future<List<WeatherAlert>> getMockAlerts({
    required double latitude,
    required double longitude,
    String? location,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      WeatherAlert(
        id: '1',
        title: 'Severe Thunderstorm Warning',
        description: 'A severe thunderstorm capable of producing damaging winds, '
            'heavy rainfall, and frequent lightning is moving through the area.',
        location: location ?? 'San Francisco, CA',
        latitude: latitude,
        longitude: longitude,
        issuedTime: DateTime.now().subtract(const Duration(hours: 2)),
        expiresTime: DateTime.now().add(const Duration(hours: 4)),
        severity: 'Severe',
        source: 'NATIONAL WEATHER SERVICE',
        eventType: 'Severe Thunderstorm Warning',
      ),
      WeatherAlert(
        id: '2',
        title: 'Wind Advisory',
        description: 'Strong winds with gusts up to 40 mph are expected throughout '
            'the afternoon and evening. Secure loose objects and use caution if operating vehicles.',
        location: location ?? 'San Francisco, CA',
        latitude: latitude,
        longitude: longitude,
        issuedTime: DateTime.now().subtract(const Duration(hours: 1)),
        expiresTime: DateTime.now().add(const Duration(hours: 6)),
        severity: 'Moderate',
        source: 'NATIONAL WEATHER SERVICE',
        eventType: 'Wind Advisory',
      ),
    ];
  }
}
