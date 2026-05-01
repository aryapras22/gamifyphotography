# dev-tasks.md — Mission (Core)

> Setiap task dirancang selesai dalam 30–60 menit coding bersama AI.
> Update kolom Status setiap kali task selesai.

---

## Phase 0: Critical Fixes (Kerjakan Dulu!)

| ID | Task | Estimasi | Status |
|----|------|----------|--------|
| TASK-M01 | Buat `lib/providers/service_providers.dart` dengan semua service provider | 30 mnt | ⏳ |
| TASK-M02 | Konversi `ModuleModel` ke `@freezed` + jalankan `build_runner` | 30 mnt | ⏳ |
| TASK-M03 | Konversi `ChallengeModel` ke `@freezed` + jalankan `build_runner` | 30 mnt | ⏳ |
| TASK-M04 | Refactor `ChallengeViewModel`: hapus mutasi langsung, pakai `copyWith` | 45 mnt | ⏳ |
| TASK-M05 | Ganti `image_picker` → `camera` package di `ChallengeView` + `ChallengeViewModel` | 60 mnt | ⏳ |

## Phase 1: Mission Flow

| ID | Task | Estimasi | Status |
|----|------|----------|--------|
| TASK-M06 | Buat `MissionState` dengan field: `modules`, `isLoading`, `errorMessage` | 30 mnt | ⏳ |
| TASK-M07 | Implementasi `ModuleService.getModules()` dengan mock data 10 misi | 45 mnt | ⏳ |
| TASK-M08 | Sambungkan `MissionViewModel` ke `ModuleService` via `moduleServiceProvider` | 30 mnt | ⏳ |
| TASK-M09 | Update `ModuleListView`: tampilkan loading skeleton + error state | 30 mnt | ⏳ |
| TASK-M10 | Update `ModuleDetailView`: PageView 2 halaman (Teori + Visual Guide) | 45 mnt | ⏳ |

## Phase 2: Challenge & Submit

| ID | Task | Estimasi | Status |
|----|------|----------|--------|
| TASK-M11 | Buat `ChallengeState` yang immutable dengan `@freezed` | 30 mnt | ⏳ |
| TASK-M12 | Implementasi kamera di `ChallengeView` menggunakan `camera` package | 60 mnt | ⏳ |
| TASK-M13 | Implementasi preview foto + tombol Retake/Submit | 30 mnt | ⏳ |
| TASK-M14 | Implementasi `ChallengeService.uploadPhoto()` (mock: kembalikan dummy URL) | 30 mnt | ⏳ |
| TASK-M15 | Implementasi `ChallengeService.completeChallenge()` + update poin user | 45 mnt | ⏳ |
| TASK-M16 | Implementasi `FeedbackView`: animasi Lottie + display poin diperoleh | 30 mnt | ⏳ |

## Phase 3: Polish

| ID | Task | Estimasi | Status |
|----|------|----------|--------|
| TASK-M17 | Tandai misi selesai di `ModuleListView` (centang + non-interaktif) | 20 mnt | ⏳ |
| TASK-M18 | Handle edge case: izin kamera ditolak → dialog ke Settings | 30 mnt | ⏳ |
| TASK-M19 | Handle edge case: upload gagal → snackbar + retry | 30 mnt | ⏳ |
| TASK-M20 | Kompresi foto otomatis jika >5MB sebelum upload | 30 mnt | ⏳ |
