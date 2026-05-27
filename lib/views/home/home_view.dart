import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/daily_login_view_model.dart';
import '../../view_models/mission_view_model.dart';
import '../../view_models/level_view_model.dart';
import '../../view_models/progress_view_model.dart';
import '../../models/module_model.dart';
import '../../providers/submission_providers.dart';
import '../../providers/service_providers.dart';
import '../widgets/brutal_widgets.dart';
import '../progress/level_detail_view.dart';
import '../progress/progress_view.dart';
import '../quiz/quiz_level_view.dart';
import 'daily_login_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final missionState = ref.read(missionViewModelProvider);
      if (missionState.modules.isEmpty && !missionState.isLoading) {
        ref.read(missionViewModelProvider.notifier).fetchModules();
      }
      ref.read(levelViewModelProvider.notifier).loadAll();
      ref.read(progressViewModelProvider.notifier).loadUserProgress();
      ref.read(progressViewModelProvider.notifier).loadBadges();
      ref.read(dailyLoginViewModelProvider.notifier).initialize();
    });
  }



  void _openLevel(BuildContext context, LevelEntry entry) {
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.currentUser;
    final dailyState = ref.watch(dailyLoginViewModelProvider);
    final missionState = ref.watch(missionViewModelProvider);
    final levelState = ref.watch(levelViewModelProvider);
    final progressState = ref.watch(progressViewModelProvider);

    final userName = user?.name ?? 'Fotografer';
    final firstName = userName.split(' ').first;
    final userPoints = user?.points ?? 0;
    final userLevel = user?.level ?? 1;
    final xpProgress = (userPoints % 100) / 100.0;

    // Find the current active level entry that the user has not completed yet
    LevelEntry? activeLevelEntry;
    try {
      activeLevelEntry = levelState.entries.firstWhere(
        (e) => e.status == LevelStatus.available || e.status == LevelStatus.completedFail,
      );
    } catch (_) {
      if (levelState.entries.isNotEmpty) {
        activeLevelEntry = levelState.entries.last;
      }
    }

    // Filter active incomplete modules to display as Active Missions
    final activeMissions = missionState.modules.where((m) => !m.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Section ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      BrutalAvatar(initial: firstName.isNotEmpty ? firstName[0] : 'U', size: 44),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $firstName! 👋',
                            style: AppTextStyles.display.copyWith(fontSize: 18),
                          ),
                          Text(
                            userLevel >= 10 ? 'Fotografer Ahli' : 'Fotografer Pemula',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondaryText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5), // orange-100
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2.0),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                    ),
                    child: Row(
                      children: [
                        const Text('🔥 ', style: TextStyle(fontSize: 12)),
                        Text(
                          '${dailyState.currentStreak} Hari',
                          style: GoogleFonts.bricolageGrotesque(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Level XP Bar ────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MISI $userLevel',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandInk,
                        ),
                      ),
                      Text(
                        '${userPoints % 100} / 100 XP',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  BrutalProgressBar(value: xpProgress, height: 12),
                ],
              ),
              const SizedBox(height: 24),

              // ── Daily Check-in Card Promo ────────────────────────
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: BrutalCard(
                  backgroundColor: dailyState.hasClaimed ? const Color(0xFFF1F5F9) : AppColors.brandAccent,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-in Harian',
                              style: AppTextStyles.title.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dailyState.hasClaimed
                                  ? 'Streak kamu saat ini: 🔥 ${dailyState.currentStreak} Hari'
                                  : '+50 XP menunggu kamu',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      BrutalButton(
                        onPressed: () => showDailyLoginSheet(context, ref, user?.id ?? '', forceShow: true),
                        variant: dailyState.hasClaimed ? BrutalButtonVariant.secondary : BrutalButtonVariant.primary,
                        height: 38,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(dailyState.hasClaimed ? 'Detail' : 'Klaim'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats Block Grid ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '${levelState.entries.where((e) => e.status == LevelStatus.completedPass).length}/25',
                      label: 'Misi',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: '#12',
                      label: 'Peringkat',
                      isAccent: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: '${progressState.earnedBadges.length.toString().padLeft(2, '0')}',
                      label: 'Badge',
                      isSuccess: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Lanjutkan Belajar Section ────────────────────────
              if (activeLevelEntry != null) ...[
                Text(
                  'Lanjutkan Misi',
                  style: AppTextStyles.title.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                BrutalCard(
                  shadowColor: AppColors.brandPrimary,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          // Level thumbnail image container
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.brandBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 2.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _buildThumbnail(activeLevelEntry),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BrutalChip(
                                  tone: BrutalChipTone.primary,
                                  child: Text('Misi ${activeLevelEntry.config.levelNumber}'),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  activeLevelEntry.config.title,
                                  style: AppTextStyles.title.copyWith(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: BrutalProgressBar(
                                        value: 0.6,
                                        height: 8,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '60%',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BrutalButton(
                        fullWidth: true,
                        onPressed: () => _openLevel(context, activeLevelEntry!),
                        variant: BrutalButtonVariant.primary,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('LANJUTKAN MISI '),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // ── Misi Aktif Section ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Misi Aktif',
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProgressTab()),
                      ).then((_) => ref.read(levelViewModelProvider.notifier).loadAll());
                    },
                    child: Text(
                      'Lihat Semua',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (activeMissions.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: Text(
                    'Semua misi aktif selesai! 🎉',
                    style: GoogleFonts.inter(color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeMissions.length.clamp(0, 3), // Show up to 3 active missions
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final mission = activeMissions[idx];
                    return _MissionCardItem(mission: mission);
                  },
                ),

              const SizedBox(height: 24),
              // Level map link
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProgressTab()),
                  ).then((_) => ref.read(levelViewModelProvider.notifier).loadAll());
                },
                child: Text(
                  'Lihat Semua Misi →',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(LevelEntry entry) {
    final urls = entry.config.materiContent?.allImageUrls ?? [];
    if (urls.isNotEmpty) {
      final url = urls.first;
      if (url.startsWith('http')) {
        return Image.network(url, fit: BoxFit.cover);
      } else {
        return Image.asset(url, fit: BoxFit.cover);
      }
    }
    return Container(
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book_rounded, color: Colors.black),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isAccent;
  final bool isSuccess;

  const _StatCard({
    required this.value,
    required this.label,
    this.isAccent = false,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    Color valCol = Colors.black;
    if (isAccent) {
      valCol = AppColors.brandPrimary;
    } else if (isSuccess) {
      valCol = const Color(0xFF059669); // emerald-600
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: valCol,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCardItem extends ConsumerWidget {
  final ModuleModel mission;

  const _MissionCardItem({required this.mission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine icon and tint background based on mission title
    IconData icon = Icons.task_alt_rounded;
    Color tint = const Color(0xFFECFDF5); // bg-emerald-50
    if (mission.title.toLowerCase().contains('hour')) {
      icon = Icons.wb_sunny_rounded;
      tint = const Color(0xFFFFF7ED); // bg-orange-50
    } else if (mission.title.toLowerCase().contains(' thirds') ||
        mission.title.toLowerCase().contains('komposisi')) {
      icon = Icons.camera_alt_rounded;
      tint = const Color(0xFFEEF2FF); // bg-indigo-50
    }

    // Watch submission status to compute progress
    final submissionAsync = ref.watch(submissionStatusProvider(mission.id));
    final status = submissionAsync.valueOrNull?.status;

    double progress = 0.0;
    if (status == 'pending') {
      progress = 0.5;
    } else if (status == 'approved') {
      progress = 1.0;
    }

    return BrutalCard(
      shadowColor: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2.0),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        mission.title,
                        style: AppTextStyles.title.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const BrutalXPPill(amount: 100),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  mission.description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: BrutalProgressBar(
                        value: progress,
                        height: 8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
