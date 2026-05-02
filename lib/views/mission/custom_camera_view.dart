import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomCameraView extends StatefulWidget {
  final String moduleId; 

  const CustomCameraView({super.key, required this.moduleId});

  @override
  State<CustomCameraView> createState() => _CustomCameraViewState();
}

class _CustomCameraViewState extends State<CustomCameraView> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
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
      default: return 'assets/images/visual_guides/01_rule_of_thirds.svg';
    }
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          
          // Custom Grid Overlay (SVG)
          Positioned.fill(
            child: IgnorePointer(
              child: SvgPicture.asset(
                _getVisualGuideAsset(widget.moduleId),
                fit: BoxFit.fill,
              ),
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (!_controller!.value.isTakingPicture) {
                    try {
                      final XFile file = await _controller!.takePicture();
                      // Return file path
                      if (context.mounted) {
                        Navigator.of(context).pop(file);
                      }
                    } catch (e) {
                      debugPrint('Error taking picture: $e');
                    }
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
