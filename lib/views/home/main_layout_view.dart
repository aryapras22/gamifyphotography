import 'package:flutter/material.dart';
import '../mission/module_list_view.dart';
import '../leaderboard/leaderboard_view.dart';
import '../progress/progress_view.dart';

class MainLayoutView extends StatefulWidget {
  const MainLayoutView({Key? key}) : super(key: key);

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ModuleListView(),
    const LeaderboardView(),
    const ProgressView(),
  ];

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
          selectedItemColor: const Color(0xFF1CB0F6), // Dodger Blue
          unselectedItemColor: const Color(0xFF4B4B4B).withOpacity(0.5), // Eel Black faded
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
