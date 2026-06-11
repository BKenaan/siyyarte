import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Flip to `false` to return to in-memory mock mode (offline demo). When `true`
/// the app uses the live Firebase backend configured by `flutterfire configure`.
const bool kUseFirebase = true;

/// Cloud Storage for Firebase requires the Blaze plan on new projects, so it's
/// off while we run on the free Spark plan. Invoice photos save to a local path
/// instead (no error). Flip to `true` after enabling Billing + Storage.
const bool kUseFirebaseStorage = false;

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
