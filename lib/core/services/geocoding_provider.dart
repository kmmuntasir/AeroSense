import 'dart:math' as math;

import 'package:aero_sense/core/models/geocoding_response.dart';
import 'package:aero_sense/core/services/api_client.dart';
import 'package:dio/dio.dart';

class GeocodingProvider {
  final ApiClient _apiClient;
  final ApiClient _nominatimClient;

  GeocodingProvider()
    : _apiClient = ApiClient(baseUrl: ApiClient.geocodingBaseUrl),
      _nominatimClient = ApiClient(
        baseUrl: 'https://nominatim.openstreetmap.org',
      );

  Future<List<GeocodingResult>> searchLocation({
    required String query,
    int? count = 10,
    String? language = 'en',
    String? format = 'json',
  }) async {
    try {
      final queryParameters = {
        'name': query,
        'count': count.toString(),
        'language': language,
        'format': format,
      };

      final response = await _apiClient.get(
        '/v1/search',
        queryParameters: queryParameters,
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

  Future<GeocodingResult> searchSingleLocation({
    required String query,
    String? language = 'en',
  }) async {
    try {
      final results = await searchLocation(
        query: query,
        count: 1,
        language: language,
      );

      if (results.isEmpty) {
        throw ApiException('Location not found: $query');
      }

      return results.first;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to search single location: ${e.toString()}');
    }
  }

  /// Reverse geocode [latitude]/[longitude] using the Nominatim API
  /// (OpenStreetMap). Returns the nearest city/town/village.
  Future<GeocodingResult> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _nominatimClient.get(
        '/reverse',
        queryParameters: {
          'format': 'json',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'zoom': '10', // city-level granularity
          'addressdetails': '1',
        },
        options: Options(
          headers: {'User-Agent': 'AeroSense/1.0 (weather app)'},
        ),
      );

      final data = response.data;
      if (data == null) {
        throw ApiException('Empty response from Nominatim API');
      }

      final address = data['address'] as Map<String, dynamic>? ?? {};
      // Priority: city > town > village > suburb > county
      final name =
          address['city'] as String? ??
          address['town'] as String? ??
          address['village'] as String? ??
          address['suburb'] as String? ??
          address['county'] as String? ??
          'Unknown';
      final state = address['state'] as String?;
      final country = address['country'] as String? ?? '';
      final countryCode = address['country_code'] as String? ?? '';

      return GeocodingResult(
        latitude: latitude,
        longitude: longitude,
        name: name,
        country: country,
        countryCode: countryCode,
        state: state,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to reverse geocode: ${e.toString()}');
    }
  }

  /// Kept for API compatibility; delegates to [reverseGeocode].
  Future<List<GeocodingResult>> searchByCoordinates({
    required double latitude,
    required double longitude,
    int? count = 10,
    String? language = 'en',
    String? format = 'json',
  }) async {
    try {
      final results = await searchByCoordinates(
        latitude: latitude,
        longitude: longitude,
        count: 1,
        language: language,
      );

      if (results.isEmpty) {
        throw ApiException(
          'No location found for coordinates: $latitude, $longitude',
        );
      }

      return results;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to reverse geocode: ${e.toString()}');
    }
  }

  Future<List<GeocodingResult>> searchWithinBounds({
    required double minLatitude,
    required double minLongitude,
    required double maxLatitude,
    required double maxLongitude,
    int? count = 10,
    String? language = 'en',
  }) async {
    try {
      final queryParameters = {
        'min_latitude': minLatitude.toString(),
        'min_longitude': minLongitude.toString(),
        'max_latitude': maxLatitude.toString(),
        'max_longitude': maxLongitude.toString(),
        'count': count.toString(),
        'language': language,
      };

      final response = await _apiClient.get(
        '/v1/geocoding',
        queryParameters: queryParameters,
      );

      final data = response.data;
      if (data == null) {
        throw ApiException('Empty response from bounded search API');
      }

      return GeocodingResponse.fromJson(data).results;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to search within bounds: ${e.toString()}');
    }
  }

  Future<List<String>> autocompleteLocation({
    required String query,
    int? count = 5,
    String? language = 'en',
  }) async {
    try {
      final results = await searchLocation(
        query: query,
        count: count,
        language: language,
      );

      return results
          .where(
            (result) => result.name.toLowerCase().contains(query.toLowerCase()),
          )
          .map((result) => result.formattedLocation)
          .toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to autocomplete location: ${e.toString()}');
    }
  }

  Future<List<GeocodingResult>> searchByCountry({
    required String countryCode,
    String? state,
    String? language = 'en',
    int? count = 10,
  }) async {
    try {
      final queryParameters = {
        'country_code': countryCode.toUpperCase(),
        'count': count.toString(),
        'language': language,
      };

      if (state != null) {
        queryParameters['state'] = state;
      }

      final response = await _apiClient.get(
        '/v1/geocoding',
        queryParameters: queryParameters,
      );

      final data = response.data;
      if (data == null) {
        throw ApiException('Empty response from country search API');
      }

      return GeocodingResponse.fromJson(data).results;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to search by country: ${e.toString()}');
    }
  }

  /// Validates if coordinates are within valid latitude and longitude ranges
  bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Calculates distance between two coordinates using Haversine formula
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
