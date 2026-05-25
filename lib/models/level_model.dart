// lib/models/level_model.dart
// TASK-01 — Model & Data Level Baru

/// Tipe level: materi (konten belajar) atau quiz (evaluasi checkpoint)
enum LevelType { materi, quiz }

/// Satu soal quiz dengan gambar dan 4 pilihan jawaban
class QuizQuestion {
  final String question;
  final String? imagePath; // asset path, bisa null jika tidak ada gambar
  final List<String> options; // 4 pilihan: A, B, C, D
  final int correctIndex; // 0-based index jawaban benar

  const QuizQuestion({
    required this.question,
    this.imagePath,
    required this.options,
    required this.correctIndex,
  });
}

/// Konten untuk level materi (2 halaman)
class MateriContent {
  final String page1Title;
  final String page1Description; // Pengertian + keterangan referensi foto
  final String? page1ImagePath; // Referensi foto (asset path)
  final String page2WhenToUse; // Kapan digunakan
  final String page2HowToUse; // Cara menggunakan

  const MateriContent({
    required this.page1Title,
    required this.page1Description,
    this.page1ImagePath,
    required this.page2WhenToUse,
    required this.page2HowToUse,
  });
}

/// Konfigurasi satu level (materi atau quiz)
class LevelConfig {
  final int levelNumber;
  final String title;
  final LevelType type;

  // Untuk level materi
  final MateriContent? materiContent;

  // Untuk level quiz
  final List<QuizQuestion>? questions;
  final int passingScore; // default 70 (dari 100)

  const LevelConfig({
    required this.levelNumber,
    required this.title,
    required this.type,
    this.materiContent,
    this.questions,
    this.passingScore = 70,
  });

  bool get isMateri => type == LevelType.materi;
  bool get isQuiz => type == LevelType.quiz;

  /// Hitung skor dari jumlah jawaban benar (25 soal × 4 poin = 100)
  static int calculateScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    return (correctAnswers * 100) ~/ totalQuestions;
  }
}
