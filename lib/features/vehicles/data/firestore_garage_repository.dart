import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/vehicle.dart';
import '../../maintenance/models/service_record.dart';
import '../../maintenance/models/service_type.dart';
import 'garage_repository.dart';

/// Firestore-backed garage. Firestore's built-in offline persistence makes this
/// work with no/poor connectivity — reads come from the local cache and writes
/// queue until signal returns, which matches Lebanese conditions.
///
/// Layout: users/{uid}/vehicles/{vid} and users/{uid}/vehicles/{vid}/history.
class FirestoreGarageRepository implements GarageRepository {
  FirestoreGarageRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _vehiclesCol =>
      _db.collection('users').doc(_uid).collection('vehicles');

  CollectionReference<Map<String, dynamic>> _historyCol(String vehicleId) =>
      _vehiclesCol.doc(vehicleId).collection('history');

  DocumentReference<Map<String, dynamic>> _vinRef(String vin) =>
      _db.collection('vin_registry').doc(vin);

  @override
  Stream<List<Vehicle>> watchVehicles() => _vehiclesCol
      .orderBy('createdAt')
      .snapshots()
      .map((snap) => snap.docs
          // Cars sold + transferred to another account drop out of the
          // garage (the docs stay for the seller's own records).
          .where((d) => d.data()['transferredOut'] != true)
          .map((d) => Vehicle.fromMap(d.id, d.data()))
          .toList());

  @override
  Future<void> upsertVehicle(Vehicle vehicle) async {
    final vin = vehicle.vin;
    if (vin == null || vin.isEmpty) {
      await _vehiclesCol.doc(vehicle.id).set(vehicle.toMap());
      return;
    }
    // One car ↔ one account: the VIN is claimed in a global registry in the
    // SAME batch as the vehicle write. If another account holds it, the
    // pre-check (and, on a race, the rules) reject the save.
    final regRef = _vinRef(vin);
    final reg = await regRef.get();
    if (reg.exists && reg.data()?['uid'] != _uid) {
      throw VinAlreadyClaimedException(vin);
    }
    final batch = _db.batch();
    batch.set(_vehiclesCol.doc(vehicle.id), vehicle.toMap());
    if (!reg.exists) {
      batch.set(regRef, {
        'uid': _uid,
        'vehicleId': vehicle.id,
        'claimedAt': FieldValue.serverTimestamp(),
      });
    }
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      // Race: someone claimed the VIN between our read and the commit — the
      // registry create became an update, which the rules deny.
      if (e.code == 'permission-denied') {
        throw VinAlreadyClaimedException(vin);
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    // Free the VIN claim along with the vehicle so the next owner can add it.
    final snap = await _vehiclesCol.doc(vehicleId).get();
    final vin = snap.data()?['vin'] as String?;
    final batch = _db.batch();
    batch.delete(_vehiclesCol.doc(vehicleId));
    if (vin != null && vin.isNotEmpty) {
      // Only release a claim that is still OURS — after a sale transfer the
      // registry entry belongs to the buyer and must survive this delete.
      final reg = await _vinRef(vin).get();
      if (reg.exists && reg.data()?['uid'] == _uid) {
        batch.delete(_vinRef(vin));
      }
    }
    await batch.commit();
  }

  @override
  Future<void> updateOdometer(String vehicleId, int km) =>
      _vehiclesCol.doc(vehicleId).update({
        'odometerKm': km,
        'odometerUpdatedAt': DateTime.now().toIso8601String(),
      });

  @override
  Stream<List<ServiceRecord>> watchHistory(String vehicleId) =>
      _historyCol(vehicleId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => ServiceRecord.fromMap(d.id, d.data()))
              .toList());

  @override
  Future<void> addServiceRecord(ServiceRecord record) async {
    // Server-stamp the entry time so it cannot be backdated by the client.
    // The security rule requires createdAt == request.time, so a forged client
    // value would be rejected — making the log tamper-evident.
    final map = record.toMap()..['createdAt'] = FieldValue.serverTimestamp();
    await _historyCol(record.vehicleId).doc(record.id).set(map);
    // Bump the odometer if this is a new high reading. Fuel fill-ups DO carry a
    // real odometer (the most frequent checkpoint) so they bump; the other pure
    // expenses (insurance/registration/parking/other) don't ratchet the reading.
    if (kExpenseTypes.contains(record.type) &&
        record.type != ServiceType.fuel) {
      return;
    }
    final vehicleRef = _vehiclesCol.doc(record.vehicleId);
    final snap = await vehicleRef.get();
    final current = (snap.data()?['odometerKm'] as int?) ?? 0;
    if (record.odometerKm > current) {
      await vehicleRef.update({
        'odometerKm': record.odometerKm,
        'odometerUpdatedAt': record.date.toIso8601String(),
      });
    }
  }

  @override
  Future<void> deleteServiceRecord(String vehicleId, String recordId) =>
      _historyCol(vehicleId).doc(recordId).delete();
}
