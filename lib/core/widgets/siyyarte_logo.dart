import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// The "SIYYARTE" wordmark glyphs: "SIYYART" inherits the caller's text color,
/// the final "E" is painted in the brand orange accent. Rendered as live text
/// (never a rasterized image) so the mark stays crisp at every size and DPI.
const InlineSpan _wordmarkSpan = TextSpan(
  children: [
    TextSpan(text: 'SIYYART'),
    TextSpan(text: 'E', style: TextStyle(color: AppColors.accentOrange)),
  ],
);

/// The Siyyarte emblem — the vehicle artwork (سيّارتي = "my car").
class SiyyarteMark extends StatelessWidget {
  const SiyyarteMark({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/siyyarte_mark.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// Just the "SIYYARTE" wordmark (the E in tail-light red) — clean at small
/// sizes like the app bar, where the detailed badge would get muddy.
class SiyyarteWordmark extends StatelessWidget {
  const SiyyarteWordmark({super.key, this.fontSize = 20, this.onDark});
  final double fontSize;
  final bool? onDark;

  @override
  Widget build(BuildContext context) {
    final dark =
        onDark ?? Theme.of(context).brightness == Brightness.dark;
    final color = dark ? AppColors.textPrimaryDark : AppColors.charcoal;
    return Text.rich(
      _wordmarkSpan,
      style: GoogleFonts.sora(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: color,
      ),
    );
  }
}

/// Full logo lockup: emblem + "SIYYARTE" wordmark (the E in tail-light red).
class SiyyarteLogo extends StatelessWidget {
  const SiyyarteLogo({
    super.key,
    this.markSize = 44,
    this.fontSize = 24,
    this.onDark = false,
    this.showTagline = false,
    this.tagline,
  });

  final double markSize;
  final double fontSize;
  final bool onDark;
  final bool showTagline;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final textColor = onDark ? AppColors.textPrimaryDark : AppColors.charcoal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SiyyarteMark(size: markSize),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              _wordmarkSpan,
              style: GoogleFonts.sora(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: textColor,
              ),
            ),
            if (showTagline)
              Text(
                tagline ?? 'MY CAR · MAINTAINED',
                style: GoogleFonts.sora(
                  fontSize: fontSize * 0.42,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                  color: onDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
