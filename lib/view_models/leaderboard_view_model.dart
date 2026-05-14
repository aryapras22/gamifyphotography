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
  }) =>
      LeaderboardState(
        entries: entries ?? this.entries,
        isLoading: isLoading ?? this.isLoading,
        currentUserRank: currentUserRank ?? this.currentUserRank,
        errorMessage: errorMessage,
      );
}

final leaderboardViewModelProvider =
    StateNotifierProvider<LeaderboardViewModel, LeaderboardState>(
        (ref) => LeaderboardViewModel());

class LeaderboardViewModel extends StateNotifier<LeaderboardState> {
  final _db = FirebaseFirestore.instance;

  LeaderboardViewModel() : super(const LeaderboardState());

  Future<void> loadLeaderboard(String currentUserId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final snapshot = await _db
          .collection('users')
          .orderBy('points', descending: true)
          .limit(50)
          .get();

      final ranked = <LeaderboardEntry>[];
      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        ranked.add(LeaderboardEntry(
          userId: doc.id,
          userName: (data['name'] as String?) ?? 'Unknown',
          points: (data['points'] as int?) ?? 0,
          rank: i + 1,
        ));
      }

      final myRank = ranked.indexWhere((e) => e.userId == currentUserId);

      state = state.copyWith(
        isLoading: false,
        entries: ranked,
        currentUserRank: myRank >= 0 ? myRank + 1 : 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat peringkat. Periksa koneksi internet.',
      );
    }
  }
}
