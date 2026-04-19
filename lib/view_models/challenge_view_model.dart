import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';
import 'auth_view_model.dart';
import '../services/user_service.dart';
import 'crafting_view_model.dart'; // To get userServiceProvider

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

final challengeServiceProvider = Provider<ChallengeService>((ref) => ChallengeService());

final challengeViewModelProvider = StateNotifierProvider<ChallengeViewModel, ChallengeState>(
  (ref) => ChallengeViewModel(ref, ref.read(challengeServiceProvider)),
);

class ChallengeViewModel extends StateNotifier<ChallengeState> {
  final Ref _ref;
  final ChallengeService _challengeService;

  ChallengeViewModel(this._ref, this._challengeService) : super(ChallengeState());

  Future<void> loadChallenge(String moduleId) async {
    final challenge = await _challengeService.getChallenge(moduleId);
    state = state.copyWith(challenge: challenge);
  }

  Future<void> uploadPhoto(XFile file) async {
    state = state.copyWith(isUploading: true);
    try {
      final url = await _challengeService.uploadPhoto(file);
      final updatedChallenge = state.challenge!..uploadedPhotoUrl = url;
      state = state.copyWith(challenge: updatedChallenge, isUploading: false);
    } catch (e) {
      state = state.copyWith(isUploading: false);
    }
  }

  Future<void> completeChallenge() async {
    if (state.challenge == null) return;
    
    await _challengeService.completeChallenge(state.challenge!.id);
    state.challenge!.isCompleted = true;
    
    final points = state.challenge!.pointReward;
    
    // Update user points
    final authState = _ref.read(authViewModelProvider);
    if (authState.currentUser != null) {
      authState.currentUser!.points += points;
      checkLevelUp();
      checkAndAwardBadge();
    }
    
    state = state.copyWith(pointsEarned: points);
  }

  void checkLevelUp() {
    final user = _ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      // Simple logic: level up every 100 points
      user.level = (user.points ~/ 100) + 1;
    }
  }

  Future<void> checkAndAwardBadge() async {
    final user = _ref.read(authViewModelProvider).currentUser;
    if (user == null) return;
    
    final userService = _ref.read(userServiceProvider);
    final badges = await userService.getBadges();
    
    for (var badge in badges) {
      if (user.points >= badge.requiredPoints && !user.earnedBadgeIds.contains(badge.id)) {
        user.earnedBadgeIds.add(badge.id);
      }
    }
  }
}
