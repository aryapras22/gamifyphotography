import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_view_model.dart';
import '../providers/service_providers.dart';
import '../services/user_service.dart';

class CraftingState {
  final bool craftingDone;
  final int currentPoints;
  final int requiredPoints;
  final int bridgeProgress;
  final int maxBridgeSegments;
  final bool isLoading;
  /// true saat crafting baru saja selesai dan posttest perlu ditampilkan
  final bool triggerPosttest;

  CraftingState({
    this.craftingDone = false,
    this.currentPoints = 0,
    this.requiredPoints = 1000,
    this.bridgeProgress = 0,
    this.maxBridgeSegments = 5,
    this.isLoading = false,
    this.triggerPosttest = false,
  });

  CraftingState copyWith({
    bool? craftingDone,
    int? currentPoints,
    int? requiredPoints,
    int? bridgeProgress,
    int? maxBridgeSegments,
    bool? isLoading,
    bool? triggerPosttest,
  }) {
    return CraftingState(
      craftingDone: craftingDone ?? this.craftingDone,
      currentPoints: currentPoints ?? this.currentPoints,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      bridgeProgress: bridgeProgress ?? this.bridgeProgress,
      maxBridgeSegments: maxBridgeSegments ?? this.maxBridgeSegments,
      isLoading: isLoading ?? this.isLoading,
      triggerPosttest: triggerPosttest ?? this.triggerPosttest,
    );
  }
}

final craftingViewModelProvider = StateNotifierProvider<CraftingViewModel, CraftingState>(
  (ref) => CraftingViewModel(ref, ref.read(userServiceProvider)),
);

class CraftingViewModel extends StateNotifier<CraftingState> {
  final Ref _ref;
  final UserService _userService;

  CraftingViewModel(this._ref, this._userService) : super(CraftingState());

  void loadCraftingStatus() {
    final user = _ref.read(authViewModelProvider).currentUser;
    final progress = user?.bridgeProgress ?? 0;
    const itemCosts = [200, 150, 350, 500, 800, 1200];
    final cost = progress < itemCosts.length ? itemCosts[progress] : 0;
    state = state.copyWith(
      currentPoints: user?.points ?? 0,
      bridgeProgress: progress,
      maxBridgeSegments: itemCosts.length,
      requiredPoints: cost,
      craftingDone: progress >= itemCosts.length,
    );
  }

  bool get hasSufficientPoints => state.currentPoints >= state.requiredPoints;

  Future<void> doCrafting(int pointCost) async {
    if (state.isLoading || !hasSufficientPoints || state.bridgeProgress >= state.maxBridgeSegments) return;

    state = state.copyWith(isLoading: true);
    try {
      final success = await _userService.doCrafting(pointCost);
      if (success) {
        final user = _ref.read(authViewModelProvider).currentUser;
        if (user != null) {
          final updatedUser = user.copyWith(
            points: user.points - pointCost,
            bridgeProgress: user.bridgeProgress + 1,
          );
          _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);
        }

        final newProgress = state.bridgeProgress + 1;
        final justFinished = newProgress >= state.maxBridgeSegments;

        // Cek apakah posttest perlu ditampilkan
        final currentUser = _ref.read(authViewModelProvider).currentUser;
        final needPosttest = justFinished && (currentUser?.posttestDone == false);

        // Update the next required points
        const itemCosts = [200, 150, 350, 500, 800, 1200];
        final nextCost = newProgress < itemCosts.length ? itemCosts[newProgress] : 0;

        state = state.copyWith(
          craftingDone: justFinished,
          currentPoints: state.currentPoints - pointCost,
          bridgeProgress: newProgress,
          requiredPoints: nextCost,
          isLoading: false,
          triggerPosttest: needPosttest,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Reset triggerPosttest setelah posttest ditampilkan
  void clearPosttestTrigger() => state = state.copyWith(triggerPosttest: false);
}
