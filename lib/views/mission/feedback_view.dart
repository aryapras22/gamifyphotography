import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../view_models/challenge_view_model.dart';
import '../../view_models/badge_view_model.dart';
import '../widgets/animated_3d_button.dart';
import '../widgets/badge_unlock_sheet.dart';

class FeedbackView extends ConsumerStatefulWidget {
  const FeedbackView({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends ConsumerState<FeedbackView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newBadges = ref.read(badgeViewModelProvider).newlyUnlocked;
      if (newBadges.isNotEmpty && mounted) {
        showBadgeUnlockSheet(context, newBadges.first);
        ref.read(badgeViewModelProvider.notifier).clearNewlyUnlocked();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeViewModelProvider);
    final photoUrl = state.challenge?.uploadedPhotoUrl;
    final challengeTitle = state.challenge?.instruction ?? 'Misi Selesai';

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti background
            Lottie.asset(
              'assets/lottie/confetti.json',
              repeat: false,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),

            // Content column
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // ── Heading ───────────────────────────────────
                  Text(
                    'MISI SELESAI! 🎉',
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.bodyText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // ── Photo Preview ──────────────────────────────
                  _PhotoPreview(photoUrl: photoUrl),
                  const SizedBox(height: 28),

                  // ── Pending Review Card ────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.lensGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.lensGold, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hourglass_top_rounded,
                            color: AppColors.lensGold, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Foto terkirim!',
                                style: AppTextStyles.title
                                    .copyWith(color: AppColors.lensGold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Poin akan diberikan setelah admin menilai fotomu.',
                                style: AppTextStyles.body.copyWith(
                                    color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Technique label ────────────────────────────
                  if (challengeTitle.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.forestGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Teknik: $challengeTitle',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 40),

                  // ── Buttons ────────────────────────────────────
                  Animated3DButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    color: AppColors.brandBlue,
                    shadowColor: const Color(0xFF1590C8),
                    child: Text(
                      'MISI BERIKUTNYA →',
                      style: AppTextStyles.button,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      'Kembali ke Beranda',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widget: Photo Preview
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoPreview extends StatelessWidget {
  final String? photoUrl;
  const _PhotoPreview({this.photoUrl});

  bool get _isNetwork =>
      photoUrl != null &&
      (photoUrl!.startsWith('http://') || photoUrl!.startsWith('https://'));

  bool get _isLocalFile =>
      photoUrl != null &&
      photoUrl!.isNotEmpty &&
      !_isNetwork &&
      File(photoUrl!).existsSync();

  bool get _hasPhoto => _isNetwork || _isLocalFile;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: _hasPhoto
          ? (_isNetwork
              ? Image.network(
                  photoUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 220,
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
                  errorBuilder: (_, __, ___) => _buildEmpty(),
                )
              : Image.file(
                  File(photoUrl!),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildEmpty(),
                ))
          : _buildEmpty(),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 220,
      width: double.infinity,
      color: AppColors.backgroundGray,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined,
              size: 56, color: AppColors.disabled),
          const SizedBox(height: 8),
          const Text('Tidak ada foto',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
        ],
      ),
    );
  }
}
