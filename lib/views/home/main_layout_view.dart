import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_view.dart';
import '../crafting/crafting_view.dart';
import '../leaderboard/leaderboard_view.dart';
import '../profile/profile_progress_view.dart';
import '../mission/custom_camera_view.dart';
import '../../view_models/auth_view_model.dart';
import '../../core/app_colors.dart';
import '../../providers/submission_providers.dart';
import '../../providers/service_providers.dart';
import 'daily_login_view.dart';

class MainLayoutView extends ConsumerStatefulWidget {
  const MainLayoutView({super.key});

  @override
  ConsumerState<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends ConsumerState<MainLayoutView> {
  final List<Widget> _pages = [
    const HomeView(),
    const CraftingView(),
    const LeaderboardView(),
    const ProfileProgressView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerDailyLoginIfNeeded();
    });
  }

  Future<void> _triggerDailyLoginIfNeeded() async {
    if (!mounted) return;
    try {
      final authUser = ref.read(authViewModelProvider).currentUser;
      if (authUser == null) return;
      await showDailyLoginSheet(context, ref, authUser.id);
    } catch (e) {
      debugPrint('[DailyLogin] startup error suppressed: $e');
    }
  }

  Future<void> _launchCamera() async {
    // Practice camera — not tied to any mission submission.
    // Opens camera with visual guide overlay for learning purposes.
    // Photos are saved to the user's personal gallery only.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CustomCameraView(
          moduleId: 'practice',
          visualGuideUrl: null,
          isPracticeMode: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep the approval watcher alive across all tabs
    ref.watch(submissionApprovalWatcherProvider);
    final currentIndex = ref.watch(mainLayoutIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      body: Stack(
        children: [
          // Content Stack with padding at the bottom so it's not hidden by BottomNav
          Padding(
            padding: const EdgeInsets.only(bottom: 76),
            child: IndexedStack(
              index: currentIndex,
              children: _pages,
            ),
          ),

          // Floating Bottom Navigation Bar Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Container(
                width: 342,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Tab 1: Beranda (Home)
                    Expanded(
                      child: _TabItem(
                        icon: Icons.home_filled,
                        label: 'Beranda',
                        isActive: currentIndex == 0,
                        onTap: () => ref.read(mainLayoutIndexProvider.notifier).state = 0,
                      ),
                    ),
                    // Tab 2: Kreasi (Crafting)
                    Expanded(
                      child: _TabItem(
                        icon: Icons.handyman_rounded,
                        label: 'Kreasi',
                        isActive: currentIndex == 1,
                        onTap: () => ref.read(mainLayoutIndexProvider.notifier).state = 1,
                      ),
                    ),

                    // Camera Floating Raised Button
                    GestureDetector(
                      onTap: _launchCamera,
                      child: Transform.translate(
                        offset: const Offset(0, -16),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.brandAccent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandAccent.withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Tab 3: Peringkat (Leaderboard)
                    Expanded(
                      child: _TabItem(
                        icon: Icons.emoji_events_rounded,
                        label: 'Peringkat',
                        isActive: currentIndex == 2,
                        onTap: () => ref.read(mainLayoutIndexProvider.notifier).state = 2,
                      ),
                    ),
                    // Tab 4: Profil (Profile)
                    Expanded(
                      child: _TabItem(
                        icon: Icons.person_rounded,
                        label: 'Profil',
                        isActive: currentIndex == 3,
                        onTap: () => ref.read(mainLayoutIndexProvider.notifier).state = 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.brandAccent : const Color(0xFF94A3B8); // slate-400

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
