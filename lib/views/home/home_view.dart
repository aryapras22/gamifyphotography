import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/home_view_model.dart';
import '../../view_models/auth_view_model.dart';

class HomeView extends ConsumerWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeVM = ref.watch(homeViewModelProvider);
    final user = ref.watch(authViewModelProvider).currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authViewModelProvider.notifier).logout();
              context.go('/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Hello, ${user.name}', style: const TextStyle(fontSize: 20)),
                    Text('Level: ${homeVM.currentLevel} | Points: ${homeVM.currentPoints}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => homeVM.navigateToMission(context),
              child: const Text('Missions'),
            ),
            ElevatedButton(
              onPressed: () => homeVM.navigateToCrafting(context),
              child: const Text('Crafting'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/progress'),
              child: const Text('My Progress'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/leaderboard'),
              child: const Text('Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}
