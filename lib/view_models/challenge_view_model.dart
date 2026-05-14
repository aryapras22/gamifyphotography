import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';
import '../services/photo_submission_service.dart';
import 'auth_view_model.dart';
import 'daily_login_view_model.dart';
import 'mission_view_model.dart';
import '../providers/service_providers.dart';

class ChallengeState {
  final ChallengeModel? challenge;
  final bool isUploading;
  final int pointsEarned;
  final String? errorMessage;

  ChallengeState({
    this.challenge,
    this.isUploading = false,
    this.pointsEarned = 0,
    this.errorMessage,
  });

  ChallengeState copyWith({
    ChallengeModel? challenge,
    bool? isUploading,
    int? pointsEarned,
    String? errorMessage,
  }) {
    return ChallengeState(
      challenge: challenge ?? this.challenge,
      isUploading: isUploading ?? this.isUploading,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      errorMessage: errorMessage,
    );
  }
}

final challengeViewModelProvider =
    StateNotifierProvider<ChallengeViewModel, ChallengeState>(
      (ref) => ChallengeViewModel(
        ref,
        ref.read(challengeServiceProvider),
        ref.read(photoSubmissionServiceProvider),
      ),
    );

class ChallengeViewModel extends StateNotifier<ChallengeState> {
  final Ref _ref;
  final ChallengeService _challengeService;
  final PhotoSubmissionService _submissionService;

  ChallengeViewModel(this._ref, this._challengeService, this._submissionService)
      : super(ChallengeState());

  Future<void> loadChallenge(String moduleId) async {
    state = ChallengeState();
    final challenge = await _challengeService.getChallenge(moduleId);
    state = state.copyWith(challenge: challenge);
  }

  Future<void> uploadPhoto(XFile file, {required String moduleTitle}) async {
    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final url = await _challengeService.uploadPhoto(file);
      final updatedChallenge = state.challenge!.copyWith(uploadedPhotoUrl: url);

      final user = _ref.read(authViewModelProvider).currentUser;
      if (user != null && state.challenge != null) {
        await _submissionService.submitPhoto(
          userId: user.id,
          userName: user.name,
          moduleId: state.challenge!.moduleId,
          moduleTitle: moduleTitle,
          photoUrl: url,
        );
      }

      state = state.copyWith(challenge: updatedChallenge, isUploading: false);
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Upload failed. Please try again.',
      );
    }
  }

  Future<void> completeChallenge() async {
    if (state.challenge == null) return;
    final user = _ref.read(authViewModelProvider).currentUser;
    if (user == null) return;
    if (user.completedModuleIds.contains(state.challenge!.moduleId)) return;
    if (state.challenge!.isCompleted) return;

    state = state.copyWith(isUploading: true, errorMessage: null);

    try {
      await _challengeService.completeChallenge(state.challenge!.id);

      final updatedChallenge = state.challenge!.copyWith(isCompleted: true);
      final points = updatedChallenge.pointReward;
      final photoUrl = state.challenge!.uploadedPhotoUrl;
      final newPhotoUrls =
          (photoUrl != null && photoUrl.isNotEmpty) ? [photoUrl] : <String>[];

      // Atomic Firestore transaction — prevents double point-add on retry
      await _ref.read(authServiceProvider).completeModuleAtomic(
            userId: user.id,
            moduleId: state.challenge!.moduleId,
            pointsToAdd: points,
            newPhotoUrls: newPhotoUrls,
          );

      // Build updated in-memory user to sync local state
      var updatedUser = user.copyWith(
        points: user.points + points,
        completedModuleIds: [
          ...user.completedModuleIds,
          state.challenge!.moduleId,
        ],
        level: ((user.points + points) ~/ 100) + 1,
        completedPhotoUrls: [...user.completedPhotoUrls, ...newPhotoUrls],
      );

      // Badge check
      final badgeService = _ref.read(badgeServiceProvider);
      final streak = _ref.read(dailyLoginViewModelProvider).currentStreak;
      final newBadges = await badgeService.checkNewBadges(
        level: updatedUser.level,
        streak: streak,
        earnedBadgeIds: updatedUser.earnedBadgeIds,
        completedFirstMission: updatedUser.completedModuleIds.isNotEmpty,
      );
      if (newBadges.isNotEmpty) {
        updatedUser = updatedUser.copyWith(
          earnedBadgeIds: [
            ...updatedUser.earnedBadgeIds,
            ...newBadges.map((b) => b.id),
          ],
        );
        // Persist badge update separately (non-critical, no transaction needed)
        await _ref.read(authServiceProvider).updateUserProgress(updatedUser);
      }

      _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);
      _ref
          .read(missionViewModelProvider.notifier)
          .markModuleCompleted(state.challenge!.moduleId);

      state = state.copyWith(
        challenge: updatedChallenge,
        pointsEarned: points,
        isUploading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage:
            'Failed to complete mission. Check your connection and try again.',
      );
      rethrow;
    }
  }
}
