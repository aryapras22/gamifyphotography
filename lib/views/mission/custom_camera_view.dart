import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';

class CustomCameraView extends StatefulWidget {
  final String gridType; // e.g., 'rule_of_thirds', 'golden_ratio'

  const CustomCameraView({Key? key, this.gridType = 'rule_of_thirds'}) : super(key: key);

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
          
          // Custom Grid Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(gridType: widget.gridType),
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
                    color: Colors.white.withOpacity(0.5),
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

class GridPainter extends CustomPainter {
  final String gridType;

  GridPainter({required this.gridType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.5;

    if (gridType == 'rule_of_thirds' || true) { // Default fallback
      final thirdW = size.width / 3;
      final thirdH = size.height / 3;
      
      // Vertical lines
      canvas.drawLine(Offset(thirdW, 0), Offset(thirdW, size.height), paint);
      canvas.drawLine(Offset(thirdW * 2, 0), Offset(thirdW * 2, size.height), paint);
      // Horizontal lines
      canvas.drawLine(Offset(0, thirdH), Offset(size.width, thirdH), paint);
      canvas.drawLine(Offset(0, thirdH * 2), Offset(size.width, thirdH * 2), paint);

      // Red cross + circle at intersections
      final redPaint = Paint()
        ..color = const Color(0xFFE63946)
        ..strokeWidth = 1.5;
      final circlePaint = Paint()
        ..color = const Color(0xFFE63946)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (int row = 1; row < 3; row++) {
        for (int col = 1; col < 3; col++) {
          final cx = thirdW * col;
          final cy = thirdH * row;
          canvas.drawCircle(Offset(cx, cy), 10, circlePaint);
          canvas.drawLine(Offset(cx - 6, cy), Offset(cx + 6, cy), redPaint);
          canvas.drawLine(Offset(cx, cy - 6), Offset(cx, cy + 6), redPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
