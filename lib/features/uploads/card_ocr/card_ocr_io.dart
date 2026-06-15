import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Mobile implementation: Google ML Kit on-device Latin text recognition.
/// The card's values (make, model, year, VIN, plate) are printed in Latin, so
/// the Latin model is enough — we don't need the Arabic label text.
Future<List<String>> recognizeCardText(String imagePath) async {
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final result =
        await recognizer.processImage(InputImage.fromFilePath(imagePath));
    final lines = <String>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        final t = line.text.trim();
        if (t.isNotEmpty) lines.add(t);
      }
    }
    return lines;
  } finally {
    await recognizer.close();
  }
}
