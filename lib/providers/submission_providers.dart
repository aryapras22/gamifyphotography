import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo_submission_model.dart';
import '../view_models/auth_view_model.dart';
import 'service_providers.dart';

/// Single source of truth for a user's submission status on one module.
/// Uses .select() so it only restarts on userId change, not on every user update.
final submissionStatusProvider =
    StreamProvider.autoDispose.family<PhotoSubmissionModel?, String>(
  (ref, moduleId) {
    final userId = ref.watch(
      authViewModelProvider.select((s) => s.currentUser?.id),
    );
    if (userId == null) return Stream.value(null);
    final service = ref.read(photoSubmissionServiceProvider);
    return service.watchUserSubmission(userId, moduleId);
  },
);

/// Real-time stream of all submissions for the current user (for profile history).
/// Uses .select() so it only restarts on userId change, not on points/level updates.
final submissionHistoryProvider =
    StreamProvider.autoDispose<List<PhotoSubmissionModel>>((ref) {
  final userId = ref.watch(
    authViewModelProvider.select((s) => s.currentUser?.id),
  );
  if (userId == null) return Stream.value([]);
  final service = ref.read(photoSubmissionServiceProvider);
  return service.watchAllUserSubmissions(userId);
});

/// Watches all user submissions and awards points when admin approves.
/// Uses ref.read for auth calls inside the loop to prevent restart cycles.
/// This provider must be watched somewhere that stays alive (e.g., MainLayoutView).
final submissionApprovalWatcherProvider =
    StreamProvider.autoDispose<void>((ref) async* {
  // Only watch userId — restarts only on login/logout, not on every user update
  final userId = ref.watch(
    authViewModelProvider.select((s) => s.currentUser?.id),
  );
  if (userId == null) return;

  // Use ref.read to avoid restarting this provider when service instances change
  final service = ref.read(photoSubmissionServiceProvider);
  final authService = ref.read(authServiceProvider);
  final authNotifier = ref.read(authViewModelProvider.notifier);

  await for (final submissions in service.watchAllUserSubmissions(userId)) {
    for (final submission in submissions) {
      if (submission.status == 'approved' && submission.adminScore != null) {
        // Re-read current user inside loop to get fresh completedModuleIds
        final currentUser = ref.read(authViewModelProvider).currentUser;
        if (currentUser == null) continue;
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
