import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/badge_model.dart';
import '../services/user_service.dart';
import 'auth_view_model.dart';
import '../providers/service_providers.dart';

class ProgressState {
  final UserModel? user;
  final List<BadgeModel> earnedBadges;
  final double progressPercentage;

  ProgressState({
    this.user,
    this.earnedBadges = const [],
    this.progressPercentage = 0.0,
  });

  ProgressState copyWith({
    UserModel? user,
    List<BadgeModel>? earnedBadges,
    double? progressPercentage,
  }) {
    return ProgressState(
      user: user ?? this.user,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}

final progressViewModelProvider = StateNotifierProvider<ProgressViewModel, ProgressState>(
  (ref) => ProgressViewModel(ref, ref.read(userServiceProvider)),
);

class ProgressViewModel extends StateNotifier<ProgressState> {
  final Ref _ref;
  final UserService _userService;

  ProgressViewModel(this._ref, this._userService) : super(ProgressState());

  Future<void> loadUserProgress() async {
    final user = _ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      double percentage = (user.points % 100) / 100.0;
      state = state.copyWith(user: user, progressPercentage: percentage);
    }
  }

  Future<void> loadBadges() async {
    final allBadges = await _userService.getBadges();
    final user = state.user;
    
    if (user != null) {
      final earned = allBadges.where((b) => user.earnedBadgeIds.contains(b.id)).toList();
      state = state.copyWith(earnedBadges: earned);
    }
  }
}
