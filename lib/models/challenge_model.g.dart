// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeModelImpl _$$ChallengeModelImplFromJson(Map<String, dynamic> json) =>
    _$ChallengeModelImpl(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      instruction: json['instruction'] as String,
      pointReward: (json['pointReward'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      uploadedPhotoUrl: json['uploadedPhotoUrl'] as String?,
    );

Map<String, dynamic> _$$ChallengeModelImplToJson(
  _$ChallengeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'moduleId': instance.moduleId,
  'instruction': instance.instruction,
  'pointReward': instance.pointReward,
  'isCompleted': instance.isCompleted,
  'uploadedPhotoUrl': instance.uploadedPhotoUrl,
};
