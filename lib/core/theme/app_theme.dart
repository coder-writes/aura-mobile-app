import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        outlineVariant: AppColors.outlineVariant,
      ),
      
      // Typography
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Integrated Component Designs
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          // Avoid forcing infinite width globally; row/inline buttons need bounded constraints.
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // xl = 1.5rem
          ),
          textStyle: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
        labelStyle: AppTextStyles.labelLarge,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      
      dividerTheme: const DividerThemeData(
        thickness: 0,
        color: Colors.transparent, // Disable standard dividers
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme.copyWith(brightness: Brightness.dark);
}
