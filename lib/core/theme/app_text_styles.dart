import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display - Baloo 2
  static TextStyle displayLarge = GoogleFonts.baloo2(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.baloo2(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.baloo2(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.3,
  );

  // Headline - Baloo 2
  static TextStyle headlineLarge = GoogleFonts.baloo2(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMedium = GoogleFonts.baloo2(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSmall = GoogleFonts.baloo2(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Title - DM Sans
  static TextStyle titleLarge = GoogleFonts.dmSans(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle titleMedium = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
    letterSpacing: 0.15,
  );

  static TextStyle titleSmall = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
    letterSpacing: 0.1,
  );

  // Body - DM Sans
  static TextStyle bodyLarge = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    letterSpacing: 0.5,
  );

  static TextStyle bodyMedium = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    letterSpacing: 0.25,
  );

  static TextStyle bodySmall = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.4,
  );

  // Label - DM Sans
  static TextStyle labelLarge = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.5,
  );

  // Bilingual Helper
  static TextStyle hindiStyle(TextStyle base) {
    return base.copyWith(
      fontSize: (base.fontSize ?? 14) * 1.1,
      height: (base.height ?? 1.2) + 0.2,
    );
  }
}
