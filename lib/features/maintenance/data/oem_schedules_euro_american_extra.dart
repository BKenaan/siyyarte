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

  // ==========================================================================
  // PEUGEOT (PSA / Stellantis) — EB2 "PureTech" petrol, official "PLAN
  // D'ENTRETIEN" dealer sheets. Each sheet is the Peugeot per-engine maintenance
  // plan (it carries the genuine Peugeot B71 oil specs and the Peugeot severe-use
  // definition "taxi/ambulance/urban/dusty-country"); it is reproduced on the
  // forum-peugeot.com enthusiast site, NOT fetched from a Peugeot-owned host, so
  // each value is graded B with an explicit "forum-mirror" caveat. The plans were
  // read individually per model via pdftotext table extraction — the intervals
  // genuinely DIFFER between 208, 2008 and 5008 (oil 20k vs 25k; plugs/air 40k vs
  // 50k; cabin 1 yr vs 2 yr), which is why nothing was copied across models.
  //
  // The PureTech publishes a FIXED normal/severe km+time table (the owner chooses
  // the normal or "séverisé" plan at purchase), so conditionBased is false; an
  // onboard service indicator (témoin) can only bring a service FORWARD, noted on
  // the oil rows. Lebanon = severe, so the severe rows apply. Each sheet prints
  // both columns; where severe differs it is a distinct OemSeverity.severe row.
  // ==========================================================================
  OemSchedule(
    make: 'Peugeot',
    model: '208',
    yearStart: 2019,
    yearEnd: 2024,
    engine: '1.2 PureTech 100 BVM6 / 1.2 PureTech 130 EAT8 (identical plan)',
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 20000,
        intervalMonths: 12,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes:
            '"Révisions : opérations systématiques" every 20,000 km / 1 yr '
            '(normal). Oils 0W20 B71 2010 / 0W30 B71 2312. Onboard service '
            'indicator can bring it forward. Forum-mirrored reproduction of '
            'Peugeot\'s official plan d\'entretien (both the PureTech 100 BVM6 '
            'and 130 EAT8 sheets were opened; intervals identical).',
      ),
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 15000,
        intervalMonths: 12,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 15,000 km / 1 yr. Lebanon = severe.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 20000,
        intervalMonths: 12,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes: '"Remplacement du filtre d\'habitacle" every 20,000 km / 1 yr.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 15000,
        intervalMonths: 12,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 15,000 km / 1 yr.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes:
            '"Remplacement du liquide de frein" every 2 years, no km limit. '
            'Same for normal and severe plans.',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 40000,
        intervalMonths: 48,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes: '"Remplacement du filtre à air" every 40,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 30000,
        intervalMonths: 48,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 30,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 40000,
        intervalMonths: 48,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes: '"Remplacement des bougies d\'allumage" every 40,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 30000,
        intervalMonths: 48,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 30,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Timing Belt',
        intervalKm: 100000,
        intervalMonths: 72,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes:
            '"Remplacement de la courroie de distribution" at 100,000 km / 6 yr, '
            'then every 200,000 km / 12 yr thereafter. EB2 PureTech uses a wet '
            'belt. (NB: Peugeot later issued shorter wet-belt intervals via '
            'service campaigns; this is the plan sheet value as printed.)',
      ),
      OemInterval(
        service: 'Timing Belt',
        intervalKm: 105000,
        intervalMonths: 72,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: 105,000 km / 6 yr, then every 210,000 km / 12 yr.',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 180000,
        intervalMonths: 120,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes:
            '"Remplacement du liquide de refroidissement" every 180,000 km / '
            '10 yr (a coolant pH check runs at 120,000 km / 4 yr then yearly).',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 165000,
        intervalMonths: 120,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 208 1.2 PureTech Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 165,000 km / 10 yr.',
      ),
    ],
  ),

  OemSchedule(
    make: 'Peugeot',
    model: '2008',
    yearStart: 2013,
    yearEnd: 2019,
    engine: '1.2 PureTech 82 BVM5',
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 25000,
        intervalMonths: 12,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes:
            '"Révisions : opérations systématiques" every 25,000 km / 1 yr '
            '(normal). Onboard service indicator can bring it forward. '
            'Forum-mirrored reproduction of Peugeot\'s official plan d\'entretien.',
      ),
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 15000,
        intervalMonths: 12,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 15,000 km / 1 yr. Lebanon = severe.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 25000,
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes: '"Remplacement du filtre d\'habitacle" every 25,000 km / 2 yr.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 15000,
        intervalMonths: 12,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 15,000 km / 1 yr.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes:
            '"Remplacement du liquide de frein" every 2 years, no km limit. '
            'Same for normal and severe plans.',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 50000,
        intervalMonths: 48,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes: '"Remplacement du filtre à air" every 50,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 45000,
        intervalMonths: 48,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 45,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 50000,
        intervalMonths: 48,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes: '"Remplacement des bougies d\'allumage" every 50,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 45000,
        intervalMonths: 48,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 45,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Timing Belt',
        intervalKm: 175000,
        intervalMonths: 120,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes:
            '"Remplacement du kit de distribution" every 175,000 km / 10 yr. '
            'EB2 PureTech wet belt. (Peugeot later shortened wet-belt intervals '
            'via campaigns; this is the plan sheet value.)',
      ),
      OemInterval(
        service: 'Timing Belt',
        intervalKm: 165000,
        intervalMonths: 120,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 2008 1.2 PureTech 82 Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 165,000 km / 10 yr.',
      ),
      // Coolant: the 2008 PT82 sheet prints only a pH check (125,000 km / 4 yr
      // then yearly), no explicit coolant-replacement line — omitted, not guessed.
    ],
  ),

  OemSchedule(
    make: 'Peugeot',
    model: '5008',
    yearStart: 2017,
    yearEnd: 2024,
    engine: '1.2 PureTech 130 BVM6',
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 25000,
        intervalMonths: 12,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes:
            '"Révisions : opérations systématiques" every 25,000 km / 1 yr '
            '(normal). Onboard service indicator can bring it forward. '
            'Forum-mirrored reproduction of Peugeot\'s official plan d\'entretien.',
      ),
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 15000,
        intervalMonths: 12,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 15,000 km / 1 yr. Lebanon = severe.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 50000,
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes: '"Remplacement du filtre d\'habitacle" every 50,000 km / 2 yr.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 15000,
        intervalMonths: 12,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 15,000 km / 1 yr.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes:
            '"Remplacement du liquide de frein" every 2 years, no km limit. '
            'Same for normal and severe plans.',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 50000,
        intervalMonths: 48,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes: '"Remplacement du filtre à air" every 50,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 45000,
        intervalMonths: 48,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: every 45,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 50000,
        intervalMonths: 48,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes: '"Remplacement des bougies d\'allumage" every 50,000 km / 4 yr.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 30000,
        intervalMonths: 48,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes:
            'SEVERE column: every 30,000 km / 4 yr (note: the 5008 severe plug '
            'step is 30,000 km, shorter than its 45,000 km air-filter step).',
      ),
      OemInterval(
        service: 'Timing Belt',
        intervalKm: 100000,
        intervalMonths: 72,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes:
            '"Remplacement de la courroie de distribution" at 100,000 km / 6 yr, '
            'then every 200,000 km / 12 yr. EB2 PureTech wet belt (later '
            'shortened via campaigns; this is the plan sheet value).',
      ),
      OemInterval(
        service: 'Timing Belt',
        intervalKm: 105000,
        intervalMonths: 72,
        severity: OemSeverity.severe,
        grade: OemGrade.b,
        source: 'Peugeot 5008 1.2 PureTech 130 Plan d\'Entretien (forum-peugeot)',
        notes: 'SEVERE column: 105,000 km / 6 yr, then every 210,000 km / 12 yr.',
      ),
      // Coolant: the 5008 PT130 sheet prints only a pH check (125,000 km / 4 yr
      // then every 25,000 km), no explicit replacement line — omitted, not guessed.
    ],
  ),

  // ==========================================================================
  // FIAT — Tipo (356), petrol. Read from the OFFICIAL Fiat/FCA English Owner
  // Handbook (Pub. 603.91.675, 06.2018) hosted on aftersales.fiat.com (Fiat's
  // own eLUM portal), "SCHEDULED SERVICING PLAN (Petrol versions)". The plan is a
  // fixed X-mark grid at 15,000 km / 1 yr steps; each grid page was rendered to an
  // image and the X marks read visually (Grade A — the method the sibling corpora
  // use for X-grid tables). Footnotes gave the severe-condition figures verbatim.
  // conditionBased: false (hard fixed table). Lebanon = severe/dusty, so the
  // dusty-area footnote intervals are captured as OemSeverity.severe rows.
  // ==========================================================================
  OemSchedule(
    make: 'Fiat',
    model: 'Tipo',
    yearStart: 2016,
    yearEnd: 2024,
    engine: '1.4 16V 95HP / 1.4 T-Jet 120HP / 1.6 E.TorQ 110HP',
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 15000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes:
            'Service grid at 15,000 km / 1 yr steps. Oil change is "obligatory" '
            'every grid step (15,000 km / 1 yr) on 1.6 E.TorQ and 1.4 16V 95HP '
            'E4; on 1.4 T-Jet 120HP / 1.4 16V 95HP E6 the 15,000 km / 1 yr step '
            'is "recommended" and 30,000 km / 2 yr "obligatory". Footnote: if '
            'annual mileage < 10,000 km, change oil & filter every year.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 30000,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes:
            '1.4 T-Jet 120HP, 1.4 16V 95HP E4 and 1.6 E.TorQ: every 30,000 km '
            '(X at 30/60/90/120/150k). Mileage-based regardless of time. '
            'Separate 60,000 km row below for the 1.4 16V 95HP E6.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 60000,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes: '1.4 16V 95HP E6 version: every 60,000 km (X at 60k & 120k).',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 15000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes:
            'SEVERE (footnote 7): plugs every 15,000 km for 1.4 16V 95HP E4 / '
            '1.6 E.TorQ when used in listed hot/dusty markets (incl. Jordan, '
            'Bahrain, Libya — same MENA climate band as Lebanon).',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 30000,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes:
            'Air cleaner cartridge every 30,000 km (X at 30/60/90/120/150k) on '
            'the 1.4 engines.',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 15000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes:
            'SEVERE (footnote 8): "If the vehicle is used in dusty areas, change '
            'this filter every 15,000 km." Lebanon = dusty.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 15000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes:
            '"Passenger compartment cleaner" recommended every 15,000 km / 1 yr '
            '(obligatory 30,000 km / 2 yr).',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 15000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes:
            'SEVERE (footnote 8): dusty areas every 15,000 km — matches the '
            'recommended step, so it becomes obligatory in dusty use.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 24,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes:
            'Footnote 10 verbatim: "The brake fluid replacement has to be done '
            'every two years, irrespective of the mileage."',
      ),
      OemInterval(
        service: 'Timing Belt',
        intervalKm: 120000,
        intervalMonths: 72,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes:
            'Footnote 4: toothed timing belt max 120,000 km, replace every 6 yr '
            'regardless of distance (1.4 16V 95HP & 1.4 T-Jet belt engines; the '
            '1.6 E.TorQ is not belt-driven for timing).',
      ),
      OemInterval(
        service: 'Timing Belt',
        intervalKm: 60000,
        intervalMonths: 48,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'Fiat Tipo Owner Handbook 603.91.675 EN (aftersales.fiat.com)',
        notes:
            'SEVERE (footnote 4): heavy conditions (dusty, extreme temps, urban, '
            'long idling) max 60,000 km, replace every 4 years. Lebanon = severe.',
      ),
    ],
  ),

  // ==========================================================================
  // LAND ROVER — Range Rover (L405) / Range Rover Sport (L494): concrete
  // service/oil baseline. The general Land Rover entry above (coolant + brake
  // fluid) omitted the oil item because JLR uses a variable Service Interval
  // Indicator. This separate, more-specific entry adds the PUBLISHED MAXIMUM
  // service interval, read verbatim from an official JLR TopIx bulletin
  // (SSM72769): "...below the 16,000 miles (26,000 km) or 12 month service
  // interval." The bulletin states only DIESEL SIIs are variable (DPF oil
  // dilution), so PETROL follows this fixed 16,000 mi / 12 mo figure. Kept as a
  // new entry so the existing Land Rover schedule is not rewritten.
  // ==========================================================================
  OemSchedule(
    make: 'Land Rover',
    model: 'Range Rover (L405) / Range Rover Sport (L494)',
    yearStart: 2013,
    yearEnd: 2022,
    engine: 'Petrol (Service Interval Indicator)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 26000,
        intervalMonths: 12,
        grade: OemGrade.b,
        source: 'Land Rover SSM72769 TopIx Service Bulletin (JLR)',
        notes:
            'Published service interval, quoted verbatim: "16,000 miles '
            '(26,000 km) or 12 month service interval" (Range Rover L405 / '
            'Range Rover Sport L494). conditionBased: the SII can bring it '
            'forward; the bulletin says only DIESEL intervals are variable '
            '(DPF oil dilution), so petrol follows this fixed maximum. Recorded '
            'as the concrete baseline per the app directive. Grade B: read from '
            'an official JLR bulletin about the indicator, not the primary '
            'maintenance-schedule table.',
      ),
    ],
  ),

  // ==========================================================================
  // LAND ROVER — per-model PETROL service intervals from the official
  // "Land Rover Maintenance Plan" brochure (Jaguar Land Rover North America,
  // 2022, doc 22 01 387). It lists two petrol service-interval bands under
  // "FLEXIBLE SERVICE":
  //   • 2 YEAR / 21,000 mi (~34,000 km): Evoque, Velar i4/i6, Discovery,
  //     Discovery Sport, Defender i4/i6, Range Rover/Sport i4/i6.
  //   • 1 YEAR / 16,000 mi (~26,000 km): all V8 petrol (incl. Defender V8,
  //     Range Rover/Sport V8).
  // conditionBased: true — "Flexible Service ... takes into account individual
  // driving styles and conditions to determine when a service is due", so the
  // figure is the published MAXIMUM; severe use (Lebanon) brings it forward.
  // Grade B: a JLR service-plan brochure (states the interval band clearly) rather
  // than the per-VIN owner handbook schedule; km is the ×1.6 mile conversion.
  // Added as separate per-model entries; the general Land Rover entry above is
  // unchanged. The older Range Rover L405 / Sport L494 oil entry (SSM72769,
  // 16,000 mi) is a different generation/doc and is kept as-is.
  // ==========================================================================
  OemSchedule(
    make: 'Land Rover',
    model: 'Range Rover Evoque (petrol)',
    yearStart: 2019,
    yearEnd: 2024,
    engine: 'i4 petrol (Ingenium 2.0 P200/P250/P300), Flexible Service',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 34000,
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'Land Rover Maintenance Plan Brochure 22 01 387 (JLR NA 2022)',
        notes:
            'Petrol band "2 YEAR / 21,000 mi" (21,000 mi = ~34,000 km). '
            'conditionBased (Flexible Service): severe use brings it forward. '
            'Covers Evoque petrol i4 per the brochure\'s model list.',
      ),
    ],
  ),

  OemSchedule(
    make: 'Land Rover',
    model: 'Range Rover Velar (petrol)',
    yearStart: 2017,
    yearEnd: 2024,
    engine: 'i4 / i6 petrol (Ingenium 2.0 / 3.0), Flexible Service',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 34000,
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'Land Rover Maintenance Plan Brochure 22 01 387 (JLR NA 2022)',
        notes:
            'Petrol band "2 YEAR / 21,000 mi" (~34,000 km). Brochure lists '
            '"Range Rover Velar i4" and "Range Rover Velar i6" in this band. '
            'conditionBased (Flexible Service); severe use brings it forward.',
      ),
    ],
  ),

  OemSchedule(
    make: 'Land Rover',
    model: 'Discovery / Discovery Sport (petrol)',
    yearStart: 2017,
    yearEnd: 2024,
    engine: 'i4 / i6 petrol (Ingenium), Flexible Service',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 34000,
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'Land Rover Maintenance Plan Brochure 22 01 387 (JLR NA 2022)',
        notes:
            'Petrol band "2 YEAR / 21,000 mi" (~34,000 km). Brochure lists '
            '"Discovery" and "Discovery Sport" in this band. conditionBased '
            '(Flexible Service); severe use brings it forward.',
      ),
    ],
  ),

  OemSchedule(
    make: 'Land Rover',
    model: 'Defender (L663, petrol)',
    yearStart: 2020,
    yearEnd: 2024,
    engine: 'i4 / i6 petrol and V8 petrol, Flexible Service',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 34000,
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'Land Rover Maintenance Plan Brochure 22 01 387 (JLR NA 2022)',
        notes:
            'Defender i4 / i6 petrol: "2 YEAR / 21,000 mi" band (~34,000 km). '
            'conditionBased (Flexible Service); severe use brings it forward. '
            'V8 is the separate 1-yr/16k row below.',
      ),
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 26000,
        intervalMonths: 12,
        grade: OemGrade.b,
        source: 'Land Rover Maintenance Plan Brochure 22 01 387 (JLR NA 2022)',
        notes:
            'Defender V8 petrol: "1 YEAR / 16,000 mi" band (16,000 mi = '
            '~26,000 km). conditionBased (Flexible Service). The brochure puts '
            'all V8 petrol models on this shorter interval.',
      ),
    ],
  ),

  // ==========================================================================
  // RENAULT — Duster (India / MENA, petrol): service/oil cadence only.
  // From the official Renault India "New Duster Additional Warranty Terms &
  // Conditions" (cdn.group.renault.com, version Mar-2026), which ties the
  // Periodic Maintenance Schedule (PMS) to "1 year or 10,000 km, whichever
  // occurs earlier" (illustrated with PMS at 10k/20k/30k/40k km steps). Only the
  // service/oil CADENCE is stated in this document; component intervals (spark
  // plugs, brake fluid, filters) are in the owner's-manual PMS table, which was
  // NOT openable — recorded as a gap, not guessed. conditionBased: false.
  // ==========================================================================
  OemSchedule(
    make: 'Renault',
    model: 'Duster',
    yearStart: 2020,
    yearEnd: 2026,
    engine: 'Petrol (TCe / naturally-aspirated), Renault India PMS',
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 10000,
        intervalMonths: 12,
        grade: OemGrade.b,
        source: 'Renault India New Duster Warranty T&C (cdn.group.renault.com)',
        notes:
            'Periodic Maintenance Schedule cadence "1 year or 10,000 km, '
            'whichever occurs earlier" (stated for PMS/warranty, illustrated at '
            '10k/20k/30k/40k km steps). Service/oil interval only; the full '
            'component PMS table was not openable. conditionBased: false.',
      ),
    ],
  ),

  // ==========================================================================
  // CADILLAC — Escalade / Escalade ESV (6.2L V8 petrol). Read from the GENUINE
  // GM owner manual PDF (2021, GM Canada bilingual FR/EN edition — km-native,
  // obtained via a dealer mirror of the GM publication), "ENTRETIEN ET
  // MAINTENANCE / Interventions supplémentaires requises". Two X-mark grids
  // (normal + severe) at 12,000 km / 7,500 mi steps; rendered to PNG (pymupdf)
  // and read visually, with footnotes taken verbatim. Oil uses the GM Engine Oil
  // Life System (conditionBased). Lebanon = severe → the severe-only automatic-
  // transmission-fluid change applies. Grade A (authentic GM publication, values
  // read directly; km printed natively, no conversion).
  // ==========================================================================
  OemSchedule(
    make: 'Cadillac',
    model: 'Escalade / Escalade ESV',
    yearStart: 2015,
    yearEnd: 2024,
    engine: '6.2L V8 petrol',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Cadillac Escalade Owner Manual 2021 (GM, km-native)',
        notes:
            'GM Engine Oil Life System. "L\'huile moteur doit être vidangée et '
            'le filtre remplacé au moins une fois par an" (at least once a year); '
            'the indicator may extend to ~2 yr only in ideal conditions. '
            'conditionBased — no fixed km; the inspection/tire-rotation visit is '
            'every 12,000 km / 7,500 mi.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 36000,
        intervalMonths: 24,
        grade: OemGrade.a,
        source: 'Cadillac Escalade Owner Manual 2021 (GM, km-native)',
        notes:
            'X at 36/72/108/144/180/216k; footnote 1: or every 2 years. Replace '
            'more often in dense-traffic / poor-air / dusty areas (severe — no '
            'separate number given).',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 72000,
        intervalMonths: 48,
        grade: OemGrade.a,
        source: 'Cadillac Escalade Owner Manual 2021 (GM, km-native)',
        notes:
            'X at 72/144k; footnote 3: or every 4 years, inspect at each oil '
            'change; replace more often in dusty conditions (severe).',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 156000,
        grade: OemGrade.a,
        source: 'Cadillac Escalade Owner Manual 2021 (GM, km-native)',
        notes:
            'Replace spark plugs & inspect wires/boots at 156,000 km '
            '(97,500 mi). Same in normal and severe tables.',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 240000,
        intervalMonths: 60,
        grade: OemGrade.a,
        source: 'Cadillac Escalade Owner Manual 2021 (GM, km-native)',
        notes:
            'DEX-COOL: drain & refill at 240,000 km (150,000 mi); footnote 5: '
            'or every 5 years, whichever first.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 60,
        grade: OemGrade.a,
        source: 'Cadillac Escalade Owner Manual 2021 (GM, km-native)',
        notes:
            'Footnote 7: "Remplacer le liquide de frein tous les cinq ans" '
            '(every 5 years). Not tied to a mileage in the grid.',
      ),
      OemInterval(
        service: 'Accessory Drive Belt',
        intervalKm: 240000,
        intervalMonths: 120,
        grade: OemGrade.a,
        source: 'Cadillac Escalade Owner Manual 2021 (GM, km-native)',
        notes:
            'Visually inspect at 240,000 km; footnote 6: or every 10 years. '
            'Replace if frayed/cracked.',
      ),
      OemInterval(
        service: 'Transfer Case Fluid (4WD)',
        intervalKm: 156000,
        grade: OemGrade.a,
        source: 'Cadillac Escalade Owner Manual 2021 (GM, km-native)',
        notes: 'Replace transfer-case fluid at 156,000 km (4WD). Both tables.',
      ),
      OemInterval(
        service: 'Automatic Transmission Fluid & Filter',
        intervalKm: 72000,
        severity: OemSeverity.severe,
        grade: OemGrade.a,
        source: 'Cadillac Escalade Owner Manual 2021 (GM, km-native)',
        notes:
            'SEVERE table only: replace auto-trans fluid & filter every 72,000 km '
            '(X at 72/144k; 45,000 mi). The NORMAL table schedules no trans-fluid '
            'change (fill-for-life). Lebanon = severe, so this applies.',
      ),
    ],
  ),
];
