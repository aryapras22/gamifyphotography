# system-state.md — GamifyPhotography

> Update file ini setiap kali ada perubahan signifikan pada codebase.
> **Terakhir diperbarui:** 2026-05-02 (Sprint UI/UX: 3-tab Integration)

---

## Struktur Folder Saat Ini

```
lib/
├── app/
│   ├── app.dart               ✅ Entry point, AppTheme.lightTheme
│   └── routes.dart            ✅ Route MVP + Custom Transitions
├── core/                      ✅ [BARU] Design System tokens
│   ├── app_colors.dart        ✅ AppColors
│   ├── app_text_styles.dart   ✅ AppTextStyles (Nunito)
│   └── app_theme.dart         ✅ AppTheme (Material 3)
├── models/
│   ├── user_model.dart        ✅ @freezed
│   ├── badge_model.dart       ✅ @freezed
│   ├── challenge_model.dart   ✅ @freezed
│   ├── module_model.dart      ✅ @freezed
│   └── leaderboard_model.dart ✅ @freezed
├── providers/
│   └── service_providers.dart ✅ Centralized
├── services/
│   ├── auth_service.dart          🔴 Mock
│   ├── badge_service.dart         ✅ 5 badge, mock logic
│   ├── challenge_service.dart     🔴 Mock
│   ├── daily_login_service.dart   ✅ In-memory mock
│   ├── module_service.dart        ✅ Mock data 10 misi
│   └── user_service.dart          🔴 Mock
├── view_models/
│   ├── auth_view_model.dart           ✅ OK
│   ├── badge_view_model.dart          ✅ OK
│   ├── challenge_view_model.dart      ✅ OK
│   ├── daily_login_view_model.dart    ✅ OK
│   ├── home_view_model.dart           ✅ OK
│   ├── leaderboard_view_model.dart    ✅ OK
│   ├── profile_view_model.dart        ✅ OK
│   └── progress_view_model.dart       ✅ OK
└── views/
    ├── home/
    │   ├── main_layout_view.dart   ✅ 3 Tab (Home, Peringkat, Profil)
    │   ├── home_view.dart          ✅ Gamifikasi Dashboard + Integrated Missions
    │   └── daily_login_view.dart   ✅ OK
    ├── leaderboard/ ✅ leaderboard_view (Design System polished)
    ├── mission/
    │   ├── custom_camera_view.dart    ✅ Camera HUD Polish (floating close, shutter 80dp)
    │   └── feedback_view.dart         ✅ Redesign Reward (rolling points, photo preview)
    ├── onboarding/  ✅ onboarding_view (3-slide carousel)
    ├── profile/     ✅ profile_view (Rolling counter, design polished)
    └── widgets/     ✅ badge_unlock_sheet, animated_3d_button, dll
```

---

## Status Kesiapan per Fitur

| Fitur | View | ViewModel | Service | Kesiapan |
|-------|------|-----------|---------|----------|
| Onboarding | ✅ 3-slide carousel | ✅ | — | 100% |
| Home Dashboard | ✅ Integrated Missions | ✅ | ✅ | 95% |
| Challenge (Kamera) | ✅ HUD Polish | ✅ | 🔴 Mock | 90% |
| Feedback | ✅ Reward Screen | ✅ | ✅ | 90% |
| Leaderboard | ✅ Design System | ✅ | 🔴 Mock | 85% |
| Profile | ✅ Design System | ✅ | ✅ | 90% |
| **Design System** | ✅ Centralized | — | — | 100% |

---

## Catatan Arsitektur Terkini

- **Design System**: Menggunakan `Nunito` via `google_fonts`. Warna primer `#1CB0F6` (brandBlue).
- **Navigation**: Menggunakan `go_router` dengan custom transitions (Fade/Slide). Tab bar dibatasi menjadi 3 item (Home, Peringkat, Profil).
- **Home View**: Menjadi dashboard utama yang mengintegrasikan alur misi (S-curve path) langsung di dalam layar beranda, di bawah header dashboard.
- **Badge System**: Terintegrasi di `FeedbackView` dengan bottom sheet animasi saat unlock.
- **Animations**: Menggunakan `TweenAnimationBuilder` untuk rolling counter poin di Feedback dan Profile.
- **ModuleModel** menggunakan field `materialContent` (bukan `whenToUse`/`howToUse` seperti di tech-design lama) — sudah sesuai dengan implementasi `module_service.dart`
- **ChallengeView** menggunakan pola: buka `CustomCameraView` via `Navigator.push`, menerima `XFile` via pop, lalu upload foto → tampilkan preview → user tap "CEK HASIL" → completeChallenge() → navigate ke feedback (kembali ke Home).
- **BadgeModel** menggunakan field `iconPath` (bukan `svgPath`) — semua badge service dan view sudah menggunakan field yang benar
- **build_runner** sudah dijalankan, semua `.freezed.dart` dan `.g.dart` sudah ter-generate
