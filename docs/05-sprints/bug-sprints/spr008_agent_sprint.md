# SPR-008 — Fix Critical & High Bugs

**Repo:** https://github.com/aryapras22/gamifyphotography
**Base branch:** `main`
**Working branch:** `fix/critical-high-bugs`

```bash
git checkout main && git pull origin main
git checkout -b fix/critical-high-bugs
```

Run `flutter analyze` after every task. Zero new warnings before moving on.
Do NOT modify: `main.dart`, any model file, any `.freezed.dart` / `.g.dart`.

---

## TASK 1 — BUG-01 + BUG-07: Unify submission status to a shared StreamProvider

### 1a. Create `lib/providers/submission_providers.dart` (new file)

```dart
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
```

### 1b. Edit `lib/views/mission/module_detail_view.dart`

- Remove the existing `submissionStatusProvider` definition at the top of the file (the one defined with `StreamProvider.autoDispose.family`).
- Add import: `import '../../providers/submission_providers.dart';`
- In the `error:` branch of `submissionAsync.when(...)` inside the `Consumer` widget, replace `const SizedBox.shrink()` with:

```dart
error: (e, st) {
  debugPrint('[SubmissionStatus] stream error for ${module.id}: $e');
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.coralRed.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.coralRed.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline_rounded,
            size: 18, color: AppColors.coralRed),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Cannot load submission status. Check your connection.',
            style: TextStyle(fontSize: 13, color: AppColors.coralRed),
          ),
        ),
      ],
    ),
  );
},
```

- In `_buildVisualGuidePage`, keep the null guard for `module == null` but change the return to redirect instead of showing static text (see Task 4).

### 1c. Edit `lib/views/mission/submission_status_view.dart`

Replace the entire `_SubmissionStatusViewState` class:

- Remove `initState` (delete the whole override).
- Remove `ref.watch(submissionViewModelProvider)` and any related import.
- Add import: `import '../../providers/submission_providers.dart';`
- Rewrite `build()`:

```dart
@override
Widget build(BuildContext context) {
  final submissionAsync = ref.watch(submissionStatusProvider(widget.moduleId));

  return Scaffold(
    backgroundColor: AppColors.backgroundGray,
    appBar: AppBar(
      backgroundColor: AppColors.surfaceWhite,
      elevation: 0,
      title: Text(widget.moduleTitle, style: AppTextStyles.heading),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.bodyText),
        onPressed: () => context.pop(),
      ),
    ),
    body: submissionAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandBlue),
      ),
      error: (e, st) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.coralRed),
            const SizedBox(height: 16),
            Text('Failed to load submission status.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.secondaryText)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  ref.invalidate(submissionStatusProvider(widget.moduleId)),
              child: Text('Retry',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.brandBlue)),
            ),
          ],
        ),
      ),
      data: (submission) =>
          submission == null ? _buildNoSubmission() : _buildStatusCard(submission),
    ),
  );
}
```

Also fix the status string bug in `_StatusBanner.build()` (same file):

```dart
// Change 'accepted' → 'approved' in two places:

// Place 1 — switch expression
'approved' => (          // was 'accepted'
    icon: Icons.check_circle_rounded,
    color: AppColors.forestGreen,
    label: 'FOTO DISETUJUI ✅',
    sub: 'Admin sudah menilai fotomu.',
  ),

// Place 2 — _ScoreCard visibility condition in _buildStatusCard()
if (status == 'approved' && submission.adminScore != null)   // was 'accepted'
  _ScoreCard(score: submission.adminScore!),
```

---

## TASK 2 — BUG-02 + BUG-04: Fix `PhotoSubmissionService`

Edit `lib/services/photo_submission_service.dart`. Full replacement of the class body:

```dart
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
}
```

> ⚠️ The `orderBy('submittedAt')` + `where` combination requires a Firestore composite index.
> If `flutter run` logs a `FAILED_PRECONDITION` error with a link, open that link in the browser to create the index automatically. The index fields are: `userId ASC`, `moduleId ASC`, `submittedAt DESC`.

---

## TASK 3 — BUG-03 + BUG-05: Atomic challenge completion

### 3a. Add `completeModuleAtomic` to `lib/services/auth_service.dart`

Add this method to the `AuthService` class (after `updateUserProgress`):

```dart
/// Atomically adds points and moduleId using a Firestore transaction.
/// Server-side guard prevents double-add even if called twice.
Future<void> completeModuleAtomic({
  required String userId,
  required String moduleId,
  required int pointsToAdd,
  required List<String> newPhotoUrls,
}) async {
  final ref = _db.collection('users').doc(userId);
  await _db.runTransaction((tx) async {
    final snap = await tx.get(ref);
    if (!snap.exists) return;
    final data = snap.data()!;
    final completedIds = List<String>.from(data['completedModuleIds'] ?? []);
    if (completedIds.contains(moduleId)) return; // idempotent
    completedIds.add(moduleId);
    final currentPoints = (data['points'] as int?) ?? 0;
    final newPoints = currentPoints + pointsToAdd;
    tx.update(ref, {
      'completedModuleIds': completedIds,
      'points': newPoints,
      'level': (newPoints ~/ 100) + 1,
      if (newPhotoUrls.isNotEmpty)
        'completedPhotoUrls': FieldValue.arrayUnion(newPhotoUrls),
    });
  });
}
```

### 3b. Rewrite `completeChallenge()` in `lib/view_models/challenge_view_model.dart`

Replace the entire `completeChallenge` method:

```dart
Future<void> completeChallenge() async {
  if (state.challenge == null) return;
  final user = _ref.read(authViewModelProvider).currentUser;
  if (user == null) return;
  if (user.completedModuleIds.contains(state.challenge!.moduleId)) return;
  if (state.challenge!.isCompleted) return;

  state = state.copyWith(isUploading: true, errorMessage: null);

  try {
    await _challengeService.completeChallenge(state.challenge!.id);

    final updatedChallenge = state.challenge!.copyWith(isCompleted: true);
    final points = updatedChallenge.pointReward;
    final photoUrl = state.challenge!.uploadedPhotoUrl;
    final newPhotoUrls =
        (photoUrl != null && photoUrl.isNotEmpty) ? [photoUrl] : <String>[];

    // Atomic Firestore transaction — prevents double point-add on retry
    await _ref.read(authServiceProvider).completeModuleAtomic(
          userId: user.id,
          moduleId: state.challenge!.moduleId,
          pointsToAdd: points,
          newPhotoUrls: newPhotoUrls,
        );

    // Build updated in-memory user to sync local state
    var updatedUser = user.copyWith(
      points: user.points + points,
      completedModuleIds: [...user.completedModuleIds, state.challenge!.moduleId],
      level: ((user.points + points) ~/ 100) + 1,
      completedPhotoUrls: [...user.completedPhotoUrls, ...newPhotoUrls],
    );

    // Badge check
    final badgeService = _ref.read(badgeServiceProvider);
    final streak = _ref.read(dailyLoginViewModelProvider).currentStreak;
    final newBadges = await badgeService.checkNewBadges(
      level: updatedUser.level,
      streak: streak,
      earnedBadgeIds: updatedUser.earnedBadgeIds,
      completedFirstMission: updatedUser.completedModuleIds.isNotEmpty,
    );
    if (newBadges.isNotEmpty) {
      updatedUser = updatedUser.copyWith(
        earnedBadgeIds: [
          ...updatedUser.earnedBadgeIds,
          ...newBadges.map((b) => b.id),
        ],
      );
      // Persist badge update separately (non-critical, no transaction needed)
      await _ref.read(authServiceProvider).updateUserProgress(updatedUser);
    }

    _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);
    _ref
        .read(missionViewModelProvider.notifier)
        .markModuleCompleted(state.challenge!.moduleId);

    state = state.copyWith(
      challenge: updatedChallenge,
      pointsEarned: points,
      isUploading: false,
    );
  } catch (e) {
    state = state.copyWith(
      isUploading: false,
      errorMessage: 'Failed to complete mission. Check your connection and try again.',
    );
    rethrow;
  }
}
```

Also update the `onPressed` caller in `lib/views/mission/challenge_view.dart` to handle the rethrow:

```dart
onPressed: hasPhoto && !state.isUploading
    ? () async {
        try {
          await ref
              .read(challengeViewModelProvider.notifier)
              .completeChallenge();
          if (mounted) context.push('/mission/feedback');
        } catch (_) {
          // errorMessage already set in ViewModel; SnackBar shown via ref.listen
        }
      }
    : () {},
```

---

## TASK 4 — BUG-08: Null guard redirects in detail & challenge views

### In `lib/views/mission/module_detail_view.dart`

```dart
// Replace
if (module == null) {
  return const Scaffold(body: Center(child: Text('No module selected')));
}

// With
if (module == null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) context.go('/home');
  });
  return const Scaffold(
    body: Center(child: CircularProgressIndicator(color: AppColors.brandBlue)),
  );
}
```

### In `lib/views/mission/challenge_view.dart`

```dart
// Replace
if (challenge == null) {
  return const Scaffold(
    body: Center(child: Text('No challenge available')),
  );
}

// With
if (challenge == null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) context.go('/home');
  });
  return const Scaffold(
    body: Center(child: CircularProgressIndicator(color: AppColors.brandBlue)),
  );
}
```

---

## Files Changed

| File | Action |
|---|---|
| `lib/providers/submission_providers.dart` | CREATE |
| `lib/views/mission/module_detail_view.dart` | MODIFY |
| `lib/views/mission/submission_status_view.dart` | MODIFY |
| `lib/services/photo_submission_service.dart` | MODIFY |
| `lib/services/auth_service.dart` | MODIFY |
| `lib/view_models/challenge_view_model.dart` | MODIFY |
| `lib/views/mission/challenge_view.dart` | MODIFY |

---

## PR

**Title:** `fix(SPR-008): submission flow, atomic points, null guards`
**Base:** `main`
**Body:** list the 8 bugs fixed with one sentence each.
