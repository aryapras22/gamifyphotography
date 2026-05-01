// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BadgeModelImpl _$$BadgeModelImplFromJson(Map<String, dynamic> json) =>
    _$BadgeModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String,
      requiredPoints: (json['requiredPoints'] as num).toInt(),
    );

Map<String, dynamic> _$$BadgeModelImplToJson(_$BadgeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconPath': instance.iconPath,
      'requiredPoints': instance.requiredPoints,
    };
