import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/level_model.dart';
import '../../providers/service_providers.dart';
import '../../view_models/level_view_model.dart';
import '../widgets/brutal_widgets.dart';

class QuizLevelView extends ConsumerStatefulWidget {
  final LevelConfig config;
  final bool isPrePostTest;
  final void Function(int score, List<int> answers)? onComplete;

  const QuizLevelView({
    super.key,
    required this.config,
    this.isPrePostTest = false,
    this.onComplete,
  });

  @override
  ConsumerState<QuizLevelView> createState() => _QuizLevelViewState();
}

class _QuizLevelViewState extends ConsumerState<QuizLevelView> {
  int _currentIndex = 0;
  int? _pickedIndex;
  bool _submitted = false;
  int _correctCount = 0;

  List<QuizQuestion> _questions = [];
  final List<int?> _answers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final service = ref.read(firestoreLevelContentServiceProvider);
      String? levelId;

      final fsLevels = ref.read(levelViewModelProvider).firestoreLevels;
      try {
        final matched = fsLevels.firstWhere(
          (l) => l.levelNumber == widget.config.levelNumber,
        );
        levelId = matched.id;
      } catch (_) {}

      if (levelId == null) {
        final fsLevel = await service.getLevelByNumber(widget.config.levelNumber);
        levelId = fsLevel?.id;
      }

      if (levelId != null) {
        final fsQuestions = await service.getQuizQuestions(levelId);
        setState(() {
          _questions = fsQuestions;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Gagal memuat soal dari Firestore: $e');
    }

    // Firestore failed or no questions found
    setState(() {
      _questions = [];
      _isLoading = false;
    });
  }

  void _handleAnswer() {
    final q = _questions[_currentIndex];
    
    if (!_submitted) {
      // User clicks Jawab
      setState(() {
        _submitted = true;
        _answers.add(_pickedIndex);
        if (_pickedIndex == q.correctIndex) {
          _correctCount++;
        }
      });
    } else {
      // User clicks Lanjut or Lihat Hasil
      final isLast = _currentIndex == _questions.length - 1;
      if (isLast) {
        _finishQuiz();
      } else {
        setState(() {
          _currentIndex++;
          _pickedIndex = null;
          _submitted = false;
        });
      }
    }
  }

  Future<void> _finishQuiz() async {
    final score = LevelConfig.calculateScore(_correctCount, _questions.length);
    final finalAnswers = _answers.map((a) => a ?? -1).toList();

    if (widget.isPrePostTest && widget.onComplete != null) {
      widget.onComplete!(score, finalAnswers);
      return;
    }

    // Save progress to database
    await ref.read(levelViewModelProvider.notifier).submitQuizResult(
          levelNumber: widget.config.levelNumber,
          score: score,
          answers: finalAnswers,
        );

    final fsLevel = ref.read(levelViewModelProvider.notifier).getLevelContent(widget.config.levelNumber);
    final passingScore = fsLevel?.passingScore ?? widget.config.passingScore;
    final passed = score >= passingScore;

    if (!mounted) return;

    // Show QuizResultModal dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogCtx) => _QuizResultModal(
        score: _correctCount,
        total: _questions.length,
        passed: passed,
        xpReward: _correctCount * 20,
        onActionPressed: () {
          // Close dialog
          Navigator.pop(dialogCtx);
          
          if (passed) {
            // Go back to home or level list
            Navigator.pop(context);
          } else {
            // Restart quiz
            setState(() {
              _currentIndex = 0;
              _pickedIndex = null;
              _submitted = false;
              _correctCount = 0;
              _answers.clear();
            });
          }
        },
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black, width: 2.0),
        ),
        title: Text('Keluar dari Misi Quiz?', style: GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w900)),
        content: Text(
          'Progress Misi Quiz akan hilang jika kamu keluar sekarang.',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Lanjutkan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Keluar', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.brandDanger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.brandBg,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.brandBg,
        appBar: BrutalAppBar(title: 'Misi Quiz', onBackPressed: () => Navigator.pop(context)),
        body: const Center(child: Text('Materi soal belum siap.')),
      );
    }

    final q = _questions[_currentIndex];
    final progress = (_currentIndex + (_submitted ? 1 : 0)) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      appBar: BrutalAppBar(
        title: 'Misi Quiz',
        subtitle: 'Soal ${_currentIndex + 1} dari ${_questions.length}',
        onBackPressed: _showExitDialog,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress Indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: BrutalProgressBar(value: progress, height: 10),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question index pill
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2.0),
                            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                          ),
                          child: Text(
                            'SOAL ${_currentIndex + 1}',
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question image (if any)
                    if (q.imagePath != null && q.imagePath!.isNotEmpty) ...[
                      BrutalCard(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: _buildQuestionImage(q.imagePath!),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Question Text
                    Text(
                      q.displayText,
                      style: AppTextStyles.heading.copyWith(fontSize: 20, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    // Options List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: q.options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final letter = String.fromCharCode(65 + idx);
                        final isPicked = _pickedIndex == idx;
                        final isCorrect = _submitted && idx == q.correctIndex;
                        final isWrong = _submitted && isPicked && idx != q.correctIndex;

                        Color bg = Colors.white;
                        Color textCol = Colors.black;
                        Color borderCol = Colors.black;
                        Offset shadow = const Offset(2, 2);
                        Widget trailing = const SizedBox.shrink();

                        if (isCorrect) {
                          bg = const Color(0xFFD1FAE5); // bg-emerald-100
                          textCol = const Color(0xFF065F46); // text-emerald-800
                          borderCol = const Color(0xFF059669); // border-emerald-600
                          shadow = const Offset(4, 4);
                          trailing = const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20);
                        } else if (isWrong) {
                          bg = const Color(0xFFFEE2E2); // bg-red-100
                          textCol = const Color(0xFF991B1B); // text-red-800
                          borderCol = const Color(0xFFDC2626); // border-red-600
                          shadow = const Offset(4, 4);
                          trailing = const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 20);
                        } else if (isPicked) {
                          bg = AppColors.brandAccent;
                          shadow = const Offset(4, 4);
                        }

                        return GestureDetector(
                          onTap: _submitted ? null : () => setState(() => _pickedIndex = idx),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Transform.translate(
                              offset: -shadow,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderCol, width: 2.0),
                                ),
                                child: Row(
                                  children: [
                                    // Circular letter container
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isCorrect
                                            ? const Color(0xFF10B981)
                                            : isWrong
                                                ? const Color(0xFFEF4444)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.black, width: 2.0),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        letter,
                                        style: GoogleFonts.bricolageGrotesque(
                                          color: (isCorrect || isWrong) ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        q.options[idx],
                                        style: GoogleFonts.inter(
                                          color: textCol,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    trailing,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Shutter Submission Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: BrutalButton(
                fullWidth: true,
                onPressed: _pickedIndex == null ? null : _handleAnswer,
                variant: _submitted ? BrutalButtonVariant.accent : BrutalButtonVariant.primary,
                child: Text(
                  _submitted
                      ? (_currentIndex == _questions.length - 1 ? 'LIHAT HASIL' : 'LANJUT')
                      : 'JAWAB',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(url, height: 180, width: double.infinity, fit: BoxFit.cover);
    }
    return Image.asset(url, height: 180, width: double.infinity, fit: BoxFit.cover);
  }
}

// ── Quiz Result Modal Dialog ────────────────────────────────────────────────

class _QuizResultModal extends StatelessWidget {
  final int score;
  final int total;
  final bool passed;
  final int xpReward;
  final VoidCallback onActionPressed;

  const _QuizResultModal({
    required this.score,
    required this.total,
    required this.passed,
    required this.xpReward,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.black, width: 2.0),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
            ),
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  passed ? 'Misi Quiz Selesai!' : 'Coba Lagi!',
                  style: AppTextStyles.display.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Skor kamu: ',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: '$score/$total',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // XP Reward Card (if passed)
                if (passed) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.brandBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 2.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          '+$xpReward XP',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action button
                BrutalButton(
                  fullWidth: true,
                  onPressed: onActionPressed,
                  variant: BrutalButtonVariant.primary,
                  child: Text(passed ? 'LANJUT' : 'ULANGI'),
                ),
              ],
            ),
          ),

          // Floating Emoji Icon on top
          Positioned(
            top: -40,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: passed ? const Color(0xFF34D399) : const Color(0xFFF87171), // emerald-400 or red-400
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2.0),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
              ),
              alignment: Alignment.center,
              child: Text(
                passed ? '🎉' : '💪',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
