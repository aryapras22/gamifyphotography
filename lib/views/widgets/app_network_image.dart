import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';

/// An animated shimmer skeleton used as a placeholder while remote content
/// (e.g. images loaded from Firebase Storage) is still loading.
class AppSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 - 2.0 * _controller.value, 0),
                end: Alignment(1.0 - 2.0 * _controller.value, 0),
                colors: const [
                  Color(0xFFE2E8F0), // slate-200
                  Color(0xFFF1F5F9), // slate-100
                  Color(0xFFE2E8F0), // slate-200
                ],
                stops: const [0.1, 0.5, 0.9],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A network image (raster: PNG/JPG/etc.) loaded from Firebase Storage with a
/// built-in shimmer skeleton placeholder and a graceful error fallback.
///
/// Use this everywhere a remote raster image is shown so loading behaviour is
/// consistent across the app.
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) => AppSkeleton(
        width: width,
        height: height,
        borderRadius: borderRadius,
      ),
      errorWidget: (context, _, __) => _ErrorBox(
        width: width,
        height: height,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// A network SVG loaded from Firebase Storage with a shimmer skeleton while it
/// downloads/parses.
class AppNetworkSvg extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ColorFilter? colorFilter;
  final BorderRadius borderRadius;

  const AppNetworkSvg({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.colorFilter,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: fit,
      colorFilter: colorFilter,
      placeholderBuilder: (_) => AppSkeleton(
        width: width,
        height: height,
        borderRadius: borderRadius,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const _ErrorBox({this.width, this.height, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // slate-100
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_rounded,
        color: AppColors.secondaryText,
        size: 28,
      ),
    );
  }
}
