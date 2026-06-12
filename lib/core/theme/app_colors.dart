import 'package:flutter/material.dart';

/// Siyyarte brand palette — deep navy from the emblem tile with a single
/// confident orange accent (the reminder bubble in the logo).
abstract class AppColors {
  // Brand
  static const Color brandNavy = Color(0xFF011E4B); // emblem tile
  static const Color primaryNavy = Color(0xFF0D3573); // buttons / chrome
  static const Color navyLight = Color(0xFF1A4E9E);
  static const Color accentOrange = Color(0xFFF47C20);
  static const Color accentOrangeDark = Color(0xFFD96510);

  // Neutrals (charcoal / brushed metal)
  static const Color charcoal = Color(0xFF1C1F22);
  static const Color charcoalSurface = Color(0xFF26292D);
  static const Color steel = Color(0xFF3A3F44);
  static const Color mist = Color(0xFFF4F5F7);
  static const Color cloud = Color(0xFFFFFFFF);

  // Health status (color + always paired with an icon/label in the UI)
  static const Color healthGood = Color(0xFF2E7D32); // green
  static const Color healthUpcoming = Color(0xFFF9A825); // amber
  static const Color healthOverdue = Color(0xFFD32F2F); // red

  // Text
  static const Color textPrimaryLight = Color(0xFF1C1F22);
  static const Color textSecondaryLight = Color(0xFF5F6368);
  static const Color textPrimaryDark = Color(0xFFF4F5F7);
  static const Color textSecondaryDark = Color(0xFFB0B5BB);

  // Brand gradient (matches the logo emblem tile).
  static const Gradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D3573), Color(0xFF011E4B)],
  );
}
