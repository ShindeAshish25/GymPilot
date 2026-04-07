import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (From GymFlow Pro HTML Template)
  static const Color primary = Color(0xFFF5385B); 
  static const Color secondary = Color(0xFFE2F1F3);
  static const Color muted = Color(0xFF959AA4);
  
  // Background & Surface
  static const Color backgroundLight = Color(0xFFF8F5F6);
  static const Color backgroundDark = Color(0xFF221013);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF5F7E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Functional Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color accentYellow = Color(0xFFD5FF5F);

  // Surface colors
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF111827); // slate-900
  static const Color surfaceLight = Color(0xFFF3F4F6);
  
  // Text colors
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF475569); // slate-600
  static const Color textMuted = Color(0xFF94A3B8); // slate-400

  // For compatibility with old code
  static const Color background = backgroundLight;
  static const Color darkSurface = Color(0xFF181829); 
  static const Color cardShadow = Color(0x0F000000);
}
