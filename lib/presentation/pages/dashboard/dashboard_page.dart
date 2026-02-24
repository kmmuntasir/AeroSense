import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aero_sense/core/constants/app_colors.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:aero_sense/core/controllers/location_controller.dart';
import 'package:aero_sense/core/models/geocoding_response.dart';
import 'package:aero_sense/presentation/widgets/dashboard/current_weather_hero.dart';
import 'package:aero_sense/presentation/widgets/dashboard/insights_card.dart';
import 'package:aero_sense/presentation/widgets/dashboard/hourly_forecast_list.dart';
import 'package:aero_sense/presentation/widgets/dashboard/daily_forecast_list.dart';
import 'package:aero_sense/presentation/widgets/dashboard/air_quality_card.dart';
import 'package:aero_sense/presentation/widgets/dashboard/wind_card.dart';
import 'package:aero_sense/presentation/widgets/dashboard/humidity_card.dart';
import 'package:aero_sense/presentation/pages/locations/locations_page.dart';

// ── Shell ─────────────────────────────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedNavIndex = 0;

  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    switch (index) {
      case 2:
        // TODO: Navigate to Alerts (Task 11)
        break;
      case 3:
        // TODO: Navigate to Settings (Task 10)
        break;
      default:
        setState(() => _selectedNavIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedNavIndex,
        children: const [_DashboardTab(), LocationsPage()],
      ),
      bottomNavigationBar: _DashboardBottomNav(
        selectedIndex: _selectedNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ── Dashboard tab ─────────────────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  late final WeatherController _weatherController;
  late final LocationController _locationController;
  late final GeocodingResult? _location;

  @override
  void initState() {
    super.initState();
    _weatherController = Get.find<WeatherController>();
    _locationController = Get.find<LocationController>();
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
        locationKey: _location.formattedLocation,
      );
    } else if (_weatherController.currentWeather == null) {
      // GPS-based — only fetch if no data exists yet.
      _weatherController.fetchCurrentWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = _location;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Obx(() {
          // Always read the reactive GPS name so Obx keeps its subscription
          // even when _location is non-null (avoids "improper use" warning).
          final gpsName =
              _locationController.currentLocationAsGeocodingResult?.name;
          final name = _location?.name ?? gpsName ?? 'AeroSense';
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }),
        centerTitle: false,
        actions: [
          if (location != null)
            Obx(() {
              final isSaved = _locationController.savedLocations.any(
                (s) =>
                    s.latitude == location.latitude &&
                    s.longitude == location.longitude,
              );
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  color: isSaved
                      ? AppColors.locationButton
                      : theme.colorScheme.onSurface,
                ),
                onPressed: () async {
                  if (isSaved) {
                    await _locationController.removeLocation(location);
                  } else {
                    await _locationController.saveLocation(location);
                  }
                },
              );
            }),
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
            onPressed: () => Get.toNamed('/search'),
          ),
        ],
      ),
      body: Obx(() {
        if (_weatherController.isLoading &&
            _weatherController.currentWeather == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_weatherController.errorMessage.isNotEmpty &&
            _weatherController.currentWeather == null) {
          return _ErrorView(
            message: _weatherController.errorMessage,
            onRetry: _weatherController.refreshWeather,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _weatherController.refreshWeather();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                CurrentWeatherHero(),
                InsightsCard(),
                HourlyForecastList(),
                DailyForecastList(),
                AirQualityCard(),
                WindCard(),
                HumidityCard(),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onTap,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Locations',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<bool> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
