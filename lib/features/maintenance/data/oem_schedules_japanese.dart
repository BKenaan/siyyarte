// OEM maintenance schedules — Japanese & Korean makes (research dataset).
//
// This file is SOURCED RESEARCH DATA, not yet wired into the maintenance
// engine. It deliberately mirrors the discipline of the `verified_specs`
// system in `data_backend/` and `lib/features/specs/`:
//
//   GOLDEN RULE: never show an unverified number.
//
// Every interval below carries a real, citable source (publisher + document +
// URL) and a confidence [OemGrade]. Where a trustworthy source could not be
// found for a value it was OMITTED and recorded as a gap in the companion file
// `oem_schedules_japanese_SOURCES.md` — nothing here is inferred, guessed or
// "reasonable-defaulted".
//
// Integration into `MaintenanceRule` / `MaintenanceEngine` is intentionally NOT
// done here; that safety-critical mapping is reviewed separately. This file
// only has to compile cleanly and carry honest, cited data.
//
// Units: km are kilometres; months are calendar months. [firstKm] is used for
// "first replacement at X, then every [intervalKm]" schedules (common for
// long-life coolant). [intervalKm] / [intervalMonths] are "whichever comes
// first". A null value means that dimension was not published for the item.

/// Field-level confidence, aligned with the verified_specs A–D scale.
enum OemGrade {
  /// Directly read from a manufacturer or official importer maintenance
  /// document (owner's-manual schedule, OEM service-requirement sheet).
  a,

  /// Official source, but a market-specific dealer/importer schedule (e.g. a
  /// single tropical-market table) rather than the global owner's manual, or a
  /// value derived from an explicit footnote.
  b,

  /// Value whose exact figure is only positionally implied by the source
  /// (needs confirmation before display).
  c,

  /// Placeholder — not used; present so the scale matches verified_specs.
  d,
}

/// Driving severity, matching the app's existing [DrivingSeverity] semantics.
/// Lebanese conditions (dust, heat, short trips, stop-and-go) meet every OEM's
/// "severe / special operating conditions" definition, so [severe] matters most.
enum OemSeverity { normal, severe }

/// One cited maintenance interval for a single service item.
class OemInterval {
  /// Human service label, e.g. 'Engine oil & filter', 'Spark plugs (iridium)'.
  final String service;

  /// Replace/service interval in kilometres (null if not published in km).
  final int? intervalKm;

  /// Replace/service interval in months (null if not published in months).
  final int? intervalMonths;

  /// For "first at X km, then every [intervalKm]" items (e.g. long-life
  /// coolant). Null for fixed-interval items.
  final int? firstKm;

  /// Whether this interval is the normal or the severe-conditions figure.
  final OemSeverity severity;

  /// Full citation: publisher — document (date) — URL.
  final String source;

  /// Field-level confidence.
  final OemGrade grade;

  /// Any clarifying note (engine qualifier, market caveat, footnote text).
  final String? notes;

  const OemInterval({
    required this.service,
    this.intervalKm,
    this.intervalMonths,
    this.firstKm,
    required this.severity,
    required this.source,
    required this.grade,
    this.notes,
  });
}

/// A set of cited intervals scoped to make / model / year-range / engine.
class OemModelSchedule {
  final String make;

  /// Model, or a make-level descriptor when the source is make-wide.
  final String model;

  /// Inclusive model-year range the source covers (null when the source does
  /// not print model years; see [generationNote]).
  final int? yearStart;
  final int? yearEnd;

  /// Engine / fuel descriptor the source differentiates by (null = applies to
  /// the model's engines as published).
  final String? engine;

  final String? fuel;

  /// Note on generation / year-range provenance when not printed in the source.
  final String? generationNote;

  final List<OemInterval> intervals;

  const OemModelSchedule({
    required this.make,
    required this.model,
    this.yearStart,
    this.yearEnd,
    this.engine,
    this.fuel,
    this.generationNote,
    required this.intervals,
  });
}

// ---------------------------------------------------------------------------
// Source citation constants (kept as named consts so each interval references
// an exact, auditable string; full list also in the SOURCES.md companion).
// ---------------------------------------------------------------------------

const String _srcToyotaNzHybrid =
    'Toyota New Zealand — "Service Requirements: Petrol Hybrid Vehicles" (v. Sept 2023) — '
    'https://www.toyota.co.nz/globalassets/owners/servicing-your-toyota/toyota-petrol-hybrid-service-requirements.pdf';

const String _srcToyotaBruneiPms =
    'Toyota Brunei (official) — "Periodic Maintenance Service (PMS) table" (rev. 01-09-2022) — '
    'https://www.toyota.com.bn/media/nlqnjp0d/pms-table-01092022-rev-1-1.pdf';

const String _srcNissanZaXtrail =
    'Nissan South Africa — X-Trail Periodic Maintenance schedule (PDF) — '
    'https://www.nissan.co.za/content/dam/Nissan/za/Maintenance/X-Trail.pdf';

const String _srcNissanZaQashqai =
    'Nissan South Africa — Qashqai Periodic Maintenance schedule (PDF) — '
    'https://www.nissan.co.za/content/dam/Nissan/za/Maintenance/Qashqai.pdf';

const String _srcHondaOmPrelude =
    'Honda (UK) online Owner\'s Manual — Prelude 2026, Maintenance schedule page '
    '(Honda\'s common European service schedule) — '
    'https://manuals.honda.co.uk/prelude/2026/details/67973c83ca02c6-71933317.html';

const String _srcHyundaiNzHev =
    'Hyundai New Zealand (myHyundai Care) — "Standard Maintenance Requirements: '
    'Petrol Turbo Hybrid Vehicles" (V2) — '
    'https://go.hyundai.co.nz/rs/147-PQU-830/images/3.%20Petrol-HEV-Turbo-service-requirements%20Jul%2026.pdf';

const String _srcHyundaiNzMpi =
    'Hyundai New Zealand (myHyundai Care) — "Standard Maintenance Requirements: '
    'Petrol Vehicles (MPI)" (V2) — '
    'https://go.hyundai.co.nz/rs/147-PQU-830/images/1.%20Petrol-MPI%20Service%20Requirements.pdf';

const String _srcMitsuAuOutlander =
    'Mitsubishi Motors Australia — "24MY ZM Outlander Inspection and Maintenance '
    'Schedule" (Oct 2023) — '
    'https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/24MY-ZM-OUTLANDER-INSPECTION-AND-MAINTENANCE-SCHEDULE-WEB.pdf';

const String _srcMitsuAuTriton =
    'Mitsubishi Motors Australia — "19MY MR Triton Periodic Inspection and '
    'Maintenance Schedule" — '
    'https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/TRITON-MY19_Maintenance-Schedule.pdf';

// ---------------------------------------------------------------------------
// TOYOTA
// ---------------------------------------------------------------------------

const OemModelSchedule _toyotaPetrolHybrid = OemModelSchedule(
  make: 'Toyota',
  model: 'Petrol hybrid range (Corolla / RAV4 / Camry / Prius etc.)',
  engine: 'Petrol-electric hybrid (HEV), incl. e-CVT',
  fuel: 'Hybrid',
  generationNote:
      'Source is make-wide for Toyota petrol-hybrid vehicles; it does not '
      'enumerate model years. Normal-conditions schedule; severe = "shorten".',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcToyotaNzHybrid,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Brake fluid (DOT3/DOT4)',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcToyotaNzHybrid,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 75000,
      severity: OemSeverity.normal,
      source: _srcToyotaNzHybrid,
      grade: OemGrade.a,
      notes: 'Replaced at the 75,000 km and 150,000 km services.',
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcToyotaNzHybrid,
      grade: OemGrade.a,
      notes: 'Replaced at specified km only (90,000 / 180,000 km).',
    ),
    OemInterval(
      service: 'Transmission fluid (e-CVT)',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcToyotaNzHybrid,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine/heater coolant (+ inverter coolant)',
      firstKm: 150000,
      intervalKm: 75000,
      severity: OemSeverity.normal,
      source: _srcToyotaNzHybrid,
      grade: OemGrade.a,
      notes: 'First change at 150,000 km, then every 75,000 km.',
    ),
    OemInterval(
      service: 'Rear differential fluid (AWD)',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcToyotaNzHybrid,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Timing belt (belt-driven engines)',
      intervalKm: 150000,
      severity: OemSeverity.normal,
      source: _srcToyotaNzHybrid,
      grade: OemGrade.a,
      notes: 'Source: "important to ensure the timing belt is changed at the '
          'equivalent of 150,000 kilometres". Chain-driven engines: inspect only.',
    ),
  ],
);

const OemModelSchedule _toyotaBruneiPms = OemModelSchedule(
  make: 'Toyota',
  model: 'General range (Toyota Brunei PMS)',
  generationNote:
      'Single tropical-market service table (Toyota Brunei), not the global '
      'owner\'s-manual normal/severe split. Intervals here are the Brunei '
      'published figures; treat as a hot-climate (severe-leaning) schedule.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 5000,
      intervalMonths: 3,
      severity: OemSeverity.severe,
      source: _srcToyotaBruneiPms,
      grade: OemGrade.b,
      notes: 'Brunei tropical schedule replaces oil & filter every 5,000 km.',
    ),
    OemInterval(
      service: 'Spark plugs (standard)',
      intervalKm: 20000,
      severity: OemSeverity.normal,
      source: _srcToyotaBruneiPms,
      grade: OemGrade.a,
      notes: 'Table note: standard plugs @ 20,000 km, iridium @ 100,000 km.',
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 100000,
      severity: OemSeverity.normal,
      source: _srcToyotaBruneiPms,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.severe,
      source: _srcToyotaBruneiPms,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Cabin / A-C filter',
      intervalKm: 40000,
      severity: OemSeverity.severe,
      source: _srcToyotaBruneiPms,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 40000,
      severity: OemSeverity.severe,
      source: _srcToyotaBruneiPms,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Fuel filter',
      intervalKm: 40000,
      severity: OemSeverity.severe,
      source: _srcToyotaBruneiPms,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Transmission fluid (ATF)',
      intervalKm: 40000,
      severity: OemSeverity.severe,
      source: _srcToyotaBruneiPms,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Engine coolant',
      intervalKm: 40000,
      severity: OemSeverity.severe,
      source: _srcToyotaBruneiPms,
      grade: OemGrade.b,
      notes: 'Brunei tropical schedule; differs from Toyota global SLLC '
          '(first 160,000 km) — market-conservative value.',
    ),
    OemInterval(
      service: 'Differential oil (where applicable)',
      intervalKm: 40000,
      severity: OemSeverity.severe,
      source: _srcToyotaBruneiPms,
      grade: OemGrade.b,
    ),
  ],
);

// ---------------------------------------------------------------------------
// NISSAN
// ---------------------------------------------------------------------------

const OemModelSchedule _nissanXtrailPetrol = OemModelSchedule(
  make: 'Nissan',
  model: 'X-Trail',
  engine: '2.0L / 2.5L petrol (MR20 / QR25)',
  fuel: 'Petrol',
  generationNote:
      'Engine lineup (MR20/QR25) identifies the T32 generation (c.2014–2021); '
      'the Nissan SA PDF itself is undated.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
      notes: 'Table: "Replace every 90,000 km" (no month figure given).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 150000,
      intervalKm: 75000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
      notes: 'First change 150,000 km / 96 mo, then 75,000 km / 48 mo. Use '
          'Genuine NISSAN Engine Coolant (Blue).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
      notes: 'Inspect/change by 90,000 km; change (not just inspect) at '
          '90,000 km if not inspected. Genuine NISSAN CVT Fluid only.',
    ),
    OemInterval(
      service: 'Cabin / A-C filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Differential gear oil',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.severe,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
      notes: 'Normal = inspect; severe (dusty/towing) = replace 30,000 km/24 mo.',
    ),
  ],
);

const OemModelSchedule _nissanXtrailDiesel = OemModelSchedule(
  make: 'Nissan',
  model: 'X-Trail',
  engine: '1.6L diesel (R9M)',
  fuel: 'Diesel',
  generationNote: 'T32 generation (engine R9M); Nissan SA PDF undated.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 150000,
      intervalKm: 75000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
      notes: 'First 150,000 km / 96 mo, then 75,000 km / 48 mo.',
    ),
    OemInterval(
      service: 'Drive belts',
      intervalKm: 160000,
      intervalMonths: 72,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Timing chain',
      intervalKm: 160000,
      intervalMonths: 240,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
      notes: 'CVT model: 160,000 km / 240 mo. MT model: 300,000 km / 120 mo.',
    ),
    OemInterval(
      service: 'Fuel filter',
      intervalKm: 30000,
      severity: OemSeverity.normal,
      source: _srcNissanZaXtrail,
      grade: OemGrade.a,
    ),
  ],
);

const OemModelSchedule _nissanQashqai12t = OemModelSchedule(
  make: 'Nissan',
  model: 'Qashqai',
  engine: '1.2L turbo petrol (HRA2)',
  fuel: 'Petrol',
  generationNote:
      'Engine lineup identifies the J11 generation (c.2014–2021); PDF undated.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 5000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 60000,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
      notes: 'Replaced at 60,000 / 120,000 km ("at the specified mileage only").',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 30000,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 150000,
      intervalKm: 75000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
      notes: 'First 150,000 km / 96 mo, then 75,000 km / 48 mo.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 10000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
      notes: 'Genuine NISSAN CVT Fluid only.',
    ),
  ],
);

const OemModelSchedule _nissanQashqai15Diesel = OemModelSchedule(
  make: 'Nissan',
  model: 'Qashqai',
  engine: '1.5L diesel (K9K)',
  fuel: 'Diesel',
  generationNote: 'J11 generation (engine K9K); PDF undated.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 30000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
      notes: 'Table: "Replace every 30,000 km / 12 months" (whichever first).',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Timing belt & pulleys',
      intervalKm: 90000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Drive belt & pulleys',
      intervalKm: 90000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Fuel filter',
      intervalKm: 30000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 150000,
      intervalKm: 75000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
      notes: 'First 150,000 km / 96 mo, then 75,000 km / 48 mo.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 30000,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
  ],
);

const OemModelSchedule _nissanQashqai16t = OemModelSchedule(
  make: 'Nissan',
  model: 'Qashqai',
  engine: '1.6L turbo petrol (MR16DDT)',
  fuel: 'Petrol',
  generationNote: 'J11 generation (engine MR16DDT); PDF undated.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs (iridium/platinum)',
      intervalKm: 100000,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
      notes: 'Replaced at the 100,000 km service ("at the specified mileage").',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 160000,
      intervalKm: 80000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcNissanZaQashqai,
      grade: OemGrade.a,
      notes: 'First 160,000 km / 96 mo, then 80,000 km / 48 mo; mixture check '
          'every 40,000 km / 24 mo.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// HONDA
// ---------------------------------------------------------------------------

const OemModelSchedule _hondaGeneral = OemModelSchedule(
  make: 'Honda',
  model: 'General schedule (per Prelude 2026 OM; Honda\'s common EU schedule)',
  generationNote:
      'Honda\'s owner\'s-manual maintenance schedule is presented make-wide (the '
      'page does not name a model year and states it "applies generally"). '
      'Note: everyday Honda petrol models also use the on-board Maintenance '
      'Minder, which can call oil service earlier than the fixed interval below.',
  intervals: [
    OemInterval(
      service: 'Engine oil',
      intervalKm: 10000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcHondaOmPrelude,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil',
      intervalKm: 5000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcHondaOmPrelude,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine air filter (cleaner element)',
      intervalKm: 30000,
      severity: OemSeverity.normal,
      source: _srcHondaOmPrelude,
      grade: OemGrade.a,
      notes: 'No month figure published.',
    ),
    OemInterval(
      service: 'Dust & pollen (cabin) filter',
      intervalKm: 20000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcHondaOmPrelude,
      grade: OemGrade.c,
      notes: 'Positioned at the 20,000 km service points; exact figure is '
          'positionally implied rather than printed — confirm before display.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 100000,
      severity: OemSeverity.normal,
      source: _srcHondaOmPrelude,
      grade: OemGrade.a,
      notes: 'Some markets (e.g. Algeria) inspect at 20,000 km.',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 200000,
      intervalKm: 100000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcHondaOmPrelude,
      grade: OemGrade.a,
      notes: 'First 200,000 km / 120 mo, then 100,000 km / 60 mo.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcHondaOmPrelude,
      grade: OemGrade.a,
      notes: 'Every 3 years; no distance interval published.',
    ),
    OemInterval(
      service: 'Transmission fluid',
      intervalKm: 150000,
      intervalMonths: 72,
      severity: OemSeverity.normal,
      source: _srcHondaOmPrelude,
      grade: OemGrade.a,
      notes: 'Lebanon (also Jordan, HK, Macao, Morocco, Tunisia) uses '
          '80,000 km / 48 mo per the same table — directly market-relevant.',
    ),
    OemInterval(
      service: 'Transmission fluid',
      intervalKm: 75000,
      intervalMonths: 36,
      severity: OemSeverity.severe,
      source: _srcHondaOmPrelude,
      grade: OemGrade.a,
    ),
  ],
);

// ---------------------------------------------------------------------------
// HYUNDAI
// ---------------------------------------------------------------------------

const OemModelSchedule _hyundaiHevTurbo = OemModelSchedule(
  make: 'Hyundai',
  model: 'Tucson (NX4) HEV / Santa Fe (MX5) HEV / Palisade (LX3) HEV',
  yearStart: 2025,
  engine: 'GDI petrol turbo hybrid',
  fuel: 'Hybrid',
  generationNote:
      'Tucson NX4 HEV & Santa Fe MX5 HEV MY2025+, Palisade LX3 HEV MY2026+. '
      'Severe-conditions intervals are half the standard figures (per source).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzHev,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 5000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcHyundaiNzHev,
      grade: OemGrade.a,
      notes: 'Severe = half standard (source states this rule explicitly).',
    ),
    OemInterval(
      service: 'Cabin / pollen filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzHev,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzHev,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzHev,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 70000,
      intervalMonths: 84,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzHev,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Coolant (engine & inverter)',
      intervalKm: 100000,
      intervalMonths: 120,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzHev,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Hybrid starter-generator belt',
      intervalKm: 40000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzHev,
      grade: OemGrade.a,
    ),
  ],
);

const OemModelSchedule _hyundaiPetrolMpi = OemModelSchedule(
  make: 'Hyundai',
  model: 'Kona (SX2) / Venue (QX) / Tucson (NX4) Series II',
  engine: 'MPI petrol (naturally aspirated)',
  fuel: 'Petrol',
  generationNote:
      'Hyundai NZ Petrol (MPI) sheet — excludes turbo & hybrid variants. '
      'Severe = half the standard figures (per source).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzMpi,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcHyundaiNzMpi,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Cabin / pollen filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzMpi,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzMpi,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 45000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzMpi,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs (Venue QX)',
      intervalKm: 60000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzMpi,
      grade: OemGrade.a,
      notes: 'Venue (QX) MPI only.',
    ),
    OemInterval(
      service: 'Spark plugs (Kona SX2 / Tucson NX4)',
      intervalKm: 150000,
      intervalMonths: 120,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzMpi,
      grade: OemGrade.a,
      notes: 'Kona (SX2) & Tucson (NX4) MPI.',
    ),
    OemInterval(
      service: 'Engine coolant',
      intervalKm: 150000,
      intervalMonths: 120,
      severity: OemSeverity.normal,
      source: _srcHyundaiNzMpi,
      grade: OemGrade.a,
    ),
  ],
);

// ---------------------------------------------------------------------------
// MITSUBISHI
// ---------------------------------------------------------------------------

const OemModelSchedule _mitsubishiOutlander = OemModelSchedule(
  make: 'Mitsubishi',
  model: 'Outlander (ZM)',
  yearStart: 2022,
  engine: '2.5L petrol (MIVEC), CVT',
  fuel: 'Petrol',
  generationNote: 'ZM generation, 24MY schedule.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMitsuAuOutlander,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      severity: OemSeverity.severe,
      source: _srcMitsuAuOutlander,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 90000,
      intervalMonths: 72,
      severity: OemSeverity.normal,
      source: _srcMitsuAuOutlander,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMitsuAuOutlander,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMitsuAuOutlander,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuOutlander,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.severe,
      source: _srcMitsuAuOutlander,
      grade: OemGrade.b,
      notes: 'Severe (towing / rough roads) per footnote *3.',
    ),
  ],
);

const OemModelSchedule _mitsubishiTriton = OemModelSchedule(
  make: 'Mitsubishi',
  model: 'Triton (MR)',
  yearStart: 2019,
  yearEnd: 2023,
  engine: 'Petrol & diesel (per-item qualifiers in notes)',
  generationNote: '5th-gen (MR) Triton, 19MY schedule.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      severity: OemSeverity.severe,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Timing belt (petrol)',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
      notes: 'Petrol engine only; diesel uses a chain.',
    ),
    OemInterval(
      service: 'Spark plugs (petrol, standard)',
      intervalKm: 45000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
      notes: 'Standard-type plugs, petrol engine.',
    ),
    OemInterval(
      service: 'Fuel filter (petrol)',
      intervalKm: 150000,
      intervalMonths: 120,
      severity: OemSeverity.normal,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine coolant (diesel)',
      firstKm: 165000,
      intervalKm: 105000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
      notes: 'First 165,000 km / 8 yr, then every 105,000 km / 5 yr (diesel).',
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 195000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 90000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Transfer gear oil',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Transfer gear oil',
      intervalKm: 30000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Front/rear differential gear oil',
      intervalKm: 75000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Front/rear differential gear oil',
      intervalKm: 30000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuTriton,
      grade: OemGrade.a,
    ),
  ],
);

// ===========================================================================
// GAP-FILL PASS (added later): Nissan SA sedans/trucks, additional Mitsubishi
// AU models, and — now partially filled — Kia and Lexus.
//
// Kia & Lexus sourcing note: every Kia/Lexus OEM host (ownersmanual.kia.com,
// kia.com, assets.sia.toyota.com) and every third-party aggregator (ManualsLib,
// manualmachine) was Cloudflare/WAF-blocked to both plain fetch AND a real
// rendered browser. The rows below were instead read from the GENUINE Kia/Lexus
// owner's-manuals / Warranty-&-Services guides mirrored (with OCR full text) on
// the Internet Archive. Because that is an OCR mirror rather than the maker's
// own host, these carry Grade B even where read directly, and anything the OCR
// could not render unambiguously was OMITTED (per the GOLDEN RULE). No value was
// copied across makes/models (no Hyundai->Kia, no Toyota->Lexus).
// ===========================================================================

const String _srcNissanZaAlmera =
    'Nissan South Africa — Almera 1.5 Petrol Periodic Maintenance schedule (PDF, normal + severe) — '
    'https://www.nissan.co.za/content/dam/Nissan/za/Maintenance/Almera.pdf';

const String _srcNissanZaNavara =
    'Nissan South Africa — Navara 2.3 Turbo Diesel Periodic Maintenance schedule (PDF, normal + severe) — '
    'https://www.nissan.co.za/content/dam/Nissan/za/Maintenance/Navara.pdf';

const String _srcMitsuAuMirage =
    'Mitsubishi Motors Australia — "21MY LA Mirage Periodic Inspection and Maintenance Schedule" — '
    'https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/MIRAGE-21MY_Maintenance-Schedule.pdf';

const String _srcMitsuAuPajeroSport =
    'Mitsubishi Motors Australia — "24MY QG Pajero Sport Inspection and Maintenance Schedule" — '
    'https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/24MY-QG-PAJERO-SPORT-MAINTENANCE-SCHEDULE-WEB.pdf';

const String _srcMitsuAuPajero =
    'Mitsubishi Motors Australia — "22MY NX Pajero Periodic Inspection and Maintenance Schedule" — '
    'https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/22MY-NX-Pajero-service-schedule.pdf';

const String _srcMitsuAuAsx =
    'Mitsubishi Motors Australia — "24MY XD ASX Inspection and Maintenance Schedule" — '
    'https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/24MY-XD-ASX-INSPECTION-AND-MAINTENANCE-SCHEDULE-WEB.pdf';

const String _srcKiaSorento =
    'Kia — 2015 Sorento (UM) Owner\'s Manual: "Normal Maintenance Schedule" + '
    '"Maintenance Under Severe Usage Conditions" (official Kia manual, OCR full text via Internet Archive) — '
    'https://archive.org/details/car-service-manuals-kia-2015-sorento';

const String _srcKiaSportage =
    'Kia — 2016 Sportage (QL) Owner\'s Manual: Normal Maintenance Schedule '
    '(official Kia manual, OCR full text via Internet Archive) — '
    'https://archive.org/details/car-service-manuals-kia-2016-sportage';

const String _srcKiaForte =
    'Kia — 2016 Forte/Cerato (YD) Owner\'s Manual: "Normal Maintenance Schedule" + '
    '"Maintenance Under Severe Usage Conditions" (official Kia manual, OCR full text via Internet Archive) — '
    'https://archive.org/details/car-service-manuals-kia-2016-forte';

const String _srcKiaRio =
    'Kia — 2016 Rio (UB) Owner\'s Manual: "Normal Maintenance Schedule" + '
    '"Maintenance Under Severe Usage Conditions" (official Kia manual, OCR full text via Internet Archive) — '
    'https://archive.org/details/car-service-manuals-kia-2016-rio';

const String _srcLexusNx200t =
    'Lexus — 2016 NX 200t Warranty and Services Guide: Scheduled Maintenance Log + '
    'Special Operating Conditions (official Lexus guide, OCR full text via Internet Archive) — '
    'https://archive.org/details/manuals-plus-2016-lexus-nx-200t-warranty-and-services-guide-11e5a98e';

// ---------------------------------------------------------------------------
// NISSAN (gap-fill: sedans/trucks)
// ---------------------------------------------------------------------------

const OemModelSchedule _nissanAlmera = OemModelSchedule(
  make: 'Nissan',
  model: 'Almera (Sunny)',
  engine: '1.5L petrol',
  fuel: 'Petrol',
  generationNote:
      'Nissan SA "Almera 1.5 Petrol" PDF — the same car sold as the Sunny in '
      'MENA markets. Full normal + severe tables; the PDF itself is undated.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanZaAlmera,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcNissanZaAlmera,
      grade: OemGrade.a,
      notes: 'Severe (dusty / short-trip / towing / idling) per severe table.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 30000,
      severity: OemSeverity.normal,
      source: _srcNissanZaAlmera,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcNissanZaAlmera,
      grade: OemGrade.a,
      notes: '"[R] at the specified mileage only" — replaced at 90,000 km.',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 150000,
      intervalKm: 75000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcNissanZaAlmera,
      grade: OemGrade.a,
      notes: 'First 150,000 km / 96 mo, then 75,000 km / 48 mo; mixture check '
          'every 30,000 km / 24 mo. Genuine NISSAN Coolant (Blue).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanZaAlmera,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcNissanZaAlmera,
      grade: OemGrade.a,
      notes: 'Severe (high-humidity) per severe table.',
    ),
    OemInterval(
      service: 'Automatic transaxle fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.severe,
      source: _srcNissanZaAlmera,
      grade: OemGrade.a,
      notes: 'Normal = inspect; severe (towing / rough roads) = replace. '
          'Fuel filter is maintenance-free.',
    ),
  ],
);

const OemModelSchedule _nissanNavara = OemModelSchedule(
  make: 'Nissan',
  model: 'Navara',
  engine: '2.3L turbo diesel (YS23)',
  fuel: 'Diesel',
  generationNote:
      'Nissan SA "Navara 2.3 Turbo Diesel" PDF (D23 generation). Full normal + '
      'severe tables; PDF undated.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
      notes: 'If the oil-replacement indicator lights, change sooner. The '
          'severe table does NOT shorten engine oil for the Navara.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 30000,
      severity: OemSeverity.normal,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
      notes: 'Replace every 30,000 km (R at 30/60/90/120); clean every '
          '5,000 km. Severe = more frequently.',
    ),
    OemInterval(
      service: 'Fuel filter',
      intervalKm: 45000,
      severity: OemSeverity.normal,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
      notes: 'Replace (R shown at 45,000 & 90,000 km); drain water at each '
          'service when the water-level lamp lights.',
    ),
    OemInterval(
      service: 'Fuel filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 150000,
      intervalKm: 75000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
      notes: 'First 150,000 km / 96 mo, then 75,000 km / 48 mo; mixture check '
          'every 30,000 km / 24 mo.',
    ),
    OemInterval(
      service: 'Drive belts',
      intervalKm: 240000,
      intervalMonths: 120,
      severity: OemSeverity.normal,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Drive belts',
      intervalKm: 120000,
      intervalMonths: 60,
      severity: OemSeverity.severe,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Timing chain',
      intervalKm: 300000,
      severity: OemSeverity.normal,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
      notes: 'Replace every 300,000 km (NOTE 3).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.severe,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
      notes: 'Normal = inspect; severe (towing / rough roads) = replace.',
    ),
    OemInterval(
      service: 'Differential gear oil',
      intervalKm: 120000,
      severity: OemSeverity.normal,
      source: _srcNissanZaNavara,
      grade: OemGrade.b,
      notes: 'Single scheduled replacement at the 120,000 km service (R in an '
          'otherwise inspect row).',
    ),
    OemInterval(
      service: 'Differential gear oil',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.severe,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Transfer fluid',
      intervalKm: 105000,
      severity: OemSeverity.normal,
      source: _srcNissanZaNavara,
      grade: OemGrade.b,
      notes: 'Single scheduled replacement at the 105,000 km service (R in an '
          'otherwise inspect row).',
    ),
    OemInterval(
      service: 'Cabin / A-C filter',
      intervalKm: 15000,
      severity: OemSeverity.normal,
      source: _srcNissanZaNavara,
      grade: OemGrade.a,
    ),
  ],
);

// ---------------------------------------------------------------------------
// MITSUBISHI (gap-fill: additional models)
// ---------------------------------------------------------------------------

const OemModelSchedule _mitsubishiMirage = OemModelSchedule(
  make: 'Mitsubishi',
  model: 'Mirage (LA)',
  yearStart: 2021,
  engine: 'Petrol (1.2 3-cyl), CVT / MT',
  fuel: 'Petrol',
  generationNote:
      'Mitsubishi AU 21MY LA Mirage. Only the schedule\'s explicit "R: Every X" '
      'text rows are recorded; the densely-packed column-marker rows (air / '
      'brake fluid) were not legible from the PDF text layer and are omitted. '
      'The Attrage sedan shares the LA platform but is not named in this '
      'document, so it is NOT covered here.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMitsuAuMirage,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      severity: OemSeverity.severe,
      source: _srcMitsuAuMirage,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs (platinum/iridium)',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuMirage,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 165000,
      intervalKm: 105000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuMirage,
      grade: OemGrade.a,
      notes: 'Petrol: first 165,000 km / 8 yr, then every 105,000 km / 5 yr.',
    ),
    OemInterval(
      service: 'Fuel filter',
      intervalKm: 150000,
      intervalMonths: 120,
      severity: OemSeverity.normal,
      source: _srcMitsuAuMirage,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'CVT / automatic transmission fluid',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuMirage,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'CVT / automatic transmission fluid',
      intervalKm: 45000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuMirage,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Manual transmission gear oil',
      intervalKm: 195000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuMirage,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Manual transmission gear oil',
      intervalKm: 90000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuMirage,
      grade: OemGrade.a,
    ),
  ],
);

const OemModelSchedule _mitsubishiPajeroSport = OemModelSchedule(
  make: 'Mitsubishi',
  model: 'Pajero Sport (QG) / Montero Sport',
  yearStart: 2024,
  engine: '2.4L turbo diesel (common rail)',
  fuel: 'Diesel',
  generationNote:
      'Mitsubishi AU 24MY QG Pajero Sport. Only the schedule\'s clean, same-line '
      'values are recorded; the dense column-marker rows were not legible from '
      'the PDF text layer.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMitsuAuPajeroSport,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      severity: OemSeverity.severe,
      source: _srcMitsuAuPajeroSport,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 165000,
      intervalKm: 105000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuPajeroSport,
      grade: OemGrade.a,
      notes: 'First 165,000 km / 8 yr, then every 105,000 km / 5 yr.',
    ),
  ],
);

const OemModelSchedule _mitsubishiPajero = OemModelSchedule(
  make: 'Mitsubishi',
  model: 'Pajero (NX) / Montero',
  yearStart: 2022,
  engine: '3.2L turbo diesel (common rail)',
  fuel: 'Diesel',
  generationNote:
      'Mitsubishi AU 22MY NX Pajero (full-size). Columns in the PDF text layer '
      'were fully collapsed; only the explicit "R: Every X" text rows are '
      'recorded.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMitsuAuPajero,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      severity: OemSeverity.severe,
      source: _srcMitsuAuPajero,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 195000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuPajero,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 90000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuPajero,
      grade: OemGrade.a,
    ),
  ],
);

const OemModelSchedule _mitsubishiAsx = OemModelSchedule(
  make: 'Mitsubishi',
  model: 'ASX (XD)',
  yearStart: 2024,
  engine: '2.0L / 2.4L petrol (MIVEC), CVT',
  fuel: 'Petrol',
  generationNote:
      'Mitsubishi AU 24MY XD ASX. Engine oil from the every-column normal row + '
      'severe "R: Every 7,500km" text; CVT fluid from the explicit "R: Every '
      '40,000km" text. Spark-plug and coolant rows were not legible and are '
      'omitted.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMitsuAuAsx,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      severity: OemSeverity.severe,
      source: _srcMitsuAuAsx,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 40000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuAsx,
      grade: OemGrade.b,
      notes: '"R: Every 40,000km" in the schedule; corroborated by the 23MY XD '
          'ASX schedule.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// KIA  (Grade B: official Kia owner's-manual text via Internet Archive OCR;
// never copied from the sibling Hyundai platform.)
// ---------------------------------------------------------------------------

const OemModelSchedule _kiaSorento = OemModelSchedule(
  make: 'Kia',
  model: 'Sorento (UM)',
  yearStart: 2015,
  engine: 'Petrol GDI (2.4 / 3.3 V6)',
  fuel: 'Petrol',
  generationNote:
      'Kia 2015 Sorento (UM) owner\'s manual, "Except Europe" gasoline schedule '
      '(normal + severe). Spark-plug normal interval was only positionally '
      'listed in the OCR and is omitted.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 12000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcKiaSorento,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 6000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcKiaSorento,
      grade: OemGrade.b,
      notes: 'Severe schedule: every 6,000 km (3,750 mi) or 6 months.',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 96000,
      intervalKm: 48000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKiaSorento,
      grade: OemGrade.b,
      notes: 'First 96,000 km (60,000 mi) / 60 mo, then every 48,000 km '
          '(30,000 mi) / 24 mo.',
    ),
    OemInterval(
      service: 'Drive belts',
      firstKm: 96000,
      intervalKm: 24000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKiaSorento,
      grade: OemGrade.b,
      notes: 'First 96,000 km / 72 mo, then every 24,000 km / 24 mo.',
    ),
    OemInterval(
      service: 'Automatic transaxle fluid',
      intervalKm: 96000,
      severity: OemSeverity.severe,
      source: _srcKiaSorento,
      grade: OemGrade.b,
      notes: 'Severe schedule: replace every 96,000 km (60,000 mi).',
    ),
    OemInterval(
      service: 'Manual transaxle fluid',
      intervalKm: 120000,
      severity: OemSeverity.severe,
      source: _srcKiaSorento,
      grade: OemGrade.b,
      notes: 'Normal = inspect every 64,000 km (40,000 mi) / 48 mo; severe = '
          'replace 120,000 km.',
    ),
    OemInterval(
      service: 'Transfer case oil (AWD)',
      intervalKm: 120000,
      severity: OemSeverity.severe,
      source: _srcKiaSorento,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Rear axle (differential) oil (AWD)',
      intervalKm: 120000,
      severity: OemSeverity.severe,
      source: _srcKiaSorento,
      grade: OemGrade.b,
    ),
  ],
);

const OemModelSchedule _kiaSportage = OemModelSchedule(
  make: 'Kia',
  model: 'Sportage (QL)',
  yearStart: 2016,
  engine: '2.4 GDI / 1.6 T-GDI petrol',
  fuel: 'Petrol',
  generationNote:
      'Kia 2016 Sportage (QL) owner\'s manual, Normal Maintenance Schedule. The '
      'severe-conditions table\'s columns were not legibly aligned in the OCR '
      'and are NOT recorded (honest gap — Lebanon should treat the normal '
      'figures as a ceiling and service sooner).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter (2.4 GDI)',
      intervalKm: 12000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcKiaSportage,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Engine oil & filter (1.6 T-GDI)',
      firstKm: 5000,
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcKiaSportage,
      grade: OemGrade.b,
      notes: 'Turbo GDI: first change 5,000 km / 6 mo, then every 8,000 km / '
          '6 mo.',
    ),
    OemInterval(
      service: 'Engine air cleaner filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcKiaSportage,
      grade: OemGrade.b,
      notes: 'Replaced at 48,000 / 96,000 / 144,000 / 192,000 km.',
    ),
  ],
);

const OemModelSchedule _kiaForte = OemModelSchedule(
  make: 'Kia',
  model: 'Cerato / Forte (YD)',
  yearStart: 2016,
  engine: 'MPI/GDI petrol & 1.6 Turbo GDI',
  fuel: 'Petrol',
  generationNote:
      'Kia 2016 Forte/Cerato (YD) owner\'s manual (normal + severe).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter (MPI/GDI)',
      intervalKm: 12000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcKiaForte,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Engine oil & filter (MPI/GDI)',
      intervalKm: 6000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcKiaForte,
      grade: OemGrade.b,
      notes: 'Severe: every 6,000 km (3,750 mi) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter (1.6 Turbo GDI)',
      firstKm: 5000,
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcKiaForte,
      grade: OemGrade.b,
      notes: 'Turbo GDI: first 5,000 km / 6 mo, then every 8,000 km / 6 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter (1.6 Turbo GDI)',
      intervalKm: 5000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcKiaForte,
      grade: OemGrade.b,
      notes: 'Severe: every 5,000 km (3,000 mi) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 192000,
      intervalKm: 48000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKiaForte,
      grade: OemGrade.b,
      notes: 'First 192,000 km (120,000 mi) / 120 mo, then every 48,000 km '
          '(30,000 mi) / 24 mo.',
    ),
    OemInterval(
      service: 'Automatic transaxle fluid',
      intervalKm: 96000,
      severity: OemSeverity.severe,
      source: _srcKiaForte,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Manual transaxle fluid',
      intervalKm: 120000,
      severity: OemSeverity.severe,
      source: _srcKiaForte,
      grade: OemGrade.b,
    ),
  ],
);

const OemModelSchedule _kiaRio = OemModelSchedule(
  make: 'Kia',
  model: 'Rio (UB)',
  yearStart: 2016,
  engine: '1.4 / 1.6 MPI petrol',
  fuel: 'Petrol',
  generationNote:
      'Kia 2016 Rio (UB) owner\'s manual (normal + severe). Normal oil is listed '
      'at the manual\'s 12,000 km service; the exact month figure for oil was '
      'not separately printed, so normal-oil months are omitted.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 12000,
      severity: OemSeverity.normal,
      source: _srcKiaRio,
      grade: OemGrade.b,
      notes: 'Replaced at the manual\'s 12,000 km (7,500 mi) service.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 6000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcKiaRio,
      grade: OemGrade.b,
      notes: 'Severe: every 6,000 km (3,750 mi) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 192000,
      intervalKm: 48000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKiaRio,
      grade: OemGrade.b,
      notes: 'First 192,000 km / 120 mo, then every 48,000 km / 24 mo.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// LEXUS  (Grade B: official Lexus Warranty & Services Guide via Internet
// Archive OCR; never copied from the Toyota equivalents.)
// ---------------------------------------------------------------------------

const OemModelSchedule _lexusNx200t = OemModelSchedule(
  make: 'Lexus',
  model: 'NX 200t (AGZ1#)',
  yearStart: 2016,
  engine: '2.0L turbo (8AR-FTS)',
  fuel: 'Petrol',
  generationNote:
      'Lexus 2016 NX 200t Warranty & Services Guide — US Scheduled Maintenance '
      'Log + Special Operating Conditions (= the "severe" schedule for Lebanon). '
      'Intervals are printed in miles; the km shown are the exact conversions '
      'the guide itself prints (e.g. 10,000 mi = 16,000 km).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcLexusNx200t,
      grade: OemGrade.b,
      notes: 'Baseline: every 12 months or 10,000 mi (16,000 km), or when the '
          'oil maintenance reminder appears.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcLexusNx200t,
      grade: OemGrade.b,
      notes: 'Special operating conditions (short cold trips, idling, dusty '
          'roads, towing): every 6 months or 5,000 mi (8,000 km).',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 64000,
      severity: OemSeverity.normal,
      source: _srcLexusNx200t,
      grade: OemGrade.b,
      notes: 'Replaced at 40,000 mi and 80,000 mi — every 40,000 mi '
          '(64,000 km) (turbo engine).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcLexusNx200t,
      grade: OemGrade.b,
      notes: 'Replaced at 30,000 mi and 60,000 mi — every 30,000 mi '
          '(48,000 km).',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcLexusNx200t,
      grade: OemGrade.b,
      notes: 'Replaced at 30,000 mi and 60,000 mi (48,000 km). Inspect more '
          'often on dirt/dusty roads (special operating conditions).',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 32000,
      severity: OemSeverity.normal,
      source: _srcLexusNx200t,
      grade: OemGrade.b,
      notes: 'Replaced at 20,000 / 40,000 / 60,000 / 80,000 mi — every '
          '20,000 mi (32,000 km).',
    ),
    OemInterval(
      service: 'Transmission fluid',
      intervalKm: 96000,
      severity: OemSeverity.normal,
      source: _srcLexusNx200t,
      grade: OemGrade.b,
      notes: 'Listed at the 60,000 mi (96,000 km) service.',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 160000,
      severity: OemSeverity.normal,
      source: _srcLexusNx200t,
      grade: OemGrade.b,
      notes: 'First replacement at 100,000 mi (160,000 km); Toyota Super '
          'Long-Life Coolant thereafter (~50,000 mi) per the guide\'s coolant '
          'note (thereafter figure not separately captured).',
    ),
  ],
);

// ===========================================================================
// GAP-FILL PASS 2 (added later): Mitsubishi Eclipse Cross / Lancer + the
// Outlander ZM coolant; Lexus RX / ES / LX; non-hybrid Toyota Corolla / Camry /
// RAV4; Nissan Altima / Sentra.
//
// Sourcing routes that unblocked this pass:
//   • Mitsubishi AU schedule PDFs (media.adtorqueedge.com) fetch cleanly; the
//     older "R: Every X" template (Eclipse Cross 20MY, Lancer MY17) and the
//     22/23MY ZM Outlander parse unambiguously with `pdftotext -table`.
//   • The Lexus/Toyota Warranty-&-Services guides on assets.sia.toyota.com
//     return HTTP 403 live (WAF/IP block), but the GENUINE publisher PDFs (not
//     OCR — native text, column-aligned) are cached on the Wayback Machine and
//     were read directly from there. Toyota RAV4 fetched live from toyota.com.
//   • Nissan Altima/Sentra come from Nissan USA's official per-model schedule
//     tool (maintenance-schedules.nissanusa.com) — a US-market schedule.
//
// All Lexus/Toyota/Nissan figures above are published in MILES; km shown are the
// OEM's own 1 mi = 1.6 km convention (e.g. Nissan prints "7,500 miles
// (12,000 km)"; Lexus prints "10,000 mi (16,000 km)"). The source mileage is
// kept in each note. No value was invented or copied across makes/models.
// ===========================================================================

const String _srcMitsuAuEclipseCross =
    'Mitsubishi Motors Australia — "20MY YA Eclipse Cross Periodic Inspection '
    'and Maintenance Schedule" (petrol 1.5T, CVT; MY19 schedule identical) — '
    'https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/ECLIPSE-CROSS-20MY-Maintenance-Schedule.pdf';

const String _srcMitsuAuLancer =
    'Mitsubishi Motors Australia — "MY17 CF Lancer Periodic Inspection and '
    'Maintenance Schedule" (2.0/2.4 petrol) — '
    'https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/LANCER-MY17_Maintenance-Schedule.pdf';

const String _srcMitsuAuOutlanderZm =
    'Mitsubishi Motors Australia — "22MY & 23MY ZM Outlander Inspection and '
    'Maintenance Schedule" (2.5 PR25 petrol; both model years print the same '
    'coolant row, same ZM generation as the 24MY entry above) — '
    'https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/22MY-ZM-Outlander-service-schedule.pdf';

const String _srcLexusRx350 =
    'Lexus — 2025 RX 350 Warranty and Services Guide: Scheduled Maintenance Log '
    '+ Special Operating Conditions (genuine publisher PDF, native text; live '
    'host assets.sia.toyota.com is 403/WAF-blocked, read via Wayback Machine) — '
    'https://web.archive.org/web/20260906010458/https://assets.sia.toyota.com/publications/en/omms-s/L-MMS-25RX350/pdf/L-MMS-25RX350.pdf';

const String _srcLexusEs =
    'Lexus — 2025 ES 250 / ES 350 Warranty and Services Guide: Scheduled '
    'Maintenance Log + Special Operating Conditions (genuine publisher PDF, '
    'native text; live host 403/WAF-blocked, read via Wayback Machine) — '
    'https://web.archive.org/web/20260906062515/https://assets.sia.toyota.com/publications/en/omms-s/L-MMS-25ES250ES350/pdf/L-MMS-25ES250ES350.pdf';

const String _srcLexusLx600 =
    'Lexus — 2023 LX 600 Warranty and Services Guide (3.5L twin-turbo V6, '
    'non-hybrid): oil + coolant only; the dense two-column maintenance pages did '
    'not column-align unambiguously for the remaining items (honest gap). '
    'Genuine publisher PDF read via Wayback Machine (live host 403) — '
    'https://web.archive.org/web/20260823000342/https://assets.sia.toyota.com/publications/en/omms-s/L-MMS-23X600/pdf/L-MMS-23X600.pdf';

const String _srcToyotaRav4 =
    'Toyota — 2023 RAV4 Warranty & Maintenance Guide (2.5L A25A petrol): '
    'Factory Scheduled Maintenance + Special Operating Conditions '
    '(fetched live from toyota.com) — '
    'https://www.toyota.com/content/dam/toyota/brochures/pdf/2023/T-MMS-23RAV4.pdf';

const String _srcToyotaCamry =
    'Toyota — 2024 Camry Warranty & Maintenance Guide (2.5L A25A petrol): '
    'Factory Scheduled Maintenance + Special Operating Conditions (genuine '
    'publisher PDF read via Wayback Machine; live host 403) — '
    'https://web.archive.org/web/20260923041010/https://assets.sia.toyota.com/publications/en/omms-s/T-MMS-24Camry/pdf/T-MMS-24Camry.pdf';

const String _srcToyotaCorolla =
    'Toyota — 2024 Corolla Warranty & Maintenance Guide (2.0L M20A petrol): '
    'Factory Scheduled Maintenance + Special Operating Conditions (genuine '
    'publisher PDF read via Wayback Machine; live host 403) — '
    'https://web.archive.org/web/20241206200326/https://assets.sia.toyota.com/publications/en/omms-s/T-MMS-24Corolla/pdf/T-MMS-24Corolla.pdf';

const String _srcNissanAltima =
    'Nissan USA — official per-model maintenance schedule tool, 2022 Altima '
    '(L34; 2.5L I4 and 2.0T). US-market schedule; intervals published in miles — '
    'https://maintenance-schedules.nissanusa.com/maintenance-schedules/2022/altima/components/';

const String _srcNissanSentra =
    'Nissan USA — official per-model maintenance schedule tool, 2019 Sentra '
    '(B17; 1.8L MRA8, CVT). US-market schedule; intervals published in miles — '
    'https://maintenance-schedules.nissanusa.com/maintenance-schedules/2019/sentra/components/';

// ---------------------------------------------------------------------------
// MITSUBISHI (gap-fill pass 2)
// ---------------------------------------------------------------------------

const OemModelSchedule _mitsubishiEclipseCross = OemModelSchedule(
  make: 'Mitsubishi',
  model: 'Eclipse Cross (YA)',
  yearStart: 2018,
  yearEnd: 2020,
  engine: '1.5L turbo petrol (4B40), CVT',
  fuel: 'Petrol',
  generationNote:
      'Mitsubishi AU 20MY YA Eclipse Cross (MY19 schedule identical). Read with '
      '`pdftotext -table`; the coolant value sits on its own "Replace engine '
      'coolant" row once table-aligned (it is NOT the air-cleaner value).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      severity: OemSeverity.severe,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs (platinum/iridium)',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 195000,
      intervalKm: 120000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
      notes: 'First 195,000 km / 10 years, thereafter every 120,000 km / 6 years '
          '(Mitsubishi Super Long Life Coolant).',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 45000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.c,
      notes: 'Positionally implied: 4 column "R" markers at 45/90/135/180k; '
          'corroborated by the identical-template Lancer (clean 6 markers @45k). '
          'Confirm exact figure before display.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.b,
      notes: 'Counted column "R" markers: 7 evenly spaced at 30/60/90/120/150/'
          '180/210k = every 30,000 km (24 mo). Severe: inspect every 7,500 km.',
    ),
    OemInterval(
      service: 'Fuel filter (petrol)',
      intervalKm: 150000,
      intervalMonths: 120,
      severity: OemSeverity.normal,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 45000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Transfer gear oil (FF-base 4WD)',
      intervalKm: 75000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Transfer gear oil (FF-base 4WD)',
      intervalKm: 45000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Front/rear differential gear oil',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Front/rear differential gear oil',
      intervalKm: 45000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuEclipseCross,
      grade: OemGrade.a,
    ),
  ],
);

const OemModelSchedule _mitsubishiLancer = OemModelSchedule(
  make: 'Mitsubishi',
  model: 'Lancer (CF)',
  yearStart: 2016,
  yearEnd: 2017,
  engine: '2.0L / 2.4L petrol (4B11/4B12)',
  fuel: 'Petrol',
  generationNote:
      'Mitsubishi AU MY17 CF Lancer. Same car (final CF generation) sold across '
      'MENA. Column "R" markers counted via `pdftotext -table`.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      severity: OemSeverity.severe,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs (platinum/iridium)',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 120000,
      intervalKm: 75000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
      notes: 'First 120,000 km / 8 years, thereafter every 75,000 km / 5 years.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 45000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
      notes: 'Column "R" markers: 6 evenly spaced at 45/90/135/180/225/270k = '
          'every 45,000 km.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
      notes: 'Column "R" markers: 10 evenly spaced at every 30,000 km (24 mo).',
    ),
    OemInterval(
      service: 'Cabin / A-C (air purifier) filter',
      intervalKm: 15000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
      notes: 'Air purifier filter replaced at every 15,000 km service.',
    ),
    OemInterval(
      service: 'Fuel filter (petrol)',
      intervalKm: 150000,
      intervalMonths: 120,
      severity: OemSeverity.normal,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Manual transmission gear oil',
      intervalKm: 195000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Manual transmission gear oil',
      intervalKm: 90000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Automatic transmission / CVT fluid',
      intervalKm: 90000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Automatic transmission / CVT fluid',
      intervalKm: 45000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuLancer,
      grade: OemGrade.a,
    ),
  ],
);

const OemModelSchedule _mitsubishiOutlanderZmCoolant = OemModelSchedule(
  make: 'Mitsubishi',
  model: 'Outlander (ZM)',
  yearStart: 2022,
  yearEnd: 2023,
  engine: '2.5L petrol (PR25 MIVEC), CVT',
  fuel: 'Petrol',
  generationNote:
      'Supplements the 24MY ZM Outlander entry above, which had the coolant row '
      'omitted. The 22MY and 23MY ZM schedules (same ZM generation, same PR25 '
      'engine) BOTH print the coolant interval cleanly via `pdftotext -table`.',
  intervals: [
    OemInterval(
      service: 'Engine coolant',
      firstKm: 150000,
      intervalKm: 75000,
      severity: OemSeverity.normal,
      source: _srcMitsuAuOutlanderZm,
      grade: OemGrade.a,
      notes: 'First 150,000 km / 8 years, thereafter every 75,000 km / 4 years '
          '(Mitsubishi Genuine Super Long Life Coolant Premium). Fills the ZM '
          'Outlander coolant gap from the 24MY entry.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMitsuAuOutlanderZm,
      grade: OemGrade.a,
      notes: 'PR25 engine; "R :30,000 km/24 months" on its own row.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// LEXUS (gap-fill pass 2 — genuine Warranty & Services Guides via Wayback;
// native-text PDFs read directly. Miles are the source; km = OEM 1 mi=1.6 km.)
// ---------------------------------------------------------------------------

const OemModelSchedule _lexusRx350 = OemModelSchedule(
  make: 'Lexus',
  model: 'RX 350 (TALA1#)',
  yearStart: 2025,
  engine: '2.4L turbo (T24A-FTS)',
  fuel: 'Petrol',
  generationNote:
      'Lexus 2025 RX 350 Warranty & Services Guide. Normal = "Recommended"; '
      'severe = "Special Operating Conditions" (= Lebanon). Automatic '
      'transmission fluid, rear-differential and transfer oils are inspect-only '
      'under normal use and replace only under towing — not recorded as '
      'replacement intervals here.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcLexusRx350,
      grade: OemGrade.a,
      notes: 'Every 12 mo / 10,000 mi (16,000 km), or when the oil maintenance '
          'reminder appears.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcLexusRx350,
      grade: OemGrade.a,
      notes: 'Special operating conditions: every 6 mo / 5,000 mi (8,000 km).',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 64000,
      severity: OemSeverity.normal,
      source: _srcLexusRx350,
      grade: OemGrade.a,
      notes: 'Replaced at 40k/80k/120k mi — every 40,000 mi (64,000 km) '
          '(turbo engine).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcLexusRx350,
      grade: OemGrade.a,
      notes: 'Replaced at every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcLexusRx350,
      grade: OemGrade.a,
      notes: 'Every 30,000 mi (48,000 km); inspect more often on dusty roads '
          '(special operating conditions).',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 16000,
      severity: OemSeverity.normal,
      source: _srcLexusRx350,
      grade: OemGrade.a,
      notes: 'Every 10,000 mi (16,000 km).',
    ),
    OemInterval(
      service: 'Engine coolant (engine & intercooler)',
      firstKm: 160000,
      intervalKm: 80000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcLexusRx350,
      grade: OemGrade.a,
      notes: 'Footnote: initial at 100,000 mi (160,000 km) / 120 mo, then every '
          '50,000 mi (80,000 km) / 60 mo.',
    ),
  ],
);

const OemModelSchedule _lexusEs = OemModelSchedule(
  make: 'Lexus',
  model: 'ES 250 / ES 350 (AXZ1#)',
  yearStart: 2025,
  engine: '2.5L (A25A) / 3.5L V6 (2GR-FKS), naturally aspirated',
  fuel: 'Petrol',
  generationNote:
      'Lexus 2025 ES 250 / ES 350 Warranty & Services Guide. Normal = '
      '"Recommended"; severe = "Special Operating Conditions". ATF, rear-diff '
      'and transfer oils (ES 250 AWD) are inspect-only normal / replace under '
      'towing — not recorded as replacement intervals here.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcLexusEs,
      grade: OemGrade.a,
      notes: 'Every 12 mo / 10,000 mi (16,000 km), or when the reminder appears.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcLexusEs,
      grade: OemGrade.a,
      notes: 'Special operating conditions: every 6 mo / 5,000 mi (8,000 km).',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 192000,
      severity: OemSeverity.normal,
      source: _srcLexusEs,
      grade: OemGrade.a,
      notes: 'Replaced at 120,000 mi (192,000 km) (naturally-aspirated engine).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcLexusEs,
      grade: OemGrade.a,
      notes: 'Every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcLexusEs,
      grade: OemGrade.a,
      notes: 'Every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 16000,
      severity: OemSeverity.normal,
      source: _srcLexusEs,
      grade: OemGrade.a,
      notes: 'Every 10,000 mi (16,000 km).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 160000,
      intervalKm: 80000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcLexusEs,
      grade: OemGrade.a,
      notes: 'Initial at 100,000 mi (160,000 km) / 120 mo, then every 50,000 mi '
          '(80,000 km) / 60 mo.',
    ),
  ],
);

const OemModelSchedule _lexusLx600 = OemModelSchedule(
  make: 'Lexus',
  model: 'LX 600 (J310)',
  yearStart: 2023,
  engine: '3.5L twin-turbo V6 (F33A-FTS)',
  fuel: 'Petrol',
  generationNote:
      'Lexus 2023 LX 600 Warranty & Services Guide (non-hybrid). Only oil and '
      'coolant are recorded: the guide\'s dense two-column maintenance pages did '
      'not column-align unambiguously for brake fluid / air filters / spark '
      'plugs / transfer oil, so those are left as an honest gap.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcLexusLx600,
      grade: OemGrade.a,
      notes: 'Every 12 mo / 10,000 mi (16,000 km), or when the reminder appears.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcLexusLx600,
      grade: OemGrade.a,
      notes: 'Special operating conditions: every 6 mo / 5,000 mi (8,000 km).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 160000,
      intervalKm: 80000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcLexusLx600,
      grade: OemGrade.a,
      notes: 'Guide note: initial at 100,000 mi (160,000 km) / 120 mo, then '
          'every 50,000 mi (80,000 km).',
    ),
  ],
);

// ---------------------------------------------------------------------------
// TOYOTA non-hybrid (gap-fill pass 2 — per-model Warranty & Maintenance Guides.
// Oil interval assumes factory 0W-16 fill (10,000 mi); if 0W-20 is used the
// normal oil interval shortens to 5,000 mi per the guide footnote.)
// ---------------------------------------------------------------------------

const OemModelSchedule _toyotaRav4 = OemModelSchedule(
  make: 'Toyota',
  model: 'RAV4',
  yearStart: 2023,
  engine: '2.5L petrol (A25A-FKS)',
  fuel: 'Petrol',
  generationNote:
      'Toyota 2023 RAV4 (non-hybrid). Factory Scheduled Maintenance (normal) + '
      'Special Operating Conditions (severe). ATF / rear-diff / transfer oils '
      'are inspect-only normal; ATF replaced at 60,000 mi under towing/idling.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcToyotaRav4,
      grade: OemGrade.a,
      notes: 'Every 10,000 mi (16,000 km) / 12 mo with factory 0W-16; with '
          '0W-20, every 5,000 mi (8,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcToyotaRav4,
      grade: OemGrade.a,
      notes: 'Special operating conditions (dusty, short trips, idling, towing): '
          'every 5,000 mi (8,000 km) / 6 mo regardless of oil grade.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcToyotaRav4,
      grade: OemGrade.a,
      notes: 'Replaced at every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcToyotaRav4,
      grade: OemGrade.a,
      notes: 'Replaced at every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 192000,
      severity: OemSeverity.normal,
      source: _srcToyotaRav4,
      grade: OemGrade.a,
      notes: 'Replaced at 120,000 mi (192,000 km).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 160000,
      intervalKm: 80000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcToyotaRav4,
      grade: OemGrade.a,
      notes: 'Super Long-Life Coolant: initial at 100,000 mi (160,000 km) / '
          '120 mo, then every 50,000 mi (80,000 km) / 60 mo.',
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 96000,
      severity: OemSeverity.severe,
      source: _srcToyotaRav4,
      grade: OemGrade.a,
      notes: 'Normal = inspect; severe (towing / extensive idling) = replace at '
          '60,000 mi (96,000 km).',
    ),
  ],
);

const OemModelSchedule _toyotaCamry = OemModelSchedule(
  make: 'Toyota',
  model: 'Camry',
  yearStart: 2024,
  engine: '2.5L petrol (A25A-FKS)',
  fuel: 'Petrol',
  generationNote:
      'Toyota 2024 Camry (non-hybrid 2.5L). Note: this guide lists spark plugs '
      'at the 60,000-mi milestone (not 120,000 like the RAV4/Corolla) — recorded '
      'as read. Cabin-filter milestone was not legible on the two-column pages '
      'and is omitted (gap).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcToyotaCamry,
      grade: OemGrade.a,
      notes: 'Every 10,000 mi (16,000 km) / 12 mo with factory 0W-16; with '
          '0W-20, every 5,000 mi (8,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcToyotaCamry,
      grade: OemGrade.a,
      notes: 'Special operating conditions: every 5,000 mi (8,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcToyotaCamry,
      grade: OemGrade.a,
      notes: 'Replaced at every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 96000,
      severity: OemSeverity.normal,
      source: _srcToyotaCamry,
      grade: OemGrade.a,
      notes: 'Replaced at 60,000 mi and 120,000 mi — every 60,000 mi '
          '(96,000 km) per this guide.',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 160000,
      intervalKm: 80000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcToyotaCamry,
      grade: OemGrade.a,
      notes: 'Initial at 100,000 mi (160,000 km) / 120 mo, then every 50,000 mi '
          '(80,000 km) / 60 mo.',
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 96000,
      severity: OemSeverity.severe,
      source: _srcToyotaCamry,
      grade: OemGrade.a,
      notes: 'Normal = inspect; severe (towing / idling) = replace at 60,000 mi '
          '(96,000 km).',
    ),
  ],
);

const OemModelSchedule _toyotaCorolla = OemModelSchedule(
  make: 'Toyota',
  model: 'Corolla',
  yearStart: 2024,
  engine: '2.0L petrol (M20A-FKS)',
  fuel: 'Petrol',
  generationNote:
      'Toyota 2024 Corolla (non-hybrid 2.0L). Factory Scheduled Maintenance + '
      'Special Operating Conditions. ATF inspect-only normal / replace under '
      'towing.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcToyotaCorolla,
      grade: OemGrade.a,
      notes: 'Every 10,000 mi (16,000 km) / 12 mo with factory 0W-16; with '
          '0W-20, every 5,000 mi (8,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcToyotaCorolla,
      grade: OemGrade.a,
      notes: 'Special operating conditions: every 5,000 mi (8,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcToyotaCorolla,
      grade: OemGrade.a,
      notes: 'Replaced at every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcToyotaCorolla,
      grade: OemGrade.a,
      notes: 'Replaced at every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 192000,
      severity: OemSeverity.normal,
      source: _srcToyotaCorolla,
      grade: OemGrade.a,
      notes: 'Replaced at 120,000 mi (192,000 km).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 160000,
      intervalKm: 80000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcToyotaCorolla,
      grade: OemGrade.a,
      notes: 'Initial at 100,000 mi (160,000 km) / 120 mo, then every 50,000 mi '
          '(80,000 km) / 60 mo.',
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 96000,
      severity: OemSeverity.severe,
      source: _srcToyotaCorolla,
      grade: OemGrade.a,
      notes: 'Normal = inspect; severe (towing / idling) = replace at 60,000 mi '
          '(96,000 km).',
    ),
  ],
);

// ---------------------------------------------------------------------------
// NISSAN (gap-fill pass 2 — Nissan USA official schedule tool; US-market.
// Intervals published in miles; km = Nissan's own 1 mi = 1.6 km convention.)
// ---------------------------------------------------------------------------

const OemModelSchedule _nissanAltima = OemModelSchedule(
  make: 'Nissan',
  model: 'Altima (L34)',
  yearStart: 2022,
  engine: '2.5L petrol (PR25DD); 2.0T values in notes',
  fuel: 'Petrol',
  generationNote:
      'Nissan USA 2022 Altima schedule tool (US-market). Figures below are the '
      '2.5L I4; the 2.0T turbo differs on oil (7,500 mi) and brake fluid '
      '(15,000 mi) as noted. Same intervals apply to normal & severe except '
      'where a severe figure is given.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanAltima,
      grade: OemGrade.a,
      notes: '2.5L: every 10,000 mi (16,000 km) / 12 mo (normal = severe). '
          '2.0T: every 7,500 mi (12,000 km) / 12 mo.',
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 168000,
      intervalMonths: 126,
      severity: OemSeverity.normal,
      source: _srcNissanAltima,
      grade: OemGrade.a,
      notes: 'Every 105,000 mi (168,000 km): 2.5L /126 mo, 2.0T /168 mo '
          '(normal = severe).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 168000,
      intervalKm: 120000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcNissanAltima,
      grade: OemGrade.a,
      notes: 'Initial at 105,000 mi (168,000 km) / 84 mo, then every 75,000 mi '
          '(120,000 km) / 60 mo (normal = severe).',
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 96000,
      intervalMonths: 72,
      severity: OemSeverity.severe,
      source: _srcNissanAltima,
      grade: OemGrade.a,
      notes: 'Normal = inspect every 10,000 mi; severe = replace every 60,000 mi '
          '(96,000 km) / 72 mo. Genuine NISSAN CVT Fluid only.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 32000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanAltima,
      grade: OemGrade.a,
      notes: '2.5L: 20,000 mi (32,000 km) / 24 mo. 2.0T: 15,000 mi (24,000 km).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcNissanAltima,
      grade: OemGrade.a,
      notes: '2.5L severe: 10,000 mi (16,000 km) / 12 mo. 2.0T: 7,500 mi.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 48000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcNissanAltima,
      grade: OemGrade.a,
      notes: 'Every 30,000 mi (48,000 km): 2.5L /36 mo, 2.0T /48 mo. Severe '
          '(dusty) = more frequently.',
    ),
  ],
);

const OemModelSchedule _nissanSentra = OemModelSchedule(
  make: 'Nissan',
  model: 'Sentra (B17)',
  yearStart: 2013,
  yearEnd: 2019,
  engine: '1.8L petrol (MRA8DE), CVT',
  fuel: 'Petrol',
  generationNote:
      'Nissan USA 2019 Sentra schedule tool (B17 generation, US-market). '
      'Intervals are the same under normal and severe except CVT fluid.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcNissanSentra,
      grade: OemGrade.a,
      notes: 'Every 5,000 mi (8,000 km) / 6 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 168000,
      severity: OemSeverity.normal,
      source: _srcNissanSentra,
      grade: OemGrade.a,
      notes: 'Every 105,000 mi (168,000 km) (normal = severe).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 168000,
      intervalKm: 120000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcNissanSentra,
      grade: OemGrade.a,
      notes: 'Initial at 105,000 mi (168,000 km) / 84 mo, then every 75,000 mi '
          '(120,000 km) / 60 mo.',
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 96000,
      severity: OemSeverity.severe,
      source: _srcNissanSentra,
      grade: OemGrade.a,
      notes: 'Normal = inspect every 10,000 mi; severe = replace every 60,000 mi '
          '(96,000 km). Genuine NISSAN CVT Fluid only.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 48000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcNissanSentra,
      grade: OemGrade.a,
      notes: 'Every 30,000 mi (48,000 km) / 36 mo (normal = severe).',
    ),
  ],
);

// ===========================================================================
// GAP-FILL PASS 3 (added later): Infiniti (Q50 / QX60 / QX80), Genesis
// (G70 / G80 / GV70 / GV80 gasoline), Kia Picanto, Nissan Patrol (Y62), and a
// make-wide conventional-petrol Toyota schedule (covers Hilux / Land Cruiser /
// Prado petrol among others).
//
// Sourcing routes (GCC/MENA + Australia/NZ + official schedule tools):
//   • Infiniti — Infiniti USA's official per-model schedule tool
//     (maintenance-schedules.infinitiusa.com), the Nissan-family sibling of the
//     Nissan tool used in pass 2. US-market; miles, 1 mi = 1.6 km.
//   • Genesis — Genesis Canada "Service Maintenance Schedules" PDF (metric km),
//     which lists G70/G80/GV70/GV80 explicitly. The gasoline models share one
//     set of long-interval figures (oil 10,000 km, plugs 70,000 km, LSD diff
//     60,000 km). EV variants were excluded.
//   • Kia Picanto — the genuine Kia Australia owner's manual (kia.com, native
//     text once the subset-font byte offset is undone via PyMuPDF).
//   • Nissan Patrol Y62 — Nissan NZ Capped Price Service document (VK56VD V8),
//     which prints the normal-conditions schedule + notes.
//   • Toyota conventional petrol — Toyota NZ "Service Requirements: Petrol
//     Vehicles" (Sept 2023), the non-hybrid sibling of the pass-1 hybrid sheet;
//     make-wide (so Hilux/LC/Prado petrol fall under it), not per-model.
//
// No value was invented or copied across makes/models. Honest gaps remain:
// Kia Seltos (AU manual URL 404s / moved), Lexus IS (no reachable guide), Honda
// per-model (only the make-wide Maintenance-Minder schedule exists), and the
// per-model Hilux/LC/Prado spark-plug figures (the NZ sheet is make-wide).
// ===========================================================================

const String _srcInfinitiQ50 =
    'Infiniti USA — official per-model maintenance schedule tool, 2022 Q50 '
    '(V37; 3.0L twin-turbo V6 VR30DDTT). US-market; intervals in miles — '
    'https://maintenance-schedules.infinitiusa.com/maintenance-schedules/2022/q50/components/';

const String _srcInfinitiQx60 =
    'Infiniti USA — official per-model maintenance schedule tool, 2022 QX60 '
    '(L51; 3.5L V6 VQ35DD). US-market; intervals in miles — '
    'https://maintenance-schedules.infinitiusa.com/maintenance-schedules/2022/qx60/components/';

const String _srcInfinitiQx80 =
    'Infiniti USA — official per-model maintenance schedule tool, 2022 QX80 '
    '(Z62; 5.6L V8 VK56VD). US-market; intervals in miles — '
    'https://maintenance-schedules.infinitiusa.com/maintenance-schedules/2022/qx80/components/';

const String _srcGenesisCaSchedule =
    'Genesis Canada — "Service Maintenance Schedules" (metric; lists G70, G80, '
    'GV70, GV80 gasoline explicitly) — '
    'https://www.genesis.com/content/dam/genesis-p2/ca/assets/owners/owners-resources/documents/Genesis-Service-Maintenance-Schedules-EN.pdf';

const String _srcKiaPicantoAu =
    'Kia — Picanto MY24 Owner\'s Manual (Australia/NZ), "Normal Maintenance '
    'Schedule - For petrol Engine" + "Maintenance Under Severe Usage Conditions" '
    '(1.2 MPI petrol; genuine kia.com PDF, native text via PyMuPDF) — '
    'https://www.kia.com/content/dam/kwcms/au/en/files/owners-manuals/picanto/kia-picanto-owners-manual-my24.pdf';

const String _srcNissanPatrolNz =
    'Nissan New Zealand — "Capped Price Service Program: Patrol Y62 Series" '
    '(VK56VD V8, normal-conditions 10,000 km/12 mo schedule + Notes) — '
    'https://www.nissan.co.nz/content/dam/Nissan/new-zealand/files/Owners/Servicing/capped-price-service/Y62%20-%20Patrol%20Capped%20Price%20Service.pdf';

const String _srcToyotaNzPetrol =
    'Toyota New Zealand — "Service Requirements: Petrol Vehicles" (v. Sept 2023); '
    'make-wide conventional-petrol schedule (covers Hilux / Land Cruiser / Prado '
    'petrol among others), normal conditions — '
    'https://www.toyota.co.nz/globalassets/owners/servicing-your-toyota/toyota-petrol-service-requirements.pdf';

// ---------------------------------------------------------------------------
// INFINITI (gap-fill pass 3 — Infiniti USA schedule tool; US-market.
// Intervals in miles; km = 1 mi = 1.6 km, with source mileage in each note.)
// ---------------------------------------------------------------------------

const OemModelSchedule _infinitiQ50 = OemModelSchedule(
  make: 'Infiniti',
  model: 'Q50 (V37)',
  yearStart: 2022,
  engine: '3.0L twin-turbo V6 (VR30DDTT)',
  fuel: 'Petrol',
  generationNote:
      'Infiniti USA 2022 Q50 schedule tool (US-market). Automatic-transmission '
      'fluid is not a scheduled component in the tool (lifetime fill). Same '
      'interval for normal & severe except brake fluid.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcInfinitiQ50,
      grade: OemGrade.a,
      notes: 'Every 10,000 mi (16,000 km) / 12 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 168000,
      intervalMonths: 126,
      severity: OemSeverity.normal,
      source: _srcInfinitiQ50,
      grade: OemGrade.a,
      notes: 'Every 105,000 mi (168,000 km) / 126 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 168000,
      intervalKm: 120000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcInfinitiQ50,
      grade: OemGrade.a,
      notes: 'Initial at 105,000 mi (168,000 km) / 84 mo, then every 75,000 mi '
          '(120,000 km) / 60 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 32000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcInfinitiQ50,
      grade: OemGrade.a,
      notes: 'Every 20,000 mi (32,000 km) / 24 mo.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcInfinitiQ50,
      grade: OemGrade.a,
      notes: 'Severe: every 10,000 mi (16,000 km) / 12 mo.',
    ),
  ],
);

const OemModelSchedule _infinitiQx60 = OemModelSchedule(
  make: 'Infiniti',
  model: 'QX60 (L51)',
  yearStart: 2022,
  engine: '3.5L V6 (VQ35DD)',
  fuel: 'Petrol',
  generationNote:
      'Infiniti USA 2022 QX60 schedule tool (US-market). Same interval for '
      'normal & severe except brake fluid.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcInfinitiQx60,
      grade: OemGrade.a,
      notes: 'Every 10,000 mi (16,000 km) / 12 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 168000,
      intervalMonths: 126,
      severity: OemSeverity.normal,
      source: _srcInfinitiQx60,
      grade: OemGrade.a,
      notes: 'Every 105,000 mi (168,000 km) / 126 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 168000,
      intervalKm: 120000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcInfinitiQx60,
      grade: OemGrade.a,
      notes: 'Initial at 105,000 mi (168,000 km) / 84 mo, then every 75,000 mi '
          '(120,000 km) / 60 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 32000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcInfinitiQx60,
      grade: OemGrade.a,
      notes: 'Every 20,000 mi (32,000 km) / 24 mo.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcInfinitiQx60,
      grade: OemGrade.a,
      notes: 'Severe: every 10,000 mi (16,000 km) / 12 mo.',
    ),
  ],
);

const OemModelSchedule _infinitiQx80 = OemModelSchedule(
  make: 'Infiniti',
  model: 'QX80 (Z62)',
  yearStart: 2022,
  engine: '5.6L V8 (VK56VD)',
  fuel: 'Petrol',
  generationNote:
      'Infiniti USA 2022 QX80 schedule tool (US-market). The V8 has a shorter '
      'oil interval than the V6 models.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 12000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcInfinitiQx80,
      grade: OemGrade.a,
      notes: 'Normal: every 7,500 mi (12,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcInfinitiQx80,
      grade: OemGrade.a,
      notes: 'Severe: every 5,000 mi (8,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 168000,
      intervalMonths: 84,
      severity: OemSeverity.normal,
      source: _srcInfinitiQx80,
      grade: OemGrade.a,
      notes: 'Every 105,000 mi (168,000 km) / 84 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 168000,
      intervalKm: 120000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcInfinitiQx80,
      grade: OemGrade.a,
      notes: 'Initial at 105,000 mi (168,000 km) / 84 mo, then every 75,000 mi '
          '(120,000 km) / 60 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 48000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcInfinitiQx80,
      grade: OemGrade.a,
      notes: 'Every 30,000 mi (48,000 km) / 24 mo.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcInfinitiQx80,
      grade: OemGrade.a,
      notes: 'Severe: every 10,000 mi (16,000 km) / 12 mo.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// GENESIS (gap-fill pass 3 — Genesis Canada Service Maintenance Schedules.
// The gasoline G70/G80/GV70/GV80 share one set of long-interval figures;
// recorded once as a range. EV variants excluded. Metric (km) native.)
// ---------------------------------------------------------------------------

const OemModelSchedule _genesisGasolineRange = OemModelSchedule(
  make: 'Genesis',
  model: 'G70 / G80 / GV70 / GV80 (gasoline)',
  engine: 'Turbo & NA petrol (G70 2.0T/3.3T, G80 2.5T/3.5, GV70 2.5T/3.5, '
      'GV80 2.5T/3.5)',
  fuel: 'Petrol',
  generationNote:
      'Genesis Canada "Service Maintenance Schedules" lists each gasoline model '
      'with the SAME long-interval figures, so they are recorded once. The doc '
      'is a complimentary-maintenance schedule; engine oil is replaced at every '
      '10,000 km service. Coolant and brake-fluid intervals are not stated for '
      'the gasoline models in this doc (EV-only) — left as a gap. EV variants '
      'excluded. No value copied from the Hyundai platform.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcGenesisCaSchedule,
      grade: OemGrade.a,
      notes: 'Replaced at every service (10,000 km / 12 months) through the '
          '100,000 km complimentary schedule.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 70000,
      intervalMonths: 84,
      severity: OemSeverity.normal,
      source: _srcGenesisCaSchedule,
      grade: OemGrade.a,
      notes: 'Replace every 70,000 km / 84 months (all gasoline G70/G80/GV70/'
          'GV80 variants).',
    ),
    OemInterval(
      service: 'Differential oil (LSD, AWD)',
      intervalKm: 60000,
      intervalMonths: 72,
      severity: OemSeverity.normal,
      source: _srcGenesisCaSchedule,
      grade: OemGrade.a,
      notes: 'Replace differential oil with LSD every 60,000 km / 72 months '
          '(AWD models).',
    ),
  ],
);

// ---------------------------------------------------------------------------
// KIA (gap-fill pass 3 — genuine Kia AU owner's manual, Picanto)
// ---------------------------------------------------------------------------

const OemModelSchedule _kiaPicanto = OemModelSchedule(
  make: 'Kia',
  model: 'Picanto (JA)',
  engine: '1.2L MPI petrol',
  fuel: 'Petrol',
  generationNote:
      'Kia Picanto MY24 owner\'s manual, AU/NZ petrol "Normal Maintenance '
      'Schedule" + "Maintenance Under Severe Usage Conditions (Non-Turbo)". '
      'Read via PyMuPDF (the manual uses a subset font that pdftotext garbles).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcKiaPicantoAu,
      grade: OemGrade.a,
      notes: 'R at every 15,000 km column (15/30/45…120k) = every 15,000 km / '
          '12 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcKiaPicantoAu,
      grade: OemGrade.a,
      notes: 'Severe usage (conditions A–L): every 7,500 km or 6 months.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 150000,
      severity: OemSeverity.normal,
      source: _srcKiaPicantoAu,
      grade: OemGrade.a,
      notes: 'Replace every 150,000 km (1.2 MPI unleaded). Severe = "more '
          'frequently" (not quantified).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 180000,
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKiaPicantoAu,
      grade: OemGrade.a,
      notes: 'At first replace 180,000 km / 120 mo, after that replace every '
          '30,000 km / 24 months.',
    ),
    OemInterval(
      service: 'Air cleaner filter',
      intervalKm: 45000,
      severity: OemSeverity.normal,
      source: _srcKiaPicantoAu,
      grade: OemGrade.a,
      notes: 'R at the 45,000 km and 90,000 km columns = every 45,000 km.',
    ),
    OemInterval(
      service: 'Climate control (cabin) air filter',
      intervalKm: 30000,
      severity: OemSeverity.normal,
      source: _srcKiaPicantoAu,
      grade: OemGrade.a,
      notes: 'R at 30/60/90/120k columns = every 30,000 km.',
    ),
    OemInterval(
      service: 'Manual transmission fluid',
      intervalKm: 120000,
      severity: OemSeverity.severe,
      source: _srcKiaPicantoAu,
      grade: OemGrade.a,
      notes: 'Normal = no service required; severe = every 120,000 km.',
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 90000,
      severity: OemSeverity.severe,
      source: _srcKiaPicantoAu,
      grade: OemGrade.a,
      notes: 'Normal = no service required; severe = every 90,000 km.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// NISSAN PATROL (gap-fill pass 3 — Nissan NZ capped-price service, Y62 V8)
// ---------------------------------------------------------------------------

const OemModelSchedule _nissanPatrol = OemModelSchedule(
  make: 'Nissan',
  model: 'Patrol (Y62)',
  engine: '5.6L V8 petrol (VK56VD)',
  fuel: 'Petrol',
  generationNote:
      'Nissan NZ Capped Price Service document, Y62 Patrol (VK56VD V8). '
      'Normal-conditions 10,000 km / 12 month schedule; severe shortens (the '
      'doc flags diamond items for more-frequent service but does not quantify).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanPatrolNz,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 160000,
      intervalKm: 80000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcNissanPatrolNz,
      grade: OemGrade.a,
      notes: 'Note-3: first replacement 160,000 km / 96 mo, after first replace '
          'every 80,000 km / 48 mo. Mixture-ratio check every 40,000 km / 24 mo.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanPatrolNz,
      grade: OemGrade.a,
      notes: 'Brake fluid replaced every 40,000 km / 24 months.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 100000,
      severity: OemSeverity.normal,
      source: _srcNissanPatrolNz,
      grade: OemGrade.b,
      notes: 'Single "R" at the 100,000 km service. Note-5: replace sooner if '
          'plug gap exceeds 1.25 mm.',
    ),
    OemInterval(
      service: 'Engine air cleaner filter',
      intervalKm: 40000,
      severity: OemSeverity.normal,
      source: _srcNissanPatrolNz,
      grade: OemGrade.b,
      notes: '"R" markers at 40/80/120k (inspect between) = every 40,000 km.',
    ),
    OemInterval(
      service: 'Differential gear oil',
      intervalKm: 40000,
      severity: OemSeverity.normal,
      source: _srcNissanPatrolNz,
      grade: OemGrade.b,
      notes: '"R" markers at 40/80/120k (inspect between) = every 40,000 km.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// TOYOTA conventional petrol (gap-fill pass 3 — Toyota NZ make-wide sheet;
// covers Hilux / Land Cruiser / Prado petrol among others. Per-model
// spark-plug / transmission figures are NOT isolated here — honest gap.)
// ---------------------------------------------------------------------------

const OemModelSchedule _toyotaNzPetrol = OemModelSchedule(
  make: 'Toyota',
  model: 'Conventional petrol range (incl. Hilux / Land Cruiser / Prado petrol)',
  engine: 'Conventional petrol (non-hybrid), excl. GR models',
  fuel: 'Petrol',
  generationNote:
      'Toyota NZ "Service Requirements: Petrol Vehicles" (Sept 2023), make-wide '
      'for conventional petrol Toyotas. Only the unambiguous figures are '
      'recorded: engine oil (every service) and the coolant subsequent interval. '
      'Spark-plug km is "at specified Kms only" (not printed) and the A–G coded '
      'brake/ATF/transfer grid is not recorded per the GOLDEN RULE. Severe = '
      '"shorten normal interval" (not quantified).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcToyotaNzPetrol,
      grade: OemGrade.a,
      notes: 'R at every service (15,000 km / 12 months) under normal '
          'conditions; severe shortens.',
    ),
    OemInterval(
      service: 'Engine/heater coolant',
      firstKm: 150000,
      intervalKm: 75000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcToyotaNzPetrol,
      grade: OemGrade.c,
      notes: 'Sheet states "then every 75,000 km / 5 years" (Grade A for the '
          'subsequent interval); first replacement is positionally ~150,000 km '
          'in the coded grid (Grade C) — confirm before display.',
    ),
  ],
);

// ===========================================================================
// GAP-FILL PASS 4 (added later, OLX-Lebanon market scan): Nissan Rogue (US
// X-Trail sibling) and Kicks; Toyota Tacoma petrol; and the Lexus LX 600
// non-oil items that were previously illegible (now read with column-aware
// PyMuPDF + pdftotext -table on the same guide).
//
// Routes: Nissan USA schedule tool (miles, 1 mi = 1.6 km); Toyota Tacoma guide
// fetched live from toyota.com. No value invented or cross-copied. Honest gap:
// Nissan Magnite (India/MENA small SUV) is not on any reachable Nissan host
// (404 on the SA CDN, absent from the US tool).
// ===========================================================================

const String _srcNissanRogue =
    'Nissan USA — official per-model maintenance schedule tool, 2023 Rogue '
    '(T33; 1.5L VC-Turbo 3-cyl KR15DDT — the US sibling of the X-Trail). '
    'US-market; intervals in miles — '
    'https://maintenance-schedules.nissanusa.com/maintenance-schedules/2023/rogue/components/';

const String _srcNissanKicks =
    'Nissan USA — official per-model maintenance schedule tool, 2023 Kicks '
    '(P15; 1.6L NA HR16DE, CVT). US-market; intervals in miles — '
    'https://maintenance-schedules.nissanusa.com/maintenance-schedules/2023/kicks/components/';

const String _srcToyotaTacoma =
    'Toyota — 2023 Tacoma Warranty & Maintenance Guide (2.7L 2TR-FE / 3.5L V6 '
    '2GR-FKS petrol): Factory Scheduled Maintenance + Special Operating '
    'Conditions (fetched live from toyota.com) — '
    'https://www.toyota.com/content/dam/toyota/brochures/pdf/2023/T-MMS-23Tacoma.pdf';

// ---------------------------------------------------------------------------
// NISSAN (gap-fill pass 4 — Nissan USA schedule tool; US-market.
// Intervals in miles; km = 1 mi = 1.6 km, with source mileage in each note.)
// ---------------------------------------------------------------------------

const OemModelSchedule _nissanRogue = OemModelSchedule(
  make: 'Nissan',
  model: 'Rogue (T33)',
  yearStart: 2023,
  engine: '1.5L VC-Turbo 3-cyl (KR15DDT)',
  fuel: 'Petrol',
  generationNote:
      'Nissan USA 2023 Rogue schedule tool (US-market). The Rogue is the US '
      'sibling of the X-Trail (T33). Turbo engine — note the shorter 60,000 mi '
      'spark-plug interval vs the NA Nissans\' 105,000 mi.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 12000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcNissanRogue,
      grade: OemGrade.a,
      notes: 'Every 7,500 mi (12,000 km) / 12 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 96000,
      intervalMonths: 96,
      severity: OemSeverity.normal,
      source: _srcNissanRogue,
      grade: OemGrade.a,
      notes: 'Every 60,000 mi (96,000 km) / 96 mo (turbo engine; normal = '
          'severe).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 168000,
      intervalKm: 120000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcNissanRogue,
      grade: OemGrade.a,
      notes: 'Initial at 105,000 mi (168,000 km) / 84 mo, then every 75,000 mi '
          '(120,000 km) / 60 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 24000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanRogue,
      grade: OemGrade.a,
      notes: 'Every 15,000 mi (24,000 km) / 24 mo.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 12000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcNissanRogue,
      grade: OemGrade.a,
      notes: 'Severe: every 7,500 mi (12,000 km) / 12 mo.',
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 96000,
      severity: OemSeverity.severe,
      source: _srcNissanRogue,
      grade: OemGrade.a,
      notes: 'Normal = inspect every 7,500 mi; severe = replace every 60,000 mi '
          '(96,000 km). Genuine NISSAN CVT Fluid only.',
    ),
  ],
);

const OemModelSchedule _nissanKicks = OemModelSchedule(
  make: 'Nissan',
  model: 'Kicks (P15)',
  yearStart: 2023,
  engine: '1.6L NA (HR16DE), CVT',
  fuel: 'Petrol',
  generationNote:
      'Nissan USA 2023 Kicks schedule tool (US-market). Same NA engine family '
      'as the older Sentra B17 (105,000 mi plugs).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 12000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcNissanKicks,
      grade: OemGrade.a,
      notes: 'Normal: every 7,500 mi (12,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcNissanKicks,
      grade: OemGrade.a,
      notes: 'Severe: every 5,000 mi (8,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Spark plugs (iridium)',
      intervalKm: 168000,
      intervalMonths: 84,
      severity: OemSeverity.normal,
      source: _srcNissanKicks,
      grade: OemGrade.a,
      notes: 'Every 105,000 mi (168,000 km) / 84 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 168000,
      intervalKm: 120000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcNissanKicks,
      grade: OemGrade.a,
      notes: 'Initial at 105,000 mi (168,000 km) / 84 mo, then every 75,000 mi '
          '(120,000 km) / 60 mo (normal = severe).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 48000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcNissanKicks,
      grade: OemGrade.a,
      notes: 'Every 30,000 mi (48,000 km) / 24 mo.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.severe,
      source: _srcNissanKicks,
      grade: OemGrade.a,
      notes: 'Severe: every 10,000 mi (16,000 km) / 12 mo.',
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 96000,
      intervalMonths: 72,
      severity: OemSeverity.severe,
      source: _srcNissanKicks,
      grade: OemGrade.a,
      notes: 'Normal = inspect every 15,000 mi; severe = replace every 60,000 mi '
          '(96,000 km) / 72 mo. Genuine NISSAN CVT Fluid only.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// TOYOTA Tacoma (gap-fill pass 4 — 2023 Warranty & Maintenance Guide, petrol)
// ---------------------------------------------------------------------------

const OemModelSchedule _toyotaTacoma = OemModelSchedule(
  make: 'Toyota',
  model: 'Tacoma',
  yearStart: 2023,
  engine: '3.5L V6 (2GR-FKS); 2.7L I4 (2TR-FE) spark-plug note',
  fuel: 'Petrol',
  generationNote:
      'Toyota 2023 Tacoma (petrol). Factory Scheduled Maintenance (normal) + '
      'Special Operating Conditions (severe). ATF / front & rear differential / '
      'transfer oils are inspect-only under normal use; replaced under towing.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcToyotaTacoma,
      grade: OemGrade.a,
      notes: 'Every 10,000 mi (16,000 km) / 12 mo with factory 0W-20; if 0W-20 '
          'not used, every 5,000 mi (8,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcToyotaTacoma,
      grade: OemGrade.a,
      notes: 'Special operating conditions (dusty, short trips, idling, towing): '
          'every 5,000 mi (8,000 km) / 6 mo.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcToyotaTacoma,
      grade: OemGrade.a,
      notes: 'Replaced at every 30,000 mi (48,000 km) (30k/60k/90k).',
    ),
    OemInterval(
      service: 'Spark plugs (3.5 V6, 2GR-FKS)',
      intervalKm: 96000,
      severity: OemSeverity.normal,
      source: _srcToyotaTacoma,
      grade: OemGrade.a,
      notes: 'V6: "Replace spark plugs (2GR-FKS engine only)" at 60,000 mi '
          '(96,000 km). The 2.7L I4 (2TR-FE) is at the generic 120,000 mi '
          '(192,000 km) milestone.',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 160000,
      intervalKm: 80000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcToyotaTacoma,
      grade: OemGrade.a,
      notes: 'Super Long-Life Coolant: initial at 100,000 mi (160,000 km) / '
          '120 mo, then every 50,000 mi (80,000 km) / 60 mo.',
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 96000,
      severity: OemSeverity.severe,
      source: _srcToyotaTacoma,
      grade: OemGrade.a,
      notes: 'Normal = inspect; severe (towing / idling, "Special Operating '
          'Conditions") = replace at 60,000 mi (96,000 km).',
    ),
  ],
);

// ---------------------------------------------------------------------------
// LEXUS LX 600 non-oil supplement (gap-fill pass 4). Supplements the LX 600
// entry above (oil + coolant), which had the rest noted illegible. These were
// now read from the SAME 2023 LX 600 guide using column-aware PyMuPDF plus
// `pdftotext -table`, which agree on the 30,000 mi service pattern.
// ---------------------------------------------------------------------------

const OemModelSchedule _lexusLx600NonOil = OemModelSchedule(
  make: 'Lexus',
  model: 'LX 600 (J310)',
  yearStart: 2023,
  engine: '3.5L twin-turbo V6 (F33A-FTS)',
  fuel: 'Petrol',
  generationNote:
      'Supplements the LX 600 oil+coolant entry above with the previously-'
      'illegible non-oil items, read column-aware from the same 2023 LX 600 '
      'Warranty & Services Guide. ATF / differential oils are inspect-only '
      'normal / replace under towing (not recorded here).',
  intervals: [
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcLexusLx600,
      grade: OemGrade.a,
      notes: 'Replaced at 30k/60k/90k mi = every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcLexusLx600,
      grade: OemGrade.a,
      notes: 'Replaced at 30k/60k/90k mi = every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcLexusLx600,
      grade: OemGrade.a,
      notes: 'Replaced at 30k/60k/90k mi = every 30,000 mi (48,000 km).',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 64000,
      severity: OemSeverity.normal,
      source: _srcLexusLx600,
      grade: OemGrade.a,
      notes: 'Replaced at 40k/80k mi = every 40,000 mi (64,000 km) '
          '(twin-turbo engine).',
    ),
    OemInterval(
      service: 'Transfer case oil',
      intervalKm: 48000,
      severity: OemSeverity.normal,
      source: _srcLexusLx600,
      grade: OemGrade.a,
      notes: 'Replaced at 30k/60k/90k mi = every 30,000 mi (48,000 km).',
    ),
  ],
);

// ---------------------------------------------------------------------------
// The dataset.
//
// NOTE ON COVERAGE (see oem_schedules_japanese_SOURCES.md for full detail):
//   • Kia carries Sorento, Sportage, Forte/Cerato, Rio (Grade B, Archive OCR)
//     and now Picanto (Grade A, Kia AU owner's manual). Seltos remains a gap
//     (its Kia AU manual URL 404s / has moved).
//   • Lexus carries NX 200t (Grade B) plus RX 350, ES 250/350 and LX 600
//     (Grade A, via Wayback) — the LX 600 now with its non-oil items filled.
//     IS remains a gap (no reachable guide).
//   • Toyota carries non-hybrid Corolla, Camry, RAV4, Tacoma (Grade A, US
//     guides) and a make-wide conventional-petrol NZ sheet (Hilux / Land
//     Cruiser / Prado petrol, oil + coolant only). Per-model Hilux/LC/Prado
//     spark-plug and transmission figures remain gaps.
//   • Nissan carries Altima, Sentra, Patrol Y62, and now Rogue (US X-Trail
//     sibling) and Kicks (Grade A). Magnite remains a gap (not on reachable
//     Nissan hosts).
//   • Infiniti (Q50, QX60, QX80) and Genesis (G70/G80/GV70/GV80 gasoline) are
//     covered (Grade A). GV/sedan EV variants were excluded.
//   • Mitsubishi carries Eclipse Cross, Lancer and the filled Outlander ZM
//     coolant. Honda per-model (Civic/Accord/CR-V) still relies on the make-wide
//     Maintenance-Minder schedule already recorded.
//   • Per the GOLDEN RULE, nothing was invented or copied across makes/models.
// ---------------------------------------------------------------------------

const List<OemModelSchedule> kOemJapaneseSchedules = [
  // Toyota
  _toyotaPetrolHybrid,
  _toyotaBruneiPms,
  // Nissan
  _nissanXtrailPetrol,
  _nissanXtrailDiesel,
  _nissanQashqai12t,
  _nissanQashqai15Diesel,
  _nissanQashqai16t,
  _nissanAlmera,
  _nissanNavara,
  // Honda
  _hondaGeneral,
  // Hyundai
  _hyundaiHevTurbo,
  _hyundaiPetrolMpi,
  _nissanAltima,
  _nissanSentra,
  // Mitsubishi
  _mitsubishiOutlander,
  _mitsubishiTriton,
  _mitsubishiMirage,
  _mitsubishiPajeroSport,
  _mitsubishiPajero,
  _mitsubishiAsx,
  _mitsubishiEclipseCross,
  _mitsubishiLancer,
  _mitsubishiOutlanderZmCoolant,
  // Kia
  _kiaSorento,
  _kiaSportage,
  _kiaForte,
  _kiaRio,
  // Lexus
  _lexusNx200t,
  _lexusRx350,
  _lexusEs,
  _lexusLx600,
  // Toyota (non-hybrid, pass 2)
  _toyotaRav4,
  _toyotaCamry,
  _toyotaCorolla,
  // Pass 3
  _toyotaNzPetrol,
  _nissanPatrol,
  _kiaPicanto,
  _infinitiQ50,
  _infinitiQx60,
  _infinitiQx80,
  _genesisGasolineRange,
  // Pass 4 (OLX market scan)
  _nissanRogue,
  _nissanKicks,
  _toyotaTacoma,
  _lexusLx600NonOil,
];
