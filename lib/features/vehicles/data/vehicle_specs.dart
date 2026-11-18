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

    // ===================================================================
    // ROUND 3 — completeness sweep. Extra generations for existing models
    // (older 2005–2015 and newest 2023–2026) plus many more mainstream
    // models, so the make/model pickers rarely miss and the engine picker
    // has the right options. Same rules: factory-accurate engines, correct
    // fuel (EV/PHEV drive the schedule), omit genuinely uncertain configs.
    // Overlapping ranges are fine — enginesFrom() de-duplicates by engine.
    // ===================================================================

    // -------- Toyota (more generations + models) ----------------------------
    ModelSpec('Toyota', 'Corolla', 2008, 2013, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.8L', '1.8L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Corolla', 2020, 2026, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'CVT'),
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Toyota', 'Corolla Cross', 2022, 2026, [
      TrimSpec('1.8L', '1.8L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Toyota', 'Land Cruiser', 2022, 2026, [
      TrimSpec('3.5L V6 Twin-Turbo', '3.5L V6 Twin-Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Land Cruiser 70', 2008, 2026, [
      TrimSpec('4.0L V6', '4.0L V6', 'Petrol', 'Manual'),
    ]),
    ModelSpec('Toyota', 'Prado', 2024, 2026, [
      TrimSpec('2.4L Turbo', '2.4L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'RAV4', 2013, 2018, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Camry', 2012, 2017, [
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', '4Runner', 2010, 2024, [
      TrimSpec('4.0L V6', '4.0L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'FJ Cruiser', 2007, 2014, [
      TrimSpec('4.0L V6', '4.0L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Sequoia', 2008, 2022, [
      TrimSpec('5.7L V8', '5.7L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Toyota', 'Prius', 2016, 2022, [
      TrimSpec('1.8L Hybrid', '1.8L I4 Hybrid', 'Hybrid', 'CVT'),
    ]),
    ModelSpec('Toyota', 'Previa', 2006, 2019, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
    ]),

    // -------- Lexus (fill the lineup) ---------------------------------------
    ModelSpec('Lexus', 'RX', 2010, 2015, [
      TrimSpec('RX 350', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Lexus', 'GX', 2010, 2023, [
      TrimSpec('GX 460', '4.6L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Lexus', 'NX', 2015, 2021, [
      TrimSpec('NX 200t / 300', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Lexus', 'IS', 2014, 2023, [
      TrimSpec('IS 300', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('IS 350', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Lexus', 'LS', 2007, 2017, [
      TrimSpec('LS 460', '4.6L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Lexus', 'LS', 2018, 2024, [
      TrimSpec('LS 500', '3.5L V6 Twin-Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Lexus', 'LX', 2008, 2015, [
      TrimSpec('LX 570', '5.7L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Lexus', 'ES', 2013, 2018, [
      TrimSpec('ES 350', '3.5L V6', 'Petrol', 'Automatic'),
    ]),

    // -------- Nissan --------------------------------------------------------
    ModelSpec('Nissan', 'Altima', 2019, 2024, [
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Nissan', 'Sentra', 2013, 2019, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'CVT'),
      TrimSpec('1.8L', '1.8L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Nissan', 'Sentra', 2020, 2024, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Nissan', 'Qashqai', 2014, 2021, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Nissan', 'Murano', 2015, 2024, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Nissan', 'Pathfinder', 2013, 2020, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Nissan', 'Armada', 2017, 2024, [
      TrimSpec('5.6L V8', '5.6L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Nissan', 'Patrol', 2004, 2010, [
      TrimSpec('4.8L', '4.8L I6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Nissan', 'Tiida', 2007, 2013, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.8L', '1.8L I4', 'Petrol', 'Automatic'),
    ]),

    // -------- Honda ---------------------------------------------------------
    ModelSpec('Honda', 'Accord', 2013, 2017, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'CVT'),
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Honda', 'CR-V', 2012, 2016, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Honda', 'Civic', 2012, 2015, [
      TrimSpec('1.8L', '1.8L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Honda', 'Civic', 2022, 2026, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'CVT'),
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Honda', 'City', 2014, 2024, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Honda', 'Pilot', 2009, 2015, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),

    // -------- Hyundai -------------------------------------------------------
    ModelSpec('Hyundai', 'Tucson', 2010, 2015, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Tucson', 2022, 2026, [
      TrimSpec('1.6L Turbo', '1.6L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Elantra', 2011, 2016, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.8L', '1.8L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Elantra', 2021, 2026, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Sonata', 2011, 2014, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Sonata', 2020, 2024, [
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Accent', 2011, 2017, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hyundai', 'Azera', 2012, 2017, [
      TrimSpec('3.0L V6', '3.0L V6', 'Petrol', 'Automatic'),
      TrimSpec('3.3L V6', '3.3L V6', 'Petrol', 'Automatic'),
    ]),

    // -------- Kia -----------------------------------------------------------
    ModelSpec('Kia', 'Sportage', 2011, 2016, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'Sportage', 2022, 2026, [
      TrimSpec('1.6L Turbo', '1.6L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'Optima', 2011, 2020, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'K5', 2021, 2024, [
      TrimSpec('1.6L Turbo', '1.6L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'Cerato', 2013, 2018, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'Carnival', 2015, 2024, [
      TrimSpec('3.3L V6', '3.3L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kia', 'Soul', 2014, 2019, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
    ]),

    // -------- Mitsubishi ----------------------------------------------------
    ModelSpec('Mitsubishi', 'Pajero Sport', 2016, 2023, [
      TrimSpec('3.0L V6', '3.0L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mitsubishi', 'Eclipse Cross', 2018, 2024, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Mitsubishi', 'Xpander', 2018, 2024, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mitsubishi', 'Mirage', 2014, 2024, [
      TrimSpec('1.2L', '1.2L I3', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Mitsubishi', 'Attrage', 2014, 2024, [
      TrimSpec('1.2L', '1.2L I3', 'Petrol', 'CVT'),
    ]),

    // -------- Mercedes-Benz -------------------------------------------------
    ModelSpec('Mercedes-Benz', 'C-Class', 2008, 2014, [
      TrimSpec('C 200', '1.8L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('C 300', '3.0L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'E-Class', 2010, 2016, [
      TrimSpec('E 250', '1.8L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('E 350', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'GLE', 2020, 2024, [
      TrimSpec('GLE 350', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('GLE 450', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'GLC', 2023, 2026, [
      TrimSpec('GLC 300', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'S-Class', 2014, 2017, [
      TrimSpec('S 400', '3.0L V6 BiTurbo', 'Petrol', 'Automatic'),
      TrimSpec('S 500', '4.7L V8 BiTurbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'CLA', 2014, 2019, [
      TrimSpec('CLA 200', '1.6L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('CLA 250', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'GLK', 2010, 2015, [
      TrimSpec('GLK 350', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mercedes-Benz', 'GLS', 2020, 2024, [
      TrimSpec('GLS 450', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('GLS 580', '4.0L V8 BiTurbo', 'Petrol', 'Automatic'),
    ]),

    // -------- BMW -----------------------------------------------------------
    ModelSpec('BMW', '3 Series', 2006, 2011, [
      TrimSpec('325i', '2.5L I6', 'Petrol', 'Automatic'),
      TrimSpec('330i', '3.0L I6', 'Petrol', 'Automatic'),
      TrimSpec('335i', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BMW', '3 Series', 2019, 2026, [
      TrimSpec('330i', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('M340i', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BMW', '5 Series', 2011, 2016, [
      TrimSpec('528i', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('535i', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('550i', '4.4L V8 BiTurbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BMW', 'X5', 2007, 2013, [
      TrimSpec('xDrive30i', '3.0L I6', 'Petrol', 'Automatic'),
      TrimSpec('xDrive48i', '4.8L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BMW', 'X3', 2011, 2017, [
      TrimSpec('xDrive28i', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('xDrive35i', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BMW', 'X6', 2008, 2014, [
      TrimSpec('xDrive35i', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('xDrive50i', '4.4L V8 BiTurbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BMW', 'X7', 2019, 2024, [
      TrimSpec('xDrive40i', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('M50i', '4.4L V8 BiTurbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Audi ----------------------------------------------------------
    ModelSpec('Audi', 'A4', 2009, 2015, [
      TrimSpec('2.0 TFSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Audi', 'Q5', 2009, 2016, [
      TrimSpec('2.0 TFSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.0 TFSI', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Audi', 'A6', 2012, 2018, [
      TrimSpec('2.0 TFSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.0 TFSI', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Audi', 'Q7', 2007, 2015, [
      TrimSpec('3.0 TFSI', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('4.2 FSI', '4.2L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Audi', 'Q7', 2016, 2024, [
      TrimSpec('45 TFSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('55 TFSI', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Audi', 'A3', 2015, 2020, [
      TrimSpec('1.4 TFSI', '1.4L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0 TFSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Volkswagen ----------------------------------------------------
    ModelSpec('Volkswagen', 'Jetta', 2011, 2018, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.4 TSI', '1.4L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Volkswagen', 'Jetta', 2019, 2024, [
      TrimSpec('1.4 TSI', '1.4L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Volkswagen', 'Passat', 2006, 2010, [
      TrimSpec('2.0 TSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Volkswagen', 'Tiguan', 2009, 2016, [
      TrimSpec('2.0 TSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Volkswagen', 'Touareg', 2011, 2018, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Volkswagen', 'Teramont', 2018, 2024, [
      TrimSpec('2.0 TSI', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),

    // -------- Chevrolet / GMC -----------------------------------------------
    ModelSpec('Chevrolet', 'Cruze', 2011, 2016, [
      TrimSpec('1.8L', '1.8L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.4L Turbo', '1.4L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chevrolet', 'Traverse', 2009, 2024, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chevrolet', 'Camaro', 2016, 2023, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
      TrimSpec('SS 6.2L V8', '6.2L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chevrolet', 'Impala', 2014, 2020, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chevrolet', 'Equinox', 2018, 2024, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chevrolet', 'Trailblazer', 2021, 2024, [
      TrimSpec('1.3L Turbo', '1.3L I3 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chevrolet', 'Tahoe', 2021, 2024, [
      TrimSpec('5.3L V8', '5.3L V8', 'Petrol', 'Automatic'),
      TrimSpec('6.2L V8', '6.2L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('GMC', 'Yukon', 2021, 2024, [
      TrimSpec('5.3L V8', '5.3L V8', 'Petrol', 'Automatic'),
      TrimSpec('6.2L V8 Denali', '6.2L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('GMC', 'Sierra', 2014, 2018, [
      TrimSpec('4.3L V6', '4.3L V6', 'Petrol', 'Automatic'),
      TrimSpec('5.3L V8', '5.3L V8', 'Petrol', 'Automatic'),
      TrimSpec('6.2L V8', '6.2L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('GMC', 'Acadia', 2017, 2024, [
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('GMC', 'Terrain', 2018, 2024, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Ford ----------------------------------------------------------
    ModelSpec('Ford', 'Expedition', 2018, 2024, [
      TrimSpec('3.5L EcoBoost', '3.5L V6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Ford', 'Taurus', 2010, 2019, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Ford', 'Mustang', 2015, 2023, [
      TrimSpec('2.3L EcoBoost', '2.3L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('GT 5.0L V8', '5.0L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Ford', 'Explorer', 2020, 2024, [
      TrimSpec('2.3L EcoBoost', '2.3L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.0L EcoBoost', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Ford', 'Bronco', 2021, 2024, [
      TrimSpec('2.3L EcoBoost', '2.3L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('2.7L EcoBoost', '2.7L V6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Ford', 'Fusion', 2013, 2020, [
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.0L EcoBoost', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Jeep / Dodge / Chrysler / Cadillac (American V6/V8) -----------
    ModelSpec('Jeep', 'Grand Cherokee', 2011, 2021, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
      TrimSpec('5.7L V8', '5.7L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jeep', 'Grand Cherokee', 2022, 2026, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jeep', 'Wrangler', 2007, 2017, [
      TrimSpec('3.8L V6', '3.8L V6', 'Petrol', 'Automatic'),
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jeep', 'Wrangler', 2018, 2024, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jeep', 'Compass', 2017, 2024, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jeep', 'Cherokee', 2014, 2023, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
      TrimSpec('3.2L V6', '3.2L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Dodge', 'Charger', 2011, 2023, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
      TrimSpec('5.7L V8', '5.7L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Dodge', 'Challenger', 2015, 2023, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
      TrimSpec('5.7L V8', '5.7L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Dodge', 'Durango', 2011, 2024, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
      TrimSpec('5.7L V8', '5.7L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chrysler', '300', 2011, 2023, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
      TrimSpec('5.7L V8', '5.7L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Cadillac', 'Escalade', 2015, 2024, [
      TrimSpec('6.2L V8', '6.2L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Cadillac', 'CTS', 2014, 2019, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Cadillac', 'XT5', 2017, 2024, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Cadillac', 'SRX', 2010, 2016, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),

    // -------- Mazda ---------------------------------------------------------
    ModelSpec('Mazda', 'Mazda3', 2014, 2018, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mazda', 'Mazda3', 2019, 2024, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mazda', 'Mazda6', 2013, 2021, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mazda', 'CX-5', 2013, 2024, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mazda', 'CX-9', 2016, 2023, [
      TrimSpec('2.5L Turbo', '2.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mazda', 'CX-3', 2016, 2024, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Mazda', 'CX-30', 2020, 2024, [
      TrimSpec('2.0L', '2.0L I4', 'Petrol', 'Automatic'),
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'Automatic'),
    ]),

    // -------- Suzuki --------------------------------------------------------
    ModelSpec('Suzuki', 'Swift', 2011, 2024, [
      TrimSpec('1.2L', '1.2L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Suzuki', 'Vitara', 2015, 2024, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
      TrimSpec('1.4L Turbo', '1.4L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Suzuki', 'Ciaz', 2015, 2024, [
      TrimSpec('1.4L', '1.4L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Suzuki', 'Jimny', 2019, 2024, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Suzuki', 'Baleno', 2016, 2024, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Automatic'),
    ]),

    // -------- Subaru --------------------------------------------------------
    ModelSpec('Subaru', 'Forester', 2014, 2024, [
      TrimSpec('2.0L', '2.0L H4', 'Petrol', 'CVT'),
      TrimSpec('2.5L', '2.5L H4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Subaru', 'Outback', 2015, 2024, [
      TrimSpec('2.5L', '2.5L H4', 'Petrol', 'CVT'),
      TrimSpec('3.6L', '3.6L H6', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Subaru', 'XV', 2012, 2024, [
      TrimSpec('2.0L', '2.0L H4', 'Petrol', 'CVT'),
    ]),

    // -------- Infiniti ------------------------------------------------------
    ModelSpec('Infiniti', 'Q50', 2014, 2024, [
      TrimSpec('2.0t', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.0t', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Infiniti', 'QX80', 2014, 2024, [
      TrimSpec('5.6L V8', '5.6L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Infiniti', 'QX60', 2014, 2024, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'CVT'),
    ]),

    // -------- Land Rover / Jaguar / Volvo / Porsche -------------------------
    ModelSpec('Land Rover', 'Range Rover', 2013, 2021, [
      TrimSpec('3.0L V6 SC', '3.0L V6 Supercharged', 'Petrol', 'Automatic'),
      TrimSpec('5.0L V8 SC', '5.0L V8 Supercharged', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Land Rover', 'Range Rover Sport', 2014, 2022, [
      TrimSpec('3.0L V6 SC', '3.0L V6 Supercharged', 'Petrol', 'Automatic'),
      TrimSpec('5.0L V8 SC', '5.0L V8 Supercharged', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Land Rover', 'Evoque', 2012, 2019, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Land Rover', 'Defender', 2020, 2024, [
      TrimSpec('P300 2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('P400 3.0L I6', '3.0L I6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jaguar', 'F-Pace', 2017, 2024, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.0L V6 SC', '3.0L V6 Supercharged', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jaguar', 'XF', 2016, 2024, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Volvo', 'XC60', 2018, 2024, [
      TrimSpec('T5/T6 2.0L', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Volvo', 'XC90', 2016, 2024, [
      TrimSpec('T5/T6 2.0L', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Volvo', 'S60', 2019, 2024, [
      TrimSpec('T5 2.0L', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Porsche', 'Cayenne', 2011, 2018, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
      TrimSpec('4.8L V8', '4.8L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Porsche', 'Cayenne', 2019, 2024, [
      TrimSpec('3.0L V6 Turbo', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('4.0L V8 Turbo', '4.0L V8 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Porsche', 'Macan', 2015, 2024, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
      TrimSpec('3.0L V6 Turbo', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Peugeot / Renault (French, common used imports) ---------------
    ModelSpec('Peugeot', '3008', 2017, 2024, [
      TrimSpec('1.6L Turbo', '1.6L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Peugeot', '208', 2012, 2024, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Peugeot', '308', 2014, 2021, [
      TrimSpec('1.6L Turbo', '1.6L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Renault', 'Megane', 2016, 2023, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Renault', 'Duster', 2018, 2024, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Renault', 'Captur', 2014, 2024, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'CVT'),
    ]),
    ModelSpec('Renault', 'Koleos', 2017, 2024, [
      TrimSpec('2.5L', '2.5L I4', 'Petrol', 'CVT'),
    ]),

    // ===================================================================
    // More Chinese brands — fuel type is critical (EV/PHEV change schedule).
    // ===================================================================
    // GAC — Aion sub-brand is fully electric; GS/GN run petrol turbo.
    ModelSpec('GAC', 'Aion S', 2020, 2026, [
      TrimSpec('Aion S', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('GAC', 'Aion V', 2021, 2026, [
      TrimSpec('Aion V', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('GAC', 'Aion Y', 2021, 2026, [
      TrimSpec('Aion Y', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('GAC', 'GS3', 2019, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('GAC', 'GS4', 2019, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('GAC', 'GS8', 2019, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    // Zeekr — all BEV.
    ModelSpec('Zeekr', '001', 2021, 2026, [
      TrimSpec('001', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Zeekr', '007', 2024, 2026, [
      TrimSpec('007', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Zeekr', 'X', 2023, 2026, [
      TrimSpec('X', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Zeekr', '7X', 2024, 2026, [
      TrimSpec('7X', 'Electric', 'Electric', 'Automatic'),
    ]),
    // MG — MG4 is BEV.
    ModelSpec('MG', 'MG4', 2022, 2026, [
      TrimSpec('MG4 EV', 'Electric', 'Electric', 'Automatic'),
    ]),
    // BYD — more of the lineup.
    ModelSpec('BYD', 'Seagull', 2023, 2026, [
      TrimSpec('Seagull', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('BYD', 'Song Pro', 2021, 2026, [
      TrimSpec('Song Pro EV', 'Electric', 'Electric', 'Automatic'),
      TrimSpec('Song Pro DM-i (PHEV)', 'Plug-in Hybrid', 'Plug-in Hybrid', 'Automatic'),
    ]),
    ModelSpec('BYD', 'Sealion 6', 2023, 2026, [
      TrimSpec('Sealion 6 DM-i (PHEV)', 'Plug-in Hybrid', 'Plug-in Hybrid', 'Automatic'),
    ]),
    ModelSpec('BYD', 'Sealion 7', 2024, 2026, [
      TrimSpec('Sealion 7', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('BYD', 'e6', 2019, 2026, [
      TrimSpec('e6', 'Electric', 'Electric', 'Automatic'),
    ]),
    // Geely / Great Wall / Hongqi EVs + petrol.
    ModelSpec('Geely', 'Geometry C', 2021, 2026, [
      TrimSpec('Geometry C', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Geely', 'Boyue', 2019, 2026, [
      TrimSpec('1.8L Turbo', '1.8L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Geely', 'Preface', 2021, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Great Wall', 'Ora Good Cat', 2021, 2026, [
      TrimSpec('Good Cat', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Great Wall', 'Tank 300', 2021, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Great Wall', 'Tank 500', 2022, 2026, [
      TrimSpec('3.0L V6 Turbo', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hongqi', 'E-HS9', 2021, 2026, [
      TrimSpec('E-HS9', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Hongqi', 'HS5', 2020, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    // Changan / Chery / Jetour / JAC / Exeed / Jaecoo / Omoda / Bestune / Skywell
    ModelSpec('Changan', 'UNI-V', 2022, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Changan', 'CS95', 2019, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Changan', 'CS35', 2018, 2026, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chery', 'Tiggo 3', 2017, 2024, [
      TrimSpec('1.6L', '1.6L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Chery', 'Tiggo 9', 2023, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jetour', 'X90', 2019, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('JAC', 'JS6', 2021, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Exeed', 'TXL', 2020, 2026, [
      TrimSpec('1.6L Turbo', '1.6L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Exeed', 'VX', 2021, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jaecoo', 'J7', 2023, 2026, [
      TrimSpec('1.6L Turbo', '1.6L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Jaecoo', 'J8', 2024, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Omoda', 'E5', 2023, 2026, [
      TrimSpec('E5 EV', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Bestune', 'T77', 2019, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Bestune', 'T99', 2020, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Skywell', 'ET5', 2021, 2026, [
      TrimSpec('ET5 EV', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Lynk & Co', '06', 2021, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I3 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Kaiyi', 'X7', 2023, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),

    // ===================================================================
    // ROUND 4 — specs for the newly added makes where the powertrain is
    // well established. Makes/models not listed here still appear in the
    // pickers and fall back to free-text engine entry. Fuel is set
    // correctly (BEV = Electric) so the schedule branches right.
    // ===================================================================

    // -------- Acura / Buick / Hummer (American & Japanese premium, petrol) ---
    ModelSpec('Acura', 'MDX', 2014, 2024, [
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Acura', 'RDX', 2019, 2024, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Acura', 'TLX', 2015, 2024, [
      TrimSpec('2.4L', '2.4L I4', 'Petrol', 'Automatic'),
      TrimSpec('3.5L V6', '3.5L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Buick', 'Encore', 2013, 2022, [
      TrimSpec('1.4L Turbo', '1.4L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Buick', 'Envision', 2016, 2024, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Buick', 'Enclave', 2018, 2024, [
      TrimSpec('3.6L V6', '3.6L V6', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Buick', 'Regal', 2014, 2020, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hummer', 'H2', 2008, 2009, [
      TrimSpec('6.2L V8', '6.2L V8', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Hummer', 'H3', 2006, 2010, [
      TrimSpec('3.7L I5', '3.7L I5', 'Petrol', 'Automatic'),
    ]),

    // -------- Maserati (petrol) ---------------------------------------------
    ModelSpec('Maserati', 'Ghibli', 2014, 2024, [
      TrimSpec('3.0L V6 Turbo', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Maserati', 'Levante', 2017, 2024, [
      TrimSpec('3.0L V6 Turbo', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
    ]),

    // -------- BEV / premium EV makes (fuel = Electric) ----------------------
    ModelSpec('Polestar', '2', 2020, 2026, [
      TrimSpec('Polestar 2', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Polestar', '3', 2024, 2026, [
      TrimSpec('Polestar 3', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Polestar', '4', 2024, 2026, [
      TrimSpec('Polestar 4', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Rivian', 'R1T', 2022, 2026, [
      TrimSpec('R1T', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Rivian', 'R1S', 2022, 2026, [
      TrimSpec('R1S', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Lucid', 'Air', 2022, 2026, [
      TrimSpec('Air', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Nio', 'ET5', 2022, 2026, [
      TrimSpec('ET5', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Nio', 'ET7', 2022, 2026, [
      TrimSpec('ET7', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Nio', 'ES6', 2019, 2026, [
      TrimSpec('ES6', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Nio', 'ES8', 2018, 2026, [
      TrimSpec('ES8', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('XPeng', 'P7', 2020, 2026, [
      TrimSpec('P7', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('XPeng', 'G6', 2023, 2026, [
      TrimSpec('G6', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('XPeng', 'G9', 2022, 2026, [
      TrimSpec('G9', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Aion', 'S', 2020, 2026, [
      TrimSpec('Aion S', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Aion', 'V', 2021, 2026, [
      TrimSpec('Aion V', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Aion', 'Y', 2021, 2026, [
      TrimSpec('Aion Y', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Ora', 'Good Cat', 2021, 2026, [
      TrimSpec('Good Cat', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Leapmotor', 'T03', 2021, 2026, [
      TrimSpec('T03', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Wuling', 'Air EV', 2022, 2026, [
      TrimSpec('Air EV', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Smart', '#1', 2023, 2026, [
      TrimSpec('#1', 'Electric', 'Electric', 'Automatic'),
    ]),
    ModelSpec('Smart', '#3', 2023, 2026, [
      TrimSpec('#3', 'Electric', 'Electric', 'Automatic'),
    ]),

    // -------- Tank / BAIC / Forthing (petrol turbo) -------------------------
    ModelSpec('Tank', '300', 2021, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Tank', '500', 2022, 2026, [
      TrimSpec('3.0L V6 Turbo', '3.0L V6 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BAIC', 'X55', 2021, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('BAIC', 'BJ40', 2020, 2026, [
      TrimSpec('2.0L Turbo', '2.0L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Forthing', 'T5', 2019, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I4 Turbo', 'Petrol', 'Automatic'),
    ]),

    // -------- Proton / UAZ / Iran Khodro / Daewoo (older & regional) --------
    ModelSpec('Proton', 'X70', 2018, 2026, [
      TrimSpec('1.8L Turbo', '1.8L I4 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Proton', 'X50', 2020, 2026, [
      TrimSpec('1.5L Turbo', '1.5L I3 Turbo', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('Proton', 'Saga', 2016, 2026, [
      TrimSpec('1.3L', '1.3L I4', 'Petrol', 'Automatic'),
    ]),
    ModelSpec('UAZ', 'Patriot', 2010, 2026, [
      TrimSpec('2.7L', '2.7L I4', 'Petrol', 'Manual'),
    ]),
    ModelSpec('Iran Khodro', 'Samand', 2005, 2020, [
      TrimSpec('1.7L', '1.7L I4', 'Petrol', 'Manual'),
    ]),
    ModelSpec('Daewoo', 'Lanos', 2000, 2010, [
      TrimSpec('1.5L', '1.5L I4', 'Petrol', 'Manual'),
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
