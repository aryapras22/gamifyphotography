import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  factory UserModel({
    required String id,
    required String name,
    required String email,
    @Default(0) int points,
    @Default(1) int level,
    @Default([]) List<String> earnedBadgeIds,
    @Default([]) List<String> completedPhotoUrls,
    @Default(0) int bridgeProgress, // Tracker untuk jembatan
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
