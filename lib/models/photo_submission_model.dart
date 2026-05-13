import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_submission_model.freezed.dart';
part 'photo_submission_model.g.dart';

@freezed
class PhotoSubmissionModel with _$PhotoSubmissionModel {
  factory PhotoSubmissionModel({
    required String id,
    required String userId,
    required String userName,
    required String moduleId,
    required String moduleTitle,
    required String photoUrl,
    @Default('pending') String status,
    String? adminNote,
    required DateTime submittedAt,
    DateTime? reviewedAt,
  }) = _PhotoSubmissionModel;

  factory PhotoSubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$PhotoSubmissionModelFromJson(json);
}
