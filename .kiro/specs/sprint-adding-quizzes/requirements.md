# Requirements: Sprint Adding Quizzes

## Overview
Implementasi fitur Pretest/Posttest, visual Crafting Jembatan berbasis milestone XP, penyempurnaan Daily Login ke Firestore, update Firestore Rules, dan update UserModel.

---

## R1 — Pretest Gate Sebelum Level 2

### R1.1 — Cek Status Pretest Saat User Tap Level 2
**User Story:** Sebagai user, ketika saya mengetuk modul Level 2 di halaman home, sistem harus mengecek apakah saya sudah mengerjakan pretest sebelum membuka detail modul.

**Acceptance Criteria:**
- AC1.1.1: Ketika user mengetuk modul dengan `order == 2` dan `users/{uid}.pretestDone == false` (atau field belum ada), sistem mengarahkan ke `PretestScreen` bukan ke `/mission/detail`.
- AC1.1.2: Ketika user mengetuk modul dengan `order == 2` dan `users/{uid}.pretestDone == true`, sistem melanjutkan ke `/mission/detail` seperti biasa.
- AC1.1.3: Modul dengan `order != 2` tidak terpengaruh oleh logika pretest.

### R1.2 — Tampilan Pretest Screen
**User Story:** Sebagai user, saya ingin melihat soal pretest satu per satu dengan gambar agar bisa menjawab dengan fokus.

**Acceptance Criteria:**
- AC1.2.1: `PretestScreen` menampilkan 25 soal pilihan ganda satu per satu.
- AC1.2.2: Setiap soal menampilkan gambar dari asset lokal (`assets/images/quiz/`).
- AC1.2.3: Setiap soal memiliki 4 pilihan jawaban (A, B, C, D).
- AC1.2.4: User tidak bisa melewati soal tanpa memilih jawaban.
- AC1.2.5: Terdapat indikator progres (misal: "Soal 3 / 25").
- AC1.2.6: Setelah soal terakhir dijawab, tampilkan ringkasan skor sebelum submit.

### R1.3 — Penyimpanan Hasil Pretest
**User Story:** Sebagai sistem, hasil pretest harus disimpan ke Firestore agar tidak bisa diulang dan bisa dibaca admin.

**Acceptance Criteria:**
- AC1.3.1: Skor dihitung sebagai `jumlah_benar × 4` (max 100).
- AC1.3.2: Hasil disimpan ke `quiz_results/{uid}_pretest` dengan struktur:
  ```
  { userId, type: 'pretest', score, answers: List<int>, submittedAt: Timestamp }
  ```
- AC1.3.3: Field `users/{uid}.pretestDone` di-set ke `true` setelah submit.
- AC1.3.4: Setelah submit berhasil, user diarahkan ke `/mission/detail` Level 2.
- AC1.3.5: Jika `pretestDone == true`, user tidak bisa mengakses `PretestScreen` lagi (redirect langsung ke Level 2).

---

## R2 — Posttest Setelah Crafting Jembatan Selesai

### R2.1 — Trigger Posttest Saat XP Crafting = 5000
**User Story:** Sebagai user, setelah jembatan selesai (XP crafting mencapai 5000), saya ingin mengerjakan posttest untuk mengukur kemajuan belajar saya.

**Acceptance Criteria:**
- AC2.1.1: Ketika `bridgeProgress` mencapai nilai yang setara dengan 5000 XP total crafting, sistem menampilkan dialog "Jembatan Selesai! 🎉".
- AC2.1.2: Setelah dialog ditutup, sistem mengarahkan ke `PosttestScreen`.
- AC2.1.3: Jika `users/{uid}.posttestDone == true`, posttest tidak ditampilkan lagi meski jembatan sudah selesai.

### R2.2 — Tampilan Posttest Screen
**User Story:** Sebagai user, saya ingin mengerjakan posttest dengan soal yang sama seperti pretest.

**Acceptance Criteria:**
- AC2.2.1: `PosttestScreen` menggunakan soal yang sama dengan pretest (25 soal dari `pretest_questions.dart`).
- AC2.2.2: Tampilan dan alur soal identik dengan `PretestScreen`.
- AC2.2.3: Skor ditampilkan di akhir sebelum submit.

### R2.3 — Penyimpanan Hasil Posttest
**Acceptance Criteria:**
- AC2.3.1: Hasil disimpan ke `quiz_results/{uid}_posttest` dengan struktur:
  ```
  { userId, type: 'posttest', score, answers: List<int>, submittedAt: Timestamp }
  ```
- AC2.3.2: Field `users/{uid}.posttestDone` di-set ke `true` setelah submit.
- AC2.3.3: Skor akhir ditampilkan ke user di halaman hasil.

---

## R3 — Visual Crafting Jembatan Berbasis Milestone XP

### R3.1 — Milestone Visual Berdasarkan XP
**User Story:** Sebagai user, saya ingin melihat visual jembatan berubah sesuai progres XP crafting saya agar termotivasi.

**Acceptance Criteria:**
- AC3.1.1: Visual jembatan berubah berdasarkan total XP crafting dengan 4 tahap:
  - 0–999 XP: `bridge_stage_0.png` (pondasi/tanah kosong)
  - 1000–1999 XP: `bridge_stage_1.png`
  - 2000–4999 XP: `bridge_stage_2.png`
  - 5000 XP: `bridge_stage_3.png` (jembatan selesai)
- AC3.1.2: Gambar dimuat dari `assets/crafting/` menggunakan `Image.asset()`.
- AC3.1.3: Transisi antar milestone menggunakan `AnimatedSwitcher` atau animasi fade.

### R3.2 — Progress Bar XP Crafting
**Acceptance Criteria:**
- AC3.2.1: Progress bar menampilkan `currentCraftingXP / 5000`.
- AC3.2.2: Target total XP crafting adalah 5000 (bukan 1000 seperti sebelumnya).
- AC3.2.3: Progress bar dianimasikan saat nilai XP berubah.

---

## R4 — Daily Login Tersimpan ke Firestore Subcollection

### R4.1 — Simpan Data Login Harian ke Subcollection
**User Story:** Sebagai admin, saya ingin bisa membaca riwayat login harian setiap user dari Firestore.

**Acceptance Criteria:**
- AC4.1.1: Setiap kali `claimDailyLogin()` berhasil, sistem menyimpan dokumen ke `users/{uid}/daily_logins/{tanggal}` dengan format tanggal `YYYY-MM-DD`.
- AC4.1.2: Dokumen berisi `{ loginAt: Timestamp, streak: int }`.
- AC4.1.3: Penyimpanan ke subcollection dilakukan bersamaan dengan update root document (tidak menggantikan).
- AC4.1.4: Jika dokumen untuk tanggal tersebut sudah ada, tidak ada duplikasi (idempotent).

---

## R5 — Update Firestore Rules untuk quiz_results

### R5.1 — Rules Koleksi quiz_results
**Acceptance Criteria:**
- AC5.1.1: User hanya bisa membaca dokumen `quiz_results` milik sendiri (`resource.data.userId == request.auth.uid`).
- AC5.1.2: Admin bisa membaca semua dokumen `quiz_results`.
- AC5.1.3: User hanya bisa membuat dokumen baru dengan `userId` milik sendiri.
- AC5.1.4: Update dan delete tidak diizinkan untuk siapapun.

---

## R6 — Update UserModel

### R6.1 — Tambah Field pretestDone dan posttestDone
**Acceptance Criteria:**
- AC6.1.1: `UserModel` memiliki field `@Default(false) bool pretestDone`.
- AC6.1.2: `UserModel` memiliki field `@Default(false) bool posttestDone`.
- AC6.1.3: File `user_model.freezed.dart` dan `user_model.g.dart` di-generate ulang dengan `build_runner`.
- AC6.1.4: Semua tempat yang membaca `UserModel` dari Firestore tetap kompatibel (field baru bersifat optional dengan default `false`).

---

## R7 — Data Soal Pretest/Posttest (Hardcoded)

### R7.1 — File pretest_questions.dart
**Acceptance Criteria:**
- AC7.1.1: File `lib/core/data/pretest_questions.dart` berisi 25 soal dengan struktur `QuizQuestion` (teks soal, path gambar, 4 pilihan, index jawaban benar).
- AC7.1.2: Gambar soal disimpan di `assets/images/quiz/` dan didaftarkan di `pubspec.yaml`.
- AC7.1.3: Soal bersifat hardcoded dan tidak bisa diubah dari admin panel.

> **Catatan:** Konten soal aktual (teks + gambar) diterima dari Affan. Implementasi menggunakan placeholder soal sampai konten diterima.

---

## R8 — Routing Quiz

### R8.1 — Route Baru untuk Pretest dan Posttest
**Acceptance Criteria:**
- AC8.1.1: Route `/quiz/pretest` terdaftar di `router.dart` dan mengarah ke `PretestScreen`.
- AC8.1.2: Route `/quiz/posttest` terdaftar di `router.dart` dan mengarah ke `PosttestScreen`.
- AC8.1.3: Kedua route hanya bisa diakses oleh user yang sudah login (mengikuti redirect logic yang sudah ada).
