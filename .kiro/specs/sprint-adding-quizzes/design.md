# Design: Sprint Adding Quizzes

## Architecture Overview

Fitur ini mengikuti pola MVVM + Riverpod yang sudah ada di codebase. Tidak ada dependency baru yang ditambahkan.

```
lib/
├── core/
│   └── data/
│       └── pretest_questions.dart       ← QuizQuestion list (hardcoded)
├── models/
│   └── quiz_result_model.dart           ← Freezed model untuk hasil quiz
├── services/
│   └── quiz_service.dart                ← Simpan hasil ke Firestore
├── view_models/
│   └── quiz_view_model.dart             ← StateNotifier untuk state quiz
└── views/
    └── quiz/
        ├── pretest_screen.dart          ← Screen pretest
        ├── posttest_screen.dart         ← Screen posttest
        └── quiz_question_widget.dart    ← Widget soal reusable

assets/
└── crafting/
    ├── bridge_stage_0.png
    ├── bridge_stage_1.png
    ├── bridge_stage_2.png
    └── bridge_stage_3.png
```

---

## Data Models

### QuizQuestion (non-Freezed, simple class)
```dart
// lib/core/data/pretest_questions.dart
class QuizQuestion {
  final String questionText;
  final String imagePath;       // assets/images/quiz/q01.jpg
  final List<String> options;   // 4 pilihan
  final int correctIndex;       // 0-3
}
```

### QuizResultModel (Freezed)
```dart
// lib/models/quiz_result_model.dart
@freezed
class QuizResultModel with _$QuizResultModel {
  factory QuizResultModel({
    required String userId,
    required String type,           // 'pretest' | 'posttest'
    required int score,
    required List<int> answers,     // index jawaban per soal
    required DateTime submittedAt,
  }) = _QuizResultModel;

  factory QuizResultModel.fromJson(Map<String, dynamic> json) => ...;
}
```

### UserModel — Field Baru
```dart
@Default(false) bool pretestDone,
@Default(false) bool posttestDone,
```

---

## Service Layer

### QuizService
```dart
class QuizService {
  final _db = FirebaseFirestore.instance;

  // Simpan hasil pretest ke quiz_results/{uid}_pretest
  Future<void> savePretest(String uid, int score, List<int> answers) async { ... }

  // Simpan hasil posttest ke quiz_results/{uid}_posttest
  Future<void> savePosttest(String uid, int score, List<int> answers) async { ... }

  // Cek apakah pretest sudah dikerjakan
  Future<bool> isPretestDone(String uid) async { ... }

  // Cek apakah posttest sudah dikerjakan
  Future<bool> isPosttestDone(String uid) async { ... }
}
```

Setelah menyimpan hasil, `QuizService` juga mengupdate `users/{uid}` dengan field `pretestDone` atau `posttestDone`.

---

## ViewModel Layer

### QuizState
```dart
class QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final List<int?> selectedAnswers;   // null = belum dijawab
  final bool isSubmitting;
  final bool isCompleted;
  final int? finalScore;
}
```

### QuizViewModel (StateNotifier)
- `loadQuestions()` — load dari `pretest_questions.dart`
- `selectAnswer(int questionIndex, int answerIndex)` — simpan pilihan
- `nextQuestion()` — maju ke soal berikutnya
- `submitQuiz(String uid, String type)` — hitung skor, panggil `QuizService`, update state

---

## View Layer

### PretestScreen / PosttestScreen
Keduanya menggunakan `QuizViewModel` yang sama. Perbedaan hanya pada `type` ('pretest' vs 'posttest') dan navigasi setelah submit.

**Alur UI:**
1. Loading soal → tampilkan `QuizQuestionWidget`
2. User pilih jawaban → tombol "Lanjut" aktif
3. Soal terakhir → tombol berubah jadi "Selesai"
4. Tampilkan `_ScoreSummaryWidget` (skor + jumlah benar)
5. Tombol "Submit" → panggil `submitQuiz()` → navigasi

### QuizQuestionWidget (reusable)
```dart
class QuizQuestionWidget extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedAnswer;
  final int questionNumber;
  final int totalQuestions;
  final ValueChanged<int> onAnswerSelected;
}
```

---

## Crafting View — Perubahan

### CraftingViewModel — Update requiredPoints
`requiredPoints` diubah dari 1000 menjadi 5000. `craftingDone` tetap berdasarkan `bridgeProgress >= maxBridgeSegments`.

### CraftingView — Visual Milestone
Ganti `CustomPaint` (BridgeScenePainter) dengan `Stack` + `Image.asset()` berdasarkan XP:

```dart
String _getBridgeStageAsset(int currentXP) {
  if (currentXP >= 5000) return 'assets/crafting/bridge_stage_3.png';
  if (currentXP >= 2000) return 'assets/crafting/bridge_stage_2.png';
  if (currentXP >= 1000) return 'assets/crafting/bridge_stage_1.png';
  return 'assets/crafting/bridge_stage_0.png';
}
```

Gunakan `AnimatedSwitcher` untuk transisi antar gambar.

### Posttest Trigger di CraftingView
```dart
// Di dalam ref.listen atau setelah doCrafting():
if (state.craftingDone && !posttestDone) {
  // Tampilkan dialog "Jembatan Selesai!"
  // Setelah dialog ditutup → context.push('/quiz/posttest')
}
```

---

## Daily Login — Perubahan

### DailyLoginService — Tambah Subcollection Write
Di dalam `claimDailyLogin()`, setelah update root document, tambahkan:
```dart
final dateKey = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
await _userRef(userId)
    .collection('daily_logins')
    .doc(dateKey)
    .set({
      'loginAt': Timestamp.fromDate(now),
      'streak': streak,
    }, SetOptions(merge: true));  // idempotent
```

---

## Routing

Tambahkan ke `router.dart`:
```dart
GoRoute(
  path: '/quiz/pretest',
  builder: (context, state) => const PretestScreen(),
),
GoRoute(
  path: '/quiz/posttest',
  builder: (context, state) => const PosttestScreen(),
),
```

---

## Firestore Rules — Tambahan

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

---

## pubspec.yaml — Tambahan Assets

```yaml
flutter:
  assets:
    - assets/images/quiz/        # gambar soal pretest/posttest
    - assets/crafting/           # bridge_stage_0..3.png
    # (existing entries tetap ada)
```

---

## Dependency Baru
Tidak ada. Semua fitur menggunakan package yang sudah ada:
- `cloud_firestore` — sudah ada
- `flutter_riverpod` — sudah ada
- `go_router` — sudah ada
- `freezed_annotation` — sudah ada

---

## Catatan Implementasi

1. **Soal placeholder**: Karena konten soal dari Affan belum tersedia, implementasi menggunakan 25 soal placeholder dengan gambar dummy. Struktur `QuizQuestion` sudah final sehingga mudah diganti.

2. **Bridge stage images**: File PNG belum ada di repo. Implementasi menggunakan `Image.asset()` dengan `errorBuilder` fallback ke `BridgeScenePainter` yang sudah ada, sehingga app tidak crash jika gambar belum ada.

3. **build_runner**: Setelah update `UserModel`, jalankan:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Pretest gate di home_view.dart**: Logika pengecekan `pretestDone` ditambahkan di `_showMissionBottomSheet()` — ketika `module.order == 2` dan `pretestDone == false`, navigasi ke `/quiz/pretest` bukan `/mission/detail`.
