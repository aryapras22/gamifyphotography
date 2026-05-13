import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/daily_login_view_model.dart';
import '../../view_models/mission_view_model.dart';
import '../widgets/bouncing_node.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(missionViewModelProvider.notifier).fetchModules();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(missionViewModelProvider, (prev, next) {
        if ((prev?.modules.isEmpty ?? true) && next.modules.isNotEmpty) {
          _scrollToActiveModule(next.modules);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveModule(List modules) {
    final idx = modules.indexWhere((m) => !m.isCompleted);
    if (idx <= 0) return;
    const headerHeight = 200.0;
    const nodeHeight = 120.0;
    _scrollController.animateTo(
      headerHeight + idx * nodeHeight,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'pagi';
    if (hour >= 11 && hour < 17) return 'siang';
    return 'malam';
  }

  double _getOffset(int index, double screenWidth) {
    const List<double> pathMultipliers = [
      0.0, 0.4, 0.7, 0.4, 0.0, -0.4, -0.7, -0.4, 0.0, 0.4,
    ];
    final multiplier = pathMultipliers[index % pathMultipliers.length];
    final maxSwing = (screenWidth / 2) - 80; 
    return multiplier * maxSwing;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.currentUser;
    final streak = ref.watch(dailyLoginViewModelProvider).currentStreak;
    final missionState = ref.watch(missionViewModelProvider);

    // Fallback data if user is null (preventing infinite loading)
    final userName = user?.name ?? 'Fotografer';
    final userPoints = user?.points ?? 0;
    final userLevel = user?.level ?? 1;
    final xpProgress = (userPoints % 100) / 100;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Dashboard Header ────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GreetingHeader(name: userName, greeting: _greeting()),
                    const SizedBox(height: 16),
                    _XpCard(
                      level: userLevel,
                      points: userPoints,
                      xpProgress: xpProgress,
                      streak: streak,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('MISI ANDA', style: AppTextStyles.title.copyWith(fontSize: 14, color: AppColors.secondaryText)),
                        if (missionState.isLoading)
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Mission Path ────────────────────────────────────
            if (missionState.isLoading && missionState.modules.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (missionState.errorMessage != null && missionState.modules.isEmpty)
              SliverFillRemaining(
                child: Center(child: Text(missionState.errorMessage!)),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final module = missionState.modules[index];
                    final screenWidth = MediaQuery.of(context).size.width;
                    
                    double currentOffset = _getOffset(index, screenWidth);
                    double prevOffset = index > 0 ? _getOffset(index - 1, screenWidth) : currentOffset;
                    double nextOffset = index < missionState.modules.length - 1 ? _getOffset(index + 1, screenWidth) : currentOffset;

                    return SizedBox(
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: PathPainter(
                                currentOffset: currentOffset,
                                prevOffset: prevOffset,
                                nextOffset: nextOffset,
                                isFirst: index == 0,
                                isLast: index == missionState.modules.length - 1,
                                isCompleted: module.isCompleted,
                              ),
                            ),
                          ),
                          Positioned(
                            left: (screenWidth / 2) - 40 + currentOffset, 
                            child: BouncingNode(
                              isPulsing: !module.isCompleted && (index == 0 || missionState.modules[index - 1].isCompleted),
                              onTap: () => _showMissionBottomSheet(context, module),
                              child: Container(
                                width: 80,
                                height: 80,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: module.isCompleted ? AppColors.lensGold : AppColors.brandBlue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: module.isCompleted ? const Color(0xFFD6A600) : const Color(0xFF1590C8),
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: AppTextStyles.display.copyWith(color: AppColors.surfaceWhite, fontSize: 28),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: missionState.modules.length,
                ),
              ),

            // ── Footer Padding ──────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                module.title,
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                module.description,
                style: AppTextStyles.body.copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(missionViewModelProvider.notifier).selectModule(module.id);
                  context.push('/mission/detail');
                },
                child: Text('MULAI MISI', style: AppTextStyles.button),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets & Painters
// ─────────────────────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String name;
  final String greeting;
  const _GreetingHeader({required this.name, required this.greeting});
  @override
  Widget build(BuildContext context) {
    final firstName = name.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selamat $greeting 👋', style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(firstName, style: AppTextStyles.heading),
      ],
    );
  }
}

class _XpCard extends StatelessWidget {
  final int level;
  final int points;
  final double xpProgress;
  final int streak;
  const _XpCard({required this.level, required this.points, required this.xpProgress, required this.streak});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.brandBlue, borderRadius: BorderRadius.circular(12)),
            child: Text('Lv.$level', style: AppTextStyles.caption.copyWith(color: AppColors.surfaceWhite, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: xpProgress, minHeight: 8, backgroundColor: AppColors.cardBorder, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpBarFill)),
                ),
                const SizedBox(height: 4),
                Text('$points XP', style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text('$streak', style: AppTextStyles.body.copyWith(color: AppColors.streakFire, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
        ],
      ),
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

  PathPainter({required this.currentOffset, required this.prevOffset, required this.nextOffset, required this.isFirst, required this.isLast, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCompleted ? AppColors.lensGold : AppColors.cardBorder
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double startX = (size.width / 2) + prevOffset;
    final double midX = (size.width / 2) + currentOffset;
    final double endX = (size.width / 2) + nextOffset;

    final path = Path();
    if (!isFirst) {
      path.moveTo(startX, 0);
      path.quadraticBezierTo(startX, size.height / 4, midX, size.height / 2);
    } else {
      path.moveTo(midX, size.height / 2);
    }
    if (!isLast) {
      path.quadraticBezierTo(endX, size.height * 3 / 4, endX, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.isCompleted != isCompleted ||
           oldDelegate.currentOffset != currentOffset;
  }
}
