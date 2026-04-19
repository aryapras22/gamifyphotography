import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/progress_view_model.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../widgets/animated_3d_button.dart';

class ProgressView extends ConsumerStatefulWidget {
  const ProgressView({Key? key}) : super(key: key);

  @override
  ConsumerState<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends ConsumerState<ProgressView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(progressViewModelProvider.notifier).loadUserProgress());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressViewModelProvider);
    final user = state.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F5),
      appBar: AppBar(
        title: const Text('Profil & Progres', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4B4B4B))),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                boxShadow: const [BoxShadow(color: Color(0xFFE5E5E5), offset: Offset(0, 6))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1CB0F6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1CB0F6), width: 4),
                    ),
                    child: const Icon(Icons.person_rounded, size: 60, color: Color(0xFF1CB0F6)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF4B4B4B)),
                  ),
                  const SizedBox(height: 24),
                  
                  // Level and Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('LEVEL ${user.level}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFFFC800))),
                      Text('${user.points} XP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1CB0F6))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 24.0,
                    percent: state.progressPercentage,
                    barRadius: const Radius.circular(12),
                    backgroundColor: const Color(0xFFE5E5E5),
                    progressColor: const Color(0xFFFFC800),
                    center: Text(
                      '${(state.progressPercentage * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Badges Button
            Animated3DButton(
              color: const Color(0xFF1CB0F6),
              shadowColor: const Color(0xFF007BCC),
              onPressed: () => context.push('/progress/badges'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shield_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('LIHAT KOLEKSI BADGE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
