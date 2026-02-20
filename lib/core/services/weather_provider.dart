import 'package:aero_sense/core/models/weather_response.dart';
import 'package:aero_sense/core/services/api_client.dart';
import 'package:aero_sense/core/models/geocoding_response.dart';

class WeatherProvider {
  final ApiClient _apiClient;
  static const String _weatherPath = '/v1/forecast';

  WeatherProvider() : _apiClient = ApiClient();

  Future<WeatherResponse> getCurrentWeather({
    required double latitude,
    required double longitude,
    double? elevation,
    String? timezone = 'auto',
    List<String>? variables = const [
      'temperature_2m',
      'relative_humidity_2m',
      'wind_speed_10m',
      'wind_direction_10m',
      'precipitation',
      'weather_code',
    ],
  }) async {
    try {
      final queryParameters = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': variables?.join(',') ?? '',
        'hourly': variables?.join(',') ?? '',
        'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code,sunrise,sunset',
        'timezone': timezone ?? 'auto',
        'forecast_days': '7',
        'windspeed_unit': 'ms',
        'precipitation_unit': 'mm',
        'temperature_unit': 'celsius',
      };

      if (elevation != null) {
        queryParameters['elevation'] = elevation.toString();
      }

      final response = await _apiClient.get(_weatherPath, queryParameters: queryParameters);
      final data = response.data;

      if (data == null) {
        throw ApiException('Empty response from weather API');
      }

      return WeatherResponse.fromJson(data);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch weather data: ${e.toString()}');
    }
  }

  Future<WeatherResponse> getWeatherByLocationName({
    required String locationName,
    List<String>? variables = const [
      'temperature_2m',
      'relative_humidity_2m',
      'wind_speed_10m',
      'wind_direction_10m',
      'precipitation',
      'weather_code',
    ],
  }) async {
    try {
      // First geocode the location
      final geocodingResult = await searchLocation(locationName);
      if (geocodingResult.isEmpty) {
        throw ApiException('Location not found: $locationName');
      }

      // Use the first result
      final location = geocodingResult.first;

      // Get weather for the geocoded location
      return await getCurrentWeather(
        latitude: location.latitude,
        longitude: location.longitude,
        elevation: location.elevation,
        variables: variables,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch weather by location name: ${e.toString()}');
    }
  }

  Future<List<GeocodingResult>> searchLocation(String query) async {
    try {
      final response = await _apiClient.get(
        '/v1/geocoding',
        queryParameters: {
          'name': query,
          'count': '10',
          'language': 'en',
          'format': 'json',
        },
      );

      final data = response.data;
      if (data == null) {
        throw ApiException('Empty response from geocoding API');
      }

      return GeocodingResponse.fromJson(data).results;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to search location: ${e.toString()}');
    }
  }

  Future<List<WeatherResponse>> getMultipleWeatherLocations({
    required List<String> locationNames,
    List<String>? variables = const [
      'temperature_2m',
      'relative_humidity_2m',
      'wind_speed_10m',
      'wind_direction_10m',
      'precipitation',
      'weather_code',
    ],
  }) async {
    try {
      final results = <WeatherResponse>[];
      final failedLocations = <String>[];

      for (final locationName in locationNames) {
        try {
          final weather = await getWeatherByLocationName(
            locationName: locationName,
            variables: variables,
          );
          results.add(weather);
        } catch (e) {
          failedLocations.add('$locationName: ${e.toString()}');
        }
      }

      // if (failedLocations.isNotEmpty) {
        //   print('Failed to fetch weather for: ${failedLocations.join(', ')}');
      // }

      return results;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch multiple weather locations: ${e.toString()}');
    }
  }

  String getWeatherCodeDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Fog';
      case 48:
        return 'Freezing fog';
      case 51:
        return 'Drizzle: Light intensity';
      case 53:
        return 'Drizzle: Moderate intensity';
      case 55:
        return 'Drizzle: Dense intensity';
      case 56:
        return 'Freezing Drizzle: Light intensity';
      case 57:
        return 'Freezing Drizzle: Dense intensity';
      case 61:
        return 'Rain: Slight intensity';
      case 63:
        return 'Rain: Moderate intensity';
      case 65:
        return 'Rain: Heavy intensity';
      case 66:
        return 'Freezing Rain: Light intensity';
      case 67:
        return 'Freezing Rain: Heavy intensity';
      case 71:
        return 'Snow fall: Slight intensity';
      case 73:
        return 'Snow fall: Moderate intensity';
      case 75:
        return 'Snow fall: Heavy intensity';
      case 77:
        return 'Snow grains';
      case 80:
        return 'Rain showers: Slight';
      case 81:
        return 'Rain showers: Moderate';
      case 82:
        return 'Rain showers: Violent';
      case 85:
        return 'Snow showers: Slight';
      case 86:
        return 'Snow showers: Heavy';
      case 95:
        return 'Thunderstorm: Slight or moderate';
      case 96:
        return 'Thunderstorm with slight hail';
      case 99:
        return 'Thunderstorm with heavy hail';
      default:
        return 'Unknown weather code: $weatherCode';
    }
  }

  String getWindDirection(double windDirection) {
    // Convert degrees to cardinal direction
    if (windDirection >= 348.75 || windDirection < 11.25) return 'N';
    if (windDirection >= 11.25 && windDirection < 33.75) return 'NNE';
    if (windDirection >= 33.75 && windDirection < 56.25) return 'NE';
    if (windDirection >= 56.25 && windDirection < 78.75) return 'ENE';
    if (windDirection >= 78.75 && windDirection < 101.25) return 'E';
    if (windDirection >= 101.25 && windDirection < 123.75) return 'ESE';
    if (windDirection >= 123.75 && windDirection < 146.25) return 'SE';
    if (windDirection >= 146.25 && windDirection < 168.75) return 'SSE';
    if (windDirection >= 168.75 && windDirection < 191.25) return 'S';
    if (windDirection >= 191.25 && windDirection < 213.75) return 'SSW';
    if (windDirection >= 213.75 && windDirection < 236.25) return 'SW';
    if (windDirection >= 236.25 && windDirection < 258.75) return 'WSW';
    if (windDirection >= 258.75 && windDirection < 281.25) return 'W';
    if (windDirection >= 281.25 && windDirection < 303.75) return 'WNW';
    if (windDirection >= 303.75 && windDirection < 326.25) return 'NW';
    if (windDirection >= 326.25 && windDirection < 348.75) return 'NNW';
    return 'Unknown';
  }
}