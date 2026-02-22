import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/controllers/location_controller.dart';

enum _OnboardingPhase { splash, steps }

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final LocationController _locationController = Get.find<LocationController>();

  _OnboardingPhase _phase = _OnboardingPhase.splash;
  late AnimationController _progressController;
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _startSplash();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _startSplash() async {
    _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (_locationController.hasPermission) {
      Get.offAllNamed('/dashboard');
    } else {
      setState(() => _phase = _OnboardingPhase.steps);
    }
  }

  void _animateToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onEnableLocation() async {
    final granted = await _locationController.requestLocationPermission();
    if (!mounted) return;
    if (granted) {
      _animateToStep(1);
    } else {
      Get.offAllNamed('/search');
    }
  }

  Future<void> _onEnableNotifications() async {
    await Permission.notification.request();
    if (!mounted) return;
    _animateToStep(2);
  }

  Future<void> _onGetStarted() async {
    final success = await _locationController.getCurrentLocation();
    if (!mounted) return;
    if (success) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _phase == _OnboardingPhase.splash
          ? _SplashContent(progressController: _progressController)
          : _StepsContent(
              pageController: _pageController,
              currentStep: _currentStep,
              onEnableLocation: _onEnableLocation,
              onEnableNotifications: _onEnableNotifications,
              onGetStarted: _onGetStarted,
              onAnimateToStep: _animateToStep,
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Splash
// ---------------------------------------------------------------------------

class _SplashContent extends StatelessWidget {
  const _SplashContent({required this.progressController});

  final AnimationController progressController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          const Spacer(),
          // Logo
          Image.asset(
            'assets/images/splash_logo.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
          Text(
            'AeroSense',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Making sense of the sky',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: AnimatedBuilder(
              animation: progressController,
              builder: (context, _) => LinearProgressIndicator(
                value: progressController.value,
                borderRadius: BorderRadius.circular(4),
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Steps
// ---------------------------------------------------------------------------

class _StepsContent extends StatelessWidget {
  const _StepsContent({
    required this.pageController,
    required this.currentStep,
    required this.onEnableLocation,
    required this.onEnableNotifications,
    required this.onGetStarted,
    required this.onAnimateToStep,
  });

  final PageController pageController;
  final int currentStep;
  final VoidCallback onEnableLocation;
  final VoidCallback onEnableNotifications;
  final VoidCallback onGetStarted;
  final void Function(int) onAnimateToStep;

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StepPage(
          illustration: _LocationIllustration(),
          progressDots: _ProgressDots(current: 0, total: 3),
          title: 'Where in the world are you?',
          body:
              'AeroSense uses your location to provide accurate, real-time weather conditions and forecasts for where you actually are.',
          primaryLabel: '  Enable Location',
          primaryIcon: Icons.lock_outline,
          onPrimary: onEnableLocation,
          secondaryLabel: 'Enter location manually',
          onSecondary: () => Get.offAllNamed('/search'),
          showSkip: true,
          onSkip: () => Get.offAllNamed('/search'),
        ),
        _StepPage(
          illustration: _NotificationIllustration(),
          progressDots: _ProgressDots(current: 1, total: 3),
          title: 'Stay ahead of the storm',
          body:
              'Get timely alerts for severe weather, rain reminders, and daily forecasts delivered right to your device.',
          primaryLabel: '  Turn on Notifications',
          primaryIcon: Icons.notifications_outlined,
          onPrimary: onEnableNotifications,
          secondaryLabel: 'Maybe later',
          onSecondary: () => onAnimateToStep(2),
          showSkip: true,
          onSkip: () => onAnimateToStep(2),
        ),
        _StepPage(
          illustration: _FeaturesIllustration(),
          progressDots: _ProgressDots(current: 2, total: 3),
          title: 'Your personal weather, your way',
          body:
              'Explore real-time conditions, 5-day forecasts, air quality metrics, and hourly breakdowns — all in one beautiful dashboard.',
          primaryLabel: 'Get Started',
          primaryIcon: Icons.arrow_forward,
          onPrimary: onGetStarted,
          secondaryLabel: 'Skip setup for now',
          onSecondary: () => Get.offAllNamed('/search'),
          showSkip: false,
          onSkip: null,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step page template
// ---------------------------------------------------------------------------

class _StepPage extends StatelessWidget {
  const _StepPage({
    required this.illustration,
    required this.progressDots,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.showSkip,
    required this.onSkip,
  });

  final Widget illustration;
  final Widget progressDots;
  final String title;
  final String body;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;
  final bool showSkip;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Skip button row
          SizedBox(
            height: 48,
            child: showSkip
                ? Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onSkip,
                      child: Text(
                        'Skip',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Illustration (top 45% of remaining space)
          Expanded(flex: 45, child: Center(child: illustration)),
          // Progress dots
          progressDots,
          const SizedBox(height: 24),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          // Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          // Primary button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onPrimary,
                icon: Icon(primaryIcon, size: 20),
                label: Text(primaryLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: const StadiumBorder(),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Secondary text button
          Center(
            child: TextButton(
              onPressed: onSecondary,
              child: Text(
                secondaryLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Illustrations
// ---------------------------------------------------------------------------

class _LocationIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.public, size: 96, color: Colors.white),
    );
  }
}

class _NotificationIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFFE65100),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.wb_sunny, size: 80, color: Colors.amber),
          Positioned(
            right: 32,
            top: 32,
            child: Icon(Icons.notifications, size: 44, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _FeaturesIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFF00695C),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.cloud, size: 80, color: Color(0xFF80DEEA)),
          Positioned(
            right: 28,
            bottom: 28,
            child: Icon(Icons.person, size: 44, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress dots
// ---------------------------------------------------------------------------

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
