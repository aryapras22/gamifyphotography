import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_view_model.dart';
import '../providers/service_providers.dart';
import '../providers/crafting_items_provider.dart';
import '../services/user_service.dart';

class CraftingState {
  final bool craftingDone;
  final int currentPoints;
  final int craftingBalance;
  final int requiredPoints;
  final int bridgeProgress;
  final int maxBridgeSegments;
  final bool isLoading;

  CraftingState({
    this.craftingDone = false,
    this.currentPoints = 0,
    this.craftingBalance = 0,
    this.requiredPoints = 1000,
    this.bridgeProgress = 0,
    this.maxBridgeSegments = 5,
    this.isLoading = false,
  });

  CraftingState copyWith({
    bool? craftingDone,
    int? currentPoints,
    int? craftingBalance,
    int? requiredPoints,
    int? bridgeProgress,
    int? maxBridgeSegments,
    bool? isLoading,
  }) {
    return CraftingState(
      craftingDone: craftingDone ?? this.craftingDone,
      currentPoints: currentPoints ?? this.currentPoints,
      craftingBalance: craftingBalance ?? this.craftingBalance,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      bridgeProgress: bridgeProgress ?? this.bridgeProgress,
      maxBridgeSegments: maxBridgeSegments ?? this.maxBridgeSegments,
      isLoading: isLoading ?? this.isLoading,
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

    // Get items from provider (Firestore-driven)
    final itemsAsync = _ref.read(craftingItemsProvider);
    final items = itemsAsync.valueOrNull ?? [];
    final maxSegments = items.isNotEmpty ? items.length : 6;
    final cost = progress < items.length ? items[progress].cost : 0;

    state = state.copyWith(
      currentPoints: user?.points ?? 0,
      craftingBalance: user?.craftingBalance ?? 0,
      bridgeProgress: progress,
      maxBridgeSegments: maxSegments,
      requiredPoints: cost,
      craftingDone: progress >= maxSegments,
    );
  }

  bool get hasSufficientPoints => state.craftingBalance >= state.requiredPoints;

  Future<void> doCrafting(int pointCost) async {
    if (state.isLoading || !hasSufficientPoints || state.bridgeProgress >= state.maxBridgeSegments) return;

    state = state.copyWith(isLoading: true);
    try {
      final user = _ref.read(authViewModelProvider).currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final success = await _userService.doCrafting(
        userId: user.id,
        pointCost: pointCost,
      );
      if (success) {
        // Update local user state — only craftingBalance decreases, points stays
        final updatedUser = user.copyWith(
          craftingBalance: user.craftingBalance - pointCost,
          bridgeProgress: user.bridgeProgress + 1,
        );
        _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);

        final newProgress = state.bridgeProgress + 1;
        final justFinished = newProgress >= state.maxBridgeSegments;

        // Get next cost from Firestore items
        final itemsAsync = _ref.read(craftingItemsProvider);
        final items = itemsAsync.valueOrNull ?? [];
        final nextCost = newProgress < items.length ? items[newProgress].cost : 0;

        state = state.copyWith(
          craftingDone: justFinished,
          craftingBalance: state.craftingBalance - pointCost,
          currentPoints: state.currentPoints,
          bridgeProgress: newProgress,
          requiredPoints: nextCost,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}
