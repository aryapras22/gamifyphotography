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

                  // ── Rolling Points Counter ─────────────────────
                  if (state.pointsEarned > 0)
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: state.pointsEarned),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      builder: (context, value, _) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.forestGreen,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.diamond_rounded,
                              color: AppColors.forestGreen,
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '+$value poin',
                              style: AppTextStyles.display.copyWith(
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      'Misi Selesai!',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.forestGreen,
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

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        photoUrl != null &&
        photoUrl!.isNotEmpty &&
        File(photoUrl!).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: hasPhoto
          ? Image.file(
              File(photoUrl!),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              height: 220,
              width: double.infinity,
              color: AppColors.backgroundGray,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 56,
                    color: AppColors.disabled,
                  ),
                  const SizedBox(height: 8),
                  Text('Tidak ada foto', style: AppTextStyles.caption),
                ],
              ),
            ),
    );
  }
}
