import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:aero_sense/core/models/geocoding_response.dart';
import 'package:aero_sense/presentation/widgets/dashboard/current_weather_hero.dart';
import 'package:aero_sense/presentation/widgets/dashboard/insights_card.dart';
import 'package:aero_sense/presentation/widgets/dashboard/hourly_forecast_list.dart';
import 'package:aero_sense/presentation/widgets/dashboard/daily_forecast_list.dart';
import 'package:aero_sense/presentation/widgets/dashboard/air_quality_card.dart';
import 'package:aero_sense/presentation/widgets/dashboard/wind_card.dart';
import 'package:aero_sense/presentation/widgets/dashboard/humidity_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final WeatherController _weatherController;
  late final GeocodingResult? _location;

  @override
  void initState() {
    super.initState();
    _weatherController = Get.find<WeatherController>();
    _location = Get.arguments as GeocodingResult?;

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchWeather());
  }

  void _fetchWeather() {
    if (_location != null) {
      // Explicit city selected from search — clear stale data then fetch fresh.
      _weatherController.clearCurrentWeather();
      _weatherController.fetchWeatherForLocation(
        latitude: _location.latitude,
        longitude: _location.longitude,
        locationName: _location.name,
      );
    } else if (_weatherController.currentWeather == null) {
      // GPS-based — only fetch if no data exists yet.
      _weatherController.fetchCurrentWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _weatherController.fetchCurrentWeather,
          ),
        ],
      ),
      body: Obx(() {
        if (_weatherController.isLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (_weatherController.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(_weatherController.errorMessage),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _weatherController.fetchCurrentWeather,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_weatherController.currentWeather == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return RefreshIndicator(
          onRefresh: () => _weatherController.fetchCurrentWeather(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: const [
              CurrentWeatherHero(),
              SizedBox(height: 16),
              InsightsCard(),
              SizedBox(height: 16),
              HourlyForecastList(),
              SizedBox(height: 16),
              DailyForecastList(),
              SizedBox(height: 16),
              AirQualityCard(),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: WindCard()),
                  SizedBox(width: 12),
                  Expanded(child: HumidityCard()),
                ],
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}
