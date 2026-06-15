// On-device text recognition for the registration card. Free, offline, no API
// key. Real implementation on mobile (Google ML Kit); a no-op stub on web so
// the admin web build keeps compiling.
import 'card_ocr_stub.dart' if (dart.library.io) 'card_ocr_io.dart' as impl;

/// Returns every recognised text line on the image (Latin script). Empty on
/// web or when nothing is read.
Future<List<String>> recognizeCardText(String imagePath) =>
    impl.recognizeCardText(imagePath);
