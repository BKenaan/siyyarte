/// Pure-Dart extraction of structured fields from on-device OCR text lines of
/// a Lebanese registration card. The VIN is the key win: a 17-char VIN-charset
/// string is highly distinctive, so a regex finds it reliably — and the engine
/// number (shorter) never matches, which avoids the #1 confusion. From the VIN
/// alone the free NHTSA decoder fills make/model/year/engine, so on-device OCR
/// + VIN decode = a fully free auto-fill path.
class OnDeviceCard {
  final String? vin;
  final String? make;
  final int? year;
  final String? plate;
  const OnDeviceCard({this.vin, this.make, this.year, this.plate});

  bool get isEmpty => vin == null && make == null && year == null && plate == null;
}

// VIN charset excludes I, O, Q by standard.
final _vinToken = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');
final _vinRun = RegExp(r'[A-HJ-NPR-Z0-9]{17}');
final _year = RegExp(r'\b(19[89]\d|20[0-4]\d)\b');
// Lebanese plate: a Latin letter group + 5-6 digits (e.g. "Y 345555").
final _plate = RegExp(r'\b([A-Z]{1,2})[\s-]?(\d{5,6})\b');

OnDeviceCard parseCardLines(List<String> lines, List<String> knownMakes) {
  if (lines.isEmpty) return const OnDeviceCard();
  final joined = lines.join(' ');
  final upper = joined.toUpperCase();

  // --- VIN: strict per-token first (most reliable), then a compacted scan. ---
  String? vin;
  for (final tok in upper.split(RegExp(r'[^A-Z0-9]+'))) {
    if (_vinToken.hasMatch(tok)) {
      vin = tok;
      break;
    }
  }
  if (vin == null) {
    final compact = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    vin = _vinRun.firstMatch(compact)?.group(0);
  }

  // --- Year ---
  int? year;
  for (final m in _year.allMatches(joined)) {
    final y = int.tryParse(m.group(1)!);
    if (y != null) {
      year = y;
      break;
    }
  }

  // --- Make: match a known catalog make appearing in the text ---
  String? make;
  for (final m in knownMakes) {
    if (m.isNotEmpty && upper.contains(m.toUpperCase())) {
      make = m;
      break;
    }
  }

  // --- Plate (front side): letter(s) + digits, not the VIN itself ---
  String? plate;
  for (final m in _plate.allMatches(upper)) {
    final candidate = '${m.group(1)} ${m.group(2)}';
    if (vin == null || !vin.contains(m.group(2)!)) {
      plate = candidate;
      break;
    }
  }

  return OnDeviceCard(vin: vin, make: make, year: year, plate: plate);
}
