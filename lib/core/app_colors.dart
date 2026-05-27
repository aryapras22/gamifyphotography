import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary & Redesign Colors
  static const brandBlue = Color(0xFF6366F1); // Indigo (Redesign primary)
  static const brandPrimary = Color(0xFF6366F1);
  static const lensGold = Color(0xFFFACC15);   // Yellow/Amber (Redesign accent)
  static const brandAccent = Color(0xFFFACC15);
  static const forestGreen = Color(0xFF10B981); // Emerald (Redesign success)
  static const brandSuccess = Color(0xFF10B981);
  static const coralRed = Color(0xFFEF4444);    // Red (Redesign danger)
  static const brandDanger = Color(0xFFEF4444);
  static const brandWarm = Color(0xFFFB923C);    // Orange
  static const brandInk = Color(0xFF0A0A0A);     // Off-black

  // Semantic aliases
  static const Color success = brandSuccess;
  static const Color error = brandDanger;

  // Neutral
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const backgroundGray = Color(0xFFF8FAFC); // Slate-50 (Redesign bg)
  static const brandBg = Color(0xFFF8FAFC);
  static const cardBorder = Color(0xFF000000);    // Hard black borders
  static const bodyText = Color(0xFF0A0A0A);
  static const secondaryText = Color(0xFF64748B); // slate-500
  static const disabled = Color(0xFFCBD5E1);      // slate-300

  // Gamification
  static const xpBarFill = brandPrimary;
  static const streakFire = brandWarm;
  static const badgeLocked = Color(0xFF94A3B8);   // slate-400
  static const goldMedal = brandAccent;
  static const silverMedal = Color(0xFFE2E8F0);   // slate-200
  static const bronzeMedal = Color(0xFFEDF2F7);

  // Gamification extended
  static const Color xpAmber = brandAccent;
  static const Color streakBg = Color(0xFFFFEDD5); // orange-100
  static const Color streakBorder = Color(0xFF000000);
}
