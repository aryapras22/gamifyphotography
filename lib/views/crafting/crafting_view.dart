import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/crafting_item_model.dart';
import '../../providers/crafting_items_provider.dart';
import '../../view_models/crafting_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/brutal_widgets.dart';
import '../quiz/pretest_view.dart';

class CraftingView extends ConsumerStatefulWidget {
  const CraftingView({super.key});

  @override
  ConsumerState<CraftingView> createState() => _CraftingViewState();
}

class _CraftingViewState extends ConsumerState<CraftingView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(craftingViewModelProvider.notifier).loadCraftingStatus(),
    );
  }

  /// Parses hex color string to Color
  Color _parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(craftingViewModelProvider);
    final craftingItemsAsync = ref.watch(craftingItemsProvider);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (prev?.currentUser?.craftingBalance != next.currentUser?.craftingBalance ||
          prev?.currentUser?.points != next.currentUser?.points) {
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
        child: craftingItemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Gagal memuat item: $e')),
          data: (items) => _buildContent(context, state, items),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CraftingState state, List<CraftingItemModel> items) {
    return SingleChildScrollView(
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

          // XP Balance Card — shows both crafting balance and total XP
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
                      'SALDO CRAFTING',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⭐ ${state.craftingBalance}',
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total XP: ${state.currentPoints}',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final owned = index < state.bridgeProgress;
              final locked = index > state.bridgeProgress;
              final nextToCraft = index == state.bridgeProgress;
              final affordable = nextToCraft && state.craftingBalance >= item.cost;

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
                      // Image Preview Box
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _parseColor(item.colorHex),
                            border: Border.all(color: Colors.black, width: 2.0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Item image from Firebase Storage
                              if (item.imagePath.isNotEmpty)
                                CachedNetworkImage(
                                  imageUrl: item.imagePath,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: Icon(
                                      Icons.image_rounded,
                                      size: 36,
                                      color: Colors.black.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      size: 36,
                                      color: Colors.black.withValues(alpha: 0.3),
                                    ),
                                  ),
                                )
                              else
                                Center(
                                  child: Icon(
                                    Icons.image_rounded,
                                    size: 36,
                                    color: Colors.black.withValues(alpha: 0.3),
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
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: GoogleFonts.inter(
                            color: AppColors.secondaryText,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
    );
  }
}
