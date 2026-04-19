import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/crafting_view_model.dart';
import '../widgets/animated_3d_button.dart';

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
      backgroundColor: const Color(0xFFF0F4F5),
      appBar: AppBar(
        title: const Text('Crafting', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4B4B4B))),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF4B4B4B)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                  boxShadow: const [BoxShadow(color: Color(0xFFE5E5E5), offset: Offset(0, 6))],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.build_circle_rounded, size: 80, color: Color(0xFF1CB0F6)),
                    const SizedBox(height: 24),
                    const Text(
                      'Buat Item Baru',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF4B4B4B)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('XP Kamu: ', style: TextStyle(fontSize: 18, color: Color(0xFF4B4B4B))),
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC800), size: 24),
                        Text(' ${state.currentPoints}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFFFC800))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Butuh: ', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC800), size: 20),
                        Text(' ${state.requiredPoints} XP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              if (state.craftingDone)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF58CC02), width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'Berhasil Dibuat! 🎉',
                      style: TextStyle(color: Color(0xFF58CC02), fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                )
              else
                Animated3DButton(
                  color: state.currentPoints >= state.requiredPoints ? const Color(0xFF1CB0F6) : const Color(0xFFE5E5E5),
                  shadowColor: state.currentPoints >= state.requiredPoints ? const Color(0xFF007BCC) : const Color(0xFFC4C4C4),
                  onPressed: state.currentPoints >= state.requiredPoints
                      ? () => ref.read(craftingViewModelProvider.notifier).doCrafting(state.requiredPoints)
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('XP Kamu tidak cukup!')),
                          );
                        },
                  child: Text(
                    'CRAFT SEKARANG',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: state.currentPoints >= state.requiredPoints ? Colors.white : const Color(0xFFAFAFAF),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
