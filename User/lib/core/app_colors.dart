import 'package:flutter/material.dart';

/// App color scheme untuk tema pertanian
/// Menggunakan warna hijau natural yang sesuai dengan tema agro
class AppColors {
  AppColors._();

  // Primary colors - Green theme
  static const Color primary = Color(0xFF2E7D32); // Green 800
  static const Color primaryLight = Color(0xFF4CAF50); // Green 500
  static const Color primaryDark = Color(0xFF1B5E20); // Green 900

  // Secondary colors
  static const Color secondary = Color(0xFF8D6E63); // Brown 400
  static const Color secondaryLight = Color(0xFFA1887F); // Brown 300
  static const Color secondaryDark = Color(0xFF5D4037); // Brown 700

  // Accent colors
  static const Color accent = Color(0xFFFFC107); // Amber
  static const Color accentLight = Color(0xFFFFD54F); // Amber 300

  // Neutral colors
  static const Color background = Color(0xFFF5F5F5); // Grey 100
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color card = Color(0xFFFFFFFF); // White
  static const Color divider = Color(0xFFE0E0E0); // Grey 300

  // Text colors
  static const Color textPrimary = Color(0xFF212121); // Grey 900
  static const Color textSecondary = Color(0xFF757575); // Grey 600
  static const Color textHint = Color(0xFFBDBDBD); // Grey 400
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White

  // Status colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue

  // Category colors
  static const Color fertilizer = Color(0xFF8D6E63); // Brown
  static const Color seeds = Color(0xFF4CAF50); // Green
  static const Color tools = Color(0xFF607D8B); // Blue Grey
  static const Color pesticides = Color(0xFFFF9800); // Orange
}