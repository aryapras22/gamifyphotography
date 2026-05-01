import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';
import 'auth_view_model.dart';
import '../services/user_service.dart';
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
      final updatedChallenge = state.challenge!.copyWith(uploadedPhotoUrl: url);
      state = state.copyWith(challenge: updatedChallenge, isUploading: false);
    } catch (e) {
      state = state.copyWith(isUploading: false);
    }
  }

  Future<void> completeChallenge() async {
    if (state.challenge == null) return;
    
    await _challengeService.completeChallenge(state.challenge!.id);
    final updatedChallenge = state.challenge!.copyWith(isCompleted: true);
    
    final points = updatedChallenge.pointReward;
    
    // Update user points
    final authState = _ref.read(authViewModelProvider);
    if (authState.currentUser != null) {
      var user = authState.currentUser!.copyWith(points: authState.currentUser!.points + points);
      
      // Simple logic: level up every 100 points
      user = user.copyWith(level: (user.points ~/ 100) + 1);
      
      final userService = _ref.read(userServiceProvider);
      final badges = await userService.getBadges();
      
      final newBadgeIds = List<String>.from(user.earnedBadgeIds);
      for (var badge in badges) {
        if (user.points >= badge.requiredPoints && !newBadgeIds.contains(badge.id)) {
          newBadgeIds.add(badge.id);
        }
      }
      user = user.copyWith(earnedBadgeIds: newBadgeIds);
      
      _ref.read(authViewModelProvider.notifier).updateUser(user);
    }
    
    state = state.copyWith(challenge: updatedChallenge, pointsEarned: points);
  }
}
