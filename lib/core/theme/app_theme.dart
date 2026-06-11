import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Premium automotive theme. Body text uses Inter (Cairo for Arabic); display
/// headings use Sora to match the wordmark. A single confident tail-light-red
/// accent over charcoal/mist neutrals.
abstract class AppTheme {
  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.tailLightRed,
      brightness: brightness,
      primary: AppColors.tailLightRed,
      surface: isDark ? AppColors.charcoalSurface : AppColors.cloud,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.charcoal : AppColors.mist,
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
      textTheme: text.apply(
          bodyColor: textColor, displayColor: textColor),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.charcoal : AppColors.mist,
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
        color: isDark ? AppColors.charcoalSurface : AppColors.cloud,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.sora(
              fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: 0.12),
          ),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12))),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.cloud,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.tailLightRed, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.charcoalSurface : AppColors.cloud,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.tailLightRed.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
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
