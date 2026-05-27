import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../widgets/brutal_widgets.dart';

class CustomCameraView extends StatefulWidget {
  final String moduleId;
  final String? visualGuideUrl;
  /// When true, the camera is in practice mode — photos are saved to gallery
  /// and not returned for mission submission.
  final bool isPracticeMode;

  const CustomCameraView({
    super.key,
    required this.moduleId,
    this.visualGuideUrl,
    this.isPracticeMode = false,
  });

  @override
  State<CustomCameraView> createState() => _CustomCameraViewState();
}

class _CustomCameraViewState extends State<CustomCameraView> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isInitialized = false;
  int _selectedCameraIdx = 0;

  // Temp captured state for redesign UX confirmation overlay
  XFile? _tempCapturedFile;

  // Practice mode: index for switching between SVG templates
  int _currentGuideIndex = 0;

  static const _practiceGuides = [
    ('Rule of Thirds', 'assets/images/visual_guides/01_rule_of_thirds.svg'),
    ('Leading Lines', 'assets/images/visual_guides/02_leading_lines.svg'),
    ('Framing', 'assets/images/visual_guides/03_framing.svg'),
    ('Symmetry', 'assets/images/visual_guides/04_symmetry.svg'),
    ('Golden Triangle', 'assets/images/visual_guides/05_golden_triangle.svg'),
    ('Negative Space', 'assets/images/visual_guides/06_negative_space.svg'),
    ('Rule of Odds', 'assets/images/visual_guides/07_rule_of_odds.svg'),
    ('Depth of Field', 'assets/images/visual_guides/08_depth_of_field.svg'),
    ('Point of View', 'assets/images/visual_guides/09_point_of_view.svg'),
    ('Center Dominance', 'assets/images/visual_guides/10_center_dominance.svg'),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _initCamera();
  }

  String _getVisualGuideAsset(String moduleId) {
    switch (moduleId) {
      case 'M01': return 'assets/images/visual_guides/01_rule_of_thirds.svg';
      case 'M02': return 'assets/images/visual_guides/02_leading_lines.svg';
      case 'M03': return 'assets/images/visual_guides/03_framing.svg';
      case 'M04': return 'assets/images/visual_guides/04_symmetry.svg';
      case 'M05': return 'assets/images/visual_guides/05_golden_triangle.svg';
      case 'M06': return 'assets/images/visual_guides/06_negative_space.svg';
      case 'M07': return 'assets/images/visual_guides/07_rule_of_odds.svg';
      case 'M08': return 'assets/images/visual_guides/08_depth_of_field.svg';
      case 'M09': return 'assets/images/visual_guides/09_point_of_view.svg';
      case 'M10': return 'assets/images/visual_guides/10_center_dominance.svg';
      default:    return 'assets/images/visual_guides/01_rule_of_thirds.svg';
    }
  }

  Widget _buildVisualGuide() {
    // In practice mode, use the switchable template
    if (widget.isPracticeMode) {
      final (_, assetPath) = _practiceGuides[_currentGuideIndex];
      return SvgPicture.asset(assetPath, fit: BoxFit.fill);
    }

    final url = widget.visualGuideUrl;
    if (url != null && url.isNotEmpty && url.startsWith('http')) {
      return SvgPicture.network(
        url,
        fit: BoxFit.fill,
        placeholderBuilder: (_) => const SizedBox.shrink(),
      );
    }
    return SvgPicture.asset(
      _getVisualGuideAsset(widget.moduleId),
      fit: BoxFit.fill,
    );
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![_selectedCameraIdx],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() => _isInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _flipCamera() async {
    if (cameras == null || cameras!.length < 2) return;
    setState(() {
      _isInitialized = false;
      _selectedCameraIdx = (_selectedCameraIdx + 1) % cameras!.length;
    });
    _controller?.dispose();
    await _initCamera();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final String moduleLabel = widget.isPracticeMode
        ? _practiceGuides[_currentGuideIndex].$1
        : (widget.moduleId == 'M03' ? 'Rule of Thirds' : widget.moduleId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Viewfinder Area ───────────────────────────────────
          Positioned.fill(
            child: _tempCapturedFile == null
                ? CameraPreview(_controller!)
                : Image.file(
                    File(_tempCapturedFile!.path),
                    fit: BoxFit.cover,
                  ),
          ),

          // ── Visual Grid overlay (only active during capture) ──
          if (_tempCapturedFile == null)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.35,
                  child: _buildVisualGuide(),
                ),
              ),
            ),

          // ── Top HUD bar ───────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(null),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                ),

                // Active Mission label pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MISI',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        moduleLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Visual guide mode label / template switcher
                GestureDetector(
                  onTap: widget.isPracticeMode
                      ? () {
                          setState(() {
                            _currentGuideIndex = (_currentGuideIndex + 1) % _practiceGuides.length;
                          });
                        }
                      : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.brandAccent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2.0),
                    ),
                    alignment: Alignment.center,
                    child: widget.isPracticeMode
                        ? const Icon(Icons.swap_horiz_rounded, color: Colors.black, size: 20)
                        : Text(
                            '3×3',
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom HUD panel ──────────────────────────────────
          if (_tempCapturedFile == null)
            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dummy preview of last photos in gallery
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.tealAccent, Colors.blueAccent],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Shutter Button
                  GestureDetector(
                    onTap: () async {
                      if (_controller!.value.isTakingPicture) return;
                      try {
                        final file = await _controller!.takePicture();
                        setState(() => _tempCapturedFile = file);
                      } catch (e) {
                        debugPrint('Error taking picture: $e');
                      }
                    },
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4.0),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  // Camera flip button
                  GestureDetector(
                    onTap: _flipCamera,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            )
          else
            // Confirmation Card Overlay
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: BrutalCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'PREVIEW',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Foto Tersimpan!',
                      style: AppTextStyles.heading,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: BrutalButton(
                            onPressed: () => setState(() => _tempCapturedFile = null),
                            variant: BrutalButtonVariant.secondary,
                            height: 44,
                            child: const Text('AMBIL ULANG'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BrutalButton(
                            onPressed: () {
                              if (widget.isPracticeMode) {
                                // Practice mode: photo stays on device, show success
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Foto tersimpan di perangkat! 📸'),
                                    backgroundColor: AppColors.brandSuccess,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                setState(() => _tempCapturedFile = null);
                              } else {
                                // Mission mode: return XFile for submission
                                Navigator.of(context).pop(_tempCapturedFile);
                              }
                            },
                            variant: BrutalButtonVariant.accent,
                            height: 44,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_rounded, color: Colors.black, size: 16),
                                const SizedBox(width: 4),
                                Text(widget.isPracticeMode ? 'SIMPAN' : 'GUNAKAN'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
