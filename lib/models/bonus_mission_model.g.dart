// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bonus_mission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BonusMissionModelImpl _$$BonusMissionModelImplFromJson(
  Map<String, dynamic> json,
) => _$BonusMissionModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  page1Title: json['page1Title'] as String? ?? '',
  page1Description: json['page1Description'] as String? ?? '',
  page1ImageUrls:
      (json['page1ImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  page2WhenToUse: json['page2WhenToUse'] as String? ?? '',
  page2HowToUse: json['page2HowToUse'] as String? ?? '',
  page2VisualGuideUrl: json['page2VisualGuideUrl'] as String? ?? '',
  xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
  order: (json['order'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? false,
);

Map<String, dynamic> _$$BonusMissionModelImplToJson(
  _$BonusMissionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'page1Title': instance.page1Title,
  'page1Description': instance.page1Description,
  'page1ImageUrls': instance.page1ImageUrls,
  'page2WhenToUse': instance.page2WhenToUse,
  'page2HowToUse': instance.page2HowToUse,
  'page2VisualGuideUrl': instance.page2VisualGuideUrl,
  'xpReward': instance.xpReward,
  'order': instance.order,
  'isActive': instance.isActive,
};
