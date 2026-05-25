// lib/views/quiz/quiz_result_view.dart
// TASK-05 — Quiz Result Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../models/level_model.dart';
import '../../view_models/level_view_model.dart';

class QuizResultView extends ConsumerStatefulWidget {
  final LevelConfig config;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final List<int> answers;

  const QuizResultView({
    Key? key,
    required this.config,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.answers,
  }) : super(key: key);

  @override
  ConsumerState<QuizResultView> createState() => _QuizResultViewState();
}

class _QuizResultViewState extends ConsumerState<QuizResultView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _saved = false;

  bool get _passed => widget.score >= widget.config.passingScore;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();
    _saveResult();
  }

  Future<void> _saveResult() async {
    if (_saved) return;
    _saved = true;
    await ref.read(levelViewModelProvider.notifier).submitQuizResult(
      levelNumber: widget.config.levelNumber,
      score: widget.score,
      answers: widget.answers,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Animated result icon
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: _passed
                        ? AppColors.forestGreen.withValues(alpha: 0.12)
                        : AppColors.coralRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _passed ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
                      size: 64,
                      color: _passed ? AppColors.forestGreen : AppColors.coralRed,
                    ),
                  ),
                ),
              ),
              // Status text
              Text(
                _passed ? 'Selamat! Kamu Lulus 🎉' : 'Belum Lulus',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _passed ? AppColors.forestGreen : AppColors.coralRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.config.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              // Score card
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), offset: Offset(0, 8), blurRadius: 16),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${widget.score}',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: _passed ? AppColors.forestGreen : AppColors.coralRed,
                        height: 1,
                      ),
                    ),
                    const Text(
                      '/ 100',
                      style: TextStyle(fontSize: 20, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatChip(
                          label: 'Benar',
                          value: '${widget.correctAnswers}',
                          color: AppColors.forestGreen,
                        ),
                        _StatChip(
                          label: 'Salah',
                          value: '${widget.totalQuestions - widget.correctAnswers}',
                          color: AppColors.coralRed,
                        ),
                        _StatChip(
                          label: 'Passing',
                          value: '${widget.config.passingScore}',
                          color: AppColors.lensGold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Info message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _passed
                      ? AppColors.forestGreen.withValues(alpha: 0.08)
                      : AppColors.lensGold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _passed
                        ? AppColors.forestGreen.withValues(alpha: 0.3)
                        : AppColors.lensGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _passed
                      ? 'Level berikutnya sudah terbuka. Terus semangat belajar!'
                      : 'Kamu perlu skor minimal ${widget.config.passingScore} untuk melanjutkan. Pelajari lagi materinya dan coba lagi!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _passed ? AppColors.forestGreen : AppColors.lensGold,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              // Action buttons
              if (_passed)
                ElevatedButton(
                  onPressed: () {
                    // Pop back to progress screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: AppColors.surfaceWhite,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lanjut ke Level Berikutnya',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                )
              else ...[
                ElevatedButton(
                  onPressed: () {
                    // Pop result, then pop quiz → back to level list
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lensGold,
                    foregroundColor: AppColors.surfaceWhite,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text(
                    'Kembali ke Daftar Level',
                    style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
