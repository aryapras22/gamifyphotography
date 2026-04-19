import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/crafting_view_model.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Crafting')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Points: ${state.currentPoints}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Text('Requires ${state.requiredPoints} points to craft a Bridge', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            if (state.craftingDone)
              const Text('Crafting Successful!', style: TextStyle(color: Colors.green, fontSize: 24))
            else
              ElevatedButton(
                onPressed: state.currentPoints >= state.requiredPoints
                    ? () => ref.read(craftingViewModelProvider.notifier).doCrafting(state.requiredPoints)
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not enough points!')),
                        );
                        context.go('/home');
                      },
                child: const Text('Craft Bridge'),
              ),
          ],
        ),
      ),
    );
  }
}
