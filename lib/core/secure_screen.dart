import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Blocks screenshots/screen recording for free users; Siyyarte Plus lifts
/// the restriction. Android: FLAG_SECURE. iOS: the secure-text-field layer
/// technique (screenshots come out black, as in banking apps). No-op on web.
Future<void> setSecureScreen(bool secure) async {
  if (kIsWeb) return;
  try {
    await const MethodChannel('siyyarte/secure_screen')
        .invokeMethod('setSecure', secure);
  } catch (_) {
    // Platform without the channel (iOS, desktop, tests) — view-only policy
    // still holds via the export/share gates.
  }
}
