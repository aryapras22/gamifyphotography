// lib/views/home/main_layout_view.dart
// Sprint UI — 3 tab layout: Home, Peringkat, Profil

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_view.dart';
import '../leaderboard/leaderboard_view.dart';
import '../profile/profile_view.dart';
import '../crafting/crafting_view.dart';
import '../../view_models/auth_view_model.dart';
import '../../core/app_colors.dart';
import 'daily_login_view.dart';

const String _kFallbackUserId = 'user_1';

class MainLayoutView extends ConsumerStatefulWidget {
  const MainLayoutView({super.key});

  @override
  ConsumerState<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends ConsumerState<MainLayoutView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const LeaderboardView(),
    const CraftingView(),
    const ProfileView(),
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
      final userId = authUser?.id ?? _kFallbackUserId;
      await showDailyLoginSheet(context, ref, userId);
    } catch (e) {
      debugPrint('[DailyLogin] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.brandBlue,
          unselectedItemColor: AppColors.disabled,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          backgroundColor: AppColors.surfaceWhite,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded, size: 28),
              label: 'Peringkat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman_rounded, size: 28),
              label: 'Crafting',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 28),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
