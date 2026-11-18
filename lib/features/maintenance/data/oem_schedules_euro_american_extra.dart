// OEM maintenance schedules — additional European & American makes.
//
// RESEARCH DATA ONLY. Like its sibling files (oem_schedules_german_american.dart
// and oem_schedules_japanese.dart) this is a sourced, structured corpus gathered
// from real manufacturer / official-importer maintenance documents. It is
// intentionally NOT wired into the engine (maintenance_engine.dart) or the rule
// set (maintenance_rule.dart); integration is reviewed separately.
//
// Scope: makes present in Lebanon but not covered by the German/American or
// Japanese corpora — Peugeot, Renault, Citroën, Fiat, Jeep, Dodge, RAM, Land
// Rover, Jaguar, Volvo, MINI, Škoda, SEAT. Petrol only (diesel passenger cars
// are banned in Lebanon).
//
// Discipline (mirrors the sibling files and verified_specs): the GOLDEN RULE is
// never show an unverified number. Every [OemInterval] below was read from a
// real document; the full citation (document title + URL + what it is) lives in
// the companion file oem_schedules_euro_american_extra_SOURCES.md, keyed by the
// `source` string, and each value carries a confidence [OemGrade] A–D. Values
// that could not be sourced from an opened OEM document were OMITTED and are
// recorded as honest gaps in the SOURCES file — nothing here is invented,
// guessed, or copied across models/makes.
//
// Units: intervals are stored in KILOMETRES. The Stellantis / MINI / Volvo /
// Jaguar-Land-Rover documents publish in MILES; miles were converted at the
// repo's standard ×1.6 factor (10k mi = 16,000 km, 60k mi = 96,000 km, 100k mi =
// 160,000 km, 150k mi = 240,000 km), the same convention used in
// data_backend/verified_specs.json and the sibling corpora. Where a document
// itself printed a round km value, that km value is stored verbatim and noted.
//
// Condition-based service: several of these makes do NOT publish a single fixed
// odometer table — they compute the next service from an on-board indicator:
//   • Stellantis (Jeep/Dodge/RAM) — Oil Change Indicator for the oil item (the
//     rest of the plan IS a fixed mileage table). Baseline cap 10,000 mi/12 mo.
//   • MINI — Condition Based Service (CBS), like BMW; the booklet still ties
//     each item to a specific oil-service count, giving concrete ~mile figures.
//   • Land Rover — variable Service Interval Indicator (distance-to-service or
//     days remaining); no single fixed odometer figure is published.
//   • Volvo — fixed Service Reminder Indicator, 10,000 mi / 1 yr; the FSM sheet
//     then lists each longer item at a fixed mileage. (Effectively a fixed table.)
// Where a make is indicator-driven, [OemSchedule.conditionBased] is true and a
// concrete baseline number is still recorded per the app directive, flagged in
// notes.
//
// Severe / harsh-conditions: Lebanon is a severe-use market (heat, dust, stop-
// and-go, mountainous). The published SEVERE / "special operating conditions" /
// "arduous conditions" column is captured as a distinct [OemSeverity.severe] row
// wherever the document gives a separate figure.

/// Confidence grade of the source backing a value (mirrors verified_specs A–D).
///  • [a] official manufacturer / official-importer document, value read
///        unambiguously from it (incl. an X-mark table read from the rendered
///        page image).
///  • [b] official document but value is model/engine-column dependent, or the
///        concrete number is corroborated across the maker's own owner-guide
///        family rather than read from the single opened page.
///  • [c] weaker secondary source.
///  • [d] inferred / placeholder — NOT used in this file (we omit instead).
enum OemGrade { a, b, c, d }

/// Driving severity, matching DrivingSeverity in maintenance_rule.dart. Most of
/// these OEM schedules publish a single "normal" table and describe severe use
/// in prose; [OemSeverity.severe] rows are only present where a document gives a
/// distinct severe figure.
enum OemSeverity { normal, severe }

/// One sourced maintenance interval for a service item.
class OemInterval {
  /// Service item label as printed by the OEM (e.g. "Engine Oil & Filter",
  /// "Spark Plugs", "Brake Fluid", "Cabin Air Filter").
  final String service;

  /// Interval in kilometres (null = this item is time-only or has no published
  /// distance interval, e.g. brake fluid "every 3 years regardless of mileage").
  final int? intervalKm;

  /// Interval in months (null = distance-only).
  final int? intervalMonths;

  final OemSeverity severity;
  final OemGrade grade;

  /// Short provenance string. The full citation (document title, page, URL,
  /// publisher) is in oem_schedules_euro_american_extra_SOURCES.md keyed by this.
  final String source;

  /// Caveats: condition-based flag, "lifetime/check-only" claims, model/engine
  /// scoping, mile-equivalent of the stored km, severe-use trigger, etc.
  final String? notes;

  const OemInterval({
    required this.service,
    this.intervalKm,
    this.intervalMonths,
    this.severity = OemSeverity.normal,
    required this.grade,
    required this.source,
    this.notes,
  });
}

/// A per (make, model, year-range, engine/fuel) set of sourced intervals.
class OemSchedule {
  final String make;
  final String model;
  final int? yearStart;
  final int? yearEnd;

  /// Engine / fuel descriptor this schedule is scoped to (null = applies across
  /// the model's engines per the cited doc).
  final String? engine;

  /// 'Petrol', 'Diesel', 'Hybrid', etc.
  final String fuel;

  /// True when the make/item uses a flexible / condition-based indicator, so the
  /// recorded figure is a published baseline/maximum rather than a hard table.
  final bool conditionBased;

  final List<OemInterval> intervals;

  const OemSchedule({
    required this.make,
    required this.model,
    this.yearStart,
    this.yearEnd,
    this.engine,
    this.fuel = 'Petrol',
    this.conditionBased = false,
    required this.intervals,
  });
}

/// The research corpus for the additional Euro/American makes. Grouped by make.
const List<OemSchedule> kOemSchedulesEuroAmericanExtra = [
  // ==========================================================================
  // STELLANTIS — Jeep / Dodge / RAM (US-market Mopar owner manuals).
  //
  // Common pattern read directly from each model's official US owner manual
  // (vehicleinfo.mopar.com / msmownerassets): the OIL item is governed by the
  // Oil Change Indicator System with a hard cap of "10,000 miles (16,000 km),
  // 12 months or 350 engine-hours, whichever first" (conditionBased). The REST
  // of the plan is a fixed X-mark mileage table (read from the rendered page
  // image, Grade A). Spark-plug rows are explicitly "mileage-based only; yearly
  // intervals do not apply." These Mopar plans publish NO brake-fluid
  // replacement interval and NO normal automatic-transmission-fluid interval
  // (fill-for-life; only severe police/taxi/fleet/tow items for the driveline) —
  // see SOURCES "gaps". Lebanon = severe, so the severe driveline rows apply.
  // ==========================================================================

  OemSchedule(
    make: 'RAM',
    model: '1500 (DT)',
    yearStart: 2019,
    yearEnd: 2024,
    engine: '3.6L V6 eTorque / 5.7L V8 HEMI',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'RAM 1500 2022 Owner Manual (Mopar US)',
        notes:
            'Oil Change Indicator System. "Under no circumstances should oil '
            'change intervals exceed 10,000 miles (16,000 km), 12 months or '
            '350 hours", whichever first. conditionBased.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 160000,
        grade: OemGrade.a,
        source: 'RAM 1500 2022 Owner Manual (Mopar US)',
        notes: '100,000 mi. Mileage-based only; yearly interval does not apply.',
      ),
      OemInterval(
        service: 'Engine Air Cleaner Filter',
        intervalKm: 48000,
        grade: OemGrade.a,
        source: 'RAM 1500 2022 Owner Manual (Mopar US)',
        notes: 'Replace every 30,000 mi (X at 30/60/90/120/150k).',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 19000,
        grade: OemGrade.a,
        source: 'RAM 1500 2022 Owner Manual (Mopar US)',
        notes: 'Printed verbatim: "To be replaced every 12,000 miles (19,000 km)".',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 240000,
        intervalMonths: 120,
        grade: OemGrade.a,
        source: 'RAM 1500 2022 Owner Manual (Mopar US)',
        notes: 'Flush & replace at 10 years or 150,000 mi (240,000 km).',
      ),
      OemInterval(
        service: 'Transfer Case Fluid (4WD)',
        intervalKm: 192000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'RAM 1500 2022 Owner Manual (Mopar US)',
        notes:
            'SEVERE only (police/taxi/fleet/frequent trailer towing): inspect '
            '60k, change by 120,000 mi (192,000 km). No normal-service interval.',
      ),
      OemInterval(
        service: 'Evaporative System Fresh Air Filter',
        intervalKm: 16000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'RAM 1500 2022 Owner Manual (Mopar US)',
        notes:
            'SEVERE dusty conditions: every 10,000 mi (16,000 km). NOTE: this is '
            'the fuel-vapor canister fresh-air filter, not the cabin filter.',
      ),
    ],
  ),

  OemSchedule(
    make: 'Dodge',
    model: 'Charger (LD)',
    yearStart: 2015,
    yearEnd: 2023,
    engine: '3.6L V6 Pentastar / 5.7L V8 HEMI',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Dodge Charger 2023 Owner Manual (Mopar US)',
        notes: 'Oil Change Indicator; cap 10,000 mi (16,000 km)/12 mo. conditionBased.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 160000,
        grade: OemGrade.a,
        source: 'Dodge Charger 2023 Owner Manual (Mopar US)',
        notes: '100,000 mi. Mileage-based only.',
      ),
      OemInterval(
        service: 'Engine Air Cleaner Filter',
        intervalKm: 48000,
        grade: OemGrade.a,
        source: 'Dodge Charger 2023 Owner Manual (Mopar US)',
        notes: 'Replace every 30,000 mi (X at 30/60/90/120/150k).',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 19000,
        grade: OemGrade.a,
        source: 'Dodge Charger 2023 Owner Manual (Mopar US)',
        notes: 'Printed verbatim: "To be replaced every 12,000 miles (19,000 km)".',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 240000,
        intervalMonths: 120,
        grade: OemGrade.a,
        source: 'Dodge Charger 2023 Owner Manual (Mopar US)',
        notes: 'Flush & replace at 10 years or 150,000 mi (240,000 km).',
      ),
      OemInterval(
        service: 'Transfer Case Fluid (AWD)',
        intervalKm: 192000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'Dodge Charger 2023 Owner Manual (Mopar US)',
        notes:
            'AWD only, SEVERE (police/taxi/fleet/off-road/towing): change at '
            '60k & 120,000 mi. No normal-service interval.',
      ),
    ],
  ),

  OemSchedule(
    make: 'Dodge',
    model: 'Durango (WD) — Non-SRT',
    yearStart: 2014,
    yearEnd: 2023,
    engine: '3.6L V6 Pentastar / 5.7L V8 HEMI',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Dodge Durango 2020 Owner Manual (Mopar US)',
        notes: 'Oil Change Indicator; cap 10,000 mi (16,000 km)/12 mo. conditionBased.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 160000,
        grade: OemGrade.a,
        source: 'Dodge Durango 2020 Owner Manual (Mopar US)',
        notes: '100,000 mi. Mileage-based only.',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 48000,
        grade: OemGrade.a,
        source: 'Dodge Durango 2020 Owner Manual (Mopar US)',
        notes: 'Replace every 30,000 mi (X at 30/60/90/120/150k).',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 32000,
        grade: OemGrade.a,
        source: 'Dodge Durango 2020 Owner Manual (Mopar US)',
        notes:
            'Air-conditioning filter every 20,000 mi (X at 20/40/60/80/100/'
            '120/140k). Note: Durango cabin interval differs from RAM/Charger.',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 240000,
        intervalMonths: 120,
        grade: OemGrade.a,
        source: 'Dodge Durango 2020 Owner Manual (Mopar US)',
        notes: 'Flush & replace at 10 years or 150,000 mi (240,000 km).',
      ),
      OemInterval(
        service: 'Accessory Drive Belt',
        intervalKm: 240000,
        grade: OemGrade.a,
        source: 'Dodge Durango 2020 Owner Manual (Mopar US)',
        notes: 'Replace at 150,000 mi (240,000 km).',
      ),
      OemInterval(
        service: 'Front/Rear Axle Fluid',
        intervalKm: 64000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'Dodge Durango 2020 Owner Manual (Mopar US)',
        notes:
            'SEVERE only (police/taxi/fleet/off-road/towing): change every '
            '40,000 mi (X at 40/80/120k).',
      ),
    ],
  ),

  OemSchedule(
    make: 'Jeep',
    model: 'Grand Cherokee (WK)',
    yearStart: 2014,
    yearEnd: 2021,
    engine: '3.6L V6 Pentastar / 5.7L V8 HEMI',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Jeep Grand Cherokee 2021 Owner Manual (Mopar US)',
        notes: 'Oil Change Indicator; cap 10,000 mi (16,000 km)/12 mo. conditionBased.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 160000,
        grade: OemGrade.a,
        source: 'Jeep Grand Cherokee 2021 Owner Manual (Mopar US)',
        notes: '100,000 mi. Mileage-based only.',
      ),
      OemInterval(
        service: 'Engine Air Cleaner Filter',
        intervalKm: 48000,
        grade: OemGrade.a,
        source: 'Jeep Grand Cherokee 2021 Owner Manual (Mopar US)',
        notes: 'Replace every 30,000 mi (X at 30/60/90/120/150k).',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 32000,
        grade: OemGrade.a,
        source: 'Jeep Grand Cherokee 2021 Owner Manual (Mopar US)',
        notes: 'Replace every 20,000 mi (X at 20/40/60/80/100/120/140k).',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 240000,
        intervalMonths: 120,
        grade: OemGrade.a,
        source: 'Jeep Grand Cherokee 2021 Owner Manual (Mopar US)',
        notes: 'Flush & replace at 10 years or 150,000 mi (240,000 km).',
      ),
    ],
  ),

  // Jeep Wrangler — spark-plug interval differs by engine, so two sourced rows.
  OemSchedule(
    make: 'Jeep',
    model: 'Wrangler (JL)',
    yearStart: 2018,
    yearEnd: 2024,
    engine: '2.0L Turbo I4 (GME-T4) / 3.6L V6 Pentastar',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Jeep Wrangler 2023 Owner Manual (Mopar US)',
        notes: 'Oil Change Indicator; cap 10,000 mi (16,000 km)/12 mo. conditionBased.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 96000,
        grade: OemGrade.a,
        source: 'Jeep Wrangler 2023 Owner Manual (Mopar US)',
        notes:
            '2.0L Turbo engine: every 60,000 mi (96,000 km) (X at 60k & 120k). '
            'Mileage-based only. Separate from the 3.6L V6 row below.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 160000,
        grade: OemGrade.a,
        source: 'Jeep Wrangler 2023 Owner Manual (Mopar US)',
        notes:
            '3.6L V6 engine: every 100,000 mi (160,000 km) (X at 100k). '
            'Mileage-based only.',
      ),
      OemInterval(
        service: 'Engine Air Cleaner Filter',
        intervalKm: 48000,
        grade: OemGrade.a,
        source: 'Jeep Wrangler 2023 Owner Manual (Mopar US)',
        notes: 'Replace every 30,000 mi (X at 30/60/90/120/150k).',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 19000,
        grade: OemGrade.a,
        source: 'Jeep Wrangler 2023 Owner Manual (Mopar US)',
        notes: 'Printed verbatim: "To be replaced every 12,000 miles (19,000 km)".',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 240000,
        intervalMonths: 120,
        grade: OemGrade.a,
        source: 'Jeep Wrangler 2023 Owner Manual (Mopar US)',
        notes: 'Flush & replace engine/intercooler coolant at 10 yr or 150,000 mi.',
      ),
      OemInterval(
        service: 'Transfer Case Fluid',
        intervalKm: 96000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'Jeep Wrangler 2023 Owner Manual (Mopar US)',
        notes:
            'SEVERE only (police/taxi/fleet/towing): change at 60k & 120,000 mi.',
      ),
      OemInterval(
        service: 'Front/Rear Axle Fluid',
        intervalKm: 64000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'Jeep Wrangler 2023 Owner Manual (Mopar US)',
        notes:
            'SEVERE only (police/taxi/fleet/off-road/towing): every 40,000 mi '
            '(X at 40/80/120k).',
      ),
    ],
  ),

  OemSchedule(
    make: 'Jeep',
    model: 'Compass (MP)',
    yearStart: 2022,
    yearEnd: 2024,
    engine: '2.0L Turbo I4 (GME-T4)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Jeep Compass 2023 Owner Manual (Mopar US)',
        notes: 'Oil Change Indicator; cap 10,000 mi (16,000 km)/12 mo. conditionBased.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 96000,
        grade: OemGrade.a,
        source: 'Jeep Compass 2023 Owner Manual (Mopar US)',
        notes: 'Every 60,000 mi (96,000 km) (X at 60k & 120k). Mileage-based only.',
      ),
      OemInterval(
        service: 'Engine Air Cleaner Filter',
        intervalKm: 48000,
        grade: OemGrade.a,
        source: 'Jeep Compass 2023 Owner Manual (Mopar US)',
        notes: 'Replace every 30,000 mi (X at 30/60/90/120/150k).',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 19000,
        grade: OemGrade.a,
        source: 'Jeep Compass 2023 Owner Manual (Mopar US)',
        notes: 'Printed verbatim: "To be replaced every 12,000 miles (19,000 km)".',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 240000,
        intervalMonths: 120,
        grade: OemGrade.a,
        source: 'Jeep Compass 2023 Owner Manual (Mopar US)',
        notes: 'Flush & replace at 10 years or 150,000 mi (240,000 km).',
      ),
    ],
  ),

  // Jeep Cherokee — three engines; spark-plug interval differs, two sourced rows.
  OemSchedule(
    make: 'Jeep',
    model: 'Cherokee (KL)',
    yearStart: 2019,
    yearEnd: 2023,
    engine: '2.0L Turbo I4 / 2.4L Tigershark I4 / 3.2L V6 Pentastar',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Jeep Cherokee 2020 Owner Manual (Mopar US)',
        notes: 'Oil Change Indicator; cap 10,000 mi (16,000 km)/12 mo. conditionBased.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 96000,
        grade: OemGrade.a,
        source: 'Jeep Cherokee 2020 Owner Manual (Mopar US)',
        notes:
            '2.0L Turbo engine: every 60,000 mi (96,000 km) (X at 60k & 120k). '
            'Mileage-based only. Separate from the 2.4L/3.2L row below.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 160000,
        grade: OemGrade.a,
        source: 'Jeep Cherokee 2020 Owner Manual (Mopar US)',
        notes:
            '2.4L & 3.2L engines: every 100,000 mi (160,000 km) (X at 100k). '
            'Mileage-based only.',
      ),
      OemInterval(
        service: 'Engine Air Cleaner Filter',
        intervalKm: 48000,
        grade: OemGrade.a,
        source: 'Jeep Cherokee 2020 Owner Manual (Mopar US)',
        notes: 'Replace every 30,000 mi (X at 30/60/90/120/150k).',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 32000,
        grade: OemGrade.a,
        source: 'Jeep Cherokee 2020 Owner Manual (Mopar US)',
        notes:
            'Air-conditioning/cabin filter every 20,000 mi '
            '(X at 20/40/60/80/100/120/140k).',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 240000,
        intervalMonths: 120,
        grade: OemGrade.a,
        source: 'Jeep Cherokee 2020 Owner Manual (Mopar US)',
        notes: 'Flush & replace at 10 years or 150,000 mi (240,000 km).',
      ),
    ],
  ),

  // ==========================================================================
  // MINI — Condition Based Service (CBS), from the official MINI USA maintenance
  // booklet. The booklet ties each item to a specific engine-oil-service count,
  // which it converts to an approximate mileage. Covers all current models
  // (Cooper 3-cyl 1.5T B38, Cooper S / JCW 2.0T B48); spark plugs are stated
  // "(all models)". conditionBased: the CBS counter sets the actual due point.
  // ==========================================================================
  OemSchedule(
    make: 'MINI',
    model: 'Cooper / Cooper S / JCW (all models)',
    yearStart: 2022,
    yearEnd: 2025,
    engine: '1.5L Turbo I3 (B38) / 2.0L Turbo I4 (B48), CBS',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        grade: OemGrade.b,
        source: 'MINI MY2025 / 2022 Maintenance Booklet (MINI USA)',
        notes:
            'CBS: "As specified by CBS". Booklet CBS-display illustration shows '
            'an oil service at ~10,000 mi; stored 16,000 km as the baseline. '
            'conditionBased — the CBS counter sets the actual due point.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 96000,
        grade: OemGrade.a,
        source: 'MINI MY2025 / 2022 Maintenance Booklet (MINI USA)',
        notes:
            'Printed verbatim: "At every 6th Engine Oil Service: Spark plugs: '
            'Replace (approximately 60,000 miles)" — all models.',
      ),
      OemInterval(
        service: 'Engine Air Filter (Intake Air Cleaner)',
        intervalKm: 64000,
        grade: OemGrade.a,
        source: 'MINI MY2025 / 2022 Maintenance Booklet (MINI USA)',
        notes:
            'Printed verbatim: "At every 4th Engine Oil Service ... '
            '(approximately 40,000 miles)".',
      ),
      OemInterval(
        service: 'Engine Air Filter (Intake Air Cleaner)',
        intervalKm: 64000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'MINI MY2025 / 2022 Maintenance Booklet (MINI USA)',
        notes:
            'SEVERE: booklet says "reduce replacement interval in dusty '
            'operating conditions" (no separate number given) — Lebanon dust '
            'means replace sooner than the 40,000 mi normal step.',
      ),
      OemInterval(
        service: 'Cabin Microfilter',
        intervalKm: 32000,
        grade: OemGrade.a,
        source: 'MINI MY2025 / 2022 Maintenance Booklet (MINI USA)',
        notes:
            'Ventilation microfilter "At every 2nd Engine Oil Service" '
            '(~20,000 mi / 32,000 km).',
      ),
      OemInterval(
        service: 'Oxygen Sensor',
        intervalKm: 240000,
        grade: OemGrade.a,
        source: 'MINI MY2025 / 2022 Maintenance Booklet (MINI USA)',
        notes: 'Emission-control oxygen sensor: 150,000 mi (all MINI models).',
      ),
      OemInterval(
        service: 'Brake Fluid',
        grade: OemGrade.b,
        source: 'MINI MY2025 / 2022 Maintenance Booklet (MINI USA)',
        notes:
            'TIME-based via CBS: booklet states "Replace brake fluid (as shown '
            'in CBS)" and tracks it by date, but prints NO fixed months/mileage. '
            'No number recorded (BMW-group CBS brake fluid is conventionally '
            '~2 yr, but that figure is not in this document).',
      ),
    ],
  ),

  // ==========================================================================
  // VOLVO — official "Schedule of Factory Maintenance Service Operations",
  // 2025 PHEV/MHEV models: S60, S90, V60, V60CC, V90, V90CC, XC40, XC60, XC90
  // (B5/B6 mild-hybrid petrol + T8 PHEV). Fixed Service Reminder Indicator,
  // 10,000 mi / 1 yr, then a fixed-mileage table for the longer items. Grade A
  // throughout (read from the official sheet). Source: Volvo Warranty and
  // Service Records Information.
  // ==========================================================================
  OemSchedule(
    make: 'Volvo',
    model: 'XC40 / XC60 / XC90 / S60 / S90 (and V60/V90)',
    yearStart: 2020,
    yearEnd: 2025,
    engine: 'B5 / B6 mild-hybrid petrol (+ T8 PHEV)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Volvo 2025 Factory Scheduled Maintenance (PHEV/MHEV)',
        notes:
            'Replace every 10,000 mi or 1 year, whichever first. Full-synthetic '
            'ACEA A5/B5 oil only. Fixed SRI (reset at each service).',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 36,
        grade: OemGrade.a,
        source: 'Volvo 2025 Factory Scheduled Maintenance (PHEV/MHEV)',
        notes:
            'Replace every 3 years. SEVERE note printed on the same line: '
            '"if driven in mountainous areas or humid climates — every year".',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 12,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'Volvo 2025 Factory Scheduled Maintenance (PHEV/MHEV)',
        notes: 'SEVERE (mountainous/humid): every year, per the sheet.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 32000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Volvo 2025 Factory Scheduled Maintenance (PHEV/MHEV)',
        notes:
            'Replace every 20,000 mi (32,000 km). Sheet: "replaced at least '
            'once a year or more often in heavy traffic and dirty/dusty areas" '
            '(severe note).',
      ),
      OemInterval(
        service: 'Engine Air Cleaner (ACL) Filter',
        intervalKm: 64000,
        grade: OemGrade.a,
        source: 'Volvo 2025 Factory Scheduled Maintenance (PHEV/MHEV)',
        notes:
            'Replace every 40,000 mi (64,000 km). "May be necessary to change '
            'more frequently when driving in dusty/dirty areas" (severe note).',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 96000,
        grade: OemGrade.a,
        source: 'Volvo 2025 Factory Scheduled Maintenance (PHEV/MHEV)',
        notes: 'Replace every 60,000 mi (96,000 km).',
      ),
      OemInterval(
        service: 'Accessory Drive Belt',
        intervalKm: 128000,
        grade: OemGrade.a,
        source: 'Volvo 2025 Factory Scheduled Maintenance (PHEV/MHEV)',
        notes:
            'Replace at 80,000 mi (128,000 km). Belt tensioner + idler pulley '
            'replaced later, at 150,000 mi (240,000 km).',
      ),
      OemInterval(
        service: 'Timing Belt, Tensioner & Idler Pulley',
        intervalKm: 240000,
        intervalMonths: 120,
        grade: OemGrade.a,
        source: 'Volvo 2025 Factory Scheduled Maintenance (PHEV/MHEV)',
        notes:
            'Replace at 150,000 mi (240,000 km) or 10 years, whichever first. '
            '(Volvo VEA engines use a wet timing belt — a real replacement item, '
            'unlike the chain-driven German/Japanese engines.) Water-pump belt '
            'shares the same 150,000 mi / 10 yr interval.',
      ),
    ],
  ),

  // ==========================================================================
  // LAND ROVER — Range Rover / Sport / Evoque / Discovery / Defender (petrol).
  // The vehicle uses a VARIABLE Service Interval Indicator (distance-to-service
  // OR days-remaining shown on the odometer), so NO single fixed odometer figure
  // is published for the oil/service item — omitted honestly, conditionBased.
  // Coolant read directly from the Land Rover owner's-handbook "Maintenance"
  // section (Grade A). Brake fluid is time-based (the handbook confirms the
  // mechanism and the Passport-to-Service records it); the concrete 3-year
  // figure is corroborated across the JLR owner-guide family (Grade B).
  // "Arduous conditions" = severe (Lebanon).
  // ==========================================================================
  OemSchedule(
    make: 'Land Rover',
    model: 'Range Rover / Sport / Evoque / Discovery / Defender',
    yearStart: 2013,
    yearEnd: 2024,
    engine: 'Petrol (variable Service Interval Indicator)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Coolant',
        intervalMonths: 120,
        grade: OemGrade.a,
        source: 'Land Rover Owner Handbook — Maintenance (JLR Topix)',
        notes:
            'Printed verbatim: anti-corrosion checked once a year and coolant '
            '"completely renewed every ten years, regardless of distance".',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 36,
        grade: OemGrade.b,
        source: 'Land Rover Owner Handbook — Maintenance (JLR Topix)',
        notes:
            'TIME-based. The opened handbook confirms the brake-fluid change is '
            'time-driven and recorded in the Passport to Service. The concrete '
            'figure — every 3 years (Range Rover/Sport/Discovery/Evoque) — is '
            'corroborated across the JLR owner-guide family (Grade B). EXCEPTION: '
            'Defender every 2 years / 24,000 mi (40,000 km).',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalKm: 40000,
        intervalMonths: 24,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Land Rover Owner Handbook — Maintenance (JLR Topix)',
        notes:
            'DEFENDER variant: every 2 years or 24,000 mi (40,000 km), '
            'whichever first (JLR owner-guide family). Also captures the shorter '
            'end for severe use.',
      ),
    ],
  ),
];
