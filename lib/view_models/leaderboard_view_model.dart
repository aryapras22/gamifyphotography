import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';

class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final int currentUserRank;
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

final leaderboardViewModelProvider =
    StateNotifierProvider<LeaderboardViewModel, LeaderboardState>((ref) {
  return LeaderboardViewModel();
});

class LeaderboardViewModel extends StateNotifier<LeaderboardState> {
  final _db = FirebaseFirestore.instance;

  LeaderboardViewModel() : super(const LeaderboardState());

  Future<void> loadLeaderboard(String currentUserId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'user')
          .orderBy('points', descending: true)
          .limit(50)
          .get();

      final raw = snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardEntry(
          userId: doc.id,
          userName: data['name'] ?? 'Unknown',
          points: data['points'] ?? 0,
          rank: 0,
        );
      }).toList();

      final ranked = <LeaderboardEntry>[];
      for (var i = 0; i < raw.length; i++) {
        ranked.add(LeaderboardEntry(
          userId: raw[i].userId,
          userName: raw[i].userId == currentUserId
              ? '${raw[i].userName} (You)'
              : raw[i].userName,
          points: raw[i].points,
          rank: i + 1,
        ));
      }

      final currentEntry = ranked.firstWhere(
        (e) => e.userId == currentUserId,
        orElse: () => LeaderboardEntry(
          userId: currentUserId,
          userName: 'You',
          points: 0,
          rank: ranked.length + 1,
        ),
      );

      state = state.copyWith(
        isLoading: false,
        entries: ranked,
        currentUserRank: currentEntry.rank,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load leaderboard.',
      );
    }
  }
}
