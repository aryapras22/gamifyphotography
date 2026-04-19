import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_view_model.dart';
import '../services/user_service.dart';

class CraftingState {
  final bool craftingDone;
  final int currentPoints;
  final int requiredPoints;
  final int bridgeProgress;
  final int maxBridgeSegments;

  CraftingState({
    this.craftingDone = false,
    this.currentPoints = 0,
    this.requiredPoints = 1000, // as per user's image, 1000 point for crafting
    this.bridgeProgress = 0,
    this.maxBridgeSegments = 5,
  });

  CraftingState copyWith({
    bool? craftingDone,
    int? currentPoints,
    int? requiredPoints,
    int? bridgeProgress,
    int? maxBridgeSegments,
  }) {
    return CraftingState(
      craftingDone: craftingDone ?? this.craftingDone,
      currentPoints: currentPoints ?? this.currentPoints,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      bridgeProgress: bridgeProgress ?? this.bridgeProgress,
      maxBridgeSegments: maxBridgeSegments ?? this.maxBridgeSegments,
    );
  }
}

final userServiceProvider = Provider<UserService>((ref) => UserService());

final craftingViewModelProvider = StateNotifierProvider<CraftingViewModel, CraftingState>(
  (ref) => CraftingViewModel(ref, ref.read(userServiceProvider)),
);

class CraftingViewModel extends StateNotifier<CraftingState> {
  final Ref _ref;
  final UserService _userService;

  CraftingViewModel(this._ref, this._userService) : super(CraftingState());

  void loadCraftingStatus() {
    final user = _ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      state = state.copyWith(
        currentPoints: user.points,
        bridgeProgress: user.bridgeProgress,
      );
    }
  }

  bool get hasSufficientPoints => state.currentPoints >= state.requiredPoints;

  Future<void> doCrafting(int pointCost) async {
    // Only craft if we have enough points AND bridge is not finished
    if (!hasSufficientPoints || state.bridgeProgress >= state.maxBridgeSegments) return;

    final success = await _userService.doCrafting(pointCost);
    if (success) {
      final user = _ref.read(authViewModelProvider).currentUser;
      if (user != null) {
        user.points -= pointCost;
        user.bridgeProgress += 1;
      }
      
      final newProgress = state.bridgeProgress + 1;
      state = state.copyWith(
        craftingDone: newProgress >= state.maxBridgeSegments,
        currentPoints: state.currentPoints - pointCost,
        bridgeProgress: newProgress,
      );
    }
  }
}
