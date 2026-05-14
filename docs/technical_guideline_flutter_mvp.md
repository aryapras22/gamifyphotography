# Technical Guideline: MVP Flutter App — Gamifikasi Pelatihan Fotografi

> Dokumen ini adalah instruksi utama untuk AI Coding Agent (Antigravity) dalam membangun MVP aplikasi Flutter berbasis pola MVVM.

---

## 1. Project Overview

Aplikasi pelatihan fotografi berbasis **gamifikasi** yang dirancang untuk membantu pengguna (staf Corporate Communication) mempelajari teknik komposisi fotografi secara bertahap dan menyenangkan. MVP ini berfokus pada alur inti: **Onboarding → Login/Register → Home → Mission → Feedback → Crafting → Progress**.

**Goal MVP:**
- Pengguna dapat mendaftar dan login
- Pengguna dapat membaca modul & menyelesaikan challenge foto
- Pengguna mendapat poin, level up, dan badge
- Pengguna dapat melakukan crafting menggunakan poin
- Pengguna dapat melihat progress dan leaderboard

---

## 2. Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                  # MaterialApp, routing setup
│   └── routes.dart               # Named routes / GoRouter config
│
├── models/
│   ├── user_model.dart
│   ├── module_model.dart
│   ├── challenge_model.dart
│   ├── badge_model.dart
│   └── leaderboard_model.dart
│
├── views/
│   ├── auth/
│   │   ├── login_view.dart
│   │   └── register_view.dart
│   ├── onboarding/
│   │   └── onboarding_view.dart
│   ├── home/
│   │   └── home_view.dart
│   ├── mission/
│   │   ├── module_list_view.dart
│   │   ├── module_detail_view.dart
│   │   ├── challenge_view.dart
│   │   └── feedback_view.dart
│   ├── crafting/
│   │   └── crafting_view.dart
│   ├── progress/
│   │   ├── progress_view.dart
│   │   └── badge_view.dart
│   └── leaderboard/
│       └── leaderboard_view.dart
│
├── view_models/
│   ├── auth_view_model.dart
│   ├── onboarding_view_model.dart
│   ├── home_view_model.dart
│   ├── mission_view_model.dart
│   ├── challenge_view_model.dart
│   ├── crafting_view_model.dart
│   └── progress_view_model.dart
│
└── services/
    ├── auth_service.dart
    ├── module_service.dart
    ├── challenge_service.dart
    └── user_service.dart
```

---

## 3. Feature Roadmap (MVP Scope)

| # | Feature | Priority | Diekstrak dari Alur |
|---|---------|----------|----------------------|
| 1 | Onboarding (animasi pengenalan) | P0 | Alur Permainan |
| 2 | Register & Login Player | P0 | UC-P01, UC-P02 |
| 3 | Home Screen (pilih Mission / Crafting) | P0 | Alur Permainan |
| 4 | List Modul Pembelajaran | P0 | UC-P04, UC-P05 |
| 5 | Baca Materi Modul | P0 | UC-P06, UC-P15 |
| 6 | Mulai & Upload Hasil Challenge | P0 | UC-P07, UC-P08, UC-P09 |
| 7 | Feedback + Earn Points setelah Challenge | P0 | UC-P10, Feedback Screen |
| 8 | Level Up otomatis berdasarkan poin | P1 | UC-P11 |
| 9 | Crafting (konversi poin → jembatan) | P1 | Alur Crafting |
| 10 | Progress Indicator (poin, level, modul) | P1 | UC-P12 |
| 11 | Badge / Lencana | P1 | UC-P13 |
| 12 | Leaderboard | P2 | UC-P14 |

> **P0** = Wajib ada di MVP | **P1** = Sangat direkomendasikan | **P2** = Nice to have

---

## 4. Simplified Data Models (Dart)

```dart
// models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  int points;
  int level;
  List<String> earnedBadgeIds;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.points = 0,
    this.level = 1,
    this.earnedBadgeIds = const [],
  });
}

// models/module_model.dart
class ModuleModel {
  final String id;
  final String title;
  final String description;
  final String materialContent; // teks materi
  final int order;              // urutan level
  bool isCompleted;

  ModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.materialContent,
    required this.order,
    this.isCompleted = false,
  });
}

// models/challenge_model.dart
class ChallengeModel {
  final String id;
  final String moduleId;
  final String instruction;
  final int pointReward;
  bool isCompleted;
  String? uploadedPhotoUrl;

  ChallengeModel({
    required this.id,
    required this.moduleId,
    required this.instruction,
    required this.pointReward,
    this.isCompleted = false,
    this.uploadedPhotoUrl,
  });
}

// models/badge_model.dart
class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final int requiredPoints; // threshold poin untuk unlock

  BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.requiredPoints,
  });
}

// models/leaderboard_model.dart
class LeaderboardEntry {
  final String userId;
  final String userName;
  final int points;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.points,
    required this.rank,
  });
}
```

---

## 5. ViewModel Logic

### `AuthViewModel`
- `login(email, password)` → validasi input, panggil `AuthService.login()`, simpan user ke state
- `register(name, email, password)` → validasi, panggil `AuthService.register()`
- `logout()` → clear state, redirect ke login
- State: `isLoading`, `errorMessage`, `currentUser`

### `OnboardingViewModel`
- `markOnboardingDone()` → simpan flag ke SharedPreferences agar tidak muncul lagi
- `isOnboardingDone` → bool, dicek di `main.dart` untuk routing awal

### `HomeViewModel`
- Expose data ringkasan: `currentUser.points`, `currentUser.level`
- `navigateToMission()`, `navigateToCrafting()`

### `MissionViewModel`
- `fetchModules()` → load list modul dari `ModuleService`
- `selectModule(moduleId)` → set modul aktif
- State: `List<ModuleModel> modules`, `ModuleModel? activeModule`, `isLoading`

### `ChallengeViewModel`
- `loadChallenge(moduleId)` → fetch challenge dari `ChallengeService`
- `uploadPhoto(file)` → upload hasil foto, simpan URL
- `completeChallenge()` → tandai selesai, tambah poin ke user, cek level up
- `checkLevelUp()` → jika `points >= threshold`, increment `user.level`
- `checkAndAwardBadge()` → bandingkan poin user dengan `requiredPoints` semua badge
- State: `ChallengeModel? challenge`, `isUploading`, `pointsEarned`

### `CraftingViewModel`
- `loadCraftingStatus()` → cek apakah poin user mencukupi untuk crafting
- `doCrafting(int pointCost)` → kurangi poin, set status crafting selesai
- `hasSufficientPoints` → bool
- State: `craftingDone`, `currentPoints`, `requiredPoints`

### `ProgressViewModel`
- `loadUserProgress()` → fetch data user terkini (poin, level, modul selesai)
- `loadBadges()` → fetch semua badge + filter yang sudah diraih user
- State: `UserModel user`, `List<BadgeModel> earnedBadges`, `double progressPercentage`

---

## 6. Screen List & Navigation

**State Management: Riverpod (direkomendasikan untuk MVP)**
> Riverpod lebih aman dari Provider karena compile-time safe, tidak butuh `context`, dan cocok dengan arsitektur MVVM yang strict.

### Daftar Screen

| File | Route Name | Deskripsi |
|------|-----------|-----------|
| `onboarding_view.dart` | `/onboarding` | Animasi pengenalan, tampil sekali |
| `login_view.dart` | `/login` | Form login player |
| `register_view.dart` | `/register` | Form registrasi player |
| `home_view.dart` | `/home` | Hub utama: tombol Mission & Crafting |
| `module_list_view.dart` | `/mission` | Daftar semua modul fotografi |
| `module_detail_view.dart` | `/mission/detail` | Baca materi modul |
| `challenge_view.dart` | `/mission/challenge` | Praktik + upload foto |
| `feedback_view.dart` | `/mission/feedback` | Tampil poin earned + animasi |
| `crafting_view.dart` | `/crafting` | Konversi poin → jembatan |
| `progress_view.dart` | `/progress` | Poin, level, progress bar |
| `badge_view.dart` | `/progress/badges` | Koleksi badge pengguna |
| `leaderboard_view.dart` | `/leaderboard` | Ranking pemain |

### Alur Navigasi

```
App Start
  └─► Cek onboarding flag
        ├─► Belum → /onboarding → /login
        └─► Sudah  → /login

/login ──────────────────────────────► /home
                                          │
                    ┌─────────────────────┴──────────────────────┐
                    ▼                                             ▼
              /mission                                      /crafting
                 │                                    (cek poin cukup?)
       ┌─────────┴──────────┐                         ├─ Cukup   → crafting done
       ▼                    ▼                         └─ Kurang  → /mission
 /mission/detail    (modul lain)
       │
       ▼
 /mission/challenge
       │
       ▼
 /mission/feedback ──► /home atau /mission/detail (level berikutnya)

/home (bottom nav)
  ├─ /progress
  │     └─ /progress/badges
  └─ /leaderboard
```

---

## 7. Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1

  # Navigation
  go_router: ^13.0.0

  # Network & API
  dio: ^5.4.0

  # Local Storage (onboarding flag, cache user)
  shared_preferences: ^2.2.3

  # Image Picker (upload foto challenge)
  image_picker: ^1.0.7

  # UI Utilities
  cached_network_image: ^3.3.1
  lottie: ^3.1.0              # Animasi onboarding & feedback
  percent_indicator: ^4.2.3   # Progress bar visual

  # Functional / Utilities
  freezed_annotation: ^2.4.1  # Immutable models (opsional tapi direkomendasikan)
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
```

---

## 8. Implementation Notes untuk AI Agent

1. **MVVM Strict Rule:** View **tidak boleh** mengandung logika bisnis. Semua logika ada di ViewModel. View hanya `watch` provider dan panggil method ViewModel.
2. **Riverpod Pattern:** Gunakan `StateNotifierProvider` untuk setiap ViewModel.
   ```dart
   // Contoh
   final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
     (ref) => AuthViewModel(ref.read(authServiceProvider)),
   );
   ```
3. **Service Layer:** Service hanya bertanggung jawab komunikasi data (API call / local DB). Tidak ada logika UI di sini.
4. **Crafting Validation:** `CraftingViewModel` harus selalu cek `hasSufficientPoints` sebelum eksekusi `doCrafting()`. Jika false, emit state yang men-trigger navigasi ke `/mission`.
5. **Offline-first (opsional untuk MVP+):** Pertimbangkan caching modul dengan `shared_preferences` atau `hive` agar bisa diakses tanpa internet.

---

*Generated by Senior Systems Analyst & Flutter Architect | MVP Scope Only*
