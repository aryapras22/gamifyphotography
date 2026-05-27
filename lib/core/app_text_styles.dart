import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.bricolageGrotesque(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        color: AppColors.bodyText,
      );

  static TextStyle get heading => GoogleFonts.bricolageGrotesque(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.bodyText,
      );

  static TextStyle get title => GoogleFonts.bricolageGrotesque(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.bodyText,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.bodyText,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
      );

  static TextStyle get button => GoogleFonts.bricolageGrotesque(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        color: AppColors.surfaceWhite,
      );
}
