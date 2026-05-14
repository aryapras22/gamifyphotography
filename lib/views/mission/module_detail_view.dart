import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_colors.dart';
import '../../view_models/mission_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/challenge_view_model.dart';
import '../../providers/submission_providers.dart';
import '../../models/photo_submission_model.dart';
import '../widgets/animated_3d_button.dart';
import '../../core/app_text_styles.dart';
class ModuleDetailView extends ConsumerStatefulWidget {
  const ModuleDetailView({Key? key}) : super(key: key);

  @override
  ConsumerState<ModuleDetailView> createState() => _ModuleDetailViewState();
}

class _ModuleDetailViewState extends ConsumerState<ModuleDetailView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Returns the list of asset paths for example photos for the given module level.
  /// File naming convention: assets/images/examples/LEVEL {N}-({i}).jpg
  static List<String> _getExamplePhotoPaths(int level) {
    const counts = <int, int>{
      1: 4, 2: 4, 3: 4, 4: 2,
      5: 4, 6: 3, 7: 4, 8: 3,
      9: 4,
      // 10: missing — fallback below
      11: 4, 12: 3, 13: 3,
    };

    final count = counts[level];
    if (count == null || count == 0) {
      // TODO: add LEVEL 10 example photos to assets/images/examples/
      // Fallback to Level 1
      return List.generate(
        4,
        (i) => 'assets/images/examples/LEVEL 1-(${i + 1}).jpg',
      );
    }
    return List.generate(
      count,
      (i) => 'assets/images/examples/LEVEL $level-(${i + 1}).jpg',
    );
  }

  String _getVisualGuideAsset(String moduleId) {
    // Extract nomor dari moduleId (M01 → 01, M12 → 12, dll)
    // final numStr = moduleId.replaceAll('M', '').padLeft(2, '0');
    // final path = 'assets/images/visual_guides/${numStr}_guide.svg';

    // Daftar yang sudah pasti ada (M01–M10)
    const available = {
      'M01',
      'M02',
      'M03',
      'M04',
      'M05',
      'M06',
      'M07',
      'M08',
      'M09',
      'M10',
    };
    if (available.contains(moduleId)) {
      // Gunakan nama file eksisting (nama bisa berbeda per modul)
      switch (moduleId) {
        case 'M01':
          return 'assets/images/visual_guides/01_rule_of_thirds.svg';
        case 'M02':
          return 'assets/images/visual_guides/02_leading_lines.svg';
        case 'M03':
          return 'assets/images/visual_guides/03_framing.svg';
        case 'M04':
          return 'assets/images/visual_guides/04_symmetry.svg';
        case 'M05':
          return 'assets/images/visual_guides/05_golden_triangle.svg';
        case 'M06':
          return 'assets/images/visual_guides/06_negative_space.svg';
        case 'M07':
          return 'assets/images/visual_guides/07_rule_of_odds.svg';
        case 'M08':
          return 'assets/images/visual_guides/08_depth_of_field.svg';
        case 'M09':
          return 'assets/images/visual_guides/09_point_of_view.svg';
        case 'M10':
          return 'assets/images/visual_guides/10_center_dominance.svg';
      }
    }
    // Fallback eksplisit dengan komentar — bukan diam-diam pakai M01
    debugPrint('WARNING: No visual guide asset for $moduleId — using fallback');
    return 'assets/images/visual_guides/01_rule_of_thirds.svg';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missionViewModelProvider);
    final module = state.activeModule;
    final authState = ref.watch(authViewModelProvider);
    final points = authState.currentUser?.points ?? 0;

    if (module == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.brandBlue)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Bar ────────────────────────────────────────────────
            Container(
              color: AppColors.surfaceWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_currentPage > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            context.pop();
                          }
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.bodyText,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _badge('Level ${module.order}'),
                    ],
                  ),
                  _badge(
                    'Poin $points',
                    icon: Icons.star_rounded,
                    iconColor: AppColors.lensGold,
                  ),
                ],
              ),
            ),

            // ── Progress Dots ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.brandBlue
                          : AppColors.disabled,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView ───────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Only button navigation
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildTheoryPage(module),
                  _buildVisualGuidePage(module, ref, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTheoryPage(module) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  module.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.bodyText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    module.materialContent,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _ExamplePhotoGallery(
                  photoPaths: _getExamplePhotoPaths(module.order as int),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Animated3DButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text(
              'LANJUT',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.surfaceWhite,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualGuidePage(module, WidgetRef ref, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cara Menggunakan:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.bodyText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  module.description,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.bodyText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 36),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 180,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.bodyText,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.disabled,
                              offset: Offset(0, 6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(21),
                          child: Stack(
                            children: [
                              // The SVG image acting as visual guide
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    _getVisualGuideAsset(module.id),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // Top speaker wireframe to make it look like a phone
                              Align(
                                alignment: const Alignment(0, -0.85),
                                child: Container(
                                  width: 36,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.bodyText,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Visual Guide ${module.title}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.brandBlue,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: _buildActionPanel(context, module),
        ),
      ],
    );
  }

  /// Builds the bottom action area for the challenge page.
  /// • If submitted → show status card (pending/approved/rejected)
  /// • If not submitted → show MULAI CHALLENGE button
  Widget _buildActionPanel(BuildContext context, module) {
    final submissionAsync = ref.watch(submissionStatusProvider(module.id));
    return submissionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        debugPrint('[SubmissionStatus] stream error for ${module.id}: $e');
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.coralRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.coralRed.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.coralRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cannot load submission status. Check your connection.',
                  style: TextStyle(fontSize: 13, color: AppColors.coralRed),
                ),
              ),
            ],
          ),
        );
      },
      data: (submission) {
        if (submission == null) {
          return _buildStartChallengeButton(context, module.id);
        }
        return switch (submission.status) {
          'pending' => _PendingReviewCard(submission: submission),
          'approved' => _ApprovedResultCard(submission: submission),
          'rejected' => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RejectedResultCard(submission: submission),
                const SizedBox(height: 12),
                _buildStartChallengeButton(context, module.id, isRetry: true),
              ],
            ),
          _ => _buildStartChallengeButton(context, module.id),
        };
      },
    );
  }

  Widget _buildStartChallengeButton(
    BuildContext context,
    String moduleId, {
    bool isRetry = false,
  }) {
    return Animated3DButton(
      color: AppColors.brandBlue,
      shadowColor: const Color(0xFF1590C8),
      onPressed: () async {
        await ref
            .read(challengeViewModelProvider.notifier)
            .loadChallenge(moduleId);
        if (context.mounted) {
          context.push('/mission/challenge');
        }
      },
      child: Text(
        isRetry ? 'KIRIM ULANG FOTO →' : 'MULAI CHALLENGE',
        style: AppTextStyles.button,
      ),
    );
  }

  Widget _badge(String label, {IconData? icon, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bodyText,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: AppColors.surfaceWhite,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Submission Status Cards ──────────────────────────────────────────────────

class _PendingReviewCard extends StatelessWidget {
  final PhotoSubmissionModel submission;
  const _PendingReviewCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    final submittedAt = submission.submittedAt;
    final formatted =
        '${submittedAt.day} ${_month(submittedAt.month)} ${submittedAt.year}, '
        '${submittedAt.hour.toString().padLeft(2, '0')}:'
        '${submittedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.xpAmber, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule_rounded, color: AppColors.xpAmber, size: 20),
              SizedBox(width: 8),
              Text(
                'Menunggu Review Admin',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Foto kamu sedang ditinjau. Kamu tetap bisa melanjutkan misi berikutnya!',
            style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 10),
          Text(
            'Dikirim: $formatted',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (submission.photoUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(submission.photoUrl,
                        fit: BoxFit.contain),
                  ),
                ),
              ),
              child: const Text(
                'Lihat Foto',
                style: TextStyle(
                  color: AppColors.brandBlue,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.brandBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ][m];
}

class _ApprovedResultCard extends StatelessWidget {
  final PhotoSubmissionModel submission;
  const _ApprovedResultCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    final score = submission.adminScore ?? 0;
    final note = submission.adminNote;
    final reviewedAt = submission.reviewedAt;
    final formattedDate = reviewedAt != null
        ? '${reviewedAt.day}/${reviewedAt.month}/${reviewedAt.year} '
            '${reviewedAt.hour.toString().padLeft(2, '0')}:'
            '${reviewedAt.minute.toString().padLeft(2, '0')}'
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.forestGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.forestGreen, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.forestGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Foto Disetujui!',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.forestGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Skor Admin',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText)),
              Text('$score / 100',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.forestGreen)),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.backgroundGray,
              color: AppColors.forestGreen,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Catatan:',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bodyText)),
            const SizedBox(height: 4),
            Text('"$note"',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    fontStyle: FontStyle.italic)),
          ],
          if (formattedDate != null) ...[
            const SizedBox(height: 10),
            Text('Ditinjau: $formattedDate',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

class _RejectedResultCard extends StatelessWidget {
  final PhotoSubmissionModel submission;
  const _RejectedResultCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    final note = submission.adminNote;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.coralRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.coralRed, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cancel_rounded, color: AppColors.coralRed, size: 20),
              SizedBox(width: 8),
              Text('Foto Ditolak',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.coralRed)),
            ],
          ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('Catatan Admin:',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bodyText)),
            const SizedBox(height: 4),
            Text('"$note"',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

/// Swipeable gallery of real reference example photos for a module level.
/// Renders every photo at its native 16:9 landscape ratio — zero crop, zero clipping.
class _ExamplePhotoGallery extends StatefulWidget {
  final List<String> photoPaths;
  const _ExamplePhotoGallery({required this.photoPaths});

  @override
  State<_ExamplePhotoGallery> createState() => _ExamplePhotoGalleryState();
}

class _ExamplePhotoGalleryState extends State<_ExamplePhotoGallery> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.photoPaths.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contoh Foto:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 10),

        // ── DISPLAY DESIGN NOTE (SPR-011) ─────────────────────────────────
        // Photography training requires users to evaluate the full, unaltered
        // frame. Cropping destroys composition evidence. We use AspectRatio(16:9)
        // so the image fills the column width while revealing every pixel.
        // Rounded corners removed — the frame edge IS the photographic boundary.
        // Reference: Nielsen Norman Group — "Images in UX" (2024)
        // ─────────────────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _controller,
              itemCount: total,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (context, index) {
                return Image.asset(
                  widget.photoPaths[index],
                  fit: BoxFit.contain,  // NEVER use cover — see note above
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.backgroundGray,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        size: 48,
                        color: AppColors.disabled,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        if (total > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              total,
              (i) => GestureDetector(
                onTap: () => _controller.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _current == i
                        ? AppColors.brandBlue
                        : AppColors.disabled,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${_current + 1} / $total',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ignore: unused_element
class _SamplePhotoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD4A44C), Color(0xFF8B6914), Color(0xFF5C3D0A)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    final thirdW = size.width / 3;
    final thirdH = size.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(thirdW * i, 0),
        Offset(thirdW * i, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, thirdH * i),
        Offset(size.width, thirdH * i),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
