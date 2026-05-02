import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../view_models/mission_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/challenge_view_model.dart';
import '../widgets/animated_3d_button.dart';

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

  String _getVisualGuideAsset(String moduleId) {
    // Extract nomor dari moduleId (M01 → 01, M12 → 12, dll)
    final numStr = moduleId.replaceAll('M', '').padLeft(2, '0');
    final path = 'assets/images/visual_guides/${numStr}_guide.svg';

    // Daftar yang sudah pasti ada (M01–M10)
    const available = {'M01','M02','M03','M04','M05','M06','M07','M08','M09','M10'};
    if (available.contains(moduleId)) {
      // Gunakan nama file eksisting (nama bisa berbeda per modul)
      switch (moduleId) {
        case 'M01': return 'assets/images/visual_guides/01_rule_of_thirds.svg';
        case 'M02': return 'assets/images/visual_guides/02_leading_lines.svg';
        case 'M03': return 'assets/images/visual_guides/03_framing.svg';
        case 'M04': return 'assets/images/visual_guides/04_symmetry.svg';
        case 'M05': return 'assets/images/visual_guides/05_golden_triangle.svg';
        case 'M06': return 'assets/images/visual_guides/06_negative_space.svg';
        case 'M07': return 'assets/images/visual_guides/07_rule_of_odds.svg';
        case 'M08': return 'assets/images/visual_guides/08_depth_of_field.svg';
        case 'M09': return 'assets/images/visual_guides/09_point_of_view.svg';
        case 'M10': return 'assets/images/visual_guides/10_center_dominance.svg';
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
      return const Scaffold(body: Center(child: Text('No module selected')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Bar ────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_currentPage > 0) {
                            _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                          } else {
                            context.pop();
                          }
                        },
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4B4B4B), size: 24),
                      ),
                      const SizedBox(width: 12),
                      _badge('Level ${module.order}'),
                    ],
                  ),
                  _badge('Poin $points', icon: Icons.star_rounded, iconColor: const Color(0xFFFFC800)),
                ],
              ),
            ),

            // ── Progress Dots ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFF1CB0F6) : const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),

            // ── PageView ───────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Only button navigation
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
                    color: Color(0xFF4B4B4B),
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
                      color: Color(0xFF4B4B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: CustomPaint(painter: _SamplePhotoPainter()),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Animated3DButton(
            onPressed: () {
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
            child: const Text(
              'LANJUT',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
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
                    color: Color(0xFF4B4B4B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  module.description,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4B4B4B),
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
                          border: Border.all(color: const Color(0xFF4B4B4B), width: 3),
                          boxShadow: const [
                            BoxShadow(color: Color(0xFFD0D0D0), offset: Offset(0, 6), blurRadius: 12),
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
                                    color: const Color(0xFF4B4B4B),
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
                          color: Color(0xFF1CB0F6),
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
          child: Animated3DButton(
            onPressed: () async {
              await ref.read(challengeViewModelProvider.notifier).loadChallenge(module.id);
              if (context.mounted) {
                context.push('/mission/challenge');
              }
            },
            child: const Text(
              'MULAI CHALLENGE',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(String label, {IconData? icon, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4B4B4B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
          ],
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

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
      canvas.drawLine(Offset(thirdW * i, 0), Offset(thirdW * i, size.height), gridPaint);
      canvas.drawLine(Offset(0, thirdH * i), Offset(size.width, thirdH * i), gridPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

