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
      'Yaris', 'Yaris Cross', 'Corolla', 'Corolla Cross', 'Camry', 'Avalon',
      'C-HR', 'Raize', 'Veloz', 'RAV4', 'Highlander', 'Land Cruiser',
      'Land Cruiser 70', 'Prado', 'Fortuner', 'Sequoia', 'FJ Cruiser', '4Runner',
      'Hilux', 'Hiace', 'Innova', 'Previa', 'Rush', 'Crown', 'Supra', 'GR86',
      'Prius', 'bZ4X', 'Aygo'
    ]),
    VehicleMake('Honda', 'Japanese', [
      'Brio', 'City', 'Jazz', 'Fit', 'Civic', 'Accord', 'HR-V', 'Vezel', 'CR-V',
      'ZR-V', 'Pilot', 'Passport', 'Odyssey'
    ]),
    VehicleMake('Nissan', 'Japanese', [
      'Micra', 'Tiida', 'Note', 'Sunny', 'Sentra', 'Sylphy', 'Versa', 'Altima',
      'Maxima', 'Kicks', 'Juke', 'Qashqai', 'X-Trail', 'Rogue', 'Murano',
      'Pathfinder', 'Patrol', 'Armada', 'Xterra', 'Terra', 'Navara', 'Urvan',
      'Z', '370Z', 'GT-R'
    ]),
    VehicleMake('Mitsubishi', 'Japanese', [
      'Mirage', 'Attrage', 'Colt', 'Lancer', 'Galant', 'Eclipse Cross', 'ASX',
      'Xpander', 'Outlander', 'Montero Sport', 'Pajero', 'Pajero Sport',
      'L200', 'Triton'
    ]),
    VehicleMake('Mazda', 'Japanese', [
      'Mazda2', 'Mazda3', 'Mazda6', 'MX-5', 'CX-3', 'CX-30', 'CX-5', 'CX-8',
      'CX-9', 'CX-50', 'CX-60', 'CX-90', 'BT-50'
    ]),
    VehicleMake('Suzuki', 'Japanese', [
      'Alto', 'Celerio', 'Swift', 'Dzire', 'Baleno', 'Ciaz', 'Ertiga', 'XL7',
      'Fronx', 'Vitara', 'Grand Vitara', 'Jimny', 'S-Cross'
    ]),
    VehicleMake('Subaru', 'Japanese', [
      'Impreza', 'WRX', 'BRZ', 'Legacy', 'XV', 'Crosstrek', 'Forester',
      'Outback', 'Ascent'
    ]),
    VehicleMake('Lexus', 'Japanese', [
      'CT', 'IS', 'ES', 'GS', 'LS', 'RC', 'LC', 'UX', 'NX', 'RX', 'GX', 'LX',
      'RZ', 'TX', 'LM'
    ]),
    VehicleMake('Infiniti', 'Japanese',
        ['Q50', 'Q60', 'Q70', 'QX30', 'QX50', 'QX55', 'QX60', 'QX70', 'QX80']),
    VehicleMake('Acura', 'Japanese',
        ['ILX', 'TLX', 'TL', 'TSX', 'RLX', 'Integra', 'RDX', 'MDX', 'ZDX']),
    VehicleMake('Isuzu', 'Japanese', ['D-Max', 'MU-X', 'Trooper']),
    VehicleMake('Daihatsu', 'Japanese', ['Terios', 'Sirion', 'Gran Max']),

    // ============================= Korean =============================
    VehicleMake('Hyundai', 'Korean', [
      'Atos', 'Getz', 'i10', 'Grand i10', 'i20', 'i30', 'Accent', 'Verna',
      'Elantra', 'Veloster', 'Sonata', 'Azera', 'Grandeur', 'Venue', 'Bayon',
      'Kona', 'Creta', 'Tucson', 'Santa Fe', 'Santa Cruz', 'Palisade', 'Staria',
      'Starex', 'H-1', 'Ioniq', 'Ioniq 5', 'Ioniq 6'
    ]),
    VehicleMake('Kia', 'Korean', [
      'Picanto', 'Morning', 'Rio', 'Pegas', 'Cerato', 'Forte', 'K5', 'Optima',
      'Cadenza', 'Stinger', 'Soul', 'Stonic', 'Sonet', 'Seltos', 'Sportage',
      'Sorento', 'Mohave', 'Telluride', 'Carens', 'Carnival', 'Niro', 'EV6',
      'EV9'
    ]),
    VehicleMake('Genesis', 'Korean',
        ['G70', 'G80', 'G90', 'GV60', 'GV70', 'GV80']),
    VehicleMake('SsangYong', 'Korean',
        ['Tivoli', 'Korando', 'Actyon', 'Rexton', 'Musso', 'Torres']),
    VehicleMake('KGM', 'Korean',
        ['Torres', 'Tivoli', 'Korando', 'Rexton', 'Musso', 'Actyon']),
    VehicleMake('Daewoo', 'Korean',
        ['Matiz', 'Lanos', 'Nubira', 'Cielo', 'Leganza', 'Nexia']),

    // ============================ European ============================
    VehicleMake('BMW', 'European', [
      '1 Series', '2 Series', '3 Series', '4 Series', '5 Series', '6 Series',
      '7 Series', '8 Series', 'Z4', 'X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7',
      'i4', 'iX', 'iX3'
    ]),
    VehicleMake('Mercedes-Benz', 'European', [
      'A-Class', 'B-Class', 'C-Class', 'E-Class', 'S-Class', 'CLA', 'CLS',
      'CLE', 'SLK', 'SL', 'GLA', 'GLB', 'GLC', 'GLE', 'GLK', 'GLS', 'GL', 'ML',
      'G-Class', 'V-Class', 'Vito', 'EQA', 'EQB', 'EQC', 'EQE', 'EQS'
    ]),
    VehicleMake('Audi', 'European', [
      'A1', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'Q2', 'Q3', 'Q5', 'Q6', 'Q7',
      'Q8', 'TT', 'e-tron', 'Q4 e-tron'
    ]),
    VehicleMake('Volkswagen', 'European', [
      'Up', 'Polo', 'Golf', 'Beetle', 'Jetta', 'Bora', 'Passat', 'CC',
      'Arteon', 'T-Cross', 'T-Roc', 'Taos', 'Tiguan', 'Touran', 'Touareg',
      'Teramont', 'Atlas', 'Amarok', 'ID.4', 'ID.6'
    ]),
    VehicleMake('Porsche', 'European', [
      '718', 'Cayman', 'Boxster', '911', 'Panamera', 'Macan', 'Cayenne', 'Taycan'
    ]),
    VehicleMake('Mini', 'European',
        ['Cooper', 'Hatch', 'Convertible', 'Clubman', 'Countryman', 'Paceman']),
    VehicleMake('Smart', 'European', ['Fortwo', 'Forfour', '#1', '#3', '#5']),
    VehicleMake('Peugeot', 'European', [
      '206', '207', '208', '301', '307', '308', '406', '508', '2008', '3008',
      '408', '5008', 'Partner', 'RCZ'
    ]),
    VehicleMake('Renault', 'European', [
      'Twingo', 'Clio', 'Symbol', 'Fluence', 'Megane', 'Laguna', 'Talisman',
      'Captur', 'Arkana', 'Austral', 'Duster', 'Scenic', 'Kadjar', 'Koleos',
      'Kangoo'
    ]),
    VehicleMake('Citroën', 'European',
        ['C1', 'C3', 'C-Elysée', 'C4', 'C5', 'C5 Aircross', 'Berlingo']),
    VehicleMake('Dacia', 'European', ['Sandero', 'Logan', 'Duster', 'Spring']),
    VehicleMake('Opel', 'European', [
      'Corsa', 'Astra', 'Insignia', 'Vectra', 'Mokka', 'Crossland',
      'Grandland', 'Zafira', 'Antara'
    ]),
    VehicleMake('Škoda', 'European',
        ['Fabia', 'Octavia', 'Superb', 'Scala', 'Kamiq', 'Karoq', 'Kodiaq']),
    VehicleMake('SEAT', 'European', ['Ibiza', 'Leon', 'Arona', 'Ateca', 'Tarraco']),
    VehicleMake('Volvo', 'European',
        ['S40', 'S60', 'S80', 'S90', 'V40', 'V60', 'XC40', 'XC60', 'XC70',
        'XC90', 'C40']),
    VehicleMake('Fiat', 'European',
        ['500', '500X', 'Tipo', 'Egea', 'Punto', 'Linea', 'Panda', 'Doblo']),
    VehicleMake('Alfa Romeo', 'European',
        ['Giulietta', 'Giulia', '159', 'Stelvio', 'Tonale']),
    VehicleMake('Land Rover', 'European', [
      'Defender', 'Discovery', 'Discovery Sport', 'Freelander', 'Range Rover',
      'Range Rover Sport', 'Evoque', 'Velar'
    ]),
    VehicleMake('Jaguar', 'European',
        ['XE', 'XF', 'XJ', 'F-Type', 'S-Type', 'F-Pace', 'E-Pace', 'I-Pace']),
    VehicleMake('Polestar', 'European', ['1', '2', '3', '4']),
    VehicleMake('DS', 'European', ['DS 3', 'DS 4', 'DS 5', 'DS 7', 'DS 9']),
    VehicleMake('Cupra', 'European',
        ['Leon', 'Formentor', 'Ateca', 'Born', 'Tavascan', 'Terramar']),
    VehicleMake('Maserati', 'European',
        ['Ghibli', 'Quattroporte', 'Levante', 'Grecale', 'GranTurismo', 'MC20']),
    VehicleMake('Lancia', 'European', ['Ypsilon', 'Delta', 'Musa']),
    VehicleMake('Bentley', 'European',
        ['Continental GT', 'Flying Spur', 'Bentayga']),
    VehicleMake('Ferrari', 'European',
        ['Roma', 'Portofino', '296', 'SF90', 'F8', '812', 'Purosangue']),
    VehicleMake('Lamborghini', 'European',
        ['Huracán', 'Aventador', 'Urus', 'Revuelto']),
    VehicleMake('Rolls-Royce', 'European',
        ['Ghost', 'Phantom', 'Wraith', 'Dawn', 'Cullinan', 'Spectre']),
    VehicleMake('Aston Martin', 'European',
        ['Vantage', 'DB11', 'DB12', 'DBS', 'DBX']),

    // ============================ American ============================
    VehicleMake('Chevrolet', 'American', [
      'Spark', 'Aveo', 'Sonic', 'Optra', 'Cruze', 'Malibu', 'Impala', 'Lumina',
      'Caprice', 'Camaro', 'Captiva', 'Groove', 'Trax', 'Trailblazer',
      'Equinox', 'Blazer', 'Traverse', 'Tahoe', 'Suburban', 'Colorado',
      'Silverado'
    ]),
    VehicleMake('Ford', 'American', [
      'Fiesta', 'Focus', 'Fusion', 'Taurus', 'Mustang', 'EcoSport', 'Escape',
      'Edge', 'Territory', 'Explorer', 'Everest', 'Flex', 'Bronco', 'Expedition',
      'Crown Victoria', 'Ranger', 'F-150', 'Transit'
    ]),
    VehicleMake('GMC', 'American',
        ['Terrain', 'Acadia', 'Envoy', 'Yukon', 'Canyon', 'Sierra', 'Savana']),
    VehicleMake('Jeep', 'American', [
      'Renegade', 'Compass', 'Patriot', 'Liberty', 'Cherokee', 'Grand Cherokee',
      'Commander', 'Wrangler', 'Gladiator', 'Wagoneer'
    ]),
    VehicleMake('Dodge', 'American',
        ['Charger', 'Challenger', 'Journey', 'Nitro', 'Caliber', 'Durango',
        'Grand Caravan']),
    VehicleMake('RAM', 'American', ['1500', '2500', '3500']),
    VehicleMake('Chrysler', 'American',
        ['300', '200', 'Sebring', 'Pacifica', 'Town & Country', 'Voyager']),
    VehicleMake('Cadillac', 'American', [
      'ATS', 'CTS', 'CT4', 'CT5', 'STS', 'XTS', 'DTS', 'SRX', 'XT4', 'XT5',
      'XT6', 'Escalade', 'Lyriq'
    ]),
    VehicleMake('Lincoln', 'American', [
      'MKZ', 'MKC', 'MKX', 'MKS', 'Corsair', 'Nautilus', 'Aviator', 'Navigator',
      'Continental', 'Town Car'
    ]),
    VehicleMake('Buick', 'American', [
      'Encore', 'Encore GX', 'Envista', 'Envision', 'Enclave', 'Verano',
      'Regal', 'LaCrosse', 'Excelle'
    ]),
    VehicleMake('Tesla', 'American',
        ['Model 3', 'Model Y', 'Model S', 'Model X', 'Cybertruck']),
    VehicleMake('Hummer', 'American', ['H1', 'H2', 'H3']),
    VehicleMake('Rivian', 'American', ['R1T', 'R1S']),
    VehicleMake('Lucid', 'American', ['Air', 'Gravity']),

    // ============================= Chinese ============================
    VehicleMake('MG', 'Chinese', [
      'MG3', 'MG5', 'MG6', 'MG7', 'ZS', 'HS', 'RX5', 'RX8', 'RX9', 'GT', 'MG4',
      'One', 'Whale', 'Marvel R', 'Cyberster', 'Extender'
    ]),
    VehicleMake('Geely', 'Chinese', [
      'Emgrand', 'Emgrand X7', 'GC6', 'Binyue', 'Coolray', 'Azkarra', 'Boyue',
      'Tugella', 'Okavango', 'Preface', 'Monjaro', 'Starray', 'Geometry C',
      'Cityray', 'EX5', 'GX3 Pro'
    ]),
    VehicleMake('Chery', 'Chinese', [
      'QQ', 'Tiggo 2', 'Tiggo 3', 'Tiggo 4 Pro', 'Tiggo 5', 'Tiggo 7 Pro',
      'Tiggo 8 Pro', 'Tiggo 9', 'Arrizo 5', 'Arrizo 6', 'Arrizo 8', 'Fulwin'
    ]),
    VehicleMake('Haval', 'Chinese',
        ['H2', 'Jolion', 'H6', 'H6 GT', 'H7', 'Dargo', 'H9', 'F7', 'M6',
        'Big Dog']),
    VehicleMake('Great Wall', 'Chinese', [
      'Poer', 'Wingle 5', 'Wingle 7', 'Cannon', 'Tank 300', 'Tank 400',
      'Tank 500', 'Ora Good Cat'
    ]),
    VehicleMake('BYD', 'Chinese', [
      'F0', 'F3', 'Seagull', 'Dolphin', 'Atto 2', 'Qin', 'Han', 'Tang',
      'Song Pro', 'Song Plus', 'Yuan Plus / Atto 3', 'Yuan Up', 'Seal',
      'Seal U', 'Sealion 6', 'Sealion 7', 'Shark', 'e6'
    ]),
    VehicleMake('Changan', 'Chinese', [
      'Benni', 'Alsvin', 'Eado', 'Lamore', 'CS15', 'CS35', 'CS35 Plus',
      'CS55 Plus', 'CS75 Plus', 'CS95', 'UNI-T', 'UNI-K', 'UNI-V', 'Oshan X7',
      'Hunter'
    ]),
    VehicleMake('GAC', 'Chinese', [
      'GA4', 'GA6', 'Empow', 'GS3', 'GS4', 'GS5', 'GS8', 'GN6', 'GN8', 'M8',
      'Emkoo', 'Emzoom', 'Aion S', 'Aion V', 'Aion Y'
    ]),
    VehicleMake('Jetour', 'Chinese',
        ['X70', 'X70 Plus', 'X90', 'X95', 'Dashing', 'Traveller', 'T1', 'T2']),
    VehicleMake('JAC', 'Chinese',
        ['S2', 'S3', 'J7', 'JS2', 'JS4', 'JS6', 'Sunray', 'M4', 'T6', 'T8',
        'T9']),
    VehicleMake('Dongfeng', 'Chinese', [
      'Rich 6', 'Glory 500', 'Glory 580', 'AX7', 'Forthing T5', 'Fengon 500',
      'Mage'
    ]),
    VehicleMake('Hongqi', 'Chinese',
        ['H5', 'H6', 'H7', 'H9', 'HS3', 'HS5', 'HS7', 'LS7', 'HQ9', 'E-HS9']),
    VehicleMake('Exeed', 'Chinese', ['TXL', 'VX', 'LX', 'RX', 'Sterra']),
    VehicleMake('Jaecoo', 'Chinese', ['J5', 'J6', 'J7', 'J8']),
    VehicleMake('Omoda', 'Chinese', ['5', 'C5', 'E5', 'C7', 'C9']),
    VehicleMake('Maxus', 'Chinese',
        ['T60', 'T70', 'T90', 'D90', 'G50', 'Mifa 9', 'Deliver 9']),
    VehicleMake('Bestune', 'Chinese', ['T55', 'T77', 'T90', 'T99', 'B70']),
    VehicleMake('Zeekr', 'Chinese', ['001', '007', '009', 'X', '7X']),
    VehicleMake('Lynk & Co', 'Chinese', ['01', '03', '05', '06', '09']),
    VehicleMake('Avatr', 'Chinese', ['11', '12']),
    VehicleMake('Kaiyi', 'Chinese', ['X3', 'X3 Pro', 'X7', 'E5']),
    VehicleMake('Skywell', 'Chinese', ['ET5', 'HT-i']),
    VehicleMake('Deepal', 'Chinese', ['S05', 'S07', 'L07', 'E07']),
    VehicleMake('Tank', 'Chinese', ['300', '400', '500', '700']),
    VehicleMake('Ora', 'Chinese', ['Good Cat', '03', '07']),
    VehicleMake('Aion', 'Chinese', ['S', 'V', 'Y', 'ES', 'UT']),
    VehicleMake('Forthing', 'Chinese', ['T5', 'T5 Evo', 'Friday', 'Xinghai']),
    VehicleMake('Voyah', 'Chinese', ['Free', 'Dream', 'Passion', 'Courage']),
    VehicleMake('BAIC', 'Chinese', ['BJ40', 'BJ80', 'X35', 'X55', 'X7', 'U5']),
    VehicleMake('Foton', 'Chinese', ['Tunland', 'View', 'Sauvana', 'Toano']),
    VehicleMake('Leapmotor', 'Chinese', ['T03', 'C10', 'C11', 'C16', 'B10']),
    VehicleMake('Nio', 'Chinese', ['ET5', 'ET7', 'ES6', 'ES8', 'EC6', 'ET9']),
    VehicleMake('XPeng', 'Chinese', ['P7', 'P5', 'G3', 'G6', 'G9', 'X9']),
    VehicleMake('Wuling', 'Chinese',
        ['Hongguang', 'Air EV', 'Bingo', 'Almaz', 'Cortez']),
    VehicleMake('Seres', 'Chinese', ['3', '5', '7']),
    VehicleMake('Aito', 'Chinese', ['M5', 'M7', 'M9']),

    // ============================== Other =============================
    VehicleMake('Lada', 'Other', ['Granta', 'Vesta', 'Niva', 'Largus']),
    VehicleMake('UAZ', 'Other', ['Patriot', 'Hunter', 'Pickup', '469']),
    VehicleMake('Mahindra', 'Other', ['Scorpio', 'XUV300', 'XUV700', 'Pik Up']),
    VehicleMake('Tata', 'Other',
        ['Nexon', 'Punch', 'Tiago', 'Tigor', 'Altroz', 'Harrier', 'Safari']),
    VehicleMake('Proton', 'Other',
        ['Saga', 'Persona', 'Iriz', 'X50', 'X70', 'X90']),
    VehicleMake('Saipa', 'Other', ['Saba', 'Pride', 'Tiba', 'Shahin', 'Quick']),
    VehicleMake('Iran Khodro', 'Other',
        ['Samand', 'Dena', 'Runna', 'Soren', 'Peugeot Pars']),

    // Fallback for anything not listed.
    VehicleMake('Other', 'Other', ['Other']),
  ];

  static List<String> makeNames() => makes.map((m) => m.name).toList();

  static List<String> modelsFor(String make) =>
      makes.firstWhere((m) => m.name == make,
          orElse: () => const VehicleMake('', '', ['Other'])).models;

  // No Diesel: diesel passenger cars are banned from registration in Lebanon.
  static const List<String> fuelTypes = [
    'Petrol', 'Hybrid', 'Plug-in Hybrid', 'Electric', 'LPG'
  ];
  static const List<String> transmissions = [
    'Automatic', 'Manual', 'CVT', 'Dual-clutch'
  ];
}
