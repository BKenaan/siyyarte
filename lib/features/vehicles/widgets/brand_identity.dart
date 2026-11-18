import 'package:flutter/material.dart';

/// Legally-safe brand identity helpers.
///
/// IMPORTANT: Siyyarte deliberately ships NO trademarked manufacturer logos
/// (no Mercedes star, Toyota ellipse, BMW roundel, etc.). Instead, every make
/// is represented by a generic monogram badge: a 1–2 letter abbreviation drawn
/// in the app's own typography, tinted with a stable accent colour derived
/// deterministically from the make name. This gives each car a distinct,
/// recognisable visual anchor without using anyone's protected marks.
abstract class BrandIdentity {
  /// A short, stable monogram for a make name.
  ///
  /// * Multi-word makes → initials of the first two words
  ///   ("Land Rover" → "LR", "Mercedes-Benz" → "MB", "Alfa Romeo" → "AR").
  /// * Single-word makes → the first letter ("Toyota" → "T", "Honda" → "H").
  /// Always upper-cased; falls back to "?" for an empty/blank make.
  static String abbreviation(String make) {
    final tokens = make
        .trim()
        .split(RegExp(r'[\s\-/]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return '?';
    if (tokens.length == 1) {
      return tokens.first.characters.first.toUpperCase();
    }
    final a = tokens[0].characters.first;
    final b = tokens[1].characters.first;
    return '$a$b'.toUpperCase();
  }

  /// A deterministic, stable accent colour for a make.
  ///
  /// The lower-cased make name is hashed to a hue (0–360); saturation and
  /// lightness are fixed so the result always reads as a rich, premium tone
  /// that carries white text well in both light and dark mode. The same make
  /// always yields the same colour across sessions and devices.
  static Color color(String make, {bool isDark = false}) {
    final key = make.trim().toLowerCase();
    if (key.isEmpty) return const Color(0xFF0D3573); // brand navy fallback

    // FNV-1a style hash → stable across runs (unlike String.hashCode, which
    // is randomised per isolate on some platforms).
    var hash = 0x811c9dc5;
    for (final code in key.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    final hue = (hash % 360).toDouble();

    // Slightly brighter/less saturated in dark mode so the badge doesn't go
    // muddy on the near-black canvas; richer on light surfaces.
    final hsl = HSLColor.fromAHSL(
      1,
      hue,
      isDark ? 0.52 : 0.58,
      isDark ? 0.52 : 0.44,
    );
    return hsl.toColor();
  }
}
