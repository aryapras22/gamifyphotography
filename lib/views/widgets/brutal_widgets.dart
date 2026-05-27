import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

/// A card decorated with a solid black border and flat shadow.
class BrutalCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color shadowColor;
  final Offset shadowOffset;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const BrutalCard({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    this.borderRadius = 16.0,
    this.shadowColor = Colors.black,
    this.shadowOffset = const Offset(4, 4),
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: shadowColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Transform.translate(
        offset: -shadowOffset,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}

enum BrutalButtonVariant { primary, secondary, accent }

/// An interactive Neo-brutalist button that compresses/translates when clicked.
class BrutalButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final BrutalButtonVariant variant;
  final bool fullWidth;
  final double height;
  final double borderRadius;

  const BrutalButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = BrutalButtonVariant.primary,
    this.fullWidth = false,
    this.height = 48.0,
    this.borderRadius = 12.0,
  });

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton> {
  bool _isPressed = false;

  Color get _bg {
    if (widget.onPressed == null) return AppColors.disabled;
    switch (widget.variant) {
      case BrutalButtonVariant.primary:
        return AppColors.brandInk;
      case BrutalButtonVariant.secondary:
        return Colors.white;
      case BrutalButtonVariant.accent:
        return AppColors.brandAccent;
    }
  }

  Color get _textCol {
    if (widget.onPressed == null) return Colors.grey.shade500;
    switch (widget.variant) {
      case BrutalButtonVariant.primary:
        return Colors.white;
      case BrutalButtonVariant.secondary:
      case BrutalButtonVariant.accent:
        return AppColors.brandInk;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            },
      onTapCancel: widget.onPressed == null
          ? null
          : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.fullWidth ? double.infinity : null,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: AnimatedSlide(
          offset: _isPressed ? const Offset(0.02, 0.02) : const Offset(0, 0),
          duration: const Duration(milliseconds: 60),
          child: Container(
            height: widget.height - 4,
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: Colors.black, width: 2.0),
            ),
            alignment: Alignment.center,
            child: DefaultTextStyle(
              style: GoogleFonts.bricolageGrotesque(
                color: _textCol,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

enum BrutalChipTone { defaultTone, primary, accent, success, danger, muted, warm }

/// Neo-brutalist styled pill tags.
class BrutalChip extends StatelessWidget {
  final Widget child;
  final BrutalChipTone tone;

  const BrutalChip({
    super.key,
    required this.child,
    this.tone = BrutalChipTone.defaultTone,
  });

  Color get _bg {
    switch (tone) {
      case BrutalChipTone.defaultTone:
        return Colors.white;
      case BrutalChipTone.primary:
        return AppColors.brandPrimary;
      case BrutalChipTone.accent:
        return AppColors.brandAccent;
      case BrutalChipTone.success:
        return const Color(0xFFD1FAE5); // bg-emerald-100
      case BrutalChipTone.danger:
        return const Color(0xFFFEE2E2); // bg-red-100
      case BrutalChipTone.muted:
        return const Color(0xFFF1F5F9); // bg-slate-100
      case BrutalChipTone.warm:
        return const Color(0xFFFFEDD5); // bg-orange-100
    }
  }

  Color get _textColor {
    switch (tone) {
      case BrutalChipTone.primary:
        return Colors.white;
      case BrutalChipTone.success:
        return const Color(0xFF065F46); // text-emerald-800
      case BrutalChipTone.danger:
        return const Color(0xFF991B1B); // text-red-800
      case BrutalChipTone.muted:
        return const Color(0xFF475569); // text-slate-600
      case BrutalChipTone.warm:
        return const Color(0xFFC2410C); // text-orange-700
      default:
        return AppColors.brandInk;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      child: DefaultTextStyle(
        style: GoogleFonts.inter(
          color: _textColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
        child: child,
      ),
    );
  }
}

/// XP Reward Pill containing star emoji.
class BrutalXPPill extends StatelessWidget {
  final int amount;

  const BrutalXPPill({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            '$amount XP',
            style: GoogleFonts.bricolageGrotesque(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Re-themed progress bar with black border outline.
class BrutalProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color color;
  final Color backgroundColor;

  const BrutalProgressBar({
    super.key,
    required this.value,
    this.height = 12.0,
    this.color = AppColors.brandPrimary,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0.0, 1.0);
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

/// Responsive and themed custom App Bar.
class BrutalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? backLocation; // for GoRouter navigation
  final VoidCallback? onBackPressed;
  final Widget? rightAction;

  const BrutalAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.backLocation,
    this.onBackPressed,
    this.rightAction,
  });

  @override
  Widget build(BuildContext context) {
    final canBack = backLocation != null || onBackPressed != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.brandBg,
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
      child: Row(
        children: [
          if (canBack) ...[
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2.0),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                  ],
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.black),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondaryText,
                      letterSpacing: 1.0,
                    ),
                  ),
                Text(
                  title,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandInk,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (rightAction != null) ...[
            const SizedBox(width: 12),
            rightAction!,
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

/// Circular avatar with custom styling.
class BrutalAvatar extends StatelessWidget {
  final String initial;
  final double size;

  const BrutalAvatar({
    super.key,
    required this.initial,
    this.size = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.brandAccent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2.0),
      ),
      alignment: Alignment.center,
      child: Text(
        initial.toUpperCase(),
        style: GoogleFonts.bricolageGrotesque(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
