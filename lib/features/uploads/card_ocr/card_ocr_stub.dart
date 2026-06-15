/// Web/desktop stub — on-device OCR isn't available, so callers fall back to
/// the AI scan (or manual entry).
Future<List<String>> recognizeCardText(String imagePath) async => const [];
