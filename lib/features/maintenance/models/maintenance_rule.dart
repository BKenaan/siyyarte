import 'service_type.dart';

/// How an interval is sourced — so the UI can be honest about what is a real
/// manufacturer schedule vs. a wear/condition estimate.
enum IntervalBasis {
  /// Published manufacturer (OEM) maintenance schedule.
  factory,

  /// Wear/condition based — no fixed factory interval exists (tires, battery,
  /// brake pads). We surface a typical estimate and flag it as such.
  wearEstimate,

  /// Legal/regulatory requirement (e.g. Lebanon annual Mécanique inspection).
  regulatory,
}

/// Driving severity. Every OEM publishes a "special / severe operating
/// conditions" schedule for dusty roads, heat, short trips and stop-and-go —
/// which describes Lebanese driving, so [severe] is the app default.
enum DrivingSeverity { normal, severe }

/// A maintenance interval rule sourced from manufacturer factory schedules.
///
/// Each rule carries BOTH the normal and the severe-conditions interval (km and
/// months). The engine resolves which to use from the vehicle's
/// [DrivingSeverity]. Rules cascade trim → model → make → global; the most
/// specific match wins, so the admin catalog can drop in exact owner's-manual
/// values per vehicle while these factory defaults cover everything else.
class MaintenanceRule {
  final ServiceType type;

  final int? normalKm;
  final int? severeKm;
  final int? normalMonths;
  final int? severeMonths;

  final IntervalBasis basis;

  /// Human-readable provenance, e.g. "Toyota factory schedule (severe)".
  final String source;

  // Cascade scoping (null = applies to all).
  final String? make;
  final String? model;
  final String? trim;

  const MaintenanceRule({
    required this.type,
    this.normalKm,
    this.severeKm,
    this.normalMonths,
    this.severeMonths,
    this.basis = IntervalBasis.factory,
    required this.source,
    this.make,
    this.model,
    this.trim,
  });

  int? km(DrivingSeverity s) =>
      s == DrivingSeverity.severe ? (severeKm ?? normalKm) : normalKm;

  int? months(DrivingSeverity s) =>
      s == DrivingSeverity.severe ? (severeMonths ?? normalMonths) : normalMonths;
}

/// Factory-sourced default intervals for the Lebanese fleet.
///
/// Values are drawn from manufacturers' published maintenance schedules
/// (owner's manuals / OEM service guides), expressed in km. They are GENERIC
/// factory baselines; exact figures vary by model year, engine and trim and are
/// meant to be overridden by the admin catalog with the precise owner's-manual
/// values. Items marked [IntervalBasis.wearEstimate] have no fixed factory
/// interval and are shown as estimates.
///
/// Sources consulted (June 2026):
///  • Toyota scheduled maintenance guide (5k/15k/30k mi; severe = city/dusty;
///    iridium plugs ~100k mi; coolant 100k then 50k mi).
///  • Hyundai/Kia normal & severe maintenance schedules (oil 6mo/12mo;
///    plugs ~96–150k km; ATF/coolant 60–96k km).
///  • Honda & Nissan owner's manuals (oil 7.5k mi; CVT severe ~90k km;
///    timing belt 96–105k km; plugs 60–100k mi).
///  • BMW / German LongLife schedules (oil 10k mi/12mo; plugs 72–96k km;
///    brake fluid 24mo).
abstract class DefaultMaintenanceRules {
  // ---- Global factory baselines (apply to any make w/o an override) ----
  static const List<MaintenanceRule> _global = [
    MaintenanceRule(
      type: ServiceType.oilChange,
      normalKm: 10000, severeKm: 5000,
      normalMonths: 12, severeMonths: 6,
      source: 'OEM factory schedule — engine oil (normal/severe)',
    ),
    MaintenanceRule(
      type: ServiceType.oilFilter,
      normalKm: 10000, severeKm: 5000,
      normalMonths: 12, severeMonths: 6,
      source: 'OEM factory schedule — oil filter (with oil change)',
    ),
    MaintenanceRule(
      type: ServiceType.airFilter,
      normalKm: 30000, severeKm: 20000,
      normalMonths: 36, severeMonths: 24,
      source: 'OEM factory schedule — engine air filter',
    ),
    MaintenanceRule(
      type: ServiceType.sparkPlugs,
      normalKm: 100000, severeKm: 80000,
      normalMonths: 120, severeMonths: 96,
      source: 'OEM factory schedule — iridium/platinum spark plugs',
    ),
    MaintenanceRule(
      type: ServiceType.coolant,
      normalKm: 100000, severeKm: 80000,
      normalMonths: 60, severeMonths: 48,
      source: 'OEM factory schedule — engine coolant (first interval)',
    ),
    MaintenanceRule(
      type: ServiceType.transmissionFluid,
      normalKm: 80000, severeKm: 60000,
      normalMonths: 72, severeMonths: 48,
      source: 'OEM factory schedule — transmission/CVT fluid (severe)',
    ),
    MaintenanceRule(
      type: ServiceType.timingBelt,
      normalKm: 100000, severeKm: 90000,
      normalMonths: 96, severeMonths: 84,
      source: 'OEM factory schedule — timing belt (chain = inspect only)',
    ),
    // Brake fluid is hygroscopic and universally time-based: most OEMs call for
    // a 2–3 year change regardless of mileage. Generic baseline; sourced OEM
    // schedules override it with the exact cited figure where available.
    MaintenanceRule(
      type: ServiceType.brakeFluid,
      normalMonths: 36, severeMonths: 24,
      source: 'OEM factory schedule — brake fluid (hygroscopic, time-based)',
    ),
    // Inspection-based factory items (manufacturer says "inspect at each
    // service"); we schedule the inspection interval.
    MaintenanceRule(
      type: ServiceType.suspension,
      normalKm: 30000, severeKm: 20000,
      normalMonths: 24, severeMonths: 18,
      basis: IntervalBasis.wearEstimate,
      source: 'OEM factory schedule — inspect; replacement is wear-based',
    ),
    MaintenanceRule(
      type: ServiceType.brakePads,
      normalKm: 20000, severeKm: 15000,
      normalMonths: 24, severeMonths: 18,
      basis: IntervalBasis.wearEstimate,
      source: 'Inspection interval — pad replacement is wear-based',
    ),
    MaintenanceRule(
      type: ServiceType.tires,
      normalKm: 60000, severeKm: 50000,
      normalMonths: 72, severeMonths: 60,
      basis: IntervalBasis.wearEstimate,
      source: 'Estimate — tires are tread/age-based, not factory-scheduled',
    ),
    MaintenanceRule(
      type: ServiceType.battery,
      normalMonths: 48, severeMonths: 36,
      basis: IntervalBasis.wearEstimate,
      source: 'Estimate — battery life is condition-based',
    ),
    // Lebanon legal annual vehicle inspection (Mécanique).
    MaintenanceRule(
      type: ServiceType.inspection,
      normalMonths: 12, severeMonths: 12,
      basis: IntervalBasis.regulatory,
      source: 'Lebanon — mandatory annual vehicle inspection (Mécanique)',
    ),
  ];

  // ---- Per-make factory overrides where schedules clearly differ ----
  static const List<MaintenanceRule> _overrides = [
    // Toyota / Lexus — long iridium plug life, SLLC coolant.
    MaintenanceRule(
      type: ServiceType.sparkPlugs, make: 'Toyota',
      normalKm: 100000, severeKm: 100000,
      normalMonths: 120, severeMonths: 120,
      source: 'Toyota factory schedule — iridium spark plugs ~100,000 km',
    ),
    MaintenanceRule(
      type: ServiceType.coolant, make: 'Toyota',
      normalKm: 160000, severeKm: 80000,
      normalMonths: 120, severeMonths: 60,
      source: 'Toyota factory schedule — SLLC: first 160,000 km then 80,000 km',
    ),
    // Honda — plugs ~100k mi, Maintenance Minder oil.
    MaintenanceRule(
      type: ServiceType.sparkPlugs, make: 'Honda',
      normalKm: 160000, severeKm: 120000,
      normalMonths: 120, severeMonths: 96,
      source: 'Honda factory schedule — spark plugs ~160,000 km',
    ),
    // Nissan — CVT fluid attention under severe use.
    MaintenanceRule(
      type: ServiceType.transmissionFluid, make: 'Nissan',
      normalKm: 90000, severeKm: 60000,
      normalMonths: 72, severeMonths: 48,
      source: 'Nissan factory schedule — CVT fluid (severe ~60,000 km)',
    ),
    // Hyundai / Kia — longer plug life on many engines.
    MaintenanceRule(
      type: ServiceType.sparkPlugs, make: 'Hyundai',
      normalKm: 150000, severeKm: 100000,
      normalMonths: 120, severeMonths: 96,
      source: 'Hyundai factory schedule — spark plugs ~150,000 km',
    ),
    MaintenanceRule(
      type: ServiceType.sparkPlugs, make: 'Kia',
      normalKm: 150000, severeKm: 100000,
      normalMonths: 120, severeMonths: 96,
      source: 'Kia factory schedule — spark plugs ~150,000 km',
    ),
    // German makes — LongLife oil, shorter plug life.
    MaintenanceRule(
      type: ServiceType.oilChange, make: 'BMW',
      normalKm: 16000, severeKm: 10000,
      normalMonths: 12, severeMonths: 12,
      source: 'BMW factory schedule — LongLife oil (severe ~10,000 km/12 mo)',
    ),
    MaintenanceRule(
      type: ServiceType.sparkPlugs, make: 'BMW',
      normalKm: 96000, severeKm: 72000,
      normalMonths: 96, severeMonths: 72,
      source: 'BMW factory schedule — spark plugs ~72,000–96,000 km',
    ),
    MaintenanceRule(
      type: ServiceType.oilChange, make: 'Mercedes-Benz',
      normalKm: 16000, severeKm: 10000,
      normalMonths: 12, severeMonths: 12,
      source: 'Mercedes Service A/B — oil ~16,000 km/12 mo (severe shorter)',
    ),
    MaintenanceRule(
      type: ServiceType.oilChange, make: 'Volkswagen',
      normalKm: 15000, severeKm: 10000,
      normalMonths: 12, severeMonths: 12,
      source: 'VW factory schedule — LongLife (fixed/severe ~10,000 km)',
    ),
  ];

  static const List<MaintenanceRule> all = [..._global, ..._overrides];
}
