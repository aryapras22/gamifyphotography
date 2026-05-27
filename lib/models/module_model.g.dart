// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModuleModelImpl _$$ModuleModelImplFromJson(Map<String, dynamic> json) =>
    _$ModuleModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      materialContent: json['materialContent'] as String? ?? '',
      order: (json['order'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      levelCount: (json['levelCount'] as num?)?.toInt() ?? 0,
      referenceImageUrls:
          (json['referenceImageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      howToUse: json['howToUse'] as String? ?? '',
      howToUseImageUrl: json['howToUseImageUrl'] as String?,
      type: json['type'] as String? ?? 'materi',
    );

Map<String, dynamic> _$$ModuleModelImplToJson(_$ModuleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'materialContent': instance.materialContent,
      'order': instance.order,
      'isCompleted': instance.isCompleted,
      'levelCount': instance.levelCount,
      'referenceImageUrls': instance.referenceImageUrls,
      'howToUse': instance.howToUse,
      'howToUseImageUrl': instance.howToUseImageUrl,
      'type': instance.type,
    };
