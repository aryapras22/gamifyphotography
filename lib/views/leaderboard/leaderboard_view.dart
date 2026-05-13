// lib/views/leaderboard/leaderboard_view.dart
// TASK-06 â€” Wire LeaderboardView ke LeaderboardViewModel

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/leaderboard_model.dart';
import '../../view_models/leaderboard_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';

const String _kFallbackUserId = 'user_1';

// Medal emoji untuk top 3
const List<String> _kMedals = ['🥇', '🥈', '🥉'];

class LeaderboardView extends ConsumerStatefulWidget {
  const LeaderboardView({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends ConsumerState<LeaderboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = ref.read(authViewModelProvider).currentUser;
      final userId = authUser?.id ?? _kFallbackUserId;
      ref.read(leaderboardViewModelProvider.notifier).loadLeaderboard(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardViewModelProvider);
    final authUser = ref.watch(authViewModelProvider).currentUser;
    final currentUserId = authUser?.id ?? _kFallbackUserId;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Text('Papan Peringkat', style: AppTextStyles.heading),
        elevation: 1,
        backgroundColor: AppColors.surfaceWhite,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              )
            : null,
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        actions: [
          if (state.currentUserRank > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Chip(
                backgroundColor: AppColors.brandBlue.withOpacity(0.12),
                label: Text(
                  'Kamu: #${state.currentUserRank}',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? _buildLoadingSkeleton()
          : state.errorMessage != null
          ? _buildError(state.errorMessage!)
          : _buildList(state.entries, currentUserId),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading Skeleton
  // ---------------------------------------------------------------------------

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 82,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            _shimmerBox(40, 40, radius: 8),
            const SizedBox(width: 12),
            _shimmerBox(50, 50, radius: 25),
            const SizedBox(width: 16),
            Expanded(child: _shimmerBox(12, 120, radius: 4)),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double h, double w, {double radius = 4}) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: AppColors.disabled.withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error State
  // ---------------------------------------------------------------------------

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.coralRed),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.coralRed),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Leaderboard List
  // ---------------------------------------------------------------------------

  Widget _buildList(List<LeaderboardEntry> entries, String currentUserId) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isCurrentUser = entry.userId == currentUserId;
        return _LeaderboardTile(entry: entry, isCurrentUser: isCurrentUser);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Widget: Leaderboard Tile
// ---------------------------------------------------------------------------

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardTile({required this.entry, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;

    final Color rankColor;
    final Color bgColor;
    final Color borderColor;

    if (entry.rank == 1) {
      rankColor = AppColors.goldMedal;
      bgColor = rankColor.withOpacity(0.1);
      borderColor = rankColor;
    } else if (entry.rank == 2) {
      rankColor = AppColors.silverMedal;
      bgColor = rankColor.withOpacity(0.1);
      borderColor = rankColor;
    } else if (entry.rank == 3) {
      rankColor = AppColors.bronzeMedal;
      bgColor = rankColor.withOpacity(0.1);
      borderColor = rankColor;
    } else if (isCurrentUser) {
      rankColor = AppColors.brandBlue;
      bgColor = AppColors.brandBlue.withOpacity(0.1);
      borderColor = AppColors.brandBlue;
    } else {
      rankColor = AppColors.secondaryText;
      bgColor = AppColors.surfaceWhite;
      borderColor = AppColors.cardBorder;
    }

    final String initials = entry.userName.isNotEmpty
        ? entry.userName
              .trim()
              .split(RegExp(' +'))
              .take(2)
              .map((e) => e[0].toUpperCase())
              .join()
        : '?';

    final List<Color> avatarColors = [
      AppColors.brandBlue,
      AppColors.forestGreen,
      AppColors.coralRed,
      AppColors.lensGold,
      AppColors.streakFire,
    ];
    final Color avatarBgColor = avatarColors[entry.rank % avatarColors.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isCurrentUser || isTop3 ? 2 : 1,
        ),
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: AppColors.brandBlue.withOpacity(0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ]
            : const [
                BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4)),
              ],
      ),
      child: Row(
        children: [
          // Rank / Medal
          SizedBox(
            width: 40,
            child: isTop3
                ? Text(
                    _kMedals[entry.rank - 1],
                    style: const TextStyle(fontSize: 26),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '${entry.rank}',
                    style: AppTextStyles.title.copyWith(color: rankColor),
                    textAlign: TextAlign.center,
                  ),
          ),

          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: rankColor, width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: avatarBgColor,
              child: Text(
                initials,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.surfaceWhite,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name + "Kamu" badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.userName,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isCurrentUser
                              ? AppColors.brandBlue
                              : AppColors.bodyText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (isCurrentUser)
                  Text(
                    'Kamu',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlue,
                    ),
                  ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.points}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: rankColor,
                ),
              ),
              Text(
                'XP',
                style: AppTextStyles.caption.copyWith(color: rankColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
