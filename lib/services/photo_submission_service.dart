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
    await _db.collection('photo_submissions').add({
      'userId': userId,
      'userName': userName,
      'moduleId': moduleId,
      'moduleTitle': moduleTitle,
      'photoUrl': photoUrl,
      'status': 'pending',
      'adminNote': null,
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
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return PhotoSubmissionModel.fromJson({...doc.data(), 'id': doc.id});
    });
  }
}
