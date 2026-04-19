import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_view_model.dart';
import '../services/user_service.dart';

class CraftingState {
  final bool craftingDone;
  final int currentPoints;
  final int requiredPoints;

  CraftingState({
    this.craftingDone = false,
    this.currentPoints = 0,
    this.requiredPoints = 100, // example
  });

  CraftingState copyWith({
    bool? craftingDone,
    int? currentPoints,
    int? requiredPoints,
  }) {
    return CraftingState(
      craftingDone: craftingDone ?? this.craftingDone,
      currentPoints: currentPoints ?? this.currentPoints,
      requiredPoints: requiredPoints ?? this.requiredPoints,
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
      state = state.copyWith(currentPoints: user.points);
    }
  }

  bool get hasSufficientPoints => state.currentPoints >= state.requiredPoints;

  Future<void> doCrafting(int pointCost) async {
    if (!hasSufficientPoints) return;

    final success = await _userService.doCrafting(pointCost);
    if (success) {
      final user = _ref.read(authViewModelProvider).currentUser;
      if (user != null) {
        user.points -= pointCost;
      }
      state = state.copyWith(
        craftingDone: true,
        currentPoints: state.currentPoints - pointCost,
      );
    }
  }
}
