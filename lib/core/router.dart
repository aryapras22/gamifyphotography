import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/auth_view_model.dart';
import '../views/splash_view.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/home/main_layout_view.dart';
import '../views/mission/module_detail_view.dart';
import '../views/mission/challenge_view.dart';
import '../views/mission/feedback_view.dart';
import '../views/crafting/crafting_view.dart';
import '../views/progress/progress_view.dart';
import '../views/leaderboard/leaderboard_view.dart';
import '../views/profile/profile_view.dart';

/// Bridges Riverpod state changes into a [ChangeNotifier] that GoRouter
/// can use as [refreshListenable]. This avoids calling router.refresh()
/// manually inside ref.listen, which can trigger infinite rebuild loops.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen<AuthState>(authViewModelProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final auth = ref.read(authViewModelProvider);
      final loc = state.matchedLocation;

      debugPrint('[Router] redirect → loc=$loc, '
          'isCheckingSession=${auth.isCheckingSession}, '
          'isLoggedIn=${auth.isLoggedIn}');

      if (auth.isCheckingSession) return loc == '/splash' ? null : '/splash';

      const open = ['/login', '/register', '/onboarding'];
      final isOpen = open.contains(loc);

      if (!auth.isLoggedIn && !isOpen) return '/login';
      if (auth.isLoggedIn && (loc == '/login' || loc == '/register' || loc == '/splash')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashView()),
      GoRoute(path: '/login', builder: (_, __) => const LoginView()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterView()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const MainLayoutView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/mission/detail',
        builder: (context, state) => const ModuleDetailView(),
      ),
      GoRoute(
        path: '/mission/challenge',
        builder: (context, state) => const ChallengeView(),
      ),
      GoRoute(
        path: '/mission/feedback',
        builder: (context, state) => const FeedbackView(),
      ),
      GoRoute(
        path: '/crafting',
        builder: (context, state) => const CraftingView(),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressView(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardView(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
    ],
  );
});
