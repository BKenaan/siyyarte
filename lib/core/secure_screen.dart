import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Blocks screenshots/screen recording on Android via FLAG_SECURE.
/// Free users can view their service history but not capture it; Siyyarte
/// Plus lifts the restriction. No-op on web/iOS (iOS cannot block capture).
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
