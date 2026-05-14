import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/photo_submission_model.dart';
import '../../providers/submission_providers.dart';
import '../widgets/animated_3d_button.dart';

class SubmissionStatusView extends ConsumerStatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const SubmissionStatusView({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  ConsumerState<SubmissionStatusView> createState() =>
      _SubmissionStatusViewState();
}

class _SubmissionStatusViewState extends ConsumerState<SubmissionStatusView> {
  @override
  Widget build(BuildContext context) {
    final submissionAsync = ref.watch(submissionStatusProvider(widget.moduleId));

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        title: Text(widget.moduleTitle, style: AppTextStyles.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.bodyText),
          onPressed: () => context.pop(),
        ),
      ),
      body: submissionAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.brandBlue),
        ),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.coralRed),
              const SizedBox(height: 16),
              Text('Failed to load submission status.',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.secondaryText)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.invalidate(submissionStatusProvider(widget.moduleId)),
                child: Text('Retry',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.brandBlue)),
              ),
            ],
          ),
        ),
        data: (submission) =>
            submission == null ? _buildNoSubmission() : _buildStatusCard(submission),
      ),
    );
  }

  Widget _buildNoSubmission() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined,
              size: 64, color: AppColors.disabled),
          const SizedBox(height: 16),
          Text('Belum ada foto untuk modul ini.',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 24),
          Animated3DButton(
            color: AppColors.brandBlue,
            shadowColor: const Color(0xFF1590C8),
            onPressed: () => context.pop(),
            child: Text('Ambil Foto', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(PhotoSubmissionModel submission) {
    final status = submission.status;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Foto submission
          // ── DISPLAY DESIGN NOTE (SPR-011) ───────────────────────────────────────
          // The submission result page is the primary moment where both the student
          // and admin evaluate the submitted photograph against the mission criteria.
          // Displaying a cropped thumbnail destroys the learning feedback loop.
          // Full 9:16 portrait ratio is enforced — zero crop, zero rounded clipping.
          // ─────────────────────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: Image.network(
                submission.photoUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.backgroundGray,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Container(
                    color: AppColors.backgroundGray,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_rounded,
                            size: 56, color: AppColors.disabled),
                        SizedBox(height: 12),
                        Text(
                          'Gagal memuat foto',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Status banner
          _StatusBanner(status: status),
          const SizedBox(height: 24),

          // Skor (hanya jika approved)
          if (status == 'approved' && submission.adminScore != null)
            _ScoreCard(score: submission.adminScore!),

          if (status == 'approved' && submission.adminNote != null && submission.adminNote!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandBlue,
                  side: const BorderSide(color: AppColors.brandBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => context.push('/mission/feedback'),
                icon: const Icon(Icons.comment_outlined, size: 18),
                label: Text('Lihat Feedback Lengkap', style: AppTextStyles.button.copyWith(
                  color: AppColors.brandBlue,
                  fontSize: 14,
                )),
              ),
            ),

          // Komentar admin
          if (submission.adminNote != null && submission.adminNote!.isNotEmpty)
            _AdminNoteCard(
                note: submission.adminNote!, isRejected: status == 'rejected'),

          const SizedBox(height: 32),

          // Tombol aksi
          if (status == 'rejected')
            Animated3DButton(
              color: AppColors.brandBlue,
              shadowColor: const Color(0xFF1590C8),
              onPressed: () {
                // Kembali ke challenge view untuk foto ulang
                context.pop();
              },
              child: Text('Foto Ulang', style: AppTextStyles.button),
            ),
          if (status != 'rejected')
            Animated3DButton(
              color: AppColors.forestGreen,
              shadowColor: const Color(0xFF2D8A00),
              onPressed: () => context.go('/home'),
              child: Text('Ke Beranda', style: AppTextStyles.button),
            ),

          const SizedBox(height: 12),
          Text(
            'Dikirim: ${_formatDate(submission.submittedAt)}',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          if (submission.reviewedAt != null)
            Text(
              'Dinilai: ${_formatDate(submission.reviewedAt!)}',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      'approved' => (
          icon: Icons.check_circle_rounded,
          color: AppColors.forestGreen,
          label: 'FOTO DISETUJUI ✅',
          sub: 'Admin sudah menilai fotomu.',
        ),
      'rejected' => (
          icon: Icons.cancel_rounded,
          color: AppColors.coralRed,
          label: 'FOTO DITOLAK',
          sub: 'Silakan ambil foto ulang.',
        ),
      _ => (
          icon: Icons.hourglass_top_rounded,
          color: AppColors.lensGold,
          label: 'MENUNGGU PENILAIAN ⏳',
          sub: 'Admin sedang memeriksa fotomu. Kamu tetap bisa lanjut ke misi lain.',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color, width: 2),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.color, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(config.label,
                    style: AppTextStyles.title
                        .copyWith(color: config.color)),
                const SizedBox(height: 4),
                Text(config.sub,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  const _ScoreCard({required this.score});

  Color get _scoreColor {
    if (score >= 80) return AppColors.forestGreen;
    if (score >= 60) return AppColors.lensGold;
    return AppColors.coralRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.lensGold, size: 32),
          const SizedBox(width: 12),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: score),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              '$value / 100',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: _scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNoteCard extends StatelessWidget {
  final String note;
  final bool isRejected;
  const _AdminNoteCard({required this.note, required this.isRejected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment_rounded,
                size: 18,
                color: isRejected ? AppColors.coralRed : AppColors.brandBlue,
              ),
              const SizedBox(width: 8),
              Text('Komentar Admin',
                  style: AppTextStyles.title.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(note,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}
