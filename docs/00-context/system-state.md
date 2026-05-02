# system-state.md — GamifyPhotography

> Update file ini setiap kali ada perubahan signifikan pada codebase.
> **Terakhir diperbarui:** 2026-05-02 (Sprint: Profile + Badge + BugFix)

---

## Struktur Folder Saat Ini

```
lib/
├── app/
│   ├── app.dart               ✅ Entry point, ProviderScope
│   └── routes.dart            ✅ Semua route MVP terdaftar (go_router)
├── models/
│   ├── user_model.dart        ✅ @freezed + generated (.freezed.dart, .g.dart)
│   ├── badge_model.dart       ✅ @freezed + generated
│   ├── challenge_model.dart   ✅ @freezed + generated
│   ├── module_model.dart      ✅ @freezed + generated (field: id, title, description, materialContent, order, isCompleted)
│   └── leaderboard_model.dart ✅ @freezed + generated
├── providers/
│   └── service_providers.dart ✅ Centralized: auth, challenge, module, user, dailyLoginServiceProvider
├── services/
│   ├── auth_service.dart          🔴 Mock only
│   ├── badge_service.dart         ✅ [BARU] 5 badge, mock unlock logic
│   ├── challenge_service.dart     🔴 Mock only
│   ├── daily_login_service.dart   ✅ In-memory mock, streak logic
│   ├── module_service.dart        ✅ Mock data lengkap 10 misi (M01–M10)
│   └── user_service.dart          🔴 Mock only
├── view_models/
│   ├── auth_view_model.dart           ✅ Mock bypass dihapus
│   ├── badge_view_model.dart          ✅ [BARU] BadgeState (manual copyWith), loadBadges + checkAndUnlock
│   ├── challenge_view_model.dart      ✅ BUG-09 fixed, BadgeService integration
│   ├── crafting_view_model.dart       ✅ Menggunakan service_providers.dart
│   ├── daily_login_view_model.dart    ✅ DailyLoginState (manual copyWith), initialize + claimToday
│   ├── home_view_model.dart           ✅ Minimal, OK
│   ├── leaderboard_view_model.dart    ✅ 15 mock user, sort descending, currentUserRank
│   ├── mission_view_model.dart        ✅ Struktur OK
│   ├── onboarding_view_model.dart     ✅ OK
│   ├── profile_view_model.dart        ✅ [BARU] ProfileState (manual copyWith), loadProfile + refresh
│   └── progress_view_model.dart       ✅ Struktur OK
└── views/
    ├── auth/        ✅ login_view, register_view
    ├── crafting/    ✅ crafting_view
    ├── home/
    │   ├── main_layout_view.dart   ✅ Tab Profil → ProfileView
    │   ├── home_view.dart          ✅
    │   └── daily_login_view.dart   ✅ Bottom sheet modal, 7 day indicators
    ├── leaderboard/ ✅ leaderboard_view (wired ke LeaderboardViewModel)
    ├── mission/
    │   ├── module_list_view.dart      ✅
    │   ├── module_detail_view.dart    ✅ PageView 2 hal (Teori + Visual Guide)
    │   ├── challenge_brief_view.dart  ✅
    │   ├── challenge_view.dart        ✅ BUG-09 fixed: completeChallenge hanya dari tombol CEK HASIL
    │   ├── custom_camera_view.dart    ✅ BUG-08 fixed: duplicate import dihapus
    │   └── feedback_view.dart         ✅
    ├── onboarding/  ✅ onboarding_view
    ├── profile/
    │   └── profile_view.dart          ✅ [BARU] Avatar, badge grid, foto grid
    ├── progress/    ✅ progress_view
    └── widgets/     ✅ animated_3d_button, dll
```

**File yang BELUM ADA (perlu dibuat):**
- `lib/services/leaderboard_service.dart`

---

## Status Kesiapan per Fitur

| Fitur | View | ViewModel | Service | Kesiapan |
|-------|------|-----------|---------|----------|
| Onboarding | ✅ | ✅ | — | 80% |
| Login/Register | ✅ | ✅ Mock fixed | 🔴 Mock | 50% |
| Mission List | ✅ | ✅ | ✅ Mock 10 misi | 80% |
| Challenge (Kamera) | ✅ camera native | ✅ Immutable + badge | 🔴 Mock | 80% (BUG-09 fixed) |
| Crafting | ✅ | ✅ | 🔴 Mock | 55% |
| Leaderboard | ✅ ViewModel wired | ✅ 15 mock users | 🔴 Mock | 65% |
| Profile | ✅ [BARU] | ✅ [BARU] | ✅ BadgeService | 75% |
| Daily Login | ✅ Bottom sheet | ✅ StateNotifier | ✅ In-memory mock | 70% |
| Badge | ✅ (di ProfileView) | ✅ [BARU] | ✅ [BARU] | 70% |

---

## Known Issues

| ID | Severity | Status | File | Deskripsi |
|----|----------|--------|------|-----------|
| BUG-01 | 🔴 Critical | ✅ Closed | `challenge_view_model.dart` | State mutation langsung |
| BUG-02 | 🔴 Critical | ✅ Closed | `auth_view_model.dart` | Mock bypass login |
| BUG-03 | 🟠 High | ✅ Closed | `user_model.dart` | Semua field non-final |
| BUG-04 | 🟠 High | ✅ Closed | `challenge_view_model.dart` | Import cross-ViewModel |
| BUG-05 | 🟡 Medium | ✅ Closed | `crafting_view_model.dart` | `userServiceProvider` salah tempat |
| BUG-06 | 🟡 Medium | ✅ Closed | `models/*.dart` | Semua model belum `@freezed` |
| BUG-07 | 🟡 Medium | ✅ Closed | `challenge_view_model.dart` | `image_picker` harus diganti `camera` |
| BUG-08 | 🟡 Medium | ✅ Closed | `custom_camera_view.dart` | Duplicate import `camera/camera.dart` (baris 2 & 3) |
| BUG-09 | 🔴 Critical | ✅ Closed | `challenge_view.dart` + `challenge_view_model.dart` | completeChallenge dipanggil 2x → fix: hapus dari capture, guard isCompleted di ViewModel |
| BUG-10 | 🟡 Medium | ⏳ Open | `leaderboard_view_model.dart` | userId dari auth tidak otomatis sync ke mock data — `_kCurrentUserMockId` harus diganti saat Firebase live |

---

## Catatan Arsitektur Terkini

- **ModuleModel** menggunakan field `materialContent` (bukan `whenToUse`/`howToUse` seperti di tech-design lama) — sudah sesuai dengan implementasi `module_service.dart`
- **ChallengeView** menggunakan pola: buka `CustomCameraView` via `Navigator.push`, menerima `XFile` via pop, lalu upload foto → tampilkan preview → user tap "CEK HASIL" → completeChallenge() → navigate ke feedback
- **BadgeModel** menggunakan field `iconPath` (bukan `svgPath`) — semua badge service dan view sudah menggunakan field yang benar
- **build_runner** sudah dijalankan, semua `.freezed.dart` dan `.g.dart` sudah ter-generate
