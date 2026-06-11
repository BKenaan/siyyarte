import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Flip to `false` to return to in-memory mock mode (offline demo). When `true`
/// the app uses the live Firebase backend configured by `flutterfire configure`.
const bool kUseFirebase = true;

/// Cloud Storage is live (default bucket in us-east1, rules deployed
/// 2026-06-11). Registration-card and invoice photos upload under
/// users/{uid}/... and survive reinstalls and phone changes.
const bool kUseFirebaseStorage = true;

/// Initializes platform services. Safe to call when Firebase isn't configured;
/// it simply no-ops so `flutter run` works out of the box.
Future<void> bootstrap() async {
  if (!kUseFirebase) return;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init skipped/failed: $e');
  }
}
