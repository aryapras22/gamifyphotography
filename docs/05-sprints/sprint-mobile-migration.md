# Implementation Plan: Sprint Mobile — Migrasi Data ke Firestore

## Overview

Sprint ini memigrasikan aplikasi mobile dari **data hardcoded** ke **data dinamis dari
Firestore** sekaligus menyinkronkan model-model Flutter dengan perubahan schema yang
dilakukan di sprint admin (Sprint Admin CMS Fixes). Ada dua kategori pekerjaan:

**Kategori A — Model & Schema Sync** (harus selesai sebelum kategori lain):
Menyesuaikan `LevelModel`, `QuizQuestion`, `MateriContent` dengan field baru dari admin
(`referenceImageUrls[]`, `howToUseImageUrl`, `questionText`).

**Kategori B — Migrasi Service dari Hardcoded ke Firestore**:
Mengganti `LevelContentData` (hardcoded 71KB) dan `ModuleService` (hardcoded) dengan
panggilan Firestore yang sebenarnya. Setelah ini, semua konten level dan soal quiz
dikelola dari web admin.

**Kategori C — UI Adaptation**:
Mengupdate semua View yang saat ini masih membaca dari `LevelContentData` dan
`ModuleService` hardcoded agar membaca dari ViewModel yang sudah terhubung ke Firestore.

---

## Tasks

- [ ] TASK-M01 — Update `LevelModel` & model terkait untuk backward-compat dan field baru
  - Buka `lib/models/level_model.dart`
  - Update class `MateriContent`:
    - Tambah `final List<String> page1ImageUrls` (menggantikan `page1ImagePath` lama)
    - Tambah `final String? page2HowToUseImageUrl` (field baru dari admin FIX-02)
    - **Jangan hapus** `page1ImagePath` dulu — jadikan deprecated dengan `@Deprecated`
      agar tidak ada compile error sebelum semua View diupdate di TASK-M05
    - Tambah helper getter:
      ```dart
      // Backward-compat: gabungkan asset lama dan URL Firestore baru
      List<String> get allImageUrls {
        final urls = List<String>.from(page1ImageUrls);
        if (page1ImagePath != null && !urls.contains(page1ImagePath!)) {
          urls.insert(0, page1ImagePath!);
        }
        return urls;
      }
      ```
  - Update class `QuizQuestion`:
    - Tambah `final String? questionText` (field baru)
    - Ubah `imagePath` dari required ke optional (sudah optional, tidak perlu ubah)
    - Tambah static factory `QuizQuestion.fromFirestore(Map<String, dynamic> data)`:
      ```dart
      factory QuizQuestion.fromFirestore(Map<String, dynamic> data) {
        return QuizQuestion(
          question: data['questionText'] as String? ?? '',
          imagePath: data['questionImageUrl'] as String?,
          options: List<String>.from(data['options'] ?? []),
          correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
        );
      }
      ```
  - Tambah class baru `FirestoreLevel` (bukan mengganti `LevelConfig` agar tidak break):
    ```dart
    class FirestoreLevel {
      final String id;
      final int levelNumber;
      final String title;
      final LevelType type;
      final int order;
      final bool isActive;
      final int passingScore;
      final FirestorePage1? page1;
      final FirestorePage2? page2;
      ...
      factory FirestoreLevel.fromFirestore(String id, Map<String, dynamic> data) { ... }
    }

    class FirestorePage1 {
      final String description;
      final List<String> referenceImageUrls; // FIX-01: array
      // backward-compat: jika Firestore masih kirim referenceImageUrl (singular)
      static List<String> _parseUrls(Map<String, dynamic> data) {
        final arr = data['referenceImageUrls'];
        if (arr != null) return List<String>.from(arr);
        final single = data['referenceImageUrl'] as String?;
        return single != null ? [single] : [];
      }
    }

    class FirestorePage2 {
      final String whenToUse;
      final String howToUse;
      final String? howToUseImageUrl; // FIX-02: foto cara penggunaan
    }
    ```
  - **Requirements:** sinkronisasi dengan admin FIX-01
  - **Depends on:** —

- [ ] TASK-M02 — Buat `FirestoreLevelService` (service baru, tidak mengganti yang lama)
  - Buat file baru `lib/services/firestore_level_content_service.dart`
  - Implementasi method berikut:
    ```dart
    class FirestoreLevelContentService {
      final _db = FirebaseFirestore.instance;

      // Ambil semua level aktif, terurut by field 'order'
      Future<List<FirestoreLevel>> getAllActiveLevels() async {
        final snap = await _db
            .collection('levels')
            .where('isActive', isEqualTo: true)
            .orderBy('order')
            .get();
        return snap.docs
            .map((d) => FirestoreLevel.fromFirestore(d.id, d.data()))
            .toList();
      }

      // Ambil soal quiz untuk satu level
      Future<List<QuizQuestion>> getQuizQuestions(String levelId) async {
        final snap = await _db
            .collection('levels')
            .doc(levelId)
            .collection('questions')
            .orderBy('order')
            .get();
        return snap.docs
            .map((d) => QuizQuestion.fromFirestore(d.data()))
            .toList();
      }

      // Ambil soal pretest (dari collection 'pretest_questions', bukan subcollection level)
      Future<List<QuizQuestion>> getPretestQuestions() async {
        final snap = await _db
            .collection('pretest_questions')
            .orderBy('order')
            .get();
        return snap.docs
            .map((d) => QuizQuestion.fromFirestore(d.data()))
            .toList();
      }
    }
    ```
  - Daftarkan `firestoreLevelContentServiceProvider` di `lib/providers/service_providers.dart`
  - **Catatan:** method ini memanggil Firestore, bukan lagi static data dari
    `LevelContentData`. Perlu pastikan index Firestore tersedia:
    - `levels` dengan `isActive == true` + `orderBy order`
    - `levels/{id}/questions` dengan `orderBy order`
    - `pretest_questions` dengan `orderBy order`
  - **Requirements:** data level dari Firestore
  - **Depends on:** TASK-M01

- [ ] TASK-M03 — Update `LevelViewModel` untuk load dari Firestore
  - Buka `lib/view_models/level_view_model.dart`
  - Tambah field baru ke `LevelState`:
    ```dart
    final bool isContentLoading;      // loading konten level dari Firestore
    final List<FirestoreLevel> firestoreLevels; // data konten dari Firestore
    ```
  - Tambah method `loadLevelContent()` di `LevelViewModel`:
    ```dart
    Future<void> loadLevelContent() async {
      state = state.copyWith(isContentLoading: true);
      try {
        final levels = await _firestoreLevelContentService.getAllActiveLevels();
        state = state.copyWith(
          firestoreLevels: levels,
          isContentLoading: false,
        );
      } catch (e) {
        // Fallback ke LevelContentData hardcoded jika Firestore gagal
        state = state.copyWith(isContentLoading: false);
      }
    }
    ```
  - Update `loadLevels()` agar menggunakan `firestoreLevels` jika tersedia,
    fallback ke `LevelContentData.levels` jika kosong (zero downtime migration)
  - Update `_buildEntries()` agar bisa menerima `FirestoreLevel` maupun `LevelConfig`
    (buat abstraksi interface `ILevelConfig` atau gunakan polymorphism)
  - Tambah method `getLevelContent(int levelNumber)` yang return `FirestoreLevel?`
    dari `firestoreLevels`
  - Update provider agar inject `firestoreLevelContentServiceProvider`
  - **Requirements:** konten level live dari Firestore
  - **Depends on:** TASK-M01, TASK-M02

- [ ] TASK-M04 — Update `ModuleService` dari hardcoded ke Firestore
  - Buka `lib/services/module_service.dart`
  - Ganti implementasi `getModules()`:
    ```dart
    Future<List<ModuleModel>> getModules() async {
      final snap = await _db
          .collection('modules')
          .orderBy('order')
          .get();
      return snap.docs
          .map((d) => ModuleModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
    }
    ```
  - Update `ModuleModel` Freezed (`lib/models/module_model.dart`):
    - `materialContent` ubah menjadi `@Default('') String materialContent` (opsional,
      karena konten detail kini ada di `levels` collection, bukan `modules`)
    - Tambah field `@Default(0) int levelCount` untuk tampilan di UI
  - Jalankan `flutter pub run build_runner build --delete-conflicting-outputs`
    untuk regenerasi `module_model.freezed.dart` dan `module_model.g.dart`
  - **Catatan:** Koleksi `modules` di Firestore saat ini belum ada (hanya hardcoded di sini).
    Perlu seed data ke Firestore — lihat TASK-M10 untuk script seed.
  - **Requirements:** data modul dari Firestore
  - **Depends on:** —

- [ ] TASK-M05 — Update `MateriLevelView` untuk multi-foto referensi (Page 1)
  - Cari file view yang menampilkan konten Page 1 level materi
    (kemungkinan di `lib/views/mission/` atau komponen dalam `level_view`)
  - Ganti `Image.asset(materiContent.page1ImagePath)` (satu foto) dengan
    widget carousel/PageView yang menampilkan semua foto dari `allImageUrls`:
    ```dart
    // Jika URL dimulai dengan 'http' → Network image (Firestore)
    // Jika tidak → Asset image (data lama hardcoded)
    Widget _buildImage(String url) {
      if (url.startsWith('http')) {
        return Image.network(url,
          loadingBuilder: (_, child, prog) =>
            prog == null ? child : const CircularProgressIndicator(),
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      }
      return Image.asset(url, errorBuilder: (_, __, ___) => const SizedBox());
    }
    ```
  - Tambah dot indicator di bawah gambar jika jumlah foto > 1
  - Hapus semua referensi ke `page1ImagePath` (deprecated) — gunakan `allImageUrls`
  - **Requirements:** tampilkan multi-foto dari Firestore
  - **Depends on:** TASK-M01, TASK-M03

- [ ] TASK-M06 — Update `MateriLevelView` untuk foto cara penggunaan (Page 2)
  - Di View yang menampilkan Page 2 (howToUse), tambah section gambar setelah
    teks `howToUse`:
    ```dart
    if (page2.howToUseImageUrl != null) ...[
      const SizedBox(height: 16),
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          page2.howToUseImageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: ...,
          errorBuilder: ...,
        ),
      ),
    ]
    ```
  - **Requirements:** tampilkan foto cara penggunaan dari Firestore
  - **Depends on:** TASK-M01, TASK-M03

- [ ] TASK-M07 — Update `QuizLevelView` dan `PretestView` untuk questionText
  - Buka `lib/views/quiz/quiz_level_view.dart` dan `lib/views/quiz/pretest_view.dart`
  - Di widget soal, ubah logika tampilan menjadi:
    ```dart
    // Tampilkan teks pertanyaan jika ada
    if (question.questionText != null && question.questionText!.isNotEmpty) ...[
      Text(question.questionText!, style: AppTextStyles.bodyLarge),
      const SizedBox(height: 12),
    ],
    // Tampilkan gambar jika ada (bisa bersamaan dengan teks)
    if (question.imagePath != null && question.imagePath!.isNotEmpty) ...[
      _buildQuestionImage(question.imagePath!),
      const SizedBox(height: 12),
    ],
    // Validasi: setidaknya satu dari keduanya harus ada
    // (sudah dijamin di admin, tapi tetap handle null case)
    if ((question.questionText == null || question.questionText!.isEmpty) &&
        (question.imagePath == null || question.imagePath!.isEmpty))
      const Text('Soal tidak tersedia', style: TextStyle(color: Colors.grey)),
    ```
  - Di `pretest_view.dart`, update source soal dari `kPretestQuestions`
    (hardcoded di `lib/core/pretest_questions.dart`) ke data dari Firestore:
    - Gunakan `firestoreLevelContentService.getPretestQuestions()` 
    - Jika Firestore kosong (belum di-seed), fallback ke `kPretestQuestions`
  - **Requirements:** soal bisa berisi teks dan/atau gambar dari Firestore
  - **Depends on:** TASK-M01, TASK-M03

- [ ] TASK-M08 — Update `LevelContentData` menjadi deprecated (non-breaking)
  - Buka `lib/core/level_content_data.dart`
  - Tambahkan `@Deprecated` annotation di class:
    ```dart
    @Deprecated(
      'Gunakan FirestoreLevelContentService via LevelViewModel.firestoreLevels. '
      'LevelContentData hanya dipertahankan sebagai fallback offline. '
      'Akan dihapus setelah semua data ter-seed ke Firestore.'
    )
    class LevelContentData { ... }
    ```
  - **Jangan hapus file ini** sampai data Firestore sudah diverifikasi lengkap (TASK-M10)
  - Update semua `import` yang masih menggunakan `LevelContentData` secara langsung
    (selain di `LevelViewModel` yang sudah pakai sebagai fallback) dengan
    menambahkan `// ignore: deprecated_member_use`
  - **Requirements:** tidak ada breaking change, fallback tetap jalan
  - **Depends on:** TASK-M03, TASK-M05, TASK-M06, TASK-M07

- [ ] TASK-M09 — Update `DailyLoginService` untuk baca dari subcollection Firestore
  - Buka `lib/services/daily_login_service.dart`
  - Saat ini `claimDailyLogin()` sudah menulis ke `users/{uid}/daily_logins/{date}`
    (dari sprint sebelumnya). Tambahkan method `getDailyLoginHistory(uid)`:
    ```dart
    Future<List<DateTime>> getDailyLoginHistory(String uid) async {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('daily_logins')
          .orderBy('loginAt', descending: true)
          .limit(30)
          .get();
      return snap.docs.map((d) {
        final ts = d.data()['loginAt'] as Timestamp?;
        return ts?.toDate() ?? DateTime.now();
      }).toList();
    }
    ```
  - Update `DailyLoginViewModel` untuk menggunakan history dari Firestore
    (untuk menampilkan streak calendar di Profile)
  - Pastikan `streakCount` dibaca dari `users/{uid}.streakCount` (bukan `loginStreak`
    yang sudah di-deprecate di admin FIX-05)
  - **Requirements:** sinkronisasi dengan FIX-05 admin
  - **Depends on:** —

- [ ] TASK-M10 — Seed data level, modul, dan pretest ke Firestore
  - Buat script Dart/Node.js di `scripts/seed_firestore.dart` untuk seed:
    1. **Collection `modules`** (10 dokumen) — dari data di `module_service.dart`
       hardcoded, field: `id`, `title`, `description`, `order`, `levelCount`
    2. **Collection `levels`** (25 dokumen) — dari `LevelContentData.levels`:
       - Level materi: field `levelNumber`, `title`, `type: 'materi'`, `order`,
         `isActive: true`, `page1.description`, `page1.referenceImageUrls: []`
         (kosong — foto diupload via admin), `page2.whenToUse`, `page2.howToUse`
       - Level quiz: field `levelNumber`, `title`, `type: 'quiz'`, `passingScore`
         (soal quiz di-seed ke subcollection `questions`)
    3. **Collection `levels/{id}/questions`** — dari `LevelContentData.levels`
       untuk level 10, 15, 20, 25: field `order`, `questionText` (dari `question`),
       `questionImageUrl: null`, `options`, `correctIndex`
    4. **Collection `pretest_questions`** — dari `kPretestQuestions` di
       `lib/core/pretest_questions.dart`: field `order`, `questionText`, `options`,
       `correctIndex`
  - **Catatan seed:** `referenceImageUrls` di-seed sebagai array kosong `[]`.
    Foto diupload secara manual melalui web admin (tidak di-seed programatik).
  - Setelah seed berhasil, verifikasi dengan membuka app dan pastikan:
    - Home screen menampilkan level dari Firestore
    - Quiz level 10 menampilkan 25 soal dengan teks
    - Pretest menampilkan soal dari Firestore (bukan fallback hardcoded)
  - **Requirements:** data live di Firestore sebagai prasyarat TASK-M08
  - **Depends on:** TASK-M02, TASK-M04

- [ ] TASK-M11 — Update `UserModel` untuk sinkronisasi field `streakCount`
  - Buka `lib/models/user_model.dart`
  - Pastikan `UserModel` sudah punya `@Default(0) int streakCount` (bukan `loginStreak`)
  - Jika masih ada `loginStreak` atau `login_streak`, update `fromJson` dengan fallback:
    ```dart
    streakCount: (json['streakCount'] ?? json['loginStreak'] ?? 0) as int,
    ```
  - Jalankan `build_runner` untuk regenerasi `user_model.freezed.dart`
  - Update semua View yang masih membaca `user.loginStreak` → `user.streakCount`
    (cari di `lib/views/profile/` dan `lib/views/home/`)
  - **Requirements:** sinkronisasi dengan admin FIX-05
  - **Depends on:** —

---

## Task Dependency Graph

```json
{
  "waves": [
    { "wave": 1, "tasks": ["TASK-M01", "TASK-M04", "TASK-M09", "TASK-M11"] },
    { "wave": 2, "tasks": ["TASK-M02"] },
    { "wave": 3, "tasks": ["TASK-M03", "TASK-M10"] },
    { "wave": 4, "tasks": ["TASK-M05", "TASK-M06", "TASK-M07"] },
    { "wave": 5, "tasks": ["TASK-M08"] }
  ]
}
```

Wave 1 dapat dikerjakan paralel dan independen. Wave 5 (deprecated `LevelContentData`)
hanya boleh dilakukan setelah semua View sudah tidak bergantung pada data hardcoded
dan seed Firestore sudah diverifikasi.

---

## Notes

### Zero-Downtime Migration Strategy
Sprint ini dirancang agar app tidak pernah crash selama proses migrasi:
- `LevelViewModel.loadLevels()` menggunakan `firestoreLevels` jika tersedia,
  **fallback otomatis** ke `LevelContentData.levels` jika Firestore kosong atau error
- `PretestView` fallback ke `kPretestQuestions` jika Firestore belum di-seed
- `_buildImage()` handle dua format: `assets/...` (lama) dan `https://...` (baru)

Ini berarti app tetap berfungsi penuh bahkan sebelum seed Firestore selesai.

### Urutan Pengerjaan yang Disarankan
1. **TASK-M11** dulu (1 jam) — paling kecil, tidak ada dependency
2. **TASK-M01** (2–3 jam) — fondasi semua task lain di wave 2+
3. **TASK-M04 + TASK-M09** paralel (masing-masing 1–2 jam)
4. **TASK-M02** (1–2 jam) — service layer baru
5. **TASK-M03** (3–4 jam) — ViewModel terbesar, butuh testing menyeluruh
6. **TASK-M10** (2–3 jam) — seed data (bisa dilakukan bersamaan dengan TASK-M05)
7. **TASK-M05 + TASK-M06 + TASK-M07** (masing-masing 1–2 jam)
8. **TASK-M08** (30 menit) — terakhir, hanya annotation

### Firestore Index yang Perlu Dibuat
Tambahkan ke `firestore.indexes.json` sebelum deploy:
```json
[
  {
    "collectionGroup": "levels",
    "queryScope": "COLLECTION",
    "fields": [
      { "fieldPath": "isActive", "order": "ASCENDING" },
      { "fieldPath": "order", "order": "ASCENDING" }
    ]
  },
  {
    "collectionGroup": "questions",
    "queryScope": "COLLECTION_GROUP",
    "fields": [
      { "fieldPath": "order", "order": "ASCENDING" }
    ]
  },
  {
    "collectionGroup": "pretest_questions",
    "queryScope": "COLLECTION",
    "fields": [
      { "fieldPath": "order", "order": "ASCENDING" }
    ]
  }
]
```

### build_runner
Wajib dijalankan setelah TASK-M01 dan TASK-M04 karena kedua task mengubah Freezed model:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing Checklist per Task
- **TASK-M01:** Kompilasi tanpa error; `FirestoreLevel.fromFirestore` parse dokumen
  dengan `referenceImageUrls` array dan dokumen lama dengan `referenceImageUrl` string
- **TASK-M02:** Unit test `getAllActiveLevels()` dengan mock Firestore
- **TASK-M03:** Buka LevelScreen → data muncul dari Firestore; matikan internet →
  fallback ke data hardcoded tanpa crash
- **TASK-M05:** Buka level materi → jika ada 2+ foto tampil carousel dengan dot indicator;
  foto lama dari assets tetap tampil
- **TASK-M07:** Buka quiz level 10 → soal tampil sebagai teks; soal pretest tampil
  dari Firestore setelah TASK-M10 selesai
- **TASK-M10:** Cek Firestore console → 25 dokumen di `levels`, soal ada di
  subcollection `questions` level 10/15/20/25, soal pretest di `pretest_questions`
