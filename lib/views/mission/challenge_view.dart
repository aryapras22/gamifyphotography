import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import '../../view_models/challenge_view_model.dart';
import '../../view_models/mission_view_model.dart';
import '../../providers/submission_providers.dart';
import '../widgets/animated_3d_button.dart';
import 'custom_camera_view.dart';
import 'submission_status_view.dart';
import 'dart:io';
import '../../core/app_colors.dart';

class ChallengeView extends ConsumerStatefulWidget {
  const ChallengeView({super.key});

  @override
  ConsumerState<ChallengeView> createState() => _ChallengeViewState();
}

class _ChallengeViewState extends ConsumerState<ChallengeView> {
  @override
  Widget build(BuildContext context) {
    ref.listen<ChallengeState>(challengeViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.coralRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final state = ref.watch(challengeViewModelProvider);
    final challenge = state.challenge;

    if (challenge == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.brandBlue)),
      );
    }

    // Watch submission status to block camera when pending
    final submissionAsync = ref.watch(
      submissionStatusProvider(challenge.moduleId),
    );
    final submissionStatus = submissionAsync.valueOrNull?.status;
    final isPending = submissionStatus == 'pending';

    final hasPhoto =
        challenge.uploadedPhotoUrl != null &&
        challenge.uploadedPhotoUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            // Immersive Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 32,
                      color: AppColors.bodyText,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: hasPhoto ? 1.0 : 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32), // Balance
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardBorder,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'MISI KAMU:',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.brandBlue,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            challenge.instruction,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.bodyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (hasPhoto)
                      // ── DISPLAY DESIGN NOTE (SPR-011) ─────────────────────────────────────
                      // User submissions are portrait photos (9:16). We display them at their
                      // native ratio so the student and admin can assess the full composition:
                      // horizon placement, subject framing, depth gradient to the edges.
                      // BoxFit.cover and fixed heights are banned — they silently hide evidence.
                      // ClipRRect removed — rounded corners misrepresent the photographic frame.
                      // ─────────────────────────────────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: _isNetworkUrl(challenge.uploadedPhotoUrl)
                              ? Image.network(
                                  challenge.uploadedPhotoUrl!,
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
                                  errorBuilder: (_, __, ___) =>
                                      const _PhotoErrorPlaceholder(),
                                )
                              : Image.file(
                                  File(challenge.uploadedPhotoUrl!),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const _PhotoErrorPlaceholder(),
                                ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: isPending
                            ? null
                            : () async {
                                final XFile? xfile =
                                    await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CustomCameraView(
                                      moduleId: challenge.moduleId,
                                    ),
                                  ),
                                );
                                if (xfile != null) {
                                  await ref
                                      .read(challengeViewModelProvider.notifier)
                                      .uploadPhoto(xfile);
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.cardBorder,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: isPending
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.hourglass_top_rounded,
                                        size: 64, color: AppColors.lensGold),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'MENUNGGU PENILAIAN',
                                      style: TextStyle(
                                        color: AppColors.lensGold,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Fotomu sedang ditinjau admin.',
                                      style: TextStyle(
                                        color: AppColors.secondaryText,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt_rounded,
                                        size: 80, color: AppColors.brandBlue),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'AMBIL FOTO',
                                      style: TextStyle(
                                        color: AppColors.brandBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                    const SizedBox(height: 40),

                    if (isPending)
                      Animated3DButton(
                        color: AppColors.lensGold,
                        shadowColor: const Color(0xFFB8860B),
                        onPressed: () {
                          final moduleTitle = ref
                                  .read(missionViewModelProvider)
                                  .activeModule
                                  ?.title ??
                              challenge.moduleId;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubmissionStatusView(
                                moduleId: challenge.moduleId,
                                moduleTitle: moduleTitle,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'LIHAT STATUS FOTO →',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      )
                    else
                      Animated3DButton(
                        color: hasPhoto
                            ? AppColors.forestGreen
                            : AppColors.cardBorder,
                        shadowColor: hasPhoto
                            ? const Color(0xFF2D8A00)
                            : const Color(0xFFC4C4C4),
                        onPressed: hasPhoto && !state.isUploading
                            ? () {
                                if (mounted) context.push('/mission/feedback');
                              }
                            : () {},
                        child: state.isUploading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'CEK HASIL',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: hasPhoto
                                      ? Colors.white
                                      : AppColors.disabled,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isNetworkUrl(String? url) =>
    url != null && (url.startsWith('http://') || url.startsWith('https://'));

class _PhotoErrorPlaceholder extends StatelessWidget {
  const _PhotoErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundGray,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded,
              size: 64, color: AppColors.disabled),
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
    );
  }
}
