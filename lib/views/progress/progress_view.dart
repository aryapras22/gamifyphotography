import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../view_models/progress_view_model.dart';
import '../../view_models/level_view_model.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/service_providers.dart';
import '../widgets/brutal_widgets.dart';
import 'level_detail_view.dart';
import '../quiz/quiz_level_view.dart';

class ProgressTab extends ConsumerStatefulWidget {
  const ProgressTab({super.key});

  @override
  ConsumerState<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends ConsumerState<ProgressTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(progressViewModelProvider.notifier).loadUserProgress();
      ref.read(progressViewModelProvider.notifier).loadBadges();
      ref.read(levelViewModelProvider.notifier).loadAll();
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
    final lvState = ref.watch(levelViewModelProvider);
    final totalLevels = lvState.entries.length;
    final doneLevels = lvState.entries.where((e) => e.status == LevelStatus.completedPass).length;
    final double progressPct = totalLevels > 0 ? doneLevels / totalLevels : 0.0;

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      appBar: BrutalAppBar(
        title: 'Daftar Misi',
        subtitle: 'Petualangan Misi',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: lvState.isLoading && lvState.entries.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : lvState.entries.isEmpty
                ? const Center(child: Text('Memuat misi...'))
                : Column(
                    children: [
                      // Overall Level Progress Summary Box
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$doneLevels / $totalLevels Misi Selesai',
                                  style: AppTextStyles.title.copyWith(fontSize: 15),
                                ),
                                Text(
                                  '${(progressPct * 100).toInt()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            BrutalProgressBar(value: progressPct, height: 12),
                          ],
                        ),
                      ),

                      // Level Cards List
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                          itemCount: lvState.entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final entry = lvState.entries[index];
                            final config = entry.config;
                            final status = entry.status;
                            final isQuiz = config.isQuiz;
                            final isLocked = status == LevelStatus.locked;
                            final isDone = status == LevelStatus.completedPass;

                            // Custom Visual indicators
                            Color numberBg = Colors.white;
                            Color numberText = Colors.black;
                            Widget? trailingIcon;

                            if (isDone) {
                              numberBg = const Color(0xFF34D399); // emerald-400
                              numberText = Colors.white;
                              trailingIcon = const Icon(Icons.check_rounded, color: Color(0xFF059669), size: 24);
                            } else if (status == LevelStatus.available || status == LevelStatus.completedFail) {
                              if (isQuiz) {
                                numberBg = AppColors.brandAccent;
                                trailingIcon = Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                                );
                              } else {
                                numberBg = AppColors.brandPrimary;
                                numberText = Colors.white;
                                trailingIcon = Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                                );
                              }
                            } else {
                              // Locked
                              numberBg = const Color(0xFFE2E8F0); // slate-200
                              numberText = const Color(0xFF94A3B8); // slate-400
                              trailingIcon = const Icon(Icons.lock_rounded, color: Color(0xFF94A3B8), size: 20);
                            }

                            final contentCard = Opacity(
                              opacity: isLocked ? 0.55 : 1.0,
                              child: BrutalCard(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    // Circular level indicator box
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: numberBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.black, width: 2.0),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.bricolageGrotesque(
                                          color: numberText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Details column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              BrutalChip(
                                                tone: isQuiz ? BrutalChipTone.accent : BrutalChipTone.muted,
                                                child: Text(isQuiz ? 'MISI QUIZ' : 'MISI MATERI'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            config.title,
                                            style: AppTextStyles.title.copyWith(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isDone
                                                ? 'Selesai'
                                                : isLocked
                                                    ? 'Selesaikan misi sebelumnya'
                                                    : 'Tap untuk memulai misi',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: AppColors.secondaryText,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Trailing Icon
                                    trailingIcon,
                                  ],
                                ),
                              ),
                            );

                            return isLocked
                                ? contentCard
                                : GestureDetector(
                                    onTap: () => _openLevel(context, entry),
                                    child: contentCard,
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
