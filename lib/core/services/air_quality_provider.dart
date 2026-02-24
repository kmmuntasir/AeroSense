import 'package:aero_sense/core/models/air_quality_response.dart';
import 'package:aero_sense/core/services/api_client.dart';

class AirQualityProvider {
  static const String _baseUrl = 'https://air-quality-api.open-meteo.com';
  final ApiClient _apiClient;

  AirQualityProvider() : _apiClient = ApiClient(baseUrl: _baseUrl);

  Future<AirQualityResponse> getAirQuality({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.get(
        '/v1/air-quality',
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current': 'us_aqi',
        },
      );

      if (response.data == null) {
        throw ApiException('Empty response from air quality API');
      }

      return AirQualityResponse.fromJson(response.data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch air quality: ${e.toString()}');
    }
  }
}
