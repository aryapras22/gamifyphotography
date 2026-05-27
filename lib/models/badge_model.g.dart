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
      badgeType: json['badgeType'] as String? ?? 'points',
      requiredPoints: (json['requiredPoints'] as num?)?.toInt() ?? 0,
      requiredLevels: (json['requiredLevels'] as num?)?.toInt() ?? 0,
      requiredStreak: (json['requiredStreak'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$BadgeModelImplToJson(_$BadgeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconPath': instance.iconPath,
      'badgeType': instance.badgeType,
      'requiredPoints': instance.requiredPoints,
      'requiredLevels': instance.requiredLevels,
      'requiredStreak': instance.requiredStreak,
      'isActive': instance.isActive,
    };
