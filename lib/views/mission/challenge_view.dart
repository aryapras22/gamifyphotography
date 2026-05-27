import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../view_models/challenge_view_model.dart';
import '../../view_models/mission_view_model.dart';
import '../../view_models/level_view_model.dart';
import '../../providers/submission_providers.dart';
import '../widgets/brutal_widgets.dart';
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
            backgroundColor: AppColors.brandDanger,
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
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    final submissionAsync = ref.watch(
      submissionStatusProvider(challenge.moduleId),
    );
    final submissionStatus = submissionAsync.valueOrNull?.status;
    final isPending = submissionStatus == 'pending';

    final hasPhoto =
        challenge.uploadedPhotoUrl != null &&
        challenge.uploadedPhotoUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.brandBg,
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
                      color: AppColors.brandInk,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2.0),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: hasPhoto ? 1.0 : 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.brandSuccess,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Instruction Card
                    BrutalCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'MISI KAMU:',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.brandPrimary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            challenge.instruction,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brandInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (hasPhoto)
                      // ── DISPLAY DESIGN NOTE (SPR-011) ─────────────────────────────────────
                      // Native 9:16 aspect ratio box - BoxFit.contain - no clip - raw border
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2.0),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                        ),
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
                                      child: const Center(
                                        child: CircularProgressIndicator(color: Colors.black),
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
                                final firestoreLevels = ref.read(levelViewModelProvider).firestoreLevels;
                                String? visualGuideUrl;
                                try {
                                  final fsLevel = firestoreLevels.firstWhere(
                                    (l) => l.id == challenge.moduleId,
                                  );
                                  visualGuideUrl = fsLevel.page2?.howToUseImageUrl;
                                } catch (_) {
                                  try {
                                    final doc = await FirebaseFirestore.instance.collection('modules').doc(challenge.moduleId).get();
                                    if (doc.exists) {
                                      final data = doc.data();
                                      if (data != null && data['page2'] is Map) {
                                        visualGuideUrl = data['page2']['howToUseImageUrl'] as String?;
                                      }
                                    }
                                  } catch (e) {
                                    debugPrint('Gagal fetch visual guide: $e');
                                  }
                                }

                                final XFile? xfile =
                                    await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CustomCameraView(
                                      moduleId: challenge.moduleId,
                                      visualGuideUrl: visualGuideUrl,
                                    ),
                                  ),
                                );
                                if (xfile != null) {
                                  await ref
                                      .read(challengeViewModelProvider.notifier)
                                      .uploadPhoto(xfile);
                                }
                              },
                        child: BrutalCard(
                          backgroundColor: Colors.white,
                          height: 240,
                          child: isPending
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.hourglass_top_rounded,
                                        size: 52, color: AppColors.brandAccent),
                                    const SizedBox(height: 12),
                                    Text(
                                      'MENUNGGU PENILAIAN',
                                      style: GoogleFonts.bricolageGrotesque(
                                        color: AppColors.brandAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Fotomu sedang ditinjau admin.',
                                      style: GoogleFonts.inter(
                                        color: AppColors.secondaryText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt_rounded,
                                        size: 64, color: AppColors.brandPrimary),
                                    const SizedBox(height: 12),
                                    Text(
                                      'AMBIL FOTO',
                                      style: GoogleFonts.bricolageGrotesque(
                                        color: AppColors.brandPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                    const SizedBox(height: 40),

                    if (isPending)
                      BrutalButton(
                        variant: BrutalButtonVariant.accent,
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
                        child: const Text('LIHAT STATUS FOTO →'),
                      )
                    else
                      BrutalButton(
                        variant: hasPhoto ? BrutalButtonVariant.accent : BrutalButtonVariant.secondary,
                        onPressed: hasPhoto && !state.isUploading
                            ? () {
                                if (mounted) context.push('/mission/feedback');
                              }
                            : () {},
                        child: state.isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.0),
                              )
                            : const Text('CEK HASIL'),
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
              size: 56, color: AppColors.disabled),
          SizedBox(height: 10),
          Text(
            'Gagal memuat foto',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
