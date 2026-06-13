// Manufacturer-verified, source-cited specs ingested from the beta dataset
// (Firestore `verified_specs`). Every field row carries its own citation and
// market scope — the app shows these as "✓ Verified" with a tappable source,
// distinct from the computed general schedule.

/// One cited field value (a fluid, an attribute, or a maintenance interval).
class VerifiedField {
  final String label; // e.g. "Engine Oil", "Spark Plugs", "Fuel tank"
  final String? value; // spec string or formatted value
  final String? sourceDoc;
  final String? sourcePage;
  final String? sourceUrl;
  final String? publisher;
  const VerifiedField({
    required this.label,
    this.value,
    this.sourceDoc,
    this.sourcePage,
    this.sourceUrl,
    this.publisher,
  });

  bool get hasCitation => sourceDoc != null && sourcePage != null;
}

/// A maintenance interval read from an official source (km/months, normal &
/// severe), with its citation. Used to overlay the computed schedule.
class VerifiedInterval {
  final String item; // "Engine Oil & Filter", "Spark Plugs", ...
  final int? normalKm;
  final int? normalMonths;
  final int? severeKm;
  final int? severeMonths;
  final int? firstKm;
  final int? subsequentKm;
  final String? notes;
  final String? sourceDoc;
  final String? sourcePage;
  final String? sourceUrl;
  const VerifiedInterval({
    required this.item,
    this.normalKm,
    this.normalMonths,
    this.severeKm,
    this.severeMonths,
    this.firstKm,
    this.subsequentKm,
    this.notes,
    this.sourceDoc,
    this.sourcePage,
    this.sourceUrl,
  });

  factory VerifiedInterval.fromMap(Map<String, dynamic> m) => VerifiedInterval(
        item: (m['item'] as String?) ?? '',
        normalKm: (m['normal_km'] as num?)?.toInt(),
        normalMonths: (m['normal_months'] as num?)?.toInt(),
        severeKm: (m['severe_km'] as num?)?.toInt(),
        severeMonths: (m['severe_months'] as num?)?.toInt(),
        firstKm: (m['first_km'] as num?)?.toInt(),
        subsequentKm: (m['subsequent_km'] as num?)?.toInt(),
        notes: m['notes'] as String?,
        sourceDoc: m['source_doc'] as String?,
        sourcePage: m['source_page'] as String?,
        sourceUrl: m['source_url'] as String?,
      );
}

class VerifiedSpec {
  final String id;
  final String make;
  final String model;
  final String market; // 'GCC' | 'North America' | ...
  final String? generation;
  final int? yearStart;
  final int? yearEnd;
  final String? engineCode;
  final String? engineName;
  final String? fuelType;
  final String? drivetrain;
  final String? betaStatus; // Beta_Ready | Beta_Partial | Not_Ready
  final List<VerifiedField> fluids;
  final List<VerifiedField> attributes;
  final List<VerifiedInterval> maintenance;
  final String? octane;
  final String? variantOrigin;

  const VerifiedSpec({
    required this.id,
    required this.make,
    required this.model,
    required this.market,
    this.generation,
    this.yearStart,
    this.yearEnd,
    this.engineCode,
    this.engineName,
    this.fuelType,
    this.drivetrain,
    this.betaStatus,
    this.fluids = const [],
    this.attributes = const [],
    this.maintenance = const [],
    this.octane,
    this.variantOrigin,
  });

  bool coversYear(int year) =>
      (yearStart == null || year >= yearStart!) &&
      (yearEnd == null || year <= yearEnd!);

  /// Human label for the market scope shown next to verified values.
  String get marketScope => switch (market) {
        'GCC' => 'GCC-spec',
        'North America' => 'US-spec',
        'Europe' => 'EU-spec',
        'Japan' => 'JDM-spec',
        _ => market,
      };

  static String _fluidValue(Map<String, dynamic> m) {
    final spec = (m['spec'] as String?)?.trim();
    final cap = m['capacity'];
    final unit = (m['unit'] as String?)?.trim();
    final parts = <String>[];
    if (spec != null && spec.isNotEmpty) parts.add(spec);
    if (cap != null) parts.add('$cap${unit != null ? ' $unit' : ''}');
    return parts.join(' · ');
  }

  static VerifiedField _fieldFromFluid(Map<String, dynamic> m) => VerifiedField(
        label: (m['type'] as String?) ?? '',
        value: _fluidValue(m),
        sourceDoc: m['source_doc'] as String?,
        sourcePage: m['source_page'] as String?,
        sourceUrl: m['source_url'] as String?,
        publisher: m['publisher'] as String?,
      );

  static const _attrLabels = {
    'fuel_tank_l': 'Fuel tank',
    'tire_size': 'Tyre size',
    'spark_plug_part': 'Spark plug',
    'battery_12v': 'Battery',
    'differential_oil': 'Differential oil',
    'fuel_requirement': 'Fuel requirement',
    'engine_identity': 'Engine',
  };

  static VerifiedField? _fieldFromAttr(Map<String, dynamic> m) {
    final key = (m['key'] as String?) ?? '';
    final label = _attrLabels[key];
    if (label == null) return null; // skip internal/status-only keys
    final text = (m['text'] as String?)?.trim();
    final num = m['num'];
    final unit = (m['unit'] as String?)?.trim();
    final value = (text != null && text.isNotEmpty)
        ? text
        : (num != null ? '$num${unit != null ? ' $unit' : ''}' : null);
    if (value == null || value.isEmpty) return null;
    return VerifiedField(
      label: label,
      value: value,
      sourceDoc: m['source_doc'] as String?,
      sourcePage: m['source_page'] as String?,
      sourceUrl: m['source_url'] as String?,
      publisher: m['publisher'] as String?,
    );
  }

  factory VerifiedSpec.fromMap(String id, Map<String, dynamic> m) {
    List<Map<String, dynamic>> rows(String k) =>
        ((m[k] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
    final leb = m['lebanon'] is Map
        ? Map<String, dynamic>.from(m['lebanon'] as Map)
        : null;
    return VerifiedSpec(
      id: id,
      make: (m['make'] as String?) ?? '',
      model: (m['model'] as String?) ?? '',
      market: (m['market'] as String?) ?? '',
      generation: m['generation'] as String?,
      yearStart: (m['yearStart'] as num?)?.toInt(),
      yearEnd: (m['yearEnd'] as num?)?.toInt(),
      engineCode: m['engineCode'] as String?,
      engineName: m['engineName'] as String?,
      fuelType: m['fuelType'] as String?,
      drivetrain: m['drivetrain'] as String?,
      betaStatus: m['betaStatus'] as String?,
      fluids: rows('fluids').map(_fieldFromFluid).toList(),
      attributes:
          rows('attributes').map(_fieldFromAttr).whereType<VerifiedField>().toList(),
      maintenance: rows('maintenance').map(VerifiedInterval.fromMap).toList(),
      octane: leb?['octane'] as String?,
      variantOrigin: leb?['variant_origin'] as String?,
    );
  }
}
