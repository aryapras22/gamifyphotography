import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../view_models/onboarding_view_model.dart';
import '../widgets/brutal_widgets.dart';

class _SlideData {
  final String headline;
  final String subtitle;
  final Widget illustration;

  const _SlideData({
    required this.headline,
    required this.subtitle,
    required this.illustration,
  });
}

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(int totalSlides) {
    if (_currentPage < totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipToLast(int totalSlides) {
    _pageController.animateToPage(
      totalSlides - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingViewModelProvider.notifier).markOnboardingDone();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      _SlideData(
        headline: 'Belajar Fotografi dengan Cara Seru',
        subtitle: 'Pelajari teknik fotografi lewat modul interaktif yang menyenangkan.',
        illustration: const _Slide1Illustration(),
      ),
      _SlideData(
        headline: 'Praktik Langsung dengan Panduan',
        subtitle: 'Gunakan panduan visual kamera untuk mengambil foto sesuai teknik yang dipelajari.',
        illustration: const _Slide2Illustration(),
      ),
      _SlideData(
        headline: 'Bersaing & Raih Badge',
        subtitle: 'Kumpulkan XP, naiki level, dan puncaki papan peringkat.',
        illustration: const _Slide3Illustration(),
      ),
    ];

    final isLastPage = _currentPage == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AnimatedOpacity(
                  opacity: isLastPage ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: isLastPage ? null : () => _skipToLast(slides.length),
                    child: Text(
                      'Lewati',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondaryText,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: slide.illustration,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          slide.headline,
                          style: AppTextStyles.display.copyWith(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.subtitle,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator and Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (idx) {
                      final active = idx == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? AppColors.brandPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black, width: 2.0),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  BrutalButton(
                    fullWidth: true,
                    onPressed: () => _nextPage(slides.length),
                    variant: BrutalButtonVariant.primary,
                    child: Text(
                      isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                    ),
                  ),
                  if (isLastPage) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Sudah punya akun? ',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Masuk',
                              style: GoogleFonts.inter(
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 48), // Keep size parity
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide1Illustration extends StatelessWidget {
  const _Slide1Illustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Accent Card
          Positioned(
            left: 20,
            top: 20,
            right: 20,
            bottom: 20,
            child: Transform.rotate(
              angle: -0.07,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.brandAccent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 2.0),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(6, 6)),
                  ],
                ),
              ),
            ),
          ),
          // Front Card with Camera
          Positioned(
            left: 36,
            top: 36,
            right: 36,
            bottom: 36,
            child: Transform.rotate(
              angle: 0.035,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 80,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // XP pill
          Positioned(
            top: 16,
            left: 24,
            child: Transform.rotate(
              angle: -0.21,
              child: const BrutalXPPill(amount: 50),
            ),
          ),
          // Sparkle symbols
          const Positioned(
            top: 0,
            right: 12,
            child: Text(
              '✨',
              style: TextStyle(fontSize: 32),
            ),
          ),
          const Positioned(
            bottom: 12,
            left: 8,
            child: Text(
              '✨',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide2Illustration extends StatelessWidget {
  const _Slide2Illustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 230,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.brandAccent,
            offset: Offset(6, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2.0),
          gradient: const LinearGradient(
            colors: [Color(0xFFFED7AA), Color(0xFFF472B6)], // orange-200 to pink-400
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Grid Overlay lines
            Positioned.fill(
              child: GridPaper(
                color: Colors.white.withOpacity(0.4),
                divisions: 1,
                subdivisions: 1,
                interval: 500, // Large grid simulation
              ),
            ),
            // Precise custom Grid lines for 3x3 layout
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
            // Recording dot
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.brandDanger,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.0;

    // Draw vertical lines
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);

    // Draw horizontal lines
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Slide3Illustration extends StatelessWidget {
  const _Slide3Illustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Rank 2
              Container(
                width: 56,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  '2',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Rank 1
              Container(
                width: 64,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.brandAccent,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.emoji_events_rounded, size: 36, color: Colors.black),
                    SizedBox(height: 8),
                    Text(
                      '1',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Rank 3
              Container(
                width: 56,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  '3',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          // Gold crown float above center
          Positioned(
            top: 24,
            child: Transform.rotate(
              angle: 0.1,
              child: const Text('👑', style: TextStyle(fontSize: 28)),
            ),
          ),
        ],
      ),
    );
  }
}
