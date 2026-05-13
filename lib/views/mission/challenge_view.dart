import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import '../../view_models/challenge_view_model.dart';
import '../../view_models/mission_view_model.dart';
import '../widgets/animated_3d_button.dart';
import 'custom_camera_view.dart';
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
    final state = ref.watch(challengeViewModelProvider);
    final challenge = state.challenge;

    if (challenge == null) {
      return const Scaffold(
        body: Center(child: Text('No challenge available')),
      );
    }

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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(
                          File(challenge.uploadedPhotoUrl!),
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () async {
                          final XFile? xfile = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CustomCameraView(
                                moduleId: challenge.moduleId,
                              ),
                            ),
                          );

                          if (xfile != null) {
                            final moduleTitle = ref.read(missionViewModelProvider).activeModule?.title ?? challenge.moduleId;
                            // Hanya upload foto — user harus tap "CEK HASIL" secara eksplisit
                            await ref
                                .read(challengeViewModelProvider.notifier)
                                .uploadPhoto(xfile, moduleTitle: moduleTitle);
                            // TIDAK ada completeChallenge() di sini (fix BUG-09)
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 80,
                                color: AppColors.brandBlue,
                              ),
                              SizedBox(height: 16),
                              Text(
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

                    Animated3DButton(
                      color: hasPhoto
                          ? AppColors.forestGreen
                          : AppColors.cardBorder,
                      shadowColor: hasPhoto
                          ? const Color(0xFF2D8A00)
                          : const Color(0xFFC4C4C4),
                      onPressed: hasPhoto && !state.isUploading
                          ? () async {
                              await ref
                                  .read(challengeViewModelProvider.notifier)
                                  .completeChallenge();
                              if (mounted) {
                                context.push('/mission/feedback');
                              }
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
