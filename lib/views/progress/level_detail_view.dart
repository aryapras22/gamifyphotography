import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/level_model.dart';
import '../../view_models/level_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../providers/service_providers.dart';
import '../widgets/brutal_widgets.dart';
import '../mission/custom_camera_view.dart';

class LevelDetailView extends ConsumerStatefulWidget {
  final LevelConfig config;

  const LevelDetailView({super.key, required this.config});

  @override
  ConsumerState<LevelDetailView> createState() => _LevelDetailViewState();
}

class _LevelDetailViewState extends ConsumerState<LevelDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTabIdx = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _activeTabIdx = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  MateriContent get _content {
    final fsLevel = ref.watch(levelViewModelProvider.notifier)
        .getLevelContent(widget.config.levelNumber);
    if (fsLevel != null) {
      final merged = fsLevel.toMateriContent();
      if (merged != null) return merged;
    }
    return widget.config.materiContent!;
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      appBar: BrutalAppBar(
        title: widget.config.title,
        subtitle: 'Misi ${widget.config.levelNumber}',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Neo-brutalist Tab Switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 2.0),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _tabController.animateTo(0);
                          setState(() => _activeTabIdx = 0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _activeTabIdx == 0 ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'PENGERTIAN',
                            style: GoogleFonts.bricolageGrotesque(
                              color: _activeTabIdx == 0 ? Colors.white : const Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _tabController.animateTo(1);
                          setState(() => _activeTabIdx = 1);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _activeTabIdx == 1 ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'CARA PAKAI',
                            style: GoogleFonts.bricolageGrotesque(
                              color: _activeTabIdx == 1 ? Colors.white : const Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Pages Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _Page1(content: content),
                  _Page2(
                    content: content,
                    levelNumber: widget.config.levelNumber,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1: Pengertian ──────────────────────────────────────────────────────

class _Page1 extends StatefulWidget {
  final MateriContent content;

  const _Page1({required this.content});

  @override
  State<_Page1> createState() => _Page1State();
}

class _Page1State extends State<_Page1> {
  int _photoIdx = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.content.allImageUrls;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reference Image Carousel Card
          if (imageUrls.isNotEmpty) ...[
            BrutalCard(
              padding: EdgeInsets.zero,
              shadowColor: Colors.black,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        onPageChanged: (idx) => setState(() => _photoIdx = idx),
                        itemBuilder: (context, idx) {
                          final url = imageUrls[idx];
                          if (url.startsWith('http')) {
                            return Image.network(url, fit: BoxFit.cover);
                          } else {
                            return Image.asset(url, fit: BoxFit.cover);
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.black, width: 2.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Foto referensi: ${widget.content.page1Title}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (imageUrls.length > 1)
                          Row(
                            children: List.generate(imageUrls.length, (idx) {
                              final active = idx == _photoIdx;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                                width: active ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active ? Colors.black : const Color(0xFFCBD5E1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Title & Description
          BrutalCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.content.page1Title,
                  style: AppTextStyles.heading,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.content.page1Description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.brandInk,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Slide Swipe Help Pill
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3), // light yellow
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 2.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Geser ke tab Cara Pakai untuk melanjutkan ',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2: Cara Pakai ──────────────────────────────────────────────────────

class _Page2 extends ConsumerStatefulWidget {
  final MateriContent content;
  final int levelNumber;

  const _Page2({
    required this.content,
    required this.levelNumber,
  });

  @override
  ConsumerState<_Page2> createState() => _Page2State();
}

class _Page2State extends ConsumerState<_Page2> {
  XFile? _capturedPhoto;
  bool _isUploading = false;

  String get _moduleId {
    String moduleId = 'M${widget.levelNumber.toString().padLeft(2, '0')}';
    final fsLevels = ref.read(levelViewModelProvider).firestoreLevels;
    try {
      final matched = fsLevels.firstWhere((l) => l.levelNumber == widget.levelNumber);
      moduleId = matched.id;
    } catch (_) {}
    return moduleId;
  }

  Future<void> _openCamera() async {
    final visualGuideUrl = widget.content.page2HowToUseImageUrl;
    final XFile? xfile = await Navigator.of(context).push<XFile?>(
      MaterialPageRoute(
        builder: (_) => CustomCameraView(
          moduleId: _moduleId,
          visualGuideUrl: visualGuideUrl,
        ),
      ),
    );
    if (xfile != null && mounted) {
      setState(() => _capturedPhoto = xfile);
    }
  }

  Future<void> _submitPhoto() async {
    if (_capturedPhoto == null || _isUploading) return;

    setState(() => _isUploading = true);

    try {
      final challengeService = ref.read(challengeServiceProvider);
      final submissionService = ref.read(photoSubmissionServiceProvider);
      final user = ref.read(authViewModelProvider).currentUser;

      if (user == null) throw Exception('User not found');

      // 1. Upload photo to Firebase Storage
      final photoUrl = await challengeService.uploadPhoto(_capturedPhoto!);

      // 2. Create submission in Firestore
      final moduleTitle = widget.content.page1Title;
      await submissionService.submitPhoto(
        userId: user.id,
        userName: user.name,
        moduleId: _moduleId,
        moduleTitle: moduleTitle,
        photoUrl: photoUrl,
      );

      // 3. Mark level as completed
      await ref
          .read(levelViewModelProvider.notifier)
          .completeMaterialLevel(widget.levelNumber);

      if (!mounted) return;

      // 4. Show success and navigate back
      await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (dialogCtx) => _SubmissionSuccessModal(
          levelTitle: widget.content.page1Title,
          onDismiss: () {
            Navigator.pop(dialogCtx);
            Navigator.pop(context); // Pop level detail view
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim foto: $e'),
            backgroundColor: AppColors.brandDanger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visualGuideUrl = widget.content.page2HowToUseImageUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // InfoCard: Kapan Digunakan
          _InfoCard(
            title: 'Kapan Digunakan',
            body: widget.content.page2WhenToUse,
            icon: Icons.calendar_today_rounded,
            tint: const Color(0xFFF3E8FF), // bg-purple-100
          ),
          const SizedBox(height: 16),

          // InfoCard: Cara Menggunakan
          _InfoCard(
            title: 'Cara Menggunakan',
            body: widget.content.page2HowToUse,
            icon: Icons.tips_and_updates_rounded,
            tint: const Color(0xFFFEF9C3), // bg-yellow-100
          ),
          const SizedBox(height: 24),

          // Camera / Photo section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _capturedPhoto != null ? 'FOTO KAMU' : 'PANDUAN KAMERA',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondaryText,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),

              if (_capturedPhoto != null)
                // Show captured photo preview
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.black, width: 2.0),
                        boxShadow: const [BoxShadow(color: AppColors.brandSuccess, offset: Offset(4, 4))],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_capturedPhoto!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Retake button
                    GestureDetector(
                      onTap: _isUploading ? null : _openCamera,
                      child: Text(
                        'Ambil ulang foto →',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Show camera guide preview (tap to open camera)
                GestureDetector(
                  onTap: _openCamera,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black, width: 2.0),
                      boxShadow: const [BoxShadow(color: AppColors.brandAccent, offset: Offset(4, 4))],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 2.0),
                          color: visualGuideUrl != null && visualGuideUrl.isNotEmpty
                              ? Colors.white
                              : null,
                          gradient: visualGuideUrl == null || visualGuideUrl.isEmpty
                              ? const LinearGradient(
                                  colors: [Color(0xFFFED7AA), Color(0xFFF472B6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            if (visualGuideUrl != null && visualGuideUrl.isNotEmpty && visualGuideUrl.startsWith('http'))
                              Positioned.fill(
                                child: SvgPicture.network(
                                  visualGuideUrl,
                                  fit: BoxFit.contain,
                                  placeholderBuilder: (_) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.brandAccent,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _GuideGridPainter(),
                                ),
                              ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.camera_alt_rounded, color: AppColors.brandAccent, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'TAP UNTUK FOTO',
                                      style: GoogleFonts.bricolageGrotesque(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),

          // Submit Button
          BrutalButton(
            fullWidth: true,
            onPressed: _capturedPhoto != null && !_isUploading ? _submitPhoto : null,
            variant: _capturedPhoto != null ? BrutalButtonVariant.accent : BrutalButtonVariant.secondary,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.0),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_capturedPhoto != null ? 'SUBMIT FOTO ' : 'AMBIL FOTO DULU'),
                      if (_capturedPhoto != null)
                        const Icon(Icons.send_rounded, color: Colors.black, size: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color tint;

  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2.0),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.brandInk,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 1.0;

    final circlePaint = Paint()
      ..color = AppColors.brandAccent
      ..style = PaintingStyle.fill;

    final circleStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final w = size.width;
    final h = size.height;

    // Draw 3x3 Grid
    canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), linePaint);
    canvas.drawLine(Offset(w * 2 / 3, 0), Offset(w * 2 / 3, h), linePaint);
    canvas.drawLine(Offset(0, h * 0.33), Offset(w, h * 0.33), linePaint);
    canvas.drawLine(Offset(0, h * 0.67), Offset(w, h * 0.67), linePaint);

    // Draw yellow dots at intersections
    final points = [
      Offset(w / 3, h * 0.33),
      Offset(w * 2 / 3, h * 0.33),
      Offset(w / 3, h * 0.67),
      Offset(w * 2 / 3, h * 0.67),
    ];

    for (final pt in points) {
      canvas.drawCircle(pt, 5.0, circlePaint);
      canvas.drawCircle(pt, 5.0, circleStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Success Dialog Modal ────────────────────────────────────────────────────

class _LevelCompleteModal extends StatelessWidget {
  final String levelTitle;
  final VoidCallback onActionPressed;

  const _LevelCompleteModal({
    required this.levelTitle,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.black, width: 2.0),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
            ),
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Misi Selesai!',
                  style: AppTextStyles.display.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Kamu menguasai teknik ',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText),
                    children: [
                      TextSpan(
                        text: levelTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.brandBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 2.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        '+100 XP',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                BrutalButton(
                  fullWidth: true,
                  onPressed: onActionPressed,
                  variant: BrutalButtonVariant.primary,
                  child: const Text('PRAKTIK SEKARANG →'),
                ),
              ],
            ),
          ),
          Positioned(
            top: -40,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.brandAccent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 2.0),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.black,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Submission Success Modal ────────────────────────────────────────────────

class _SubmissionSuccessModal extends StatelessWidget {
  final String levelTitle;
  final VoidCallback onDismiss;

  const _SubmissionSuccessModal({
    required this.levelTitle,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.black, width: 2.0),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
            ),
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Foto Terkirim! 📸',
                  style: AppTextStyles.display.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Foto untuk misi ',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText),
                    children: [
                      TextSpan(
                        text: levelTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const TextSpan(text: ' sudah dikirim.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.brandAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.brandAccent, width: 2.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_top_rounded, color: AppColors.brandAccent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Menunggu penilaian admin.\nKamu tetap bisa lanjut ke misi lain!',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                BrutalButton(
                  fullWidth: true,
                  onPressed: onDismiss,
                  variant: BrutalButtonVariant.primary,
                  child: const Text('LANJUT MISI LAIN →'),
                ),
              ],
            ),
          ),
          Positioned(
            top: -40,
            child: Transform.rotate(
              angle: 0.1,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.brandSuccess,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 2.0),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
