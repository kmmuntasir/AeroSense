import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/geocoding_response.dart';

/// DashboardPage displays the weather information for a selected location.
/// This is a placeholder implementation that will be expanded in Task 5.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get location passed from onboarding/search
    final location = Get.arguments as GeocodingResult?;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF4A90E2)),
          onPressed: () {
            // TODO: Open locations drawer (Task 9)
          },
        ),
        title: Text(
          location?.name ?? 'AeroSense',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF121212),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              location != null ? Icons.star : Icons.star_border,
              color: location != null ? const Color(0xFF4A90E2) : Colors.grey,
            ),
            onPressed: () {
              // TODO: Toggle favorite (Task 9)
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF4A90E2)),
            onPressed: () {
              // TODO: Open settings (Task 10)
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud,
              size: 120,
              color: const Color(0xFF4A90E2),
            ),
            const SizedBox(height: 24),
            Text(
              'Dashboard Coming Soon',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 16),
            if (location != null)
              Text(
                'Showing weather for ${location.formattedLocation}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 32),
            Text(
              'This will be implemented in Task 5:\nMain Dashboard UI',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
