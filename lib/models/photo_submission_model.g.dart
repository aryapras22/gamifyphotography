// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_submission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoSubmissionModelImpl _$$PhotoSubmissionModelImplFromJson(
  Map<String, dynamic> json,
) => _$PhotoSubmissionModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  moduleId: json['moduleId'] as String,
  moduleTitle: json['moduleTitle'] as String,
  photoUrl: json['photoUrl'] as String,
  status: json['status'] as String? ?? 'pending',
  adminNote: json['adminNote'] as String?,
  submittedAt: DateTime.parse(json['submittedAt'] as String),
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
);

Map<String, dynamic> _$$PhotoSubmissionModelImplToJson(
  _$PhotoSubmissionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'moduleId': instance.moduleId,
  'moduleTitle': instance.moduleTitle,
  'photoUrl': instance.photoUrl,
  'status': instance.status,
  'adminNote': instance.adminNote,
  'submittedAt': instance.submittedAt.toIso8601String(),
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
};
