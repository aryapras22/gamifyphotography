import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../view_models/onboarding_view_model.dart';

class _SlideData {
  final IconData icon;
  final Color iconColor;
  final String headline;
  final String subtitle;

  const _SlideData({
    required this.icon,
    required this.iconColor,
    required this.headline,
    required this.subtitle,
  });
}

const _slides = [
  _SlideData(
    icon: Icons.camera_alt_rounded,
    iconColor: AppColors.brandBlue,
    headline: 'Kuasai Teknik Foto Profesional',
    subtitle:
        'Pelajari Rule of Thirds, Leading Lines, dan 30+ teknik lainnya',
  ),
  _SlideData(
    icon: Icons.emoji_events_rounded,
    iconColor: AppColors.lensGold,
    headline: 'Praktik Langsung, Dapat Hadiah',
    subtitle:
        'Setiap teori diikuti tantangan foto nyata — selesaikan dan kumpulkan poin',
  ),
  _SlideData(
    icon: Icons.leaderboard_rounded,
    iconColor: AppColors.forestGreen,
    headline: 'Bersaing & Berkembang Bersama',
    subtitle:
        'Raih lencana, naiki papan peringkat, dan bangun jembatan kreativitasmu',
  ),
];

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

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipToLast() {
    _pageController.animateToPage(
      _slides.length - 1,
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
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar with Skip ──────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AnimatedOpacity(
                  opacity: isLastPage ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: isLastPage ? null : _skipToLast,
                    child: Text(
                      'Lewati',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView ───────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _OnboardingSlide(slide: slide);
                },
              ),
            ),

            // ── Dot Indicator ──────────────────────────────────
            _DotIndicator(
              count: _slides.length,
              currentIndex: _currentPage,
            ),
            const SizedBox(height: 24),

            // ── Action Buttons ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandBlue,
                        foregroundColor: AppColors.surfaceWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                  // "Sudah punya akun?" hanya di slide terakhir
                  if (isLastPage) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Sudah punya akun? Masuk',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widget: Single Slide
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  final _SlideData slide;

  const _OnboardingSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background pill
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: slide.iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 80, color: slide.iconColor),
          ),
          const SizedBox(height: 40),
          Text(
            slide.headline,
            style: AppTextStyles.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widget: Dot Indicator
// ─────────────────────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _DotIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.brandBlue : AppColors.disabled,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
