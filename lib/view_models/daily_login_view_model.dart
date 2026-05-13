// lib/view_models/daily_login_view_model.dart
// TASK-03 — DailyLoginViewModel

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/daily_login_service.dart';
import '../providers/service_providers.dart';
import 'auth_view_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class DailyLoginState {
  final bool isLoading;
  final bool hasClaimed;
  final int currentStreak; // 0–7
  final List<bool> weekHistory; // 7 items
  final bool showClaimSuccess;
  final String? errorMessage;

  const DailyLoginState({
    this.isLoading = false,
    this.hasClaimed = false,
    this.currentStreak = 0,
    this.weekHistory = const [false, false, false, false, false, false, false],
    this.showClaimSuccess = false,
    this.errorMessage,
  });

  DailyLoginState copyWith({
    bool? isLoading,
    bool? hasClaimed,
    int? currentStreak,
    List<bool>? weekHistory,
    bool? showClaimSuccess,
    String? errorMessage,
  }) {
    return DailyLoginState(
      isLoading: isLoading ?? this.isLoading,
      hasClaimed: hasClaimed ?? this.hasClaimed,
      currentStreak: currentStreak ?? this.currentStreak,
      weekHistory: weekHistory ?? this.weekHistory,
      showClaimSuccess: showClaimSuccess ?? this.showClaimSuccess,
      errorMessage: errorMessage,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final dailyLoginViewModelProvider =
    StateNotifierProvider<DailyLoginViewModel, DailyLoginState>((ref) {
  return DailyLoginViewModel(ref, ref.read(dailyLoginServiceProvider));
});

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------

class DailyLoginViewModel extends StateNotifier<DailyLoginState> {
  final Ref _ref;
  final DailyLoginService _service;
  Timer? _successTimer;

  DailyLoginViewModel(this._ref, this._service) : super(const DailyLoginState());

  @override
  void dispose() {
    _successTimer?.cancel();
    super.dispose();
  }

  /// Dipanggil saat view pertama kali tampil — load state awal user.
  Future<void> initialize() async {
    final userId = _ref.read(authViewModelProvider).currentUser?.id ?? '';
    if (userId.isEmpty) return;

    state = state.copyWith(isLoading: true);
    try {
      final hasClaimed = await _service.hasClaimedToday(userId);
      final streak = await _service.getCurrentStreak(userId);
      final history = await _service.getWeekHistory(userId);

      state = state.copyWith(
        isLoading: false,
        hasClaimed: hasClaimed,
        currentStreak: streak,
        weekHistory: history,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat data login harian.',
      );
    }
  }

  /// Lakukan claim — update state + trigger success animation selama 2 detik.
  Future<void> claimToday() async {
    final userId = _ref.read(authViewModelProvider).currentUser?.id ?? '';
    if (userId.isEmpty) return;

    if (state.hasClaimed || state.isLoading) return;

    state = state.copyWith(isLoading: true);
    try {
      await _service.claimDailyLogin(userId);
      final newStreak = await _service.getCurrentStreak(userId);
      final history = await _service.getWeekHistory(userId);

      // Persist points
      final user = _ref.read(authViewModelProvider).currentUser;
      if (user != null) {
        final updatedUser = user.copyWith(
          points: user.points + kDailyLoginPoints,
          level: ((user.points + kDailyLoginPoints) ~/ 100) + 1,
          streakCount: newStreak,
          lastLoginDate: DateTime.now(),
        );
        await _ref.read(authServiceProvider).updateUserProgress(updatedUser);
        _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);
      }

      state = state.copyWith(
        isLoading: false,
        hasClaimed: true,
        currentStreak: newStreak,
        weekHistory: history,
        showClaimSuccess: true,
      );

      // Auto-reset success flag setelah 2 detik
      _successTimer?.cancel();
      _successTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          state = state.copyWith(showClaimSuccess: false);
        }
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}
