// lib/services/level_service.dart
// Firestore operations for level progress & quiz results

import 'package:cloud_firestore/cloud_firestore.dart';

class LevelService {
  final _db = FirebaseFirestore.instance;

  DocumentReference _userRef(String userId) =>
      _db.collection('users').doc(userId);

  // ── Level Completion ────────────────────────────────────────────────────

  /// Tandai level materi sebagai selesai dan unlock level berikutnya.
  /// Idempotent: aman dipanggil berkali-kali.
  Future<void> completeMaterialLevel({
    required String userId,
    required int levelNumber,
  }) async {
    final ref = _userRef(userId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data()! as Map<String, dynamic>;
      final completed = List<int>.from(
        (data['completedLevels'] as List? ?? []).map((e) => (e as num).toInt()),
      );
      if (completed.contains(levelNumber)) return; // idempotent
      completed.add(levelNumber);
      tx.update(ref, {'completedLevels': completed});
    });
  }

  /// Simpan skor quiz dan tandai level quiz sebagai selesai jika lulus.
  /// Selalu menyimpan skor terbaik (tidak menimpa skor lebih tinggi).
  Future<void> completeQuizLevel({
    required String userId,
    required int levelNumber,
    required int score,
    required bool passed,
  }) async {
    final ref = _userRef(userId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data()! as Map<String, dynamic>;

      final completed = List<int>.from(
        (data['completedLevels'] as List? ?? []).map((e) => (e as num).toInt()),
      );

      // Simpan skor terbaik
      final quizScores = Map<String, dynamic>.from(data['quizScores'] ?? {});
      final key = levelNumber.toString();
      final existingScore = (quizScores[key] as num?)?.toInt() ?? 0;
      if (score > existingScore) {
        quizScores[key] = score;
      }

      // Tandai completed hanya jika lulus
      if (passed && !completed.contains(levelNumber)) {
        completed.add(levelNumber);
      }

      tx.update(ref, {
        'completedLevels': completed,
        'quizScores': quizScores,
      });
    });
  }

  /// Simpan hasil quiz ke collection quiz_results (untuk analytics).
  Future<void> saveQuizResult({
    required String userId,
    required String userName,
    required String userEmail,
    required int levelNumber,
    required int score,
    required List<int> answers,
    required bool passed,
  }) async {
    await _db.collection('quiz_results').add({
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'type': 'quiz_level_$levelNumber',
      'levelNumber': levelNumber,
      'score': score,
      'answers': answers,
      'passed': passed,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }
}
