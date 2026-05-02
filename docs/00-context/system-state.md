# system-state.md — GamifyPhotography

> Update file ini setiap kali ada perubahan signifikan pada codebase.
> **Terakhir diperbarui:** 2026-05-02 (Sprint: Daily Login + Leaderboard)

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
│   ├── challenge_service.dart     🔴 Mock only
│   ├── daily_login_service.dart   ✅ [BARU] In-memory mock, streak logic, 500ms delay
│   ├── module_service.dart        ✅ Mock data lengkap 10 misi (M01–M10)
│   └── user_service.dart          🔴 Mock only
├── view_models/
│   ├── auth_view_model.dart           ✅ Mock bypass dihapus
│   ├── challenge_view_model.dart      ✅ Immutable state (copyWith), camera package, completeChallenge + badge logic
│   ├── crafting_view_model.dart       ✅ Menggunakan service_providers.dart
│   ├── daily_login_view_model.dart    ✅ [BARU] DailyLoginState (manual copyWith), initialize + claimToday
│   ├── home_view_model.dart           ✅ Minimal, OK
│   ├── leaderboard_view_model.dart    ✅ [BARU] 15 mock user, sort descending, currentUserRank
│   ├── mission_view_model.dart        ✅ Struktur OK
│   ├── onboarding_view_model.dart     ✅ OK
│   └── progress_view_model.dart       ✅ Struktur OK
└── views/
    ├── auth/        ✅ login_view, register_view
    ├── crafting/    ✅ crafting_view
    ├── home/
    │   ├── main_layout_view.dart   ✅ ConsumerStatefulWidget, trigger daily login sheet di initState
    │   ├── home_view.dart          ✅
    │   └── daily_login_view.dart   ✅ [BARU] Bottom sheet modal, 7 day indicators, AnimatedScale
    ├── leaderboard/ ✅ leaderboard_view (wired ke LeaderboardViewModel, 15 user, highlight current user)
    ├── mission/
    │   ├── module_list_view.dart      ✅
    │   ├── module_detail_view.dart    ✅ PageView 2 hal (Teori + Visual Guide)
    │   ├── challenge_brief_view.dart  ✅
    │   ├── challenge_view.dart        ✅ Kamera via CustomCameraView, auto-complete + navigate ke feedback
    │   ├── custom_camera_view.dart    ✅ Kamera native + SVG overlay per modul
    │   └── feedback_view.dart         ✅
    ├── onboarding/  ✅ onboarding_view
    ├── progress/    ✅ progress_view
    └── widgets/     ✅ animated_3d_button, dll
```

**File yang BELUM ADA (perlu dibuat):**
- `lib/views/profile/profile_view.dart`
- `lib/view_models/badge_view_model.dart`
- `lib/view_models/profile_view_model.dart`
- `lib/services/badge_service.dart`
- `lib/services/leaderboard_service.dart`

---

## Status Kesiapan per Fitur

| Fitur | View | ViewModel | Service | Kesiapan |
|-------|------|-----------|---------|----------|
| Onboarding | ✅ | ✅ | — | 80% |
| Login/Register | ✅ | ✅ Mock fixed | 🔴 Mock | 50% |
| Mission List | ✅ | ✅ | ✅ Mock 10 misi | 80% |
| Challenge (Kamera) | ✅ camera native | ✅ Immutable + badge | 🔴 Mock | 70% |
| Crafting | ✅ | ✅ | 🔴 Mock | 55% |
| Leaderboard | ✅ ViewModel wired | ✅ 15 mock users | 🔴 Mock | 65% |
| Profile | ❌ | ❌ | ❌ | 0% |
| Daily Login | ✅ Bottom sheet | ✅ StateNotifier | ✅ In-memory mock | 70% |
| Badge | ❌ | ❌ | ❌ | 0% |

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
| BUG-08 | 🟡 Medium | ⏳ Open | `custom_camera_view.dart` | Duplicate import `camera/camera.dart` (baris 2 & 3) |
| BUG-09 | 🟡 Medium | ⏳ Open | `challenge_view.dart` | completeChallenge dipanggil 2x (saat capture & saat tombol) |
| BUG-10 | 🟡 Medium | ⏳ Open | `leaderboard_view_model.dart` | userId dari auth tidak otomatis sync ke mock data — `_kCurrentUserMockId` harus diganti saat Firebase live |

---

## Catatan Arsitektur Terkini

- **ModuleModel** menggunakan field `materialContent` (bukan `whenToUse`/`howToUse` seperti di tech-design lama) — sudah sesuai dengan implementasi `module_service.dart`
- **ChallengeView** menggunakan pola: buka `CustomCameraView` via `Navigator.push`, menerima `XFile` via pop, lalu otomatis upload + complete + navigate ke feedback
- **build_runner** sudah dijalankan, semua `.freezed.dart` dan `.g.dart` sudah ter-generate
