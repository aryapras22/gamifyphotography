import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_model.freezed.dart';
part 'challenge_model.g.dart';

@freezed
class ChallengeModel with _$ChallengeModel {
  factory ChallengeModel({
    required String id,
    required String moduleId,
    required String instruction,
    required int pointReward,
    @Default(false) bool isCompleted,
    String? uploadedPhotoUrl,
  }) = _ChallengeModel;

  factory ChallengeModel.fromJson(Map<String, dynamic> json) => _$ChallengeModelFromJson(json);
}
