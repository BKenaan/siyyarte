import 'package:flutter/material.dart';

/// Garagi brand palette — premium automotive: charcoal instrument-cluster
/// neutrals with a single confident "tail-light red" accent.
abstract class AppColors {
  // Brand accent
  static const Color tailLightRed = Color(0xFFD32F2F);
  static const Color tailLightRedDark = Color(0xFFB71C1C);

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

  // Brand gradients (match the logo emblem).
  static const Gradient charcoalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF262A2E), Color(0xFF0B0C0E)],
  );

  static const Gradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4B3E), Color(0xFFC01209)],
  );
}
