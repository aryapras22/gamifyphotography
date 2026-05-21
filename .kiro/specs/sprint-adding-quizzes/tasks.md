# Implementation Plan: Sprint Adding Quizzes

## Overview
Implementasi Pretest/Posttest, visual Crafting Jembatan berbasis milestone XP, Daily Login ke Firestore subcollection, update Firestore Rules, dan update UserModel.

## Tasks

- [ ] 1. Update UserModel — tambah pretestDone & posttestDone
  - Edit `lib/models/user_model.dart` — tambah `@Default(false) bool pretestDone` dan `@Default(false) bool posttestDone`
  - Jalankan `flutter pub run build_runner build --delete-conflicting-outputs` untuk regenerate `user_model.freezed.dart` dan `user_model.g.dart`
  - **Requirements:** R6.1

- [ ] 2. Buat QuizResultModel (Freezed)
  - Buat `lib/models/quiz_result_model.dart` dengan fields: `userId`, `type`, `score`, `answers` (List<int>), `submittedAt` (DateTime)
  - Jalankan `build_runner` untuk generate `quiz_result_model.freezed.dart` dan `quiz_result_model.g.dart`
  - **Requirements:** R7.1
  - **Depends on:** 1

- [ ] 3. Buat pretest_questions.dart dan daftarkan assets baru
  - Buat class `QuizQuestion` di `lib/core/data/pretest_questions.dart` dengan fields: `questionText`, `imagePath`, `options` (List<String>), `correctIndex`
  - Buat list `kPretestQuestions` berisi 25 soal placeholder
  - Tambahkan `- assets/images/quiz/` dan `- assets/crafting/` ke `pubspec.yaml` bagian `flutter.assets`
  - Buat direktori `assets/images/quiz/` dan `assets/crafting/` dengan file `.gitkeep`
  - **Requirements:** R7.1

- [ ] 4. Buat QuizService
  - Buat `lib/services/quiz_service.dart` dengan method `savePretest(uid, score, answers)` — simpan ke `quiz_results/{uid}_pretest` dan update `users/{uid}.pretestDone = true`
  - Tambahkan method `savePosttest(uid, score, answers)` — simpan ke `quiz_results/{uid}_posttest` dan update `users/{uid}.posttestDone = true`
  - Tambahkan method `isPretestDone(uid)` dan `isPosttestDone(uid)` — baca dari Firestore
  - Daftarkan `quizServiceProvider` di `lib/providers/service_providers.dart`
  - **Requirements:** R1.3, R2.3
  - **Depends on:** 1, 2

- [ ] 5. Buat QuizViewModel
  - Buat `QuizState` di `lib/view_models/quiz_view_model.dart` dengan fields: `questions`, `currentIndex`, `selectedAnswers` (List<int?>), `isSubmitting`, `isCompleted`, `finalScore`
  - Buat `QuizViewModel extends StateNotifier<QuizState>` dengan methods: `loadQuestions()`, `selectAnswer(questionIndex, answerIndex)`, `nextQuestion()`, `submitQuiz(uid, type)`
  - Daftarkan `quizViewModelProvider` sebagai `StateNotifierProvider`
  - **Requirements:** R1.2, R2.2
  - **Depends on:** 3, 4

- [ ] 6. Buat QuizQuestionWidget (reusable)
  - Buat `lib/views/quiz/quiz_question_widget.dart` dengan props: `question`, `selectedAnswer`, `questionNumber`, `totalQuestions`, `onAnswerSelected`
  - Tampilkan gambar soal dari asset lokal dengan `Image.asset()` dan fallback jika gambar tidak ada
  - Tampilkan 4 pilihan jawaban sebagai tombol yang bisa dipilih (highlight pilihan aktif)
  - Tampilkan progress indicator "Soal X / 25"
  - **Requirements:** R1.2, R2.2
  - **Depends on:** 5

- [ ] 7. Buat PretestScreen
  - Buat `lib/views/quiz/pretest_screen.dart` sebagai `ConsumerStatefulWidget`
  - Tampilkan soal satu per satu menggunakan `QuizQuestionWidget`; tombol "Lanjut" hanya aktif setelah user memilih jawaban
  - Soal terakhir: tombol berubah jadi "Selesai" → tampilkan ringkasan skor
  - Tombol "Submit" → panggil `submitQuiz(uid, 'pretest')` → navigasi ke `/mission/detail` (dengan `selectModule` Level 2)
  - **Requirements:** R1.2, R1.3
  - **Depends on:** 6

- [ ] 8. Buat PosttestScreen
  - Buat `lib/views/quiz/posttest_screen.dart` sebagai `ConsumerStatefulWidget` (struktur identik dengan PretestScreen)
  - Setelah submit → panggil `submitQuiz(uid, 'posttest')` → tampilkan halaman hasil skor final dengan pesan selamat
  - **Requirements:** R2.2, R2.3
  - **Depends on:** 6

- [ ] 9. Update Routing — tambah route quiz
  - Import `PretestScreen` dan `PosttestScreen` di `lib/core/router.dart`
  - Tambahkan `GoRoute(path: '/quiz/pretest', ...)` dan `GoRoute(path: '/quiz/posttest', ...)`
  - **Requirements:** R8.1
  - **Depends on:** 7, 8

- [ ] 10. Update HomeView — Pretest Gate untuk Level 2
  - Di `_showMissionBottomSheet()` di `lib/views/home/home_view.dart`, cek jika `module.order == 2`
  - Baca `authState.currentUser?.pretestDone` — jika `false`, tutup bottom sheet dan navigasi ke `/quiz/pretest`
  - Jika `pretestDone == true`, lanjutkan ke `/mission/detail` seperti biasa
  - **Requirements:** R1.1
  - **Depends on:** 1, 9

- [ ] 11. Update CraftingViewModel — target XP 5000 & posttest trigger
  - Ubah `requiredPoints` default dari 1000 menjadi 5000 di `CraftingState`
  - Tambahkan field `bool shouldTriggerPosttest` ke `CraftingState`
  - Di `doCrafting()`, setelah `craftingDone` baru tercapai, set `shouldTriggerPosttest = true` jika `posttestDone == false` (baca dari `authViewModelProvider`)
  - **Requirements:** R2.1, R3.2
  - **Depends on:** 1

- [ ] 12. Update CraftingView — visual milestone & posttest dialog
  - Tambahkan helper `_getBridgeStageAsset(int currentXP)` yang return path gambar berdasarkan milestone XP (0–999, 1000–1999, 2000–4999, 5000+)
  - Ganti `CustomPaint(BridgeScenePainter)` dengan `AnimatedSwitcher` + `Image.asset()` untuk visual milestone; gunakan `BridgeScenePainter` sebagai fallback jika gambar belum ada
  - Update progress bar: ubah target ke 5000 XP
  - Tambahkan `ref.listen` untuk `shouldTriggerPosttest` — tampilkan dialog "Jembatan Selesai! 🎉" lalu navigasi ke `/quiz/posttest`
  - **Requirements:** R2.1, R3.1, R3.2
  - **Depends on:** 11, 9

- [ ] 13. Update DailyLoginService — simpan ke subcollection
  - Di `claimDailyLogin()` di `lib/services/daily_login_service.dart`, setelah update root document, tambahkan write ke `users/{uid}/daily_logins/{YYYY-MM-DD}`
  - Dokumen berisi `{ loginAt: Timestamp, streak: int }` dengan `SetOptions(merge: true)` agar idempotent
  - **Requirements:** R4.1

- [ ] 14. Update Firestore Rules — tambah quiz_results
  - Tambahkan block `match /quiz_results/{docId}` ke `firestore.rules` dengan rules: read (owner atau admin), create (owner saja), update/delete (false)
  - **Requirements:** R5.1

## Task Dependency Graph

```json
{
  "waves": [
    { "wave": 1, "tasks": ["1", "3", "13", "14"] },
    { "wave": 2, "tasks": ["2", "11"] },
    { "wave": 3, "tasks": ["4"] },
    { "wave": 4, "tasks": ["5"] },
    { "wave": 5, "tasks": ["6"] },
    { "wave": 6, "tasks": ["7", "8"] },
    { "wave": 7, "tasks": ["9"] },
    { "wave": 8, "tasks": ["10", "12"] }
  ]
}
```

## Notes

- **Soal placeholder**: Konten soal aktual dari Affan belum tersedia. Implementasi menggunakan 25 soal placeholder. Struktur `QuizQuestion` sudah final sehingga mudah diganti.
- **Bridge stage images**: File PNG belum ada di repo. `CraftingView` menggunakan `BridgeScenePainter` sebagai fallback agar app tidak crash.
- **build_runner**: Harus dijalankan setelah Task 1 dan Task 2 sebelum melanjutkan ke task yang bergantung pada model tersebut.
- **Pretest gate**: Logika pengecekan `pretestDone` ada di `home_view.dart` di `_showMissionBottomSheet()`, bukan di `module_detail_view.dart`, agar user tidak bisa bypass lewat deep link.
