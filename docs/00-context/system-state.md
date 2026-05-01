# system-state.md — GamifyPhotography

> Update file ini setiap kali ada perubahan signifikan pada codebase.
> **Terakhir diperbarui:** 2026-05-01

---

## Struktur Folder Saat Ini

```
lib/
├── app/
│   ├── app.dart               ✅ Entry point, ProviderScope
│   └── routes.dart            ✅ Semua route MVP terdaftar (go_router)
├── models/
│   ├── user_model.dart        ✅ @freezed
│   ├── badge_model.dart       ✅ @freezed
│   ├── challenge_model.dart   ✅ @freezed
│   ├── module_model.dart      ✅ @freezed
│   └── leaderboard_model.dart ✅ @freezed
├── services/
│   ├── auth_service.dart      🔴 Mock only
│   ├── challenge_service.dart 🔴 Mock only
│   ├── module_service.dart    🔴 Mock only
│   └── user_service.dart      🔴 Mock only
├── view_models/
│   ├── auth_view_model.dart       ✅ Mock bypass dihapus
│   ├── challenge_view_model.dart  ✅ State mutation & camera package fixed
│   ├── crafting_view_model.dart   ✅ Menggunakan service_providers.dart
│   ├── home_view_model.dart       ✅ Minimal, OK
│   ├── mission_view_model.dart    ✅ Struktur OK
│   └── progress_view_model.dart   ✅ Struktur OK
└── views/
    ├── auth/        ✅ login_view, register_view
    ├── crafting/    ✅ crafting_view
    ├── home/        ✅ main_layout_view
    ├── leaderboard/ ✅ leaderboard_view (belum ada ViewModel)
    ├── mission/     ✅ module_list, module_detail, challenge, brief, feedback
    ├── onboarding/  ✅ onboarding_view
    └── progress/    ✅ progress_view
```

**File yang BELUM ADA (perlu dibuat):**
- `lib/views/profile/profile_view.dart`
- `lib/views/profile/profile_view.dart`
- `lib/view_models/daily_login_view_model.dart`
- `lib/view_models/badge_view_model.dart`
- `lib/view_models/leaderboard_view_model.dart`
- `lib/view_models/profile_view_model.dart`
- `lib/services/daily_login_service.dart`
- `lib/services/badge_service.dart`
- `lib/services/leaderboard_service.dart`

---

## Status Kesiapan per Fitur

| Fitur | View | ViewModel | Service | Kesiapan |
|-------|------|-----------|---------|----------|
| Onboarding | ✅ | ✅ | — | 80% |
| Login/Register | ✅ | 🔴 Mock bypass | 🔴 Mock | 30% |
| Mission List | ✅ | ✅ | 🔴 Mock | 45% |
| Challenge (Kamera) | ✅ | 🔴 Bug mutation | 🔴 Mock | 25% |
| Crafting | ✅ | ⚠️ Bug minor | 🔴 Mock | 45% |
| Leaderboard | ✅ | ❌ Belum ada | 🔴 Mock | 20% |
| Profile | ❌ | ❌ | ❌ | 0% |
| Daily Login | ❌ | ❌ | ❌ | 0% |
| Badge | ❌ | ❌ | ❌ | 0% |

---

## Known Issues

| ID | Severity | Status | File | Deskripsi |
|----|----------|--------|------|-----------|
| BUG-01 | 🔴 Critical | Closed | `challenge_view_model.dart` | State mutation langsung |
| BUG-02 | 🔴 Critical | Closed | `auth_view_model.dart` | Mock bypass login |
| BUG-03 | 🟠 High | Closed | `user_model.dart` | Semua field non-final |
| BUG-04 | 🟠 High | Closed | `challenge_view_model.dart` | Import cross-ViewModel |
| BUG-05 | 🟡 Medium | Closed | `crafting_view_model.dart` | `userServiceProvider` salah tempat |
| BUG-06 | 🟡 Medium | Closed | `models/*.dart` | Semua model belum `@freezed` |
| BUG-07 | 🟡 Medium | Closed | `challenge_view_model.dart` | `image_picker` harus diganti `camera` |
