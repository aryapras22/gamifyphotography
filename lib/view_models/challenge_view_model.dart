import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';
import 'auth_view_model.dart';
import 'daily_login_view_model.dart';
import 'mission_view_model.dart';
import '../providers/service_providers.dart';

class ChallengeState {
  final ChallengeModel? challenge;
  final bool isUploading;
  final int pointsEarned;

  ChallengeState({
    this.challenge,
    this.isUploading = false,
    this.pointsEarned = 0,
  });

  ChallengeState copyWith({
    ChallengeModel? challenge,
    bool? isUploading,
    int? pointsEarned,
  }) {
    return ChallengeState(
      challenge: challenge ?? this.challenge,
      isUploading: isUploading ?? this.isUploading,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }
}

final challengeViewModelProvider =
    StateNotifierProvider<ChallengeViewModel, ChallengeState>(
      (ref) => ChallengeViewModel(ref, ref.read(challengeServiceProvider)),
    );

class ChallengeViewModel extends StateNotifier<ChallengeState> {
  final Ref _ref;
  final ChallengeService _challengeService;

  ChallengeViewModel(this._ref, this._challengeService)
    : super(ChallengeState());

  Future<void> loadChallenge(String moduleId) async {
    state = ChallengeState();
    final challenge = await _challengeService.getChallenge(moduleId);
    state = state.copyWith(challenge: challenge);
  }

  Future<void> uploadPhoto(XFile file) async {
    state = state.copyWith(isUploading: true);
    try {
      final url = await _challengeService.uploadPhoto(file);
      final updatedChallenge = state.challenge!.copyWith(uploadedPhotoUrl: url);
      state = state.copyWith(challenge: updatedChallenge, isUploading: false);
    } catch (e) {
      state = state.copyWith(isUploading: false);
    }
  }

  Future<void> completeChallenge() async {
    if (state.challenge == null) return;
    if (state.challenge!.isCompleted) return; // Guard idempotent (fix BUG-09)

    await _challengeService.completeChallenge(state.challenge!.id);
    final updatedChallenge = state.challenge!.copyWith(isCompleted: true);

    final points = updatedChallenge.pointReward;

    // Update user points
    final authState = _ref.read(authViewModelProvider);
    if (authState.currentUser != null) {
      var user = authState.currentUser!.copyWith(
        points: authState.currentUser!.points + points,
      );

      // Level up setiap 100 poin
      user = user.copyWith(level: (user.points ~/ 100) + 1);

      // Cek badge baru via BadgeService (konsisten dengan BadgeViewModel)
      final badgeService = _ref.read(badgeServiceProvider);
      final streak = _ref.read(dailyLoginViewModelProvider).currentStreak;
      final newBadges = await badgeService.checkNewBadges(
        level: user.level,
        streak: streak,
        earnedBadgeIds: user.earnedBadgeIds,
        completedFirstMission: user.level >= 1,
      );
      if (newBadges.isNotEmpty) {
        final newIds = newBadges.map((b) => b.id).toList();
        user = user.copyWith(
          earnedBadgeIds: [...user.earnedBadgeIds, ...newIds],
        );
      }

      _ref.read(authViewModelProvider.notifier).updateUser(user);
    }

    final moduleId = state.challenge!.moduleId;
    _ref.read(missionViewModelProvider.notifier).markModuleCompleted(moduleId);

    state = state.copyWith(challenge: updatedChallenge, pointsEarned: points);
  }
}
