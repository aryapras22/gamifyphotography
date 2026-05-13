import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.brandBlue),
      ),
    );
  }
}
