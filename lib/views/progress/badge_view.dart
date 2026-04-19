import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/progress_view_model.dart';

class BadgeView extends ConsumerStatefulWidget {
  const BadgeView({Key? key}) : super(key: key);

  @override
  ConsumerState<BadgeView> createState() => _BadgeViewState();
}

class _BadgeViewState extends ConsumerState<BadgeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(progressViewModelProvider.notifier).loadBadges());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Badges')),
      body: state.earnedBadges.isEmpty
          ? const Center(child: Text('No badges earned yet. Keep going!'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: state.earnedBadges.length,
              itemBuilder: (context, index) {
                final badge = state.earnedBadges[index];
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield, size: 50, color: Colors.amber), // Mock badge icon
                      const SizedBox(height: 10),
                      Text(badge.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(badge.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
