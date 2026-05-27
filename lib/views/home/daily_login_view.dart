import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../view_models/daily_login_view_model.dart';
import '../../services/daily_login_service.dart';
import '../widgets/brutal_widgets.dart';

const List<String> _kDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

Future<void> showDailyLoginSheet(
  BuildContext context,
  WidgetRef ref,
  String userId, {
  bool forceShow = false,
}) async {
  await ref.read(dailyLoginViewModelProvider.notifier).initialize();

  final hasClaimed = ref.read(dailyLoginViewModelProvider).hasClaimed;
  if (hasClaimed && !forceShow) return;

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DailyCheckInSheet(),
  );
}

class _DailyCheckInSheet extends ConsumerWidget {
  const _DailyCheckInSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyLoginViewModelProvider);

    // Calculate active day index:
    // If hasClaimed is true, active day index is currentStreak - 1. But sheet only opens if NOT claimed today.
    // So today index is exactly currentStreak.
    final todayIdx = state.hasClaimed
        ? (state.currentStreak - 1).clamp(0, 6)
        : state.currentStreak.clamp(0, 6);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Stack(
        children: [
          // Content
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Header
              Row(
                children: [
                  Text(
                    'Check-in Harian!',
                    style: AppTextStyles.display.copyWith(fontSize: 24),
                  ),
                  const SizedBox(width: 6),
                  const Text('🎉', style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  text: 'Kamu sudah ',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                  children: [
                    TextSpan(
                      text: '🔥 ${state.currentStreak} hari berturut-turut',
                      style: GoogleFonts.inter(
                        color: AppColors.brandWarm,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: '. Jangan putus!'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 7 Days Grid
              state.isLoading
                  ? const SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator(color: Colors.black)),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final isClaimed = i < state.weekHistory.length && state.weekHistory[i];
                        final isToday = i == todayIdx;

                        Color boxBg = const Color(0xFFF8FAFC);
                        Widget boxChild = Text(
                          '${i + 1}',
                          style: GoogleFonts.bricolageGrotesque(
                            color: const Color(0xFF94A3B8), // slate-400
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        );

                        if (isClaimed) {
                          boxBg = AppColors.brandPrimary;
                          boxChild = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
                        } else if (isToday) {
                          boxBg = AppColors.brandAccent;
                          boxChild = const Icon(Icons.star_rounded, color: Colors.black, size: 16);
                        }

                        return Column(
                          children: [
                            Text(
                              _kDays[i].toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: boxBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black, width: 2.0),
                                boxShadow: isToday
                                    ? const [BoxShadow(color: Colors.black, offset: Offset(2, 2))]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: boxChild,
                            ),
                          ],
                        );
                      }),
                    ),
              const SizedBox(height: 24),

              // Reward Card
              BrutalCard(
                backgroundColor: AppColors.brandBg,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REWARD HARI INI',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondaryText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+$kDailyLoginPoints XP',
                          style: AppTextStyles.display.copyWith(fontSize: 22),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.brandAccent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 2.0),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Claim Button
              BrutalButton(
                fullWidth: true,
                onPressed: (state.hasClaimed || state.isLoading)
                    ? null
                    : () async {
                        await ref.read(dailyLoginViewModelProvider.notifier).claimToday();
                      },
                variant: BrutalButtonVariant.accent,
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.0),
                      )
                    : Text(
                        state.showClaimSuccess
                            ? 'BERHASIL KLAIM! 🎉'
                            : state.hasClaimed
                                ? 'SUDAH DIKLAIM ✓'
                                : 'KLAIM REWARD!',
                      ),
              ),

              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.errorMessage!,
                  style: GoogleFonts.inter(color: AppColors.brandDanger, fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),

          // Close button positioned top-right
          Positioned(
            right: 0,
            top: 10,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
