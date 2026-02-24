import 'package:aero_sense/core/constants/app_constants.dart';
import 'package:aero_sense/core/models/forecast_response.dart';
import 'package:aero_sense/presentation/controllers/forecast_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForecastDetailsPage extends GetView<ForecastDetailsController> {
  const ForecastDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Detailed Forecast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshForecast(),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : controller.errorMessage.isNotEmpty
                ? _ErrorState(errorMessage: controller.errorMessage)
                : RefreshIndicator(
                    onRefresh: () => controller.refreshForecast(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        _CurrentWeatherCard(controller: controller),
                        const SizedBox(height: 20),
                        _ForecastTabSelector(controller: controller),
                        const SizedBox(height: 16),
                        Obx(
                          () {
                            switch (controller.selectedTab) {
                              case ForecastTab.hourly:
                                return _HourlyForecastList(
                                  hourlyData: controller.hourlyForecast,
                                  controller: controller,
                                );
                              case ForecastTab.daily:
                                return _DailyForecastList(
                                  dailyData: controller.dailyForecast,
                                  controller: controller,
                                );
                              case ForecastTab.extended:
                                return _ExtendedForecastList(
                                  dailyData: controller.dailyForecast,
                                  controller: controller,
                                );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

// ── Current Weather Card ───────────────────────────────────────────────────

class _CurrentWeatherCard extends StatelessWidget {
  final ForecastDetailsController controller;

  const _CurrentWeatherCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final current = controller.currentWeather;

    if (current == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Right Now',
            style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temperature.toStringAsFixed(0)}°F',
                      style: tt.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Feels like ${current.apparentTemperature.toStringAsFixed(0)}°F',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.wind_power, size: 24, color: cs.primary),
                  const SizedBox(height: 4),
                  Text(
                    '${current.windSpeed.toStringAsFixed(0)} mph',
                    style: tt.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.getWeatherCondition(current.weatherCode),
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Forecast Tab Selector ──────────────────────────────────────────────────

class _ForecastTabSelector extends StatelessWidget {
  final ForecastDetailsController controller;

  const _ForecastTabSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(
      () => Row(
        children: [
          _TabButton(
            label: 'Hourly',
            isSelected: controller.selectedTab == ForecastTab.hourly,
            onTap: () => controller.selectTab(ForecastTab.hourly),
            colorScheme: cs,
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Daily',
            isSelected: controller.selectedTab == ForecastTab.daily,
            onTap: () => controller.selectTab(ForecastTab.daily),
            colorScheme: cs,
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Extended',
            isSelected: controller.selectedTab == ForecastTab.extended,
            onTap: () => controller.selectTab(ForecastTab.extended),
            colorScheme: cs,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}

// ── Hourly Forecast List ───────────────────────────────────────────────────

class _HourlyForecastList extends StatelessWidget {
  final List<HourlyData> hourlyData;
  final ForecastDetailsController controller;

  const _HourlyForecastList({
    required this.hourlyData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return const Center(child: Text('No hourly data available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next 24 Hours',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyData.length,
            itemBuilder: (context, index) {
              final data = hourlyData[index];
              return _HourlyCard(data: data, controller: controller);
            },
          ),
        ),
      ],
    );
  }
}

class _HourlyCard extends StatelessWidget {
  final HourlyData data;
  final ForecastDetailsController controller;

  const _HourlyCard({required this.data, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            data.formattedTime,
            style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          Icon(Icons.cloud, size: 20, color: cs.primary),
          Text(
            '${data.temperature.toStringAsFixed(0)}°',
            style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '${data.precipitationProbability.toStringAsFixed(0)}%',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Daily Forecast List ────────────────────────────────────────────────────

class _DailyForecastList extends StatelessWidget {
  final List<DailyData> dailyData;
  final ForecastDetailsController controller;

  const _DailyForecastList({
    required this.dailyData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return const Center(child: Text('No daily data available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next 7 Days',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...dailyData.map((data) => _DailyRow(data: data, controller: controller)),
      ],
    );
  }
}

class _DailyRow extends StatelessWidget {
  final DailyData data;
  final ForecastDetailsController controller;

  const _DailyRow({required this.data, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.formattedDate,
                  style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  controller.getWeatherCondition(data.weatherCode),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${data.maxTemperature.toStringAsFixed(0)}°',
                      style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data.minTemperature.toStringAsFixed(0)}°',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.opacity, size: 16, color: cs.primary),
                Text(
                  '${data.precipitationProbability}%',
                  style: tt.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Extended Forecast List ─────────────────────────────────────────────────

class _ExtendedForecastList extends StatelessWidget {
  final List<DailyData> dailyData;
  final ForecastDetailsController controller;

  const _ExtendedForecastList({
    required this.dailyData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.calendar_month, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text('Extended forecast loading...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchExtendedForecast(),
                child: const Text('Load Extended Forecast'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extended Forecast (7-14 Days)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...dailyData.map((data) => _DailyRow(data: data, controller: controller)),
      ],
    );
  }
}

// ── Error State ────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String errorMessage;

  const _ErrorState({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_outlined, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Forecast',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.find<ForecastDetailsController>().refreshForecast(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
