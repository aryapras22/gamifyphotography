// lib/views/profile/profile_view.dart
// TASK-06 â€” ProfileView

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_text_styles.dart';
import '../../core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../view_models/profile_view_model.dart';
import '../../models/badge_model.dart';


class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.bodyText),
                onPressed: () => context.pop(),
              )
            : null,
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        title: Text(
          'PROFIL',
          style: AppTextStyles.heading.copyWith(letterSpacing: 1.5),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandBlue))
          : state.user == null
              ? _buildErrorState(state.errorMessage)
              : RefreshIndicator(
                  color: AppColors.brandBlue,
                  onRefresh: () =>
                      ref.read(profileViewModelProvider.notifier).refreshProfile(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      _ProfileHeader(user: state.user!),
                      const SizedBox(height: 24),
                      _BadgeSection(
                        allBadges: state.allBadges,
                        earnedBadgeIds: state.earnedBadgeIds,
                      ),
                      const SizedBox(height: 24),
                      _PhotoSection(
                        photoUrls: state.completedChallengePhotoUrls,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_rounded, size: 64, color: AppColors.disabled),
          const SizedBox(height: 16),
          Text(
            message ?? 'Terjadi kesalahan.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.disabled, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widget: Header (avatar, nama, email, poin, level)
// ---------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  final dynamic user; // UserModel

  const _ProfileHeader({required this.user});

  String get _initials {
    final name = (user.name as String).trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.brandBlue,
          child: Text(
            _initials,
            style: AppTextStyles.display.copyWith(color: AppColors.surfaceWhite),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.name as String,
          style: AppTextStyles.title.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(
          user.email as String,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 20),
        // Poin & Level cards
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatCard(label: 'Poin', value: user.points as int, isPoints: true),
            const SizedBox(width: 16),
            _StatCard(label: 'Level', value: 'Lv.${user.level}'),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool isPoints;

  const _StatCard({required this.label, required this.value, this.isPoints = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: const [BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          isPoints
              ? TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: value as int),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, currentValue, child) {
                    return Text(
                      currentValue.toString(),
                      style: AppTextStyles.display.copyWith(
                        fontSize: 22,
                        color: AppColors.brandBlue,
                      ),
                    );
                  },
                )
              : Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandBlue,
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6E6E6E)),
          ),
        ],
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// Sub-widget: Badge Section
// ---------------------------------------------------------------------------

class _BadgeSection extends StatelessWidget {
  final List<BadgeModel> allBadges;
  final List<String> earnedBadgeIds;

  const _BadgeSection({
    required this.allBadges,
    required this.earnedBadgeIds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: Icons.military_tech_rounded, label: 'LENCANA SAYA'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder, width: 2),
            boxShadow: const [BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4))],
          ),
          child: allBadges.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Memuat badge...', style: TextStyle(color: AppColors.disabled)),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: allBadges.length,
                  itemBuilder: (context, index) {
                    final badge = allBadges[index];
                    final isEarned = earnedBadgeIds.contains(badge.id);
                    return _BadgeItem(
                      badge: badge,
                      isEarned: isEarned,
                      onTap: isEarned ? () => _showBadgeDetail(context, badge) : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showBadgeDetail(BuildContext context, BadgeModel badge) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BadgeDetailSheet(badge: badge),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  final bool isEarned;
  final VoidCallback? onTap;

  const _BadgeItem({
    required this.badge,
    required this.isEarned,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          SvgPicture.asset(
            badge.iconPath,
            colorFilter: isEarned
                ? null
                : const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      0.4, 0,
                  ]),
          ),
          if (!isEarned)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Icon(Icons.lock_rounded, color: AppColors.surfaceWhite.withValues(alpha: 0.7), size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

class _BadgeDetailSheet extends StatelessWidget {
  final BadgeModel badge;

  const _BadgeDetailSheet({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 20),
          SvgPicture.asset(badge.iconPath, width: 80, height: 80),
          const SizedBox(height: 16),
          Text(
            badge.title,
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: 8),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widget: Photo Section
// ---------------------------------------------------------------------------

class _PhotoSection extends StatelessWidget {
  final List<String> photoUrls;

  const _PhotoSection({required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: Icons.camera_alt_rounded, label: 'FOTO SAYA'),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder, width: 2),
            boxShadow: const [BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4))],
          ),
          child: photoUrls.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.disabled),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada foto. Mulai misi!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.disabled, fontSize: 14),
                    ),
                  ],
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: photoUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(photoUrls[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.backgroundGray,
                          child: const Icon(Icons.broken_image_rounded,
                              color: AppColors.disabled),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widget: Section Header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.brandBlue),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.title.copyWith(
            fontSize: 15,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
