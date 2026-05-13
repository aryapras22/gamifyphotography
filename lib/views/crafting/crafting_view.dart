import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/crafting_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/animated_3d_button.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CraftingView extends ConsumerStatefulWidget {
  const CraftingView({Key? key}) : super(key: key);

  @override
  ConsumerState<CraftingView> createState() => _CraftingViewState();
}

class _CraftingViewState extends ConsumerState<CraftingView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(craftingViewModelProvider.notifier).loadCraftingStatus());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(craftingViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (prev?.currentUser?.points != next.currentUser?.points) {
        ref.read(craftingViewModelProvider.notifier).loadCraftingStatus();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Beautiful Sunset Sky Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE2C284), // Golden hour top
                    Color(0xFFB57D68), // Mid orange/pink
                    Color(0xFF5A485F), // Dark purple near bottom
                    Color(0xFF2C273D), // Very dark at the bottom
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 2. Cliffs and Bridge via CustomPaint
          Positioned.fill(
            child: CustomPaint(
              painter: BridgeScenePainter(
                progress: state.bridgeProgress,
                maxSegments: state.maxBridgeSegments,
              ),
            ),
          ),

          // 3. Decorative Elements
          // Table with camera on left cliff
          Positioned(
            left: 20,
            bottom: MediaQuery.of(context).size.height * 0.35 + 20, // slightly above the left cliff
            child: _buildCameraTable(),
          ),

          // Wooden Sign "Old Creativity"
          Positioned(
            left: MediaQuery.of(context).size.width * 0.25 - 40,
            bottom: MediaQuery.of(context).size.height * 0.35 + 20,
            child: _buildWoodenSign("Old\nCreativity"),
          ),

          // Question Mark on right cliff
          Positioned(
            right: 40,
            bottom: MediaQuery.of(context).size.height * 0.35 + 80,
            child: const Text(
              '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
              ),
            ),
          ),

          // Wooden Sign "New Creativity"
          Positioned(
            right: MediaQuery.of(context).size.width * 0.25 - 40,
            bottom: MediaQuery.of(context).size.height * 0.35 + 20,
            child: _buildWoodenSign("New\nCreativity"),
          ),

          // 4. Crafting Controls at Bottom Center
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration text if done
                if (state.craftingDone)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: const Text(
                      'Jembatan Selesai! 🎉\nKamu mencapai New Creativity!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),

                // Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.handyman_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 250,
                      child: LinearPercentIndicator(
                        lineHeight: 24.0,
                        percent: (state.currentPoints / state.requiredPoints).clamp(0.0, 1.0),
                        barRadius: const Radius.circular(12),
                        backgroundColor: Colors.white30,
                        progressColor: const Color(0xFFF59E0B), // Amber
                        center: Text(
                          '${state.requiredPoints} XP untuk Crafting',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Crafting Button
                Animated3DButton(
                  color: (!state.isLoading && !state.craftingDone && state.currentPoints >= state.requiredPoints)
                      ? const Color(0xFFF59E0B) // Active Orange
                      : const Color(0xFF9E9E9E), // Inactive Grey
                  shadowColor: (!state.isLoading && !state.craftingDone && state.currentPoints >= state.requiredPoints)
                      ? const Color(0xFFD97706)
                      : const Color(0xFF616161),
                  onPressed: (state.isLoading || state.craftingDone || state.currentPoints < state.requiredPoints)
                      ? null
                      : () => ref.read(craftingViewModelProvider.notifier).doCrafting(state.requiredPoints),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: state.isLoading 
                      ? const SizedBox(
                          width: 24, 
                          height: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        )
                      : const Text(
                          'Crafting',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraTable() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.camera_alt, color: Colors.black87, size: 28),
            SizedBox(width: 8),
            Icon(Icons.camera, color: Colors.black54, size: 32),
          ],
        ),
        Container(
          width: 80,
          height: 10,
          color: const Color(0xFFB58045), // Table top
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 20, color: const Color(0xFF8B5A2B)),
            const SizedBox(width: 40),
            Container(width: 8, height: 20, color: const Color(0xFF8B5A2B)),
          ],
        ),
      ],
    );
  }

  Widget _buildWoodenSign(String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFCD9551),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF5C3A21), width: 3),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 4))],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              shadows: [Shadow(color: Colors.black54, offset: Offset(1, 1))],
            ),
          ),
        ),
        Container(
          width: 10,
          height: 30,
          color: const Color(0xFF5C3A21),
        ),
      ],
    );
  }
}

class BridgeScenePainter extends CustomPainter {
  final int progress;
  final int maxSegments;

  BridgeScenePainter({required this.progress, required this.maxSegments});

  @override
  void paint(Canvas canvas, Size size) {
    final cliffHeight = size.height * 0.35; // The bottom 35% is cliff
    final cliffY = size.height - cliffHeight;
    final cliffWidth = size.width * 0.3; // 30% width for each cliff
    
    // Draw Left Cliff
    _drawCliff(canvas, 0, cliffY, cliffWidth, cliffHeight);
    
    // Draw Right Cliff
    _drawCliff(canvas, size.width - cliffWidth, cliffY, cliffWidth, cliffHeight);

    // Draw Bridge Segments
    final gapWidth = size.width - (cliffWidth * 2);
    final segmentWidth = gapWidth / maxSegments;
    final bridgeY = cliffY + 10; // Slightly below grass line

    final ropePaint = Paint()
      ..color = const Color(0xFF5C3A21)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final woodPaint = Paint()..color = const Color(0xFF8B5A2B);

    // Always draw ropes connecting the parts that are built
    // Actually, drawing the whole rope first looks nice and gives a hint of the bridge.
    // We can draw a slack rope across the whole gap for structure.
    final path = Path();
    path.moveTo(cliffWidth, bridgeY - 5);
    // Quadratic bezier for slack rope
    path.quadraticBezierTo(size.width / 2, bridgeY + 40, size.width - cliffWidth, bridgeY - 5);
    canvas.drawPath(path, ropePaint);
    
    path.reset();
    path.moveTo(cliffWidth, bridgeY + 15);
    path.quadraticBezierTo(size.width / 2, bridgeY + 60, size.width - cliffWidth, bridgeY + 15);
    canvas.drawPath(path, ropePaint);

    // Draw wood planks up to `progress`
    for (int i = 0; i < progress; i++) {
      final startX = cliffWidth + (i * segmentWidth);
      
      // Plank Rect
      // Calculate curve drop for Y position
      final t = (i + 0.5) / maxSegments; // parametric t for the center of the plank
      final dropY = _calculateBezierDrop(t, 0, 40, 0); // using the control point drop
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startX + 4, bridgeY + dropY, segmentWidth - 8, 12),
        const Radius.circular(4),
      );
      
      // Draw Wood
      canvas.drawRRect(rect, woodPaint);
      
      // Draw Vertical Rope Ties
      canvas.drawLine(
        Offset(startX + segmentWidth / 2, bridgeY - 5 + dropY),
        Offset(startX + segmentWidth / 2, bridgeY + 15 + dropY),
        Paint()..color = const Color(0xFFD2B48C)..strokeWidth = 2,
      );
    }
  }

  void _drawCliff(Canvas canvas, double x, double y, double width, double height) {
    // Dirt
    final dirtPaint = Paint()..color = const Color(0xFF593E26);
    canvas.drawRect(Rect.fromLTWH(x, y, width, height), dirtPaint);

    // Texture (rough dirt circles)
    final texturePaint = Paint()..color = const Color(0xFF422C1A);
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(Offset(x + 20 + i * 20, y + 30 + j * 40), 8, texturePaint);
      }
    }

    // Grass Top
    final grassPaint = Paint()..color = const Color(0xFF3B7119);
    final grassPath = Path();
    grassPath.moveTo(x, y + 10);
    
    // Zig-zag grass pattern
    final steps = 10;
    final stepW = width / steps;
    for (int i = 0; i < steps; i++) {
      grassPath.lineTo(x + (i * stepW) + (stepW / 2), y);
      grassPath.lineTo(x + ((i + 1) * stepW), y + 10);
    }
    grassPath.lineTo(x + width, y + height);
    grassPath.lineTo(x, y + height);
    grassPath.close();

    canvas.drawPath(grassPath, grassPaint);
  }

  double _calculateBezierDrop(double t, double p0, double p1, double p2) {
    // Quadratic bezier equation: B(t) = (1-t)^2 P0 + 2(1-t)t P1 + t^2 P2
    return ((1 - t) * (1 - t) * p0) + (2 * (1 - t) * t * p1) + (t * t * p2);
  }

  @override
  bool shouldRepaint(covariant BridgeScenePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.maxSegments != maxSegments;
  }
}
