import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF005447); // Deep Earthy Teal
  static const Color primaryContainer = Color(0xFF0A6E5E); // Sun-drenched/Focus Teal
  
  // Surface Hierarchy (Tonal Layering)
  static const Color surface = Color(0xFFFEF9F3); // The Foundation (Base Layer)
  static const Color surfaceContainerLow = Color(0xFFF8F3ED); // Content Groupings (Section Layer)
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Cards/Interactive (Interactive Layer)
  static const Color surfaceContainerHighest = Color(0xFFE0DBD5); // Hover/Selection states (Subtle shift)
  static const Color surfaceDim = Color(0xFFDED9D2); // Outer shadow/dimming

  // Secondary / Accent Colors (Tailwind imports)
  static const Color secondary = Color(0xFF855300);
  static const Color secondaryContainer = Color(0xFFFEA619);
  static const Color onSecondaryContainer = Color(0xFF684000);
  static const Color secondaryFixed = Color(0xFFFFDDB8);
  
  // Content Colors
  static const Color onSurface = Color(0xFF1D1B18); // Primary Text (No 100% black)
  static const Color onSurfaceVariant = Color(0xFF4D463D); // Secondary Text/Labels
  static const Color onPrimaryContainer = Color(0xFF9AEDD9); // Text on primary container
  
  // Accents & Borders
  static const Color outlineVariant = Color(0xFFBEC9C4); // Ghost Border Base
  static const Color amberAccent = Color(0xFFFFB74D); // Sun-drenched Amber for health highlights
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    transform: GradientRotation(2.356), // ~135 degrees
  );

  // Shadows (Ambient Teal-tinted)
  static List<BoxShadow> ambientShadow = [
    BoxShadow(
      color: const Color(0xFF0A6E5E).withValues(alpha: 0.08),
      offset: const Offset(0, 8),
      blurRadius: 24,
    ),
  ];
  
  // Ghost Border Decoration (1.5px 20% opacity)
  static Border ghostBorder = Border.all(
    color: outlineVariant.withValues(alpha: 0.2),
    width: 1.5,
  );
}
