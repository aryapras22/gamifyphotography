import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';
import '../services/photo_submission_service.dart';
import 'auth_view_model.dart';
import '../providers/service_providers.dart';
import 'mission_view_model.dart';

// Sentinel untuk membedakan "tidak di-set" vs "di-set ke null"
const _unset = Object();

class ChallengeState {
  final ChallengeModel? challenge;
  final bool isUploading;
  final int pointsEarned;
  final String? errorMessage;

  const ChallengeState({
    this.challenge,
    this.isUploading = false,
    this.pointsEarned = 0,
    this.errorMessage,
  });

  ChallengeState copyWith({
    ChallengeModel? challenge,
    bool? isUploading,
    int? pointsEarned,
    // ── CRIT-02 fix: gunakan sentinel agar null bisa di-set secara eksplisit ─
    Object? errorMessage = _unset,
  }) {
    return ChallengeState(
      challenge: challenge ?? this.challenge,
      isUploading: isUploading ?? this.isUploading,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
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

  Future<void> uploadPhoto(XFile file) async {
    // ── CRIT-01 fix: null guard sebelum force-unwrap ──────────────────────
    final currentChallenge = state.challenge;
    if (currentChallenge == null) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Misi belum dimuat. Silakan coba lagi.',
      );
      return;
    }
    // ─────────────────────────────────────────────────────────────────────

    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final url = await _challengeService.uploadPhoto(file);
      final updatedChallenge = currentChallenge.copyWith(uploadedPhotoUrl: url);

      // ── HIGH-04 fix: resolusi moduleTitle dipindah dari View ke ViewModel ─
      final moduleTitle = _ref.read(missionViewModelProvider).activeModule?.title
          ?? currentChallenge.moduleId;
      // ──────────────────────────────────────────────────────────────────────

      final user = _ref.read(authViewModelProvider).currentUser;
      if (user != null) {
        await _submissionService.submitPhoto(
          userId: user.id,
          userName: user.name,
          moduleId: currentChallenge.moduleId,
          moduleTitle: moduleTitle,
          photoUrl: url,
        );
      }

      state = state.copyWith(challenge: updatedChallenge, isUploading: false);
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Upload gagal. Silakan coba lagi.',
      );
    }
  }

}
