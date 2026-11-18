import 'dart:convert';

import 'package:http/http.dart' as http;

/// Decoded VIN result. Any field may be null when NHTSA has no data for it.
class VinResult {
  final String? make;
  final String? model;
  final int? year;
  final String? trim;
  final String? engine; // e.g. "6.2L V8"
  final String? fuel; // mapped to app options
  final String? transmission; // mapped to app options

  /// Raw NHTSA ErrorCode (comma-separated), e.g. "1,8". "0" means a clean
  /// decode; "1" means the VIN's check digit is invalid.
  final String? errorCode;

  /// True when the decode is unreliable/sparse — the check digit failed OR
  /// NHTSA returned no model. The UI shows a non-blocking hint so the user can
  /// re-check the characters or fill the details in by hand.
  final bool incomplete;

  const VinResult({
    this.make,
    this.model,
    this.year,
    this.trim,
    this.engine,
    this.fuel,
    this.transmission,
    this.errorCode,
    this.incomplete = false,
  });
}

/// Decodes a VIN with the free, official NHTSA vPIC API — covers essentially
/// any vehicle worldwide, so specs don't have to be hand-authored per trim.
/// Engine displacement + fuel come through reliably; model/trim/transmission
/// can be sparse for some VINs (we fill what's available).
class VinDecoder {
  static const _base =
      'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues';

  static Future<VinResult> decode(String vin) async {
    final resp = await http
        .get(Uri.parse('$_base/${vin.trim()}?format=json'))
        .timeout(const Duration(seconds: 20));
    if (resp.statusCode != 200) {
      throw Exception('VIN lookup failed (${resp.statusCode})');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = body['Results'] as List?;
    if (results == null || results.isEmpty) {
      throw Exception('No data for this VIN');
    }
    final r = results.first as Map<String, dynamic>;

    final make = _titleCase(_s(r['Make']));
    var model = _titleCase(_s(r['Model']));
    final errorCode = _s(r['ErrorCode']);

    // NHTSA's ModelYear is authoritative — use it verbatim, never offset it.
    // Only when NHTSA returns no year do we fall back to decoding the VIN's own
    // model-year code (position 10). For VIN "WDC2923561A116639" NHTSA returns
    // ModelYear=2001 (position 10 = "1"), so we show 2001 — not 2011.
    final year = int.tryParse(_s(r['ModelYear']) ?? '') ?? _yearFromVin(vin);

    // Mercedes chassis-code fallback: NHTSA often returns an empty Model for
    // Mercedes VINs (especially with a bad check digit). The VDS model code
    // (characters 4–6) identifies the platform, so we can still pre-fill it.
    if (model == null && (make?.toLowerCase().contains('mercedes') ?? false)) {
      model = _mercedesModelFromVin(vin);
    }

    // "1" in ErrorCode = check-digit failed; an empty Model means a sparse
    // result. Either way, flag the decode as incomplete for the UI hint.
    final incomplete = _hasCheckDigitError(errorCode) || model == null;

    return VinResult(
      make: make,
      model: model,
      year: year,
      trim: _s(r['Trim']) ?? _s(r['Series']),
      engine: _engine(_s(r['DisplacementL']), _s(r['EngineCylinders'])),
      fuel: _fuel(_s(r['FuelTypePrimary'])),
      transmission: _transmission(_s(r['TransmissionStyle'])),
      errorCode: errorCode,
      incomplete: incomplete,
    );
  }

  /// True when NHTSA's ErrorCode list contains "1" (invalid check digit).
  static bool _hasCheckDigitError(String? errorCode) {
    if (errorCode == null) return false;
    return errorCode.split(',').map((e) => e.trim()).contains('1');
  }

  /// Decode the model year from the VIN's 10th character (position 10) using
  /// the ISO 3779 model-year code for the current 2010–2039 cycle (which also
  /// covers 2001–2009 via the digit codes). Used ONLY as a fallback when NHTSA
  /// returns no ModelYear — we never override NHTSA's own value with this.
  /// e.g. "1"=2001, "A"=2010, "B"=2011 … "J"=2018, "L"=2020.
  static int? _yearFromVin(String vin) {
    final v = vin.trim().toUpperCase();
    if (v.length < 10) return null;
    const map = {
      '1': 2001, '2': 2002, '3': 2003, '4': 2004, '5': 2005,
      '6': 2006, '7': 2007, '8': 2008, '9': 2009,
      'A': 2010, 'B': 2011, 'C': 2012, 'D': 2013, 'E': 2014,
      'F': 2015, 'G': 2016, 'H': 2017, 'J': 2018, 'K': 2019,
      'L': 2020, 'M': 2021, 'N': 2022, 'P': 2023, 'R': 2024,
      'S': 2025, 'T': 2026, 'V': 2027, 'W': 2028, 'X': 2029, 'Y': 2030,
    };
    return map[v[9]]; // position 10 = index 9
  }

  /// Map a Mercedes-Benz VDS model code (VIN characters 4–6) to a model name.
  /// Only high-confidence platform codes are included — anything uncertain is
  /// omitted so we never pre-fill a wrong model.
  static String? _mercedesModelFromVin(String vin) {
    final v = vin.trim().toUpperCase();
    if (v.length < 6) return null;
    const map = {
      '292': 'GLE Coupé',
      '166': 'GLE/ML',
      '167': 'GLE/ML',
      '253': 'GLC',
      '205': 'C-Class',
      '213': 'E-Class',
      '463': 'G-Class',
      '464': 'G-Class',
    };
    return map[v.substring(3, 6)]; // characters 4–6
  }

  static String? _s(Object? v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  static String? _titleCase(String? s) {
    if (s == null) return null;
    return s.split(' ').map((w) {
      if (w.isEmpty) return w;
      // Keep short tokens uppercase so acronym makes stay intact (GMC, BMW, MG).
      if (w.length <= 3) return w.toUpperCase();
      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ');
  }

  static String? _engine(String? displacementL, String? cylinders) {
    final disp = double.tryParse(displacementL ?? '');
    final cyl = int.tryParse(cylinders ?? '');
    if (disp == null && cyl == null) return null;
    final l = disp != null ? '${disp.toStringAsFixed(1)}L' : '';
    final config = cyl == null ? '' : _cylConfig(cyl);
    return [l, config].where((x) => x.isNotEmpty).join(' ');
  }

  static String _cylConfig(int n) => switch (n) {
        3 => 'I3',
        4 => 'I4',
        5 => 'I5',
        6 => 'V6',
        8 => 'V8',
        10 => 'V10',
        12 => 'V12',
        _ => '$n-cyl',
      };

  /// Map NHTSA fuel to the app's options (see VehicleCatalog.fuelTypes).
  static String? _fuel(String? f) {
    if (f == null) return null;
    final s = f.toLowerCase();
    if (s.contains('electric')) return 'Electric';
    if (s.contains('diesel')) return 'Diesel';
    if (s.contains('hydrogen')) return 'Electric';
    if (s.contains('compressed') || s.contains('lpg') || s.contains('propane')) {
      return 'LPG';
    }
    if (s.contains('gasoline') || s.contains('flexible') || s.contains('petrol')) {
      return 'Petrol';
    }
    return null;
  }

  static String? _transmission(String? t) {
    if (t == null) return null;
    final s = t.toLowerCase();
    if (s.contains('manual')) return 'Manual';
    if (s.contains('continuously') || s.contains('cvt')) return 'CVT';
    if (s.contains('dual')) return 'Dual-clutch';
    if (s.contains('automat')) return 'Automatic';
    return null;
  }
}
