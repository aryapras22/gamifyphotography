// lib/view_models/leaderboard_view_model.dart
// TASK-05 — LeaderboardViewModel dengan 15 mock user Indonesia

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';

// ---------------------------------------------------------------------------
// Mock Data (15 user Indonesia, poin 500–4800)
// ---------------------------------------------------------------------------

const String _kCurrentUserMockId = 'u_current';

final List<LeaderboardEntry> _kMockEntries = [
  LeaderboardEntry(userId: 'u1', userName: 'Budi Santoso', points: 4800, rank: 0),
  LeaderboardEntry(userId: 'u2', userName: 'Sari Dewi', points: 4200, rank: 0),
  LeaderboardEntry(userId: 'u3', userName: 'Eko Prasetyo', points: 3900, rank: 0),
  LeaderboardEntry(userId: 'u4', userName: 'Rina Wulandari', points: 3500, rank: 0),
  LeaderboardEntry(userId: 'u5', userName: 'Agus Setiawan', points: 3200, rank: 0),
  LeaderboardEntry(userId: 'u6', userName: 'Dewi Puspitasari', points: 2950, rank: 0),
  LeaderboardEntry(userId: 'u7', userName: 'Fajar Nugroho', points: 2700, rank: 0),
  LeaderboardEntry(userId: 'u8', userName: 'Hendra Wijaya', points: 2400, rank: 0),
  LeaderboardEntry(userId: 'u9', userName: 'Indah Permata', points: 2100, rank: 0),
  LeaderboardEntry(userId: _kCurrentUserMockId, userName: 'Kamu (User)', points: 1850, rank: 0),
  LeaderboardEntry(userId: 'u11', userName: 'Lestari Handayani', points: 1600, rank: 0),
  LeaderboardEntry(userId: 'u12', userName: 'Maya Anggraini', points: 1250, rank: 0),
  LeaderboardEntry(userId: 'u13', userName: 'Nanda Kusuma', points: 950, rank: 0),
  LeaderboardEntry(userId: 'u14', userName: 'Oki Firmansyah', points: 720, rank: 0),
  LeaderboardEntry(userId: 'u15', userName: 'Putri Rahayu', points: 500, rank: 0),
];

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final int currentUserRank; // 1-based rank user yang login
  final String? errorMessage;

  const LeaderboardState({
    this.entries = const [],
    this.isLoading = true,
    this.currentUserRank = 0,
    this.errorMessage,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? entries,
    bool? isLoading,
    int? currentUserRank,
    String? errorMessage,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      currentUserRank: currentUserRank ?? this.currentUserRank,
      errorMessage: errorMessage,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final leaderboardViewModelProvider =
    StateNotifierProvider<LeaderboardViewModel, LeaderboardState>((ref) {
  return LeaderboardViewModel();
});

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------

class LeaderboardViewModel extends StateNotifier<LeaderboardState> {
  LeaderboardViewModel() : super(const LeaderboardState());

  /// Load dan sort leaderboard data.
  /// [currentUserId] digunakan untuk menandai entry milik user yang login.
  Future<void> loadLeaderboard(String currentUserId) async {
    state = state.copyWith(isLoading: true);

    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      // Merge: jika ada user yang matching dari auth, override mock current user
      final rawEntries = _kMockEntries.map((e) {
        if (e.userId == _kCurrentUserMockId || e.userId == currentUserId) {
          return LeaderboardEntry(
            userId: currentUserId,
            userName: e.userId == currentUserId ? e.userName : 'Kamu (User)',
            points: e.points,
            rank: e.rank,
          );
        }
        return e;
      }).toList();

      // Sort descending by points
      rawEntries.sort((a, b) => b.points.compareTo(a.points));

      // Assign rank (1-based)
      final sorted = <LeaderboardEntry>[];
      for (var i = 0; i < rawEntries.length; i++) {
        sorted.add(LeaderboardEntry(
          userId: rawEntries[i].userId,
          userName: rawEntries[i].userName,
          points: rawEntries[i].points,
          rank: i + 1,
        ));
      }

      // Cari rank current user
      final currentUserEntry = sorted.firstWhere(
        (e) => e.userId == currentUserId,
        orElse: () => sorted.last,
      );

      state = state.copyWith(
        isLoading: false,
        entries: sorted,
        currentUserRank: currentUserEntry.rank,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat leaderboard.',
      );
    }
  }
}
