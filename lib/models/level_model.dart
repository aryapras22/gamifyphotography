// lib/models/level_model.dart
// TASK-01 (original) + TASK-M01 (migration update)

/// Tipe level: materi (konten belajar) atau quiz (evaluasi checkpoint)
enum LevelType { materi, quiz }

/// Satu soal quiz dengan gambar dan/atau teks pertanyaan
class QuizQuestion {
  final String question;
  /// Teks pertanyaan dari Firestore (field baru TASK-M01).
  /// Jika null, gunakan [question] sebagai fallback.
  final String? questionText;
  /// URL gambar soal — bisa asset path (lama) atau https:// (Firestore)
  final String? imagePath;
  final List<String> options; // 4 pilihan: A, B, C, D
  final int correctIndex; // 0-based index jawaban benar

  const QuizQuestion({
    required this.question,
    this.questionText,
    this.imagePath,
    required this.options,
    required this.correctIndex,
  });

  /// Factory dari dokumen Firestore subcollection `levels/{id}/questions`
  /// atau `pretest_questions`.
  factory QuizQuestion.fromFirestore(Map<String, dynamic> data) {
    final text = data['questionText'] as String? ?? '';
    return QuizQuestion(
      question: text,
      questionText: text,
      imagePath: data['questionImageUrl'] as String?,
      options: List<String>.from(data['options'] ?? []),
      correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
    );
  }

  /// Teks yang ditampilkan di UI — prioritaskan [questionText], fallback ke [question]
  String get displayText =>
      (questionText != null && questionText!.isNotEmpty) ? questionText! : question;
}

/// Konten untuk level materi (2 halaman)
class MateriContent {
  final String page1Title;
  final String page1Description;

  /// URL gambar referensi dari Firestore (array, TASK-M01 FIX-01).
  /// Kosong jika belum di-upload via admin.
  final List<String> page1ImageUrls;

  /// Asset path lama (hardcoded dari sprint sebelumnya).
  /// @Deprecated — gunakan [allImageUrls] sebagai gantinya.
  @Deprecated('Gunakan allImageUrls. Field ini dipertahankan sebagai fallback offline.')
  final String? page1ImagePath;

  final String page2WhenToUse;
  final String page2HowToUse;

  /// URL foto cara penggunaan dari Firestore (TASK-M01 FIX-02).
  final String? page2HowToUseImageUrl;

  const MateriContent({
    required this.page1Title,
    required this.page1Description,
    this.page1ImageUrls = const [],
    // ignore: deprecated_member_use_from_same_package
    this.page1ImagePath,
    required this.page2WhenToUse,
    required this.page2HowToUse,
    this.page2HowToUseImageUrl,
  });

  /// Gabungkan asset lama dan URL Firestore baru — backward-compat.
  List<String> get allImageUrls {
    final urls = List<String>.from(page1ImageUrls);
    // ignore: deprecated_member_use_from_same_package
    if (page1ImagePath != null && !urls.contains(page1ImagePath!)) {
      urls.insert(0, page1ImagePath!);
    }
    return urls;
  }
}

/// Konfigurasi satu level (materi atau quiz)
class LevelConfig {
  final int levelNumber;
  final String title;
  final LevelType type;
  final MateriContent? materiContent;
  final List<QuizQuestion>? questions;
  final int passingScore;

  // ── Pre-quiz material (untuk quiz dengan materi WYSIWYG sebelumnya) ──────
  final bool hasPreQuizMaterial;
  final String preQuizContent;
  final String preQuizTitle;

  const LevelConfig({
    required this.levelNumber,
    required this.title,
    required this.type,
    this.materiContent,
    this.questions,
    this.passingScore = 70,
    this.hasPreQuizMaterial = false,
    this.preQuizContent = '',
    this.preQuizTitle = '',
  });

  bool get isMateri => type == LevelType.materi;
  bool get isQuiz => type == LevelType.quiz;

  /// Apakah quiz ini punya materi pra-quiz yang harus ditampilkan dulu.
  bool get hasPreQuiz =>
      isQuiz && hasPreQuizMaterial && preQuizContent.trim().isNotEmpty;

  static int calculateScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    return (correctAnswers * 100) ~/ totalQuestions;
  }
}

// ── Firestore-backed models (TASK-M01) ────────────────────────────────────

/// Page 1 data dari Firestore
class FirestorePage1 {
  final String description;
  final List<String> referenceImageUrls;

  const FirestorePage1({
    required this.description,
    required this.referenceImageUrls,
  });

  factory FirestorePage1.fromFirestore(Map<String, dynamic> data) {
    return FirestorePage1(
      description: data['description'] as String? ?? '',
      referenceImageUrls: _parseImageUrls(data),
    );
  }

  /// Backward-compat: terima array baru (`referenceImageUrls`) atau
  /// string lama (`referenceImageUrl`).
  static List<String> _parseImageUrls(Map<String, dynamic> data) {
    final arr = data['referenceImageUrls'];
    if (arr != null) return List<String>.from(arr as List);
    final single = data['referenceImageUrl'] as String?;
    return single != null ? [single] : [];
  }
}

/// Page 2 data dari Firestore
class FirestorePage2 {
  final String whenToUse;
  final String howToUse;
  /// URL foto cara penggunaan (FIX-02)
  final String? howToUseImageUrl;

  const FirestorePage2({
    required this.whenToUse,
    required this.howToUse,
    this.howToUseImageUrl,
  });

  factory FirestorePage2.fromFirestore(Map<String, dynamic> data) {
    return FirestorePage2(
      whenToUse: data['whenToUse'] as String? ?? '',
      howToUse: data['howToUse'] as String? ?? '',
      howToUseImageUrl: data['howToUseImageUrl'] as String?,
    );
  }
}

/// Level dari Firestore — tidak mengganti [LevelConfig] agar tidak break
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

  // ── Pre-quiz material (WYSIWYG) ──────────────────────────────────────────
  final bool hasPreQuizMaterial;
  final String preQuizContent;
  final String preQuizTitle;

  const FirestoreLevel({
    required this.id,
    required this.levelNumber,
    required this.title,
    required this.type,
    required this.order,
    required this.isActive,
    this.passingScore = 70,
    this.page1,
    this.page2,
    this.hasPreQuizMaterial = false,
    this.preQuizContent = '',
    this.preQuizTitle = '',
  });

  bool get isMateri => type == LevelType.materi;
  bool get isQuiz => type == LevelType.quiz;

  factory FirestoreLevel.fromFirestore(String id, Map<String, dynamic> data) {
    final typeStr = data['type'] as String? ?? 'materi';
    final type = typeStr == 'quiz' ? LevelType.quiz : LevelType.materi;

    FirestorePage1? page1;
    if (data['page1'] is Map) {
      page1 = FirestorePage1.fromFirestore(
          Map<String, dynamic>.from(data['page1'] as Map));
    }

    FirestorePage2? page2;
    if (data['page2'] is Map) {
      page2 = FirestorePage2.fromFirestore(
          Map<String, dynamic>.from(data['page2'] as Map));
    }

    return FirestoreLevel(
      id: id,
      levelNumber: (data['levelNumber'] as num?)?.toInt() ?? 0,
      title: data['title'] as String? ?? '',
      type: type,
      order: (data['order'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      passingScore: (data['passingScore'] as num?)?.toInt() ?? 70,
      page1: page1,
      page2: page2,
      hasPreQuizMaterial: data['hasPreQuizMaterial'] as bool? ?? false,
      preQuizContent: data['preQuizContent'] as String? ?? '',
      preQuizTitle: data['preQuizTitle'] as String? ?? '',
    );
  }

  /// Konversi ke [MateriContent] untuk kompatibilitas dengan View lama
  MateriContent? toMateriContent() {
    if (type != LevelType.materi) return null;
    return MateriContent(
      page1Title: title,
      page1Description: page1?.description ?? '',
      page1ImageUrls: page1?.referenceImageUrls ?? [],
      page2WhenToUse: page2?.whenToUse ?? '',
      page2HowToUse: page2?.howToUse ?? '',
      page2HowToUseImageUrl: page2?.howToUseImageUrl,
    );
  }
}
