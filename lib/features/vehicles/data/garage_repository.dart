import '../models/vehicle.dart';
import '../../maintenance/models/service_record.dart';

/// Thrown when saving a vehicle whose VIN is already registered to ANOTHER
/// Siyyarte account. One car lives in one account at a time — if the car was
/// sold, the buyer requests a transfer and the current owner approves by
/// email (see VinTransferService / requestVinTransfer Cloud Function).
class VinAlreadyClaimedException implements Exception {
  const VinAlreadyClaimedException(this.vin);
  final String vin;

  @override
  String toString() =>
      'VIN $vin is already registered to another Siyyarte account.';
}

/// Storage abstraction for vehicles and their service history. Mirrors the
/// Firestore subcollection layout so the Firebase impl is a thin adapter.
abstract class GarageRepository {
  Stream<List<Vehicle>> watchVehicles();
  Future<void> upsertVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String vehicleId);
  Future<void> updateOdometer(String vehicleId, int km);

  Stream<List<ServiceRecord>> watchHistory(String vehicleId);

  /// Append a completed service. History is append-only; the engine reads it
  /// to recompute next-due automatically.
  Future<void> addServiceRecord(ServiceRecord record);

  /// Undo the most recent record of a type (mirrors rent_automation's
  /// "undo recorded payment" pattern).
  Future<void> deleteServiceRecord(String vehicleId, String recordId);
}
