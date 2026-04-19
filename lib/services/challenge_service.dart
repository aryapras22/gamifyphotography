import '../models/challenge_model.dart';
import 'package:image_picker/image_picker.dart';

class ChallengeService {
  Future<ChallengeModel> getChallenge(String moduleId) async {
    await Future.delayed(const Duration(seconds: 1));
    return ChallengeModel(
      id: 'c_$moduleId',
      moduleId: moduleId,
      instruction: 'Ambil foto menggunakan rule of thirds.',
      pointReward: 50,
    );
  }

  Future<String> uploadPhoto(XFile file) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://mockurl.com/photo.jpg';
  }

  Future<void> completeChallenge(String challengeId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
