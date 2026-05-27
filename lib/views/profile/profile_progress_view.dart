import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../providers/service_providers.dart';
import '../progress/progress_view.dart';
import 'profile_view.dart';

/// Thin wrapper so the router's `/profile` route and the
/// BottomNavigationBar tab both use the same ProfileTab entry-point.
/// The SliverAppBar + hero + logout are all owned by ProfileTab now.
class ProfileProgressView extends ConsumerWidget {
  const ProfileProgressView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subIndex = ref.watch(profileTabSubIndexProvider);
    return Scaffold(
      backgroundColor: AppColors.brandBg,
      body: subIndex == 0 ? const ProfileTab() : const ProgressTab(),
    );
  }
}

