import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';
import '../../models/badge_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/progress_view_model.dart';

class BadgeView extends ConsumerStatefulWidget {
  const BadgeView({super.key});

  @override
  ConsumerState<BadgeView> createState() => _BadgeViewState();
}

class _BadgeViewState extends ConsumerState<BadgeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(progressViewModelProvider.notifier).loadBadges());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressViewModelProvider);
    final user = ref.watch(authViewModelProvider).currentUser;

    if (state.allBadges.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: state.allBadges.length,
      itemBuilder: (context, index) {
        final badge = state.allBadges[index];
        final isEarned = user?.earnedBadgeIds.contains(badge.id) ?? false;

        return _BadgeCard(
          badge: badge,
          isEarned: isEarned,
          user: user,
        );
      },
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final bool isEarned;
  final dynamic user;

  const _BadgeCard({
    required this.badge,
    required this.isEarned,
    this.user,
  });

  String _getProgressText() {
    if (user == null) return '';
    switch (badge.badgeType) {
      case 'points':
        return '${user.points}/${badge.requiredPoints} XP';
      case 'completed_levels':
        return '${(user.completedLevels as List).length}/${badge.requiredLevels} level';
      case 'streak':
        return '${user.streakCount}/${badge.requiredStreak} hari';
      default:
        return '';
    }
  }

  double _getProgress() {
    if (user == null) return 0;
    switch (badge.badgeType) {
      case 'points':
        if (badge.requiredPoints == 0) return 1.0;
        return (user.points / badge.requiredPoints).clamp(0.0, 1.0);
      case 'completed_levels':
        if (badge.requiredLevels == 0) return 1.0;
        return ((user.completedLevels as List).length / badge.requiredLevels).clamp(0.0, 1.0);
      case 'streak':
        if (badge.requiredStreak == 0) return 1.0;
        return (user.streakCount / badge.requiredStreak).clamp(0.0, 1.0);
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned ? AppColors.brandPrimary : Colors.grey.shade300,
          width: isEarned ? 2 : 1,
        ),
        boxShadow: [
          if (isEarned)
            BoxShadow(
              color: AppColors.brandPrimary.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge icon
          ColorFiltered(
            colorFilter: isEarned
                ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                : const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0, 0, 0, 0.5, 0,
                  ]),
            child: badge.iconPath.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: badge.iconPath,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Icon(Icons.shield, size: 48, color: Colors.amber),
                    errorWidget: (context, url, error) => const Icon(Icons.shield, size: 48, color: Colors.amber),
                  )
                : const Icon(Icons.shield, size: 48, color: Colors.amber),
          ),
          const SizedBox(height: 8),

          // Badge title
          Text(
            badge.title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isEarned ? Colors.black : Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Badge description
          Text(
            badge.description,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Progress or earned indicator
          if (isEarned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '✓ Diperoleh',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandPrimary,
                ),
              ),
            )
          else ...[
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _getProgress(),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary.withValues(alpha: 0.6)),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getProgressText(),
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
