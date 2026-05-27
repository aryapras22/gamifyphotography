// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crafting_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CraftingItemModelImpl _$$CraftingItemModelImplFromJson(
  Map<String, dynamic> json,
) => _$CraftingItemModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  cost: (json['cost'] as num).toInt(),
  order: (json['order'] as num).toInt(),
  imagePath: json['imagePath'] as String? ?? '',
  colorHex: json['colorHex'] as String? ?? '#E9D5FF',
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$CraftingItemModelImplToJson(
  _$CraftingItemModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'cost': instance.cost,
  'order': instance.order,
  'imagePath': instance.imagePath,
  'colorHex': instance.colorHex,
  'isActive': instance.isActive,
};
