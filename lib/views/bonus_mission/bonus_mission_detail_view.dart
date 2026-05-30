import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/bonus_mission_model.dart';
import '../../models/photo_submission_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../providers/service_providers.dart';
import '../../providers/submission_providers.dart';
import '../widgets/brutal_widgets.dart';
import '../mission/custom_camera_view.dart';

class BonusMissionDetailView extends ConsumerStatefulWidget {
  final BonusMissionModel mission;

  const BonusMissionDetailView({super.key, required this.mission});

  @override
  ConsumerState<BonusMissionDetailView> createState() =>
      _BonusMissionDetailViewState();
}

class _BonusMissionDetailViewState extends ConsumerState<BonusMissionDetailView>
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

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      appBar: BrutalAppBar(
        title: m.title,
        subtitle: 'MISI TAMBAHAN',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Switcher
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
                            'DEFINISI',
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
                            'INSTRUKSI',
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

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BonusPage1(mission: m),
                  _BonusPage2(mission: m),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1: Definisi & Contoh Foto ──────────────────────────────────────────

class _BonusPage1 extends StatefulWidget {
  final BonusMissionModel mission;

  const _BonusPage1({required this.mission});

  @override
  State<_BonusPage1> createState() => _BonusPage1State();
}

class _BonusPage1State extends State<_BonusPage1> {
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
    final imageUrls = widget.mission.page1ImageUrls;

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
                            'Foto referensi: ${widget.mission.page1Title}',
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
                  widget.mission.page1Title.isNotEmpty
                      ? widget.mission.page1Title
                      : widget.mission.title,
                  style: AppTextStyles.heading,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.mission.page1Description.isNotEmpty
                      ? widget.mission.page1Description
                      : widget.mission.description,
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
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 2.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Geser ke tab Instruksi untuk melanjutkan ',
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

// ── Page 2: Instruksi & Visual Guide ─────────────────────────────────────────

class _BonusPage2 extends ConsumerStatefulWidget {
  final BonusMissionModel mission;

  const _BonusPage2({required this.mission});

  @override
  ConsumerState<_BonusPage2> createState() => _BonusPage2State();
}

class _BonusPage2State extends ConsumerState<_BonusPage2> {
  XFile? _capturedPhoto;
  bool _isUploading = false;

  String get _moduleId => widget.mission.id;

  /// True when the user already has an accepted (approved) submission for this
  /// bonus mission, meaning it can no longer be done again.
  bool _isAccepted(PhotoSubmissionModel? submission) {
    final status = submission?.status;
    return status == 'approved' || status == 'reviewed';
  }

  Future<void> _openCamera() async {
    final visualGuideUrl = widget.mission.page2VisualGuideUrl;
    final XFile? xfile = await Navigator.of(context).push<XFile?>(
      MaterialPageRoute(
        builder: (_) => CustomCameraView(
          moduleId: _moduleId,
          visualGuideUrl: visualGuideUrl.isNotEmpty ? visualGuideUrl : null,
        ),
      ),
    );
    if (xfile != null && mounted) {
      setState(() => _capturedPhoto = xfile);
    }
  }

  Future<void> _submitPhoto() async {
    if (_capturedPhoto == null || _isUploading) return;

    // Guard: do not allow submitting if the mission was already accepted.
    final existing = ref.read(submissionStatusProvider(_moduleId)).valueOrNull;
    if (_isAccepted(existing)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Misi ini sudah diterima dan tidak bisa dikirim lagi.'),
            backgroundColor: AppColors.brandDanger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isUploading = true);

    try {
      final challengeService = ref.read(challengeServiceProvider);
      final submissionService = ref.read(photoSubmissionServiceProvider);
      final user = ref.read(authViewModelProvider).currentUser;

      if (user == null) throw Exception('User not found');

      // 1. Upload photo to Firebase Storage
      final photoUrl = await challengeService.uploadPhoto(_capturedPhoto!);

      // 2. Create submission in Firestore (moduleId = bonus mission id)
      final moduleTitle = widget.mission.title;
      await submissionService.submitPhoto(
        userId: user.id,
        userName: user.name,
        moduleId: _moduleId,
        moduleTitle: moduleTitle,
        photoUrl: photoUrl,
      );

      if (!mounted) return;

      // 3. Show success modal — no completedLevels tracking for bonus missions
      await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        builder: (dialogCtx) => _SubmissionSuccessModal(
          missionTitle: widget.mission.title,
          onDismiss: () {
            Navigator.pop(dialogCtx);
            Navigator.pop(context); // Pop bonus mission detail view
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
    final visualGuideUrl = widget.mission.page2VisualGuideUrl;
    final hasGuide = visualGuideUrl.isNotEmpty;

    final submissionAsync = ref.watch(submissionStatusProvider(_moduleId));
    final submission = submissionAsync.valueOrNull;
    final isAccepted = _isAccepted(submission);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // InfoCard: Kapan Digunakan
          _InfoCard(
            title: 'Kapan Digunakan',
            body: widget.mission.page2WhenToUse,
            icon: Icons.calendar_today_rounded,
            tint: const Color(0xFFF3E8FF),
          ),
          const SizedBox(height: 16),

          // InfoCard: Cara Menggunakan
          _InfoCard(
            title: 'Cara Menggunakan',
            body: widget.mission.page2HowToUse,
            icon: Icons.tips_and_updates_rounded,
            tint: const Color(0xFFFEF9C3),
          ),
          const SizedBox(height: 24),

          // Once a submission has been accepted by the jury/admin, the mission
          // is locked and can no longer be done again.
          if (isAccepted)
            _MissionCompletedCard(xpReward: widget.mission.xpReward)
          else ...[
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
                          color: hasGuide ? Colors.white : null,
                          gradient: !hasGuide
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
                            if (hasGuide && visualGuideUrl.startsWith('http'))
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
                                  color: Colors.black.withValues(alpha: 0.75),
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
        ],
      ),
    );
  }
}

/// Shown in place of the camera/submit section when the user's submission for
/// this bonus mission has already been accepted by the jury/admin. The mission
/// is locked and cannot be done again.
class _MissionCompletedCard extends StatelessWidget {
  final int xpReward;

  const _MissionCompletedCard({required this.xpReward});

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.brandSuccess,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 2.0),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.verified_rounded, color: Colors.black, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'MISI SELESAI',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Foto kamu sudah diterima oleh juri. Misi ini tidak bisa dilakukan lagi.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
          if (xpReward > 0) ...[
            const SizedBox(height: 14),
            BrutalXPPill(amount: xpReward),
          ],
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
      ..color = Colors.white.withValues(alpha: 0.8)
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

    canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), linePaint);
    canvas.drawLine(Offset(w * 2 / 3, 0), Offset(w * 2 / 3, h), linePaint);
    canvas.drawLine(Offset(0, h * 0.33), Offset(w, h * 0.33), linePaint);
    canvas.drawLine(Offset(0, h * 0.67), Offset(w, h * 0.67), linePaint);

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

// ── Submission Success Modal ────────────────────────────────────────────────

class _SubmissionSuccessModal extends StatelessWidget {
  final String missionTitle;
  final VoidCallback onDismiss;

  const _SubmissionSuccessModal({
    required this.missionTitle,
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
                        text: missionTitle,
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
                    color: AppColors.brandAccent.withValues(alpha: 0.15),
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
