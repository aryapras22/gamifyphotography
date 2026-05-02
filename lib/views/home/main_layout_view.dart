// lib/views/home/main_layout_view.dart
// TASK-04 (lanjutan) — Trigger Daily Login Sheet via ConsumerStatefulWidget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mission/module_list_view.dart';
import '../leaderboard/leaderboard_view.dart';
import '../progress/progress_view.dart';
import '../../view_models/auth_view_model.dart';
import 'daily_login_view.dart';

const String _kFallbackUserId = 'user_1';

class MainLayoutView extends ConsumerStatefulWidget {
  const MainLayoutView({Key? key}) : super(key: key);

  @override
  ConsumerState<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends ConsumerState<MainLayoutView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ModuleListView(),
    const LeaderboardView(),
    const ProgressView(),
  ];

  @override
  void initState() {
    super.initState();
    // Jadwalkan setelah frame pertama selesai render agar context sudah valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerDailyLoginIfNeeded();
    });
  }

  Future<void> _triggerDailyLoginIfNeeded() async {
    if (!mounted) return;

    // Ambil userId dari auth state; fallback ke mock jika null
    final authUser = ref.read(authViewModelProvider).currentUser;
    final userId = authUser?.id ?? _kFallbackUserId;

    await showDailyLoginSheet(context, ref, userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF1CB0F6),
          unselectedItemColor: const Color(0xFF4B4B4B).withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded, size: 28),
              label: 'Misi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded, size: 28),
              label: 'Peringkat',
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
