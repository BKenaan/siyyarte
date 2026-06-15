import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/bootstrap.dart';
import '../vehicles/data/vehicle_catalog.dart';
import 'card_ocr/card_ocr.dart';
import 'card_ocr/card_parser.dart';

/// How the registration card image is obtained.
/// [scan] uses the native document scanner (edge-detect, de-skew, crop) — the
/// best input for OCR; [camera]/[gallery] are plain photo fallbacks.
enum CardCaptureMode { scan, camera, gallery }

/// Result of capturing the vehicle registration card (دفتر السيارة).
class RegCardCapture {
  const RegCardCapture({
    required this.url,
    required this.scanned,
    this.looksLikeCard = true,
    this.holderName,
    this.vin,
    this.plateNumber,
    this.make,
    this.model,
    this.year,
    this.fuelType,
    this.scanError,
  });

  /// Set when the photo saved but the AI read failed — carries a user-facing
  /// reason (bad key, quota, offline) so the UI can explain instead of going
  /// silent.
  final String? scanError;

  /// Where the card photo lives (Storage URL, or local path on Spark/mock).
  final String url;

  /// True when the AI actually read the card (functions deployed + parsed).
  final bool scanned;

  /// AI's judgement that the photo really is a registration document.
  final bool looksLikeCard;

  final String? holderName;
  final String? vin;
  final String? plateNumber;
  final String? make;
  final String? model;
  final int? year;
  final String? fuelType; // 'Petrol' | 'Diesel'

  /// Merge two sides of the same card — values from [this] win, [other]
  /// fills the gaps (Lebanese دفتر السيارة spreads fields across both faces).
  RegCardCapture mergeWith(RegCardCapture? other) {
    if (other == null) return this;
    return RegCardCapture(
      url: url,
      scanned: scanned || other.scanned,
      looksLikeCard: looksLikeCard || other.looksLikeCard,
      holderName: holderName ?? other.holderName,
      vin: vin ?? other.vin,
      plateNumber: plateNumber ?? other.plateNumber,
      make: make ?? other.make,
      model: model ?? other.model,
      year: year ?? other.year,
      fuelType: fuelType ?? other.fuelType,
    );
  }
}

/// Captures the registration card that must accompany every new vehicle:
/// picks ONE photo, keeps it as evidence, and (when the backend is deployed)
/// has the AI read the holder name + VIN off it so the app can cross-check
/// the VIN against the vehicle being added. Degrades gracefully — if the AI
/// scan is unavailable the card is still stored and the vehicle is marked
/// "card on file" rather than "verified".
class RegistrationCardService {
  final _picker = ImagePicker();

  Future<RegCardCapture?> captureAndRead(
      {CardCaptureMode mode = CardCaptureMode.scan}) async {
    // Obtain the image. The document scanner returns an already cropped,
    // de-skewed, glare-reduced page — far better OCR input than a raw photo.
    final Uint8List bytes;
    String mime = 'image/jpeg';
    String localPath;
    if (mode == CardCaptureMode.scan) {
      final paths = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: true,
      );
      if (paths == null || paths.isEmpty) return null; // cancelled
      localPath = paths.first;
      bytes = await XFile(localPath).readAsBytes();
    } else {
      // High quality + resolution: the carte grise has small chassis/VIN
      // digits that are unreadable when over-compressed. ~2400px @ 90% stays
      // well under the function's ~5MB image cap while preserving fine print.
      final file = await _picker.pickImage(
        source: mode == CardCaptureMode.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 2400,
      );
      if (file == null) return null; // user cancelled
      localPath = file.path;
      bytes = await file.readAsBytes();
      mime = file.mimeType ??
          (file.name.toLowerCase().endsWith('.png')
              ? 'image/png'
              : 'image/jpeg');
    }

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
      url = localPath; // local evidence until Storage is enabled
    }

    // 2a) FREE on-device pass first: ML Kit reads the card; the VIN (17-char,
    // unmistakable) is extracted locally at zero cost. From the VIN the free
    // NHTSA decoder fills make/model/year, so most cards never touch the AI.
    try {
      final lines = await recognizeCardText(localPath);
      final parsed = parseCardLines(
          lines, VehicleCatalog.makes.map((m) => m.name).toList());
      if (parsed.vin != null) {
        return RegCardCapture(
          url: url,
          scanned: true,
          vin: parsed.vin,
          make: parsed.make,
          year: parsed.year,
          plateNumber: parsed.plate,
        );
      }
    } catch (_) {
      // On-device unavailable (web) or failed — fall through to AI.
    }

    // 2b) AI fallback (holder name + VIN) when on-device found no VIN.
    if (kUseFirebase) {
      try {
        final callable =
            FirebaseFunctions.instance.httpsCallable('extractFromImage');
        final res = await callable.call<Map<dynamic, dynamic>>({
          'imageBase64': base64Encode(bytes),
          'mimeType': mime,
          'mode': 'registration',
        });
        final data = Map<String, dynamic>.from(res.data);
        final rawVin = data['vin'];
        final rawYear = data['year'];
        return RegCardCapture(
          url: url,
          scanned: true,
          looksLikeCard: data['isRegistrationCard'] != false,
          holderName: (data['holderName'] as String?)?.trim(),
          vin: rawVin is String
              ? rawVin.replaceAll(RegExp(r'\s'), '').toUpperCase()
              : null,
          plateNumber: (data['plateNumber'] as String?)?.trim(),
          make: (data['make'] as String?)?.trim(),
          model: (data['model'] as String?)?.trim(),
          year: rawYear is num ? rawYear.toInt() : null,
          fuelType: (data['fuelType'] as String?)?.trim(),
        );
      } on FirebaseFunctionsException catch (e) {
        // Surface a meaningful reason instead of silently doing nothing.
        final reason = switch (e.code) {
          'resource-exhausted' =>
            'Daily scan limit reached — try again tomorrow or upgrade to Plus.',
          'unauthenticated' => 'Please sign in again to scan.',
          _ =>
            "Couldn't read the card automatically. The photo is saved — please "
                'enter the details manually.',
        };
        return RegCardCapture(url: url, scanned: false, scanError: reason);
      } catch (_) {
        return RegCardCapture(
            url: url,
            scanned: false,
            scanError:
                "Couldn't read the card automatically. The photo is saved — "
                    'please enter the details manually.');
      }
    }
    return RegCardCapture(url: url, scanned: false);
  }
}

final registrationCardServiceProvider =
    Provider<RegistrationCardService>((ref) => RegistrationCardService());
