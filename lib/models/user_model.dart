import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  factory UserModel({
    required String id,
    required String name,
    required String email,
    @Default('user') String role,
    @Default(0) int points,
    @Default(1) int level,
    @Default([]) List<String> earnedBadgeIds,
    @Default([]) List<String> completedPhotoUrls,
    @Default(0) int bridgeProgress,
    @Default([]) List<String> completedModuleIds,
    @Default(0) int streakCount,
    DateTime? lastLoginDate,
    @Default([false, false, false, false, false, false, false]) List<bool> weekHistory,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
