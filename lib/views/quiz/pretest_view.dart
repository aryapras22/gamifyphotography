// lib/views/quiz/pretest_view.dart
// TASK-08 — Pretest View (muncul setelah Level 1 selesai)
// TASK-09 — Reused for Posttest
// TASK-M07 — Firestore fallback + questionText support

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../models/level_model.dart';
import '../../view_models/level_view_model.dart';
import '../../providers/service_providers.dart';
import '../widgets/app_network_image.dart';

enum TestType { pretest, posttest }

class PretestView extends ConsumerStatefulWidget {
  final TestType testType;
  final VoidCallback? onDone;

  const PretestView({
    Key? key,
    this.testType = TestType.pretest,
    this.onDone,
  }) : super(key: key);

  @override
  ConsumerState<PretestView> createState() => _PretestViewState();
}

class _PretestViewState extends ConsumerState<PretestView> {
  int _currentIndex = 0;
  final List<int?> _selectedAnswers = [];
  bool _started = false;
  bool _submitting = false;
  // Soal dari Firestore
  List<QuizQuestion> _questions = [];
  bool _questionsLoaded = false;

  String get _title =>
      widget.testType == TestType.pretest ? 'Pre-Test Fotografi' : 'Post-Test Fotografi';

  String get _subtitle => widget.testType == TestType.pretest
      ? 'Tes awal untuk mengukur pengetahuan fotografi kamu sebelum memulai misi.'
      : 'Tes akhir untuk mengukur perkembangan pengetahuan fotografi kamu.';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  /// Load questions from Firestore (Firebase-only, no hardcoded fallback)
  Future<void> _loadQuestions() async {
    try {
      final service = ref.read(firestoreLevelContentServiceProvider);
      final firestoreQuestions = await service.getPretestQuestions();
      setState(() {
        _questions = firestoreQuestions;
        _selectedAnswers.addAll(List.filled(_questions.length, null));
        _questionsLoaded = true;
      });
    } catch (_) {
      // Firestore failed — show empty state
      setState(() {
        _questions = [];
        _selectedAnswers.clear();
        _questionsLoaded = true;
      });
    }
  }

  void _selectAnswer(int optionIndex) {
    if (_selectedAnswers[_currentIndex] != null) return;
    setState(() => _selectedAnswers[_currentIndex] = optionIndex);
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _finishTest();
    }
  }

  Future<void> _finishTest() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctIndex) correct++;
    }
    final score = LevelConfig.calculateScore(correct, _questions.length);
    final answers = _selectedAnswers.map((a) => a ?? -1).toList();

    if (widget.testType == TestType.pretest) {
      await ref.read(levelViewModelProvider.notifier).submitQuizResult(
        levelNumber: 0,
        score: score,
        answers: answers,
      );
    } else {
      await ref.read(levelViewModelProvider.notifier).submitQuizResult(
        levelNumber: 26,
        score: score,
        answers: answers,
      );
    }

    if (!mounted) return;

    // Tampilkan hasil
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TestResultDialog(
        testType: widget.testType,
        score: score,
        correct: correct,
        total: _questions.length,
      ),
    );

    if (!mounted) return;
    if (widget.onDone != null) {
      widget.onDone!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_questionsLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundGray,
        body: Center(child: CircularProgressIndicator(color: AppColors.brandBlue)),
      );
    }
    if (!_started) return _buildIntroScreen();
    return _buildTestScreen();
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
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.assignment_rounded, size: 52, color: AppColors.brandBlue),
                ),
              ),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.bodyText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'Tes ini tidak memiliki nilai kelulusan. Kerjakan dengan jujur sesuai pengetahuan kamu saat ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.brandBlue,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _InfoRow(icon: Icons.help_outline_rounded, label: '${_questions.length} soal pilihan ganda'),
              const SizedBox(height: 8),
              _InfoRow(icon: Icons.block_rounded, label: 'Tidak bisa di-skip'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => setState(() => _started = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: AppColors.surfaceWhite,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Mulai Tes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Test Screen ───────────────────────────────────────────────────────────

  Widget _buildTestScreen() {
    final question = _questions[_currentIndex];
    final selected = _selectedAnswers[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return PopScope(
      canPop: false, // Tidak bisa di-back
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceWhite,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Soal ${_currentIndex + 1} / ${_questions.length}',
            style: const TextStyle(
              color: AppColors.bodyText,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  _title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandBlue),
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
                    if (question.imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildQuestionImage(question.imagePath!, height: 200),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // TASK-M07: gunakan displayText (questionText ?? question)
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
                    ...List.generate(question.options.length, (i) {
                      final isSelected = selected == i;
                      return GestureDetector(
                        onTap: selected == null ? () => _selectAnswer(i) : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brandBlue.withValues(alpha: 0.08)
                                : AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.brandBlue : AppColors.cardBorder,
                              width: isSelected ? 2 : 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  question.options[i],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.brandBlue : AppColors.bodyText,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.brandBlue, size: 22),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            if (selected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: ElevatedButton(
                  onPressed: _submitting ? null : _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    foregroundColor: AppColors.surfaceWhite,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _submitting && _currentIndex == _questions.length - 1
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.surfaceWhite,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          _currentIndex < _questions.length - 1
                              ? 'Soal Berikutnya'
                              : 'Selesai',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Result Dialog ─────────────────────────────────────────────────────────

class _TestResultDialog extends StatelessWidget {
  final TestType testType;
  final int score;
  final int correct;
  final int total;

  const _TestResultDialog({
    required this.testType,
    required this.score,
    required this.correct,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(28),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.assignment_turned_in_rounded, size: 44, color: AppColors.brandBlue),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            testType == TestType.pretest ? 'Pre-Test Selesai!' : 'Post-Test Selesai!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.bodyText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Skor kamu: $score / 100',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.brandBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$correct dari $total soal benar',
            style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 16),
          Text(
            testType == TestType.pretest
                ? 'Terima kasih! Hasil pre-test tersimpan. Sekarang kamu bisa melanjutkan misi.'
                : 'Terima kasih! Hasil post-test tersimpan. Perjalanan misimu sudah selesai!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                foregroundColor: AppColors.surfaceWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
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
        Text(label,
            style: const TextStyle(
                fontSize: 15, color: AppColors.secondaryText, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

/// TASK-M07: Render gambar soal — network atau asset
Widget _buildQuestionImage(String url, {double height = 200}) {
  if (url.startsWith('http')) {
    return AppNetworkImage(
      url: url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(16),
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
            size: 40, color: AppColors.disabled),
      ),
    ),
  );
}
