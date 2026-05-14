import 'package:flutter/material.dart';
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

/// Real-time stream of all submissions for the current user (for profile history).
final submissionHistoryProvider =
    StreamProvider.autoDispose<List<PhotoSubmissionModel>>((ref) {
  final userId = ref.watch(authViewModelProvider).currentUser?.id;
  if (userId == null) return Stream.value([]);
  final service = ref.watch(photoSubmissionServiceProvider);
  return service.watchAllUserSubmissions(userId);
});

/// Watches all user submissions and awards points when admin approves.
/// This provider must be watched somewhere that stays alive (e.g., MainLayoutView).
final submissionApprovalWatcherProvider =
    StreamProvider.autoDispose<void>((ref) async* {
  final userId = ref.watch(authViewModelProvider).currentUser?.id;
  if (userId == null) return;

  final service = ref.watch(photoSubmissionServiceProvider);
  final authService = ref.watch(authServiceProvider);
  final authNotifier = ref.read(authViewModelProvider.notifier);

  await for (final submissions in service.watchAllUserSubmissions(userId)) {
    for (final submission in submissions) {
      if (submission.status == 'approved' && submission.adminScore != null) {
        final currentUser = ref.read(authViewModelProvider).currentUser;
        if (currentUser == null) continue;
        // Only award if module not already completed in local state
        if (!currentUser.completedModuleIds.contains(submission.moduleId)) {
          try {
            await authService.awardPointsForApprovedSubmission(
              userId: userId,
              moduleId: submission.moduleId,
              adminScore: submission.adminScore!,
              photoUrl: submission.photoUrl,
            );
            // Refresh local user state from Firestore
            final updatedUser = await authService.fetchUser(userId);
            authNotifier.updateUser(updatedUser);
          } catch (e) {
            debugPrint('[SubmissionWatcher] failed to award points: $e');
          }
        }
      }
    }
  }
});
