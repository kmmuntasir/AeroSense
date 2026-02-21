import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/geocoding_response.dart';
import '../../../core/controllers/weather_controller.dart';
import '../../../core/services/weather_provider.dart';
import '../../../core/utils/weather_icons.dart';

/// DashboardPage displays the weather information for a selected location.
///
/// This page shows current weather conditions including temperature, humidity,
/// wind speed, precipitation, and meaningful insights. It supports pull-to-refresh
/// for manually updating weather data.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch weather data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<WeatherController>().fetchCurrentWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get location passed from onboarding/search
    final location = Get.arguments as GeocodingResult?;
    final controller = Get.find<WeatherController>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: theme.colorScheme.primary),
          onPressed: () {
            // TODO: Open locations drawer (Task 9)
          },
        ),
        title: Text(
          location?.name ?? 'AeroSense',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              location != null ? Icons.star : Icons.star_border,
              color: location != null ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            onPressed: () {
              // TODO: Toggle favorite (Task 9)
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: theme.colorScheme.primary),
            onPressed: () {
              // TODO: Open settings (Task 10)
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshWeather(),
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Obx(() {
            // Show loading state on initial load
            if (controller.isLoading && controller.currentWeather == null) {
              return _buildLoadingState(context);
            }

            // Show error state if there's an error
            if (controller.errorMessage.isNotEmpty && controller.currentWeather == null) {
              return _buildErrorState(context, controller.errorMessage);
            }

            // Show dashboard content
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildLocationHeader(context, location),
                _buildTemperatureDisplay(context),
                _buildSecondaryDataRow(context),
                _buildMeaningfulInsightsCard(context),
                const SizedBox(height: 32),
                // Placeholder for future hourly/daily forecast sections
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Builds the location header with icon and name.
  Widget _buildLocationHeader(BuildContext context, GeocodingResult? location) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            location?.formattedLocation ?? 'Current Location',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main temperature display with weather icon and condition.
  Widget _buildTemperatureDisplay(BuildContext context) {
    final controller = Get.find<WeatherController>();
    final theme = Theme.of(context);
    final weather = controller.currentWeather?.current;

    if (weather == null) return const SizedBox.shrink();

    final temp = weather.temperature2M ?? 0.0;
    final weatherCode = weather.weatherCode ?? 0;
    final displayTemp = controller.getTemperatureWithUnit(temp);
    final weatherProvider = WeatherProvider();

    return Column(
      children: [
        // Weather icon
        Icon(
          WeatherIcons.getIcon(weatherCode),
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),

        // Temperature
        Text(
          displayTemp,
          style: theme.textTheme.displayLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),

        // Weather condition description
        Text(
          weatherProvider.getWeatherCodeDescription(weatherCode),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the secondary data row with humidity, wind, and precipitation.
  Widget _buildSecondaryDataRow(BuildContext context) {
    final controller = Get.find<WeatherController>();
    final weather = controller.currentWeather?.current;

    if (weather == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSecondaryItem(
            context,
            Icons.water_drop,
            'Humidity',
            '${weather.relativeHumidity2M?.toInt() ?? 0}%',
          ),
          _buildSecondaryItem(
            context,
            Icons.air,
            'Wind',
            '${weather.windSpeed10M?.toInt() ?? 0} m/s',
          ),
          _buildSecondaryItem(
            context,
            Icons.umbrella,
            'Precipitation',
            '${weather.precipitation?.toStringAsFixed(1) ?? '0.0'} mm',
          ),
        ],
      ),
    );
  }

  /// Builds a single secondary data item with icon, label, and value.
  Widget _buildSecondaryItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// Builds the meaningful insights card.
  Widget _buildMeaningfulInsightsCard(BuildContext context) {
    final controller = Get.find<WeatherController>();
    final theme = Theme.of(context);
    final weatherCode = controller.currentWeather?.current.weatherCode ?? 0;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                WeatherIcons.getIcon(weatherCode),
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.meaningInsights,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the loading state widget.
  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Fetching weather data...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error state widget.
  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.6,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Unable to load weather',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Get.find<WeatherController>().fetchCurrentWeather();
                },
                icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
                label: Text(
                  'Try Again',
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
