// lib/views/progress/progress_view.dart
// TASK-03 — Updated Progress Screen: Tampilan 25 Level

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/progress_view_model.dart';
import '../../view_models/level_view_model.dart';
import '../../core/app_colors.dart';
import '../../core/level_content_data.dart';
import 'level_detail_view.dart';
import '../quiz/quiz_level_view.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressTab extends ConsumerStatefulWidget {
  const ProgressTab({Key? key}) : super(key: key);

  @override
  ConsumerState<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends ConsumerState<ProgressTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(progressViewModelProvider.notifier).loadUserProgress();
      ref.read(progressViewModelProvider.notifier).loadBadges();
      // TASK-M03: load Firestore content + progress
      ref.read(levelViewModelProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressViewModelProvider);
    final user = state.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.brandBlue));
    }

    return Column(
      children: [
        // Tab bar
        Container(
          color: AppColors.surfaceWhite,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.brandBlue,
            unselectedLabelColor: AppColors.secondaryText,
            indicatorColor: AppColors.brandBlue,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            tabs: const [
              Tab(text: 'Level Materi'),
              Tab(text: 'Profil & Badge'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _LevelListTab(),
              _ProfileBadgeTab(state: state, user: user),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Level List Tab ────────────────────────────────────────────────────────

class _LevelListTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lvState = ref.watch(levelViewModelProvider);

    if (lvState.isLoading && lvState.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.brandBlue));
    }

    if (lvState.entries.isEmpty) {
      return const Center(
        child: Text('Memuat level...', style: TextStyle(color: AppColors.secondaryText)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: lvState.entries.length,
      itemBuilder: (context, index) {
        final entry = lvState.entries[index];
        return _LevelCard(entry: entry);
      },
    );
  }
}

// ── Level Card ────────────────────────────────────────────────────────────

class _LevelCard extends ConsumerWidget {
  final LevelEntry entry;
  const _LevelCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = entry.config;
    final status = entry.status;
    final isQuiz = config.isQuiz;
    final isLocked = status == LevelStatus.locked;

    // Colors
    Color cardBg = AppColors.surfaceWhite;
    Color borderColor = AppColors.cardBorder;
    Color numberBg = AppColors.backgroundGray;
    Color numberColor = AppColors.secondaryText;

    if (isQuiz) {
      borderColor = const Color(0xFFFFB300);
      numberBg = const Color(0xFFFFF8E1);
      numberColor = const Color(0xFFE65100);
    }
    if (status == LevelStatus.completedPass) {
      borderColor = AppColors.forestGreen.withValues(alpha: 0.5);
    }
    if (status == LevelStatus.completedFail) {
      borderColor = AppColors.coralRed.withValues(alpha: 0.5);
    }
    if (isLocked) {
      cardBg = AppColors.backgroundGray;
      borderColor = AppColors.cardBorder;
    }

    return GestureDetector(
      onTap: isLocked ? null : () => _openLevel(context, ref),
      child: Opacity(
        opacity: isLocked ? 0.55 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: isLocked
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x06000000),
                      offset: Offset(0, 4),
                      blurRadius: 12,
                    )
                  ],
          ),
          child: Row(
            children: [
              // Level number badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: numberBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isLocked
                      ? const Icon(Icons.lock_rounded, size: 22, color: AppColors.disabled)
                      : Text(
                          '${config.levelNumber}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: numberColor,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isQuiz) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'QUIZ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE65100),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            config.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isLocked ? AppColors.secondaryText : AppColors.bodyText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitleText(status, entry.quizScore, config.passingScore),
                      style: TextStyle(
                        fontSize: 12,
                        color: _subtitleColor(status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status icon
              _StatusIcon(status: status, isQuiz: isQuiz),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleText(LevelStatus status, int? score, int passingScore) {
    switch (status) {
      case LevelStatus.locked:
        return 'Selesaikan level sebelumnya';
      case LevelStatus.available:
        return entry.config.isQuiz ? 'Tap untuk mulai quiz' : 'Tap untuk belajar';
      case LevelStatus.completedPass:
        if (entry.config.isQuiz && score != null) return 'Lulus — Skor: $score/100';
        return 'Selesai';
      case LevelStatus.completedFail:
        if (score != null) return 'Belum lulus — Skor: $score/100 (min. $passingScore)';
        return 'Belum lulus — Coba lagi';
    }
  }

  Color _subtitleColor(LevelStatus status) {
    switch (status) {
      case LevelStatus.locked:
        return AppColors.disabled;
      case LevelStatus.available:
        return AppColors.secondaryText;
      case LevelStatus.completedPass:
        return AppColors.forestGreen;
      case LevelStatus.completedFail:
        return AppColors.coralRed;
    }
  }

  void _openLevel(BuildContext context, WidgetRef ref) {
    final config = entry.config;
    if (config.isMateri) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LevelDetailView(config: config)),
      ).then((_) => ref.read(levelViewModelProvider.notifier).loadAll());
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => QuizLevelView(config: config)),
      ).then((_) => ref.read(levelViewModelProvider.notifier).loadAll());
    }
  }
}

class _StatusIcon extends StatelessWidget {
  final LevelStatus status;
  final bool isQuiz;
  const _StatusIcon({required this.status, required this.isQuiz});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LevelStatus.locked:
        return const SizedBox.shrink();
      case LevelStatus.available:
        return Icon(
          isQuiz ? Icons.quiz_rounded : Icons.play_circle_rounded,
          color: isQuiz ? const Color(0xFFFFB300) : AppColors.brandBlue,
          size: 28,
        );
      case LevelStatus.completedPass:
        return const Icon(Icons.check_circle_rounded, color: AppColors.forestGreen, size: 28);
      case LevelStatus.completedFail:
        return const Icon(Icons.replay_rounded, color: AppColors.coralRed, size: 28);
    }
  }
}

// ── Profile & Badge Tab ───────────────────────────────────────────────────

class _ProfileBadgeTab extends StatelessWidget {
  final ProgressState state;
  final dynamic user;

  const _ProfileBadgeTab({required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), offset: Offset(0, 12), blurRadius: 24)
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandBlue,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surfaceWhite, width: 4),
                    ),
                    child: const Center(
                      child: Icon(Icons.person_rounded, size: 60, color: AppColors.brandBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.bodyText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('LEVEL',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondaryText,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        Text('${user.level}',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.brandBlue)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TOTAL XP',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondaryText,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.xpAmber, size: 24),
                            const SizedBox(width: 4),
                            Text('${user.points}',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.xpAmber)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LinearPercentIndicator(
                  lineHeight: 16.0,
                  percent: state.progressPercentage,
                  barRadius: const Radius.circular(8),
                  backgroundColor: AppColors.backgroundGray,
                  linearGradient: LinearGradient(
                    colors: [AppColors.xpAmber, AppColors.xpAmber.withValues(alpha: 0.6)],
                  ),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                Text(
                  '${(state.progressPercentage * 100).toInt()}% menuju Level ${user.level + 1}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                ),
                // Level materi progress
                const SizedBox(height: 16),
                _LevelProgressSummary(completedLevels: user.completedLevels),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Badges
          const Text(
            'Koleksi Badge',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.bodyText,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 20),
          if (state.earnedBadges.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  'Belum ada badge yang diperoleh.\nAyo selesaikan misi!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                      height: 1.5),
                ),
              ),
            )
          else
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: state.earnedBadges.length,
              itemBuilder: (context, index) {
                final badge = state.earnedBadges[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x05000000), offset: Offset(0, 8), blurRadius: 16)
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.streakBg, const Color(0xFFFEF08A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.xpAmber.withValues(alpha: 0.2),
                              offset: const Offset(0, 8),
                              blurRadius: 16,
                            )
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.workspace_premium_rounded,
                              size: 44, color: AppColors.xpAmber),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(badge.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.bodyText)),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          badge.description,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Level Progress Summary ────────────────────────────────────────────────

class _LevelProgressSummary extends StatelessWidget {
  final List<int> completedLevels;
  const _LevelProgressSummary({required this.completedLevels});

  @override
  Widget build(BuildContext context) {
    final total = LevelContentData.levels.length;
    final done = completedLevels.length;
    final percent = total > 0 ? done / total : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LEVEL MATERI',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryText,
                  letterSpacing: 1.0),
            ),
            Text(
              '$done / $total',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.brandBlue),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 10.0,
          percent: percent.clamp(0.0, 1.0),
          barRadius: const Radius.circular(5),
          backgroundColor: AppColors.backgroundGray,
          progressColor: AppColors.brandBlue,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
