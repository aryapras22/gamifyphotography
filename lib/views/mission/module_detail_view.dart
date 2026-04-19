import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/mission_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/animated_3d_button.dart';

/// Page 1 — Pure description with a sample photo.
/// Layout: Level badge | Poin badge → Title → Description → Sample photo → Next
class ModuleDetailView extends ConsumerWidget {
  const ModuleDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(missionViewModelProvider);
    final module = state.activeModule;
    final authState = ref.watch(authViewModelProvider);
    final points = authState.currentUser?.points ?? 0;

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4B4B4B), size: 24),
                      ),
                      const SizedBox(width: 12),
                      _badge('Level ${module.order}'),
                    ],
                  ),
                  _badge('Poin $points', icon: Icons.star_rounded, iconColor: const Color(0xFFFFC800)),
                ],
              ),
            ),

            // ── Scrollable content ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      module.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4B4B4B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        module.materialContent,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFF4B4B4B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sample visual photo (cheetah / example using grid placeholder)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 220,
                        child: CustomPaint(painter: _SamplePhotoPainter()),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Fixed Bottom: Next ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Animated3DButton(
                onPressed: () => context.push('/mission/brief'),
                child: const Text(
                  'NEXT',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, {IconData? icon, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4B4B4B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
          ],
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// Sample photo painter: golden photo with rule-of-thirds white grid overlay
class _SamplePhotoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Warm background (simulating golden-hour photo)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD4A44C), Color(0xFF8B6914), Color(0xFF5C3D0A)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid overlay (white, semi-transparent)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    final thirdW = size.width / 3;
    final thirdH = size.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(thirdW * i, 0), Offset(thirdW * i, size.height), gridPaint);
      canvas.drawLine(Offset(0, thirdH * i), Offset(size.width, thirdH * i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
