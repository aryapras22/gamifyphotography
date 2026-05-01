# feature-spec.md — Badge System

## Deskripsi Fitur

Sistem penghargaan otomatis. Badge diberikan satu kali saat kondisi terpenuhi.
Setiap badge memberikan +100 poin bonus.

---

## Daftar Badge

| ID | Nama | Trigger | Poin |
|----|------|---------|------|
| B01 | 🌱 Badge Starter | Menyelesaikan misi pertama | +100 |
| B02 | 🥉 Badge Rookie | Mencapai level 15 | +100 |
| B03 | 🏆 Badge Veteran | Mencapai level 30 | +100 |
| B04 | ⭐ Badge Special Mission | Menyelesaikan special misi di level 10 | +100 |
| B05 | 🔥 Badge Survivor | Menyelesaikan 7-day login streak | +100 |

---

## Business Rules

- Setiap badge hanya diberikan **satu kali** (idempoten)
- Pemberian badge bersifat **otomatis** (triggered, bukan manual)
- Saat badge diperoleh: tampilkan **dialog selebrasi** + +100 poin
- Badge yang belum diperoleh tampil **abu-abu** di halaman Profile

---

## Trigger Points (di mana badge dicek)

| Badge | Cek Setelah |
|-------|-------------|
| Starter | `ChallengeViewModel.submitPhoto()` berhasil pertama kali |
| Rookie | `UserModel.level` berubah → cek apakah level >= 15 |
| Veteran | `UserModel.level` berubah → cek apakah level >= 30 |
| Special Mission | `ChallengeViewModel.submitPhoto()` pada misi bertipe "special" |
| Survivor | `DailyLoginViewModel.claimDaily()` saat streak = 7 |

---

## dev-tasks.md — Badge System

| ID | Task | Estimasi | Status |
|----|------|----------|--------|
| TASK-B01 | Tambah field `earnedBadges: List<String>` ke `UserModel` | 20 mnt | ⏳ |
| TASK-B02 | Buat `BadgeService`: `checkAndAwardBadge(userId, badgeId)` | 30 mnt | ⏳ |
| TASK-B03 | Buat `BadgeViewModel` + trigger dari ChallengeVM dan DailyLoginVM | 45 mnt | ⏳ |
| TASK-B04 | Buat `BadgeDialog` widget: animasi Lottie + nama badge + +100 poin | 45 mnt | ⏳ |
| TASK-B05 | Integrasikan badge check di semua trigger point yang relevan | 30 mnt | ⏳ |
