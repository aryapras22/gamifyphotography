import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/mission_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/animated_3d_button.dart';
import '../widgets/bouncing_node.dart';

class ModuleListView extends ConsumerStatefulWidget {
  const ModuleListView({Key? key}) : super(key: key);

  @override
  ConsumerState<ModuleListView> createState() => _ModuleListViewState();
}

class _ModuleListViewState extends ConsumerState<ModuleListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(missionViewModelProvider.notifier).fetchModules());
  }

  double _getOffset(int index, double screenWidth) {
    const List<double> pathMultipliers = [
      -0.8, -0.5, -0.2, 0.1, 0.4, 0.7, 
      0.4, 0.1, -0.2, -0.5, -0.8, -0.9, 
      -0.8, -0.5, -0.2, 0.1, 0.4, 0.7, 
      0.9, 0.7,
    ];
    final multiplier = pathMultipliers[index % pathMultipliers.length];
    
    // 60 pixels padding from edge so nodes don't get clipped.
    final maxSwing = (screenWidth / 2) - 60; 
    return multiplier * maxSwing;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missionViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final points = authState.currentUser?.points ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F5), // Light gamified background
      body: SafeArea(
        child: Column(
          children: [
            // Gamified Status Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC800), size: 28),
                      const SizedBox(width: 6),
                      Text('$points XP', style: const TextStyle(color: Color(0xFFFFC800), fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/crafting'),
                    child: Row(
                      children: [
                        const Icon(Icons.diamond_rounded, color: Color(0xFF1CB0F6), size: 28),
                        const SizedBox(width: 6),
                        Text('Craft', style: TextStyle(color: const Color(0xFF1CB0F6), fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 40),
              itemCount: state.modules.length,
              itemBuilder: (context, index) {
                final module = state.modules[index];
                final screenWidth = MediaQuery.of(context).size.width;
                
                double currentOffset = _getOffset(index, screenWidth);
                double prevOffset = index > 0 ? _getOffset(index - 1, screenWidth) : currentOffset;
                double nextOffset = index < state.modules.length - 1 ? _getOffset(index + 1, screenWidth) : currentOffset;

                return SizedBox(
                  height: 110, // Slightly reduced height to match the compact zigzag look
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Connecting path line
                      Positioned.fill(
                        child: CustomPaint(
                          painter: PathPainter(
                            currentOffset: currentOffset,
                            prevOffset: prevOffset,
                            nextOffset: nextOffset,
                            isFirst: index == 0,
                            isLast: index == state.modules.length - 1,
                            isCompleted: module.isCompleted,
                          ),
                        ),
                      ),
                      // The Node
                      Positioned(
                        left: (screenWidth / 2) - 40 + currentOffset, 
                        child: BouncingNode(
                          isPulsing: !module.isCompleted && (index == 0 || state.modules[index - 1].isCompleted), // Pulse if it's the current active mission
                          onTap: () {
                            _showMissionBottomSheet(context, module);
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: module.isCompleted ? const Color(0xFFFFC800) : const Color(0xFF58CC02),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: module.isCompleted ? const Color(0xFFD6A600) : const Color(0xFF58A700),
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ), // Close Expanded
          ],
        ),
      ),
    );
  }

  void _showMissionBottomSheet(BuildContext context, module) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                module.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF4B4B4B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                module.description,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Animated3DButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(missionViewModelProvider.notifier).selectModule(module.id);
                  context.push('/mission/detail');
                },
                child: const Text('MULAI MISI', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }
}

class PathPainter extends CustomPainter {
  final double currentOffset;
  final double prevOffset;
  final double nextOffset;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;

  PathPainter({
    required this.currentOffset,
    required this.prevOffset,
    required this.nextOffset,
    required this.isFirst,
    required this.isLast,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCompleted ? const Color(0xFFFFC800) : const Color(0xFFE5E5E5)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double startX = (size.width / 2) + prevOffset;
    final double midX = (size.width / 2) + currentOffset;
    final double endX = (size.width / 2) + nextOffset;

    final path = Path();

    if (!isFirst) {
      path.moveTo(startX, 0);
      // Curve to center
      path.quadraticBezierTo(startX, size.height / 4, midX, size.height / 2);
    } else {
      path.moveTo(midX, size.height / 2);
    }

    if (!isLast) {
      // Curve from center to bottom
      path.quadraticBezierTo(endX, size.height * 3 / 4, endX, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
