class ChallengeModel {
  final String id;
  final String moduleId;
  final String instruction;
  final int pointReward;
  bool isCompleted;
  String? uploadedPhotoUrl;

  ChallengeModel({
    required this.id,
    required this.moduleId,
    required this.instruction,
    required this.pointReward,
    this.isCompleted = false,
    this.uploadedPhotoUrl,
  });
}
