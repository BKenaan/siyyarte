// OEM maintenance schedules — Chinese makes (research dataset).
//
// This file is SOURCED RESEARCH DATA, not yet wired into the maintenance
// engine. It deliberately mirrors `oem_schedules_japanese.dart` and the
// discipline of the `verified_specs` system in `data_backend/` and
// `lib/features/specs/`:
//
//   GOLDEN RULE: never show an unverified number.
//
// Every interval below carries a real, citable source (publisher + document +
// URL) and a confidence [OemGrade]. Where a trustworthy source could not be
// found — or a published table could not be read unambiguously — the value was
// OMITTED and recorded as a gap in the companion file
// `oem_schedules_chinese_SOURCES.md`. Nothing here is inferred, guessed or
// copied across models/brands.
//
// Chinese brands are overwhelmingly popular in Lebanon and many are electric
// (BYD BEVs, Chery EQ7, MG EVs). EV maintenance differs from ICE: there is no
// engine oil, spark plug, fuel filter or timing belt; instead the scheduled
// items are brake fluid, powertrain/battery coolant, cabin (HEPA) filter,
// reduction-gear ("reducer"/gearbox) oil, and high-voltage battery inspection.
// Each schedule's [fuel] field records whether it is a BEV, plug-in hybrid,
// hybrid or ICE so the engine can pick the right item set.
//
// Units: km are kilometres; months are calendar months. [firstKm] is used for
// "first replacement at X, then every [intervalKm]" schedules (very common on
// these makes for coolant, spark plugs and transmission/reducer oil).
// [intervalKm] / [intervalMonths] are "whichever comes first". A null value
// means that dimension was not published for the item.
//
// Integration into `MaintenanceRule` / `MaintenanceEngine` is intentionally NOT
// done here; that safety-critical mapping is reviewed separately. This file
// only has to compile cleanly and carry honest, cited data.
//
// NOTE ON TYPE DUPLICATION: the [OemGrade] / [OemSeverity] / [OemInterval] /
// [OemModelSchedule] types are redeclared here (rather than imported from
// `oem_schedules_japanese.dart`) so this dataset compiles independently of the
// sibling file, which is being edited in parallel. The shapes match the
// Japanese file; [OemInterval] additionally carries a [conditionBased] flag
// requested for condition/odometer-reminder oil systems.

/// Field-level confidence, aligned with the verified_specs A–D scale.
enum OemGrade {
  /// Directly read from a manufacturer or official importer maintenance
  /// document (owner's-manual schedule, OEM/importer service-requirement sheet).
  a,

  /// Official source, but a market-specific dealer/importer schedule (e.g. a
  /// single-market service table or capped-price schedule) rather than the
  /// global owner's manual, or a value derived from an explicit footnote.
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
  /// Human service label, e.g. 'Brake fluid', 'Reduction gear (reducer) oil'.
  final String service;

  /// Replace/service interval in kilometres (null if not published in km).
  final int? intervalKm;

  /// Replace/service interval in months (null if not published in months).
  final int? intervalMonths;

  /// For "first at X km, then every [intervalKm]" items (e.g. coolant, spark
  /// plugs, reducer oil). Null for fixed-interval items.
  final int? firstKm;

  /// Whether this interval is the normal or the severe-conditions figure.
  final OemSeverity severity;

  /// True when the published interval is a condition-based / odometer-reminder
  /// baseline (the vehicle calls service by use, and this is the stated
  /// baseline distance the UI should show as "~X km"). False for fixed
  /// time/distance intervals.
  final bool conditionBased;

  /// Full citation: publisher — document (date) — URL.
  final String source;

  /// Field-level confidence.
  final OemGrade grade;

  /// Any clarifying note (variant qualifier, market caveat, footnote text).
  final String? notes;

  const OemInterval({
    required this.service,
    this.intervalKm,
    this.intervalMonths,
    this.firstKm,
    required this.severity,
    this.conditionBased = false,
    required this.source,
    required this.grade,
    this.notes,
  });
}

/// A set of cited intervals scoped to make / model / year-range / powertrain.
class OemModelSchedule {
  final String make;

  /// Model, or a make/range-level descriptor when the source is range-wide.
  final String model;

  /// Inclusive model-year range the source covers (null when the source does
  /// not print model years; see [generationNote]).
  final int? yearStart;
  final int? yearEnd;

  /// Engine / drivetrain descriptor the source differentiates by (null = applies
  /// to the model's variants as published).
  final String? engine;

  /// Powertrain/fuel type: 'Electric' (BEV), 'Plug-in hybrid', 'Hybrid',
  /// 'Petrol', 'Diesel'. Drives which item set applies (EV vs ICE).
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
// Source citation constants (named consts so each interval references an exact,
// auditable string; full list also in the SOURCES.md companion).
// ---------------------------------------------------------------------------

const String _srcBydCyprusEv =
    'BYD Cyprus (official importer, bydauto.com.cy) — "Service Intervals EV (EN)" '
    '(PDF, 2025) — https://bydauto.com.cy/wp-content/uploads/2025/06/Service-Intervals-EV-EN.pdf';

const String _srcBydZaAtto3 =
    'BYD South Africa (official) — "ATTO 3 Warranty & Service Booklet" '
    '(Service Schedule & Log, pp.18–19) — '
    'https://www.byd.com/material/byd-site/za/warranty-%26-service-booklets/ATTO%203%20WARRANTY%20%26%20SERVICE%20BOOKLET.pdf';

const String _srcBydBrSongDmi =
    'BYD Brazil (official) — "SONG Plus DM-i (2025/2026)" revision (service) '
    'schedule, eff. 01-09-2026 — '
    'https://www.byd.com/material/__CN/byd-site/br/manuais-p%C3%B3s-vendas/updates-01-09-2026/SONG%20Plus%20DM-i%20%282025_2026%29.pdf';

const String _srcCheryEgEq7 =
    'Chery Egypt (official, chery-eg.com) — "Chery New EQ7 Maintenance Schedule" '
    '(PDF) — https://chery-eg.com/media/maintenance_schedules/Maintanance_EQ7.pdf';

const String _srcChanganPhPms =
    'Changan Philippines (official importer) — "Standard PMS Menu for All Changan '
    'Models" (Alsvin, CS15, CS35 Plus, CS55 Plus, X7, Uni-T, Uni-K) (PDF) — '
    'https://www.changan.ph/media/l3gp2w40/pms-menu-for-changan.pdf';

const String _srcGwmNzH6 =
    'GWM New Zealand (official importer) — "H6 Service NZ 2025" scheduled-'
    'maintenance tables (petrol / H6 HEV / H6 PHEV) — '
    'https://assets.gwmanz.com/f/256395/x/9eed77357a/h6_service_nz_2025.pdf';

const String _srcGwmAuH6gt =
    'GWM Australia (official importer) — "GWM Haval H6GT" Capped Price Service '
    '& Service Schedule (petrol & PHEV) (PDF) — '
    'https://assets.gwmanz.com/f/256395/x/11515d041a/gwm-haval-h6gt-cps-au.pdf';

const String _srcGwmMyHaval =
    'GWM Malaysia (official) — "HAVAL H HEV Maintenance Schedule" (service/parts '
    'price matrix, exclusive-service) (PDF) — '
    'https://www.gwm.com.my/content/dam/gwm/pages/my/en/exclusive-service/pdf/maintenance-haval.pdf';

const String _srcMgSg =
    'MG Singapore (official importer, mg.com.sg) — "Aftersales Service Schedule" '
    'article (base service intervals per model) — '
    'https://mg.com.sg/Articles/AftersalesServiceSchedule';

const String _srcGeelyKsa =
    'Geely Saudi Arabia (official importer, geelyksa.com) — "Periodic '
    'Maintenance / Service Cost" page (per-model service intervals + fuel '
    'filter note) — https://geelyksa.com/service-cost/';

const String _srcCheryMyOmodaO5 =
    'Chery Malaysia (official) — "THE NEW CHERY O5 — Service Schedule & Pricing '
    'Guide" (eff. 10 Sept 2025) — '
    'https://www.chery.my/wp-content/uploads/2025/09/Chery-Service-Maintenance-Schedule_O5_2025_compressed-1.pdf';

const String _srcCheryMyTiggo7Pro =
    'Chery Malaysia (official) — "TIGGO 7 PRO — Service Schedule & Pricing Guide" '
    '(eff. 29 Aug 2025) — '
    'https://www.chery.my/wp-content/uploads/2025/08/Chery-Service-Pricing-Guide_TIGGO-7-PRO_2025.pdf';

const String _srcCheryMyTiggo8Pro =
    'Chery Malaysia (official) — "TIGGO 8 PRO — Service Schedule & Pricing Guide" '
    '(eff. 29 Aug 2025) — '
    'https://www.chery.my/wp-content/uploads/2025/08/Chery-Service-Maintenance-Schedule_TIGGO-8-PRO_2025.pdf';

const String _srcCheryMyTiggoCross =
    'Chery Malaysia (official) — "TIGGO CROSS — Service Schedule & Pricing Guide" '
    '(1.5T + 6DCT) — '
    'https://www.chery.my/wp-content/uploads/2025/07/tiggocross-service-maintenance-schedules.pdf';

const String _srcJacQatarJs4 =
    'JAC Qatar (official importer) — "JAC JS4 1.5T CVT" periodic maintenance '
    'schedule (R/I table, 10K–120K km) (PDF; original jacqatar.com link now '
    'Cloudflare-blocked, read via Internet Archive snapshot 2024-08-31) — '
    'https://web.archive.org/web/20240831155910/https://www.jacqatar.com/wp-content/uploads/2024/01/JS4-1.pdf';

const String _srcChanganUkDeepal =
    'Changan UK / Deepal (official importer, changaneurope.com) — "Service '
    'Schedules" (Deepal S07 BEV, S05 BEV, S05 PHEV; year/mileage per-item table, '
    'intervals in years + miles) — '
    'https://website-editor.changaneurope.com/uk/owners/service-schedules';

const String _srcGeelyClBook =
    'Geely Chile (official importer) — "Geely Warranty book all models" '
    '(owner warranty & maintenance book, "Mantención Programada" scheduled-'
    'maintenance R/I grid + special-fluids pages for New Coolray / Coolray Lite '
    '/ Cityray, engine 4G15TD) — '
    'https://www.geely.cl/content/uploads/2026/03/Geely-Warranty-book-all-models.pdf';

// ---------------------------------------------------------------------------
// BYD  (battery-electric unless noted)
// ---------------------------------------------------------------------------

const OemModelSchedule _bydEvRangeCyprus = OemModelSchedule(
  make: 'BYD',
  model: 'Atto 3 / Atto 2 / Dolphin / Seal (RWD & AWD) / Seal U EV / Sealion',
  engine: 'Battery-electric (single/dual motor)',
  fuel: 'Electric',
  generationNote:
      'BYD Cyprus importer EV service-interval sheet; one table applicable to '
      'all listed BEV models. Columns are 30/60/90/120/150 ×1000 km at '
      '24/48/72/96/120 months — i.e. the base service interval is 30,000 km / '
      '24 months, whichever comes first. No normal/severe split is published.',
  intervals: [
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcBydCyprusEv,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Cabin HEPA / A-C filter',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcBydCyprusEv,
      grade: OemGrade.b,
    ),
    OemInterval(
      service: 'Gearbox (reduction gear) oil',
      intervalKm: 48000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcBydCyprusEv,
      grade: OemGrade.b,
      notes: 'Sheet: "Gearbox oil: Replacement every 24 months / 48,000 km".',
    ),
    OemInterval(
      service: 'Coolant — Power Distribution Unit (powertrain) circuit',
      intervalKm: 90000,
      intervalMonths: 72,
      severity: OemSeverity.normal,
      source: _srcBydCyprusEv,
      grade: OemGrade.b,
      notes: 'Replaced at the 90,000 km / 72-month service (single R in table). '
          'Coolant level inspected at every 30,000 km / 24-month service.',
    ),
    OemInterval(
      service: 'High-voltage battery check',
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcBydCyprusEv,
      grade: OemGrade.b,
      notes: 'Inspection at every service interval (not a replacement).',
    ),
    OemInterval(
      service: 'Tyre rotation',
      intervalKm: 10000,
      severity: OemSeverity.normal,
      source: _srcBydCyprusEv,
      grade: OemGrade.b,
      notes: 'Sheet recommends rotating all tyres and checking alignment '
          '"every 10,000 km approximately".',
    ),
  ],
);

const OemModelSchedule _bydAtto3Za = OemModelSchedule(
  make: 'BYD',
  model: 'Atto 3',
  engine: 'Battery-electric',
  fuel: 'Electric',
  generationNote:
      'BYD South Africa warranty & service booklet. Base service interval is '
      '2 years / 40,000 km, with the FIRST check at 20,000 km / 12 months '
      '(stated as a first check, not the recurring interval). This is a '
      'different market schedule from the BYD Cyprus sheet (40,000 km vs '
      '30,000 km) — kept separate, not merged.',
  intervals: [
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcBydZaAtto3,
      grade: OemGrade.b,
      notes: 'Booklet: "Brake fluid, Replace every 2 years or 40,000 km".',
    ),
    OemInterval(
      service: 'Drive-motor coolant',
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcBydZaAtto3,
      grade: OemGrade.b,
      notes: 'Booklet: "Drive motor coolant, Replace every 4 years" '
          '(no distance figure published).',
    ),
    OemInterval(
      service: 'Gear oil & transmission (reducer)',
      firstKm: 40000,
      severity: OemSeverity.normal,
      source: _srcBydZaAtto3,
      grade: OemGrade.c,
      notes: 'Booklet narrative: "Gear oil and transmission servicing starting '
          'from 40,000 km onward" — recurring interval not stated numerically.',
    ),
    OemInterval(
      service: 'Service interval (general)',
      intervalKm: 40000,
      intervalMonths: 24,
      firstKm: 20000,
      severity: OemSeverity.normal,
      source: _srcBydZaAtto3,
      grade: OemGrade.b,
      notes: 'First check 20,000 km / 12 months; thereafter 2 years / 40,000 km.',
    ),
  ],
);

const OemModelSchedule _bydSongDmi = OemModelSchedule(
  make: 'BYD',
  model: 'Song Plus DM-i',
  yearStart: 2025,
  yearEnd: 2026,
  engine: 'DM-i plug-in hybrid (1.5L + electric)',
  fuel: 'Plug-in hybrid',
  generationNote:
      'BYD Brazil revision-pricing schedule. Only the service cadence is '
      'published here (per-item fluid intervals are not broken out in this '
      'document) — recorded as the base interval only.',
  intervals: [
    OemInterval(
      service: 'Scheduled service (general)',
      intervalKm: 12000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcBydBrSongDmi,
      grade: OemGrade.b,
      notes: 'Doc: "As revisões deverão ocorrer a cada 12.000 km ODO ou 12 '
          'meses" — every 12,000 km / 12 months, to 120,000 km. Individual '
          'item intervals (oil, plugs, coolant) not itemised in this document.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// CHERY  (EQ7 is battery-electric)
// ---------------------------------------------------------------------------

const OemModelSchedule _cheryEq7 = OemModelSchedule(
  make: 'Chery',
  model: 'EQ7 (New EQ7)',
  engine: 'Battery-electric',
  fuel: 'Electric',
  generationNote:
      'Chery Egypt official maintenance schedule. BEV item set (drive-motor + '
      'power-battery cooling, reducer oil, HV battery check). Columns run '
      '10k–100k+ km. Some rows (brake fluid, A/C filter) could not be read '
      'unambiguously from the bilingual table and were omitted (see SOURCES).',
  intervals: [
    OemInterval(
      service: 'Coolant (drive-motor + power-battery cooling circuits)',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcCheryEgEq7,
      grade: OemGrade.a,
      notes: 'Table: "Replace the coolant (including drive motor cooling system '
          'and power battery cooling system) every 2 years or 40,000 km".',
    ),
    OemInterval(
      service: 'Reducer (reduction gear) fluid',
      firstKm: 30000,
      intervalKm: 40000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcCheryEgEq7,
      grade: OemGrade.a,
      notes: 'Table: "Replace the reducer gear oil every 2 years or 30,000 km '
          'after first driving, and after that every 3 years or 40,000 km". '
          '(firstKm = first change at 30,000 km / 24 mo; then 40,000 km / 36 mo.)',
    ),
    OemInterval(
      service: 'Power battery check',
      intervalKm: 5000,
      severity: OemSeverity.normal,
      source: _srcCheryEgEq7,
      grade: OemGrade.a,
      notes: 'Table: "Check the power battery every 5,000 km of driving".',
    ),
    OemInterval(
      service: 'Tyre rotation',
      severity: OemSeverity.normal,
      source: _srcCheryEgEq7,
      grade: OemGrade.b,
      notes: 'Rotated at each scheduled maintenance (pattern shown across the '
          'interval columns); exact km step not labelled as a single figure.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// CHANGAN  (ICE range)
// ---------------------------------------------------------------------------

const OemModelSchedule _changanPms = OemModelSchedule(
  make: 'Changan',
  model: 'Alsvin / CS15 / CS35 Plus / CS55 Plus / X7 / UNI-T / UNI-K',
  engine: 'Petrol (NA & turbo), per Changan PH standard PMS',
  fuel: 'Petrol',
  generationNote:
      'Changan Philippines "Standard PMS Menu for All Changan Models" — one '
      'range-wide table. Base interval: first service 5,000 km / 3 months, then '
      'every 10,000 km / 6 months (months 3/9/15/21… ; km 5/15/25/35… ×1000). '
      'The R/I cells could not be mapped to each item unambiguously from the '
      'PDF, so only the prose "Replace every X km" statements and the header '
      'interval are recorded; engine oil is graded C (see notes).',
  intervals: [
    OemInterval(
      service: 'Scheduled service (general)',
      intervalKm: 10000,
      intervalMonths: 6,
      firstKm: 5000,
      severity: OemSeverity.normal,
      source: _srcChanganPhPms,
      grade: OemGrade.a,
      notes: 'First PMS 5,000 km / 3 months, then every 10,000 km / 6 months.',
    ),
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 6,
      firstKm: 5000,
      severity: OemSeverity.normal,
      conditionBased: false,
      source: _srcChanganPhPms,
      grade: OemGrade.c,
      notes: 'Positionally implied: engine oil & filter fall on the PMS cadence '
          '(5,000 km first, then 10,000 km / 6 mo). Footnote *2 only states '
          '"Check the engine oil level and leak every 500 km or before a long '
          'trip" — the replacement cell could not be read unambiguously.',
    ),
    OemInterval(
      service: 'Manual / automatic / dual-clutch transmission fluid',
      intervalKm: 55000,
      severity: OemSeverity.normal,
      source: _srcChanganPhPms,
      grade: OemGrade.a,
      notes: 'Table: each transmission-fluid type "Replace every 55,000 km".',
    ),
    OemInterval(
      service: 'Power transfer unit oil (4WD)',
      intervalKm: 55000,
      severity: OemSeverity.normal,
      source: _srcChanganPhPms,
      grade: OemGrade.a,
      notes: 'Table: "Power transfer unit oil (4WD) … Replace every 55,000 km".',
    ),
    OemInterval(
      service: 'Brake / clutch fluid',
      intervalKm: 75000,
      severity: OemSeverity.normal,
      source: _srcChanganPhPms,
      grade: OemGrade.b,
      notes: 'Prose "Replace every 75,000 km" adjacent to the Brake/Clutch '
          'fluid & parking-brake rows; row-to-figure mapping slightly '
          'uncertain — confirm before display.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// GWM / HAVAL
// ---------------------------------------------------------------------------

const OemModelSchedule _gwmH6Petrol = OemModelSchedule(
  make: 'GWM (Haval)',
  model: 'H6',
  engine: '1.5T / 2.0T petrol',
  fuel: 'Petrol',
  generationNote:
      'GWM New Zealand "H6 Service NZ 2025". Base interval: first 10,000 km / '
      '12 months, then every 15,000 km / 12 months (km columns 10/25/40/55/70/'
      '85/100/115/130/145 ×1000). Engine oil is R at every service. Items whose '
      'exact km could not be read from the R/I grid (air filter, cabin filter, '
      'brake fluid) were omitted; prose-stated figures are kept. '
      'Footnote: "* Shorter in severe environment".',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 15000,
      intervalMonths: 12,
      firstKm: 10000,
      severity: OemSeverity.normal,
      source: _srcGwmNzH6,
      grade: OemGrade.b,
      notes: 'Replaced at every service: first 10,000 km / 12 mo, then '
          '15,000 km / 12 mo. "* Shorter in severe environment" (not quantified).',
    ),
    OemInterval(
      service: 'Spark plugs',
      firstKm: 70000,
      intervalKm: 60000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcGwmNzH6,
      grade: OemGrade.a,
      notes: 'Table: "First replace at 60 Months / 70,000 km, then every '
          '48 Months / 60,000 km".',
    ),
    OemInterval(
      service: 'Automatic transmission fluid & pressure filter',
      firstKm: 55000,
      intervalKm: 60000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcGwmNzH6,
      grade: OemGrade.a,
      notes: 'Table: "First Replace at 48 Months / 55,000 km then every '
          '48 Months / 60,000 km".',
    ),
    OemInterval(
      service: 'Generator / water-pump belt',
      intervalKm: 100000,
      intervalMonths: 84,
      severity: OemSeverity.normal,
      source: _srcGwmNzH6,
      grade: OemGrade.a,
      notes: 'Inspect every 2nd service; replace every 84 Months / 100,000 km.',
    ),
  ],
);

const OemModelSchedule _gwmH6Hev = OemModelSchedule(
  make: 'GWM (Haval)',
  model: 'H6 HEV / PHEV (DHT)',
  engine: '1.5L DHT hybrid (HEV & plug-in)',
  fuel: 'Hybrid',
  generationNote:
      'GWM New Zealand "H6 Service NZ 2025" — DHT hybrid tables (HEV and PHEV). '
      'Base service interval first 10,000 km / 12 months then 15,000 km / '
      '12 months. "Severe Use Service" rows exist; rear-diff severe figure '
      'recorded below. Air/cabin filter & brake-fluid exact km not cleanly '
      'readable from the grid — omitted.',
  intervals: [
    OemInterval(
      service: 'Spark plugs',
      firstKm: 40000,
      intervalKm: 45000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcGwmNzH6,
      grade: OemGrade.a,
      notes: 'Table: "First Replace at 40,000 km / 36 Months, then every '
          '45,000 km / 36 Months".',
    ),
    OemInterval(
      service: 'DHT oil (incl. front differential oil)',
      firstKm: 55000,
      intervalKm: 60000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcGwmNzH6,
      grade: OemGrade.a,
      notes: 'Table: "First replace at 48 Months / 55,000 km, then every '
          '48 Months / 60,000 km".',
    ),
    OemInterval(
      service: 'DHT transmission filter (AWD)',
      firstKm: 55000,
      intervalKm: 60000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcGwmNzH6,
      grade: OemGrade.a,
      notes: 'AWD only. "First replace at 48 Months / 55,000 km, then every '
          '48 Months / 60,000 km".',
    ),
    OemInterval(
      service: 'Engine coolant',
      firstKm: 55000,
      intervalKm: 60000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcGwmNzH6,
      grade: OemGrade.a,
      notes: 'Table: "First replace at 48 Months / 55,000 km, then every '
          '48 Months / 60,000 km".',
    ),
    OemInterval(
      service: 'Electrical / EV driving-system coolant',
      firstKm: 70000,
      intervalKm: 75000,
      intervalMonths: 60,
      severity: OemSeverity.normal,
      source: _srcGwmNzH6,
      grade: OemGrade.a,
      notes: 'Table: "First replace at 60 Months / 70,000 km, then every '
          '60 Months / 75,000 km".',
    ),
    OemInterval(
      service: 'Rear differential gear oil (AWD)',
      intervalKm: 55000,
      intervalMonths: 48,
      severity: OemSeverity.severe,
      source: _srcGwmNzH6,
      grade: OemGrade.a,
      notes: 'AWD only, severe-use row: "In the event of Severe use, replace '
          'every 55,000 km / 48 Months".',
    ),
  ],
);

const OemModelSchedule _gwmH6gt = OemModelSchedule(
  make: 'GWM (Haval)',
  model: 'H6 GT',
  engine: '2.0T petrol / PHEV',
  fuel: 'Petrol',
  generationNote:
      'GWM Australia H6GT service schedule + capped-price table. Service '
      'cadence: 1st 12 mo / 10,000 km; 2nd 24 mo / 25,000 km; 3rd 36 mo / '
      '40,000 km; 4th 48 mo / 55,000 km; 5th 60 mo / 70,000 km (i.e. ~15,000 km '
      '/ 12 mo after the first). Only the explicitly-stated long-interval items '
      'are recorded here; the R/I grid items were omitted.',
  intervals: [
    OemInterval(
      service: 'Disc brakes (front & rear)',
      intervalKm: 100000,
      severity: OemSeverity.normal,
      source: _srcGwmAuH6gt,
      grade: OemGrade.b,
      notes: 'Petrol schedule: "Disc brake front and rear — Replace every '
          '100,000 km".',
    ),
    OemInterval(
      service: 'Ball joint & dust cover / radiator',
      intervalKm: 55000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcGwmAuH6gt,
      grade: OemGrade.b,
      notes: '"Replace every 48 months / 55,000 km, whichever occurs first" '
          '(ball joint + dust cover; radiator appearance same interval).',
    ),
    OemInterval(
      service: 'Air cleaner element (severe duty)',
      intervalKm: 60000,
      severity: OemSeverity.severe,
      source: _srcGwmAuH6gt,
      grade: OemGrade.b,
      notes: 'Note: "Replace every 60,000 km if vehicle is driving under Severe '
          'Duty Conditions".',
    ),
  ],
);

const OemModelSchedule _gwmHavalHevMy = OemModelSchedule(
  make: 'GWM (Haval)',
  model: 'Haval H HEV (H6 HEV, Malaysia)',
  engine: '1.5L DHT hybrid',
  fuel: 'Hybrid',
  generationNote:
      'GWM Malaysia "HAVAL H HEV Maintenance Schedule" (service/parts price '
      'matrix). Service points: 12/24/36/48/60 months = 10,000/25,000/40,000/'
      '55,000/70,000 km. Mostly pricing; the one unambiguous long-interval '
      'figure is the transmission (DHT) fluid first change. Multipoint '
      'inspection + tyre rotation at every interval.',
  intervals: [
    OemInterval(
      service: 'Transmission (DHT) fluid',
      firstKm: 145000,
      intervalMonths: 120,
      severity: OemSeverity.normal,
      source: _srcGwmMyHaval,
      grade: OemGrade.b,
      notes: 'Note: "First replacement at 145,000 km or 120 months, whichever '
          'comes first".',
    ),
  ],
);

// ---------------------------------------------------------------------------
// MG  (base service intervals only — see SOURCES for the item-level gap)
// ---------------------------------------------------------------------------

const OemModelSchedule _mgBaseIntervals = OemModelSchedule(
  make: 'MG',
  model: 'HS (petrol) / ZS EV / MG5 EV / MG4 EV / S5 EV',
  engine: 'Petrol (HS) and battery-electric (ZS EV / MG5 EV / MG4 EV / S5 EV)',
  fuel: 'Mixed (see per-note)',
  generationNote:
      'MG Singapore official aftersales page — BASE service interval only. '
      'Item-level figures (brake fluid, coolant, spark plugs, reduction-gear '
      'oil) are an honest GAP: MG publishes them in a separate "Service '
      'Schedule" booklet whose files on mgcars.com returned 404/500 and whose '
      'manualslib copies are Cloudflare-blocked; the MG5 owner\'s manual itself '
      'only defers to that booklet (see SOURCES.md).',
  intervals: [
    OemInterval(
      service: 'Scheduled service (general) — HS petrol & EV range',
      intervalKm: 10000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcMgSg,
      grade: OemGrade.a,
      notes: 'MG HS (petrol), MG4 EV, MG5 EV, MG ZS EV and MG S5 EV are each '
          'listed at "10,000 km or 6 months". (MG M9 EV 15,000 km/12 mo; '
          'Cyberster 25,000 km/12 mo — not Lebanon-priority.)',
    ),
  ],
);

// ---------------------------------------------------------------------------
// GEELY  (base service intervals + fuel filter — item-level is a gap)
// ---------------------------------------------------------------------------

const OemModelSchedule _geelyKsaRange = OemModelSchedule(
  make: 'Geely',
  model: 'Coolray / New Coolray / Emgrand / Emgrand A1 / Azkarra / Tugella / GX3 Pro',
  engine: 'Petrol (per Geely KSA service-cost schedule)',
  fuel: 'Petrol',
  generationNote:
      'Geely Saudi Arabia (MENA importer) periodic-maintenance page. Gives the '
      'per-model service interval and one item-level figure (external fuel '
      'filter). Other item intervals (oil, plugs, coolant, brake fluid) are not '
      'published on this page — honest gap.',
  intervals: [
    OemInterval(
      service: 'Scheduled service — Coolray / Azkarra / Tugella / Emgrand A1 / GX3 Pro',
      intervalKm: 10000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcGeelyKsa,
      grade: OemGrade.b,
      notes: 'Every 10,000 km / 12 months (whichever first), through 150,000 km.',
    ),
    OemInterval(
      service: 'Scheduled service — New Emgrand',
      intervalKm: 7500,
      intervalMonths: 6,
      firstKm: 5000,
      severity: OemSeverity.normal,
      source: _srcGeelyKsa,
      grade: OemGrade.b,
      notes: 'New Emgrand only: first 5,000 km / 3 mo, 2nd 12,500 km / 9 mo, '
          'then every 7,500 km / 6 months.',
    ),
    OemInterval(
      service: 'Fuel filter (external, outside tank)',
      intervalKm: 30000,
      severity: OemSeverity.normal,
      source: _srcGeelyKsa,
      grade: OemGrade.b,
      notes: 'Page note under every model: "Fuel filters outside the fuel tank '
          'are replaced every 30,000 km". In-tank filter is maintenance-free.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// CHERY / OMODA  (ICE petrol — item-level, from Chery Malaysia official
// Service Schedule & Pricing Guides. These are machine-readable manufacturer
// tables; each sparse-row interval below was cross-checked against the printed
// TOTAL SERVICE & MAINTENANCE FEE column so the service/km mapping is exact.
// The km↔month pairing printed in every guide is 10,000 km ⇄ 6 months
// (10k/6mo, 20k/12mo, 30k/18mo, 40k/24mo, 50k/30mo, 60k/36mo …). No
// normal/severe split is published. Engine displacement is not printed on the
// guides; it is recorded from the oil spec / known Malaysia-market engine.)
// ---------------------------------------------------------------------------

const OemModelSchedule _cheryOmodaC5 = OemModelSchedule(
  make: 'Chery (Omoda)',
  model: 'Omoda 5 / Omoda C5 (facelift "Chery O5")',
  engine: 'Petrol 1.5T + DCT (oil spec: Fully Synthetic SP 5W30, 4.7L)',
  fuel: 'Petrol',
  generationNote:
      'Chery Malaysia "THE NEW CHERY O5" Service Schedule & Pricing Guide. '
      'Omoda 5 / Omoda C5 are the same vehicle (Omoda C5 is the international / '
      'MENA badge). Columns 1/10/20…150 ×1000 km at 1/6/12…84 months; base '
      'interval 10,000 km / 6 months (first 1,000 km break-in is FOC, not a '
      'replacement). Intervals verified against the printed total-fee column.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcCheryMyOmodaO5,
      grade: OemGrade.a,
      notes: 'Fully Synthetic SP 5W30 (4.7L) + filter at every service '
          '(10,000 km / 6 months).',
    ),
    OemInterval(
      service: 'Element air filter',
      intervalKm: 20000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcCheryMyOmodaO5,
      grade: OemGrade.a,
      notes: 'Replaced at 20/40/60/80/100/120/140 ×1000 km → every 20,000 km / '
          '12 months.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 30000,
      intervalMonths: 18,
      severity: OemSeverity.normal,
      source: _srcCheryMyOmodaO5,
      grade: OemGrade.a,
      notes: 'Replaced at 30/60/90/120/150 ×1000 km → every 30,000 km (18-month '
          'column). Kilometres are the governing figure.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcCheryMyOmodaO5,
      grade: OemGrade.a,
      notes: 'Replaced at 40/80/120 ×1000 km → every 40,000 km / 24 months.',
    ),
    OemInterval(
      service: 'DCT transmission oil',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcCheryMyOmodaO5,
      grade: OemGrade.a,
      notes: 'DCT Transmission Oil (4.3L) at 40/80/120 ×1000 km → every '
          '40,000 km / 24 months.',
    ),
    OemInterval(
      service: 'Radiator coolant',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcCheryMyOmodaO5,
      grade: OemGrade.a,
      notes: 'Radiator Coolant (4L) at 40/80/120 ×1000 km → every 40,000 km / '
          '24 months.',
    ),
  ],
);

const OemModelSchedule _cheryTiggo7Pro = OemModelSchedule(
  make: 'Chery',
  model: 'Tiggo 7 Pro',
  engine: 'Petrol 1.5T + DCT (oil spec: SP 5W30, 4.7L)',
  fuel: 'Petrol',
  generationNote:
      'Chery Malaysia "TIGGO 7 PRO" Service Schedule & Pricing Guide. Base '
      'interval 10,000 km / 6 months. DCT oil and coolant fall on a 50,000 km '
      'cadence here (vs 40,000 km on the Omoda O5) — recorded per model, not '
      'copied across. Intervals verified against the printed total-fee column.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo7Pro,
      grade: OemGrade.a,
      notes: 'Engine Oil SP 5W30 (4.7L) + filter at every service.',
    ),
    OemInterval(
      service: 'Element air filter',
      intervalKm: 20000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo7Pro,
      grade: OemGrade.a,
      notes: 'At 20/40/60/80/100/120/140 ×1000 km → every 20,000 km / 12 months.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 30000,
      intervalMonths: 18,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo7Pro,
      grade: OemGrade.a,
      notes: 'At 30/60/90/120/150 ×1000 km → every 30,000 km (18-month column).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo7Pro,
      grade: OemGrade.a,
      notes: 'At 40/80/120 ×1000 km → every 40,000 km / 24 months (120,000 km '
          'occurrence confirmed by total-fee decomposition).',
    ),
    OemInterval(
      service: 'DCT transmission oil',
      intervalKm: 50000,
      intervalMonths: 30,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo7Pro,
      grade: OemGrade.a,
      notes: 'DCT Transmission Oil (4.25L) at 50/100/150 ×1000 km → every '
          '50,000 km / 30 months.',
    ),
    OemInterval(
      service: 'Radiator coolant (long life)',
      intervalKm: 50000,
      intervalMonths: 30,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo7Pro,
      grade: OemGrade.a,
      notes: 'Radiator Coolant Long Life (4L) at 50/100/150 ×1000 km → every '
          '50,000 km / 30 months.',
    ),
  ],
);

const OemModelSchedule _cheryTiggo8Pro = OemModelSchedule(
  make: 'Chery',
  model: 'Tiggo 8 Pro',
  engine: 'Petrol 1.6T + DCT (oil spec: C5 0W20, 4.0L)',
  fuel: 'Petrol',
  generationNote:
      'Chery Malaysia "TIGGO 8 PRO" Service Schedule & Pricing Guide. 1.6TGDI '
      '(0W20 oil). Base interval 10,000 km / 6 months. DCT oil + coolant on a '
      '50,000 km cadence. Intervals verified against the printed total-fee '
      'column.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo8Pro,
      grade: OemGrade.a,
      notes: 'Engine Oil C5 0W20 (4.0L) + filter at every service.',
    ),
    OemInterval(
      service: 'Element air filter',
      intervalKm: 20000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo8Pro,
      grade: OemGrade.a,
      notes: 'At 20/40/60/80/100/120/140 ×1000 km → every 20,000 km / 12 months.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 30000,
      intervalMonths: 18,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo8Pro,
      grade: OemGrade.a,
      notes: 'At 30/60/90/120/150 ×1000 km → every 30,000 km (18-month column).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo8Pro,
      grade: OemGrade.a,
      notes: 'At 40/80/120 ×1000 km → every 40,000 km / 24 months (120,000 km '
          'occurrence confirmed by total-fee decomposition).',
    ),
    OemInterval(
      service: 'DCT transmission oil',
      intervalKm: 50000,
      intervalMonths: 30,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo8Pro,
      grade: OemGrade.a,
      notes: 'DCT Transmission Oil (4.25L) at 50/100/150 ×1000 km → every '
          '50,000 km / 30 months.',
    ),
    OemInterval(
      service: 'Radiator coolant (long life)',
      intervalKm: 50000,
      intervalMonths: 30,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggo8Pro,
      grade: OemGrade.a,
      notes: 'Radiator Coolant Long Life (4L) at 50/100/150 ×1000 km → every '
          '50,000 km / 30 months.',
    ),
  ],
);

const OemModelSchedule _cheryTiggoCross = OemModelSchedule(
  make: 'Chery',
  model: 'Tiggo Cross',
  engine: 'Petrol 1.5T + 6DCT (oil 4.7L)',
  fuel: 'Petrol',
  generationNote:
      'Chery Malaysia "TIGGO CROSS" Service Schedule & Pricing Guide (1.5T + '
      '6DCT page). Base interval 10,000 km / 6 months. This guide prints no '
      'coolant row, so coolant is intentionally omitted. Transmission oil is a '
      '6DCT (3.4L) on a 60,000 km cadence. Verified against the total-fee '
      'column.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggoCross,
      grade: OemGrade.a,
      notes: 'Engine oil (4.7L) + filter at every service.',
    ),
    OemInterval(
      service: 'Element air filter',
      intervalKm: 20000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggoCross,
      grade: OemGrade.a,
      notes: 'At 20/40/60/80/100/120/140 ×1000 km → every 20,000 km / 12 months.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 30000,
      intervalMonths: 18,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggoCross,
      grade: OemGrade.a,
      notes: 'At 30/60/90/120/150 ×1000 km → every 30,000 km (18-month column).',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggoCross,
      grade: OemGrade.a,
      notes: 'At 40/80/120 ×1000 km → every 40,000 km / 24 months.',
    ),
    OemInterval(
      service: 'Transmission oil (6DCT)',
      intervalKm: 60000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcCheryMyTiggoCross,
      grade: OemGrade.a,
      notes: 'Transmission Oil (3.4L) at 60/120 ×1000 km → every 60,000 km / '
          '36 months.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// JAC  (ICE petrol — item-level, from JAC Qatar official importer R/I table)
// ---------------------------------------------------------------------------

const OemModelSchedule _jacJs4 = OemModelSchedule(
  make: 'JAC',
  model: 'JS4',
  engine: 'Petrol 1.5T + CVT',
  fuel: 'Petrol',
  generationNote:
      'JAC Qatar official "JAC JS4 1.5T CVT" periodic maintenance table — a '
      'clean R(replace)/I(inspect) grid, columns 10K–120K km paired 10,000 km ⇄ '
      '6 months. Every replacement interval below is read directly from an R '
      'cell. No normal/severe split is published. Only the JS4 1.5T CVT is '
      'covered by this document (JS6 not included — left as a gap, not copied).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 6,
      severity: OemSeverity.normal,
      source: _srcJacQatarJs4,
      grade: OemGrade.a,
      notes: 'R at every 10,000 km column (drain-plug washer also replaced each '
          'service).',
    ),
    OemInterval(
      service: 'Air filter element',
      intervalKm: 20000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcJacQatarJs4,
      grade: OemGrade.a,
      notes: 'R at 20/40/60/80/100/120 ×1000 km (inspected at the alternate '
          '10K services) → every 20,000 km / 12 months.',
    ),
    OemInterval(
      service: 'A/C (cabin) filter',
      intervalKm: 20000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcJacQatarJs4,
      grade: OemGrade.a,
      notes: 'R at 20/40/60/80/100/120 ×1000 km → every 20,000 km / 12 months.',
    ),
    OemInterval(
      service: 'Fuel filter',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcJacQatarJs4,
      grade: OemGrade.a,
      notes: 'R at 40/80/120 ×1000 km → every 40,000 km / 24 months.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcJacQatarJs4,
      grade: OemGrade.a,
      notes: 'R at 40/80/120 ×1000 km → every 40,000 km / 24 months.',
    ),
    OemInterval(
      service: 'Transmission (CVT) oil & filter',
      intervalKm: 60000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcJacQatarJs4,
      grade: OemGrade.a,
      notes: 'Transmission oil and transmission oil filter both R at 60/120 '
          '×1000 km → every 60,000 km / 36 months.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 60000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcJacQatarJs4,
      grade: OemGrade.a,
      notes: 'R at 60/120 ×1000 km → every 60,000 km / 36 months (inspected at '
          'intermediate services).',
    ),
    OemInterval(
      service: 'Engine coolant',
      intervalKm: 80000,
      intervalMonths: 48,
      firstKm: 80000,
      severity: OemSeverity.normal,
      source: _srcJacQatarJs4,
      grade: OemGrade.b,
      notes: 'First (and only) R in the 120K-km table is at 80,000 km / '
          '48 months; inspected at all other services. Recurring interval '
          'beyond 120K not shown on this table — firstKm recorded, treat the '
          'interval as the first-change baseline.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// DEEPAL  (Changan's EV brand. Per-model BEV vs PHEV is taken from the Changan
// UK importer schedule, which itemises engine-bearing items only for the PHEV.
// The UK market sells the S07 and S05 as BEV and the S05 as PHEV; intervals are
// published in YEARS + MILES, so months are exact and km are left null rather
// than converted. A separate S07 REEV / range-extender variant exists in other
// markets — no reachable schedule was found for it, so it is NOT recorded
// (would need its own fuel + engine-oil set). Nothing copied across variants.)
// ---------------------------------------------------------------------------

const OemModelSchedule _deepalS07Bev = OemModelSchedule(
  make: 'Deepal',
  model: 'S07 (BEV)',
  engine: 'Battery-electric',
  fuel: 'Electric',
  generationNote:
      'Changan UK / Deepal official service schedule. S07 BEV: base service '
      'every 12 months / 12,000 miles, first service at 24 months / 24,000 '
      'miles. Per-item intervals are year-based (2nd/4th/6th year = every '
      '24 months; 3rd/6th year = every 36 months). Distances are published in '
      'miles only, so intervalKm is left null and the mile figure is noted.',
  intervals: [
    OemInterval(
      service: 'Scheduled service (general)',
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: 'Every 12 months or 12,000 miles (~19,300 km), whichever first; '
          'first service at 24 months / 24,000 miles.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: 'Replaced at the 2nd, 4th and 6th year → every 24 months.',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: '2nd, 4th and 6th year → every 24 months.',
    ),
    OemInterval(
      service: 'Coolant',
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: '3rd and 6th year → every 36 months.',
    ),
    OemInterval(
      service: 'Electric drive system (reducer) lubricating oil',
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: '3rd and 6th year → every 36 months.',
    ),
    OemInterval(
      service: 'High-voltage battery check',
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: 'Battery check at the 3rd and 6th year → every 36 months '
          '(inspection, not replacement).',
    ),
  ],
);

const OemModelSchedule _deepalS05Phev = OemModelSchedule(
  make: 'Deepal',
  model: 'S05 (PHEV)',
  engine: 'Plug-in hybrid (petrol engine + electric drive)',
  fuel: 'Plug-in hybrid',
  generationNote:
      'Changan UK / Deepal official service schedule. S05 PHEV has a petrol '
      'engine, so the engine item set (oil, spark plugs, engine air filter) is '
      'present in addition to the EV items. Base service every 12 months / '
      '12,000 miles, first service at 12 months / 12,000 miles. Per-item '
      'intervals are year-based; distances published in miles only (km null).',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: 'Replaced every year (1st–7th) → every 12 months / ~12,000 miles.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: '2nd, 4th and 6th year → every 24 months.',
    ),
    OemInterval(
      service: 'Engine air filter',
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: '2nd, 4th and 6th year → every 24 months.',
    ),
    OemInterval(
      service: 'E-drive transmission oil',
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: '3rd and 6th year → every 36 months.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: '2nd, 4th and 6th year → every 24 months.',
    ),
    OemInterval(
      service: 'Cabin air filter',
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: '2nd, 4th and 6th year → every 24 months.',
    ),
    OemInterval(
      service: 'Coolant',
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcChanganUkDeepal,
      grade: OemGrade.b,
      notes: '3rd and 6th year → every 36 months.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// GEELY  (ICE petrol — item-level Coolray schedule, from the Geely Chile
// official owner warranty & maintenance book "Mantención Programada" table.
// This upgrades the earlier Geely entry, which had only the base interval +
// fuel filter from Geely KSA. Engine 4G15TD (1.5T), oil 0W-20, brake DOT4.
// Items with an explicit Spanish prose interval ("Reemplazar cada …") are
// Grade A; R/I-grid items are read from the printed grid.)
// ---------------------------------------------------------------------------

const OemModelSchedule _geelyCoolrayItems = OemModelSchedule(
  make: 'Geely',
  model: 'Coolray (New Coolray / Coolray Lite / Cityray)',
  engine: 'Petrol 1.5T (4G15TD); oil API SP 0W-20',
  fuel: 'Petrol',
  generationNote:
      'Geely Chile all-models warranty & maintenance book, "Mantención '
      'Programada" schedule for New Coolray / Coolray Lite / Cityray. Grid '
      'columns are services 1–10 at 10,000 km ⇄ 12 months (10k/12mo, 20k/24mo, '
      '40k/48mo, …). Base service interval 10,000 km / 12 months (already '
      'captured from Geely KSA); this entry adds the per-item intervals. CVT '
      'and manual-transmission fluids differ — both recorded.',
  intervals: [
    OemInterval(
      service: 'Engine oil & filter',
      intervalKm: 10000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcGeelyClBook,
      grade: OemGrade.a,
      notes: 'Engine oil (API SP 0W-20) + oil filter: R at every service → '
          '10,000 km / 12 months.',
    ),
    OemInterval(
      service: 'Air filter',
      intervalKm: 20000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcGeelyClBook,
      grade: OemGrade.a,
      notes: 'R at services 2/4/6/8/10 → every 20,000 km / 24 months.',
    ),
    OemInterval(
      service: 'A/C (cabin) filter',
      intervalKm: 20000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcGeelyClBook,
      grade: OemGrade.a,
      notes: 'Filtro de Aire Acondicionado: R at services 2/4/6/8/10 → every '
          '20,000 km / 24 months.',
    ),
    OemInterval(
      service: 'Spark plugs',
      intervalKm: 40000,
      intervalMonths: 48,
      severity: OemSeverity.normal,
      source: _srcGeelyClBook,
      grade: OemGrade.a,
      notes: 'Bujía: R at services 4 and 8 → every 40,000 km / 48 months.',
    ),
    OemInterval(
      service: 'Engine coolant',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcGeelyClBook,
      grade: OemGrade.a,
      notes: 'Prose: "Reemplazar cada 24 meses o 40.000 km" → every 40,000 km '
          '/ 24 months.',
    ),
    OemInterval(
      service: 'Brake fluid',
      intervalKm: 40000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcGeelyClBook,
      grade: OemGrade.a,
      notes: 'Prose: "Reemplazar cada 24 meses o 40.000 km" (DOT4) → every '
          '40,000 km / 24 months.',
    ),
    OemInterval(
      service: 'Fuel filter',
      intervalKm: 30000,
      intervalMonths: 12,
      severity: OemSeverity.normal,
      source: _srcGeelyClBook,
      grade: OemGrade.a,
      notes: 'Prose: "Reemplazar cada 1 año o 30.000 km" → every 30,000 km / '
          '12 months.',
    ),
    OemInterval(
      service: 'Drive (accessory) belt',
      intervalKm: 60000,
      intervalMonths: 36,
      severity: OemSeverity.normal,
      source: _srcGeelyClBook,
      grade: OemGrade.a,
      notes: 'Prose: "Reemplazar cada 36 meses o 60.000 km" → every 60,000 km '
          '/ 36 months. (Timing is by chain — no scheduled replacement.)',
    ),
    OemInterval(
      service: 'CVT transmission fluid',
      firstKm: 40000,
      severity: OemSeverity.normal,
      source: _srcGeelyClBook,
      grade: OemGrade.a,
      notes: 'Prose: "Reemplazar a los 40.000 km. Después sin mantención" — '
          'single change at 40,000 km, then maintenance-free.',
    ),
    OemInterval(
      service: 'Manual transmission fluid',
      firstKm: 10000,
      intervalKm: 30000,
      intervalMonths: 24,
      severity: OemSeverity.normal,
      source: _srcGeelyClBook,
      grade: OemGrade.a,
      notes: 'Prose: "Reemplazar a los 10.000 km, luego cada 24 meses o '
          '30.000 km" → first at 10,000 km, then every 30,000 km / 24 months.',
    ),
  ],
);

// ---------------------------------------------------------------------------
// The dataset.
//
// COVERAGE / GAPS (full detail in oem_schedules_chinese_SOURCES.md):
//   • Solid item-level data: BYD BEV range, Chery EQ7 (BEV), Chery Omoda C5 /
//     Tiggo 7 Pro / Tiggo 8 Pro / Tiggo Cross (ICE petrol, Chery Malaysia),
//     Changan ICE range, GWM/Haval H6 (petrol + DHT hybrid/PHEV + GT + Malaysia
//     HEV), JAC JS4 (ICE petrol), Geely Coolray (ICE petrol, full item set),
//     Deepal S07 BEV + S05 PHEV (Changan UK, time-based).
//   • Interval-only (item-level gap): MG (HS + EV range), Geely KSA range
//     (+ fuel filter; Coolray now item-level), BYD Song Plus DM-i (PHEV cadence).
//   • COMPLETE GAPS — no reachable official schedule, nothing recorded:
//     Chery Tiggo 2 / Tiggo 4 Pro (ICE; Malaysia has no guide, Chery Egypt media
//     links not resolvable), Jetour X70/Dashing (no fetchable official table),
//     JAC JS6 (only JS4 was published), Avatr 11/12, Voyah (Free/Dreamer EREV,
//     Courage BEV — powertrain known but no reachable schedule), Seres/Aito
//     M5/M7 (EREV + BEV variants — no reachable schedule). Per the GOLDEN RULE
//     no figures were invented or copied across brands/models for these.
// ---------------------------------------------------------------------------

const List<OemModelSchedule> kOemChineseSchedules = [
  // BYD
  _bydEvRangeCyprus,
  _bydAtto3Za,
  _bydSongDmi,
  // Chery
  _cheryEq7,
  _cheryOmodaC5,
  _cheryTiggo7Pro,
  _cheryTiggo8Pro,
  _cheryTiggoCross,
  // Changan
  _changanPms,
  // JAC
  _jacJs4,
  // Deepal (Changan EV brand)
  _deepalS07Bev,
  _deepalS05Phev,
  // GWM / Haval
  _gwmH6Petrol,
  _gwmH6Hev,
  _gwmH6gt,
  _gwmHavalHevMy,
  // MG
  _mgBaseIntervals,
  // Geely
  _geelyKsaRange,
  _geelyCoolrayItems,
];
