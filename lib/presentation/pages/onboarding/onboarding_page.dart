import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/location_controller.dart';

/// OnboardingPage handles the first-launch experience.
/// It shows a loading state while checking location permission,
/// then routes the user appropriately:
/// - Location granted: Navigate to Dashboard
/// - Location denied: Navigate to Search/Fallback view
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final LocationController _locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
    _initializeOnboarding();
  }

  Future<void> _initializeOnboarding() async {
    // Give the UI a moment to render before checking permission
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if we already have permission
    if (_locationController.hasPermission) {
      // Permission already granted, get location and go to dashboard
      final success = await _locationController.getCurrentLocation();
      if (success && mounted) {
        Get.offAllNamed('/dashboard');
      } else if (mounted) {
        Get.offAllNamed('/search');
      }
    } else {
      // Permission not granted, request it
      final granted = await _locationController.requestLocationPermission();
      if (granted && mounted) {
        // Get location and proceed to dashboard
        final success = await _locationController.getCurrentLocation();
        if (success && mounted) {
          Get.offAllNamed('/dashboard');
        } else if (mounted) {
          Get.offAllNamed('/search');
        }
      } else if (mounted) {
        // Permission denied, go to search/fallback
        Get.offAllNamed('/search');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sky Indigo weather icon (sun/cloud)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.cloud,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'AeroSense',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Making sense of the sky',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 64),
            // Loading spinner
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
