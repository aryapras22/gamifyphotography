// lib/services/firestore_level_content_service.dart
// TASK-M02 — Service baru untuk membaca konten level dari Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/level_model.dart';

class FirestoreLevelContentService {
  final _db = FirebaseFirestore.instance;

  // ── Levels ──────────────────────────────────────────────────────────────

  /// Ambil semua level aktif, terurut by field 'order'.
  /// Firestore index diperlukan: isActive ASC + order ASC
  Future<List<FirestoreLevel>> getAllActiveLevels() async {
    final snap = await _db
        .collection('modules')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => FirestoreLevel.fromFirestore(d.id, d.data()))
        .toList();
  }

  // ── Quiz Questions ───────────────────────────────────────────────────────

  /// Ambil soal quiz untuk satu level dari subcollection `questions`.
  /// Firestore index: order ASC (single-field, auto-created)
  Future<List<QuizQuestion>> getQuizQuestions(String levelId) async {
    final snap = await _db
        .collection('modules')
        .doc(levelId)
        .collection('questions')
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => QuizQuestion.fromFirestore(d.data()))
        .toList();
  }

  // ── Pretest Questions ────────────────────────────────────────────────────

  /// Ambil soal pretest dari collection `pretest_questions`.
  /// Firestore index: order ASC (single-field, auto-created)
  Future<List<QuizQuestion>> getPretestQuestions() async {
    final snap = await _db
        .collection('pretest_questions')
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => QuizQuestion.fromFirestore(d.data()))
        .toList();
  }

  /// Ambil satu level berdasarkan levelNumber (untuk lookup cepat).
  Future<FirestoreLevel?> getLevelByNumber(int levelNumber) async {
    try {
      final snap = await _db
          .collection('modules')
          .where('levelNumber', isEqualTo: levelNumber)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return FirestoreLevel.fromFirestore(doc.id, doc.data());
    } catch (e) {
      debugPrint('[FirestoreLevelContentService] getLevelByNumber error: $e');
      return null;
    }
  }
}
