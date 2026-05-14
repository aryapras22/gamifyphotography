import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo_submission_model.dart';

class SubmissionState {
  final Map<String, PhotoSubmissionModel> byModuleId; // key: moduleId
  final bool isLoading;
  final String? errorMessage;

  const SubmissionState({
    this.byModuleId = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  SubmissionState copyWith({
    Map<String, PhotoSubmissionModel>? byModuleId,
    bool? isLoading,
    String? errorMessage,
  }) =>
      SubmissionState(
        byModuleId: byModuleId ?? this.byModuleId,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

final submissionViewModelProvider =
    StateNotifierProvider<SubmissionViewModel, SubmissionState>(
        (ref) => SubmissionViewModel());

class SubmissionViewModel extends StateNotifier<SubmissionState> {
  final _db = FirebaseFirestore.instance;

  SubmissionViewModel() : super(const SubmissionState());

  Future<void> loadUserSubmissions(String userId) async {
    if (userId.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final snapshot = await _db
          .collection('photo_submissions')
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .get();

      final map = <String, PhotoSubmissionModel>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        // Normalize Timestamp → ISO String
        if (data['submittedAt'] is Timestamp) {
          data['submittedAt'] =
              (data['submittedAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['reviewedAt'] is Timestamp) {
          data['reviewedAt'] =
              (data['reviewedAt'] as Timestamp).toDate().toIso8601String();
        }
        final model = PhotoSubmissionModel.fromJson(data);
        // Simpan hanya submission terbaru per modul
        if (!map.containsKey(model.moduleId)) {
          map[model.moduleId] = model;
        }
      }
      state = state.copyWith(isLoading: false, byModuleId: map);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat data submission.',
      );
    }
  }

  PhotoSubmissionModel? forModule(String moduleId) =>
      state.byModuleId[moduleId];
}
