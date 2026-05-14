import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photo_submission_model.dart';

class PhotoSubmissionService {
  final _db = FirebaseFirestore.instance;

  Future<void> submitPhoto({
    required String userId,
    required String userName,
    required String moduleId,
    required String moduleTitle,
    required String photoUrl,
  }) async {
    // Guard: do not create a new submission if one is already pending or approved.
    // A rejected submission allows re-submission (creates a new document).
    final existing = await _db
        .collection('photo_submissions')
        .where('userId', isEqualTo: userId)
        .where('moduleId', isEqualTo: moduleId)
        .where('status', whereIn: ['pending', 'approved'])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _db.collection('photo_submissions').add({
      'userId': userId,
      'userName': userName,
      'moduleId': moduleId,
      'moduleTitle': moduleTitle,
      'photoUrl': photoUrl,
      'status': 'pending',
      'adminNote': null,
      'adminScore': null,
      'submittedAt': FieldValue.serverTimestamp(),
      'reviewedAt': null,
    });
  }

  Stream<PhotoSubmissionModel?> watchUserSubmission(
      String userId, String moduleId) {
    return _db
        .collection('photo_submissions')
        .where('userId', isEqualTo: userId)
        .where('moduleId', isEqualTo: moduleId)
        .orderBy('submittedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      final data = <String, dynamic>{...doc.data(), 'id': doc.id};

      // Normalize Firestore Timestamps to ISO 8601 strings for fromJson
      if (data['submittedAt'] is Timestamp) {
        data['submittedAt'] =
            (data['submittedAt'] as Timestamp).toDate().toIso8601String();
      }
      if (data['reviewedAt'] is Timestamp) {
        data['reviewedAt'] =
            (data['reviewedAt'] as Timestamp).toDate().toIso8601String();
      }

      return PhotoSubmissionModel.fromJson(data);
    });
  }

  /// Returns a real-time stream of ALL submissions for a user, newest first.
  Stream<List<PhotoSubmissionModel>> watchAllUserSubmissions(String userId) {
    return _db
        .collection('photo_submissions')
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = <String, dynamic>{...doc.data(), 'id': doc.id};
              if (data['submittedAt'] is Timestamp) {
                data['submittedAt'] =
                    (data['submittedAt'] as Timestamp).toDate().toIso8601String();
              }
              if (data['reviewedAt'] is Timestamp) {
                data['reviewedAt'] =
                    (data['reviewedAt'] as Timestamp).toDate().toIso8601String();
              }
              return PhotoSubmissionModel.fromJson(data);
            }).toList());
  }
}
