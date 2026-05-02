// lib/views/leaderboard/leaderboard_view.dart
// TASK-06 — Wire LeaderboardView ke LeaderboardViewModel

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/leaderboard_model.dart';
import '../../view_models/leaderboard_view_model.dart';
import '../../view_models/auth_view_model.dart';

const String _kFallbackUserId = 'user_1';

// Medal emoji untuk top 3
const List<String> _kMedals = ['🥇', '🥈', '🥉'];

class LeaderboardView extends ConsumerStatefulWidget {
  const LeaderboardView({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends ConsumerState<LeaderboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = ref.read(authViewModelProvider).currentUser;
      final userId = authUser?.id ?? _kFallbackUserId;
      ref.read(leaderboardViewModelProvider.notifier).loadLeaderboard(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardViewModelProvider);
    final authUser = ref.watch(authViewModelProvider).currentUser;
    final currentUserId = authUser?.id ?? _kFallbackUserId;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F5),
      appBar: AppBar(
        title: const Text(
          'Peringkat',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4B4B4B)),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        actions: [
          if (state.currentUserRank > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Chip(
                backgroundColor: const Color(0xFF1CB0F6).withOpacity(0.12),
                label: Text(
                  'Kamu: #${state.currentUserRank}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1CB0F6),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? _buildLoadingSkeleton()
          : state.errorMessage != null
              ? _buildError(state.errorMessage!)
              : _buildList(state.entries, currentUserId),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading Skeleton
  // ---------------------------------------------------------------------------

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 82,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            _shimmerBox(40, 40, radius: 8),
            const SizedBox(width: 12),
            _shimmerBox(50, 50, radius: 25),
            const SizedBox(width: 16),
            Expanded(child: _shimmerBox(12, 120, radius: 4)),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double h, double w, {double radius = 4}) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error State
  // ---------------------------------------------------------------------------

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.redAccent)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Leaderboard List
  // ---------------------------------------------------------------------------

  Widget _buildList(List<LeaderboardEntry> entries, String currentUserId) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isCurrentUser = entry.userId == currentUserId;
        return _LeaderboardTile(entry: entry, isCurrentUser: isCurrentUser);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Widget: Leaderboard Tile
// ---------------------------------------------------------------------------

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardTile({required this.entry, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;

    final Color rankColor;
    final Color bgColor;
    final Color borderColor;

    if (entry.rank == 1) {
      rankColor = const Color(0xFFFFC800);
      bgColor = isCurrentUser ? const Color(0xFFFFF7D9) : const Color(0xFFFFF7D9);
      borderColor = const Color(0xFFFFC800);
    } else if (entry.rank == 2) {
      rankColor = const Color(0xFFAFAFAF);
      bgColor = isCurrentUser ? const Color(0xFFF5F5F5) : const Color(0xFFF5F5F5);
      borderColor = const Color(0xFFAFAFAF);
    } else if (entry.rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      bgColor = isCurrentUser ? const Color(0xFFFAF0E6) : const Color(0xFFFAF0E6);
      borderColor = const Color(0xFFCD7F32);
    } else if (isCurrentUser) {
      rankColor = const Color(0xFF1CB0F6);
      bgColor = const Color(0xFFE3F6FF);
      borderColor = const Color(0xFF1CB0F6);
    } else {
      rankColor = const Color(0xFF4B4B4B);
      bgColor = Colors.white;
      borderColor = const Color(0xFFE5E5E5);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isCurrentUser || isTop3 ? 2 : 1),
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: const Color(0xFF1CB0F6).withOpacity(0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                )
              ]
            : const [BoxShadow(color: Color(0xFFE5E5E5), offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Rank / Medal
          SizedBox(
            width: 40,
            child: isTop3
                ? Text(
                    _kMedals[entry.rank - 1],
                    style: const TextStyle(fontSize: 26),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '${entry.rank}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: rankColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),

          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: rankColor, width: 2),
            ),
            child: Icon(
              isCurrentUser ? Icons.person_pin_rounded : Icons.person,
              color: rankColor,
            ),
          ),
          const SizedBox(width: 16),

          // Name + "Kamu" badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isCurrentUser ? const Color(0xFF1CB0F6) : const Color(0xFF4B4B4B),
                  ),
                ),
                if (isCurrentUser)
                  const Text(
                    'Kamu',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1CB0F6),
                    ),
                  ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.points}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: rankColor,
                ),
              ),
              const Text(
                'XP',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
