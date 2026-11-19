// OEM maintenance schedules — Japanese makes, set 2 (research dataset).
//
// Second Japanese-makes corpus, covering makes NOT in
// `oem_schedules_japanese.dart`: SUZUKI, MAZDA, SUBARU, ISUZU, DAIHATSU — plus
// (added Round 2) ACURA (Honda group) and SsangYong/KGM (petrol), and (Round 3)
// one MITSUBISHI ASX petrol entry that completes the sibling file's sparser one.
//
// This file is SOURCED RESEARCH DATA, not yet wired into the maintenance
// engine. It mirrors the discipline of the sibling datasets
// (`oem_schedules_japanese.dart`, `oem_schedules_german_american.dart`) and of
// the `verified_specs` system in `data_backend/` and `lib/features/specs/`:
//
//   GOLDEN RULE: never show an unverified number.
//
// Every interval below carries a real, citable source (publisher + document +
// URL) read from an actual document, and a confidence [OemGrade]. Where a
// trustworthy source could not be found for a value it was OMITTED and recorded
// as a gap in the companion file `oem_schedules_japanese2_SOURCES.md`. Nothing
// here is inferred, guessed, "reasonable-defaulted", or copied across models or
// makes (e.g. the Mazda CX-5 table was NOT copied to Mazda 3/6/CX-30, and the
// Suzuki Grand Vitara table was NOT copied to the current Swift/Vitara).
//
// This file is deliberately SELF-CONTAINED (its own type definitions), matching
// the pattern of the two sibling dataset files, which each redefine these types
// privately. None of the three files is imported together, so the repeated
// top-level names do not collide. Integration into `MaintenanceRule` /
// `MaintenanceEngine` is reviewed separately; this file only has to compile
// cleanly and carry honest, cited data.
//
// Units: km are kilometres; months are calendar months. [firstKm] is used for
// "first replacement at X, then every [intervalKm]" schedules (common for
// long-life coolant). [intervalKm] / [intervalMonths] are "whichever comes
// first". A null value means that dimension was not published for the item.
//
// Lebanon context: Lebanon = severe operating conditions (stop-and-go, heat,
// dust), so [OemSeverity.severe] figures matter most. Lebanon also BANS diesel
// passenger cars, so only petrol variants are recorded here (see the Isuzu
// note below).

/// Field-level confidence, aligned with the verified_specs A–D scale and with
/// the sibling dataset files.
enum OemGrade {
  /// Read directly and unambiguously from a manufacturer or official importer
  /// maintenance document (owner's-manual schedule, OEM service sheet).
  a,

  /// Official content but market/engine-column dependent, taken from a footnote,
  /// or from a faithful third-party reproduction of the OEM owner's manual
  /// (used where the manufacturer's own host was unreachable).
  b,

  /// Value whose exact figure is only positionally implied by the source
  /// (needs confirmation before display).
  c,

  /// Placeholder — not used; present so the scale matches the sibling files.
  d,
}

/// Driving severity, matching the app's [DrivingSeverity] semantics. Lebanese
/// conditions meet every OEM's "severe / special operating conditions"
/// definition, so [severe] matters most.
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

  /// Any clarifying note (engine qualifier, market caveat, footnote text,
  /// condition-based/algorithmic oil-life flag + baseline).
  final String? notes;

  const OemInterval({
    required this.service,
    this.intervalKm,
    this.intervalMonths,
    this.firstKm,
    this.severity = OemSeverity.normal,
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

  /// True when the make/model uses a flexible / condition-based (algorithmic)
  /// oil-life or service system, so the oil figure here is the PUBLISHED
  /// BASELINE / maximum, not a hard schedule. Flagged per-interval in notes too.
  final bool conditionBased;

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
    this.conditionBased = false,
    this.generationNote,
    required this.intervals,
  });
}

// ---------------------------------------------------------------------------
// Source citation constants (full list also in the SOURCES.md companion).
// ---------------------------------------------------------------------------

const String _srcSuzukiAuServicing =
    'Suzuki Australia (official) — "Genuine Servicing: Frequently Asked '
    'Questions" (service-interval table, accessed Nov 2025) — '
    'https://www.suzuki.com.au/owners/genuineservicing/frequently-asked-questions';

const String _srcSuzukiGrandVitaraOm =
    'Suzuki Grand Vitara Owner\'s Manual — "Periodic Maintenance Schedule" '
    '(2010-11 model year), faithful reproduction (Suzuki\'s own portals are '
    'Cloudflare-gated) — '
    'https://www.manualsdir.com/manuals/153941/suzuki-2010-grand-vitara.html?page=252';

const String _srcMazdaCx5Smg2020 =
    'Mazda North American Operations — "2020 CX-5 Scheduled Maintenance" '
    '(official Mazda USA owner-guide PDF; U.S./Canada/Mexico tables) — '
    'https://www.mazdausa.com/siteassets/global-resources/vehicle-resources/owner-manuals/2020/cx-5/2020-cx-5-scheduled-maintenance.pdf';

const String _srcSubaruWmb2022 =
    'Subaru of America — "2022 Warranty & Maintenance Booklet" (rev. Nov 2021), '
    'p.28 "2022 MY All Vehicles — Federal/California" schedule + p.29 severe '
    'notes — https://techinfo.subaru.com/stis/doc/warrantyBooklet/2022_war_and_maint_120721.PDF';

// --- Round 2 additions: more Mazda models, SsangYong/KGM, Acura ---

const String _srcMazda3Smg2023 =
    'Mazda North American Operations — "2023 Mazda3 Hatchback Scheduled '
    'Maintenance" (official owner-guide PDF; U.S./Canada/Mexico tables) — '
    'https://www.mazdausa.com/siteassets/pdf/owners-optimized/2023/m3h/2023-mazda3-hatchback-scheduled-maintenance.pdf';

const String _srcMazda6Smg2020 =
    'Mazda North American Operations — "2020 Mazda6 Scheduled Maintenance" '
    '(official owner-guide PDF; U.S./Canada/Mexico tables) — '
    'https://www.mazdausa.com/siteassets/global-resources/vehicle-resources/owner-manuals/2020/mazda6/2020-mazda6-scheduled-maintenance.pdf';

const String _srcMazdaCx30Smg2020 =
    'Mazda North American Operations — "2020 CX-30 Scheduled Maintenance" '
    '(official owner-guide PDF; U.S./Canada tables) — '
    'https://www.mazdausa.com/siteassets/global-resources/vehicle-resources/owner-manuals/2020/cx-30/2020-cx-30-scheduled-maintenance.pdf';

const String _srcMazdaCx9Smg2019 =
    'Mazda North American Operations — "2019 CX-9 Scheduled Maintenance" '
    '(official owner-guide PDF; U.S./Canada/Mexico tables) — '
    'https://www.mazdausa.com/siteassets/global-resources/vehicle-resources/owner-manuals/2019/cx-9/2019-cx9-scheduled-maintenance.pdf';

const String _srcMazdaCx3Smg2019 =
    'Mazda North American Operations — "2019 CX-3 Scheduled Maintenance" '
    '(official owner-guide PDF; U.S./Canada/Mexico tables) — '
    'https://www.mazdausa.com/siteassets/global-resources/vehicle-resources/owner-manuals/2019/cx-3/2019-cx3-scheduled-maintenance.pdf';

const String _srcKgmRextonPetrol =
    'KGM (SsangYong) Australia (official) — "Rexton Petrol (G20 GDi) service '
    'price menu & schedule" (accessed Nov 2025) — '
    'https://kgm.com.au/owners-and-service/servicing/rexton-petrol';

const String _srcKgmTivoliPetrol =
    'KGM (SsangYong) Australia (official) — "Tivoli Petrol (G16DF) service '
    'price menu & schedule" (accessed Nov 2025) — '
    'https://kgm.com.au/owners-and-service/servicing/tivoli-petrol';

const String _srcKgmKorandoPetrol =
    'KGM (SsangYong) Australia (official) — "Korando Petrol (G15DTF) service '
    'price menu & schedule" (accessed Nov 2025) — '
    'https://kgm.com.au/owners-and-service/servicing/korando-petrol';

const String _srcAcuraMdxOm2008 =
    'Acura MDX Owner\'s Manual — "Maintenance / Maintenance Minder" page '
    '(2008 MY), faithful reproduction (Acura/Honda portals & ManualsLib are '
    'Cloudflare-gated) — '
    'https://www.manualsdir.com/manuals/33002/acura-2008-mdx.html?page=396';

// --- Round 3 addition: Mitsubishi ASX (petrol) — completes the sparser 24MY
// ASX entry in the sibling oem_schedules_japanese.dart (which omits plugs &
// coolant as "not legible"); read cleanly from the 23MY schedule. ---
const String _srcMitsuAuAsx23My =
    'Mitsubishi Motors Australia (official) — "23MY XD ASX Inspection and '
    'Maintenance Schedule" (v1.2, 2023-01-12) — '
    'https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/23MY-XD-ASX-INSPECTION-AND-MAINTENANCE-SCHEDULE.pdf';

// ---------------------------------------------------------------------------
// SUZUKI
//
// Two sources, kept as SEPARATE schedules (never merged):
//  (1) Suzuki Australia's official service-interval figure for the CURRENT
//      range (service/oil interval only — the FAQ does not publish per-item
//      fluid intervals). Grade A.
//  (2) The Suzuki Grand Vitara owner's-manual Periodic Maintenance Schedule,
//      which DOES publish per-item intervals (plugs, coolant, air filter).
//      This is a legacy model, not a current priority model; it is recorded as
//      a genuine Suzuki OEM reference and labelled as such. Grade B (read from
//      a faithful reproduction because Suzuki's own hosts are Cloudflare-gated).
// NOT copied between the two — e.g. the Grand Vitara plug/coolant figures are
// NOT asserted for the current Swift/Vitara.
// ---------------------------------------------------------------------------

const OemModelSchedule _suzukiAuNonTurbo = OemModelSchedule(
  make: 'Suzuki',
  model: 'Current range, non-turbo (Swift 1.2 / Baleno 1.4 / Vitara 1.6 / '
      'Jimny 1.5 / Ignis 1.2)',
  engine: 'Naturally aspirated petrol',
  fuel: 'Petrol',
  generationNote:
      'Suzuki Australia Genuine Service Program. The FAQ publishes only the '
      'overall service interval (which includes the engine-oil change); it does '
      'not break out per-item fluid/plug intervals. Model-to-engine mapping is '
      'as listed on that page.',
  intervals: [
    OemInterval(
      service: 'Scheduled service (incl. engine oil & filter)',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcSuzukiAuServicing,
      grade: OemGrade.a,
      notes: 'Non-turbo models: "12 monthly intervals or at 15,000 kms, '
          'whichever occurs first." Service bundles the oil & filter change.',
    ),
  ],
);

const OemModelSchedule _suzukiAuTurbo = OemModelSchedule(
  make: 'Suzuki',
  model: 'Current range, turbo (Swift 1.0 / Swift Sport 1.4 / Vitara 1.4 / '
      'S-Cross 1.4 Boosterjet)',
  engine: 'Turbocharged petrol (Boosterjet)',
  fuel: 'Petrol',
  generationNote:
      'Suzuki Australia Genuine Service Program. Turbo models carry the shorter '
      '10,000 km interval. Service interval only (bundles the oil change); no '
      'per-item fluid intervals published on the FAQ.',
  intervals: [
    OemInterval(
      service: 'Scheduled service (incl. engine oil & filter)',
      intervalKm: 10000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcSuzukiAuServicing,
      grade: OemGrade.a,
      notes: 'Turbo models: "10,000 km for turbo models", or 12 months, '
          'whichever occurs first.',
    ),
  ],
);

const OemModelSchedule _suzukiGrandVitara = OemModelSchedule(
  make: 'Suzuki',
  model: 'Grand Vitara (legacy reference)',
  yearStart: 2010,
  yearEnd: 2011,
  engine: '2.4 L petrol (and range)',
  fuel: 'Petrol',
  generationNote:
      'LEGACY model, recorded as a genuine Suzuki OEM per-item reference '
      'because the current small-car owner\'s manuals were only reachable on '
      'Cloudflare-gated hosts. These figures are NOT asserted for the current '
      'Swift/Vitara/Jimny. Read from a faithful owner\'s-manual reproduction.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 12500,
      severity: OemSeverity.normal,
      source: _srcSuzukiGrandVitaraOm,
      grade: OemGrade.b,
      notes: 'Table replaces oil & filter every 12,500 km (7,500 mi). The month '
          'cell could not be read unambiguously from the reproduction, so no '
          'month figure is asserted.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 100000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcSuzukiGrandVitaraOm,
      grade: OemGrade.b,
      notes: 'Replace at 100,000 km / 60 mo, then again at 200,000 km / 120 mo '
          '("at the specified mileage only").',
    ),
    OemInterval(
      service: 'Air cleaner filter element',
      intervalKm: 50000,
      intervalMonths: 30,
      severity: OemSeverity.normal,
      source: _srcSuzukiGrandVitaraOm,
      grade: OemGrade.b,
      notes: 'Replaced at the 50,000 km and 100,000 km services.',
    ),
    OemInterval(
      service: 'Engine coolant (SUZUKI LLC Super, Blue — long-life)',
      firstKm: 150000,
      intervalKm: 75000,
      intervalMonths: 45,
      severity: OemSeverity.normal,
      source: _srcSuzukiGrandVitaraOm,
      grade: OemGrade.b,
      notes: 'Genuine blue long-life coolant: first change 150,000 km / 90 mo, '
          'then every 75,000 km / 45 mo.',
    ),
    OemInterval(
      service: 'Engine coolant (SUZUKI LLC Standard, Green — if non-genuine)',
      intervalKm: 50000,
      intervalMonths: 30,
      severity: OemSeverity.normal,
      source: _srcSuzukiGrandVitaraOm,
      grade: OemGrade.b,
      notes: 'If any coolant other than the genuine blue is used, the green '
          'schedule applies: replace every 50,000 km / 30 mo.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// MAZDA
//
// Mazda CX-5 (2nd-gen KF). Source is the official Mazda USA "2020 CX-5
// Scheduled Maintenance" guide, which carries U.S./Canada tables (in km+mi) and
// a Mexico table (pure km) with an explicit normal (Schedule 1) / severe
// (Schedule 2) split. Market-neutral items (spark plugs, coolant, air/cabin
// filter) are taken from the U.S./Canada table (Grade A). Items only published
// in the Mexico table (brake-fluid replacement, severe oil) are taken from
// there and labelled (Grade B). NOT copied to Mazda 2/3/6, CX-3, CX-30, CX-9.
//
// CX-5 oil uses "Engine Oil Flexible Maintenance" (condition-based oil-life
// monitor, default in U.S./PR): conditionBased = true, baseline captured below.
// ---------------------------------------------------------------------------

const OemModelSchedule _mazdaCx5 = OemModelSchedule(
  make: 'Mazda',
  model: 'CX-5 (KF, 2nd gen)',
  yearStart: 2017,
  engine: 'SKYACTIV-G 2.0 / 2.5 / 2.5T petrol',
  fuel: 'Petrol',
  conditionBased: true,
  generationNote:
      'From the 2020 CX-5 owner-guide schedule (2nd-gen KF). Petrol SKYACTIV-G '
      'engines only (the diesel 2.2 rows are excluded — Lebanon bans diesel '
      'passenger cars). Oil interval is condition-based (Flexible Maintenance).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 12000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMazdaCx5Smg2020,
      grade: OemGrade.a,
      notes: 'CONDITION-BASED: "Engine Oil Flexible Maintenance" (default in '
          'U.S./PR) computes oil life and can call service earlier. Figure here '
          'is the published FIXED MAXIMUM baseline: 12 months or 12,000 km '
          '(7,500 mi).',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 5000,
      intervalMonths: 3,
      severity: OemSeverity.severe,
      source: _srcMazdaCx5Smg2020,
      grade: OemGrade.b,
      notes: 'Severe from the Mexico Schedule 2 (severe-conditions) table: '
          'replace every 5,000 km / 3 mo. (U.S./Canada fixed-severe is '
          '8,000 km / 6 mo on its own table.)',
    ),
    OemInterval(
      service: 'Spark plugs (except 2.5 Turbo)',
      intervalKm: 120000,
      severity: OemSeverity.normal,
      source: _srcMazdaCx5Smg2020,
      grade: OemGrade.a,
      notes: 'SKYACTIV-G 2.0 / 2.5 NA: "Replace every 120,000 km (75,000 '
          'miles)." No month figure published.',
    ),
    OemInterval(
      service: 'Spark plugs (2.5 Turbo)',
      intervalKm: 64000,
      severity: OemSeverity.normal,
      source: _srcMazdaCx5Smg2020,
      grade: OemGrade.a,
      notes: 'SKYACTIV-G 2.5T: "Replace every 64,000 km (40,000 miles)."',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 56000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcMazdaCx5Smg2020,
      grade: OemGrade.a,
      notes: 'Canada table states "Replace every 56,000 km (35,000 miles) or '
          '3 years." In very dusty/sandy areas, clean/replace more often.',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 48000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazdaCx5Smg2020,
      grade: OemGrade.a,
      notes: 'U.S./Canada severe schedule: "Replace every 48,000 km (30,000 '
          'miles) or 2 years."',
    ),
    OemInterval(
      service: 'Engine coolant (FL-22)',
      firstKm: 192000,
      intervalKm: 96000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcMazdaCx5Smg2020,
      grade: OemGrade.a,
      notes: 'First change 192,000 km (120,000 mi) / 10 yr, then every 96,000 '
          'km (60,000 mi) / 5 yr. FL-22 coolant required.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazdaCx5Smg2020,
      grade: OemGrade.b,
      notes: 'From the Mexico table (R at 40k/80k/120k km): replace every '
          '40,000 km / 24 mo. (The U.S./Canada petrol table only inspects '
          'brake fluid level, so no km interval there.)',
    ),
  ],
);

// ---------------------------------------------------------------------------
// SUBARU
//
// Make-wide schedule from the official Subaru of America "2022 Warranty &
// Maintenance Booklet" — p.28 "2022 MY All Vehicles" table (covers Impreza,
// Forester, Outback, Crosstrek/XV, etc.; BRZ/WRX/Hybrid exceptions are noted
// where the table notes them) + p.29 severe-conditions notes. Grade A. Figures
// are published in miles; the km row printed alongside (exact conversions) is
// used verbatim. Subaru uses NO algorithmic oil system — fixed table.
// ---------------------------------------------------------------------------

const OemModelSchedule _subaruRange = OemModelSchedule(
  make: 'Subaru',
  model: 'Model range (Impreza / Forester / Outback / Crosstrek-XV etc.)',
  yearStart: 2022,
  engine: 'Petrol (FB/FA boxer; BRZ, WRX & Hybrid exceptions noted per item)',
  fuel: 'Petrol',
  generationNote:
      'Make-wide "2022 MY All Vehicles — Federal/California" table. km values '
      'are the exact-conversion km row printed beside the mile columns. Severe '
      'figures are from the booklet\'s Notes (p.29); Lebanon conditions match '
      'several listed severe examples (short trips, dust).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 9600,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Replace every 6,000 mi / 6 mo (9,600 km).',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 4800,
      intervalMonths: 3,
      severity: OemSeverity.severe,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Note 1: under severe driving conditions, change every 3,000 mi '
          '(4,800 km) / 3 mo.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 96000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Replace at 60,000 mi / 60 mo (96,000 km). WRX STI timing belt is '
          'a separate item; turbo models otherwise per this table.',
    ),
    OemInterval(
      service: 'Engine air filter (cleaner element)',
      intervalKm: 48000,
      intervalMonths: 30,
      severity: OemSeverity.normal,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Replace at 30,000 mi / 30 mo (48,000 km). Note 8: inspect more '
          'often in extremely dusty conditions.',
    ),
    OemInterval(
      service: 'Cabin / HVAC A-C filter',
      intervalKm: 19200,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Replace every 12,000 mi / 12 mo (19,200 km).',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 220000,
      intervalKm: 120000,
      intervalMonths: 72,
      severity: OemSeverity.normal,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Replace after the first 11 yr / 220,000 km (137,500 mi), then '
          'every 6 yr / 120,000 km (75,000 mi). Add Subaru Cooling System '
          'Conditioner at each change.',
    ),
    OemInterval(
      service: 'Brake fluid (& clutch fluid, MT)',
      intervalKm: 48000,
      intervalMonths: 30,
      severity: OemSeverity.normal,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Replace every 30,000 mi / 30 mo (48,000 km).',
    ),
    OemInterval(
      service: 'Brake fluid (& clutch fluid, MT)',
      intervalKm: 24000,
      intervalMonths: 15,
      severity: OemSeverity.severe,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Note 5: in high-humidity or mountainous areas, change every '
          '15,000 mi (24,000 km) / 15 mo.',
    ),
    OemInterval(
      service: 'CVT fluid (except BRZ & Hybrid)',
      intervalKm: 40000,
      severity: OemSeverity.severe,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Normal schedule only INSPECTS CVT fluid (no fixed replacement). '
          'Note 4: under severe driving, replace every 24,855 mi (40,000 km).',
    ),
    OemInterval(
      service: 'Front & rear differential gear oil (except BRZ)',
      intervalKm: 24000,
      intervalMonths: 15,
      severity: OemSeverity.severe,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Normal schedule only inspects. Note 3: under severe driving, '
          'replace every 15,000 mi (24,000 km) / 15 mo.',
    ),
    OemInterval(
      service: 'Fuel filter',
      intervalKm: 115200,
      intervalMonths: 72,
      severity: OemSeverity.normal,
      source: _srcSubaruWmb2022,
      grade: OemGrade.a,
      notes: 'Single scheduled replacement at 72,000 mi / 72 mo (115,200 km). '
          'Note 7: not required for emission-warranty eligibility.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// MAZDA (additional models) — all from official Mazda USA owner-guide PDFs,
// read page-by-page. Every Mazda schedule below is SKYACTIV-G PETROL only
// (diesel rows excluded; Lebanon bans diesel passenger cars) and uses the
// condition-based oil system (Flexible Maintenance / vehicle status monitor),
// so conditionBased = true and the oil figure is the published MAXIMUM.
// Each model was sourced from its OWN document; nothing was copied across
// models (the per-model oil-monitor max differs: 12,000 km on CX-5/6/CX-9/CX-3,
// 16,000 km on Mazda3/CX-30).
// ---------------------------------------------------------------------------

const OemModelSchedule _mazda3 = OemModelSchedule(
  make: 'Mazda',
  model: 'Mazda3 (BP, 4th gen)',
  yearStart: 2019,
  engine: 'SKYACTIV-G 2.0 / 2.5 / 2.5T petrol',
  fuel: 'Petrol',
  conditionBased: true,
  generationNote:
      'From the 2023 Mazda3 Hatchback owner-guide schedule (BP generation; '
      'sedan shares it). Vehicle status monitor oil system.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMazda3Smg2023,
      grade: OemGrade.a,
      notes: 'CONDITION-BASED: vehicle status monitor calls oil service before '
          'the max interval. Published max (U.S./Canada): 16,000 km (10,000 mi) '
          '/ 12 mo. (Mexico max is 10,000 km / 6 mo.)',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcMazda3Smg2023,
      grade: OemGrade.a,
      notes: 'Severe driving (dust, short trips, heat, idling): every 8,000 km '
          '(5,000 mi) / 6 mo. (Mexico severe is 5,000 km / 3 mo.)',
    ),
    OemInterval(
      service: 'Spark plugs (except 2.5 Turbo)',
      intervalKm: 120000,
      severity: OemSeverity.normal,
      source: _srcMazda3Smg2023,
      grade: OemGrade.a,
      notes: 'SKYACTIV-G 2.0 / 2.5 NA: replace every 120,000 km (75,000 mi).',
    ),
    OemInterval(
      service: 'Spark plugs (2.5 Turbo)',
      intervalKm: 64000,
      severity: OemSeverity.normal,
      source: _srcMazda3Smg2023,
      grade: OemGrade.a,
      notes: 'SKYACTIV-G 2.5T: replace every 64,000 km (40,000 mi).',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 56000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcMazda3Smg2023,
      grade: OemGrade.a,
      notes: 'Canada table: replace every 56,000 km (35,000 mi) or 3 yr.',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 48000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazda3Smg2023,
      grade: OemGrade.a,
      notes: 'U.S. table: every 48,000 km (30,000 mi) / 24 mo. (Mexico: '
          '40,000 km / 24 mo.)',
    ),
    OemInterval(
      service: 'Engine coolant (FL-22)',
      firstKm: 192000,
      intervalKm: 96000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcMazda3Smg2023,
      grade: OemGrade.a,
      notes: 'First 192,000 km (120,000 mi) / 10 yr, then 96,000 km (60,000 '
          'mi) / 5 yr. FL-22 required.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazda3Smg2023,
      grade: OemGrade.b,
      notes: 'Mexico table replaces at 40,000 km / 24 mo. (U.S./Canada petrol '
          'table only inspects brake-fluid level.)',
    ),
  ],
);

const OemModelSchedule _mazda6 = OemModelSchedule(
  make: 'Mazda',
  model: 'Mazda6 (GJ/GL)',
  yearStart: 2013,
  yearEnd: 2021,
  engine: 'SKYACTIV-G 2.5 / 2.5T petrol',
  fuel: 'Petrol',
  conditionBased: true,
  generationNote:
      'From the 2020 Mazda6 owner-guide schedule. Flexible Maintenance oil '
      'system. (U.S. Mazda6 ended MY2021.)',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 12000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMazda6Smg2020,
      grade: OemGrade.a,
      notes: 'CONDITION-BASED (Flexible Maintenance). Published fixed max: '
          '12,000 km (7,500 mi) / 12 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 5000,
      intervalMonths: 3,
      severity: OemSeverity.severe,
      source: _srcMazda6Smg2020,
      grade: OemGrade.b,
      notes: 'Severe: Mexico Schedule 2 = 5,000 km / 3 mo. (U.S./Canada fixed-'
          'severe is 8,000 km / 6 mo.)',
    ),
    OemInterval(
      service: 'Spark plugs (except 2.5 Turbo)',
      intervalKm: 120000,
      severity: OemSeverity.normal,
      source: _srcMazda6Smg2020,
      grade: OemGrade.a,
      notes: 'SKYACTIV-G 2.5 NA: every 120,000 km (75,000 mi).',
    ),
    OemInterval(
      service: 'Spark plugs (2.5 Turbo)',
      intervalKm: 64000,
      severity: OemSeverity.normal,
      source: _srcMazda6Smg2020,
      grade: OemGrade.a,
      notes: 'SKYACTIV-G 2.5T: every 64,000 km (40,000 mi).',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 56000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcMazda6Smg2020,
      grade: OemGrade.a,
      notes: 'Canada table: every 56,000 km (35,000 mi) or 3 yr.',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazda6Smg2020,
      grade: OemGrade.a,
      notes: 'Canada/Mexico tables: every 40,000 km (25,000 mi) / 24 mo.',
    ),
    OemInterval(
      service: 'Engine coolant (FL-22)',
      firstKm: 192000,
      intervalKm: 96000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcMazda6Smg2020,
      grade: OemGrade.a,
      notes: 'First 192,000 km / 10 yr, then 96,000 km / 5 yr. FL-22.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazda6Smg2020,
      grade: OemGrade.b,
      notes: 'Mexico table: 40,000 km / 24 mo. (U.S./Canada table only '
          'inspects fluid level.)',
    ),
  ],
);

const OemModelSchedule _mazdaCx30 = OemModelSchedule(
  make: 'Mazda',
  model: 'CX-30 (DM)',
  yearStart: 2019,
  engine: 'SKYACTIV-G 2.0 / 2.5 petrol',
  fuel: 'Petrol',
  conditionBased: true,
  generationNote:
      'From the 2020 CX-30 owner-guide schedule. Vehicle status monitor oil '
      'system (16,000 km max, like Mazda3; unlike CX-5/6/9 at 12,000 km).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 16000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMazdaCx30Smg2020,
      grade: OemGrade.a,
      notes: 'CONDITION-BASED: status monitor calls service before the max. '
          'Published max (U.S./Canada): 16,000 km (10,000 mi) / 12 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 8000,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcMazdaCx30Smg2020,
      grade: OemGrade.a,
      notes: 'Severe driving (dust, short trips, heat): every 8,000 km (5,000 '
          'mi) / 6 mo.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 120000,
      severity: OemSeverity.normal,
      source: _srcMazdaCx30Smg2020,
      grade: OemGrade.a,
      notes: 'NA 2.0 / 2.5: replace every 120,000 km (75,000 mi).',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 56000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcMazdaCx30Smg2020,
      grade: OemGrade.a,
      notes: 'Canada table: every 56,000 km (35,000 mi) or 3 yr.',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 48000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazdaCx30Smg2020,
      grade: OemGrade.a,
      notes: 'U.S. table: every 48,000 km (30,000 mi) / 24 mo. (Canada: '
          '40,000 km / 24 mo.)',
    ),
    OemInterval(
      service: 'Engine coolant (FL-22)',
      firstKm: 192000,
      intervalKm: 96000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcMazdaCx30Smg2020,
      grade: OemGrade.a,
      notes: 'First 192,000 km (120,000 mi) / 10 yr, then 96,000 km / 5 yr. '
          'FL-22.',
    ),
    OemInterval(
      service: 'Brake fluid (electric booster)',
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazdaCx30Smg2020,
      grade: OemGrade.b,
      notes: 'Electric-booster models: replaced at every 2nd service (~24 mo / '
          '~32,000 km). No clean single km figure printed in the U.S./Canada '
          'table, so only the ~24-month basis is recorded.',
    ),
  ],
);

const OemModelSchedule _mazdaCx9 = OemModelSchedule(
  make: 'Mazda',
  model: 'CX-9 (TC, 2nd gen)',
  yearStart: 2016,
  yearEnd: 2023,
  engine: 'SKYACTIV-G 2.5T petrol (turbo only)',
  fuel: 'Petrol',
  conditionBased: true,
  generationNote:
      'From the 2019 CX-9 owner-guide schedule. CX-9 is 2.5-turbo only. '
      'Flexible Maintenance oil system.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 12000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMazdaCx9Smg2019,
      grade: OemGrade.a,
      notes: 'CONDITION-BASED (Flexible Maintenance). Published fixed max: '
          '12,000 km (7,500 mi) / 12 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 5000,
      intervalMonths: 3,
      severity: OemSeverity.severe,
      source: _srcMazdaCx9Smg2019,
      grade: OemGrade.b,
      notes: 'Severe: Mexico Schedule 2 = 5,000 km / 3 mo. (U.S./Canada fixed-'
          'severe is 8,000 km / 6 mo.)',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 64000,
      severity: OemSeverity.normal,
      source: _srcMazdaCx9Smg2019,
      grade: OemGrade.a,
      notes: 'SKYACTIV-G 2.5T: replace every 64,000 km (40,000 mi).',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 56000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcMazdaCx9Smg2019,
      grade: OemGrade.a,
      notes: 'Canada table: every 56,000 km (35,000 mi) or 3 yr.',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazdaCx9Smg2019,
      grade: OemGrade.a,
      notes: 'Canada/Mexico/U.S.-severe tables: every 40,000 km (25,000 mi) / '
          '24 mo.',
    ),
    OemInterval(
      service: 'Engine coolant (FL-22)',
      firstKm: 192000,
      intervalKm: 96000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcMazdaCx9Smg2019,
      grade: OemGrade.a,
      notes: 'First 192,000 km / 10 yr, then 96,000 km / 5 yr. FL-22.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazdaCx9Smg2019,
      grade: OemGrade.b,
      notes: 'Mexico table replaces at 40,000 km / 24 mo (R at 40/80/120k).',
    ),
  ],
);

const OemModelSchedule _mazdaCx3 = OemModelSchedule(
  make: 'Mazda',
  model: 'CX-3 (DK)',
  yearStart: 2015,
  yearEnd: 2021,
  engine: 'SKYACTIV-G 2.0 petrol',
  fuel: 'Petrol',
  conditionBased: true,
  generationNote:
      'From the 2019 CX-3 owner-guide schedule. 2.0 NA only. Flexible '
      'Maintenance oil system.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 12000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMazdaCx3Smg2019,
      grade: OemGrade.a,
      notes: 'CONDITION-BASED (Flexible Maintenance). Published fixed max: '
          '12,000 km (7,500 mi) / 12 mo.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 5000,
      intervalMonths: 3,
      severity: OemSeverity.severe,
      source: _srcMazdaCx3Smg2019,
      grade: OemGrade.b,
      notes: 'Severe: Mexico Schedule 2 = 5,000 km / 3 mo. (U.S./Canada fixed-'
          'severe is 8,000 km / 6 mo.)',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 120000,
      severity: OemSeverity.normal,
      source: _srcMazdaCx3Smg2019,
      grade: OemGrade.a,
      notes: 'SKYACTIV-G 2.0: replace every 120,000 km (75,000 mi).',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalKm: 56000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcMazdaCx3Smg2019,
      grade: OemGrade.a,
      notes: 'Canada table: every 56,000 km (35,000 mi) or 3 yr.',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazdaCx3Smg2019,
      grade: OemGrade.a,
      notes: 'Canada/Mexico/U.S.-severe tables: every 40,000 km (25,000 mi) / '
          '24 mo.',
    ),
    OemInterval(
      service: 'Engine coolant (FL-22)',
      firstKm: 192000,
      intervalKm: 96000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcMazdaCx3Smg2019,
      grade: OemGrade.a,
      notes: 'First 192,000 km / 10 yr, then 96,000 km / 5 yr. FL-22.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMazdaCx3Smg2019,
      grade: OemGrade.b,
      notes: 'Mexico table replaces at 40,000 km / 24 mo (R at 40/80/120k).',
    ),
  ],
);

// ---------------------------------------------------------------------------
// SSANGYONG / KGM — petrol models only (Lebanon bans diesel passenger cars).
// Source is KGM Australia's official per-model service price menu + schedule,
// which publishes the mandatory-item replacement intervals (coolant, plugs,
// brake fluid, air filter, ATF). Grade A. KGM states severe conditions may
// require more frequent servicing but does not quantify them, so no severe
// column is recorded. Each model sourced from its own page; turbo vs NA plug
// intervals differ and are NOT cross-copied.
// ---------------------------------------------------------------------------

const OemModelSchedule _ssangyongRextonPetrol = OemModelSchedule(
  make: 'SsangYong',
  model: 'Rexton petrol (Y450)',
  engine: 'G20 GDi 2.0 turbo petrol',
  fuel: 'Petrol',
  generationNote:
      'KGM Australia official petrol service schedule. Service base interval '
      '15,000 km / 12 mo.',
  intervals: [
    OemInterval(
      service: 'Scheduled service (incl. engine oil & filter)',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcKgmRextonPetrol,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 60000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcKgmRextonPetrol,
      grade: OemGrade.a,
      notes: '"48 months or 60,000 km, whichever occurs first."',
    ),
    OemInterval(
      service: 'Engine coolant',
      intervalKm: 200000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcKgmRextonPetrol,
      grade: OemGrade.a,
      notes: '"60 months or 200,000 km, whichever occurs first."',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKgmRextonPetrol,
      grade: OemGrade.a,
      notes: 'Every 24 months (time-based; no km figure published).',
    ),
    OemInterval(
      service: 'Engine air filter element',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKgmRextonPetrol,
      grade: OemGrade.a,
      notes: '"24 months or 30,000 km, whichever occurs first."',
    ),
    OemInterval(
      service: 'Cabin / A-C filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKgmRextonPetrol,
      grade: OemGrade.b,
      notes: 'Replaced "at every second service" = the 30,000 km / 24-mo '
          'service points.',
    ),
    OemInterval(
      service: 'Fuel filter element',
      intervalKm: 30000,
      severity: OemSeverity.normal,
      source: _srcKgmRextonPetrol,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 60000,
      severity: OemSeverity.normal,
      source: _srcKgmRextonPetrol,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Rear axle oil',
      intervalKm: 60000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcKgmRextonPetrol,
      grade: OemGrade.a,
    ),
  ],
);

const OemModelSchedule _ssangyongTivoliPetrol = OemModelSchedule(
  make: 'SsangYong',
  model: 'Tivoli petrol (X100)',
  engine: 'G16DF 1.6 petrol (naturally aspirated)',
  fuel: 'Petrol',
  generationNote:
      'KGM Australia official petrol service schedule. Service base interval '
      '15,000 km / 12 mo.',
  intervals: [
    OemInterval(
      service: 'Scheduled service (incl. engine oil & filter)',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcKgmTivoliPetrol,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 120000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcKgmTivoliPetrol,
      grade: OemGrade.a,
      notes: 'NA 1.6: "60 months or 120,000 km, whichever occurs first."',
    ),
    OemInterval(
      service: 'Engine coolant',
      intervalKm: 200000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcKgmTivoliPetrol,
      grade: OemGrade.a,
      notes: '"60 months or 200,000 km, whichever occurs first."',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKgmTivoliPetrol,
      grade: OemGrade.a,
      notes: 'Every 24 months (time-based; no km figure published).',
    ),
    OemInterval(
      service: 'Engine air filter element',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKgmTivoliPetrol,
      grade: OemGrade.a,
      notes: '"24 months or 30,000 km, whichever occurs first."',
    ),
    OemInterval(
      service: 'Cabin / A-C filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKgmTivoliPetrol,
      grade: OemGrade.b,
      notes: 'Replaced "at every second service" = the 30,000 km / 24-mo '
          'service points.',
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 100000,
      severity: OemSeverity.normal,
      source: _srcKgmTivoliPetrol,
      grade: OemGrade.a,
      notes: 'Manual transaxle oil: 120,000 km (per same page).',
    ),
  ],
);

const OemModelSchedule _ssangyongKorandoPetrol = OemModelSchedule(
  make: 'SsangYong',
  model: 'Korando petrol (C300)',
  engine: 'G15DTF 1.5 turbo petrol',
  fuel: 'Petrol',
  generationNote:
      'KGM Australia official petrol service schedule. Service base interval '
      '15,000 km / 12 mo.',
  intervals: [
    OemInterval(
      service: 'Scheduled service (incl. engine oil & filter)',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcKgmKorandoPetrol,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 60000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcKgmKorandoPetrol,
      grade: OemGrade.a,
      notes: 'Turbo 1.5: "48 months or 60,000 km, whichever occurs first."',
    ),
    OemInterval(
      service: 'Engine coolant',
      intervalKm: 200000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcKgmKorandoPetrol,
      grade: OemGrade.a,
      notes: '"60 months or 200,000 km, whichever occurs first."',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKgmKorandoPetrol,
      grade: OemGrade.a,
      notes: 'Every 24 months (time-based; no km figure published).',
    ),
    OemInterval(
      service: 'Engine air filter element',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKgmKorandoPetrol,
      grade: OemGrade.a,
      notes: '"24 months or 30,000 km, whichever occurs first."',
    ),
    OemInterval(
      service: 'Cabin / A-C filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcKgmKorandoPetrol,
      grade: OemGrade.b,
      notes: 'Replaced "at every second service" = the 30,000 km / 24-mo '
          'service points.',
    ),
    OemInterval(
      service: 'Automatic transmission fluid',
      intervalKm: 100000,
      severity: OemSeverity.normal,
      source: _srcKgmKorandoPetrol,
      grade: OemGrade.a,
    ),
  ],
);

// ---------------------------------------------------------------------------
// ACURA (Honda group) — Maintenance Minder is a CONDITION-BASED (algorithmic)
// system: oil, filters, transmission fluid, spark plugs and coolant are called
// by the on-board Minder, NOT by a fixed OEM mileage table. The owner's manual
// prints fixed intervals only for the items BELOW. conditionBased = true.
// Sourced from the Acura MDX owner's manual (2008 MY, via a faithful mirror —
// current MDX/RDX/TLX manuals were on Cloudflare-gated/scanned hosts). These
// Maintenance-Minder rules are Acura-wide, but are recorded here scoped to the
// MDX document they were read from, and NOT asserted as exact for RDX/TLX.
// ---------------------------------------------------------------------------

const OemModelSchedule _acuraMdxMm = OemModelSchedule(
  make: 'Acura',
  model: 'MDX (Maintenance Minder; 2008 OM reference)',
  yearStart: 2008,
  engine: 'Petrol V6 (Maintenance Minder)',
  fuel: 'Petrol',
  conditionBased: true,
  generationNote:
      'Acura uses the Maintenance Minder (algorithmic) system; oil, plugs, '
      'coolant, transmission and filters are Minder-driven with NO fixed OEM '
      'mileage table. Only the fixed-interval items below are recorded. Legacy '
      'MDX document; not asserted as exact for current RDX/TLX.',
  intervals: [
    OemInterval(
      service: 'Brake fluid',
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcAcuraMdxOm2008,
      grade: OemGrade.b,
      notes: '"Independent of the maintenance messages... replace the brake '
          'fluid every 3 years." No distance interval; Minder does not call it.',
    ),
    OemInterval(
      service: 'Rear differential fluid (AWD, severe)',
      firstKm: 12000,
      intervalKm: 24000,
      severity: OemSeverity.severe,
      source: _srcAcuraMdxOm2008,
      grade: OemGrade.b,
      notes: 'Severe use (very-low-speed mountain driving or trailer towing): '
          'change at first 12,000 km (7,500 mi), then every 24,000 km '
          '(15,000 mi). Normal-use interval is Minder-driven.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// MITSUBISHI — ASX (petrol). NOTE: the sibling oem_schedules_japanese.dart
// already carries a Mitsubishi ASX (XD) entry from the 24MY schedule, but it
// has ONLY oil + CVT (its plug/coolant rows were "not legible"). This entry is
// read from the 23MY schedule and ADDS the spark-plug, coolant, brake-fluid and
// cabin-filter intervals that the sibling omits. The two overlap on oil & CVT —
// kept separate because this file must not edit the sibling; a maintainer may
// dedupe. Fixed schedule (not condition-based). Petrol/CVT; diesel n/a (Lebanon).
// ---------------------------------------------------------------------------

const OemModelSchedule _mitsubishiAsxPetrol = OemModelSchedule(
  make: 'Mitsubishi',
  model: 'ASX / Outlander Sport (XD)',
  yearStart: 2023,
  engine: '2.0 / 2.4 MIVEC petrol, CVT',
  fuel: 'Petrol',
  generationNote:
      'Mitsubishi AU 23MY XD ASX inspection & maintenance schedule. Base '
      'inspection interval 15,000 km / 12 mo (severe 7,500 km / 6 mo). '
      'Completes the sibling file\'s 24MY ASX entry (which lacked plugs & '
      'coolant). Air-cleaner-element replace spacing and normal-CVT replace '
      'spacing were not legible and are omitted.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMitsuAuAsx23My,
      grade: OemGrade.a,
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 7500,
      intervalMonths: 6,
      severity: OemSeverity.severe,
      source: _srcMitsuAuAsx23My,
      grade: OemGrade.a,
      notes: '"R: Every 7,500 km" severe-usage text.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 90000,
      intervalMonths: 72,
      severity: OemSeverity.normal,
      source: _srcMitsuAuAsx23My,
      grade: OemGrade.a,
      notes: 'Replace at the 90,000 km / 72-mo and 180,000 km points.',
    ),
    OemInterval(
      service: 'Engine coolant (Super Long Life Coolant Premium)',
      firstKm: 165000,
      intervalKm: 105000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcMitsuAuAsx23My,
      grade: OemGrade.a,
      notes: '"R: First 165,000 km or 8 years, thereafter every 105,000 km or '
          '5 years." Mitsubishi Super Long Life Coolant Premium, 50/50.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcMitsuAuAsx23My,
      grade: OemGrade.a,
      notes: 'Change every 24 mo / 30,000 km (R at each 2nd service column).',
    ),
    OemInterval(
      service: 'Cabin / air-purifier filter',
      intervalKm: 15000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcMitsuAuAsx23My,
      grade: OemGrade.a,
      notes: 'Normal usage: replaced at every service (15,000 km / 12 mo); '
          'severe = more frequently.',
    ),
    OemInterval(
      service: 'CVT fluid',
      intervalKm: 40000,
      severity: OemSeverity.severe,
      source: _srcMitsuAuAsx23My,
      grade: OemGrade.a,
      notes: 'Severe usage: "R: Every 40,000 km" (explicit). Normal-usage '
          'replace spacing was not legible and is omitted; CVT level is '
          'inspected every service.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// ISUZU — no rows (honest exclusion).
//
// The Isuzu D-Max (and MU-X) are DIESEL-ONLY across every current engine: the
// 1.9 L RZ4E-TC, 2.2 L RZ4F, and 3.0 L 4JJ3 are all turbo-diesels; no petrol
// passenger variant exists in the sourced markets. Lebanon bans diesel
// passenger cars, so there is nothing petrol to record. Documented, not padded.
// (Sources in oem_schedules_japanese2_SOURCES.md.)
//
// DAIHATSU — no rows (honest gap).
//
// No official Daihatsu maintenance DOCUMENT was reachable. Terios / Gran Max
// schedules surfaced only via Indonesian secondary news (e.g. a dealer-exec
// quote that the facelift Gran Max moved spark plugs from 20,000 km to
// 100,000 km) — not a fetched OEM document, so per the GOLDEN RULE nothing is
// recorded. (Sources + gap detail in the companion file.)
// ---------------------------------------------------------------------------

/// The dataset (Japanese makes, set 2). See
/// `oem_schedules_japanese2_SOURCES.md` for full provenance and the honest gaps.
const List<OemModelSchedule> kOemJapaneseSchedules2 = [
  // Suzuki
  _suzukiAuNonTurbo,
  _suzukiAuTurbo,
  _suzukiGrandVitara,
  // Mazda
  _mazdaCx5,
  _mazda3,
  _mazda6,
  _mazdaCx30,
  _mazdaCx9,
  _mazdaCx3,
  // Subaru
  _subaruRange,
  // SsangYong / KGM (petrol only)
  _ssangyongRextonPetrol,
  _ssangyongTivoliPetrol,
  _ssangyongKorandoPetrol,
  // Acura (Honda group — Maintenance Minder, condition-based)
  _acuraMdxMm,
  // Mitsubishi — ASX petrol (completes the sibling file's sparser 24MY entry)
  _mitsubishiAsxPetrol,
  // Isuzu — diesel-only, excluded for Lebanon (see SOURCES.md).
  // Daihatsu — no OEM document reachable (see SOURCES.md).
  // Mazda2 — not sourced from a clean OEM doc (see SOURCES.md).
];
