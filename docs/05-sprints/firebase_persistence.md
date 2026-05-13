# Sprint: Firebase Persistence — P0 & P1
**Branch:** `feature/firebase-persistence` (branch from `main`)
**Repo:** https://github.com/aryapras22/gamifyphotography

---

## CONTEXT

Firebase Auth has been merged to `main` and is working. Users can register and log in.
However, ALL game data (points, badges, streak, module progress, leaderboard, photo upload)
is still mock or in-memory. Every app restart wipes all user progress.

This sprint connects every data layer to Firebase Firestore and Firebase Storage.

---

## SETUP — Create Branch First

```bash
git checkout main && git pull origin main
git checkout -b feature/firebase-persistence
```

---

## STRICT RULES — NEVER VIOLATE

1. Every write to user progress (points, level, badges, completedPhotoUrls, bridgeProgress,
   completedModuleIds) MUST be persisted to Firestore `/users/{uid}` immediately after
   in-memory state update.
2. `ChallengeService.uploadPhoto()` MUST upload to Firebase Storage. Never return a local path.
3. `DailyLoginService` MUST read and write streak data from/to Firestore `/users/{uid}`.
4. `MissionViewModel.fetchModules()` MUST restore completed state from Firestore user data.
5. `LeaderboardViewModel` MUST query real data from Firestore `/users` collection.
6. Never hardcode user IDs, mock data, or in-memory stores in any service after this sprint.
7. `completeChallenge()` must be idempotent — guard using Firestore data (`completedModuleIds`),
   not local state only.
8. All Firestore writes for user progress use `.update()`, not `.set()`.
9. Do NOT touch: `AppColors`, `AppTextStyles`, any view UI layout files.
10. `flutter analyze` must pass with zero new errors after all changes.

---

## FIRESTORE SCHEMA (reference — do not change existing structure)

```
/users/{uid}
  points: number
  level: number
  bridgeProgress: number
  earnedBadgeIds: string[]
  completedPhotoUrls: string[]
  completedModuleIds: string[]     ← ADD THIS FIELD (new)
  streakCount: number              ← ADD THIS FIELD (new)
  lastLoginDate: timestamp         ← ADD THIS FIELD (new)
  weekHistory: boolean[7]          ← ADD THIS FIELD (new)

/photo_submissions/{id}
  userId, userName, moduleId, moduleTitle,
  photoUrl, status, adminNote, submittedAt, reviewedAt
  (already exists — do not change schema)
```

---

## TASK 1 — Extend UserModel with Persistence Fields

**File:** `lib/models/user_model.dart`

Add these fields to the existing Freezed model:

```dart
@Default([]) List<String> completedModuleIds,
@Default(0) int streakCount,
DateTime? lastLoginDate,
@Default([false, false, false, false, false, false, false]) List<bool> weekHistory,
```

After editing, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Ensure all existing code that constructs `UserModel` still compiles — all new fields have defaults.

---

## TASK 2 — Add `updateUserProgress()` and Update `fetchUser()` in AuthService

**File:** `lib/services/auth_service.dart`

Add this method to the existing `AuthService` class:

```dart
/// Persists mutable game progress fields to Firestore.
/// Only updates the listed fields — never overwrites role, name, or email.
Future<void> updateUserProgress(UserModel user) async {
  await _db.collection('users').doc(user.id).update({
    'points': user.points,
    'level': user.level,
    'bridgeProgress': user.bridgeProgress,
    'earnedBadgeIds': user.earnedBadgeIds,
    'completedPhotoUrls': user.completedPhotoUrls,
    'completedModuleIds': user.completedModuleIds,
    'streakCount': user.streakCount,
    'lastLoginDate': user.lastLoginDate != null
        ? Timestamp.fromDate(user.lastLoginDate!)
        : null,
    'weekHistory': user.weekHistory,
  });
}
```

Also update `fetchUser()` to parse all new fields with fallback defaults for existing users:

```dart
Future<UserModel> fetchUser(String uid) async {
  final doc = await _db.collection('users').doc(uid).get();
  if (!doc.exists) throw Exception('User data not found.');
  final data = doc.data()!;

  DateTime? lastLoginDate;
  if (data['lastLoginDate'] is Timestamp) {
    lastLoginDate = (data['lastLoginDate'] as Timestamp).toDate();
  }

  return UserModel(
    id: uid,
    name: data['name'] ?? '',
    email: data['email'] ?? '',
    role: data['role'] ?? 'user',
    points: data['points'] ?? 0,
    level: data['level'] ?? 1,
    bridgeProgress: data['bridgeProgress'] ?? 0,
    earnedBadgeIds: List<String>.from(data['earnedBadgeIds'] ?? []),
    completedPhotoUrls: List<String>.from(data['completedPhotoUrls'] ?? []),
    completedModuleIds: List<String>.from(data['completedModuleIds'] ?? []),
    streakCount: data['streakCount'] ?? 0,
    lastLoginDate: lastLoginDate,
    weekHistory: data['weekHistory'] != null
        ? List<bool>.from(data['weekHistory'])
        : List.filled(7, false),
    createdAt: data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : null,
  );
}
```

---

## TASK 3 — Replace ChallengeService.uploadPhoto() with Firebase Storage

**File:** `lib/services/challenge_service.dart`

Keep all other methods (`getChallenge`, `completeChallenge`, `_getInstruction`) exactly as-is.

Add imports:
```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
```

Replace `uploadPhoto()` entirely:

```dart
Future<String> uploadPhoto(XFile file) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) throw Exception('User not authenticated.');

  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final ref = FirebaseStorage.instance
      .ref()
      .child('challenge_photos')
      .child(uid)
      .child(fileName);

  final uploadTask = await ref.putFile(
    File(file.path),
    SettableMetadata(contentType: 'image/jpeg'),
  );

  return await uploadTask.ref.getDownloadURL();
}
```

---

## TASK 4 — Update ChallengeViewModel

**File:** `lib/view_models/challenge_view_model.dart`

### 4a — Add errorMessage to ChallengeState

```dart
class ChallengeState {
  final ChallengeModel? challenge;
  final bool isUploading;
  final int pointsEarned;
  final String? errorMessage;

  ChallengeState({
    this.challenge,
    this.isUploading = false,
    this.pointsEarned = 0,
    this.errorMessage,
  });

  ChallengeState copyWith({
    ChallengeModel? challenge,
    bool? isUploading,
    int? pointsEarned,
    String? errorMessage,
  }) {
    return ChallengeState(
      challenge: challenge ?? this.challenge,
      isUploading: isUploading ?? this.isUploading,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      errorMessage: errorMessage,
    );
  }
}
```

### 4b — Inject PhotoSubmissionService

```dart
final challengeViewModelProvider =
    StateNotifierProvider<ChallengeViewModel, ChallengeState>(
      (ref) => ChallengeViewModel(
        ref,
        ref.read(challengeServiceProvider),
        ref.read(photoSubmissionServiceProvider),
      ),
    );

class ChallengeViewModel extends StateNotifier<ChallengeState> {
  final Ref _ref;
  final ChallengeService _challengeService;
  final PhotoSubmissionService _submissionService;

  ChallengeViewModel(this._ref, this._challengeService, this._submissionService)
      : super(ChallengeState());
```

### 4c — Update uploadPhoto() to use real Storage + create submission doc

```dart
Future<void> uploadPhoto(XFile file, {required String moduleTitle}) async {
  state = state.copyWith(isUploading: true, errorMessage: null);
  try {
    final url = await _challengeService.uploadPhoto(file);
    final updatedChallenge = state.challenge!.copyWith(uploadedPhotoUrl: url);

    final user = _ref.read(authViewModelProvider).currentUser;
    if (user != null && state.challenge != null) {
      await _submissionService.submitPhoto(
        userId: user.id,
        userName: user.name,
        moduleId: state.challenge!.moduleId,
        moduleTitle: moduleTitle,
        photoUrl: url,
      );
    }

    state = state.copyWith(challenge: updatedChallenge, isUploading: false);
  } catch (e) {
    state = state.copyWith(
      isUploading: false,
      errorMessage: 'Upload failed. Please try again.',
    );
  }
}
```

### 4d — Update completeChallenge() to persist to Firestore

```dart
Future<void> completeChallenge() async {
  if (state.challenge == null) return;

  final user = _ref.read(authViewModelProvider).currentUser;
  if (user == null) return;

  // Idempotent guard using Firestore data
  if (user.completedModuleIds.contains(state.challenge!.moduleId)) return;
  if (state.challenge!.isCompleted) return;

  await _challengeService.completeChallenge(state.challenge!.id);
  final updatedChallenge = state.challenge!.copyWith(isCompleted: true);
  final points = updatedChallenge.pointReward;

  var updatedUser = user.copyWith(
    points: user.points + points,
    completedModuleIds: [...user.completedModuleIds, state.challenge!.moduleId],
    level: ((user.points + points) ~/ 100) + 1,
  );

  final photoUrl = state.challenge!.uploadedPhotoUrl;
  if (photoUrl != null && photoUrl.isNotEmpty) {
    updatedUser = updatedUser.copyWith(
      completedPhotoUrls: [...updatedUser.completedPhotoUrls, photoUrl],
    );
  }

  // Check badges
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
  }

  // CRITICAL: Persist to Firestore before updating in-memory state
  await _ref.read(authServiceProvider).updateUserProgress(updatedUser);

  _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);
  _ref.read(missionViewModelProvider.notifier).markModuleCompleted(state.challenge!.moduleId);

  state = state.copyWith(challenge: updatedChallenge, pointsEarned: points);
}
```

---

## TASK 5 — Replace DailyLoginService with Firestore-backed Implementation

**File:** `lib/services/daily_login_service.dart`

Replace the entire file. Public method signatures must stay identical so `DailyLoginViewModel`
compiles without change (except for TASK 8 additions):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

const int kDailyLoginPoints = 50;
const int kMaxStreakDays = 7;

class DailyLoginService {
  final _db = FirebaseFirestore.instance;

  DocumentReference _userRef(String userId) =>
      _db.collection('users').doc(userId);

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime? date) {
    if (date == null) return false;
    final y = DateTime.now().subtract(const Duration(days: 1));
    return date.year == y.year && date.month == y.month && date.day == y.day;
  }

  Future<Map<String, dynamic>> _fetchFields(String userId) async {
    final doc = await _userRef(userId).get() as DocumentSnapshot<Map<String, dynamic>>;
    return doc.data() ?? {};
  }

  Future<bool> hasClaimedToday(String userId) async {
    final data = await _fetchFields(userId);
    final ts = data['lastLoginDate'];
    if (ts == null) return false;
    return _isToday((ts as Timestamp).toDate());
  }

  Future<int> getCurrentStreak(String userId) async {
    final data = await _fetchFields(userId);
    final ts = data['lastLoginDate'];
    int streak = data['streakCount'] ?? 0;
    if (ts == null) return 0;
    final last = (ts as Timestamp).toDate();
    if (!_isToday(last) && !_isYesterday(last)) {
      streak = 0;
      await _userRef(userId).update({'streakCount': 0});
    }
    return streak;
  }

  Future<int> claimDailyLogin(String userId) async {
    final data = await _fetchFields(userId);
    final ts = data['lastLoginDate'];
    int streak = data['streakCount'] ?? 0;
    List<bool> history = data['weekHistory'] != null
        ? List<bool>.from(data['weekHistory'])
        : List.filled(kMaxStreakDays, false);

    if (ts != null && _isToday((ts as Timestamp).toDate())) {
      throw Exception('Already claimed today.');
    }

    if (ts != null && !_isYesterday((ts as Timestamp).toDate())) {
      streak = 0;
      history = List.filled(kMaxStreakDays, false);
    }

    if (streak >= kMaxStreakDays) {
      streak = 1;
      history = List.filled(kMaxStreakDays, false);
    } else {
      streak += 1;
    }

    history[streak - 1] = true;

    await _userRef(userId).update({
      'streakCount': streak,
      'lastLoginDate': Timestamp.fromDate(DateTime.now()),
      'weekHistory': history,
    });

    return kDailyLoginPoints;
  }

  Future<List<bool>> getWeekHistory(String userId) async {
    final data = await _fetchFields(userId);
    if (data['weekHistory'] == null) return List.filled(kMaxStreakDays, false);
    return List<bool>.from(data['weekHistory']);
  }
}
```

---

## TASK 6 — Persist Module Completion in MissionViewModel

**File:** `lib/view_models/mission_view_model.dart`

Add `Ref` to the constructor and restore completion state from Firestore user data on `fetchModules()`:

```dart
final missionViewModelProvider =
    StateNotifierProvider<MissionViewModel, MissionState>(
      (ref) => MissionViewModel(ref, ref.read(moduleServiceProvider)),
    );

class MissionViewModel extends StateNotifier<MissionState> {
  final Ref _ref;
  final ModuleService _moduleService;

  MissionViewModel(this._ref, this._moduleService) : super(MissionState());

  Future<void> fetchModules() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final modules = await _moduleService.getModules();

      // Restore completion state from persistent Firestore user data
      final user = _ref.read(authViewModelProvider).currentUser;
      final completedIds = user?.completedModuleIds ?? [];

      final restoredModules = modules.map((m) {
        if (completedIds.contains(m.id)) return m.copyWith(isCompleted: true);
        return m;
      }).toList();

      state = state.copyWith(isLoading: false, modules: restoredModules);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // selectModule() and markModuleCompleted() stay exactly as-is
}
```

---

## TASK 7 — Replace LeaderboardViewModel with Real Firestore Query

**File:** `lib/view_models/leaderboard_view_model.dart`

Replace the entire file:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';

class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final int currentUserRank;
  final String? errorMessage;

  const LeaderboardState({
    this.entries = const [],
    this.isLoading = true,
    this.currentUserRank = 0,
    this.errorMessage,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? entries,
    bool? isLoading,
    int? currentUserRank,
    String? errorMessage,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      currentUserRank: currentUserRank ?? this.currentUserRank,
      errorMessage: errorMessage,
    );
  }
}

final leaderboardViewModelProvider =
    StateNotifierProvider<LeaderboardViewModel, LeaderboardState>((ref) {
  return LeaderboardViewModel();
});

class LeaderboardViewModel extends StateNotifier<LeaderboardState> {
  final _db = FirebaseFirestore.instance;

  LeaderboardViewModel() : super(const LeaderboardState());

  Future<void> loadLeaderboard(String currentUserId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'user')
          .orderBy('points', descending: true)
          .limit(50)
          .get();

      final raw = snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardEntry(
          userId: doc.id,
          userName: data['name'] ?? 'Unknown',
          points: data['points'] ?? 0,
          rank: 0,
        );
      }).toList();

      final ranked = <LeaderboardEntry>[];
      for (var i = 0; i < raw.length; i++) {
        ranked.add(LeaderboardEntry(
          userId: raw[i].userId,
          userName: raw[i].userId == currentUserId
              ? '${raw[i].userName} (You)'
              : raw[i].userName,
          points: raw[i].points,
          rank: i + 1,
        ));
      }

      final currentEntry = ranked.firstWhere(
        (e) => e.userId == currentUserId,
        orElse: () => LeaderboardEntry(
          userId: currentUserId,
          userName: 'You',
          points: 0,
          rank: ranked.length + 1,
        ),
      );

      state = state.copyWith(
        isLoading: false,
        entries: ranked,
        currentUserRank: currentEntry.rank,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load leaderboard.',
      );
    }
  }
}
```

Also create `firestore.indexes.json` at the project root (needed for the `role + points` query):

```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "role", "order": "ASCENDING" },
        { "fieldPath": "points", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

> Deploy the index manually from Firebase Console → Firestore → Indexes → Add Composite Index,
> OR run: `firebase deploy --only firestore:indexes`

---

## TASK 8 — Update DailyLoginViewModel to Pass UserId and Persist Points

**File:** `lib/view_models/daily_login_view_model.dart`

All calls to `DailyLoginService` now require a real `userId`. Apply this pattern everywhere:

```dart
final userId = _ref.read(authViewModelProvider).currentUser?.id ?? '';
if (userId.isEmpty) return;
```

After a successful `claimDailyLogin()`, persist the updated points and streak to Firestore:

```dart
// After claimDailyLogin returns newStreak
final user = _ref.read(authViewModelProvider).currentUser;
if (user != null) {
  final updatedUser = user.copyWith(
    points: user.points + kDailyLoginPoints,
    level: ((user.points + kDailyLoginPoints) ~/ 100) + 1,
    streakCount: newStreak,
    lastLoginDate: DateTime.now(),
  );
  await _ref.read(authServiceProvider).updateUserProgress(updatedUser);
  _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);
}
```

---

## TASK 9 — Verify service_providers.dart

**File:** `lib/providers/service_providers.dart`

Ensure all of the following providers are registered. Add any that are missing:

```dart
import '../services/auth_service.dart';
import '../services/photo_submission_service.dart';

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService());

final photoSubmissionServiceProvider =
    Provider<PhotoSubmissionService>((ref) => PhotoSubmissionService());
```

---

## TASK 10 — Update Firestore Security Rules

In Firebase Console → Firestore → Rules, replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() { return request.auth != null; }
    function isOwner(uid) { return request.auth.uid == uid; }
    function isAdmin() {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    match /users/{uid} {
      allow read: if isOwner(uid) || isAdmin();
      allow create: if isAuthenticated() && isOwner(uid)
        && request.resource.data.role == 'user';
      allow update: if isOwner(uid)
        && !request.resource.data.diff(resource.data)
            .affectedKeys().hasAny(['role', 'email']);
      allow delete: if false;
    }

    match /photo_submissions/{id} {
      allow read: if isAuthenticated()
        && (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isAuthenticated()
        && request.resource.data.userId == request.auth.uid
        && request.resource.data.status == 'pending';
      allow update: if isAdmin()
        && request.resource.data.diff(resource.data)
            .affectedKeys().hasOnly(['status', 'adminNote', 'reviewedAt']);
      allow delete: if false;
    }
  }
}
```

---

## DEFINITION OF DONE

Sprint is complete only when ALL items below are checked.

### P0 — Must Pass

- [ ] `UserModel` has `completedModuleIds`, `streakCount`, `lastLoginDate`, `weekHistory` — build_runner completed successfully
- [ ] `AuthService.updateUserProgress()` exists and updates Firestore without overwriting role/email
- [ ] `AuthService.fetchUser()` parses all new fields with fallback defaults for existing users
- [ ] `ChallengeService.uploadPhoto()` uploads to Firebase Storage and returns a download URL (never a local path)
- [ ] After `completeChallenge()`: points, level, completedModuleIds, completedPhotoUrls written to Firestore `/users/{uid}`
- [ ] `completeChallenge()` is idempotent: completing the same module twice gives zero extra points (verified in Firestore)
- [ ] Upload failure sets `errorMessage` in `ChallengeState` — no more silent errors
- [ ] `DailyLoginService` reads and writes streakCount, lastLoginDate, weekHistory from/to Firestore
- [ ] After app restart: streak count and week history are restored from Firestore (not reset to 0)
- [ ] After claiming daily login: points persisted to Firestore `/users/{uid}`

### P1 — Must Pass

- [ ] `MissionViewModel.fetchModules()` restores `isCompleted: true` for all modules in `user.completedModuleIds`
- [ ] After app restart: completed modules still show as completed in the mission list
- [ ] `LeaderboardViewModel` queries Firestore `users` collection ordered by `points desc`
- [ ] Current user's real name and real points appear in the leaderboard (zero mock data)
- [ ] Logged-in user's entry shows `(You)` suffix in the leaderboard
- [ ] `PhotoSubmissionService` is injected into `ChallengeViewModel` and called on every successful upload
- [ ] A Firestore document in `/photo_submissions` is created with `status: "pending"` after every photo upload

### Verification Script (manual test — run in order)

1. Register a new account
2. Complete module M01 → check Firestore `/users/{uid}`:
   `points: 50`, `completedModuleIds: ["M01"]`
3. Kill and reopen the app → M01 must still appear as completed
4. Claim daily login → check Firestore: `streakCount: 1`, `lastLoginDate` updated
5. Kill and reopen the app → streak must still be 1 (not 0)
6. Claim daily login again same day → must throw exception, no duplicate points
7. Open leaderboard → real name and real points must appear
8. Upload a photo → check Firestore `photo_submissions` for a document with real Storage URL
   and `status: "pending"`

---

## PR REQUIREMENTS

- **Branch:** `feature/firebase-persistence`
- **Base:** `main`
- **Title:** `feat: persist all game data to firestore (P0 & P1 sprint)`
- **PR body must include:**
  - List of all changed files
  - All Definition of Done items checked with ✅
  - Note: "Firestore composite index `role ASC + points DESC` must be deployed via Firebase Console
    before leaderboard works in production"
