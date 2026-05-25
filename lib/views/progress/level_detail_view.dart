// lib/views/progress/level_detail_view.dart
// TASK-04 — Level Detail Screen (2-Page Materi)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../models/level_model.dart';
import '../../view_models/level_view_model.dart';
import '../quiz/pretest_view.dart';

class LevelDetailView extends ConsumerStatefulWidget {
  final LevelConfig config;

  const LevelDetailView({Key? key, required this.config}) : super(key: key);

  @override
  ConsumerState<LevelDetailView> createState() => _LevelDetailViewState();
}

class _LevelDetailViewState extends ConsumerState<LevelDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  MateriContent get _content => widget.config.materiContent!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onComplete() async {
    await ref
        .read(levelViewModelProvider.notifier)
        .completeMaterialLevel(widget.config.levelNumber);

    if (!mounted) return;

    // Cek apakah perlu tampilkan pretest
    final lvState = ref.read(levelViewModelProvider);
    if (lvState.showPretest) {
      ref.read(levelViewModelProvider.notifier).clearShowPretest();
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PretestView()),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.bodyText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Level ${widget.config.levelNumber}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.config.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.bodyText,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.brandBlue,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.brandBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Pengertian'),
            Tab(text: 'Cara Pakai'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _Page1(content: _content),
          _Page2(
            content: _content,
            onComplete: _onComplete,
          ),
        ],
      ),
    );
  }
}

// ── Page 1: Pengertian + Referensi Foto ──────────────────────────────────

class _Page1 extends StatelessWidget {
  final MateriContent content;
  const _Page1({required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Referensi foto
          if (content.page1ImagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                content.page1ImagePath!,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library_rounded, size: 48, color: AppColors.disabled),
                      const SizedBox(height: 8),
                      Text(
                        content.page1Title,
                        style: const TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Foto referensi: ${content.page1Title}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Judul
          Text(
            content.page1Title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.bodyText,
            ),
          ),
          const SizedBox(height: 16),
          // Deskripsi
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Text(
              content.page1Description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.bodyText,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Hint untuk lanjut
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Geser ke tab "Cara Pakai" untuk melanjutkan',
                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.secondaryText),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Page 2: Kapan & Cara Menggunakan ─────────────────────────────────────

class _Page2 extends StatelessWidget {
  final MateriContent content;
  final VoidCallback onComplete;

  const _Page2({required this.content, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kapan digunakan
          _SectionCard(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.brandBlue,
            title: 'Kapan Digunakan',
            content: content.page2WhenToUse,
          ),
          const SizedBox(height: 16),
          // Cara menggunakan
          _SectionCard(
            icon: Icons.tips_and_updates_rounded,
            iconColor: AppColors.lensGold,
            title: 'Cara Menggunakan',
            content: content.page2HowToUse,
          ),
          const SizedBox(height: 32),
          // Tombol Selesai
          ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: AppColors.surfaceWhite,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, size: 22),
                SizedBox(width: 8),
                Text(
                  'Selesai & Lanjutkan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.bodyText,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
