import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_identity.dart';

/// A legally-safe, generic vehicle brand badge.
///
/// Draws a clean rounded badge showing the make's monogram (see
/// [BrandIdentity.abbreviation]) in the app's Sora display font, over a subtle
/// gradient built from the make's deterministic accent colour
/// ([BrandIdentity.color]). It never renders a trademarked manufacturer logo.
///
/// Pure Flutter — no image assets. Symmetric, so it is RTL-safe, and it tunes
/// itself for light and dark mode.
class BrandBadge extends StatelessWidget {
  const BrandBadge({
    super.key,
    required this.make,
    this.size = 44,
  });

  /// The vehicle make, e.g. "Toyota", "Land Rover".
  final String make;

  /// Side length of the (square) badge in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = BrandIdentity.color(make, isDark: isDark);
    final label = BrandIdentity.abbreviation(make);

    // Two-letter monograms need to breathe a little more than one.
    final fontSize = size * (label.length > 1 ? 0.40 : 0.48);
    final radius = size * 0.30;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(accent, Colors.white, isDark ? 0.10 : 0.16)!,
            accent,
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.35 : 0.28),
            blurRadius: size * 0.18,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.sora(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: label.length > 1 ? 0.5 : 0,
          height: 1,
        ),
      ),
    );
  }
}
