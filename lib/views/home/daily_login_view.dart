// lib/views/home/daily_login_view.dart
// TASK-04 — Daily Login Bottom Sheet

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/daily_login_view_model.dart';
import '../../services/daily_login_service.dart';

// ---------------------------------------------------------------------------
// Konstanta UI
// ---------------------------------------------------------------------------

const _kSheetRadius = Radius.circular(28.0);
const _kDayBoxSize = 44.0;
const _kHeaderColor = Color(0xFF1CB0F6);

/// Tampilkan Daily Login Bottom Sheet.
/// Hanya muncul jika user belum claim hari ini.
Future<void> showDailyLoginSheet(
  BuildContext context,
  WidgetRef ref,
  String userId,
) async {
  await ref.read(dailyLoginViewModelProvider.notifier).initialize(userId);

  final hasClaimed = ref.read(dailyLoginViewModelProvider).hasClaimed;
  if (hasClaimed) return; // Sudah claim → tidak tampilkan

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DailyLoginSheet(userId: userId),
  );
}

// ---------------------------------------------------------------------------
// Widget: Sheet Container
// ---------------------------------------------------------------------------

class _DailyLoginSheet extends ConsumerWidget {
  final String userId;
  const _DailyLoginSheet({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyLoginViewModelProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: _kSheetRadius,
          topRight: _kSheetRadius,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kHeaderColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_rounded, color: _kHeaderColor, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Harian',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    Text(
                      'Claim hadiah setiap hari',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 7 Day Indicators
          state.isLoading
              ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
              : _DayIndicatorRow(weekHistory: state.weekHistory, currentStreak: state.currentStreak),

          const SizedBox(height: 20),

          // Streak Info
          _StreakInfo(streak: state.currentStreak),
          const SizedBox(height: 20),

          // Claim Button
          _ClaimButton(
            userId: userId,
            hasClaimed: state.hasClaimed,
            isLoading: state.isLoading,
            showSuccess: state.showClaimSuccess,
          ),

          // Error message
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 8),
          Text(
            'Datang lagi besok untuk melanjutkan streak-mu!',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget: Day Indicator Row
// ---------------------------------------------------------------------------

class _DayIndicatorRow extends StatelessWidget {
  final List<bool> weekHistory;
  final int currentStreak;

  const _DayIndicatorRow({required this.weekHistory, required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isClaimed = i < weekHistory.length && weekHistory[i];
        final isNext = i == currentStreak; // hari yang bisa di-claim berikutnya

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _kDayBoxSize,
              height: _kDayBoxSize,
              decoration: BoxDecoration(
                color: isClaimed
                    ? _kHeaderColor
                    : isNext
                        ? _kHeaderColor.withOpacity(0.15)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isClaimed
                      ? _kHeaderColor
                      : isNext
                          ? _kHeaderColor.withOpacity(0.5)
                          : Colors.grey.shade200,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  isClaimed ? '✅' : '🔒',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'H${i + 1}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isClaimed ? FontWeight.bold : FontWeight.normal,
                color: isClaimed ? _kHeaderColor : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget: Streak Info
// ---------------------------------------------------------------------------

class _StreakInfo extends StatelessWidget {
  final int streak;
  const _StreakInfo({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3DC), Color(0xFFFFE4A0)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCA28).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text(
            streak > 0 ? 'Streak kamu: $streak hari!' : 'Belum ada streak. Mulai sekarang!',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7A5800),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget: Claim Button
// ---------------------------------------------------------------------------

class _ClaimButton extends ConsumerWidget {
  final String userId;
  final bool hasClaimed;
  final bool isLoading;
  final bool showSuccess;

  const _ClaimButton({
    required this.userId,
    required this.hasClaimed,
    required this.isLoading,
    required this.showSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedScale(
      scale: showSuccess ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (hasClaimed || isLoading)
              ? null
              : () => ref.read(dailyLoginViewModelProvider.notifier).claimToday(userId),
          style: ElevatedButton.styleFrom(
            backgroundColor: showSuccess ? const Color(0xFF4CAF50) : _kHeaderColor,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: showSuccess ? 4 : 2,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  showSuccess
                      ? '🎉 +$kDailyLoginPoints Poin Berhasil!'
                      : hasClaimed
                          ? '✓ Sudah Claim Hari Ini'
                          : 'CLAIM $kDailyLoginPoints POIN',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}
