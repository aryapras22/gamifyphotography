import 'package:freezed_annotation/freezed_annotation.dart';

part 'crafting_item_model.freezed.dart';
part 'crafting_item_model.g.dart';

@freezed
class CraftingItemModel with _$CraftingItemModel {
  factory CraftingItemModel({
    required String id,
    required String name,
    @Default('') String description,
    required int cost,
    required int order,
    @Default('') String imagePath, // Firebase Storage URL
    @Default('#E9D5FF') String colorHex,
    @Default(true) bool isActive,
  }) = _CraftingItemModel;

  factory CraftingItemModel.fromJson(Map<String, dynamic> json) =>
      _$CraftingItemModelFromJson(json);
}
