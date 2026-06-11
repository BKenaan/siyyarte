import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../core/bootstrap.dart';

/// Registers the device for FCM push and stores the token on the user document
/// so the Cloud Functions reminder sweep can target it. No-op unless Firebase
/// is enabled. Call once after sign-in with the user's uid.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  String? _registeredUid;

  Future<void> register(String uid) async {
    // Skip on web (needs a VAPID key) and when Firebase/messaging is off.
    // Re-register when a different user signs in (don't short-circuit forever).
    if (!kUseFirebase || kIsWeb || _registeredUid == uid) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await messaging.getToken();
      if (token != null) {
        await _saveToken(uid, token);
      }
      // Keep the stored token fresh on rotation.
      messaging.onTokenRefresh.listen((t) => _saveToken(uid, t));
      _registeredUid = uid;
    } catch (e) {
      debugPrint('FCM registration failed: $e');
    }
  }

  Future<void> _saveToken(String uid, String token) {
    return FirebaseFirestore.instance.collection('users').doc(uid).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
      },
      SetOptions(merge: true),
    );
  }
}
