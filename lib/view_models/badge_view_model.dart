// lib/view_models/badge_view_model.dart
// TASK-04 — BadgeViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import '../models/user_model.dart';
import '../services/badge_service.dart';
import '../providers/service_providers.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class BadgeState {
  final List<BadgeModel> allBadges;
  final List<String> earnedBadgeIds;
  final List<BadgeModel> newlyUnlocked;
  final bool isLoading;
  final String? errorMessage;

  const BadgeState({
    this.allBadges = const [],
    this.earnedBadgeIds = const [],
    this.newlyUnlocked = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BadgeState copyWith({
    List<BadgeModel>? allBadges,
    List<String>? earnedBadgeIds,
    List<BadgeModel>? newlyUnlocked,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BadgeState(
      allBadges: allBadges ?? this.allBadges,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      newlyUnlocked: newlyUnlocked ?? this.newlyUnlocked,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final badgeViewModelProvider =
    StateNotifierProvider<BadgeViewModel, BadgeState>((ref) {
  return BadgeViewModel(ref.read(badgeServiceProvider));
});

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------

class BadgeViewModel extends StateNotifier<BadgeState> {
  final BadgeService _badgeService;

  BadgeViewModel(this._badgeService) : super(const BadgeState());

  /// Load semua badge dan tandai mana yang sudah earned oleh [user].
  Future<void> loadBadges(UserModel user) async {
    state = state.copyWith(isLoading: true);
    try {
      final all = await _badgeService.getAllBadges();
      state = state.copyWith(
        isLoading: false,
        allBadges: all,
        earnedBadgeIds: List.of(user.earnedBadgeIds),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat badge.',
      );
    }
  }

  /// Cek kondisi unlock badge baru. Jika ada yang baru, simpan di
  /// [newlyUnlocked] untuk ditampilkan sebagai notifikasi.
  Future<void> checkAndUnlockBadges(UserModel user, int streak) async {
    try {
      final newBadges = await _badgeService.checkNewBadges(
        level: user.level,
        streak: streak,
        earnedBadgeIds: user.earnedBadgeIds,
        completedFirstMission: user.level >= 1,
      );
      if (newBadges.isNotEmpty) {
        final updatedIds = [
          ...state.earnedBadgeIds,
          ...newBadges.map((b) => b.id),
        ];
        state = state.copyWith(
          earnedBadgeIds: updatedIds,
          newlyUnlocked: newBadges,
        );
      }
    } catch (_) {
      // Tidak perlu update error state — badge check adalah best-effort
    }
  }

  /// Reset daftar badge baru setelah notifikasi ditampilkan.
  void clearNewlyUnlocked() {
    state = state.copyWith(newlyUnlocked: []);
  }
}
