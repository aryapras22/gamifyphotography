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
    required int requiredPoints, // threshold poin untuk unlock
  }) = _BadgeModel;

  factory BadgeModel.fromJson(Map<String, dynamic> json) => _$BadgeModelFromJson(json);
}
