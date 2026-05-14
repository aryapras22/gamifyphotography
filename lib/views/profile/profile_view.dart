// lib/views/profile/profile_view.dart
// Sprint: Profile UI — Research-Based Redesign

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_text_styles.dart';
import '../../core/app_colors.dart';
import '../../view_models/profile_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../models/badge_model.dart';
import '../../models/photo_submission_model.dart';
import '../../providers/submission_providers.dart';
import '../mission/submission_status_view.dart';

// ── Main ProfileTab ─────────────────────────────────────────────────────────

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
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

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandBlue),
      );
    }

    if (state.user == null) {
      return _buildErrorState(state.errorMessage);
    }

    return RefreshIndicator(
      color: AppColors.brandBlue,
      onRefresh: () => ref.read(profileViewModelProvider.notifier).refreshProfile(),
      child: CustomScrollView(
        slivers: [
          // ── Hero SliverAppBar ────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: AppColors.brandBlue,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'PROFIL',
              style: TextStyle(
                color: AppColors.surfaceWhite,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.surfaceWhite),
                tooltip: 'Keluar',
                onPressed: () {
                  ref.read(authViewModelProvider.notifier).logout();
                  context.go('/login');
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _HeroHeader(user: state.user!),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _StatRow(user: state.user!),
                const SizedBox(height: 16),
                _XpProgressBar(user: state.user!),
                const SizedBox(height: 24),
                _ActivitySummary(
                  completedMissions: state.earnedBadgeIds.length,
                  photoCount: state.completedChallengePhotoUrls.length,
                ),
                const SizedBox(height: 24),
                _BadgeSection(
                  allBadges: state.allBadges,
                  earnedBadgeIds: state.earnedBadgeIds,
                ),
                const SizedBox(height: 24),
                _PhotoSection(photoUrls: state.completedChallengePhotoUrls),
                const SizedBox(height: 24),
                _SubmissionHistorySection(),
              ]),
            ),
          ),
        ],
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

// ── TASK 3: Hero Header ──────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final dynamic user;
  const _HeroHeader({required this.user});

  String get _initials {
    final name = (user.name as String).trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.brandBlue,
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceWhite.withValues(alpha: 0.3),
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.surfaceWhite,
              child: Text(
                _initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.brandBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.name as String,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.surfaceWhite,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            user.email as String,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.surfaceWhite.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── TASK 4: Stat Cards (Responsive) ─────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final dynamic user;
  const _StatRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.diamond_rounded,
            iconColor: AppColors.brandBlue,
            label: 'Poin',
            valueWidget: TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: user.points as int),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.brandBlue,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.workspace_premium_rounded,
            iconColor: AppColors.lensGold,
            label: 'Level',
            valueWidget: Text(
              'Lv.${user.level}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.lensGold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget valueWidget;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          valueWidget,
        ],
      ),
    );
  }
}

// ── TASK 5: XP Progress Bar ──────────────────────────────────────────────────

class _XpProgressBar extends StatelessWidget {
  final dynamic user;
  const _XpProgressBar({required this.user});

  int get _xpForCurrentLevel => (user.level as int) * 100;
  int get _xpProgress => (user.points as int) % _xpForCurrentLevel;
  double get _progressPercent =>
      (_xpProgress / _xpForCurrentLevel).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.bolt_rounded, color: AppColors.xpAmber, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'XP menuju Level berikutnya',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
              ),
              Text(
                '$_xpProgress / $_xpForCurrentLevel XP',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _progressPercent),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Stack(
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.brandBlue, AppColors.xpAmber],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lv.${user.level}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
              ),
              Text(
                'Lv.${(user.level as int) + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── TASK 6: Activity Summary ─────────────────────────────────────────────────

class _ActivitySummary extends StatelessWidget {
  final int completedMissions;
  final int photoCount;

  const _ActivitySummary({
    required this.completedMissions,
    required this.photoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: Icons.bar_chart_rounded, label: 'RINGKASAN'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActivityCard(
                icon: Icons.task_alt_rounded,
                iconColor: AppColors.forestGreen,
                count: completedMissions,
                label: 'Misi Selesai',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActivityCard(
                icon: Icons.photo_library_rounded,
                iconColor: AppColors.brandBlue,
                count: photoCount,
                label: 'Foto Diupload',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;

  const _ActivityCard({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: iconColor,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── TASK 7: Badge Section (4 columns + label + counter) ─────────────────────

class _BadgeSection extends StatelessWidget {
  final List<BadgeModel> allBadges;
  final List<String> earnedBadgeIds;

  const _BadgeSection({required this.allBadges, required this.earnedBadgeIds});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.military_tech_rounded,
                size: 20, color: AppColors.brandBlue),
            const SizedBox(width: 8),
            Text(
              'LENCANA SAYA',
              style: AppTextStyles.title.copyWith(fontSize: 15, letterSpacing: 1.2),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${earnedBadgeIds.length} / ${allBadges.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder, width: 2),
            boxShadow: const [
              BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4)),
            ],
          ),
          child: allBadges.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Memuat badge...',
                      style: TextStyle(color: AppColors.disabled),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
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

  const _BadgeItem({required this.badge, required this.isEarned, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  badge.iconPath,
                  colorFilter: isEarned
                      ? null
                      : const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      0.35, 0,
                        ]),
                ),
                if (!isEarned)
                  Icon(
                    Icons.lock_rounded,
                    color: AppColors.surfaceWhite.withValues(alpha: 0.8),
                    size: 20,
                  ),
                if (isEarned)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.forestGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: AppColors.surfaceWhite,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isEarned ? AppColors.bodyText : AppColors.disabled,
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
          Text(badge.title, style: AppTextStyles.heading),
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

// ── TASK 8: Photo Section (network-aware + counter) ─────────────────────────

class _PhotoSection extends StatelessWidget {
  final List<String> photoUrls;
  const _PhotoSection({required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.camera_alt_rounded,
                size: 20, color: AppColors.brandBlue),
            const SizedBox(width: 8),
            Text(
              'FOTO SAYA',
              style:
                  AppTextStyles.title.copyWith(fontSize: 15, letterSpacing: 1.2),
            ),
            const Spacer(),
            if (photoUrls.isNotEmpty)
              Text(
                '${photoUrls.length} foto',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder, width: 2),
            boxShadow: const [
              BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4)),
            ],
          ),
          child: photoUrls.isEmpty
              ? _buildEmpty()
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
                    final url = photoUrls[index];
                    final isNetwork =
                        url.startsWith('http://') || url.startsWith('https://');
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isNetwork
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: AppColors.backgroundGray,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.brandBlue,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.backgroundGray,
                                child: const Icon(
                                  Icons.broken_image_rounded,
                                  color: AppColors.disabled,
                                ),
                              ),
                            )
                          : Image.file(
                              File(url),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.backgroundGray,
                                child: const Icon(
                                  Icons.broken_image_rounded,
                                  color: AppColors.disabled,
                                ),
                              ),
                            ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(height: 16),
        Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.disabled),
        SizedBox(height: 12),
        Text(
          'Belum ada foto. Mulai misi!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.disabled, fontSize: 14),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

// ── TASK 9: Section Header Helper ───────────────────────────────────────────

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
          style: AppTextStyles.title.copyWith(fontSize: 15, letterSpacing: 1.2),
        ),
      ],
    );
  }
}

// -- Submission History --------------------------------------------------------

class _SubmissionHistorySection extends ConsumerWidget {
  const _SubmissionHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(submissionHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_rounded, size: 20, color: AppColors.brandBlue),
            const SizedBox(width: 8),
            Text(
              'RIWAYAT SUBMISSION',
              style: AppTextStyles.title.copyWith(fontSize: 15, letterSpacing: 1.2),
            ),
          ],
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.brandBlue),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (submissions) {
            if (submissions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                ),
                child: Center(
                  child: Text(
                    'Belum ada submission.',
                    style: AppTextStyles.body.copyWith(color: AppColors.disabled),
                  ),
                ),
              );
            }
            return Column(
              children: submissions
                  .map((s) => _SubmissionHistoryItem(
                        submission: s,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubmissionStatusView(
                              moduleId: s.moduleId,
                              moduleTitle: s.moduleTitle,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SubmissionHistoryItem extends StatelessWidget {
  final PhotoSubmissionModel submission;
  final VoidCallback onTap;

  const _SubmissionHistoryItem({required this.submission, required this.onTap});

  Color get _statusColor {
    switch (submission.status) {
      case 'approved': return AppColors.forestGreen;
      case 'rejected': return AppColors.coralRed;
      default: return AppColors.lensGold;
    }
  }

  IconData get _statusIcon {
    switch (submission.status) {
      case 'approved': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      default: return Icons.hourglass_top_rounded;
    }
  }

  String get _statusLabel {
    switch (submission.status) {
      case 'approved': return 'Disetujui';
      case 'rejected': return 'Ditolak';
      default: return 'Menunggu';
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 2),
          boxShadow: const [BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                submission.photoUrl,
                width: 56, height: 56, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56, height: 56,
                  color: AppColors.backgroundGray,
                  child: const Icon(Icons.image_not_supported_rounded, color: AppColors.disabled, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(submission.moduleTitle,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.bodyText),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(_statusLabel,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _statusColor)),
                      if (submission.status == 'approved' && submission.adminScore != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${submission.adminScore} / 100',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.forestGreen)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(_formatDate(submission.submittedAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.disabled, size: 20),
          ],
        ),
      ),
    );
  }
}
