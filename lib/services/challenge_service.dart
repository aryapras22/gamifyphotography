// lib/services/challenge_service.dart
// Firebase-only — no hardcoded instructions

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/challenge_model.dart';

class ChallengeService {
  final _db = FirebaseFirestore.instance;

  /// Fetch challenge/mission data from Firestore modules collection.
  /// The instruction comes from the module's page2.howToUse or a dedicated field.
  Future<ChallengeModel> getChallenge(String moduleId) async {
    final snap = await _db.collection('modules').doc(moduleId).get();
    if (!snap.exists) {
      // Try finding by moduleId field or legacy ID pattern
      final query = await _db
          .collection('modules')
          .where('moduleId', isEqualTo: moduleId)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        return _buildChallenge(moduleId, data);
      }
      // Return a generic challenge if module not found
      return ChallengeModel(
        id: 'c_$moduleId',
        moduleId: moduleId,
        instruction: 'Ambil foto untuk menyelesaikan tantangan ini.',
        pointReward: 50,
      );
    }
    return _buildChallenge(moduleId, snap.data()!);
  }

  ChallengeModel _buildChallenge(String moduleId, Map<String, dynamic> data) {
    // Try to get challenge instruction from various possible fields
    String instruction = 'Ambil foto untuk menyelesaikan tantangan ini.';

    if (data['challengeInstruction'] != null && data['challengeInstruction'] != '') {
      instruction = data['challengeInstruction'] as String;
    } else if (data['page2'] is Map) {
      final page2 = data['page2'] as Map;
      if (page2['howToUse'] != null && page2['howToUse'] != '') {
        instruction = 'Ambil foto menggunakan teknik: ${data['title'] ?? moduleId}';
      }
    }

    final pointReward = (data['pointReward'] as num?)?.toInt() ?? 50;

    return ChallengeModel(
      id: 'c_$moduleId',
      moduleId: moduleId,
      instruction: instruction,
      pointReward: pointReward,
    );
  }

  Future<String> uploadPhoto(XFile file) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated.');

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance
        .ref()
        .child('photo_submissions')
        .child(uid)
        .child(fileName);

    final uploadTask = await ref.putFile(
      File(file.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> completeChallenge(String challengeId) async {
    // Challenge completion is tracked via photo_submissions collection
    // No additional action needed here
  }
}
