# Sprint: Fitur Baru — GamifyPhotography (Flutter App)

> **Repo:** [aryapras22/gamifyphotography](https://github.com/aryapras22/gamifyphotography)  
> **Platform:** Flutter (Android)  
> **Sprint Goal:** Implementasi Pretest/Posttest, visual Crafting Jembatan, dan penyempurnaan fitur gamifikasi

---

## 🗂️ Daftar Tugas

---

### 1. Pretest — Gate Sebelum Level 2

**Deskripsi:**  
User harus mengerjakan pretest sebelum bisa membuka Level 2. Pretest berisi 25 soal pilihan ganda bergambar, hardcoded di dalam app (tidak dari Firestore). Setiap soal bernilai 4 poin (total max = 100).

**File yang perlu dibuat/diubah:**
- `lib/views/quiz/pretest_screen.dart` ← baru
- `lib/view_models/quiz_view_model.dart` ← baru
- `lib/services/quiz_service.dart` ← baru (simpan hasil ke Firestore)
- `lib/core/data/pretest_questions.dart` ← baru (hardcoded soal + gambar)
- `lib/views/mission/` ← modifikasi logika buka Level 2

**Alur:**
1. User tap Level 2 di halaman mission
2. Cek apakah user sudah mengerjakan pretest (`users/{uid}.pretestDone == true`)
3. Jika belum → arahkan ke `PretestScreen`
4. Tampilkan 25 soal satu per satu dengan gambar (assets lokal)
5. Hitung skor: `jumlah_benar × 4`
6. Simpan hasil ke Firestore:
   ```
   quiz_results/{uid}_pretest
   {
     userId: uid,
     type: 'pretest',
     score: int,
     answers: List<int>,        // index jawaban yang dipilih per soal
     submittedAt: Timestamp
   }
   ```
7. Update field `users/{uid}.pretestDone = true`
8. Redirect ke Level 2

**Kriteria Selesai:**
- [ ] Soal muncul dengan gambar lokal
- [ ] Skor dihitung dan disimpan ke Firestore
- [ ] Level 2 hanya bisa dibuka setelah pretest selesai
- [ ] Tidak bisa mengulang pretest

---

### 2. Posttest — Muncul Setelah Crafting Jembatan Selesai

**Deskripsi:**  
Posttest muncul otomatis ketika user mencapai 5000 XP crafting (jembatan selesai). Soal sama dengan pretest (hardcoded, 25 soal bergambar).

**File yang perlu dibuat/diubah:**
- `lib/views/quiz/posttest_screen.dart` ← baru
- `lib/views/crafting/` ← tambahkan trigger posttest saat XP = 5000
- `lib/services/quiz_service.dart` ← tambahkan method savePosttest()

**Alur:**
1. Saat XP crafting mencapai 5000 → tampilkan dialog "Jembatan selesai!"
2. Setelah dialog ditutup → arahkan ke `PosttestScreen`
3. Tampilkan 25 soal yang sama dengan pretest
4. Hitung skor: `jumlah_benar × 4`
5. Simpan ke Firestore:
   ```
   quiz_results/{uid}_posttest
   {
     userId: uid,
     type: 'posttest',
     score: int,
     answers: List<int>,
     submittedAt: Timestamp
   }
   ```
6. Update `users/{uid}.posttestDone = true`

**Kriteria Selesai:**
- [ ] Posttest hanya muncul sekali (cek `posttestDone`)
- [ ] Hasil disimpan dengan benar ke Firestore
- [ ] Skor ditampilkan ke user di akhir

---

### 3. Visual Crafting Jembatan — 3 Milestone Progress

**Deskripsi:**  
Tampilan halaman crafting berubah secara visual berdasarkan total XP yang terkumpul, dengan 3 tahap milestone jembatan.

**File yang perlu diubah:**
- `lib/views/crafting/` ← update UI widget jembatan

**Milestone visual:**

| XP | Visual |
|----|--------|
| 0–999 | Jembatan belum dimulai (pondasi/tanah kosong) |
| 1000–1999 | Jembatan berprogres tahap 1 |
| 2000–4999 | Jembatan berprogres tahap 2 |
| 5000 | Jembatan selesai + trigger posttest |

**Implementasi:**
- Gunakan `Stack` + conditional `Image.asset()` berdasarkan nilai XP
- Tambahkan animasi progress bar dari XP saat ini ke total 5000
- Sumber gambar: `assets/crafting/bridge_stage_0.png`, `bridge_stage_1.png`, `bridge_stage_2.png`, `bridge_stage_3.png`

**Kriteria Selesai:**
- [ ] Visual berubah sesuai milestone XP
- [ ] Progress bar menunjukkan XP / 5000
- [ ] Animasi transisi saat naik milestone
- [ ] Total XP crafting = 5000

---

### 4. Daily Login — Simpan ke Firestore

**Deskripsi:**  
Service `daily_login_service.dart` sudah ada. Pastikan setiap login harian menyimpan timestamp ke Firestore agar bisa dibaca admin.

**File yang perlu diubah:**
- `lib/services/daily_login_service.dart` ← pastikan menyimpan ke subcollection

**Struktur Firestore yang harus ada:**
```
users/{uid}/daily_logins/{tanggal}
{
  loginAt: Timestamp,
  streak: int
}
```
> Jika sudah tersimpan di root document `users/{uid}` sebagai array/field, pastikan admin bisa membacanya.

**Kriteria Selesai:**
- [ ] Setiap login harian tercatat di Firestore
- [ ] Data bisa dibaca dari admin panel

---

### 5. Update Firestore Rules — Koleksi Quiz Results

**Deskripsi:**  
Tambahkan rules untuk koleksi `quiz_results` yang baru.

**Tambahan di `firestore.rules`:**
```js
match /quiz_results/{docId} {
  allow read: if isAuthenticated()
    && (resource.data.userId == request.auth.uid || isAdmin());
  allow create: if isAuthenticated()
    && request.resource.data.userId == request.auth.uid;
  allow update: if false;
  allow delete: if false;
}
```

**Kriteria Selesai:**
- [ ] User hanya bisa baca hasil milik sendiri
- [ ] Admin bisa baca semua hasil
- [ ] Tidak bisa diupdate setelah submit

---

### 6. Update Model User

**Deskripsi:**  
Tambahkan field baru ke `UserModel` untuk tracking status pretest/posttest.

**File:** `lib/models/user_model.dart`

**Field baru:**
```dart
final bool pretestDone;
final bool posttestDone;
```

Jalankan `build_runner` setelah update:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Kriteria Selesai:**
- [ ] Field `pretestDone` dan `posttestDone` ada di model
- [ ] File `.freezed.dart` dan `.g.dart` sudah di-generate ulang

---

## 📦 Struktur File Baru

```
lib/
├── core/
│   └── data/
│       └── pretest_questions.dart       ← hardcoded 25 soal + gambar
├── services/
│   └── quiz_service.dart                ← simpan hasil pretest/posttest
├── view_models/
│   └── quiz_view_model.dart             ← state management quiz
└── views/
    └── quiz/
        ├── pretest_screen.dart
        ├── posttest_screen.dart
        └── quiz_question_widget.dart    ← widget soal reusable

assets/
└── crafting/
    ├── bridge_stage_0.png
    ├── bridge_stage_1.png
    ├── bridge_stage_2.png
    └── bridge_stage_3.png
```

---

## ⚠️ Catatan Penting

- **Soal pretest/posttest hardcoded** — tidak bisa diubah dari admin. Pastikan soal diterima dari Affan sebelum memulai task ini.
- **Gambar soal disimpan lokal** di `assets/` — daftarkan semua di `pubspec.yaml` bagian `flutter.assets`.
- Gunakan **Freezed** sesuai pola model yang sudah ada di repo saat membuat model baru.
- Test di device fisik untuk memastikan gambar soal tampil dengan benar.

