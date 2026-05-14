import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';
import '../services/photo_submission_service.dart';
import 'auth_view_model.dart';
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

}
