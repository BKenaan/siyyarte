/// A curated catalog of makes & models common in the Lebanese market, grouped
/// by origin market. Lebanon imports from every market, and since the economic
/// crisis the affordable Chinese brands (GAC, Geely, Chery, Haval, BYD, MG,
/// Changan, Jetour…) have surged — so this list is deliberately broad. In
/// production it lives in the admin-managed `catalog_makes/models` collections;
/// this offline seed powers the add-vehicle flow before sync and as a fallback.
class VehicleMake {
  final String name;
  final String market; // Japanese / Korean / European / American / Chinese / Other
  final List<String> models;
  const VehicleMake(this.name, this.market, this.models);
}

abstract class VehicleCatalog {
  static const List<VehicleMake> makes = [
    // ============================ Japanese ============================
    VehicleMake('Toyota', 'Japanese', [
      'Yaris', 'Corolla', 'Camry', 'Avalon', 'C-HR', 'RAV4', 'Highlander',
      'Land Cruiser', 'Prado', 'Fortuner', 'Hilux', 'Prius', 'Rush', 'Aygo'
    ]),
    VehicleMake('Honda', 'Japanese',
        ['Brio', 'City', 'Jazz', 'Civic', 'Accord', 'HR-V', 'CR-V', 'Pilot']),
    VehicleMake('Nissan', 'Japanese', [
      'Micra', 'Sunny', 'Sentra', 'Altima', 'Maxima', 'Kicks', 'Juke',
      'Qashqai', 'X-Trail', 'Patrol', 'Navara'
    ]),
    VehicleMake('Mitsubishi', 'Japanese', [
      'Mirage', 'Attrage', 'Lancer', 'Eclipse Cross', 'ASX', 'Outlander',
      'Montero Sport', 'Pajero', 'L200'
    ]),
    VehicleMake('Mazda', 'Japanese',
        ['Mazda2', 'Mazda3', 'Mazda6', 'CX-3', 'CX-30', 'CX-5', 'CX-9', 'BT-50']),
    VehicleMake('Suzuki', 'Japanese',
        ['Celerio', 'Swift', 'Baleno', 'Ciaz', 'Vitara', 'Jimny', 'S-Cross']),
    VehicleMake('Subaru', 'Japanese',
        ['Impreza', 'Legacy', 'XV', 'Forester', 'Outback', 'Ascent']),
    VehicleMake('Lexus', 'Japanese',
        ['IS', 'ES', 'LS', 'UX', 'NX', 'RX', 'GX', 'LX']),
    VehicleMake('Infiniti', 'Japanese', ['Q50', 'Q60', 'QX50', 'QX60', 'QX80']),
    VehicleMake('Isuzu', 'Japanese', ['D-Max', 'MU-X']),
    VehicleMake('Daihatsu', 'Japanese', ['Terios', 'Sirion', 'Gran Max']),

    // ============================= Korean =============================
    VehicleMake('Hyundai', 'Korean', [
      'i10', 'i20', 'i30', 'Accent', 'Elantra', 'Sonata', 'Azera',
      'Venue', 'Kona', 'Creta', 'Tucson', 'Santa Fe', 'Palisade', 'H-1'
    ]),
    VehicleMake('Kia', 'Korean', [
      'Picanto', 'Rio', 'Pegas', 'Cerato', 'K5', 'Stinger', 'Soul',
      'Stonic', 'Seltos', 'Sportage', 'Sorento', 'Carnival'
    ]),
    VehicleMake('Genesis', 'Korean', ['G70', 'G80', 'G90', 'GV70', 'GV80']),
    VehicleMake('SsangYong', 'Korean',
        ['Tivoli', 'Korando', 'Rexton', 'Musso']),

    // ============================ European ============================
    VehicleMake('BMW', 'European', [
      '1 Series', '2 Series', '3 Series', '4 Series', '5 Series', '7 Series',
      'X1', 'X3', 'X4', 'X5', 'X6', 'X7'
    ]),
    VehicleMake('Mercedes-Benz', 'European', [
      'A-Class', 'B-Class', 'C-Class', 'E-Class', 'S-Class', 'CLA', 'CLS',
      'GLA', 'GLB', 'GLC', 'GLE', 'GLS', 'G-Class'
    ]),
    VehicleMake('Audi', 'European',
        ['A1', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'Q2', 'Q3', 'Q5', 'Q7', 'Q8']),
    VehicleMake('Volkswagen', 'European',
        ['Polo', 'Golf', 'Jetta', 'Passat', 'Arteon', 'T-Roc', 'Tiguan', 'Touareg', 'Teramont']),
    VehicleMake('Porsche', 'European',
        ['718', '911', 'Panamera', 'Macan', 'Cayenne', 'Taycan']),
    VehicleMake('Mini', 'European', ['Cooper', 'Clubman', 'Countryman']),
    VehicleMake('Peugeot', 'European',
        ['208', '301', '308', '2008', '3008', '5008', 'Partner']),
    VehicleMake('Renault', 'European',
        ['Clio', 'Symbol', 'Megane', 'Talisman', 'Captur', 'Duster', 'Koleos', 'Kadjar']),
    VehicleMake('Citroën', 'European', ['C3', 'C4', 'C5 Aircross', 'Berlingo']),
    VehicleMake('Dacia', 'European', ['Sandero', 'Logan', 'Duster', 'Spring']),
    VehicleMake('Opel', 'European', ['Corsa', 'Astra', 'Insignia', 'Crossland', 'Grandland']),
    VehicleMake('Škoda', 'European',
        ['Fabia', 'Octavia', 'Superb', 'Kamiq', 'Karoq', 'Kodiaq']),
    VehicleMake('SEAT', 'European', ['Ibiza', 'Leon', 'Arona', 'Ateca']),
    VehicleMake('Volvo', 'European',
        ['S60', 'S90', 'XC40', 'XC60', 'XC90']),
    VehicleMake('Fiat', 'European', ['500', 'Tipo', 'Panda', 'Doblo']),
    VehicleMake('Alfa Romeo', 'European', ['Giulia', 'Stelvio', 'Tonale']),
    VehicleMake('Land Rover', 'European',
        ['Defender', 'Discovery', 'Range Rover', 'Range Rover Sport', 'Evoque', 'Velar']),
    VehicleMake('Jaguar', 'European', ['XE', 'XF', 'F-Pace', 'E-Pace', 'I-Pace']),

    // ============================ American ============================
    VehicleMake('Chevrolet', 'American', [
      'Spark', 'Aveo', 'Cruze', 'Malibu', 'Captiva', 'Groove', 'Trax',
      'Equinox', 'Blazer', 'Traverse', 'Tahoe', 'Suburban', 'Silverado'
    ]),
    VehicleMake('Ford', 'American',
        ['Fiesta', 'Focus', 'Fusion', 'EcoSport', 'Escape', 'Edge', 'Explorer', 'Expedition', 'Ranger', 'F-150']),
    VehicleMake('GMC', 'American',
        ['Terrain', 'Acadia', 'Yukon', 'Sierra']),
    VehicleMake('Jeep', 'American',
        ['Renegade', 'Compass', 'Cherokee', 'Grand Cherokee', 'Wrangler', 'Gladiator']),
    VehicleMake('Dodge', 'American', ['Charger', 'Challenger', 'Durango']),
    VehicleMake('RAM', 'American', ['1500', '2500']),
    VehicleMake('Chrysler', 'American', ['300', 'Pacifica']),
    VehicleMake('Cadillac', 'American', ['CT4', 'CT5', 'XT4', 'XT5', 'XT6', 'Escalade']),
    VehicleMake('Lincoln', 'American', ['Corsair', 'Nautilus', 'Aviator', 'Navigator']),
    VehicleMake('Tesla', 'American', ['Model 3', 'Model Y', 'Model S', 'Model X']),

    // ============================= Chinese ============================
    VehicleMake('MG', 'Chinese',
        ['MG3', 'MG5', 'MG6', 'MG7', 'ZS', 'HS', 'RX5', 'RX8', 'GT', 'Marvel R']),
    VehicleMake('Geely', 'Chinese',
        ['Emgrand', 'Coolray', 'Azkarra', 'Tugella', 'Okavango', 'Monjaro', 'Starray', 'GX3 Pro']),
    VehicleMake('Chery', 'Chinese',
        ['Tiggo 2', 'Tiggo 4 Pro', 'Tiggo 7 Pro', 'Tiggo 8 Pro', 'Arrizo 5', 'Arrizo 6', 'Arrizo 8']),
    VehicleMake('Haval', 'Chinese',
        ['Jolion', 'H6', 'Dargo', 'H9', 'F7', 'Big Dog']),
    VehicleMake('Great Wall', 'Chinese',
        ['Poer', 'Wingle 5', 'Wingle 7', 'Tank 300', 'Tank 500']),
    VehicleMake('BYD', 'Chinese',
        ['F3', 'Qin', 'Han', 'Tang', 'Song Plus', 'Yuan Plus / Atto 3', 'Dolphin', 'Seal']),
    VehicleMake('Changan', 'Chinese',
        ['Alsvin', 'Eado', 'CS35 Plus', 'CS55 Plus', 'CS75 Plus', 'UNI-T', 'UNI-K', 'Hunter']),
    VehicleMake('GAC', 'Chinese',
        ['GA4', 'Empow', 'GS3', 'GS4', 'GS8', 'Emkoo', 'Emzoom', 'Aion Y']),
    VehicleMake('Jetour', 'Chinese',
        ['X70', 'X70 Plus', 'X90', 'Dashing', 'T2']),
    VehicleMake('JAC', 'Chinese', ['J7', 'JS2', 'JS4', 'JS6', 'T8', 'T9']),
    VehicleMake('Dongfeng', 'Chinese', ['Rich 6', 'Glory 500', 'Glory 580', 'AX7']),
    VehicleMake('Hongqi', 'Chinese', ['H5', 'H9', 'HS3', 'HS5', 'E-HS9']),
    VehicleMake('Exeed', 'Chinese', ['TXL', 'VX', 'LX', 'RX']),
    VehicleMake('Jaecoo', 'Chinese', ['J7', 'J8']),
    VehicleMake('Omoda', 'Chinese', ['C5', 'C7']),
    VehicleMake('Maxus', 'Chinese', ['T60', 'T90', 'D90', 'G50', 'Deliver 9']),
    VehicleMake('Bestune', 'Chinese', ['T77', 'T99', 'B70']),
    VehicleMake('Zeekr', 'Chinese', ['001', 'X', '7X']),

    // ============================== Other =============================
    VehicleMake('Lada', 'Other', ['Granta', 'Vesta', 'Niva', 'Largus']),
    VehicleMake('Mahindra', 'Other', ['Scorpio', 'XUV300', 'XUV700', 'Pik Up']),

    // Fallback for anything not listed.
    VehicleMake('Other', 'Other', ['Other']),
  ];

  static List<String> makeNames() => makes.map((m) => m.name).toList();

  static List<String> modelsFor(String make) =>
      makes.firstWhere((m) => m.name == make,
          orElse: () => const VehicleMake('', '', ['Other'])).models;

  static const List<String> fuelTypes = [
    'Petrol', 'Diesel', 'Hybrid', 'Plug-in Hybrid', 'Electric', 'LPG'
  ];
  static const List<String> transmissions = [
    'Automatic', 'Manual', 'CVT', 'Dual-clutch'
  ];
}
