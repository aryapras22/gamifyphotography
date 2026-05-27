import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../view_models/profile_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../models/badge_model.dart';
import '../../providers/service_providers.dart';
import '../widgets/brutal_widgets.dart';

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

  void _showSettingsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan akun dikelola secara terpusat oleh sistem.')),
    );
  }

  void _showBadgeModal(BadgeModel badge) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Card Content
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.black, width: 2.0),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
              ),
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LENCANA DIPEROLEH',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brandPrimary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.title,
                    style: AppTextStyles.display.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    badge.description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  BrutalButton(
                    fullWidth: true,
                    onPressed: () => Navigator.pop(dialogCtx),
                    variant: BrutalButtonVariant.accent,
                    child: const Text('KEREN! 🎉'),
                  ),
                ],
              ),
            ),
            // Floating Badge Svg Circle
            Positioned(
              top: -40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2.0),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  badge.iconPath,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.brandBg,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    if (state.user == null) {
      return Scaffold(
        backgroundColor: AppColors.brandBg,
        body: Center(
          child: Text(state.errorMessage ?? 'Gagal memuat profil.'),
        ),
      );
    }

    final user = state.user!;
    final initials = user.name.split(' ').first;
    final int nextLevelXp = user.level * 100;
    final int levelProgressXp = user.points % nextLevelXp;
    final double levelProgressPct = (levelProgressXp / nextLevelXp).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      appBar: BrutalAppBar(
        title: 'Profil Saya',
        subtitle: 'Pengguna',
        rightAction: GestureDetector(
          onTap: _showSettingsMessage,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2.0),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
            ),
            child: const Icon(Icons.settings_rounded, size: 16, color: Colors.black),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.black,
          onRefresh: () => ref.read(profileViewModelProvider.notifier).refreshProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar, Name, Email, Role Chip
                Column(
                  children: [
                    BrutalAvatar(initial: initials.isNotEmpty ? initials[0] : 'U', size: 88),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: AppTextStyles.display.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    BrutalChip(
                      tone: BrutalChipTone.primary,
                      child: Text(user.level >= 10 ? 'Fotografer Ahli' : 'Fotografer Pemula'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Stats grid block row
                Row(
                  children: [
                    Expanded(
                      child: _ProfileStatBlock(
                        value: '${user.level}',
                        label: 'Misi',
                        bg: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileStatBlock(
                        value: '${user.points}',
                        label: 'XP',
                        bg: AppColors.brandPrimary,
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileStatBlock(
                        value: '🔥 ${user.streakCount}',
                        label: 'Streak',
                        bg: const Color(0xFFFFEDD5), // orange-100
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Levels Card
                BrutalCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress Misi ${user.level + 1}',
                            style: AppTextStyles.title.copyWith(fontSize: 14),
                          ),
                          Text(
                            '$levelProgressXp / $nextLevelXp XP',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      BrutalProgressBar(value: levelProgressPct, height: 10),
                      const SizedBox(height: 16),

                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Misi Selesai',
                            style: AppTextStyles.title.copyWith(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref.read(profileTabSubIndexProvider.notifier).state = 1;
                            },
                            child: Row(
                              children: [
                                Text(
                                  '${user.completedLevels.length} / 25',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(Lihat Semua)',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppColors.brandPrimary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      BrutalProgressBar(value: user.completedLevels.length / 25, height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Badges list section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Koleksi Badge',
                      style: AppTextStyles.title.copyWith(fontSize: 18),
                    ),
                    Text(
                      '${state.earnedBadgeIds.length} / ${state.allBadges.length}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Badges Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: state.allBadges.length + 1, // list + 1 locked placeholder
                  itemBuilder: (context, index) {
                    if (index == state.allBadges.length) {
                      // Locked Placeholder Card
                      final int remaining = state.allBadges.length - state.earnedBadgeIds.length;
                      if (remaining <= 0) return const SizedBox.shrink();
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 2.0, style: BorderStyle.solid),
                          color: AppColors.brandBg,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.workspace_premium_rounded, color: Color(0xFFCBD5E1), size: 36),
                            const SizedBox(height: 8),
                            Text(
                              '$remaining badge lagi',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final badge = state.allBadges[index];
                    final isEarned = state.earnedBadgeIds.contains(badge.id);

                    // Re-color/tone of badge cards
                    Color tint = const Color(0xFFFEF9C3); // default yellow
                    if (badge.title.toLowerCase().contains('hour')) {
                      tint = const Color(0xFFFFEDD5); // orange
                    } else if (badge.title.toLowerCase().contains('streak')) {
                      tint = const Color(0xFFD1FAE5); // emerald
                    }

                    return Opacity(
                      opacity: isEarned ? 1.0 : 0.45,
                      child: GestureDetector(
                        onTap: isEarned ? () => _showBadgeModal(badge) : null,
                        child: BrutalCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: tint,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black, width: 2.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    badge.iconPath,
                                    width: 44,
                                    height: 44,
                                    colorFilter: isEarned
                                        ? const ColorFilter.mode(Colors.black, BlendMode.srcIn)
                                        : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                badge.title,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                badge.description,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),

                // Logout button
                BrutalButton(
                  fullWidth: true,
                  onPressed: () {
                    ref.read(authViewModelProvider.notifier).logout();
                    context.go('/login');
                  },
                  variant: BrutalButtonVariant.secondary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout_rounded, color: AppColors.brandDanger, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'KELUAR',
                        style: TextStyle(color: AppColors.brandDanger),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStatBlock extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color textColor;

  const _ProfileStatBlock({
    required this.value,
    required this.label,
    required this.bg,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2.0),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 20,
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              color: textColor.withOpacity(0.7),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
