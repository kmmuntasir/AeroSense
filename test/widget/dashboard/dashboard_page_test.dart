import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:aero_sense/core/controllers/location_controller.dart';
import 'package:aero_sense/core/models/weather_response.dart';
import 'package:aero_sense/presentation/pages/dashboard/dashboard_page.dart';

// Minimal stub controllers for widget testing
class _StubLocationController extends LocationController {}

class _StubWeatherController extends WeatherController {
  final Rx<WeatherResponse?> _stubWeather = Rx<WeatherResponse?>(null);
  final RxBool _stubLoading = RxBool(false);
  final RxString _stubError = RxString('');
  final RxString _stubInsights = RxString('');

  @override
  WeatherResponse? get currentWeather => _stubWeather.value;

  @override
  bool get isLoading => _stubLoading.value;

  @override
  String get errorMessage => _stubError.value;

  @override
  String get meaningInsights => _stubInsights.value;

  void setLoading(bool v) => _stubLoading.value = v;
  void setError(String v) => _stubError.value = v;
  void setWeather(WeatherResponse? v) => _stubWeather.value = v;
  void setInsights(String v) => _stubInsights.value = v;

  @override
  Future<bool> fetchCurrentWeather() async => true;

  @override
  Future<bool> refreshWeather() async => true;

  @override
  Future<bool> fetchWeatherForLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async => true;
}

Widget _buildTestApp({_StubWeatherController? weatherController}) {
  // LocationController must be registered before WeatherController,
  // because WeatherController's constructor calls Get.find<LocationController>()
  Get.put<LocationController>(_StubLocationController());
  final wc = weatherController ?? _StubWeatherController();
  Get.put<WeatherController>(wc);

  return const GetMaterialApp(home: DashboardPage());
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('DashboardPage', () {
    testWidgets('shows loading indicator when loading with no data', (
      tester,
    ) async {
      // Arrange: register LocationController first, then build stub.
      // pump(Duration.zero) drains the GetStorage init timer on first use.
      Get.put<LocationController>(_StubLocationController());
      final wc = _StubWeatherController();
      wc.setLoading(true);
      Get.put<WeatherController>(wc);

      await tester.pumpWidget(const GetMaterialApp(home: DashboardPage()));
      await tester.pump(Duration.zero);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error view when error and no data', (tester) async {
      Get.put<LocationController>(_StubLocationController());
      final wc = _StubWeatherController();
      wc.setError('Failed to fetch weather');
      Get.put<WeatherController>(wc);

      await tester.pumpWidget(const GetMaterialApp(home: DashboardPage()));
      // pump(Duration.zero) drains the GetStorage init timer and fires
      // addPostFrameCallback from StatefulWidget initState
      await tester.pump(Duration.zero);

      expect(find.text('Failed to fetch weather'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows RefreshIndicator when data is available', (
      tester,
    ) async {
      Get.put<LocationController>(_StubLocationController());
      final wc = _StubWeatherController();
      wc.setWeather(_makeWeatherResponse());
      Get.put<WeatherController>(wc);

      await tester.pumpWidget(const GetMaterialApp(home: DashboardPage()));
      await tester.pump(Duration.zero);

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('shows AeroSense title when no location argument', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump(Duration.zero);

      expect(find.text('AeroSense'), findsOneWidget);
    });

    testWidgets('shows bottom navigation bar with 4 destinations', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump(Duration.zero);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Settings'), findsWidgets);
    });
  });
}

WeatherResponse _makeWeatherResponse() {
  return WeatherResponse(
    latitude: 51.5,
    longitude: -0.1,
    elevation: 10,
    current: CurrentWeather(
      time: DateTime.now(),
      temperature2M: 22.0,
      apparentTemperature: 21.0,
      relativeHumidity2M: 60,
      windSpeed10M: 5.0,
      windDirection10M: 180,
      weatherCode: 1,
      precipitation: 0,
    ),
    hourly: [],
    daily: [],
  );
}
