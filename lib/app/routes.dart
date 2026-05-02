import 'package:go_router/go_router.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/home/main_layout_view.dart';
import '../views/mission/module_list_view.dart';
import '../views/mission/module_detail_view.dart';
import '../views/mission/challenge_view.dart';
import '../views/mission/challenge_brief_view.dart';
import '../views/mission/feedback_view.dart';
import '../views/crafting/crafting_view.dart';
import '../views/progress/progress_view.dart';
import '../views/leaderboard/leaderboard_view.dart';
import '../views/profile/profile_view.dart';

GoRouter getRouter(String initialRoute) => GoRouter(
  initialLocation: initialRoute,
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainLayoutView(),
    ),
    GoRoute(
      path: '/mission',
      builder: (context, state) => const ModuleListView(),
    ),
    GoRoute(
      path: '/mission/detail',
      builder: (context, state) => const ModuleDetailView(),
    ),
    GoRoute(
      path: '/mission/brief',
      builder: (context, state) => const ChallengeBriefView(),
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
