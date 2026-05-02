import '../models/challenge_model.dart';
import 'package:image_picker/image_picker.dart';

class ChallengeService {
  Future<ChallengeModel> getChallenge(String moduleId) async {
    await Future.delayed(const Duration(seconds: 1));
    return ChallengeModel(
      id: 'c_$moduleId',
      moduleId: moduleId,
      instruction: _getInstruction(moduleId),
      pointReward: 50,
    );
  }

  String _getInstruction(String moduleId) {
    switch (moduleId) {
      case 'M01':
        return 'Ambil foto menggunakan Rule of Thirds.';
      case 'M02':
        return 'Ambil foto menggunakan Leading Lines.';
      case 'M03':
        return 'Ambil foto menggunakan Framing within a Frame.';
      case 'M04':
        return 'Ambil foto menggunakan Symmetry and Patterns.';
      case 'M05':
        return 'Ambil foto menggunakan Golden Triangle.';
      case 'M06':
        return 'Ambil foto menggunakan Negative Space.';
      case 'M07':
        return 'Ambil foto menggunakan Rule of Odds.';
      case 'M08':
        return 'Ambil foto menggunakan Depth of Field.';
      case 'M09':
        return 'Ambil foto menggunakan Point of View.';
      case 'M10':
        return 'Ambil foto menggunakan Center Dominance.';
      default:
        return 'Ambil foto untuk menyelesaikan tantangan ini.';
    }
  }

  Future<String> uploadPhoto(XFile file) async {
    await Future.delayed(const Duration(seconds: 1)); // simulasi upload
    // Mock: kembalikan path lokal asli agar foto bisa ditampilkan di FeedbackView
    return file.path;
  }

  Future<void> completeChallenge(String challengeId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
