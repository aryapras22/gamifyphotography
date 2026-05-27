import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../view_models/crafting_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/brutal_widgets.dart';
import '../quiz/pretest_view.dart';

class CraftingView extends ConsumerStatefulWidget {
  const CraftingView({super.key});

  @override
  ConsumerState<CraftingView> createState() => _CraftingViewState();
}

class CraftItem {
  final String name;
  final int cost;
  final IconData icon;
  final Color tint;

  const CraftItem({
    required this.name,
    required this.cost,
    required this.icon,
    required this.tint,
  });
}

const List<CraftItem> _craftItems = [
  CraftItem(
    name: "Frame Polaroid",
    cost: 200,
    icon: Icons.crop_original_rounded,
    tint: Color(0xFFFBCFE8), // pink-200
  ),
  CraftItem(
    name: "Sticker Set",
    cost: 150,
    icon: Icons.face_rounded,
    tint: Color(0xFFA7F3D0), // emerald-200
  ),
  CraftItem(
    name: "Filter Vintage",
    cost: 350,
    icon: Icons.filter_hdr_rounded,
    tint: Color(0xFFFEF08A), // yellow-200
  ),
  CraftItem(
    name: "Efek Sparkle",
    cost: 500,
    icon: Icons.auto_awesome_rounded,
    tint: Color(0xFFE9D5FF), // purple-200
  ),
  CraftItem(
    name: "Lensa Bokeh",
    cost: 800,
    icon: Icons.camera_rounded,
    tint: Color(0xFFBFDBFE), // blue-200
  ),
  CraftItem(
    name: "Badge Skin Gold",
    cost: 1200,
    icon: Icons.workspace_premium_rounded,
    tint: Color(0xFFFED7AA), // orange-200
  ),
];

class _CraftingViewState extends ConsumerState<CraftingView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(craftingViewModelProvider.notifier).loadCraftingStatus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(craftingViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (prev?.currentUser?.points != next.currentUser?.points) {
        ref.read(craftingViewModelProvider.notifier).loadCraftingStatus();
      }
    });

    // Tampilkan posttest saat crafting selesai
    ref.listen<CraftingState>(craftingViewModelProvider, (prev, next) {
      if (next.triggerPosttest && !(prev?.triggerPosttest ?? false)) {
        ref.read(craftingViewModelProvider.notifier).clearPosttestTrigger();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PretestView(testType: TestType.posttest),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      appBar: BrutalAppBar(
        title: 'Toko Reward',
        subtitle: 'CRAFTING',
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tukar XP-mu untuk item eksklusif.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),

              // XP Balance Card (Indigo with Yellow Accent Sparkle Box)
              BrutalCard(
                backgroundColor: AppColors.brandPrimary,
                shadowColor: Colors.black,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SALDO XP-MU',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '⭐ ${state.currentPoints}',
                          style: GoogleFonts.bricolageGrotesque(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.brandAccent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 2.0),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Items Grid (2 columns)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _craftItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final item = _craftItems[index];
                  final owned = index < state.bridgeProgress;
                  final locked = index > state.bridgeProgress;
                  final nextToCraft = index == state.bridgeProgress;
                  final affordable = nextToCraft && state.currentPoints >= item.cost;

                  // Button properties
                  String buttonText = 'Craft';
                  VoidCallback? onPressed;
                  BrutalButtonVariant buttonVariant = BrutalButtonVariant.primary;

                  if (owned) {
                    buttonText = 'Dimiliki';
                    onPressed = null;
                  } else if (locked) {
                    buttonText = 'Terkunci';
                    onPressed = null;
                  } else {
                    // Next to craft
                    buttonText = 'Craft';
                    if (affordable) {
                      onPressed = () => ref
                          .read(craftingViewModelProvider.notifier)
                          .doCrafting(item.cost);
                      buttonVariant = BrutalButtonVariant.accent;
                    } else {
                      onPressed = null;
                    }
                  }

                  return Opacity(
                    opacity: locked ? 0.55 : 1.0,
                    child: BrutalCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Aspect Square Preview Box
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: item.tint,
                                border: Border.all(color: Colors.black, width: 2.0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Icon(
                                      item.icon,
                                      size: 36,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (owned)
                                    const Positioned(
                                      top: 6,
                                      right: 6,
                                      child: BrutalChip(
                                        tone: BrutalChipTone.success,
                                        child: Text('DIMILIKI'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Text Label and XP Cost
                          Text(
                            item.name,
                            style: AppTextStyles.title.copyWith(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '⭐ ${item.cost} XP',
                            style: GoogleFonts.inter(
                              color: AppColors.secondaryText,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Action button
                          BrutalButton(
                            height: 36,
                            variant: buttonVariant,
                            onPressed: onPressed,
                            borderRadius: 8,
                            child: state.isLoading && nextToCraft
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    buttonText.toUpperCase(),
                                    style: GoogleFonts.bricolageGrotesque(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
