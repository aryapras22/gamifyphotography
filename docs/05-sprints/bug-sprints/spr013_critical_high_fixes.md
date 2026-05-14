# SPR-013 — Critical & High Severity Bug Fixes
## Null Safety · Auth Guard · MVVM Coupling · Data Consistency

**Repo:** https://github.com/aryapras22/gamifyphotography
**Base branch:** `main`
**Working branch:** `fix/critical-high-severity-bugs`

```bash
git checkout main && git pull origin main
git checkout -b fix/critical-high-severity-bugs
```

Run `flutter analyze` setelah setiap task. **Zero new warnings before committing.**

---

## Scope — 8 Issues, 7 Files

| ID | Severity | File Target | Masalah |
|---|---|---|---|
| CRIT-01 | 🔴 Critical | `challenge_view_model.dart` | Null dereference saat upload foto |
| CRIT-02 | 🔴 Critical | `challenge_view_model.dart` | `errorMessage` tidak bisa di-clear (`copyWith` pattern salah) |
| CRIT-03 | 🔴 Critical | `submission_providers.dart` | Race condition double award poin |
| HIGH-01 | 🟠 High | `auth_service.dart` | `weekHistory` `List<bool>` cast TypeError dari Firestore |
| HIGH-02 | 🟠 High | `lib/app/routes.dart` + `lib/core/router.dart` | Tidak ada Auth Guard / redirect |
| HIGH-03 | 🟠 High | `daily_login_view_model.dart` + `lib/core/level_utils.dart` | Level formula duplikasi antar file |
| HIGH-04 | 🟠 High | `challenge_view_model.dart` + `challenge_view.dart` | View mengakses business logic langsung (MVVM violation) |
| HIGH-05 | 🟠 High | `profile_view_model.dart` | ProfileViewModel tidak reaktif terhadap User updates |
| HIGH-06 | 🟠 High | `app/routes.dart` | `/mission/feedback` route tidak terhubung ke manapun |
| HIGH-07 | 🟠 High | `views/home/home_view.dart` | `fetchModules()` dipanggil ulang setiap initState tanpa guard |

**Do NOT modify:** `main.dart`, semua `*.freezed.dart`, `*.g.dart`, semua model.

---

## TASK 1 — `challenge_view_model.dart` · CRIT-01: Null Dereference Guard

### Problem
```dart
// Baris 55 — BERBAHAYA: state.challenge bisa null
final updatedChallenge = state.challenge!.copyWith(uploadedPhotoUrl: url);
```

### Fix — Tambahkan null guard di awal `uploadPhoto()`

Temukan method `uploadPhoto` dan ganti seluruh implementasinya:

```dart
Future<void> uploadPhoto(XFile file) async {
  // ── CRIT-01 fix: null guard sebelum force-unwrap ──────────────────────
  final currentChallenge = state.challenge;
  if (currentChallenge == null) {
    state = state.copyWith(
      isUploading: false,
      errorMessage: 'Misi belum dimuat. Silakan coba lagi.',
    );
    return;
  }
  // ─────────────────────────────────────────────────────────────────────

  state = state.copyWith(isUploading: true, errorMessage: null);
  try {
    final url = await _challengeService.uploadPhoto(file);
    final updatedChallenge = currentChallenge.copyWith(uploadedPhotoUrl: url);

    // ── HIGH-04 fix: resolusi moduleTitle dipindah dari View ke ViewModel ─
    final moduleTitle = _ref.read(missionViewModelProvider).activeModule?.title
        ?? currentChallenge.moduleId;
    // ──────────────────────────────────────────────────────────────────────

    final user = _ref.read(authViewModelProvider).currentUser;
    if (user != null) {
      await _submissionService.submitPhoto(
        userId: user.id,
        userName: user.name,
        moduleId: currentChallenge.moduleId,
        moduleTitle: moduleTitle,
        photoUrl: url,
      );
    }

    state = state.copyWith(challenge: updatedChallenge, isUploading: false);
  } catch (e) {
    state = state.copyWith(
      isUploading: false,
      errorMessage: 'Upload gagal. Silakan coba lagi.',
    );
  }
}
```

Tambahkan import `mission_view_model.dart` di bagian atas file jika belum ada:
```dart
import 'mission_view_model.dart';
```

---

## TASK 2 — `challenge_view_model.dart` · CRIT-02: Perbaiki `copyWith` Sentinel Pattern

### Problem
`ChallengeState.copyWith()` selalu menimpa `errorMessage` dengan `null` jika parameter tidak disertakan. Tidak konsisten dengan pola `_unset` yang dipakai di `AuthState` dan `MissionState`.

### Fix — Tambahkan sentinel di `ChallengeState`

Temukan class `ChallengeState` (bagian atas file) dan ganti **seluruh class** dengan:

```dart
// Sentinel untuk membedakan "tidak di-set" vs "di-set ke null"
const _unset = Object();

class ChallengeState {
  final ChallengeModel? challenge;
  final bool isUploading;
  final int pointsEarned;
  final String? errorMessage;

  const ChallengeState({
    this.challenge,
    this.isUploading = false,
    this.pointsEarned = 0,
    this.errorMessage,
  });

  ChallengeState copyWith({
    ChallengeModel? challenge,
    bool? isUploading,
    int? pointsEarned,
    // ── CRIT-02 fix: gunakan sentinel agar null bisa di-set secara eksplisit ─
    Object? errorMessage = _unset,
  }) {
    return ChallengeState(
      challenge: challenge ?? this.challenge,
      isUploading: isUploading ?? this.isUploading,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
```

---

## TASK 3 — `submission_providers.dart` · CRIT-03: Race Condition Double Award

### Problem
`submissionApprovalWatcherProvider` bisa memanggil `awardPointsForApprovedSubmission()` dua kali untuk modul yang sama jika dua Firestore snapshot tiba sebelum `fetchUser()` selesai, karena guard `completedModuleIds.contains()` membaca state yang stale.

### Fix — Tambahkan in-memory processing set sebagai secondary guard

Temukan fungsi `async*` di dalam `submissionApprovalWatcherProvider` dan ganti seluruh isinya:

```dart
final submissionApprovalWatcherProvider =
    StreamProvider.autoDispose<void>((ref) async* {
  final userId = ref.watch(
    authViewModelProvider.select((s) => s.currentUser?.id),
  );
  if (userId == null) return;

  final service = ref.read(photoSubmissionServiceProvider);
  final authService = ref.read(authServiceProvider);
  final authNotifier = ref.read(authViewModelProvider.notifier);

  // ── CRIT-03 fix: in-memory guard mencegah concurrent double-award ───────
  // Firestore transaction di awardPointsForApprovedSubmission sudah idempotent,
  // tapi guard ini mencegah double network call jika dua snapshot tiba bersamaan.
  final Set<String> _inFlight = {};
  // ─────────────────────────────────────────────────────────────────────────

  await for (final submissions in service.watchAllUserSubmissions(userId)) {
    for (final submission in submissions) {
      if (submission.status != 'approved') continue;
      if (submission.adminScore == null) continue;

      // ── in-memory guard ──────────────────────────────────────────────────
      if (_inFlight.contains(submission.moduleId)) continue;
      // ────────────────────────────────────────────────────────────────────

      final currentUser = ref.read(authViewModelProvider).currentUser;
      if (currentUser == null) continue;
      if (currentUser.completedModuleIds.contains(submission.moduleId)) continue;

      // ── Mark as in-flight sebelum await ─────────────────────────────────
      _inFlight.add(submission.moduleId);
      // ────────────────────────────────────────────────────────────────────
      try {
        await authService.awardPointsForApprovedSubmission(
          userId: userId,
          moduleId: submission.moduleId,
          adminScore: submission.adminScore!,
          photoUrl: submission.photoUrl,
        );
        final updatedUser = await authService.fetchUser(userId);
        authNotifier.updateUser(updatedUser);
      } catch (e) {
        debugPrint('[SubmissionWatcher] failed to award points: $e');
        // Remove from in-flight agar bisa di-retry pada snapshot berikutnya
        _inFlight.remove(submission.moduleId);
      }
      // Setelah berhasil, biarkan tetap di _inFlight — modul sudah selesai.
    }
  }
});
```

---

## TASK 4 — `auth_service.dart` · HIGH-01: Fix `weekHistory` Cast TypeError

### Problem
`List<bool>.from(data['weekHistory'])` akan **throw `TypeError`** jika Firestore menyimpan value sebagai integer `0`/`1` atau mixed types, bukan `bool` murni.

### Fix — Temukan baris `weekHistory` di `fetchUser()` dan ganti:

```dart
// SEBELUM:
weekHistory: data['weekHistory'] != null
    ? List<bool>.from(data['weekHistory'])
    : List.filled(7, false),

// SESUDAH:
weekHistory: data['weekHistory'] != null
    ? List<bool>.from(
        (data['weekHistory'] as List).map((e) => e == true || e == 1),
      )
    : List.filled(7, false),
```

---

## TASK 5 — Auth Guard · HIGH-02: Tambah Redirect di Router

### Problem
Tidak ada auth guard. User bisa mengakses `/home`, `/mission/challenge`, dll. tanpa login via deep link.

### Step 5A — Cek apakah `lib/core/router.dart` sudah ada

Berdasarkan `app.dart` yang mengimport `'../core/router.dart'`, file ini sudah ada. Buka `lib/core/router.dart`.

### Step 5B — Tambahkan `redirect` callback ke `GoRouter`

Temukan definisi `GoRouter(...)` dan tambahkan parameter `redirect`:

```dart
import '../view_models/auth_view_model.dart';

// Di dalam GoRouter(...):
redirect: (BuildContext context, GoRouterState routerState) {
  // Baca auth state via ProviderContainer jika router bukan ConsumerWidget,
  // atau pastikan router dibuat sebagai Provider yang punya akses ke ref.
  // Cara yang direkomendasikan: jadikan routerProvider sebagai Provider<GoRouter>
  // yang menerima AuthState.

  // Contoh implementasi jika router sudah punya akses ke ref:
  final authState = ref.read(authViewModelProvider);
  final isCheckingSession = authState.isCheckingSession;
  final isLoggedIn = authState.isLoggedIn;

  final location = routerState.matchedLocation;
  final publicRoutes = {'/login', '/register', '/onboarding'};
  final isPublic = publicRoutes.contains(location);

  // Selama sesi di-check, jangan redirect
  if (isCheckingSession) return null;

  // Belum login → paksa ke /login
  if (!isLoggedIn && !isPublic) return '/login';

  // Sudah login tapi masih di halaman auth → arahkan ke /home
  if (isLoggedIn && isPublic) return '/home';

  return null; // tidak ada redirect
},
```

### Step 5C — Pastikan `refreshListenable` ditambahkan agar router re-evaluates saat auth berubah

Ini krusial agar redirect otomatis berjalan ketika login/logout:

```dart
// Di GoRouter constructor:
refreshListenable: GoRouterRefreshStream(
  ref.watch(authViewModelProvider.notifier).stream,
),
```

Atau gunakan pola `ChangeNotifier` yang kompatibel dengan `go_router`. Jika sudah menggunakan `routerProvider` berbasis Riverpod, gunakan `ref.listen` untuk notifikasi.

---

## TASK 6 — `lib/core/level_utils.dart` · HIGH-03: Sentralisasi Formula Level

### Problem
Formula `(totalPoints ~/ 100) + 1` tersebar di minimal 2 tempat:
- `daily_login_view_model.dart` baris 91
- `auth_service.dart` (di `awardPointsForApprovedSubmission` dan `completeModuleAtomic`)

### Step 6A — Buat file baru `lib/core/level_utils.dart`

```dart
// lib/core/level_utils.dart
// Single source of truth untuk kalkulasi level dari total XP.
// Gunakan fungsi ini di semua tempat yang menghitung atau menampilkan level.

/// Menghitung level berdasarkan total XP.
/// Level naik setiap 100 XP: 0–99 XP = Lv.1, 100–199 XP = Lv.2, dst.
int calculateLevel(int totalPoints) => (totalPoints ~/ 100) + 1;
```

### Step 6B — Update `daily_login_view_model.dart`

Tambahkan import:
```dart
import '../core/level_utils.dart';
```

Temukan baris level calculation di `claimToday()` dan ganti:
```dart
// SEBELUM:
level: ((user.points + kDailyLoginPoints) ~/ 100) + 1,

// SESUDAH:
level: calculateLevel(user.points + kDailyLoginPoints),
```

### Step 6C — Update `auth_service.dart`

Tambahkan import:
```dart
import 'package:gamifyphotography/core/level_utils.dart';
// Sesuaikan package name jika berbeda
```

Temukan semua baris:
```dart
'level': (newPoints ~/ 100) + 1,
```

Ganti dengan:
```dart
'level': calculateLevel(newPoints),
```
Ada 2 tempat: di `completeModuleAtomic()` dan `awardPointsForApprovedSubmission()`.

---

## TASK 7 — `challenge_view.dart` · HIGH-04: Hapus Business Logic dari View

### Problem
View merakit `moduleTitle` dari dua provider berbeda sebelum memanggil ViewModel — ini adalah MVVM violation.

### Fix — Ganti panggilan `uploadPhoto` di dalam `GestureDetector.onTap`

Temukan blok onTap di `challenge_view.dart` yang berisi:
```dart
onTap: () async {
  final XFile? xfile = await Navigator.of(context).push(...);
  if (xfile != null) {
    final moduleTitle = ref            // ❌ business logic di View
        .read(missionViewModelProvider)
        .activeModule
        ?.title ?? challenge.moduleId;
    await ref
        .read(challengeViewModelProvider.notifier)
        .uploadPhoto(xfile, moduleTitle: moduleTitle);
  }
},
```

Ganti dengan (karena `moduleTitle` sekarang diresolved di ViewModel — lihat Task 1):
```dart
onTap: () async {
  final XFile? xfile = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => CustomCameraView(
        moduleId: challenge.moduleId,
      ),
    ),
  );
  if (xfile != null) {
    // ── HIGH-04 fix: tidak perlu resolve moduleTitle di sini ─────────────
    // ChallengeViewModel.uploadPhoto() menghandle resolusi moduleTitle sendiri
    // dari missionViewModelProvider.
    // ──────────────────────────────────────────────────────────────────────
    await ref
        .read(challengeViewModelProvider.notifier)
        .uploadPhoto(xfile);   // ← hapus parameter moduleTitle
  }
},
```

---

## TASK 8 — `profile_view_model.dart` · HIGH-05: Reaktivitas terhadap User Updates

### Problem
`ProfileViewModel.loadProfile()` menggunakan `ref.read(authViewModelProvider)` sehingga tidak reaktif — jika poin user berubah (karena submission di-approve), ProfileView tidak update.

### Fix — Tambahkan listener di `ProfileViewModel` constructor

Tambahkan field `_authListener` dan setup listener di konstruktor:

```dart
class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref _ref;
  final BadgeService _badgeService;

  ProfileViewModel(this._ref, this._badgeService)
      : super(const ProfileState()) {
    // ── HIGH-05 fix: listen perubahan user dari authViewModelProvider ──────
    // Ketika points/level/badges berubah (akibat submission di-approve),
    // profile state langsung diperbarui tanpa perlu user refresh manual.
    _ref.listen<AuthState>(
      authViewModelProvider,
      (previous, next) {
        if (!mounted) return;
        if (next.currentUser != null &&
            next.currentUser != previous?.currentUser) {
          final user = next.currentUser!;
          state = state.copyWith(
            user: user,
            earnedBadgeIds: List.of(user.earnedBadgeIds),
            completedChallengePhotoUrls:
                List<String>.from(user.completedPhotoUrls),
          );
        }
      },
    );
    // ─────────────────────────────────────────────────────────────────────
  }

  Future<void> loadProfile() async {
    // ... implementasi yang sama, tidak berubah
  }

  Future<void> refreshProfile() async => loadProfile();
}
```

---

## TASK 9 — `routes.dart` · HIGH-06: Hubungkan `/mission/feedback` Route

### Problem
Route `/mission/feedback` terdaftar tapi tidak ada navigasi yang mengarah ke sana.

### Fix — Di `submission_status_view.dart`, tambahkan navigasi ke feedback

Temukan blok `if (status == 'approved')` di `_buildStatusCard()` dan tambahkan tombol feedback:

```dart
// Tambahkan di bawah _ScoreCard widget (setelah SizedBox(height: 24)):
if (status == 'approved' && submission.adminNote != null && submission.adminNote!.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandBlue,
        side: const BorderSide(color: AppColors.brandBlue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () => context.push('/mission/feedback'),
      icon: const Icon(Icons.comment_outlined, size: 18),
      label: Text('Lihat Feedback Lengkap', style: AppTextStyles.button.copyWith(
        color: AppColors.brandBlue,
        fontSize: 14,
      )),
    ),
  ),
```

---

## TASK 10 — `home_view.dart` · HIGH-07: Guard `fetchModules()` dari Redundant Call

### Problem
`fetchModules()` dipanggil setiap kali `initState` dijalankan tanpa mengecek apakah data sudah ada.

### Fix — Tambahkan guard di `initState`

Temukan blok `Future.microtask` di `initState()` dan ganti:

```dart
// SEBELUM:
Future.microtask(() {
  ref.read(missionViewModelProvider.notifier).fetchModules();
});

// SESUDAH:
Future.microtask(() {
  // ── HIGH-07 fix: hanya fetch jika belum ada data atau tidak sedang loading ─
  final currentState = ref.read(missionViewModelProvider);
  if (currentState.modules.isEmpty && !currentState.isLoading) {
    ref.read(missionViewModelProvider.notifier).fetchModules();
  }
  // ─────────────────────────────────────────────────────────────────────────
});
```

---

## Verification Checklist

Run `flutter analyze` — zero new issues.

**CRIT-01:**
- [ ] Navigasi ke ChallengeView sebelum module dimuat → tidak crash, menampilkan error message yang proper

**CRIT-02:**
- [ ] Setelah upload gagal, error ditampilkan; setelah klik retry, error hilang (tidak stuck)
- [ ] `state.copyWith(isUploading: true)` tidak menghilangkan `errorMessage` yang sudah ada sebelumnya

**CRIT-03:**
- [ ] Submit foto, approve dari admin, tunggu 5 detik → poin ditambahkan sekali, tidak duplikat
- [ ] Cek Firestore: `completedModuleIds` hanya berisi moduleId satu kali

**HIGH-01:**
- [ ] Login dengan user yang punya `weekHistory` dari Firestore → tidak ada TypeError di console

**HIGH-02:**
- [ ] Akses URL `/home` tanpa login → diredirect ke `/login`
- [ ] Login → otomatis diredirect ke `/home`
- [ ] Logout → otomatis diredirect ke `/login`

**HIGH-03:**
- [ ] Cari `(~/ 100) + 1` di seluruh codebase dengan grep → hanya ada di `level_utils.dart`, zero di file lain
  ```bash
  grep -r "~/ 100" lib/ --include="*.dart"
  ```

**HIGH-04:**
- [ ] `challenge_view.dart` tidak lagi mengimport atau mengakses `missionViewModelProvider`
- [ ] Upload foto berjalan normal dengan moduleTitle yang benar

**HIGH-05:**
- [ ] Buka ProfileView, approve submission dari admin di sisi lain → XP di ProfileView update otomatis tanpa refresh

**HIGH-06:**
- [ ] Submission dengan status `approved` + `adminNote` tidak null → tombol "Lihat Feedback Lengkap" muncul
- [ ] Tap tombol → navigasi ke `/mission/feedback` berhasil tanpa crash

**HIGH-07:**
- [ ] Navigasi bolak-balik ke tab Home 5 kali → Firestore tidak dipanggil lebih dari 1 kali (cek Flutter DevTools Network tab)

---

## Files Changed Summary

| File | Task | Perubahan |
|---|---|---|
| `lib/view_models/challenge_view_model.dart` | 1, 2, 7 | Null guard, sentinel `_unset`, hapus `moduleTitle` param, resolve moduleTitle di VM |
| `lib/providers/submission_providers.dart` | 3 | In-memory `_inFlight` Set sebagai concurrent double-award guard |
| `lib/services/auth_service.dart` | 4, 6 | Fix `weekHistory` cast, ganti formula level dengan `calculateLevel()` |
| `lib/core/router.dart` | 5 | Tambah `redirect` callback + `refreshListenable` |
| `lib/core/level_utils.dart` | 6 | **File baru** — single source of truth untuk `calculateLevel()` |
| `lib/view_models/daily_login_view_model.dart` | 6 | Pakai `calculateLevel()` |
| `lib/views/mission/challenge_view.dart` | 7 | Hapus `moduleTitle` resolusi dari View |
| `lib/view_models/profile_view_model.dart` | 8 | Tambah `ref.listen` untuk reaktivitas auth user |
| `lib/views/mission/submission_status_view.dart` | 9 | Tambah tombol navigasi ke `/mission/feedback` |
| `lib/views/home/home_view.dart` | 10 | Guard `fetchModules()` dengan empty + isLoading check |

---

## PR

**Title:** `fix(SPR-013): resolve all critical and high severity bugs — null safety, auth guard, race condition, MVVM`

**Body:**
```
## Summary
Sprint ini menyelesaikan 8 issues dengan severity Critical dan High
yang ditemukan dari static analysis dan deep-dive review codebase.

## Critical Fixes (3)
- CRIT-01: Null guard sebelum `state.challenge!` force-unwrap di uploadPhoto()
- CRIT-02: Sentinel pattern `_unset` ditambahkan ke ChallengeState.copyWith()
- CRIT-03: In-memory `_inFlight` Set mencegah concurrent double-award poin

## High Fixes (7)
- HIGH-01: Fix weekHistory cast TypeError dari Firestore (int → bool mapping)
- HIGH-02: Auth redirect guard di GoRouter + refreshListenable
- HIGH-03: Sentralisasi level formula ke lib/core/level_utils.dart
- HIGH-04: Resolusi moduleTitle dipindah dari View ke ChallengeViewModel
- HIGH-05: ProfileViewModel reaktif via ref.listen ke authViewModelProvider
- HIGH-06: Route /mission/feedback dihubungkan dari submission_status_view
- HIGH-07: fetchModules() di-guard agar tidak memanggil Firestore berulang

## Files Changed: 10 files, 1 new file (level_utils.dart)

Closes SPR-013
```
