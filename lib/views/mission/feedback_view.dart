import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../view_models/challenge_view_model.dart';
import '../widgets/animated_3d_button.dart';

class FeedbackView extends ConsumerStatefulWidget {
  const FeedbackView({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends ConsumerState<FeedbackView> with SingleTickerProviderStateMixin {
  late AnimationController _pointsController;
  Animation<int>? _pointsAnimation;
  
  @override
  void initState() {
    super.initState();
    _pointsController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeViewModelProvider);
    
    // Initialize animation once points are available
    if (state.pointsEarned > 0 && _pointsAnimation == null) {
      _pointsAnimation = IntTween(begin: 0, end: state.pointsEarned).animate(
        CurvedAnimation(parent: _pointsController, curve: Curves.easeOutQuad),
      );
      _pointsController.forward();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti Lottie Background
            Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_u4yrau.json',
              repeat: false,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFC800), size: 120),
                const SizedBox(height: 20),
                const Text('LUAR BIASA!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF4B4B4B), letterSpacing: 1.5)),
                const SizedBox(height: 10),
                const Text('Misi Berhasil Diselesaikan', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 40),
                
                // Animated Points Counter
                if (state.pointsEarned > 0 && _pointsAnimation != null)
                  AnimatedBuilder(
                    animation: _pointsAnimation!,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1CB0F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF1CB0F6), width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.diamond_rounded, color: Color(0xFF1CB0F6), size: 36),
                            const SizedBox(width: 12),
                            Text('+${_pointsAnimation!.value}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFF1CB0F6))),
                          ],
                        ),
                      );
                    },
                  )
                else
                  const CircularProgressIndicator(),
                  
              ],
            ),
            
            // Bottom Button
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Animated3DButton(
                onPressed: () => context.go('/home'),
                child: const Text('LANJUTKAN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
