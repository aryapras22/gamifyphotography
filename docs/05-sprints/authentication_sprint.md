```
ROLE: You are a Senior Flutter Engineer. You write production-ready code. You do not ask clarifying questions. You do not explain your plan. You execute.

REPO: https://github.com/aryapras22/gamifyphotography
BRANCH: Create `feature/firebase-auth` from `main` and commit all changes there.

---

## RULES — READ FIRST, NEVER VIOLATE

1. Mobile app is USER ONLY. There is NO admin screen, NO `/admin` route, NO admin widget in Flutter.
2. Admin approval will be handled by a SEPARATE WEB APP in the future. Do not build it now.
3. Firebase backend (Firestore schema + security rules) MUST support future web admin from day one.
4. Never use hardcoded colors or hex. Always use `AppColors.*`.
5. Never use raw `TextStyle(...)` in auth views. Always use `AppTextStyles.*`.
6. All `TextEditingController` MUST be disposed. No exceptions.
7. All auth views MUST be `ConsumerStatefulWidget`.
8. Never manually navigate after login/register. Let GoRouter redirect handle it.
9. After changing any Freezed model, run `build_runner` immediately.
10. `flutter analyze` must pass with ZERO new errors before opening PR.

---

## WHAT EXISTS NOW (BROKEN — REPLACE ALL OF IT)

- `AuthService` → mock only, single hardcoded user, no Firebase
- `AuthViewModel` → no stream listener, no session restore
- `LoginView` → leaks controllers, uses `Colors.red`, no real validation
- `RegisterView` → leaks controllers, no confirm password, no AppColors
- `UserModel` → missing `role` and `createdAt`
- `main.dart` → has login bypass, no Firebase init
- Router → no redirect guard, all routes open
- No `Validators` class
- No `PhotoSubmissionModel` or `PhotoSubmissionService`
- No `SplashView`

---

## EXECUTE THESE TASKS IN ORDER

---

### TASK 1 — pubspec.yaml

Add under `dependencies`:

```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
firebase_storage: ^12.0.0
```

Run `flutter pub get`.

---

### TASK 2 — main.dart

- Remove login bypass
- Remove hardcoded navigation
- Call `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` before `runApp()`
- Wrap `runApp()` with `ProviderScope`
- Initial route: `/splash`

---

### TASK 3 — lib/models/user_model.dart

Replace with:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  factory UserModel({
    required String id,
    required String name,
    required String email,
    @Default('user') String role,
    @Default(0) int points,
    @Default(1) int level,
    @Default([]) List<String> earnedBadgeIds,
    @Default([]) List<String> completedPhotoUrls,
    @Default(0) int bridgeProgress,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

Then immediately run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### TASK 4 — lib/services/auth_service.dart

Replace entire file:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password,
      );
      return await fetchUser(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password,
      );
      final uid = cred.user!.uid;
      final user = UserModel(
        id: uid, name: name.trim(),
        email: email.trim(), role: 'user',
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(uid).set({
        ...user.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<UserModel> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('User data not found.');
    return UserModel.fromJson({...doc.data()!, 'id': uid});
  }

  Future<void> logout() async => _auth.signOut();

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':     return 'Email is not registered.';
      case 'wrong-password':
      case 'invalid-credential': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email already in use.';
      case 'weak-password':      return 'Password too weak (min 6 chars).';
      case 'invalid-email':      return 'Invalid email format.';
      case 'network-request-failed': return 'No internet connection.';
      default: return 'Authentication failed. Please try again.';
    }
  }
}
```

---

### TASK 5 — lib/view_models/auth_view_model.dart

Replace entire file:

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../providers/service_providers.dart';

const _unset = Object();

class AuthState {
  final bool isLoading;
  final bool isCheckingSession;
  final String? errorMessage;
  final UserModel? currentUser;

  AuthState({
    this.isLoading = false,
    this.isCheckingSession = true,
    this.errorMessage,
    this.currentUser,
  });

  bool get isLoggedIn => currentUser != null;

  AuthState copyWith({
    bool? isLoading,
    bool? isCheckingSession,
    Object? errorMessage = _unset,
    Object? currentUser = _unset,
  }) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    isCheckingSession: isCheckingSession ?? this.isCheckingSession,
    errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    currentUser: currentUser == _unset ? this.currentUser : currentUser as UserModel?,
  );
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(ref.read(authServiceProvider)),
);

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;
  StreamSubscription? _sub;

  AuthViewModel(this._authService) : super(AuthState(isCheckingSession: true)) {
    _sub = _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        state = AuthState(isCheckingSession: false);
      } else {
        try {
          final user = await _authService.fetchUser(firebaseUser.uid);
          state = AuthState(isCheckingSession: false, currentUser: user);
        } catch (_) {
          state = AuthState(isCheckingSession: false);
        }
      }
    });
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(isLoading: false, currentUser: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.register(name, email, password);
      state = state.copyWith(isLoading: false, currentUser: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState(isCheckingSession: false);
  }

  void updateUser(UserModel u) => state = state.copyWith(currentUser: u);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
```

---

### TASK 6 — lib/core/validators.dart

Create new file:

```dart
class Validators {
  Validators._();

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required.';
    if (v.trim().length < 2) return 'Minimum 2 characters.';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v.trim()))
      return 'Invalid email format.';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required.';
    if (v.length < 6) return 'Minimum 6 characters.';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Please confirm your password.';
    if (v != original) return 'Passwords do not match.';
    return null;
  }
}
```

---

### TASK 7 — lib/views/splash_view.dart

Create new file:

```dart
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.brandBlue),
      ),
    );
  }
}
```

---

### TASK 8 — lib/core/router.dart

Create or fully replace this file.

Rules:
- unauthenticated → only access `/splash`, `/login`, `/register`, `/onboarding`
- authenticated → redirected away from login/register/splash to `/home`
- no `/admin` route
- no role-based redirect in mobile app

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/auth_view_model.dart';
import '../views/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
// import all other existing views

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (auth.isCheckingSession) return loc == '/splash' ? null : '/splash';

      const open = ['/splash', '/login', '/register', '/onboarding'];
      final isOpen = open.contains(loc);

      if (!auth.isLoggedIn && !isOpen) return '/login';
      if (auth.isLoggedIn && (loc == '/login' || loc == '/register' || loc == '/splash'))
        return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/splash',     builder: (_, __) => const SplashView()),
      GoRoute(path: '/login',      builder: (_, __) => const LoginView()),
      GoRoute(path: '/register',   builder: (_, __) => const RegisterView()),
      // keep all existing user routes
      // DO NOT add /admin
    ],
  );
});
```

Update `main.dart` to use `routerProvider`:
```dart
final router = ref.watch(routerProvider);
return MaterialApp.router(routerConfig: router, ...);
```

---

### TASK 9 — lib/views/auth/login_view.dart

Replace entire file.

Hard requirements:
- `ConsumerStatefulWidget`
- `TextEditingController` and `FocusNode` disposed in `dispose()`
- `Form` + `GlobalKey<FormState>`
- validation via `Validators.email` and `Validators.password` — client side before any API call
- all colors from `AppColors.*`
- all text styles from `AppTextStyles.*`
- password field: show/hide toggle with `Icons.visibility` / `Icons.visibility_off`
- error banner: shown when `authState.errorMessage != null`, uses `AppColors.coralRed`
- login button: disabled and shows spinner when `authState.isLoading`
- do NOT call `context.go(...)` after login — router redirect handles it
- background tap dismisses keyboard

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/validators.dart';
import '../../view_models/auth_view_model.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});
  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authViewModelProvider.notifier)
        .login(_emailCtrl.text, _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.surfaceWhite,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                const Icon(Icons.camera_alt_rounded,
                    size: 64, color: AppColors.brandBlue),
                const SizedBox(height: 16),
                Text('Welcome Back', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text('Sign in to continue learning',
                    style: AppTextStyles.body),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                  ]),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.coralRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(state.errorMessage!,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.coralRed)),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandBlue,
                      foregroundColor: AppColors.surfaceWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                color: AppColors.surfaceWhite,
                                strokeWidth: 2))
                        : Text('Login', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text("Don't have an account? Register",
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.brandBlue)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### TASK 10 — lib/views/auth/register_view.dart

Replace entire file. Same rules as TASK 9, PLUS:
- add `confirmPassword` field — this is a new field, does not exist yet
- 4 controllers total: name, email, password, confirmPassword — all disposed
- validate with: `Validators.name`, `Validators.email`, `Validators.password`, `Validators.confirmPassword`
- `role` is always `'user'` — no role selector
- do NOT navigate manually after register — router handles it

Build the form with fields in this order:
1. Name
2. Email
3. Password (with show/hide toggle)
4. Confirm Password (with show/hide toggle)

Follow the exact same structure pattern as the LoginView in TASK 9.

---

### TASK 11 — lib/models/photo_submission_model.dart

Create new file:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_submission_model.freezed.dart';
part 'photo_submission_model.g.dart';

@freezed
class PhotoSubmissionModel with _$PhotoSubmissionModel {
  factory PhotoSubmissionModel({
    required String id,
    required String userId,
    required String userName,
    required String moduleId,
    required String moduleTitle,
    required String photoUrl,
    @Default('pending') String status,
    String? adminNote,
    required DateTime submittedAt,
    DateTime? reviewedAt,
  }) = _PhotoSubmissionModel;

  factory PhotoSubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$PhotoSubmissionModelFromJson(json);
}
```

Run `build_runner` immediately after.

---

### TASK 12 — lib/services/photo_submission_service.dart

Create new file:

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
```

Then add to `lib/providers/service_providers.dart`:
```dart
import '../services/photo_submission_service.dart';

final photoSubmissionServiceProvider =
    Provider<PhotoSubmissionService>((ref) => PhotoSubmissionService());
```

---

### TASK 13 — Submission Status Widget

In `lib/views/modules/module_detail_view.dart` (or equivalent challenge/module screen):

Add a reactive submission status indicator using `StreamProvider`.

Requirements:
- use `photoSubmissionServiceProvider` to call `watchUserSubmission(userId, moduleId)`
- display based on `status`:
  - `pending` → Row with `Icons.schedule` + text `'Pending Review'`, color `AppColors.lensGold`
  - `approved` → Row with `Icons.check_circle` + text `'Approved'`, color `AppColors.forestGreen`
  - `rejected` → Row with `Icons.cancel` + text `'Rejected'`, color `AppColors.coralRed`
  - if rejected and `adminNote != null` → show note text below in `AppColors.secondaryText`
- if no submission exists, show nothing
- use `StreamProvider.autoDispose` scoped to current user + moduleId

---

### TASK 14 — Firestore Security Rules

Apply this in Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }
    function isOwner(uid) {
      return request.auth.uid == uid;
    }
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
            .affectedKeys().hasAny(['role']);
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

### TASK 15 — Firebase Storage Rules

Apply in Firebase Console → Storage → Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /challenge_photos/{userId}/{photoId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## DEFINITION OF DONE

Do not open a PR until ALL of these pass:

- [ ] `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` in pubspec.yaml
- [ ] `main.dart` has no login bypass, Firebase initialized before runApp
- [ ] `UserModel` has `role` and `createdAt`, build_runner completed
- [ ] `AuthService` is fully Firebase-based, no mock code left
- [ ] `AuthViewModel` listens to `authStateChanges`, subscription cancelled in dispose
- [ ] `Validators` class exists at `lib/core/validators.dart`
- [ ] `SplashView` exists at `lib/views/splash_view.dart`
- [ ] GoRouter redirects correctly for logged-in and logged-out states
- [ ] No `/admin` route exists anywhere in the mobile codebase
- [ ] `LoginView` is `ConsumerStatefulWidget`, all controllers disposed, uses `AppColors` only
- [ ] `RegisterView` is `ConsumerStatefulWidget`, has confirm password field, all controllers disposed
- [ ] `PhotoSubmissionModel` exists, build_runner completed
- [ ] `PhotoSubmissionService` exists and is registered in `service_providers.dart`
- [ ] Submission status widget shows `pending / approved / rejected` reactively in module/challenge screen
- [ ] Firestore rules applied: role escalation blocked, status manipulation blocked
- [ ] Storage rules applied: owner-only write, 5MB max, image only
- [ ] `flutter analyze` → zero new errors

---

## PR REQUIREMENTS

- Branch: `feature/firebase-auth`
- Title: `feat: firebase auth — user-only mobile, backend ready for admin web`
- Body must include:
  - list of changed/created files
  - confirmation that each Definition of Done item is checked
  - note: "Admin approval UI is intentionally NOT in mobile. It will be built as a separate web application."
```
