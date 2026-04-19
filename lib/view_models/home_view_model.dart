import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return HomeViewModel(ref);
});

class HomeViewModel {
  final Ref _ref;

  HomeViewModel(this._ref);

  int get currentPoints {
    return _ref.read(authViewModelProvider).currentUser?.points ?? 0;
  }

  int get currentLevel {
    return _ref.read(authViewModelProvider).currentUser?.level ?? 1;
  }

  void navigateToMission(BuildContext context) {
    context.go('/mission');
  }

  void navigateToCrafting(BuildContext context) {
    context.go('/crafting');
  }
}
