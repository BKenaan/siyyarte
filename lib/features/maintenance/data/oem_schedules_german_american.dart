// OEM maintenance schedules — German & American makes.
//
// RESEARCH DATA ONLY. This file is a sourced, structured corpus gathered from
// real manufacturer maintenance documents. It is intentionally NOT wired into
// the engine (see maintenance_engine.dart) or the rule set
// (maintenance_rule.dart); integration is reviewed separately.
//
// Discipline (mirrors the `verified_specs` system in lib/features/specs/ and
// data_backend/): the GOLDEN RULE is never show an unverified number. Every
// [OemInterval] below carries a real source string (full URLs live in the
// companion file oem_schedules_german_american_SOURCES.md) and a confidence
// [OemGrade] A–D. Values that could not be sourced were OMITTED and are
// recorded as gaps in the SOURCES file — nothing here is invented or guessed.
//
// Units: intervals are stored in KILOMETRES. Manufacturer docs for these makes
// publish in MILES; miles were converted at the repo's standard 1.6 factor
// (10k mi = 16,000 km, 60k mi = 96,000 km, 100k mi = 160,000 km, etc.), the
// same convention already used in data_backend/verified_specs.json.
//
// Condition-based service: the German makes (and GM/Ford to a degree) do NOT
// publish a single fixed odometer table — they use flexible / condition-based
// systems that compute the next service from sensors and driving style:
//   • Mercedes-Benz — ASSYST / ASSYST PLUS, alternating Service A / Service B.
//   • BMW           — Condition Based Service (CBS).
//   • VW / Audi     — fixed vs. flexible (LongLife) service; US books publish a
//                     fixed-interval table, captured here.
//   • GM (Chevy/GMC)— GM Oil Life System (algorithmic oil interval).
//   • Ford          — Intelligent Oil-Life Monitor (IOLM).
// Where a make is condition-based, [OemSchedule.conditionBased] is true and the
// captured figures are the PUBLISHED BASELINE / maximum intervals, not a hard
// schedule. This is flagged per-interval in notes as well.

/// Confidence grade of the source backing a value (mirrors verified_specs A–D).
///  • [a] official manufacturer document, value read unambiguously from it.
///  • [b] official document but value is model/engine-column dependent or
///        corroborated across sources rather than read cleanly; or a reputable
///        secondary (dealer-published) schedule.
///  • [c] weaker secondary source.
///  • [d] inferred / placeholder — NOT used in this file (we omit instead).
enum OemGrade { a, b, c, d }

/// Driving severity, matching DrivingSeverity in maintenance_rule.dart. Most of
/// these OEM US schedules publish a single "normal" table and describe severe
/// use in prose; [OemSeverity.severe] rows are only present where a doc gives a
/// distinct severe figure.
enum OemSeverity { normal, severe }

/// One sourced maintenance interval for a service item.
class OemInterval {
  /// Service item label as printed by the OEM (e.g. "Engine Oil & Filter",
  /// "Spark Plugs", "Brake Fluid", "Dust & Pollen Filter").
  final String service;

  /// Interval in kilometres (null = this item is time-only or has no published
  /// distance interval, e.g. brake fluid "every 2 years regardless of mileage").
  final int? intervalKm;

  /// Interval in months (null = distance-only).
  final int? intervalMonths;

  final OemSeverity severity;
  final OemGrade grade;

  /// Short provenance string. The full citation (document title, page, URL,
  /// publisher) is in oem_schedules_german_american_SOURCES.md keyed by this.
  final String source;

  /// Caveats: condition-based flag, "lifetime/sealed" claims, model/engine
  /// scoping, mile-equivalent of the stored km, etc.
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

  /// True when the make uses a flexible / condition-based service system, so the
  /// intervals here are published baselines/maximums rather than a hard table.
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

/// The full research corpus. Grouped by make for readability.
const List<OemSchedule> kOemSchedulesGermanAmerican = [
  // ==========================================================================
  // MERCEDES-BENZ — ASSYST / ASSYST PLUS flexible service (Service A / B).
  // Source: Mercedes-Benz USA MY14 Maintenance Booklet (Edition B, 2014),
  // which publishes the per-mileage Service work for all passenger models. The
  // alternating Service A (10,000 mi / 1 yr) and Service B (20,000 mi / 2 yr)
  // baseline still applies to current MB-USA cars.
  // ==========================================================================
  OemSchedule(
    make: 'Mercedes-Benz',
    model: 'All passenger models',
    yearStart: 2009,
    yearEnd: 2014,
    engine: 'Gasoline (per MY14 booklet)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'MB MY14 Maintenance Booklet',
        notes:
            'ASSYST flexible: Service A ~10,000 mi / 1 yr (whichever first). '
            'Actual due date set by the on-board Maintenance System.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalKm: 32000,
        intervalMonths: 24,
        grade: OemGrade.a,
        source: 'MB MY14 Maintenance Booklet',
        notes: 'Replaced at every 20,000 mi / 2 yr service (Service B cadence).',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 96000,
        intervalMonths: 72,
        grade: OemGrade.a,
        source: 'MB MY14 Maintenance Booklet',
        notes:
            'First at 60,000 mi / 6 yr, then every 60,000 mi (120,000 mi…). '
            'Excludes diesel engine 642. AMG/severe may be sooner.',
      ),
      OemInterval(
        service: 'Air Filter',
        intervalKm: 64000,
        intervalMonths: 48,
        grade: OemGrade.a,
        source: 'MB MY14 Maintenance Booklet',
        notes:
            'Normal dust: 40,000 mi / 4 yr. Engine 275 (V12) 60,000 mi / 6 yr; '
            'engine 133 (AMG 2.0L) 10,000 mi / 1 yr.',
      ),
      OemInterval(
        service: 'Cabin / Combination Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.b,
        source: 'MB MY14 Maintenance Booklet',
        notes:
            'Combination/dust filter is listed at nearly every service in the '
            'booklet (≈ every 10,000 mi / 1 yr); exact cadence is model-column '
            'dependent.',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 48000,
        intervalMonths: 36,
        grade: OemGrade.b,
        source: 'MB MY14 Maintenance Booklet',
        notes:
            'Main-circuit coolant appears at 30k/60k/90k/120k/150k mi '
            '(≈ every 30,000 mi / 3 yr) for the relevant engine columns; '
            'engines 275/279 check concentration yearly instead.',
      ),
      OemInterval(
        service: 'Transmission Fluid',
        intervalKm: 64000,
        grade: OemGrade.b,
        source: 'MB MY14 Maintenance Booklet',
        notes:
            'Automatic transmission oil & filter is model-dependent: commonly '
            '~40,000 mi, some columns 30k–120k mi. NOT a lifetime fill in this '
            'booklet. Verify per transmission code (722.x).',
      ),
      OemInterval(
        service: 'Timing Chain',
        grade: OemGrade.b,
        source: 'MB MY14 Maintenance Booklet',
        notes:
            'Modern MB gasoline engines use a timing CHAIN — no scheduled '
            'replacement; inspect only. (No interval published.)',
      ),
    ],
  ),

  // ==========================================================================
  // BMW — Condition Based Service (CBS). No fixed odometer table; CBS computes
  // each item from sensors/driving. Figures below are the PUBLISHED BASELINES
  // corroborated across BMW's own CBS interval tables (bmwtechinfo), the BMW USA
  // maintenance booklet, and BMW dealer guides. Graded B where BMW's own
  // document could not be opened directly (gated PDFs) — see SOURCES.
  // ==========================================================================
  OemSchedule(
    make: 'BMW',
    model: 'All gasoline models',
    yearStart: 2015,
    yearEnd: 2026,
    engine: 'Gasoline (non-M), CBS',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.b,
        source: 'BMW CBS / MY25 Maintenance booklet',
        notes:
            'Condition-based: oil-service steps are ~10,000 mi; CBS counter '
            '(not odometer) sets the due point, up to ~1–2 yr. No hard fixed '
            'interval.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'BMW CBS / MY25 Maintenance booklet',
        notes:
            'Time-based, every 2 years (some X-series bulletins cite a 36-month '
            'first service). Independent of mileage.',
      ),
      OemInterval(
        service: 'Cabin / Micro Filter',
        intervalMonths: 24,
        grade: OemGrade.b,
        source: 'BMW CBS / MY25 Maintenance booklet',
        notes:
            'Ventilation microfilter every 2 years (or with the scheduled brake '
            'fluid change).',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 96000,
        grade: OemGrade.b,
        source: 'BMW CBS / MY25 Maintenance booklet',
        notes:
            'Tied to oil-service count: ≈ every 6th oil service ≈ 60,000 mi on '
            'current turbo engines. Older/NA engines vary (30k–100k mi); '
            'model-specific.',
      ),
      // Engine air filter & coolant: BMW surfaces these via CBS "Vehicle Check"
      // with no single published mileage — recorded as GAPS in SOURCES, omitted
      // here rather than guessed.
    ],
  ),

  // ==========================================================================
  // VOLKSWAGEN — MY2019 US Maintenance Schedule (all models except e-Golf).
  // Fixed-interval table (VWoA). First minor service 10,000 mi / 1 yr, then
  // 20,000 mi / 2 yr. Grade A throughout (read directly from the VW document).
  // ==========================================================================
  OemSchedule(
    make: 'Volkswagen',
    model: 'All models (MY2019 US schedule)',
    yearStart: 2019,
    yearEnd: 2019,
    engine: 'Gasoline',
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'VW MY2019 Maintenance Schedule',
        notes:
            'First minor service 10,000 mi / 1 yr; thereafter 20,000 mi / 2 yr '
            '(32,000 km / 24 mo). Shorter first interval stored to be safe.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 24,
        grade: OemGrade.a,
        source: 'VW MY2019 Maintenance Schedule',
        notes: 'Every 2 years regardless of mileage.',
      ),
      OemInterval(
        service: 'Air Filter',
        intervalKm: 96000,
        intervalMonths: 72,
        grade: OemGrade.a,
        source: 'VW MY2019 Maintenance Schedule',
        notes: 'Air filter element & snow screen: every 60,000 mi / 6 yr.',
      ),
      OemInterval(
        service: 'Cabin / Dust & Pollen Filter',
        intervalKm: 64000,
        intervalMonths: 24,
        grade: OemGrade.a,
        source: 'VW MY2019 Maintenance Schedule',
        notes: 'Every 40,000 mi / 2 yr.',
      ),
      OemInterval(
        service: 'Transmission Fluid',
        intervalKm: 64000,
        grade: OemGrade.a,
        source: 'VW MY2019 Maintenance Schedule',
        notes:
            '6-speed DSG: 40,000 mi. 7-speed DSG: 80,000 mi (128,000 km). '
            'Non-DSG automatic: 80,000 mi (US; "filled for life" in Canada). '
            'Stored value = 6-speed DSG.',
      ),
      OemInterval(
        service: 'Timing Chain',
        grade: OemGrade.b,
        source: 'VW MY2019 Maintenance Schedule',
        notes:
            'EA888 2.0T / EA211 use a timing CHAIN — no scheduled replacement. '
            'Some EA211 1.4T variants use a belt; verify per engine. (No '
            'interval published in the US schedule.)',
      ),
    ],
  ),
  // VW spark-plug split (same MY2019 source) — two sourced tiers.
  OemSchedule(
    make: 'Volkswagen',
    model: 'Jetta / Golf GTI / Tiguan (and most 2.0T/1.4T)',
    yearStart: 2019,
    yearEnd: 2019,
    engine: 'EA888 2.0T / EA211 1.4T (except Atlas & SportWagen 1.4L)',
    intervals: [
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 64000,
        intervalMonths: 48,
        grade: OemGrade.a,
        source: 'VW MY2019 Maintenance Schedule',
        notes: 'Every 40,000 mi / 4 yr (all except Atlas, Golf SportWagen 1.4L).',
      ),
    ],
  ),
  OemSchedule(
    make: 'Volkswagen',
    model: 'Atlas / Golf SportWagen 1.4L',
    yearStart: 2019,
    yearEnd: 2019,
    engine: 'VR6 3.6L / 2.0T (Atlas), 1.4L TSI (SportWagen)',
    intervals: [
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 128000,
        intervalMonths: 72,
        grade: OemGrade.a,
        source: 'VW MY2019 Maintenance Schedule',
        notes: 'Every 80,000 mi / 6 yr (Atlas, Golf SportWagen 1.4L).',
      ),
    ],
  ),

  // ==========================================================================
  // AUDI — MY2018/19 US Maintenance Schedule (all models, Revised 5/1/2019),
  // corroborated by the MY2021 schedule. Fixed-interval table (Audi USA). First
  // minor service 10,000 mi / 1 yr, then 20,000 mi / 2 yr. Grade A throughout.
  // ==========================================================================
  OemSchedule(
    make: 'Audi',
    model: 'All models (MY2018–19 US schedule)',
    yearStart: 2018,
    yearEnd: 2019,
    engine: 'Gasoline',
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Audi MY2018-19 Maintenance Schedule',
        notes:
            'First minor service 10,000 mi / 1 yr; thereafter 20,000 mi / 2 yr '
            '(32,000 km / 24 mo). Shorter first interval stored to be safe.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 24,
        grade: OemGrade.a,
        source: 'Audi MY2018-19 Maintenance Schedule',
        notes: 'Every 2 years — all vehicles.',
      ),
      OemInterval(
        service: 'Air Filter',
        intervalKm: 96000,
        grade: OemGrade.a,
        source: 'Audi MY2018-19 Maintenance Schedule',
        notes:
            'Every 60,000 mi (all vehicles except RS7 / A8 LWB, which are '
            '40,000 mi).',
      ),
      OemInterval(
        service: 'Cabin / Dust & Pollen Filter',
        intervalKm: 32000,
        intervalMonths: 24,
        grade: OemGrade.a,
        source: 'Audi MY2018-19 Maintenance Schedule',
        notes: 'Every 20,000 mi / 2 yr.',
      ),
      OemInterval(
        service: 'Transmission Fluid',
        intervalKm: 64000,
        grade: OemGrade.a,
        source: 'Audi MY2018-19 Maintenance Schedule',
        notes:
            'S tronic (DSG): 40,000 mi for A4/S4/A5/S5/Q5/SQ5/Q7 2.0T etc.; '
            '80,000 mi for some 2.0T B-cycle variants. Stored = 40,000 mi.',
      ),
      OemInterval(
        service: 'Timing Chain',
        grade: OemGrade.b,
        source: 'Audi MY2018-19 Maintenance Schedule',
        notes:
            'EA888 2.0T / 3.0T use a timing CHAIN — no scheduled replacement; '
            'inspect only. (No interval published.)',
      ),
    ],
  ),
  // Audi spark-plug tiers (same MY2018-19 source) — clean model mapping.
  OemSchedule(
    make: 'Audi',
    model: 'A4 / S4 / A5 / S5 / Q5 / SQ5 / Q7 2.0T / A6 2.0T / TT 2.0T / TTS',
    yearStart: 2018,
    yearEnd: 2019,
    engine: '2.0T / 4.0T (per doc list)',
    intervals: [
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 64000,
        intervalMonths: 72,
        grade: OemGrade.a,
        source: 'Audi MY2018-19 Maintenance Schedule',
        notes: 'Every 40,000 mi / 6 yr.',
      ),
    ],
  ),
  OemSchedule(
    make: 'Audi',
    model: 'A6 3.0T / A7 3.0T / A8 L 3.0T / Q3 / Q7 3.0T / R8',
    yearStart: 2018,
    yearEnd: 2019,
    engine: '3.0T V6 / V10 (per doc list)',
    intervals: [
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 96000,
        intervalMonths: 72,
        grade: OemGrade.a,
        source: 'Audi MY2018-19 Maintenance Schedule',
        notes: 'Every 60,000 mi / 6 yr.',
      ),
    ],
  ),
  OemSchedule(
    make: 'Audi',
    model: 'RS 3 / RS 5 / RS 7 performance / S8 plus / TT RS',
    yearStart: 2018,
    yearEnd: 2019,
    engine: 'RS performance',
    intervals: [
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 48000,
        intervalMonths: 36,
        grade: OemGrade.a,
        source: 'Audi MY2018-19 Maintenance Schedule',
        notes: 'Every 30,000 mi / 3 yr (RS/performance engines).',
      ),
    ],
  ),

  // ==========================================================================
  // CHEVROLET — GM Oil Life System (algorithmic oil interval). Values read from
  // the model-year US Owner Manuals (General Motors). Reused verbatim from the
  // repo's own Grade-A verified_specs dataset (data_backend/verified_specs.json).
  // ==========================================================================
  OemSchedule(
    make: 'Chevrolet',
    model: 'Equinox',
    yearStart: 2018,
    yearEnd: 2024,
    engine: '1.5L Turbo I4 (GM1.5T)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Chevrolet Equinox 2023 Owner Manual',
        notes: 'GM Oil Life System (algorithmic); minimum once per year.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 96000,
        grade: OemGrade.a,
        source: 'Chevrolet Equinox 2023 Owner Manual',
        notes: '60,000 mi.',
      ),
    ],
  ),
  OemSchedule(
    make: 'Chevrolet',
    model: 'Traverse',
    yearStart: 2018,
    yearEnd: 2023,
    engine: '3.6L V6 (LFY)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Chevrolet Traverse 2023 Owner Manual',
        notes: 'GM Oil Life System (algorithmic); minimum once per year.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 156000,
        grade: OemGrade.a,
        source: 'Chevrolet Traverse 2023 Owner Manual',
        notes: '97,500 mi.',
      ),
    ],
  ),
  OemSchedule(
    make: 'Chevrolet',
    model: 'Tahoe / Suburban',
    yearStart: 2021,
    yearEnd: 2026,
    engine: '5.3L V8 (L84) / 6.2L V8 (L87)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Chevrolet Tahoe/Suburban 2023 Owner Manual',
        notes: 'GM Oil Life System (algorithmic); minimum once per year.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 156000,
        grade: OemGrade.a,
        source: 'Chevrolet Tahoe/Suburban 2023 Owner Manual',
        notes: '97,500 mi.',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 240000,
        intervalMonths: 72,
        grade: OemGrade.a,
        source: 'Chevrolet Tahoe/Suburban 2023 Owner Manual',
        notes: '150,000 mi / 6 yr (DEX-COOL).',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 36000,
        intervalMonths: 24,
        grade: OemGrade.a,
        source: 'Chevrolet Tahoe/Suburban 2023 Owner Manual',
      ),
    ],
  ),

  // ==========================================================================
  // GMC — GM Oil Life System. Values from US Owner Manuals (General Motors),
  // reused from the repo's Grade-A verified_specs dataset.
  // ==========================================================================
  OemSchedule(
    make: 'GMC',
    model: 'Terrain',
    yearStart: 2018,
    yearEnd: 2024,
    engine: '1.5L Turbo I4 (GM1.5T)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'GMC Terrain 2022 Owner Manual',
        notes: 'GM Oil Life System (algorithmic); minimum once per year.',
      ),
    ],
  ),
  OemSchedule(
    make: 'GMC',
    model: 'Acadia',
    yearStart: 2017,
    yearEnd: 2024,
    engine: '3.6L V6 (LFY)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'GMC Acadia 2022 Owner Manual',
        notes: 'GM Oil Life System (algorithmic); minimum once per year.',
      ),
    ],
  ),
  OemSchedule(
    make: 'GMC',
    model: 'Yukon / Yukon XL',
    yearStart: 2021,
    yearEnd: 2026,
    engine: '5.3L V8 (L84) / 6.2L V8 (L87)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'GMC Yukon 2023 Owner Manual',
        notes: 'GM Oil Life System (algorithmic); minimum once per year.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 156000,
        grade: OemGrade.a,
        source: 'GMC Yukon 2023 Owner Manual',
        notes: '97,500 mi.',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 240000,
        intervalMonths: 72,
        grade: OemGrade.a,
        source: 'GMC Yukon 2023 Owner Manual',
        notes: '150,000 mi / 6 yr (DEX-COOL).',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 36000,
        intervalMonths: 24,
        grade: OemGrade.a,
        source: 'GMC Yukon 2023 Owner Manual',
      ),
    ],
  ),

  // ==========================================================================
  // FORD — Intelligent Oil-Life Monitor (IOLM). Values from US Owner Manuals
  // (Ford Motor Company), reused from the repo's Grade-A verified_specs dataset.
  // ==========================================================================
  OemSchedule(
    make: 'Ford',
    model: 'Escape',
    yearStart: 2020,
    yearEnd: 2026,
    engine: '1.5L EcoBoost I3 (Ford1.5EB)',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Ford Escape 2022 Owner Manual',
        notes: 'Intelligent Oil-Life Monitor (IOLM); up to 1 yr / 10,000 mi.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 160000,
        grade: OemGrade.a,
        source: 'Ford Escape 2022 Owner Manual',
        notes: '100,000 mi.',
      ),
    ],
  ),
  OemSchedule(
    make: 'Ford',
    model: 'Explorer',
    yearStart: 2020,
    yearEnd: 2026,
    engine: '2.3L EcoBoost I4 / 3.0L EcoBoost V6',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Ford Explorer 2022 Owner Manual',
        notes: 'IOLM up to 1 yr / 10,000 mi.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 160000,
        grade: OemGrade.a,
        source: 'Ford Explorer 2022 Owner Manual',
        notes: '100,000 mi.',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 48000,
        grade: OemGrade.a,
        source: 'Ford Explorer 2022 Owner Manual',
        notes: '30,000 mi.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 32000,
        grade: OemGrade.a,
        source: 'Ford Explorer 2022 Owner Manual',
        notes: '20,000 mi.',
      ),
      OemInterval(
        service: 'Transmission Fluid',
        intervalKm: 240000,
        grade: OemGrade.a,
        source: 'Ford Explorer 2022 Owner Manual',
        notes: '150,000 mi.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 36,
        grade: OemGrade.a,
        source: 'Ford Explorer 2022 Owner Manual',
        notes: 'Every 3 years.',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 322000,
        grade: OemGrade.a,
        source: 'Ford Explorer 2022 Owner Manual',
        notes: 'First change at 200,000 mi (322,000 km).',
      ),
    ],
  ),
  OemSchedule(
    make: 'Ford',
    model: 'F-150',
    yearStart: 2021,
    yearEnd: 2026,
    engine: '2.7L / 3.5L EcoBoost V6, 5.0L V8 Coyote',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalKm: 16000,
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Ford F-150 2022 Owner Manual',
        notes: 'IOLM up to 1 yr / 10,000 mi.',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 96600,
        grade: OemGrade.a,
        source: 'Ford F-150 2022 Owner Manual',
        notes: '60,000 mi (F-150).',
      ),
      OemInterval(
        service: 'Engine Air Filter',
        intervalKm: 48000,
        grade: OemGrade.a,
        source: 'Ford F-150 2022 Owner Manual',
        notes: '30,000 mi.',
      ),
      OemInterval(
        service: 'Cabin Air Filter',
        intervalKm: 32000,
        grade: OemGrade.a,
        source: 'Ford F-150 2022 Owner Manual',
        notes: '20,000 mi.',
      ),
      OemInterval(
        service: 'Transmission Fluid',
        intervalKm: 240000,
        grade: OemGrade.a,
        source: 'Ford F-150 2022 Owner Manual',
        notes: '150,000 mi.',
      ),
      OemInterval(
        service: 'Brake Fluid',
        intervalMonths: 36,
        grade: OemGrade.a,
        source: 'Ford F-150 2022 Owner Manual',
        notes: 'Every 3 years.',
      ),
      OemInterval(
        service: 'Coolant',
        intervalKm: 322000,
        grade: OemGrade.a,
        source: 'Ford F-150 2022 Owner Manual',
        notes: 'First change at 200,000 mi (322,000 km).',
      ),
    ],
  ),
  OemSchedule(
    make: 'Ford',
    model: 'Mustang',
    yearStart: 2015,
    yearEnd: 2023,
    engine: '5.0L V8 Coyote',
    conditionBased: true,
    intervals: [
      OemInterval(
        service: 'Engine Oil & Filter',
        intervalMonths: 12,
        grade: OemGrade.a,
        source: 'Ford Mustang 2023 Owner Manual',
        notes:
            'Intelligent Oil-Life Monitor (IOLM); booklet lists minimum once '
            'per year. (Distance interval not captured in source row.)',
      ),
      OemInterval(
        service: 'Spark Plugs',
        intervalKm: 160000,
        grade: OemGrade.a,
        source: 'Ford Mustang 2023 Owner Manual',
        notes: '100,000 mi.',
      ),
    ],
  ),
];
