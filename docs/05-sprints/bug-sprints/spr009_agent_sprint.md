# SPR-009 — Points from Admin, No Resubmit While Pending, Submission History on Profile

**Repo:** https://github.com/aryapras22/gamifyphotography
**Base branch:** `fix/critical-high-bugs`
**Working branch:** `fix/submission-review-flow`

```bash
git checkout fix/critical-high-bugs && git pull origin fix/critical-high-bugs
git checkout -b fix/submission-review-flow
```

Run `flutter analyze` after every task. Zero new warnings before moving on.
Do NOT modify: `main.dart`, any `.freezed.dart` / `.g.dart`, any model file.

---

## Context: What the current branch already does correctly

- `photo_submission_service.dart` already guards `['pending', 'approved']` — no new doc if one exists ✅
- `submission_status_view.dart` already uses `submissionStatusProvider` (real-time stream) ✅
- `submission_status_view.dart` already has `'approved'` string (not `'accepted'`) ✅
- `_ScoreCard` already shown when `status == 'approved' && adminScore != null` ✅

---

## What this sprint adds / changes

| # | Change | Files |
|---|---|---|
| 1 | Remove `completeChallenge()` — points are given by admin, not on submit | `challenge_view_model.dart`, `challenge_view.dart`, `feedback_view.dart` |
| 2 | Block camera / re-upload when submission is `pending` | `challenge_view.dart`, `submission_providers.dart` |
| 3 | Add submission history section to Profile | `profile_view.dart`, `photo_submission_service.dart`, `profile_view_model.dart` |
| 4 | Award points to user when admin approves (Firestore trigger approach via service) | `photo_submission_service.dart`, `auth_service.dart` |

---

## TASK 1 — Remove `completeChallenge()` entirely. Points come from admin only.

### Problem
Currently when user taps "CEK HASIL", `completeChallenge()` is called which:
- marks module as completed in Firestore
- adds `pointReward` from the challenge model to user.points immediately
- navigates to feedback_view showing points earned

This is wrong. Points should only be awarded when admin approves the submission.

### 1a. Edit `lib/view_models/challenge_view_model.dart`

Delete the entire `completeChallenge()` method.

Remove unused imports if any become unused:
- Keep all existing imports — `daily_login_view_model.dart` and badge-related imports may become unused, remove them if so after deletion.

`ChallengeState` stays as-is except: `pointsEarned` field is no longer set by this ViewModel. Keep the field in the state class — it may be used by feedback view — but it will always be 0 from this point.

### 1b. Edit `lib/views/mission/challenge_view.dart`

Find the `onPressed` of the "CEK HASIL" `Animated3DButton`. Currently it calls `completeChallenge()` then pushes `/mission/feedback`.

Replace the entire `onPressed` block with a simple navigation:

```dart
onPressed: hasPhoto && !state.isUploading
    ? () {
        if (mounted) context.push('/mission/feedback');
      }
    : () {},
```

No `await`, no `completeChallenge()`, no try/catch needed.

### 1c. Edit `lib/views/mission/feedback_view.dart`

The feedback view currently shows a rolling points counter (`TweenAnimationBuilder` for `state.pointsEarned`).

Since `pointsEarned` will always be 0 now, replace the points section:

Find this block:
```dart
if (state.pointsEarned > 0)
  TweenAnimationBuilder<int>(...)  // rolling counter
else
  Text('Misi Selesai!', ...)
```

Replace with a single static "pending review" card:

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  decoration: BoxDecoration(
    color: AppColors.lensGold.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.lensGold, width: 2),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.hourglass_top_rounded, color: AppColors.lensGold, size: 28),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto terkirim!',
              style: AppTextStyles.title.copyWith(color: AppColors.lensGold),
            ),
            const SizedBox(height: 4),
            Text(
              'Poin akan diberikan setelah admin menilai fotomu.',
              style: AppTextStyles.body.copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    ],
  ),
),
```

Also remove the import for `challenge_view_model.dart` from `feedback_view.dart` IF it is only used for `state.pointsEarned` and `state.challenge`. Check: if `challengeTitle` and `photoUrl` are still read from `challengeViewModelProvider`, keep the import and only remove the `pointsEarned` reference.

---

## TASK 2 — Block camera / resubmit when submission status is `pending`

### Problem
User should not be able to open the camera or re-upload a photo if they already have a `pending` submission for that module. They can only resubmit after admin reviews (approved or rejected).

The challenge view currently checks `hasPhoto` (local in-memory) but not the Firestore submission status.

### 2a. Edit `lib/views/mission/challenge_view.dart`

The `challenge_view.dart` needs to know the current Firestore submission status for this module.

At the top of `_ChallengeViewState.build()`, after getting `challenge`, add a watch for the submission stream:

```dart
// Add this import at the top of the file:
// import '../../providers/submission_providers.dart';

final submissionAsync = ref.watch(
  submissionStatusProvider(challenge.moduleId),
);
final submissionStatus = submissionAsync.valueOrNull?.status; // null, 'pending', 'approved', 'rejected'
final isPending = submissionStatus == 'pending';
```

Then update the camera tap zone (the `GestureDetector` wrapping "AMBIL FOTO") to block interaction when `isPending`:

```dart
// Replace the GestureDetector wrapping the camera placeholder:
GestureDetector(
  onTap: isPending
      ? null   // disabled — do nothing
      : () async {
          // existing camera logic unchanged
          final XFile? xfile = await Navigator.of(context).push(...);
          if (xfile != null) {
            ...
            await ref.read(challengeViewModelProvider.notifier).uploadPhoto(...);
          }
        },
  child: Container(
    // existing decoration unchanged
    child: isPending
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top_rounded,
                  size: 64, color: AppColors.lensGold),
              const SizedBox(height: 16),
              Text(
                'MENUNGGU PENILAIAN',
                style: TextStyle(
                  color: AppColors.lensGold,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fotomu sedang ditinjau admin.',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_rounded, size: 80, color: AppColors.brandBlue),
              const SizedBox(height: 16),
              Text(
                'AMBIL FOTO',
                style: TextStyle(
                  color: AppColors.brandBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
  ),
),
```

Also update `hasPhoto` logic: if `isPending`, the "CEK HASIL" button should be replaced with a "LIHAT STATUS" button that navigates to `SubmissionStatusView`:

```dart
// After the photo/camera area and before SizedBox(height: 40):
// Replace the Animated3DButton at the bottom:

if (isPending)
  Animated3DButton(
    color: AppColors.lensGold,
    shadowColor: const Color(0xFFB8860B),
    onPressed: () {
      final moduleTitle = ref.read(missionViewModelProvider).activeModule?.title ?? challenge.moduleId;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubmissionStatusView(
            moduleId: challenge.moduleId,
            moduleTitle: moduleTitle,
          ),
        ),
      );
    },
    child: const Text(
      'LIHAT STATUS FOTO →',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 1.0,
      ),
    ),
  )
else
  Animated3DButton(
    color: hasPhoto ? AppColors.forestGreen : AppColors.cardBorder,
    shadowColor: hasPhoto
        ? const Color(0xFF2D8A00)
        : const Color(0xFFC4C4C4),
    onPressed: hasPhoto && !state.isUploading
        ? () {
            if (mounted) context.push('/mission/feedback');
          }
        : () {},
    child: state.isUploading
        ? const CircularProgressIndicator(color: Colors.white)
        : Text(
            'CEK HASIL',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: hasPhoto ? Colors.white : AppColors.disabled,
              letterSpacing: 1.2,
            ),
          ),
  ),
```

Add import at top of `challenge_view.dart`:
```dart
import '../../providers/submission_providers.dart';
import '../mission/submission_status_view.dart';
```

---

## TASK 3 — Add submission history to Profile

### Problem
The profile currently shows `_PhotoSection` which only shows photo URLs from `user.completedPhotoUrls`. There is no section showing submission history with status and admin score.

### 3a. Add `watchAllUserSubmissions` to `lib/services/photo_submission_service.dart`

Add this method to the `PhotoSubmissionService` class:

```dart
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
```

> ⚠️ This query uses `orderBy('submittedAt')` with `where('userId')`. A Firestore composite index is required: `userId ASC`, `submittedAt DESC`. Create it in the Firebase console if a `FAILED_PRECONDITION` error appears.

### 3b. Add `submissionHistoryProvider` to `lib/providers/submission_providers.dart`

Add a new provider at the bottom of the existing file:

```dart
/// Real-time stream of all submissions for the current user (for profile history).
final submissionHistoryProvider =
    StreamProvider.autoDispose<List<PhotoSubmissionModel>>((ref) {
  final userId = ref.watch(authViewModelProvider).currentUser?.id;
  if (userId == null) return Stream.value([]);
  final service = ref.watch(photoSubmissionServiceProvider);
  return service.watchAllUserSubmissions(userId);
});
```

Add the import for `PhotoSubmissionModel` at the top of `submission_providers.dart` if not already present.

### 3c. Edit `lib/views/profile/profile_view.dart`

Add a new `_SubmissionHistorySection` widget and wire it into the profile scroll view.

**Step 1:** Add import at top:
```dart
import '../../models/photo_submission_model.dart';
import '../../providers/submission_providers.dart';
import '../mission/submission_status_view.dart';
```

**Step 2:** In `_ProfileTabState.build()`, inside the `SliverChildListDelegate` list, add after `_PhotoSection(...)`:

```dart
const SizedBox(height: 24),
_SubmissionHistorySection(),
```

**Step 3:** Add the new widget class at the bottom of `profile_view.dart`:

```dart
class _SubmissionHistorySection extends ConsumerWidget {
  const _SubmissionHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(submissionHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_rounded, size: 20, color: AppColors.brandBlue),
            const SizedBox(width: 8),
            Text(
              'RIWAYAT SUBMISSION',
              style: AppTextStyles.title.copyWith(fontSize: 15, letterSpacing: 1.2),
            ),
          ],
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.brandBlue),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (submissions) {
            if (submissions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                ),
                child: Center(
                  child: Text(
                    'Belum ada submission.',
                    style: AppTextStyles.body.copyWith(color: AppColors.disabled),
                  ),
                ),
              );
            }
            return Column(
              children: submissions
                  .map((s) => _SubmissionHistoryItem(
                        submission: s,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubmissionStatusView(
                              moduleId: s.moduleId,
                              moduleTitle: s.moduleTitle,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SubmissionHistoryItem extends StatelessWidget {
  final PhotoSubmissionModel submission;
  final VoidCallback onTap;

  const _SubmissionHistoryItem({
    required this.submission,
    required this.onTap,
  });

  Color get _statusColor {
    switch (submission.status) {
      case 'approved':
        return AppColors.forestGreen;
      case 'rejected':
        return AppColors.coralRed;
      default:
        return AppColors.lensGold;
    }
  }

  IconData get _statusIcon {
    switch (submission.status) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  String get _statusLabel {
    switch (submission.status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                submission.photoUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.backgroundGray,
                  child: const Icon(Icons.image_not_supported_rounded,
                      color: AppColors.disabled, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    submission.moduleTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.bodyText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                      if (submission.status == 'approved' &&
                          submission.adminScore != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${submission.adminScore} / 100',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(submission.submittedAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.disabled, size: 20),
          ],
        ),
      ),
    );
  }
}
```

---

## TASK 4 — Award points when admin approves (admin-side trigger)

### Problem
Currently `completeChallenge()` gave points immediately on submit. After removing it in Task 1, points are never awarded. Points must be awarded when admin sets status to `'approved'`.

Since this app uses Firestore directly (no Cloud Functions), the award must happen client-side when the submission stream emits `status == 'approved'` for the first time with `adminScore != null`.

### 4a. Add `awardPointsForApprovedSubmission` to `lib/services/auth_service.dart`

Add this method after `completeModuleAtomic`:

```dart
/// Called when admin approves a submission. Awards adminScore points atomically.
/// Idempotent: safe to call multiple times — only awards if module not already in completedModuleIds.
Future<void> awardPointsForApprovedSubmission({
  required String userId,
  required String moduleId,
  required int adminScore,
  required String photoUrl,
}) async {
  final ref = _db.collection('users').doc(userId);
  await _db.runTransaction((tx) async {
    final snap = await tx.get(ref);
    if (!snap.exists) return;
    final data = snap.data()!;
    final completedIds = List<String>.from(data['completedModuleIds'] ?? []);
    if (completedIds.contains(moduleId)) return; // already awarded
    completedIds.add(moduleId);
    final currentPoints = (data['points'] as int?) ?? 0;
    final newPoints = currentPoints + adminScore;
    tx.update(ref, {
      'completedModuleIds': completedIds,
      'points': newPoints,
      'level': (newPoints ~/ 100) + 1,
      if (photoUrl.isNotEmpty)
        'completedPhotoUrls': FieldValue.arrayUnion([photoUrl]),
    });
  });
}
```

### 4b. Add a listener in `lib/providers/submission_providers.dart`

Add a new provider that watches ALL user submissions and triggers point award when a new approval is detected. Add at the bottom of the file:

```dart
/// Watches all user submissions and awards points when admin approves.
/// This provider must be watched somewhere that stays alive (e.g., MainLayoutView or ProfileTab).
final submissionApprovalWatcherProvider = StreamProvider.autoDispose<void>((ref) async* {
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
```

### 4c. Watch `submissionApprovalWatcherProvider` in `lib/views/home/main_layout_view.dart`

Find the main layout view (the widget that wraps the bottom navigation and stays alive across tabs). Add the watcher in its `build()` method:

```dart
// Add inside build(), early — just to keep the provider alive:
ref.watch(submissionApprovalWatcherProvider);
```

Add import at top:
```dart
import '../../providers/submission_providers.dart';
```

---

## Files Changed

| File | Action |
|---|---|
| `lib/view_models/challenge_view_model.dart` | MODIFY — remove `completeChallenge()` |
| `lib/views/mission/challenge_view.dart` | MODIFY — remove completeChallenge call, add pending block, add LIHAT STATUS button |
| `lib/views/mission/feedback_view.dart` | MODIFY — replace points counter with "pending review" card |
| `lib/services/photo_submission_service.dart` | MODIFY — add `watchAllUserSubmissions()` |
| `lib/services/auth_service.dart` | MODIFY — add `awardPointsForApprovedSubmission()` |
| `lib/providers/submission_providers.dart` | MODIFY — add `submissionHistoryProvider`, `submissionApprovalWatcherProvider` |
| `lib/views/profile/profile_view.dart` | MODIFY — add `_SubmissionHistorySection` |
| `lib/views/home/main_layout_view.dart` | MODIFY — watch `submissionApprovalWatcherProvider` |

**Do NOT modify:** `main.dart`, any model, any `.freezed.dart` / `.g.dart`, `app_colors.dart`.

---

## PR

**Title:** `feat(SPR-009): admin-awarded points, pending lock, submission history on profile`
**Base:** `fix/critical-high-bugs`
**Body:**
- Points are now awarded only when admin sets status to `approved`, using an atomic Firestore transaction.
- Users cannot open camera or re-upload while submission is `pending`; they see "MENUNGGU PENILAIAN" with a link to status view instead.
- Profile now shows full submission history with status badge, admin score, and tap-to-detail.
- `completeChallenge()` method removed entirely from `ChallengeViewModel`.
