import 'package:aero_sense/core/models/forecast_response.dart';
import 'package:aero_sense/core/services/api_client.dart';

class ForecastProvider {
  final ApiClient _apiClient;
  static const String _baseUrl = 'https://api.open-meteo.com';
  static const String _forecastPath = '/v1/forecast';

  ForecastProvider({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: _baseUrl);

  /// Fetch detailed forecast for given location
  Future<ForecastResponse> getForecast({
    required double latitude,
    required double longitude,
    String timezone = 'auto',
    int forecastDays = 7,
  }) async {
    try {
      final queryParameters = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly':
            'temperature_2m,apparent_temperature,weather_code,precipitation_probability,wind_speed_10m,relative_humidity_2m,pressure_msl,uv_index,visibility',
        'daily':
            'temperature_2m_max,temperature_2m_min,weather_code,precipitation_sum,precipitation_probability_max,wind_speed_10m_max',
        'current':
            'temperature_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m',
        'timezone': timezone,
        'forecast_days': forecastDays.toString(),
        'temperature_unit': 'fahrenheit',
      };

      final response = await _apiClient.get(
        _forecastPath,
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        throw ApiException('Empty forecast response');
      }

      return ForecastResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch forecast: ${e.toString()}');
    }
  }

  /// Fetch extended forecast for 16 days
  Future<ForecastResponse> getExtendedForecast({
    required double latitude,
    required double longitude,
    String timezone = 'auto',
  }) async {
    return getForecast(
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      forecastDays: 16,
    );
  }

  /// Fetch hourly forecast only for next 24 hours
  Future<ForecastResponse> getHourlyForecast({
    required double latitude,
    required double longitude,
    String timezone = 'auto',
  }) async {
    try {
      final queryParameters = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly':
            'temperature_2m,apparent_temperature,weather_code,precipitation_probability,wind_speed_10m,relative_humidity_2m,pressure_msl,uv_index,visibility',
        'current':
            'temperature_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m',
        'timezone': timezone,
        'temperature_unit': 'fahrenheit',
      };

      final response = await _apiClient.get(
        _forecastPath,
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        throw ApiException('Empty forecast response');
      }

      return ForecastResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch hourly forecast: ${e.toString()}');
    }
  }
}
