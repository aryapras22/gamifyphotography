import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/progress_view_model.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressView extends ConsumerStatefulWidget {
  const ProgressView({Key? key}) : super(key: key);

  @override
  ConsumerState<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends ConsumerState<ProgressView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(progressViewModelProvider.notifier).loadUserProgress();
      ref.read(progressViewModelProvider.notifier).loadBadges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressViewModelProvider);
    final user = state.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text(
          'Profil & Progres',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Color(0xFF0F172A), // Slate 900
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Premium User Card ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    offset: Offset(0, 12),
                    blurRadius: 24,
                  )
                ],
              ),
              child: Column(
                children: [
                  // Gradient Avatar Ring
                  Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Indigo to Purple
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Level and Progress Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LEVEL',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user.level}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF6366F1)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'TOTAL XP',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 24),
                              const SizedBox(width: 4),
                              Text(
                                '${user.points}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Premium Gradient Progress Bar
                  LinearPercentIndicator(
                    lineHeight: 16.0,
                    percent: state.progressPercentage,
                    barRadius: const Radius.circular(8),
                    backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                    linearGradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)], // Amber to Gold
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(state.progressPercentage * 100).toInt()}% menuju Level ${user.level + 1}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ── Badges Section ──────────────────────────────────────────
            const Text(
              'Koleksi Badge',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),

            if (state.earnedBadges.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'Belum ada badge yang diperoleh.\nAyo selesaikan misi!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w600, height: 1.5),
                  ),
                ),
              )
            else
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: state.earnedBadges.length,
                itemBuilder: (context, index) {
                  final badge = state.earnedBadges[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x05000000),
                          offset: Offset(0, 8),
                          blurRadius: 16,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glassmorphic / Gradient Icon Container
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFEF3C7), Color(0xFFFEF08A)], // Light Amber gradient
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                offset: const Offset(0, 8),
                                blurRadius: 16,
                              )
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.workspace_premium_rounded, // Premium badge icon
                              size: 44,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          badge.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            badge.description,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
