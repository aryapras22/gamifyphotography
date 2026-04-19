import 'package:flutter/material.dart';

class Animated3DButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final Color shadowColor;
  final double height;
  final double borderRadius;

  const Animated3DButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.color = const Color(0xFF58CC02), // Default Feather Green
    this.shadowColor = const Color(0xFF58A700),
    this.height = 60,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  State<Animated3DButton> createState() => _Animated3DButtonState();
}

class _Animated3DButtonState extends State<Animated3DButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        height: widget.height + 8, // 8 is the shadow depth
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Shadow Layer
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.shadowColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            // Top Layer (moves down)
            Positioned(
              bottom: 8 - _animation.value,
              left: 0,
              right: 0,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                alignment: Alignment.center,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
