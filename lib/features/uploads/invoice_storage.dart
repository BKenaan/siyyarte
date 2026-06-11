import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/bootstrap.dart';

/// Picks an invoice/photo and returns a reference to it:
///  • mock mode  → the local file path (works offline for demos)
///  • Firebase   → uploads to Storage under users/{uid}/invoices and returns
///    the download URL.
/// Returns null if the user cancels.
abstract class InvoiceStorage {
  Future<String?> pickAndUpload();
}

class MockInvoiceStorage implements InvoiceStorage {
  final _picker = ImagePicker();

  @override
  Future<String?> pickAndUpload() async {
    final file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    return file?.path; // local path — no cloud needed
  }
}

class FirebaseInvoiceStorage implements InvoiceStorage {
  final _picker = ImagePicker();

  @override
  Future<String?> pickAndUpload() async {
    final file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file == null) return null;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');

    final ref = FirebaseStorage.instance.ref(
        'users/$uid/invoices/${DateTime.now().microsecondsSinceEpoch}.jpg');
    await ref.putData(
      await file.readAsBytes(),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}

final invoiceStorageProvider = Provider<InvoiceStorage>((ref) {
  // Cloud upload only when Storage is actually enabled (Blaze). Otherwise the
  // picked image is kept as a local path so the feature still works on Spark.
  return (kUseFirebase && kUseFirebaseStorage)
      ? FirebaseInvoiceStorage()
      : MockInvoiceStorage();
});
