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
  const VinResult({
    this.make,
    this.model,
    this.year,
    this.trim,
    this.engine,
    this.fuel,
    this.transmission,
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

    return VinResult(
      make: _titleCase(_s(r['Make'])),
      model: _titleCase(_s(r['Model'])),
      year: int.tryParse(_s(r['ModelYear']) ?? ''),
      trim: _s(r['Trim']) ?? _s(r['Series']),
      engine: _engine(_s(r['DisplacementL']), _s(r['EngineCylinders'])),
      fuel: _fuel(_s(r['FuelTypePrimary'])),
      transmission: _transmission(_s(r['TransmissionStyle'])),
    );
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
