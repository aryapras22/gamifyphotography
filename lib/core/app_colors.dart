import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const brandBlue = Color(0xFF1CB0F6);
  static const lensGold = Color(0xFFF4A622);
  static const forestGreen = Color(0xFF34A853);
  static const coralRed = Color(0xFFEA4335);

  // Semantic aliases (clarity over duplication)
  static const Color success = Color(
    0xFF34A853,
  ); // = forestGreen, button/state success
  static const Color error = Color(0xFFEA4335); // = coralRed, error text/states

  // Neutral
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const backgroundGray = Color(0xFFF8F9FA);
  static const cardBorder = Color(0xFFE8EAED);
  static const bodyText = Color(0xFF202124);
  static const secondaryText = Color(0xFF5F6368);
  static const disabled = Color(0xFFBDC1C6);

  // Gamification
  static const xpBarFill = Color(0xFF34A853);
  static const streakFire = Color(0xFFFF6D00);
  static const badgeLocked = Color(0xFF9AA0A6);
  static const goldMedal = Color(0xFFFFD700);
  static const silverMedal = Color(0xFFC0C0C0);
  static const bronzeMedal = Color(0xFFCD7F32);

  // Gamification extended
  static const Color xpAmber = Color(
    0xFFF59E0B,
  ); // XP progress bar (distinct from lensGold badge)
  static const Color streakBg = Color(
    0xFFFFF3DC,
  ); // streak background warm tint
  static const Color streakBorder = Color(0xFFFFCA28); // streak day border
}
