// NOTE: Screen ini tidak digunakan dalam flow aktif (2026-05-02).
// Dipertahankan sebagai referensi layout alternatif.
// Route /mission/brief dihapus dari routes.dart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/mission_view_model.dart';
import '../../view_models/challenge_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/animated_3d_button.dart';

/// Page 2 — Mission brief with visual guide.
/// Layout: Level badge | Poin badge → Level label small → Title big
///          → Description → Task (red) → Visual Guide phone wireframe → Mulai
class ChallengeBriefView extends ConsumerWidget {
  const ChallengeBriefView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(missionViewModelProvider);
    final module = state.activeModule;
    ref.watch(authViewModelProvider);

    if (module == null) {
      return const Scaffold(body: Center(child: Text('No module selected')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Bar ────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4B4B4B), size: 28),
              ),
            ),

            // ── Scrollable content ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level label (small)
                    Text(
                      'Level ${module.order}:',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4B4B4B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Title (big bold)
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4B4B4B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Text(
                      module.materialContent,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Color(0xFF4B4B4B),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Task instruction (red)
                    Text(
                      'Task: ${module.description}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE63946),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Visual Guide — phone wireframe with grid
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 180,
                            height: 280,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF4B4B4B), width: 3),
                              boxShadow: const [
                                BoxShadow(color: Color(0xFFD0D0D0), offset: Offset(0, 6), blurRadius: 12),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: CustomPaint(
                                painter: _RuleOfThirdsGuide(),
                                child: Align(
                                  alignment: const Alignment(0, -0.85),
                                  child: Container(
                                    width: 36,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4B4B4B),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Visual Guide ${module.title}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1CB0F6),
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Fixed Bottom: Mulai → Camera ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Animated3DButton(
                onPressed: () async {
                  await ref.read(challengeViewModelProvider.notifier).loadChallenge(module.id);
                  if (context.mounted) {
                    context.push('/mission/challenge');
                  }
                },
                child: const Text(
                  'MULAI',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rule-of-thirds grid painter for the phone wireframe visual guide
class _RuleOfThirdsGuide extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Grey grid lines
    final linePaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1.0;
    final thirdW = size.width / 3;
    final thirdH = size.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(thirdW * i, 0), Offset(thirdW * i, size.height), linePaint);
      canvas.drawLine(Offset(0, thirdH * i), Offset(size.width, thirdH * i), linePaint);
    }

    // Red cross + circle at each intersection
    final redPaint = Paint()
      ..color = const Color(0xFFE63946)
      ..strokeWidth = 1.5;
    final circlePaint = Paint()
      ..color = const Color(0xFFE63946)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int row = 1; row < 3; row++) {
      for (int col = 1; col < 3; col++) {
        final cx = thirdW * col;
        final cy = thirdH * row;
        canvas.drawCircle(Offset(cx, cy), 7, circlePaint);
        canvas.drawLine(Offset(cx - 5, cy), Offset(cx + 5, cy), redPaint);
        canvas.drawLine(Offset(cx, cy - 5), Offset(cx, cy + 5), redPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
