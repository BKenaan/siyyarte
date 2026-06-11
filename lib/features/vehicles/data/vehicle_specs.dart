/// Trim-level factory specifications: selecting make → model → year → trim
/// auto-fills the engine, fuel and transmission, so the maintenance engine can
/// tailor the schedule (e.g. a diesel has no spark plugs; a 6.2L V8 Denali vs a
/// 5.3L V8 SLE). `fuel` and `transmission` use the same option strings as
/// [VehicleCatalog] so they slot straight into the add-vehicle form.
///
/// This is a SEED. The exhaustive trim database is best sourced from a VIN/specs
/// service (e.g. NHTSA vPIC) or curated in the admin panel; anything not listed
/// here still works via free-text entry + the global factory schedule.
class TrimSpec {
  final String trim;
  final String engine; // e.g. "5.3L V8"
  final String fuel; // Petrol / Diesel / Hybrid / Electric / LPG
  final String transmission; // Automatic / Manual / CVT / Dual-clutch
  const TrimSpec(this.trim, this.engine, this.fuel, this.transmission);

  Map<String, dynamic> toMap() => {
        'trim': trim,
        'engine': engine,
        'fuel': fuel,
        'transmission': transmission,
      };

  factory TrimSpec.fromMap(Map<String, dynamic> m) => TrimSpec(
        m['trim'] as String? ?? '',
        m['engine'] as String? ?? '',
        m['fuel'] as String? ?? 'Petrol',
        m['transmission'] as String? ?? 'Automatic',
      );
}

class ModelSpec {
  /// Firestore document id (null for the built-in seed entries).
  final String? id;
  final String make;
  final String model;
  final int yearStart;
  final int yearEnd;
  final List<TrimSpec> trims;
  const ModelSpec(
      this.make, this.model, this.yearStart, this.yearEnd, this.trims,
      {this.id});

  Map<String, dynamic> toMap() => {
        'make': make,
        'model': model,
        'yearStart': yearStart,
        'yearEnd': yearEnd,
        'trims': trims.map((t) => t.toMap()).toList(),
      };

  factory ModelSpec.fromMap(String id, Map<String, dynamic> m) => ModelSpec(
        m['make'] as String? ?? '',
        m['model'] as String? ?? '',
        (m['yearStart'] as num?)?.toInt() ?? 1990,
        (m['yearEnd'] as num?)?.toInt() ?? 2100,
        ((m['trims'] as List?) ?? [])
            .map((t) => TrimSpec.fromMap(Map<String, dynamic>.from(t as Map)))
            .toList(),
        id: id,
      );
}

abstract class VehicleSpecs {
  static const List<ModelSpec> all = [
    // GMC Yukon (GMT900 → K2XX) — the worked example.
    ModelSpec('GMC', 'Yukon', 2007, 2014, [
      TrimSpec('SLE', '5.3L V8', 'Petrol', 'Automatic'),
      TrimSpec('SLT', '5.3L V8', 'Petrol', 'Automatic'),
      TrimSpec('Denali', '6.2L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('GMC', 'Yukon', 2015, 2020, [
      TrimSpec('SLE', '5.3L V8', 'Petrol', 'Automatic'),
      TrimSpec('SLT', '5.3L V8', 'Petrol', 'Automatic'),
      TrimSpec('Denali', '6.2L V8', 'Petrol', 'Automatic'),
    ]),

    // Toyota
    ModelSpec('Toyota', 'Land Cruiser', 2008, 2021, [
      TrimSpec('GXR', '4.0L V6', 'Petrol', 'Automatic'),
      TrimSpec('VXR', '5.7L V8', 'Petrol', 'Automatic'),
      TrimSpec('GXR Diesel', '4.5L V8 TD', 'Diesel', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Corolla', 2014, 2019, [
      TrimSpec('XLI', '1.6L I4', 'Petrol', 'CVT'),
      TrimSpec('GLI', '1.8L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Toyota', 'Hilux', 2016, 2023, [
      TrimSpec('2.7L Petrol', '2.7L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.8L Diesel', '2.8L I4 TD', 'Diesel', 'Automatic'),
    ]),

    // Nissan
    ModelSpec('Nissan', 'Patrol', 2010, 2023, [
      TrimSpec('XE', '4.0L V6', 'Petrol', 'Automatic'),
      TrimSpec('LE Platinum', '5.6L V8', 'Petrol', 'Automatic'),
    ]),

    // Hyundai / Kia
    ModelSpec('Hyundai', 'Tucson', 2016, 2020, [
      TrimSpec('GL', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('GLS', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'Sportage', 2017, 2021, [
      TrimSpec('LX', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('EX', '2.4L I4', 'Petrol', 'Automatic'),
    ]),

    // Lexus
    ModelSpec('Lexus', 'RX', 2016, 2022, [
      TrimSpec('RX 350', '3.5L V6', 'Petrol', 'Automatic'),
      TrimSpec('RX 450h', '3.5L V6', 'Hybrid', 'CVT'),
    ]),
    ModelSpec('Lexus', 'ES', 2019, 2024, [
      TrimSpec('ES 350', '3.5L V6', 'Petrol', 'Automatic'),
      TrimSpec('ES 300h', '2.5L I4', 'Hybrid', 'CVT'),
    ]),
    ModelSpec('Lexus', 'LX', 2016, 2021, [
      TrimSpec('LX 570', '5.7L V8', 'Petrol', 'Automatic'),
    ]),

    // BMW
    ModelSpec('BMW', '3 Series', 2012, 2018, [
      TrimSpec('320i', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('328i', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('335i', '3.0L I6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BMW', '5 Series', 2017, 2023, [
      TrimSpec('530i', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('540i', '3.0L I6', 'Petrol', 'Automatic'),
    ]),

    // Mercedes-Benz
    ModelSpec('Mercedes-Benz', 'C-Class', 2015, 2021, [
      TrimSpec('C 200', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('C 300', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'E-Class', 2017, 2023, [
      TrimSpec('E 200', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('E 350', '2.0L I4', 'Petrol', 'Automatic'),
    ]),

    // Nissan / Hyundai / Kia compacts
    ModelSpec('Nissan', 'Sunny', 2012, 2020, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Accent', 2018, 2023, [
      TrimSpec('1.4L', '1.4L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'Rio', 2017, 2023, [
      TrimSpec('1.4L', '1.4L I4', 'Petrol', 'Automatic'),
    ]),

    // EV example
    ModelSpec('Tesla', 'Model 3', 2019, 2024, [
      TrimSpec('Standard Range', 'Electric RWD', 'Electric', 'Automatic'),
      TrimSpec('Long Range', 'Electric Dual Motor', 'Electric', 'Automatic'),
    ]),
  ];

  /// The built-in seed (kept for offline use and as a baseline under any
  /// admin-curated specs from Firestore).
  static const List<ModelSpec> seed = all;

  /// All trims for a make/model/year from an explicit spec list (seed + any
  /// admin-curated specs). Empty → fall back to free text.
  static List<TrimSpec> trimsFrom(
      List<ModelSpec> specs, String make, String model, int? year) {
    if (year == null) return const [];
    return specs
        .where((m) =>
            m.make == make &&
            m.model == model &&
            year >= m.yearStart &&
            year <= m.yearEnd)
        .expand((m) => m.trims)
        .toList();
  }

  static TrimSpec? specFrom(List<ModelSpec> specs, String make, String model,
      int? year, String trim) {
    for (final t in trimsFrom(specs, make, model, year)) {
      if (t.trim == trim) return t;
    }
    return null;
  }

  // Seed-only convenience (used where the merged provider isn't available).
  static List<TrimSpec> trimsFor(String make, String model, int? year) =>
      trimsFrom(seed, make, model, year);

  static TrimSpec? specFor(String make, String model, int? year, String trim) =>
      specFrom(seed, make, model, year, trim);
}
