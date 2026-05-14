import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo_submission_model.dart';
import '../view_models/auth_view_model.dart';
import 'service_providers.dart';

/// Single source of truth for a user's submission status on one module.
/// Used by both ModuleDetailView and SubmissionStatusView.
final submissionStatusProvider =
    StreamProvider.autoDispose.family<PhotoSubmissionModel?, String>(
  (ref, moduleId) {
    final userId = ref.watch(authViewModelProvider).currentUser?.id;
    if (userId == null) return Stream.value(null);
    final service = ref.watch(photoSubmissionServiceProvider);
    return service.watchUserSubmission(userId, moduleId);
  },
);
