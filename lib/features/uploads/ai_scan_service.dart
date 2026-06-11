import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/bootstrap.dart';

/// Calls the `extractFromImage` Cloud Function (Claude vision) to read a photo
/// of a service invoice or an odometer and return structured fields. Requires
/// Firebase + the deployed function; throws a clear error otherwise.
class AiScanService {
  final _picker = ImagePicker();

  bool get available => kUseFirebase;

  Future<Map<String, dynamic>?> _scan(String mode) async {
    if (!kUseFirebase) {
      throw StateError('AI scan needs the Firebase backend (deploy functions).');
    }
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 1600,
    );
    if (file == null) return null; // user cancelled
    final bytes = await file.readAsBytes();
    // file.name (not .path) — on web the path is a blob URL with no extension.
    final mime = file.mimeType ??
        (file.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg');

    final callable =
        FirebaseFunctions.instance.httpsCallable('extractFromImage');
    final res = await callable.call<Map<dynamic, dynamic>>({
      'imageBase64': base64Encode(bytes),
      'mimeType': mime,
      'mode': mode,
    });
    return Map<String, dynamic>.from(res.data);
  }

  /// Returns the parsed invoice fields, or null if cancelled.
  Future<Map<String, dynamic>?> scanInvoice() => _scan('invoice');

  /// Returns the read odometer in km, or null if cancelled / unreadable.
  Future<int?> scanOdometer() async {
    final data = await _scan('odometer');
    final v = data?['odometerKm'];
    return v is num ? v.toInt() : null;
  }
}

final aiScanServiceProvider = Provider<AiScanService>((ref) => AiScanService());
