import '../models/challenge_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated.');

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance
        .ref()
        .child('challenge_photos')
        .child(uid)
        .child(fileName);

    final uploadTask = await ref.putFile(
      File(file.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> completeChallenge(String challengeId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
