import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../models/leaderboard_model.dart';
import '../../view_models/leaderboard_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/brutal_widgets.dart';

class LeaderboardView extends ConsumerStatefulWidget {
  const LeaderboardView({super.key});

  @override
  ConsumerState<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends ConsumerState<LeaderboardView> {
  String _activeTab = 'Mingguan';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authViewModelProvider).currentUser?.id ?? '';
      if (userId.isEmpty) return;
      ref.read(leaderboardViewModelProvider.notifier).loadLeaderboard(userId);
    });
  }

  List<LeaderboardEntry> _getProcessedEntries(
    List<LeaderboardEntry> dbEntries,
    String currentUserId,
    String tab,
  ) {
    final currentUser = ref.read(authViewModelProvider).currentUser;
    final currentPoints = currentUser?.points ?? 0;
    final currentName = currentUser?.name ?? 'Fotografer';

    double factor = 1.0;
    if (tab == 'Mingguan') factor = 0.12;
    if (tab == 'Bulanan') factor = 0.45;

    final List<LeaderboardEntry> list = [];
    bool userAdded = false;
    for (final db in dbEntries) {
      if (db.userId == currentUserId) {
        list.add(LeaderboardEntry(
          userId: db.userId,
          userName: db.userName,
          points: (db.points * factor).toInt(),
          rank: 0,
        ));
        userAdded = true;
      } else {
        list.add(LeaderboardEntry(
          userId: db.userId,
          userName: db.userName,
          points: (db.points * factor).toInt(),
          rank: 0,
        ));
      }
    }

    if (!userAdded && currentUserId.isNotEmpty) {
      list.add(LeaderboardEntry(
        userId: currentUserId,
        userName: currentName,
        points: (currentPoints * factor).toInt(),
        rank: 0,
      ));
    }

    list.sort((a, b) => b.points.compareTo(a.points));

    final result = <LeaderboardEntry>[];
    for (int i = 0; i < list.length; i++) {
      result.add(list[i].copyWith(rank: i + 1));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardViewModelProvider);
    final authUser = ref.watch(authViewModelProvider).currentUser;
    final currentUserId = authUser?.id ?? '';

    // Processed list based on current tab selection
    final processedList = _getProcessedEntries(state.entries, currentUserId, _activeTab);
    
    // Split into top 3 podium entries and the remaining listings
    final top3 = processedList.take(3).toList();
    final rest = processedList.skip(3).toList();

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      appBar: BrutalAppBar(
        title: 'Papan Peringkat',
        subtitle: 'KOMPETISI',
        onBackPressed: Navigator.of(context).canPop() ? () => context.pop() : null,
      ),
      body: SafeArea(
        child: state.isLoading && state.entries.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : Column(
                children: [
                  // Tab Switcer
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: _TabSwitcher(
                      activeTab: _activeTab,
                      onTabChanged: (tab) => setState(() => _activeTab = tab),
                    ),
                  ),

                  // Content Scroll View
                  Expanded(
                    child: RefreshIndicator(
                      color: Colors.black,
                      onRefresh: () async {
                        ref
                            .read(leaderboardViewModelProvider.notifier)
                            .loadLeaderboard(currentUserId);
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                        children: [
                          // Top 3 Podium
                          if (processedList.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Rank 2 Podium
                                _PodiumColumn(
                                  user: top3.length > 1 ? top3[1] : null,
                                  place: 2,
                                  height: 100,
                                  tint: const Color(0xFFE2E8F0), // slate-200
                                ),
                                const SizedBox(width: 12),
                                // Rank 1 Podium
                                _PodiumColumn(
                                  user: top3.length > 0 ? top3[0] : null,
                                  place: 1,
                                  height: 130,
                                  tint: AppColors.brandAccent, // yellow
                                  hasCrown: true,
                                ),
                                const SizedBox(width: 12),
                                // Rank 3 Podium
                                _PodiumColumn(
                                  user: top3.length > 2 ? top3[2] : null,
                                  place: 3,
                                  height: 80,
                                  tint: const Color(0xFFFDBA74), // orange-300
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Rest of Papan Peringkat Users
                          if (rest.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.people_outline_rounded,
                                    size: 40,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada peserta lain',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Jadilah yang pertama di papan peringkat!',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: [
                                for (int i = 0; i < rest.length; i++) ...[
                                  _LeaderboardItemRow(
                                    user: rest[i],
                                    isCurrentUser: rest[i].userId == currentUserId,
                                  ),
                                  if (i < rest.length - 1) const SizedBox(height: 8),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const _TabSwitcher({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = ["Mingguan", "Bulanan", "Semua"];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: tabs.map((t) {
          final isActive = activeTab == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  t.toUpperCase(),
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final LeaderboardEntry? user;
  final int place;
  final double height;
  final Color tint;
  final bool hasCrown;

  const _PodiumColumn({
    required this.user,
    required this.place,
    required this.height,
    required this.tint,
    this.hasCrown = false,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 26),
            const BrutalAvatar(initial: '-', size: 48),
            const SizedBox(height: 4),
            Text(
              '-',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.brandInk,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '⭐ 0',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.4),
                border: Border.all(color: Colors.black.withOpacity(0.4), width: 2.0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$place',
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.black.withOpacity(0.4),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final String initial = user!.userName.isNotEmpty ? user!.userName[0] : '?';
    final firstName = user!.userName.split(' ').first;

    return SizedBox(
      width: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (hasCrown) ...[
            const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.brandAccent,
              size: 24,
            ),
            const SizedBox(height: 2),
          ] else
            const SizedBox(height: 26),

          BrutalAvatar(initial: initial, size: 48),
          const SizedBox(height: 4),
          Text(
            firstName,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.brandInk,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '⭐ ${user!.points}',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: tint,
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$place',
              style: GoogleFonts.bricolageGrotesque(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItemRow extends StatelessWidget {
  final LeaderboardEntry user;
  final bool isCurrentUser;

  const _LeaderboardItemRow({
    required this.user,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final String initial = user.userName.isNotEmpty ? user.userName[0] : '?';

    return BrutalCard(
      backgroundColor: isCurrentUser ? AppColors.brandPrimary : Colors.white,
      shadowOffset: const Offset(2, 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${user.rank}',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),

          BrutalAvatar(
            initial: initial,
            size: 36,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName + (isCurrentUser ? ' (Kamu)' : ''),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isCurrentUser ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '⭐ ${user.points} XP',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isCurrentUser ? Colors.white.withOpacity(0.8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          if (user.rank <= 10)
            Icon(
              Icons.workspace_premium_rounded,
              color: user.rank == 1
                  ? const Color(0xFFFACC15)
                  : user.rank == 2
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFFFDBA74),
              size: 20,
            ),
        ],
      ),
    );
  }
}
