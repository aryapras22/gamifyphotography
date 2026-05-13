// lib/view_models/profile_view_model.dart
// TASK-05 — ProfileViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import '../models/user_model.dart';
import '../services/badge_service.dart';
import '../providers/service_providers.dart';
import 'auth_view_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ProfileState {
  final UserModel? user;
  final List<BadgeModel> allBadges;
  final List<String> earnedBadgeIds;
  final List<String> completedChallengePhotoUrls;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.user,
    this.allBadges = const [],
    this.earnedBadgeIds = const [],
    this.completedChallengePhotoUrls = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserModel? user,
    List<BadgeModel>? allBadges,
    List<String>? earnedBadgeIds,
    List<String>? completedChallengePhotoUrls,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      allBadges: allBadges ?? this.allBadges,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      completedChallengePhotoUrls:
          completedChallengePhotoUrls ?? this.completedChallengePhotoUrls,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(
    ref,
    ref.read(badgeServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------

class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref _ref;
  final BadgeService _badgeService;

  ProfileViewModel(this._ref, this._badgeService)
      : super(const ProfileState());

  /// Muat data profil dari authViewModelProvider + badge service.
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = _ref.read(authViewModelProvider).currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User tidak ditemukan. Silakan login ulang.',
        );
        return;
      }

      final allBadges = await _badgeService.getAllBadges();

      state = state.copyWith(
        isLoading: false,
        user: user,
        allBadges: allBadges,
        earnedBadgeIds: List.of(user.earnedBadgeIds),
        // Foto dari challenge disimpan di ChallengeState.uploadedPhotoUrl
        // Mock: list kosong — diisi dari state challenge via view jika tersedia
        completedChallengePhotoUrls: List<String>.from(user.completedPhotoUrls),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat profil.',
      );
    }
  }

  /// Reload semua data profil (untuk pull-to-refresh).
  Future<void> refreshProfile() async {
    await loadProfile();
  }
}
