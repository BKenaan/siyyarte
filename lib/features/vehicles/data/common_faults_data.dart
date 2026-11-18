import '../models/common_fault.dart';

/// Curated, source-cited catalogue of known common faults for Lebanon-market
/// priority vehicles.
///
/// ACCURACY RULES (do not relax):
///  * Every entry cites a REAL recall, service bulletin, regulator
///    investigation, or reputable reliability reference.
///  * No fault or symptom is invented. Where a vehicle could not be sourced to
///    a trustworthy reference it is intentionally omitted (coverage honesty
///    over padding) — see the "GAPS" note at the bottom.
///  * Fault prose is English technical data; the UI chrome is localized.
///
/// Last researched: 2026-11-18.
const List<CommonFault> kCommonFaults = [
  // ─────────────────────────── TOYOTA ───────────────────────────
  CommonFault(
    id: 'toyota_hilux_1gd_dpf',
    make: 'Toyota',
    model: 'Hilux',
    yearStart: 2015,
    yearEnd: 2020,
    engine: '2.8L 1GD-FTV turbo-diesel',
    engineKeywords: ['2.8', '1gd', 'diesel'],
    severity: FaultSeverity.medium,
    title: 'Diesel particulate filter (DPF) fails to self-regenerate',
    description:
        'On 1GD-FTV 2.8L diesels the DPF did not always regenerate automatically, '
        'leading to soot build-up. Toyota did not issue a safety recall but ran '
        'customer-service campaigns, pushed updated engine software, and made a '
        'manual regeneration switch standard from June 2018. Affected diesels '
        'without the regen switch later received extended DPF warranty cover.',
    symptom:
        'White smoke and a noxious smell during regeneration, reduced power, '
        'higher fuel consumption, and DPF warning lights.',
    source: FaultSource(
      type: FaultSourceType.manufacturerCampaign,
      publisher: 'Toyota (field action, reported by Drive/CarAdvice)',
      reference: 'DPF field action / extended warranty (HiLux, Prado, Fortuner)',
      url:
          'https://www.caradvice.com.au/895546/toyota-offers-10-year-unlimited-kilometre-warranty-on-cars-with-faulty-dpfs/',
    ),
  ),
  CommonFault(
    id: 'toyota_fortuner_1gd_dpf',
    make: 'Toyota',
    model: 'Fortuner',
    yearStart: 2015,
    yearEnd: 2020,
    engine: '2.8L 1GD-FTV turbo-diesel',
    engineKeywords: ['2.8', '1gd', 'diesel'],
    severity: FaultSeverity.medium,
    title: 'Diesel particulate filter (DPF) fails to self-regenerate',
    description:
        'The Fortuner shares the 1GD-FTV 2.8L diesel and the same DPF behaviour: '
        'filters that do not always auto-regenerate. Toyota addressed it with '
        'customer-service campaigns, updated software, a manual regen switch '
        '(standard from June 2018), and extended DPF warranty coverage.',
    symptom:
        'White smoke and strong odour during regeneration, power loss, and '
        'rising fuel consumption.',
    source: FaultSource(
      type: FaultSourceType.manufacturerCampaign,
      publisher: 'Toyota (field action, reported by Drive/CarAdvice)',
      reference: 'DPF field action / extended warranty (HiLux, Prado, Fortuner)',
      url:
          'https://www.caradvice.com.au/895546/toyota-offers-10-year-unlimited-kilometre-warranty-on-cars-with-faulty-dpfs/',
    ),
  ),
  CommonFault(
    id: 'toyota_prado_1kd_pistons',
    make: 'Toyota',
    model: 'Prado',
    yearStart: 2009,
    yearEnd: 2014,
    engine: '3.0L 1KD-FTV turbo-diesel',
    engineKeywords: ['3.0', '1kd', 'diesel'],
    severity: FaultSeverity.high,
    title: 'Cracked / holed pistons on the 1KD-FTV 3.0L diesel',
    description:
        'Early J150 Land Cruiser Prado 1KD-FTV 3.0L diesels are documented to '
        'suffer cracked pistons that can lead to catastrophic engine failure. '
        'Toyota introduced production changes on the KDJ150/155 in January 2014 '
        '(from engine no. 2361817). Early 150-series also had a separate 1KD '
        'injector recall.',
    symptom:
        'Power loss, heavy smoke, rattling/knocking under load, and in severe '
        'cases engine failure.',
    source: FaultSource(
      type: FaultSourceType.reliabilityReference,
      publisher: 'AustralianCar.Reviews (known-issues / recall listing)',
      reference: 'LandCruiser Prado 150 1KD-FTV cracked pistons',
      url: 'https://www.australiancar.reviews/?p=47886',
    ),
  ),
  CommonFault(
    id: 'toyota_camry_2az_oil',
    make: 'Toyota',
    model: 'Camry',
    yearStart: 2007,
    yearEnd: 2009,
    engine: '2.4L 2AZ-FE petrol',
    engineKeywords: ['2.4', '2az'],
    severity: FaultSeverity.high,
    title: 'Excessive oil consumption (2AZ-FE piston rings)',
    description:
        'The 2.4L 2AZ-FE four-cylinder (used in this Camry generation) is a '
        'documented excessive-oil-consumption engine. Toyota issued a technical '
        'service bulletin covering a redesigned piston/ring assembly as the '
        'repair, and extended warranty assistance for affected cars.',
    symptom:
        'Oil level drops between services with no visible leak, low-oil or '
        'engine light, and possible rattling if run low.',
    source: FaultSource(
      type: FaultSourceType.tsb,
      publisher: 'Toyota (TSB, via NHTSA/CarComplaints)',
      reference: 'TSB T-SB-0158-14 — 2AZ-FE oil consumption / piston replacement',
      url:
          'https://www.carcomplaints.com/Toyota/Camry/2008/engine/engine.shtml',
    ),
  ),

  // ─────────────────────────── NISSAN ───────────────────────────
  CommonFault(
    id: 'nissan_altima_cvt',
    make: 'Nissan',
    model: 'Altima',
    yearStart: 2013,
    yearEnd: 2018,
    engine: 'Jatco CVT (with 2.5L QR25DE)',
    engineKeywords: ['cvt', '2.5', 'qr25'],
    severity: FaultSeverity.high,
    title: 'Premature CVT (continuously variable transmission) failure',
    description:
        'The Jatco CVT in this Altima generation draws a high volume of owner '
        'complaints (collated from NHTSA data) for premature failure, '
        'shuddering and overheating into limp mode. No federal recall exists '
        'for the CVT itself, but Nissan extended the CVT warranty and issued '
        'TSBs for several model years.',
    symptom:
        'Shuddering/juddering on acceleration, hesitation or surging, whining '
        'noise, and overheating that drops the car into limp mode.',
    typicalMileageKm: 160000,
    source: FaultSource(
      type: FaultSourceType.reliabilityReference,
      publisher: 'CarComplaints.com (aggregating NHTSA ODI complaints)',
      reference: 'Nissan Altima powertrain / CVT complaints',
      url:
          'https://www.carcomplaints.com/Nissan/Altima/2014/drivetrain/power_train.shtml',
    ),
  ),
  CommonFault(
    id: 'nissan_patrol_y62_brakes',
    make: 'Nissan',
    model: 'Patrol',
    yearStart: 2010,
    yearEnd: 2019,
    engine: '5.6L VK56 V8 petrol',
    engineKeywords: ['5.6', 'vk56', 'v8'],
    severity: FaultSeverity.low,
    title: 'Accelerated brake and tyre wear (kerb weight)',
    description:
        'The Y62 Patrol is a very heavy SUV, and reviewers/owners consistently '
        'report that brake pads, rotors and tyres wear faster than average — a '
        'running cost to budget for rather than a defect. Early Y62s were also '
        'subject to a fuel-system recall; check your VIN against the recall '
        'database.',
    symptom:
        'Shorter-than-expected pad/rotor and tyre life; brake shudder or noise '
        'as components wear.',
    source: FaultSource(
      type: FaultSourceType.reliabilityReference,
      publisher: 'ReDriven (used-vehicle buyer review)',
      reference: 'Nissan Patrol Y62 ownership/known-issues review',
      url: 'https://redriven.com/?p=5790',
    ),
  ),

  // ────────────────────────── MERCEDES ──────────────────────────
  CommonFault(
    id: 'mercedes_cclass_m272_balanceshaft',
    make: 'Mercedes',
    model: 'C-Class',
    yearStart: 2004,
    yearEnd: 2008,
    engine: 'M272 V6 (early builds)',
    engineKeywords: ['m272', 'v6', '3.0', '3.5'],
    severity: FaultSeverity.high,
    title: 'M272 balance-shaft gear premature wear',
    description:
        'Early M272 V6 engines used a sintered-steel gear (balance-shaft '
        'sprocket) that wears prematurely, throwing off timing. Mercedes '
        'switched to conventional steel around 2006, so pre-2006/early builds '
        'are most at risk. A class action provided extended coverage for the '
        'affected gears.',
    symptom:
        'Check-engine light with camshaft/crankshaft correlation codes '
        '(P0016/P0017/P0018), misfires, and rough running.',
    source: FaultSource(
      type: FaultSourceType.reliabilityReference,
      publisher: 'The Truth About Cars (reporting Auto Bild)',
      reference: 'Mercedes M272/M273 timing-gear wear (2004–2006 builds)',
      url:
          'https://www.thetruthaboutcars.com/2011/08/mercedes-hit-with-timing-chain-issues/',
    ),
  ),
  CommonFault(
    id: 'mercedes_eclass_m272_m273_balanceshaft',
    make: 'Mercedes',
    model: 'E-Class',
    yearStart: 2004,
    yearEnd: 2008,
    engine: 'M272 V6 / M273 V8 (early builds)',
    engineKeywords: ['m272', 'm273', 'v6', 'v8', '3.5', '5.5'],
    severity: FaultSeverity.high,
    title: 'M272/M273 balance-shaft & idler-gear wear',
    description:
        'Early M272 V6 (balance-shaft sprocket) and M273 V8 (timing idler gear) '
        'engines used a soft sintered-steel gear that wears early and slackens '
        'the timing chain. Mercedes moved to conventional steel around 2006; '
        'early builds are most affected and were covered by a class action.',
    symptom:
        'Check-engine light with timing-correlation codes, misfires, rough '
        'idle, and rattle from the front of the engine.',
    source: FaultSource(
      type: FaultSourceType.reliabilityReference,
      publisher: 'The Truth About Cars (reporting Auto Bild)',
      reference: 'Mercedes M272/M273 timing-gear wear (2004–2006 builds)',
      url:
          'https://www.thetruthaboutcars.com/2011/08/mercedes-hit-with-timing-chain-issues/',
    ),
  ),
  CommonFault(
    id: 'mercedes_ml_m272_m273_balanceshaft',
    make: 'Mercedes',
    model: 'ML',
    yearStart: 2005,
    yearEnd: 2008,
    engine: 'M272 V6 / M273 V8 (early builds)',
    engineKeywords: ['m272', 'm273', 'v6', 'v8', '3.5', '5.5'],
    severity: FaultSeverity.high,
    title: 'M272/M273 balance-shaft & idler-gear wear',
    description:
        'The W164 ML (ML350/ML500) uses the same early M272 V6 / M273 V8 '
        'engines whose sintered-steel balance-shaft sprocket (V6) or idler gear '
        '(V8) wears prematurely. Pre-2006/early builds are most at risk; a '
        'class action extended coverage for the affected gears.',
    symptom:
        'Check-engine light with timing-correlation codes (P0016–P0018), '
        'misfires, and rough running.',
    source: FaultSource(
      type: FaultSourceType.reliabilityReference,
      publisher: 'The Truth About Cars (reporting Auto Bild)',
      reference: 'Mercedes M272/M273 timing-gear wear (2004–2006 builds)',
      url:
          'https://www.thetruthaboutcars.com/2011/08/mercedes-hit-with-timing-chain-issues/',
    ),
  ),
  CommonFault(
    id: 'mercedes_gle_ml_airmatic_compressor',
    make: 'Mercedes',
    model: 'GLE',
    yearStart: 2012,
    yearEnd: 2019,
    engine: 'AIRMATIC air-suspension equipped (W166 GLE/ML)',
    engineKeywords: ['airmatic', 'air suspension', 'air-suspension'],
    severity: FaultSeverity.medium,
    title: 'AIRMATIC air-suspension compressor failure',
    description:
        'On AIRMATIC-equipped W166 GLE/ML, ageing air springs develop leaks; '
        'the compressor then runs longer to compensate until it overheats and '
        'fails. A leaking strut will burn out a replacement compressor within '
        'months, so the leak must be fixed too. Only applies to air-suspension '
        'cars (not steel-spring variants).',
    symptom:
        '"AIRMATIC malfunction" warning, the car sagging on one corner or '
        'overnight, a constantly running/noisy compressor, and a harsh ride.',
    source: FaultSource(
      type: FaultSourceType.reliabilityReference,
      publisher: 'Au7o (aggregated owner-report known-issues)',
      reference: 'Mercedes GLE air-suspension compressor failure',
      url: 'https://www.au7o.io/known-issues/mercedes-benz-gle',
    ),
  ),

  // ────────────────────────── CHEVROLET ─────────────────────────
  CommonFault(
    id: 'chevrolet_tahoe_53_afm',
    make: 'Chevrolet',
    model: 'Tahoe',
    yearStart: 2007,
    yearEnd: 2013,
    engine: '5.3L V8 with Active Fuel Management (AFM)',
    engineKeywords: ['5.3', 'v8', 'afm'],
    severity: FaultSeverity.high,
    title: 'AFM-linked oil consumption & lifter failure (5.3L V8)',
    description:
        'The aluminium-block 5.3L V8 with Active Fuel Management is documented '
        'for excessive oil consumption (oil thrown onto the cylinders during '
        'cylinder deactivation) and collapsed AFM lifters. GM\'s service '
        'bulletin recommends an AFM oil deflector/shield and carbon cleanup.',
    symptom:
        'Burning ~1 quart of oil every 500–600 miles, low-oil warnings, '
        'ticking/misfire from a collapsed lifter, and cylinder-deactivation '
        'faults.',
    source: FaultSource(
      type: FaultSourceType.tsb,
      publisher: 'General Motors (Technical Service Bulletin)',
      reference: 'GM TSB #10-06-01-008B — 5.3L AFM oil consumption (2007–2009)',
      url:
          'https://carcomplaints.com/Chevrolet/Suburban/2007/engine/excessive_oil_consumption.shtml',
    ),
  ),
  CommonFault(
    id: 'chevrolet_suburban_53_afm',
    make: 'Chevrolet',
    model: 'Suburban',
    yearStart: 2007,
    yearEnd: 2013,
    engine: '5.3L V8 with Active Fuel Management (AFM)',
    engineKeywords: ['5.3', 'v8', 'afm'],
    severity: FaultSeverity.high,
    title: 'AFM-linked oil consumption & lifter failure (5.3L V8)',
    description:
        'The Suburban shares the aluminium-block 5.3L AFM V8 and the same '
        'failure modes: excessive oil consumption and collapsed AFM lifters. '
        'GM\'s bulletin covers 2007–2009 models and recommends an AFM oil '
        'deflector plus cylinder carbon cleaning.',
    symptom:
        'Heavy oil use with no external leak, low-oil light, lifter tick or '
        'misfire, and rough running in V4 (cylinder-deactivation) mode.',
    source: FaultSource(
      type: FaultSourceType.tsb,
      publisher: 'General Motors (Technical Service Bulletin)',
      reference: 'GM TSB #10-06-01-008B — 5.3L AFM oil consumption (2007–2009)',
      url:
          'https://carcomplaints.com/Chevrolet/Suburban/2007/engine/excessive_oil_consumption.shtml',
    ),
  ),

  // ───────────────────────── HYUNDAI / KIA ──────────────────────
  CommonFault(
    id: 'kia_sportage_theta2_rodbearing',
    make: 'Kia',
    model: 'Sportage',
    yearStart: 2011,
    yearEnd: 2013,
    engine: '2.4L Theta II GDI',
    engineKeywords: ['2.4', 'theta', 'gdi'],
    severity: FaultSeverity.high,
    title: 'Theta II connecting-rod bearing failure',
    description:
        'The 2.4L Theta II GDI engine can suffer connecting-rod bearing wear '
        '(linked to manufacturing debris) that leads to knocking, stalling, '
        'seizure and fire risk. Kia/Hyundai conducted large Theta II recalls '
        'and paid a combined US\$210M civil penalty; a class settlement provided '
        'a lifetime short-block warranty.',
    symptom:
        'Metallic knocking/ticking that grows with RPM, illuminated oil-pressure '
        'lamp, stalling, and in severe cases seizure or fire.',
    source: FaultSource(
      type: FaultSourceType.recall,
      publisher: 'NHTSA (Theta II recall)',
      reference:
          'Recall 17V224 — 2011–2013 Sportage (2.4L Theta II), rod-bearing wear',
      url: 'https://www.nhtsa.gov/recalls',
    ),
  ),
  CommonFault(
    id: 'hyundai_tucson_theta2_fire',
    make: 'Hyundai',
    model: 'Tucson',
    yearStart: 2011,
    yearEnd: 2015,
    engine: '2.4L Theta II GDI',
    engineKeywords: ['2.4', 'theta', 'gdi'],
    severity: FaultSeverity.high,
    title: 'Theta II engine failure / fire risk',
    description:
        'Tucson 2.4L Theta II engines are part of the same connecting-rod '
        'bearing failure family and were included in NHTSA\'s engine-fire '
        'investigation EA21-003 covering Hyundai/Kia Theta II vehicles. Failure '
        'can progress to knocking, stall, seizure and under-hood fire.',
    symptom:
        'Engine knocking, oil-pressure warning, stalling, burning smell or '
        'smoke from the engine bay.',
    source: FaultSource(
      type: FaultSourceType.investigation,
      publisher: 'NHTSA (ODI investigation, via CarComplaints)',
      reference: 'Engine-fire investigation EA21-003 (Theta II, incl. Tucson)',
      url:
          'https://m.carcomplaints.com/Hyundai/Tucson/2012/investigations/engine-fires-ea21003.shtml',
    ),
  ),
  CommonFault(
    id: 'hyundai_elantra_nu_pistonring',
    make: 'Hyundai',
    model: 'Elantra',
    yearStart: 2019,
    yearEnd: 2020,
    engine: '2.0L Nu MPI',
    engineKeywords: ['2.0', 'nu'],
    severity: FaultSeverity.high,
    title: 'Nu 2.0L piston oil-ring defect (engine stall)',
    description:
        'Improperly heat-treated piston oil rings in the 2.0L Nu MPI engine can '
        'cause engine damage and stalling. NHTSA recall 21V301000 (Hyundai '
        'campaign 203) covers 2019–2020 Elantra and related Kona/Veloster '
        'models — roughly 158,000 units.',
    symptom:
        'Abnormal engine noise, rising oil consumption, warning lights, and '
        'engine stalling.',
    source: FaultSource(
      type: FaultSourceType.recall,
      publisher: 'NHTSA / Hyundai',
      reference: 'Recall 21V301000 (Hyundai campaign 203) — Nu 2.0L oil rings',
      url: 'https://www.nhtsa.gov/recalls',
    ),
  ),

  // ─────────────────────────── GAPS ─────────────────────────────
  // Intentionally NOT catalogued (could not source a specific, trustworthy
  // common fault at research time — coverage honesty over padding):
  //   * Toyota Land Cruiser (200), Corolla (current gens)
  //   * Mercedes GLE-specific balance-shaft (that era is petrol M272/M273 ML)
  //   * Chinese brands — BYD, Chery, Changan: only generic aggregator/J.D.
  //     Power-category data (infotainment lag, DCT shudder, trim rattles) with
  //     no vehicle-specific, defect-grade citation. Omitted until sourceable.
];

/// All catalogued faults for a vehicle identity, most-severe first.
List<CommonFault> commonFaultsFor({
  required String make,
  required String model,
  required int year,
  String? engine,
}) {
  final matched = kCommonFaults
      .where((f) =>
          f.matches(make: make, model: model, year: year, engine: engine))
      .toList();
  matched.sort((a, b) => b.severity.index.compareTo(a.severity.index));
  return matched;
}
