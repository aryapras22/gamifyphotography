// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      points: (json['points'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      earnedBadgeIds:
          (json['earnedBadgeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      completedPhotoUrls:
          (json['completedPhotoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      bridgeProgress: (json['bridgeProgress'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'points': instance.points,
      'level': instance.level,
      'earnedBadgeIds': instance.earnedBadgeIds,
      'completedPhotoUrls': instance.completedPhotoUrls,
      'bridgeProgress': instance.bridgeProgress,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
