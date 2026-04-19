import 'package:flutter/material.dart';
import '../../models/leaderboard_model.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final mockLeaderboard = [
      LeaderboardEntry(userId: '1', userName: 'Alice', points: 1500, rank: 1),
      LeaderboardEntry(userId: '2', userName: 'Bob', points: 1200, rank: 2),
      LeaderboardEntry(userId: '3', userName: 'Charlie', points: 900, rank: 3),
      LeaderboardEntry(userId: '4', userName: 'Test User', points: 120, rank: 4),
      LeaderboardEntry(userId: '5', userName: 'Dave', points: 100, rank: 5),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F5),
      appBar: AppBar(
        title: const Text('Peringkat', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4B4B4B))),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockLeaderboard.length,
        itemBuilder: (context, index) {
          final entry = mockLeaderboard[index];
          
          Color rankColor;
          Color bgColor = Colors.white;
          if (entry.rank == 1) {
            rankColor = const Color(0xFFFFC800);
            bgColor = const Color(0xFFFFF7D9);
          } else if (entry.rank == 2) {
            rankColor = const Color(0xFFAFAFAF);
            bgColor = const Color(0xFFF5F5F5);
          } else if (entry.rank == 3) {
            rankColor = const Color(0xFFCD7F32);
            bgColor = const Color(0xFFFAF0E6);
          } else {
            rankColor = const Color(0xFF4B4B4B);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: entry.rank <= 3 ? rankColor : const Color(0xFFE5E5E5), width: 2),
              boxShadow: const [BoxShadow(color: Color(0xFFE5E5E5), offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '${entry.rank}',
                    style: TextStyle(
                      fontSize: entry.rank <= 3 ? 28 : 20,
                      fontWeight: FontWeight.w900,
                      color: rankColor,
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: rankColor, width: 2),
                  ),
                  child: Icon(Icons.person, color: rankColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    entry.userName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: entry.rank <= 3 ? const Color(0xFF4B4B4B) : Colors.grey.shade700),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.points}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: rankColor),
                    ),
                    const Text('XP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
