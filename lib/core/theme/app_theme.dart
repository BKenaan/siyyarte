import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Siyyarte theme — modern, high-contrast: clean white surfaces, deep navy
/// primary (the emblem tile) and a single orange accent. Every button style
/// sets explicit foreground/background so labels are always readable.
abstract class AppTheme {
  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryNavy,
      brightness: brightness,
      primary: isDark ? AppColors.navyLight : AppColors.primaryNavy,
      onPrimary: Colors.white,
      secondary: AppColors.accentOrange,
      onSecondary: Colors.white,
      surface: isDark ? const Color(0xFF15171B) : Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Clean near-white canvas (not grey) / rich near-black for dark mode.
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0E1014) : const Color(0xFFF8FAFD),
      brightness: brightness,
    );

    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    // Inter body, Sora display headings.
    var text = GoogleFonts.interTextTheme(base.textTheme);
    text = text.copyWith(
      displayLarge: GoogleFonts.sora(textStyle: text.displayLarge),
      displayMedium: GoogleFonts.sora(textStyle: text.displayMedium),
      displaySmall: GoogleFonts.sora(textStyle: text.displaySmall),
      headlineLarge: GoogleFonts.sora(
          textStyle: text.headlineLarge, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.sora(
          textStyle: text.headlineMedium, fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.sora(
          textStyle: text.headlineSmall, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.sora(
          textStyle: text.titleLarge, fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      textTheme: text.apply(bodyColor: textColor, displayColor: textColor),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? const Color(0xFF0E1014) : const Color(0xFFF8FAFD),
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF1A1D23) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFE6EAF2),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      // Primary action — solid navy, white label. Always readable.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor:
              isDark ? AppColors.navyLight : AppColors.primaryNavy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFD4DAE6),
          disabledForegroundColor:
              isDark ? Colors.white38 : const Color(0xFF8A93A6),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.sora(
              fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? AppColors.navyLight : AppColors.primaryNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.sora(
              fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.textPrimaryDark : AppColors.primaryNavy,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.22)
                : const Color(0xFFC6CEDD),
            width: 1.2,
          ),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.navyLight : AppColors.primaryNavy,
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12))),
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? (isDark ? AppColors.navyLight : AppColors.primaryNavy)
                  : Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? Colors.white
                  : (isDark ? AppColors.textPrimaryDark : textColor)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0xFFDDE3EE),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.primaryNavy, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF15171B) : Colors.white,
        elevation: 0,
        height: 68,
        indicatorColor: (isDark ? AppColors.navyLight : AppColors.primaryNavy)
            .withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? (isDark ? AppColors.navyLight : AppColors.primaryNavy)
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight))),
      ),
      dividerTheme: DividerThemeData(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06),
        thickness: 1,
      ),
    );
  }

  /// Wraps a theme's text so Arabic locales render with the Cairo font.
  static ThemeData withArabicFont(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(theme.textTheme),
    );
  }
}
