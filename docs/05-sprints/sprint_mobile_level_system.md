# Sprint: Perombakan Sistem Level & Quiz Evaluasi
**Repo:** `aryapras22/gamifyphotography` (Flutter Mobile App)
**Tanggal Sprint:** 25 Mei 2026
**Status:** 🆕 Baru

---

## 🎯 Tujuan Sprint

Mengubah sistem level dari yang sebelumnya hanya berisi materi, menjadi sistem level 1–25 yang terintegrasi dengan **Quiz Evaluasi** sebagai checkpoint wajib di Level 10, 15, 20, dan 25. User harus lulus minimal **70%** untuk dapat melanjutkan ke level berikutnya.

---

## 📋 Struktur Level Baru (Referensi)

| Level | Nama | Jenis |
|-------|------|-------|
| 1–9 | Rule of Thirds → Reflection/Mirror | Materi |
| **10** | **Quiz: Triangle Exposure I** | **Quiz Evaluasi ⚠️** |
| 11–14 | Golden Ratio → Fill the Frame | Materi |
| **15** | **Quiz: Lighting I** | **Quiz Evaluasi ⚠️** |
| 16–19 | Silhouette → Color Contrast | Materi |
| **20** | **Quiz: Triangle Exposure II** | **Quiz Evaluasi ⚠️** |
| 21–24 | Sense of Scale → L-Shape Composition | Materi |
| **25** | **Quiz: Pencahayaan II** | **Quiz Evaluasi + Post Test Trigger ⚠️** |

> **Pretest** → Muncul otomatis setelah user menyelesaikan Level 1
> **Post Test** → Muncul setelah crafting jembatan selesai (5000 XP)

---

## 📌 Task List

---

### TASK-01 · Buat Model & Data Level Baru
**Prioritas:** 🔴 Tinggi — Blocker untuk semua task lain
**File terdampak:**
- `lib/models/` → tambah model baru
- `lib/core/` → tambah konstanta/data level

**Deskripsi:**
Buat representasi data untuk dua tipe level:
1. `LevelModel` untuk level materi (tipe: `materi`) dengan field `page1Content` dan `page2Content`
2. `QuizLevelModel` untuk level quiz (tipe: `quiz`) dengan field `questions`, `passingScore` (default 70)

```dart
// Contoh struktur
enum LevelType { materi, quiz }

class LevelConfig {
  final int levelNumber;
  final String title;
  final LevelType type;
  // ...
}
```

**Acceptance Criteria:**
- [ ] `LevelType` enum tersedia (`materi`, `quiz`)
- [ ] Model level materi memiliki `page1` dan `page2`
- [ ] Model level quiz memiliki list soal dan `passingScore = 70`
- [ ] Data 25 level dapat di-load dari file konstanta lokal

---

### TASK-02 · Hardcode Konten 25 Level Materi
**Prioritas:** 🔴 Tinggi
**File terdampak:**
- `lib/core/` → buat file `level_content_data.dart`

**Deskripsi:**
Masukkan semua konten dari Excel ke dalam file konstanta Dart. Setiap level materi memiliki dua page:
- **Page 1**: Pengertian + keterangan referensi foto
- **Page 2**: Kapan digunakan + Cara menggunakan

Untuk **level quiz (10, 15, 20, 25)**, konten soal bersifat hardcoded dengan gambar (sesuai kesepakatan, sama seperti misi).

**Level Materi yang perlu diisi:** 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 16, 17, 18, 19, 21, 22, 23, 24, 25

**Acceptance Criteria:**
- [ ] Semua 21 level materi memiliki `page1` dan `page2` terisi
- [ ] Soal quiz di level 10, 15, 20 sudah ada struktur datanya (gambar bisa placeholder dulu)
- [ ] Data dapat diakses via konstanta statik

---

### TASK-03 · Update Progress Screen: Tampilan 25 Level
**Prioritas:** 🔴 Tinggi
**File terdampak:**
- `lib/views/progress/` → update tampilan daftar level

**Deskripsi:**
Tampilan daftar level perlu diperbarui untuk membedakan dua tipe:
- **Level Materi**: tampil seperti biasa (card dengan nama materi)
- **Level Quiz**: tampil dengan badge/ikon khusus (misal: 🏆 atau ikon soal), warna berbeda (misalnya kuning/oranye sebagai penanda checkpoint)

State level:
- `locked` → icon gembok, tidak bisa diklik
- `available` → bisa diklik
- `completed_pass` → centang hijau (quiz: lulus ≥70%)
- `completed_fail` → tanda silang merah + tombol retry (quiz: gagal <70%)

**Acceptance Criteria:**
- [ ] Level 1–25 tampil di progress screen
- [ ] Visual quiz level (10, 15, 20, 25) berbeda dari level materi
- [ ] State `locked`, `available`, `completed` ter-render dengan benar
- [ ] Level berikutnya ter-lock jika level quiz sebelumnya belum lulus

---

### TASK-04 · Buat Level Detail Screen (2-Page Materi)
**Prioritas:** 🔴 Tinggi
**File terdampak:**
- `lib/views/progress/` → buat `level_detail_view.dart` (atau update yang sudah ada)

**Deskripsi:**
Layar detail level materi memiliki **2 halaman** yang bisa di-swipe/navigasi:
- **Page 1**: Judul level, deskripsi/pengertian, referensi foto (dengan tombol "Klik" untuk buka foto)
- **Page 2**: "Kapan Digunakan" + "Cara Menggunakan"

Navigasi antar page bisa pakai `PageView` atau `TabBar`.

**Acceptance Criteria:**
- [ ] Level detail menampilkan Page 1 dan Page 2
- [ ] Swipe/tap next bisa pindah ke Page 2
- [ ] Tombol referensi foto berfungsi (buka gambar/URL)
- [ ] Tombol "Selesai" di Page 2 menandai level sebagai completed dan unlock level berikutnya

---

### TASK-05 · Buat Quiz Level Screen
**Prioritas:** 🔴 Tinggi
**File terdampak:**
- `lib/views/` → buat folder baru `lib/views/quiz/`
  - `quiz_level_view.dart`
  - `quiz_result_view.dart`

**Deskripsi:**
Layar untuk mengerjakan quiz evaluasi di level 10, 15, 20, 25. Soal menggunakan gambar (hardcoded).

**Alur Quiz:**
1. Intro screen → tampilkan nama quiz + jumlah soal
2. Soal satu per satu (dengan gambar + 4 pilihan jawaban A/B/C/D)
3. Setelah semua soal → tampil **Result Screen**

**Result Screen:**
- Tampilkan skor: `X / 100` (25 soal × 4 poin)
- Status: ✅ **Lulus** (≥70 / 70%) atau ❌ **Gagal** (<70)
- Jika lulus → tombol "Lanjut ke Level Berikutnya"
- Jika gagal → tombol "Coba Lagi" (quiz bisa diulang)

**Acceptance Criteria:**
- [ ] Quiz menampilkan soal dengan gambar (hardcoded)
- [ ] Skor dihitung: jumlah benar × 4
- [ ] Passing score = 70 (dari 100)
- [ ] Result screen tampil dengan status lulus/gagal
- [ ] Jika lulus, level quiz ter-unlock dan level berikutnya bisa diakses
- [ ] Jika gagal, user bisa retry tanpa batas

---

### TASK-06 · Update `UserModel`: Field Progress Level Baru
**Prioritas:** 🔴 Tinggi
**File terdampak:**
- `lib/models/user_model.dart` (atau file model user yang ada)
- `lib/services/` → update Firestore service

**Deskripsi:**
Tambahkan field baru di model user untuk menyimpan progress level 1–25 yang baru:

```dart
// Field yang perlu ditambahkan/diupdate di UserModel
int currentLevel;           // Level yang sedang dibuka (1-25)
List<int> completedLevels;  // List nomor level yang sudah selesai
Map<int, int> quizScores;   // {levelNumber: score} untuk level quiz
bool pretestDone;           // Apakah pretest sudah dikerjakan
bool posttestDone;          // Apakah posttest sudah dikerjakan
```

**Acceptance Criteria:**
- [ ] `UserModel` memiliki field `completedLevels` dan `quizScores`
- [ ] `quizScores` menyimpan skor per level quiz
- [ ] Progress tersimpan ke Firestore saat level/quiz selesai
- [ ] `pretestDone` dan `posttestDone` tersimpan di Firestore

---

### TASK-07 · Logic Gate: Level Lock/Unlock Berdasarkan Quiz
**Prioritas:** 🔴 Tinggi
**File terdampak:**
- `lib/view_models/` → buat atau update `level_view_model.dart`
- `lib/providers/` → update provider terkait

**Deskripsi:**
Implementasi logika lock/unlock level:

```
Level 1 → selesai → pretest muncul → Level 2 unlock
Level 2-9 → selesai → level berikutnya unlock
Level 9 selesai → Level 10 (Quiz) unlock
Level 10 Quiz → LULUS (≥70) → Level 11 unlock
Level 10 Quiz → GAGAL → Level 11 TETAP LOCK, retry quiz
...dst (sama untuk level 15, 20, 25)
```

**Acceptance Criteria:**
- [ ] Level 2–9 unlock secara berurutan setelah level sebelumnya selesai
- [ ] Level 11 hanya unlock jika level 10 quiz lulus
- [ ] Level 16 hanya unlock jika level 15 quiz lulus
- [ ] Level 21 hanya unlock jika level 20 quiz lulus
- [ ] Level setelah 25 (jembatan) hanya unlock jika level 25 quiz lulus
- [ ] Logic dapat ditestkan via unit test

---

### TASK-08 · Pretest: Trigger Setelah Selesai Level 1
**Prioritas:** 🟡 Medium
**File terdampak:**
- `lib/views/progress/level_detail_view.dart`
- `lib/views/quiz/` → reuse komponen quiz jika memungkinkan
- `lib/core/` → buat `pretest_questions.dart`

**Deskripsi:**
Setelah user menyelesaikan Level 1 (menekan tombol "Selesai" di Page 2), tampilkan **Pretest** sebelum Level 2 di-unlock.

- Soal pretest: 25 soal dengan gambar (hardcoded, dari Google Forms Affan)
- Scoring: 25 soal × 4 poin = max 100
- Pretest **tidak memiliki passing score** — user wajib mengerjakan tapi tidak harus lulus
- Hasil tersimpan di Firestore (`quiz_results` collection) untuk dilihat admin
- Setelah pretest selesai (apapun skornya) → Level 2 unlock

**Acceptance Criteria:**
- [ ] Setelah Level 1 selesai, pretest muncul otomatis (tidak bisa di-skip)
- [ ] Soal 25 item dengan gambar ter-render
- [ ] Skor tersimpan ke Firestore dengan `userId`, `type: "pretest"`, `score`, `answers`, `timestamp`
- [ ] Level 2 unlock setelah pretest selesai (bukan setelah lulus)
- [ ] Pretest hanya muncul sekali (`pretestDone = true` setelahnya)

---

### TASK-09 · Posttest: Trigger Setelah Crafting Jembatan Selesai
**Prioritas:** 🟡 Medium
**File terdampak:**
- `lib/views/crafting/` → tambah trigger posttest
- Reuse komponen quiz dari TASK-08

**Deskripsi:**
Setelah user menyelesaikan crafting jembatan (XP mencapai 5000), tampilkan **Post Test** sebelum masuk ke layar result crafting.

- Soal posttest: **sama persis** dengan pretest (25 soal gambar yang sama)
- Reuse file `pretest_questions.dart`
- Hasil tersimpan di Firestore (`quiz_results`) dengan `type: "posttest"`
- Tidak ada passing score untuk posttest

**Acceptance Criteria:**
- [ ] Setelah crafting selesai (5000 XP), posttest muncul otomatis
- [ ] Soal sama dengan pretest
- [ ] Skor tersimpan ke Firestore dengan `type: "posttest"`
- [ ] Posttest hanya muncul sekali (`posttestDone = true`)
- [ ] Setelah posttest, layar result crafting / completion muncul

---

### TASK-10 · Update Firestore Rules: Koleksi `quiz_results`
**Prioritas:** 🔴 Tinggi
**File terdampak:**
- `firestore.rules`

**Deskripsi:**
Tambahkan rule untuk koleksi `quiz_results` yang akan menyimpan hasil pretest, posttest, dan quiz evaluasi:

```
/quiz_results/{docId}
  - user hanya bisa write data miliknya sendiri
  - admin bisa read semua data
  - user bisa read data miliknya sendiri
```

**Acceptance Criteria:**
- [ ] User bisa write ke `quiz_results` untuk data dengan `userId` miliknya
- [ ] User bisa read hasil quiz miliknya
- [ ] Firestore rules di-deploy dan tidak ada error

---

## 🔗 Dependency Antar Task

```
TASK-01 (Model)
    └──▶ TASK-02 (Konten Data)
    └──▶ TASK-06 (UserModel Update)
              └──▶ TASK-07 (Logic Gate)
                        └──▶ TASK-03 (Progress Screen)
                        └──▶ TASK-04 (Level Detail Screen)
                        └──▶ TASK-05 (Quiz Screen)
                        └──▶ TASK-08 (Pretest)
                        └──▶ TASK-09 (Posttest)
TASK-10 (Firestore Rules) — bisa paralel, tapi harus selesai sebelum TASK-08/09 di-test
```

---

## 📦 Struktur File Baru yang Akan Dibuat

```
lib/
├── core/
│   ├── level_content_data.dart       ← konten 25 level (TASK-02)
│   └── pretest_questions.dart        ← soal pretest & posttest (TASK-08)
├── models/
│   └── level_model.dart              ← LevelConfig, LevelType (TASK-01)
├── view_models/
│   └── level_view_model.dart         ← logic lock/unlock (TASK-07)
└── views/
    └── quiz/                         ← folder baru (TASK-05)
        ├── quiz_level_view.dart
        └── quiz_result_view.dart
```

---

## ✅ Definition of Done

- [ ] Semua 25 level tampil di progress screen dengan tipe yang benar
- [ ] Level quiz (10, 15, 20, 25) memiliki tampilan berbeda dari level materi
- [ ] Sistem lock/unlock berjalan sesuai aturan (quiz harus lulus ≥70% untuk unlock)
- [ ] Pretest muncul otomatis setelah Level 1, tidak bisa di-skip, hasil tersimpan
- [ ] Posttest muncul otomatis setelah crafting selesai, hasil tersimpan
- [ ] Semua hasil quiz tersimpan di Firestore koleksi `quiz_results`
- [ ] Firestore rules sudah di-update dan di-deploy
- [ ] Tidak ada breaking change pada fitur yang sudah ada (crafting, misi, lencana, daily login)

---

*Sprint doc dibuat: 25 Mei 2026 | Repo: [gamifyphotography](https://github.com/aryapras22/gamifyphotography)*
