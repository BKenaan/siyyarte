/// Outcome of checking the vehicle's registration card (دفتر السيارة).
/// Every new vehicle must be added with a photo of its registration card —
/// this is what stops someone inventing a car and selling a fake history.
enum RegStatus {
  /// No card on file (legacy vehicles added before the requirement).
  none,

  /// Card photo attached, but the VIN on it couldn't be machine-checked
  /// (AI scan unavailable or card unreadable).
  cardOnFile,

  /// AI read the card and the VIN printed on it matches this vehicle's VIN.
  verified,

  /// AI read the card and the VIN on it does NOT match — a red flag the
  /// passport must disclose.
  mismatch,
}

extension RegStatusX on RegStatus {
  static RegStatus fromId(String? id) => RegStatus.values.firstWhere(
        (e) => e.name == id,
        orElse: () => RegStatus.none,
      );
}

/// A user's vehicle. Fields mirror the Firestore `vehicles` subcollection and
/// are designed to round-trip offline (toMap/fromMap).
class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? trim;
  final String? engineType;
  final String? fuelType;
  final String? transmission;

  /// Current odometer reading in kilometers.
  final int odometerKm;
  final DateTime odometerUpdatedAt;

  final String? plateNumber;
  final DateTime? insuranceExpiry;
  final DateTime? inspectionExpiry; // Mécanique
  final String? photoUrl;

  /// Chassis number — entered, VIN-decoded, or read off the registration card.
  final String? vin;

  /// Photo of the vehicle registration card (required for new vehicles).
  final String? registrationCardUrl;

  /// Holder name as AI-read from the registration card.
  final String? regHolderName;

  /// VIN as AI-read from the registration card (for the cross-check).
  final String? regCardVin;

  final RegStatus regStatus;
  final DateTime createdAt;

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.trim,
    this.engineType,
    this.fuelType,
    this.transmission,
    required this.odometerKm,
    required this.odometerUpdatedAt,
    this.plateNumber,
    this.insuranceExpiry,
    this.inspectionExpiry,
    this.photoUrl,
    this.vin,
    this.registrationCardUrl,
    this.regHolderName,
    this.regCardVin,
    this.regStatus = RegStatus.none,
    required this.createdAt,
  });

  String get displayName => '$year $make $model';

  Vehicle copyWith({int? odometerKm, DateTime? odometerUpdatedAt}) => Vehicle(
        id: id,
        make: make,
        model: model,
        year: year,
        trim: trim,
        engineType: engineType,
        fuelType: fuelType,
        transmission: transmission,
        odometerKm: odometerKm ?? this.odometerKm,
        odometerUpdatedAt: odometerUpdatedAt ?? this.odometerUpdatedAt,
        plateNumber: plateNumber,
        insuranceExpiry: insuranceExpiry,
        inspectionExpiry: inspectionExpiry,
        photoUrl: photoUrl,
        vin: vin,
        registrationCardUrl: registrationCardUrl,
        regHolderName: regHolderName,
        regCardVin: regCardVin,
        regStatus: regStatus,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'make': make,
        'model': model,
        'year': year,
        'trim': trim,
        'engineType': engineType,
        'fuelType': fuelType,
        'transmission': transmission,
        'odometerKm': odometerKm,
        'odometerUpdatedAt': odometerUpdatedAt.toIso8601String(),
        'plateNumber': plateNumber,
        'insuranceExpiry': insuranceExpiry?.toIso8601String(),
        'inspectionExpiry': inspectionExpiry?.toIso8601String(),
        'photoUrl': photoUrl,
        'vin': vin,
        'registrationCardUrl': registrationCardUrl,
        'regHolderName': regHolderName,
        'regCardVin': regCardVin,
        'regStatus': regStatus.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Vehicle.fromMap(String id, Map<String, dynamic> m) => Vehicle(
        id: id,
        make: m['make'] as String,
        model: m['model'] as String,
        year: m['year'] as int,
        trim: m['trim'] as String?,
        engineType: m['engineType'] as String?,
        fuelType: m['fuelType'] as String?,
        transmission: m['transmission'] as String?,
        odometerKm: m['odometerKm'] as int,
        odometerUpdatedAt: DateTime.parse(m['odometerUpdatedAt'] as String),
        plateNumber: m['plateNumber'] as String?,
        insuranceExpiry: _date(m['insuranceExpiry']),
        inspectionExpiry: _date(m['inspectionExpiry']),
        photoUrl: m['photoUrl'] as String?,
        vin: m['vin'] as String?,
        registrationCardUrl: m['registrationCardUrl'] as String?,
        regHolderName: m['regHolderName'] as String?,
        regCardVin: m['regCardVin'] as String?,
        regStatus: RegStatusX.fromId(m['regStatus'] as String?),
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.parse(v as String);
}
