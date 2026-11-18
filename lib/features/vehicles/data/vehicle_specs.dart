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
      TrimSpec('4.0L V6 Petrol', '4.0L V6', 'Petrol', 'Automatic'),
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

    // ===================================================================
    // HOW TO EXPAND THIS CATALOG
    // -------------------------------------------------------------------
    // Add a `ModelSpec(make, model, yearStart, yearEnd, [TrimSpec(...)])` for
    // each well-known car. The Engine field in the add-vehicle form becomes a
    // picker of the DISTINCT engine strings across a model/year's trims (see
    // `enginesFrom`), auto-selecting when there is only one.
    //   • `make`/`model` MUST match VehicleCatalog exactly, or the entry won't
    //     be found (e.g. BYD's model is 'Yuan Plus / Atto 3', not 'Atto 3').
    //   • `fuel` MUST be one of VehicleCatalog.fuelTypes (Petrol / Hybrid /
    //     Plug-in Hybrid / Electric / LPG) and `transmission` one of
    //     VehicleCatalog.transmissions — off-list values are silently ignored.
    //   • fuel drives the maintenance schedule (Electric skips oil / plugs /
    //     ATF / coolant), so set it correctly, especially for EV/PHEV.
    // Only add FACTORY-ACCURATE data you are confident of — omit anything
    // uncertain rather than guessing. Transmission on the newer turbo models is
    // recorded as the umbrella 'Automatic' (many are DCT) since the schedule
    // does not branch on gearbox type.
    // ===================================================================

    // -------- Chevrolet (American full-size SUV, very common in Lebanon) -----
    // Tahoe GMT900/K2XX only ever shipped the 5.3L V8 — the 6.2L V8 was a
    // Yukon Denali / Escalade engine, NOT a Tahoe option, so it's omitted.
    ModelSpec('Chevrolet', 'Tahoe', 2007, 2014, [
      TrimSpec('LS', '5.3L V8', 'Petrol', 'Automatic'),
      TrimSpec('LT', '5.3L V8', 'Petrol', 'Automatic'),
      TrimSpec('LTZ', '5.3L V8', 'Petrol', 'Automatic'),
    ]),

    // -------- Mercedes-Benz GLE (W166) --------------------------------------
    ModelSpec('Mercedes-Benz', 'GLE', 2016, 2019, [
      TrimSpec('GLE 350', '3.5L V6', 'Petrol', 'Automatic'),
      TrimSpec('GLE 400', '3.0L V6 BiTurbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Toyota (dominant in Lebanon) ----------------------------------
    // Fortuner petrol only; the 2.8L turbo-diesel is omitted (diesel passenger
    // cars can't be registered in Lebanon, and there is no Diesel fuel option).
    ModelSpec('Toyota', 'Fortuner', 2016, 2023, [
      TrimSpec('2.7L', '2.7L I4', 'Petrol', 'Automatic'),
      TrimSpec('4.0L V6', '4.0L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Camry', 2018, 2024, [
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Prado', 2010, 2023, [
      TrimSpec('2.7L', '2.7L I4', 'Petrol', 'Automatic'),
      TrimSpec('4.0L V6', '4.0L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'RAV4', 2019, 2024, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
    ]),

    // -------- Nissan / Honda / Hyundai sedans -------------------------------
    ModelSpec('Nissan', 'Altima', 2013, 2018, [
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'CVT'),
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Honda', 'Accord', 2018, 2022, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'CVT'),
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Elantra', 2017, 2020, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
    ]),

    // ===================================================================
    // Chinese brands — surging in the Lebanon market. Fuel type is critical
    // here: many are EV/PHEV, which changes the maintenance schedule.
    // ===================================================================

    // -------- BYD (mostly BEV, some PHEV) -----------------------------------
    // Model names mirror VehicleCatalog exactly ('Yuan Plus / Atto 3').
    ModelSpec('BYD', 'Yuan Plus / Atto 3', 2022, 2026, [
      TrimSpec('Atto 3', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('BYD', 'Dolphin', 2022, 2026, [
      TrimSpec('Dolphin', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('BYD', 'Seal', 2022, 2026, [
      TrimSpec('Seal', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('BYD', 'Han', 2021, 2026, [
      TrimSpec('Han EV', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('BYD', 'Tang', 2021, 2026, [
      TrimSpec('Tang EV', 'Electric', 'Electric', 'Automatic'),
      TrimSpec('Tang DM (PHEV)', 'Plug-in Hybrid', 'Plug-in Hybrid', 'Automatic'),
    ]),
    ModelSpec('BYD', 'Song Plus', 2021, 2026, [
      TrimSpec('Song Plus EV', 'Electric', 'Electric', 'Automatic'),
      TrimSpec(
          'Song Plus DM-i (PHEV)', 'Plug-in Hybrid', 'Plug-in Hybrid', 'Automatic'),
    ]),

    // -------- Chery (petrol turbo) ------------------------------------------
    ModelSpec('Chery', 'Tiggo 4 Pro', 2022, 2026, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chery', 'Tiggo 7 Pro', 2021, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chery', 'Tiggo 8 Pro', 2021, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chery', 'Arrizo 5', 2020, 2026, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),

    // -------- Changan (petrol turbo) ----------------------------------------
    ModelSpec('Changan', 'CS35 Plus', 2021, 2026, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.4L Turbo', '1.4L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Changan', 'CS55 Plus', 2021, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Changan', 'CS75 Plus', 2020, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Changan', 'UNI-T', 2021, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Changan', 'UNI-K', 2021, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Changan', 'Eado', 2019, 2026, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
    ]),

    // -------- Lynk & Co (petrol turbo + PHEV) -------------------------------
    ModelSpec('Lynk & Co', '01', 2020, 2026, [
      TrimSpec('2.0T', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('1.5T PHEV', '1.5L I4 Turbo PHEV', 'Plug-in Hybrid', 'Automatic'),
    ]),
    ModelSpec('Lynk & Co', '03', 2020, 2026, [
      TrimSpec('1.5T', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0T', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Lynk & Co', '05', 2020, 2026, [
      TrimSpec('2.0T', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Lynk & Co', '09', 2021, 2026, [
      TrimSpec('2.0T', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Avatr (BEV) ---------------------------------------------------
    ModelSpec('Avatr', '11', 2023, 2026, [
      TrimSpec('Avatr 11', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Avatr', '12', 2023, 2026, [
      TrimSpec('Avatr 12', 'Electric', 'Electric', 'Automatic'),
    ]),

    // -------- Kaiyi (petrol) ------------------------------------------------
    ModelSpec('Kaiyi', 'X3', 2022, 2026, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kaiyi', 'E5', 2022, 2026, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),

    // ===================================================================
    // ROUND 2 — broader Lebanon-market coverage. Same rules as above:
    // factory-accurate engines only, correct fuel, omit anything uncertain.
    // ===================================================================

    // -------- Toyota --------------------------------------------------------
    ModelSpec('Toyota', 'Yaris', 2014, 2024, [
      TrimSpec('1.3L', '1.3L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Rush', 2018, 2024, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'C-HR', 2018, 2023, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Toyota', 'Highlander', 2014, 2024, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Avalon', 2013, 2024, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    // Hiace: H200 petrol = 2.7L I4; H300 (2019+) petrol = 3.5L V6. Diesels are
    // omitted (banned from registration in Lebanon).
    ModelSpec('Toyota', 'Hiace', 2005, 2019, [
      TrimSpec('2.7L', '2.7L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Hiace', 2019, 2024, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),

    // -------- Nissan (CVT across most of the range) -------------------------
    ModelSpec('Nissan', 'X-Trail', 2014, 2021, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Nissan', 'Kicks', 2017, 2024, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Nissan', 'Juke', 2011, 2019, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Nissan', 'Navara', 2015, 2023, [
      TrimSpec('2.5L Petrol', '2.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Nissan', 'Maxima', 2016, 2023, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'CVT'),
    ]),

    // -------- Honda ---------------------------------------------------------
    ModelSpec('Honda', 'Civic', 2016, 2021, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Honda', 'CR-V', 2017, 2022, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'CVT'),
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Honda', 'HR-V', 2016, 2021, [
      TrimSpec('1.8L', '1.8L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Honda', 'Pilot', 2016, 2022, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),

    // -------- Hyundai -------------------------------------------------------
    ModelSpec('Hyundai', 'Sonata', 2015, 2019, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Santa Fe', 2016, 2023, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
      TrimSpec('3.3L V6', '3.3L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Creta', 2016, 2023, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Kona', 2018, 2023, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('Electric', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Palisade', 2020, 2024, [
      TrimSpec('3.8L V6', '3.8L V6', 'Petrol', 'Automatic'),
    ]),

    // -------- Kia -----------------------------------------------------------
    ModelSpec('Kia', 'Sorento', 2016, 2020, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
      TrimSpec('3.3L V6', '3.3L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'Cerato', 2019, 2024, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'Picanto', 2017, 2024, [
      TrimSpec('1.2L', '1.2L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'Seltos', 2020, 2024, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
    ]),

    // -------- Mitsubishi ----------------------------------------------------
    ModelSpec('Mitsubishi', 'Pajero', 2008, 2021, [
      TrimSpec('3.0L V6', '3.0L V6', 'Petrol', 'Automatic'),
      TrimSpec('3.8L V6', '3.8L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mitsubishi', 'Outlander', 2016, 2021, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'CVT'),
      TrimSpec('3.0L V6', '3.0L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mitsubishi', 'Lancer', 2008, 2017, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'CVT'),
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Mitsubishi', 'ASX', 2011, 2022, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
    ]),

    // -------- Mercedes-Benz -------------------------------------------------
    ModelSpec('Mercedes-Benz', 'GLC', 2016, 2022, [
      TrimSpec('GLC 200', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('GLC 300', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'GLA', 2015, 2022, [
      TrimSpec('GLA 250', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'A-Class', 2019, 2023, [
      TrimSpec('A 200', '1.3L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('A 250', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'S-Class', 2018, 2020, [
      TrimSpec('S 450', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'G-Class', 2019, 2023, [
      TrimSpec('G 500', '4.0L V8 BiTurbo', 'Petrol', 'Automatic'),
      TrimSpec('G 63 AMG', '4.0L V8 BiTurbo', 'Petrol', 'Automatic'),
    ]),
    // ML (W166) — superseded by GLE in 2015.
    ModelSpec('Mercedes-Benz', 'ML', 2012, 2015, [
      TrimSpec('ML 350', '3.5L V6', 'Petrol', 'Automatic'),
      TrimSpec('ML 400', '3.0L V6 BiTurbo', 'Petrol', 'Automatic'),
    ]),

    // -------- BMW -----------------------------------------------------------
    ModelSpec('BMW', '7 Series', 2016, 2022, [
      TrimSpec('730i', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('740i', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('750i', '4.4L V8 BiTurbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BMW', 'X1', 2016, 2022, [
      TrimSpec('sDrive/xDrive 20i', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BMW', 'X3', 2018, 2024, [
      TrimSpec('xDrive30i', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('M40i', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BMW', 'X5', 2019, 2023, [
      TrimSpec('xDrive40i', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('xDrive50i', '4.4L V8 BiTurbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Volkswagen / Audi (petrol turbo) ------------------------------
    ModelSpec('Volkswagen', 'Golf', 2013, 2020, [
      TrimSpec('1.4 TSI', '1.4L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('GTI 2.0T', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Volkswagen', 'Tiguan', 2017, 2023, [
      TrimSpec('1.4 TSI', '1.4L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0 TSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Volkswagen', 'Passat', 2015, 2022, [
      TrimSpec('1.8 TSI', '1.8L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0 TSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Audi', 'A4', 2016, 2023, [
      TrimSpec('40/45 TFSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Audi', 'Q5', 2018, 2023, [
      TrimSpec('45 TFSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Chevrolet / GMC (American V8s) --------------------------------
    ModelSpec('Chevrolet', 'Suburban', 2007, 2020, [
      TrimSpec('5.3L V8', '5.3L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chevrolet', 'Silverado', 2014, 2018, [
      TrimSpec('4.3L V6', '4.3L V6', 'Petrol', 'Automatic'),
      TrimSpec('5.3L V8', '5.3L V8', 'Petrol', 'Automatic'),
      TrimSpec('6.2L V8', '6.2L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chevrolet', 'Malibu', 2016, 2023, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    // New-generation Captiva (2019+, 1.5T) — not the older 2.4L/3.0L Captiva.
    ModelSpec('Chevrolet', 'Captiva', 2019, 2023, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Ford (EcoBoost + V6/V8) ---------------------------------------
    ModelSpec('Ford', 'Explorer', 2011, 2019, [
      TrimSpec('2.3L EcoBoost', '2.3L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Ford', 'F-150', 2015, 2020, [
      TrimSpec('2.7L EcoBoost', '2.7L V6 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.5L EcoBoost', '3.5L V6 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('5.0L V8', '5.0L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Ford', 'Escape', 2013, 2019, [
      TrimSpec('1.5L EcoBoost', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0L EcoBoost', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Ford', 'Edge', 2015, 2023, [
      TrimSpec('2.0L EcoBoost', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),

    // -------- More Chinese brands -------------------------------------------
    // BYD Qin / Seal U — EV + DM-i plug-in hybrid variants.
    ModelSpec('BYD', 'Qin', 2021, 2026, [
      TrimSpec('Qin EV', 'Electric', 'Electric', 'Automatic'),
      TrimSpec('Qin DM-i (PHEV)', 'Plug-in Hybrid', 'Plug-in Hybrid', 'Automatic'),
    ]),
    ModelSpec('BYD', 'Seal U', 2023, 2026, [
      TrimSpec('Seal U EV', 'Electric', 'Electric', 'Automatic'),
      TrimSpec(
          'Seal U DM-i (PHEV)', 'Plug-in Hybrid', 'Plug-in Hybrid', 'Automatic'),
    ]),
    ModelSpec('Chery', 'Tiggo 2', 2019, 2024, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Omoda', 'C5', 2022, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Changan', 'Alsvin', 2019, 2026, [
      TrimSpec('1.4L', '1.4L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),
    // GWM Haval (petrol turbo). HEV/PHEV variants exist but are omitted here as
    // not confidently part of the Lebanon-market lineup.
    ModelSpec('Haval', 'H6', 2021, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Haval', 'Jolion', 2021, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    // MG — petrol plus the ZS EV.
    ModelSpec('MG', 'ZS', 2018, 2026, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
      TrimSpec('ZS EV', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('MG', 'HS', 2019, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('MG', 'MG5', 2020, 2026, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Geely', 'Coolray', 2020, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I3 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Geely', 'Emgrand', 2019, 2026, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('JAC', 'JS4', 2021, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jetour', 'X70', 2019, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jetour', 'Dashing', 2022, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
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

  /// Distinct factory engine options for a make/model/year, across all known
  /// trims (order preserved, duplicates removed). When non-empty the add-vehicle
  /// form turns the Engine field into a picker of exactly these options; empty
  /// → the field stays free text for grey-market/unknown cars.
  static List<String> enginesFrom(
      List<ModelSpec> specs, String make, String model, int? year) {
    final seen = <String>{};
    final out = <String>[];
    for (final t in trimsFrom(specs, make, model, year)) {
      if (t.engine.isNotEmpty && seen.add(t.engine)) out.add(t.engine);
    }
    return out;
  }

  // Seed-only convenience (used where the merged provider isn't available).
  static List<TrimSpec> trimsFor(String make, String model, int? year) =>
      trimsFrom(seed, make, model, year);

  static TrimSpec? specFor(String make, String model, int? year, String trim) =>
      specFrom(seed, make, model, year, trim);
}
