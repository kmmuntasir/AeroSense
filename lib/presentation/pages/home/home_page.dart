import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AeroSense'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              size: 100,
              color: Get.theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to AeroSense',
              style: Get.textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Advanced Drone Flight Analytics',
              style: Get.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'and Safety Management',
              style: Get.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
