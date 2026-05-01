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
      materialContent: json['materialContent'] as String,
      order: (json['order'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$ModuleModelImplToJson(_$ModuleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'materialContent': instance.materialContent,
      'order': instance.order,
      'isCompleted': instance.isCompleted,
    };
