// lib/views/quiz/quiz_level_view.dart
// TASK-05 — Quiz Level Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../models/level_model.dart';
import 'quiz_result_view.dart';

class QuizLevelView extends ConsumerStatefulWidget {
  final LevelConfig config;
  /// Jika true, ini adalah pretest/posttest (tidak ada passing score)
  final bool isPrePostTest;
  /// Callback setelah quiz selesai (untuk pretest/posttest)
  final void Function(int score, List<int> answers)? onComplete;

  const QuizLevelView({
    Key? key,
    required this.config,
    this.isPrePostTest = false,
    this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<QuizLevelView> createState() => _QuizLevelViewState();
}

class _QuizLevelViewState extends ConsumerState<QuizLevelView> {
  int _currentIndex = 0;
  final List<int?> _selectedAnswers = [];
  bool _started = false;

  List<QuizQuestion> get _questions => widget.config.questions ?? [];

  @override
  void initState() {
    super.initState();
    _selectedAnswers.addAll(List.filled(_questions.length, null));
  }

  void _selectAnswer(int optionIndex) {
    if (_selectedAnswers[_currentIndex] != null) return; // sudah dijawab
    setState(() {
      _selectedAnswers[_currentIndex] = optionIndex;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctIndex) correct++;
    }
    final score = LevelConfig.calculateScore(correct, _questions.length);
    final answers = _selectedAnswers.map((a) => a ?? -1).toList();

    if (widget.isPrePostTest && widget.onComplete != null) {
      widget.onComplete!(score, answers);
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultView(
          config: widget.config,
          score: score,
          correctAnswers: correct,
          totalQuestions: _questions.length,
          answers: answers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) return _buildIntroScreen();
    return _buildQuizScreen();
  }

  // ── Intro Screen ──────────────────────────────────────────────────────────

  Widget _buildIntroScreen() {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Icon
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: AppColors.lensGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.quiz_rounded, size: 52, color: AppColors.lensGold),
                ),
              ),
              Text(
                widget.config.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.bodyText,
                ),
              ),
              const SizedBox(height: 16),
              if (!widget.isPrePostTest) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.coralRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.coralRed.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Kamu harus mendapat skor minimal ${widget.config.passingScore}/100 untuk lanjut ke level berikutnya.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.coralRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _InfoRow(icon: Icons.help_outline_rounded, label: '${_questions.length} soal pilihan ganda'),
              const SizedBox(height: 8),
              _InfoRow(icon: Icons.star_rounded, label: 'Setiap soal bernilai ${100 ~/ _questions.length} poin'),
              const SizedBox(height: 8),
              _InfoRow(icon: Icons.image_rounded, label: 'Beberapa soal disertai gambar'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => setState(() => _started = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lensGold,
                  foregroundColor: AppColors.surfaceWhite,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Mulai Quiz',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Kembali',
                  style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quiz Screen ───────────────────────────────────────────────────────────

  Widget _buildQuizScreen() {
    final question = _questions[_currentIndex];
    final selected = _selectedAnswers[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.bodyText),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(
          'Soal ${_currentIndex + 1} / ${_questions.length}',
          style: const TextStyle(
            color: AppColors.bodyText,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.cardBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lensGold),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TASK-M07: Gambar soal (jika ada — bisa asset atau network URL)
                  if (question.imagePath != null && question.imagePath!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildQuestionImage(question.imagePath!, height: 200),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // TASK-M07: Teks pertanyaan — gunakan displayText (questionText ?? question)
                  if (question.displayText.isNotEmpty)
                    Text(
                      question.displayText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bodyText,
                        height: 1.5,
                      ),
                    )
                  else
                    const Text(
                      'Soal tidak tersedia',
                      style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
                    ),
                  const SizedBox(height: 24),
                  // Pilihan jawaban
                  ...List.generate(question.options.length, (i) {
                    return _OptionCard(
                      text: question.options[i],
                      index: i,
                      selected: selected,
                      correctIndex: question.correctIndex,
                      onTap: selected == null ? () => _selectAnswer(i) : null,
                    );
                  }),
                ],
              ),
            ),
          ),
          // Tombol Next
          if (selected != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: AppColors.surfaceWhite,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  _currentIndex < _questions.length - 1 ? 'Soal Berikutnya' : 'Lihat Hasil',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari Quiz?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Progress quiz akan hilang jika kamu keluar sekarang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjutkan Quiz'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Keluar', style: TextStyle(color: AppColors.coralRed)),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────

/// Render gambar soal: network jika URL dimulai 'http', asset jika tidak.
Widget _buildQuestionImage(String url, {double height = 200}) {
  if (url.startsWith('http')) {
    return Image.network(
      url,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : SizedBox(
              height: height,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.brandBlue,
                  strokeWidth: 2,
                ),
              ),
            ),
      errorBuilder: (_, __, ___) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardBorder,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported_rounded,
              size: 48, color: AppColors.disabled),
        ),
      ),
    );
  }
  return Image.asset(
    url,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBorder,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded,
            size: 48, color: AppColors.disabled),
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondaryText),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 15, color: AppColors.secondaryText, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String text;
  final int index;
  final int? selected;
  final int correctIndex;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.text,
    required this.index,
    required this.selected,
    required this.correctIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.cardBorder;
    Color bgColor = AppColors.surfaceWhite;
    Color textColor = AppColors.bodyText;

    if (selected != null) {
      if (index == correctIndex) {
        borderColor = AppColors.forestGreen;
        bgColor = AppColors.forestGreen.withValues(alpha: 0.08);
        textColor = AppColors.forestGreen;
      } else if (index == selected) {
        borderColor = AppColors.coralRed;
        bgColor = AppColors.coralRed.withValues(alpha: 0.08);
        textColor = AppColors.coralRed;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
            if (selected != null && index == correctIndex)
              const Icon(Icons.check_circle_rounded, color: AppColors.forestGreen, size: 22),
            if (selected != null && index == selected && index != correctIndex)
              const Icon(Icons.cancel_rounded, color: AppColors.coralRed, size: 22),
          ],
        ),
      ),
    );
  }
}
