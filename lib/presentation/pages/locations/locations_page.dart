import 'package:aero_sense/core/constants/app_colors.dart';
import 'package:aero_sense/core/models/geocoding_response.dart';
import 'package:aero_sense/core/models/weather_response.dart';
import 'package:aero_sense/presentation/controllers/locations_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── WMO code → icon + color ───────────────────────────────────────────────────

({IconData icon, Color color}) _weatherIconFor(int? code) {
  if (code == null || code <= 1) {
    return (icon: Icons.wb_sunny_rounded, color: const Color(0xFFFFA726));
  }
  if (code <= 3) return (icon: Icons.cloud_rounded, color: Colors.grey);
  if (code <= 48) return (icon: Icons.cloud_rounded, color: Colors.blueGrey);
  if (code <= 67) return (icon: Icons.grain_rounded, color: Colors.blue);
  if (code <= 77) return (icon: Icons.ac_unit_rounded, color: Colors.lightBlue);
  if (code <= 82) {
    return (icon: Icons.water_drop_rounded, color: Colors.indigo);
  }
  if (code <= 86) return (icon: Icons.ac_unit_rounded, color: Colors.lightBlue);
  return (icon: Icons.thunderstorm_rounded, color: Colors.grey.shade700);
}

// ── UTC offset → local time string ───────────────────────────────────────────

String _localTimeFor(double? utcOffsetSeconds) {
  if (utcOffsetSeconds == null) return '--:--';
  final local = DateTime.now().toUtc().add(
    Duration(seconds: utcOffsetSeconds.round()),
  );
  final h = local.hour;
  final m = local.minute.toString().padLeft(2, '0');
  final period = h >= 12 ? 'PM' : 'AM';
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$h12:$m $period';
}

// ── Card shadow ───────────────────────────────────────────────────────────────

const _cardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
];

const _cardRadius = BorderRadius.all(Radius.circular(16));

// ── Section label style ───────────────────────────────────────────────────────

const _sectionLabelStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
  letterSpacing: 0.8,
);

// ── Page ─────────────────────────────────────────────────────────────────────

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationsController>();

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        onPressed: controller.navigateToCitySearch,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Search bar
              _LocationsSearchBar(onTap: controller.navigateToCitySearch),

              const SizedBox(height: 24),

              // Current location section label
              const Text('CURRENT LOCATION', style: _sectionLabelStyle),
              const SizedBox(height: 8),

              // Current location card
              Obx(() {
                final loc = controller.currentLocation;
                if (loc != null) {
                  return _CurrentLocationCard(
                    location: loc,
                    weather: controller.currentLocationWeather,
                    controller: controller,
                  );
                }
                if (controller.isFetchingCurrentPosition.value) {
                  return const _CardShimmer();
                }
                return const _NoLocationCard();
              }),

              const SizedBox(height: 24),

              // Saved locations header row
              Row(
                children: [
                  const Text('SAVED LOCATIONS', style: _sectionLabelStyle),
                  const Spacer(),
                  GestureDetector(
                    onTap: controller.navigateToCitySearch,
                    child: const Text(
                      'Edit List',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.locationButton,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Saved locations list
              Expanded(
                child: Obx(() {
                  final locations = controller.savedLocations;
                  final loading = controller.isLoadingWeather.value;

                  if (loading && locations.isNotEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (locations.isEmpty) {
                    return const Center(
                      child: Text(
                        'No saved cities yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  // Read all weather inside Obx scope so _savedWeatherData is a
                  // direct reactive dependency — Obx rebuilds when weather arrives.
                  final weatherMap = {
                    for (final loc in locations)
                      loc.formattedLocation: controller.weatherFor(loc),
                  };

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: locations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final loc = locations[index];
                      final weather = weatherMap[loc.formattedLocation];
                      return Dismissible(
                        key: ValueKey(loc.formattedLocation),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => controller.removeLocation(loc),
                        background: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53935),
                            borderRadius: _cardRadius,
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'DELETE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: _SavedLocationCard(
                          location: loc,
                          weather: weather,
                          controller: controller,
                        ),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _LocationsSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _LocationsSearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: const BoxDecoration(
          color: AppColors.searchBarBackground,
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Row(
          children: [
            Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 10),
            Text(
              'Search for a city...',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Current location card ─────────────────────────────────────────────────────

class _CurrentLocationCard extends StatelessWidget {
  final GeocodingResult location;
  final WeatherResponse? weather;
  final LocationsController controller;

  const _CurrentLocationCard({
    required this.location,
    required this.weather,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final tempC = weather?.current.temperature2M;
    final code = weather?.current.weatherCode;

    return GestureDetector(
      onTap: controller.navigateToCurrentLocation,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: _cardRadius,
          boxShadow: _cardShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const _LocationCircleIcon(
              icon: Icons.navigation_rounded,
              iconColor: AppColors.locationButton,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          location.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (location.countryCode.isNotEmpty) ...[
                        const Text(
                          ', ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          location.countryCode,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'My Location',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.temperatureDisplay(tempC),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                _WeatherIcon(code: code),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Saved location card ───────────────────────────────────────────────────────

class _SavedLocationCard extends StatelessWidget {
  final GeocodingResult location;
  final WeatherResponse? weather;
  final LocationsController controller;

  const _SavedLocationCard({
    required this.location,
    required this.weather,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final tempC = weather?.current.temperature2M;
    final code = weather?.current.weatherCode;
    final localTime = _localTimeFor(
      weather?.utcOffsetSeconds ?? location.utcOffsetSeconds,
    );

    return GestureDetector(
      onTap: () => controller.navigateToLocation(location),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: _cardRadius,
          boxShadow: _cardShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _LocationCircleIcon(
              icon: Icons.location_city_rounded,
              iconColor: Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          location.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (location.countryCode.isNotEmpty) ...[
                        const Text(
                          ', ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          location.countryCode,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    localTime,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.temperatureDisplay(tempC),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                _WeatherIcon(code: code),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Circle icon ───────────────────────────────────────────────────────────────

class _LocationCircleIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _LocationCircleIcon({required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: iconColor),
    );
  }
}

// ── Weather icon ──────────────────────────────────────────────────────────────

class _WeatherIcon extends StatelessWidget {
  final int? code;

  const _WeatherIcon({required this.code});

  @override
  Widget build(BuildContext context) {
    final (:icon, :color) = _weatherIconFor(code);
    return Icon(icon, size: 22, color: color);
  }
}

// ── No location card ─────────────────────────────────────────────────────────

class _NoLocationCard extends StatelessWidget {
  const _NoLocationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: _cardRadius,
        boxShadow: _cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: const Row(
        children: [
          _LocationCircleIcon(
            icon: Icons.location_off_rounded,
            iconColor: AppColors.textSecondary,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Unavailable',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Enable location access in settings',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────────────────

class _CardShimmer extends StatelessWidget {
  const _CardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: _cardRadius,
        boxShadow: _cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 11,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
