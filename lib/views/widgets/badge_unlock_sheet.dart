import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/badge_model.dart';

/// Tampilkan bottom sheet saat badge baru di-unlock.
/// Panggil dari FeedbackView via initState + postFrameCallback.
void showBadgeUnlockSheet(BuildContext context, BadgeModel badge) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _BadgeUnlockContent(badge: badge),
  );
}

class _BadgeUnlockContent extends StatelessWidget {
  final BadgeModel badge;

  const _BadgeUnlockContent({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 24),

          // Animated badge icon — elastic scale-in
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, value, child) =>
                Transform.scale(scale: value, child: child),
            child: SvgPicture.asset(badge.iconPath, width: 80, height: 80),
          ),
          const SizedBox(height: 16),

          Text('🏅 LENCANA BARU!', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(badge.title, style: AppTextStyles.heading),
          const SizedBox(height: 8),
          Text(
            badge.description,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keren!', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}
