import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/bootstrap.dart';

/// Result of capturing the vehicle registration card (دفتر السيارة).
class RegCardCapture {
  const RegCardCapture({
    required this.url,
    required this.scanned,
    this.looksLikeCard = true,
    this.holderName,
    this.vin,
    this.plateNumber,
  });

  /// Where the card photo lives (Storage URL, or local path on Spark/mock).
  final String url;

  /// True when the AI actually read the card (functions deployed + parsed).
  final bool scanned;

  /// AI's judgement that the photo really is a registration document.
  final bool looksLikeCard;

  final String? holderName;
  final String? vin;
  final String? plateNumber;
}

/// Captures the registration card that must accompany every new vehicle:
/// picks ONE photo, keeps it as evidence, and (when the backend is deployed)
/// has the AI read the holder name + VIN off it so the app can cross-check
/// the VIN against the vehicle being added. Degrades gracefully — if the AI
/// scan is unavailable the card is still stored and the vehicle is marked
/// "card on file" rather than "verified".
class RegistrationCardService {
  final _picker = ImagePicker();

  Future<RegCardCapture?> captureAndRead() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (file == null) return null; // user cancelled
    final bytes = await file.readAsBytes();

    // 1) Keep the photo — it's the ownership evidence the passport cites.
    String url;
    if (kUseFirebase && kUseFirebaseStorage) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('Not authenticated');
      final ref = FirebaseStorage.instance.ref(
          'users/$uid/registration/${DateTime.now().microsecondsSinceEpoch}.jpg');
      await ref.putData(
          bytes, SettableMetadata(contentType: 'image/jpeg'));
      url = await ref.getDownloadURL();
    } else {
      url = file.path; // local evidence until Storage is enabled
    }

    // 2) AI-read the card (holder name + VIN). Failure is non-fatal.
    if (kUseFirebase) {
      try {
        // file.name (not .path) — on web the path is a blob URL.
        final mime = file.mimeType ??
            (file.name.toLowerCase().endsWith('.png')
                ? 'image/png'
                : 'image/jpeg');
        final callable =
            FirebaseFunctions.instance.httpsCallable('extractFromImage');
        final res = await callable.call<Map<dynamic, dynamic>>({
          'imageBase64': base64Encode(bytes),
          'mimeType': mime,
          'mode': 'registration',
        });
        final data = Map<String, dynamic>.from(res.data);
        final rawVin = data['vin'];
        return RegCardCapture(
          url: url,
          scanned: true,
          looksLikeCard: data['isRegistrationCard'] != false,
          holderName: (data['holderName'] as String?)?.trim(),
          vin: rawVin is String
              ? rawVin.replaceAll(RegExp(r'\s'), '').toUpperCase()
              : null,
          plateNumber: (data['plateNumber'] as String?)?.trim(),
        );
      } catch (_) {
        // Functions not deployed / offline → card on file, unverified.
      }
    }
    return RegCardCapture(url: url, scanned: false);
  }
}

final registrationCardServiceProvider =
    Provider<RegistrationCardService>((ref) => RegistrationCardService());
