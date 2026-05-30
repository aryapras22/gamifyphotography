import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/bonus_mission_provider.dart';
import '../../models/bonus_mission_model.dart';
import '../widgets/brutal_widgets.dart';
import 'bonus_mission_detail_view.dart';

class BonusMissionListView extends ConsumerWidget {
  const BonusMissionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(bonusMissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Misi Tambahan', style: AppTextStyles.display.copyWith(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    'Tantangan ekstra di luar modul utama.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Mission List
            Expanded(
              child: missionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
                error: (e, _) => Center(child: Text('Gagal memuat: $e')),
                data: (missions) {
                  if (missions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_task_rounded, size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada misi tambahan',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: Colors.black,
                    onRefresh: () => ref.refresh(bonusMissionsProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      itemCount: missions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _BonusMissionCard(
                        mission: missions[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BonusMissionDetailView(mission: missions[i]),
                          ),
                        ),
                      ),
                    ),
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

class _BonusMissionCard extends StatelessWidget {
  final BonusMissionModel mission;
  final VoidCallback onTap;

  const _BonusMissionCard({required this.mission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BrutalCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.brandAccent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add_task_rounded, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mission.title, style: AppTextStyles.title.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    mission.description,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            BrutalXPPill(amount: mission.xpReward),
          ],
        ),
      ),
    );
  }
}
