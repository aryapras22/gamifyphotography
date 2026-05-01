# dev-tasks.md — Daily Login

| ID | Task | Estimasi | Status |
|----|------|----------|--------|
| TASK-DL01 | Tambah field `currentStreak`, `lastLoginDate`, `streakDays` ke `UserModel` | 30 mnt | ⏳ |
| TASK-DL02 | Buat `DailyLoginService`: `canClaim()`, `claimDaily()`, `getStreakStatus()` | 45 mnt | ⏳ |
| TASK-DL03 | Buat `DailyLoginViewModel` (StateNotifier) dengan state: streak, isLoading | 30 mnt | ⏳ |
| TASK-DL04 | Buat `DailyLoginPopup` widget: 7 kotak hari + tombol Claim | 45 mnt | ⏳ |
| TASK-DL05 | Integrasikan popup di `MainLayoutView`: cek dan tampilkan saat app start | 30 mnt | ⏳ |
| TASK-DL06 | Logic streak reset: bandingkan `lastLoginDate` dengan hari ini | 30 mnt | ⏳ |
| TASK-DL07 | Trigger badge Survivor saat streak mencapai 7 | 20 mnt | ⏳ |
