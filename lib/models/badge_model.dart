import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge_model.freezed.dart';
part 'badge_model.g.dart';

@freezed
class BadgeModel with _$BadgeModel {
  factory BadgeModel({
    required String id,
    required String title,
    required String description,
    required String iconPath,
    @Default('points') String badgeType, // "points" | "completed_levels" | "streak"
    @Default(0) int requiredPoints,
    @Default(0) int requiredLevels,
    @Default(0) int requiredStreak,
    @Default(true) bool isActive,
  }) = _BadgeModel;

  factory BadgeModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeModelFromJson(json);
}
