import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/onboarding_view_model.dart';
import 'package:lottie/lottie.dart';

class OnboardingView extends ConsumerWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Gamify Photography!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Placeholder for Lottie animation
            const Icon(Icons.camera_alt, size: 100, color: Colors.blue),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await ref.read(onboardingViewModelProvider.notifier).markOnboardingDone();
                context.go('/login');
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
