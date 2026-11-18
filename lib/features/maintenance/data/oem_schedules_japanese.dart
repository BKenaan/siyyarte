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

// ---------------------------------------------------------------------------
// The dataset.
//
// NOTE ON COVERAGE (see oem_schedules_japanese_SOURCES.md for full detail):
//   • Lexus and Kia carry NO rows here. Every accessible route to their
//     official owner's-manual / service schedules was blocked during research
//     (Cloudflare 403 on ownersmanual.kia.com, kia.com, manualslib; TLS chain
//     errors on Kia ZA). Per the GOLDEN RULE, no numbers were invented or
//     copied from the sibling Hyundai platform. They are honest gaps.
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
  // Honda
  _hondaGeneral,
  // Hyundai
  _hyundaiHevTurbo,
  _hyundaiPetrolMpi,
  // Mitsubishi
  _mitsubishiOutlander,
  _mitsubishiTriton,
];
