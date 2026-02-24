import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:aero_sense/core/models/geocoding_response.dart';
import 'package:aero_sense/core/services/geocoding_provider.dart';
import 'package:get_storage/get_storage.dart';

class LocationController extends GetxController {
  // Location services
  final GeocodingProvider _geocodingProvider = GeocodingProvider();
  final GetStorage _storage = GetStorage();

  // Reactive variables
  final Rx<Position?> _currentPosition = Rx<Position?>(null);
  final RxList<GeocodingResult> _savedLocations = RxList<GeocodingResult>([]);
  final RxBool _isLoading = RxBool(false);
  final RxString _errorMessage = RxString('');
  final RxBool _hasPermission = RxBool(false);

  // Getters
  Position? get currentPosition => _currentPosition.value;
  List<GeocodingResult> get savedLocations => _savedLocations;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasPermission => _hasPermission.value;

  @override
  void onInit() {
    super.onInit();
    _initializeLocationData();
    _checkLocationPermission();
  }

  Future<void> _initializeLocationData() async {
    try {
      // Load saved locations from storage
      final savedLocationsData = _storage.read('saved_locations');
      if (savedLocationsData != null) {
        final locations = List<Map<String, dynamic>>.from(savedLocationsData);
        _savedLocations.value = locations
            .map((location) => GeocodingResult.fromJson(location))
            .toList();
      }
    } catch (e) {
      _errorMessage.value = 'Failed to load saved locations: ${e.toString()}';
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      _hasPermission.value = status.isGranted;

      if (status.isDenied) {
        _errorMessage.value =
            'Location permission is required for weather data';
      } else if (status.isPermanentlyDenied) {
        _errorMessage.value =
            'Location permission permanently denied. Please enable in settings.';
      }
    } catch (e) {
      _errorMessage.value =
          'Error checking location permission: ${e.toString()}';
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final status = await Permission.location.request();
      _hasPermission.value = status.isGranted;

      if (status.isGranted) {
        _errorMessage.value = '';
        return true;
      } else if (status.isPermanentlyDenied) {
        _errorMessage.value =
            'Location permission permanently denied. Please enable in settings.';
        return false;
      } else {
        _errorMessage.value = 'Location permission denied';
        return false;
      }
    } catch (e) {
      _errorMessage.value =
          'Error requesting location permission: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get current device location
  Future<bool> getCurrentLocation() async {
    try {
      if (!hasPermission) {
        final granted = await requestLocationPermission();
        if (!granted) return false;
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage.value =
            'Location services are disabled. Please enable location services.';
        return false;
      }

      // Determine position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      _currentPosition.value = position;
      _errorMessage.value = '';
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to get current location: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get location name from coordinates
  Future<String?> getLocationNameFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final result = await _geocodingProvider.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );

      return result.formattedLocation;
    } catch (e) {
      _errorMessage.value = 'Failed to get location name: ${e.toString()}';
      return null;
    }
  }

  /// Search for location by name
  Future<List<GeocodingResult>> searchLocation(String query) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final results = await _geocodingProvider.searchLocation(
        query: query,
        count: 10,
      );

      _errorMessage.value = '';
      return results;
    } catch (e) {
      _errorMessage.value = 'Failed to search location: ${e.toString()}';
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  /// Save a location to favorites
  Future<void> saveLocation(GeocodingResult location) async {
    try {
      // Check if location already exists
      final existingIndex = _savedLocations.indexWhere(
        (saved) =>
            saved.latitude == location.latitude &&
            saved.longitude == location.longitude,
      );

      if (existingIndex == -1) {
        // Add new location
        _savedLocations.add(location);
        _saveLocationsToStorage();
      }
    } catch (e) {
      _errorMessage.value = 'Failed to save location: ${e.toString()}';
    }
  }

  /// Remove a location from favorites
  Future<void> removeLocation(GeocodingResult location) async {
    try {
      _savedLocations.removeWhere(
        (saved) =>
            saved.latitude == location.latitude &&
            saved.longitude == location.longitude,
      );
      _saveLocationsToStorage();
    } catch (e) {
      _errorMessage.value = 'Failed to remove location: ${e.toString()}';
    }
  }

  /// Check if a location is saved
  bool isLocationSaved(GeocodingResult location) {
    return _savedLocations.any(
      (saved) =>
          saved.latitude == location.latitude &&
          saved.longitude == location.longitude,
    );
  }

  /// Get saved locations with formatted names
  List<String> get savedLocationNames {
    return _savedLocations
        .map((location) => location.formattedLocation)
        .toList();
  }

  /// Get current location as GeocodingResult
  GeocodingResult? get currentLocationAsGeocodingResult {
    if (_currentPosition.value == null) return null;

    return GeocodingResult(
      latitude: _currentPosition.value!.latitude,
      longitude: _currentPosition.value!.longitude,
      name: 'Current Location',
      country: '',
      countryCode: '',
    );
  }

  /// Clear current location
  void clearCurrentLocation() {
    _currentPosition.value = null;
    _errorMessage.value = '';
  }

  /// Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  /// Save locations to storage
  void _saveLocationsToStorage() {
    try {
      final locationsJson = _savedLocations
          .map((location) => location.toJson())
          .toList();
      _storage.write('saved_locations', locationsJson);
    } catch (e) {
      _errorMessage.value =
          'Failed to save locations to storage: ${e.toString()}';
    }
  }

  /// Get distance from current location to a target location
  double getDistanceToLocation(GeocodingResult target) {
    if (_currentPosition.value == null) return double.infinity;

    return _geocodingProvider.calculateDistance(
      lat1: _currentPosition.value!.latitude,
      lon1: _currentPosition.value!.longitude,
      lat2: target.latitude,
      lon2: target.longitude,
    );
  }

  /// Check if current location is within a certain radius of a target location
  bool isWithinRadius(GeocodingResult target, {double radiusInKm = 1.0}) {
    final distance = getDistanceToLocation(target);
    return distance <= radiusInKm;
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
