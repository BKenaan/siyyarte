import 'dart:async';

import '../models/vehicle.dart';
import '../../maintenance/models/service_record.dart';
import '../../maintenance/models/service_type.dart';
import '../../../core/models/money.dart';
import 'garage_repository.dart';

/// Offline, in-memory garage seeded with a realistic Lebanese demo car so the
/// dashboard is populated on first run. The Firebase impl will replace this.
class InMemoryGarageRepository implements GarageRepository {
  final _vehicles = <Vehicle>[];
  final _history = <ServiceRecord>[];
  final _vehiclesCtrl = StreamController<List<Vehicle>>.broadcast();
  final _historyCtrl = StreamController<List<ServiceRecord>>.broadcast();

  InMemoryGarageRepository() {
    _seed();
  }

  void _seed() {
    final now = DateTime(2026, 6, 11);
    final v = Vehicle(
      id: 'demo-1',
      make: 'Toyota',
      model: 'Corolla',
      year: 2018,
      trim: 'GLI',
      engineType: '1.6L I4',
      fuelType: 'Petrol',
      transmission: 'Automatic',
      odometerKm: 96500,
      odometerUpdatedAt: now,
      plateNumber: 'B 123456',
      insuranceExpiry: DateTime(2026, 7, 20),
      inspectionExpiry: DateTime(2026, 6, 30),
      createdAt: DateTime(2024, 1, 10),
    );
    _vehicles.add(v);

    _history.addAll([
      ServiceRecord(
        id: 'h1',
        vehicleId: v.id,
        type: ServiceType.oilChange,
        date: DateTime(2025, 12, 15),
        odometerKm: 92000,
        garageName: 'Garage Beirut Auto',
        cost: const Money.usd(35),
        createdAt: DateTime(2025, 12, 15),
      ),
      ServiceRecord(
        id: 'h2',
        vehicleId: v.id,
        type: ServiceType.brakePads,
        date: DateTime(2025, 3, 2),
        odometerKm: 80000,
        garageName: 'AutoFix Jounieh',
        cost: const Money.usd(90),
        createdAt: DateTime(2025, 3, 2),
      ),
    ]);
  }

  void _pushVehicles() => _vehiclesCtrl.add(List.unmodifiable(_vehicles));
  void _pushHistory() => _historyCtrl.add(List.unmodifiable(_history));

  @override
  Stream<List<Vehicle>> watchVehicles() async* {
    yield List.unmodifiable(_vehicles);
    yield* _vehiclesCtrl.stream;
  }

  @override
  Future<void> upsertVehicle(Vehicle vehicle) async {
    final i = _vehicles.indexWhere((e) => e.id == vehicle.id);
    if (i >= 0) {
      _vehicles[i] = vehicle;
    } else {
      _vehicles.add(vehicle);
    }
    _pushVehicles();
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    _vehicles.removeWhere((e) => e.id == vehicleId);
    _history.removeWhere((e) => e.vehicleId == vehicleId);
    _pushVehicles();
    _pushHistory();
  }

  @override
  Future<void> updateOdometer(String vehicleId, int km) async {
    final i = _vehicles.indexWhere((e) => e.id == vehicleId);
    if (i < 0) return;
    _vehicles[i] = _vehicles[i]
        .copyWith(odometerKm: km, odometerUpdatedAt: DateTime.now());
    _pushVehicles();
  }

  @override
  Stream<List<ServiceRecord>> watchHistory(String vehicleId) async* {
    List<ServiceRecord> forVehicle() => _history
        .where((e) => e.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    yield forVehicle();
    yield* _historyCtrl.stream.map((_) => forVehicle());
  }

  @override
  Future<void> addServiceRecord(ServiceRecord record) async {
    _history.add(record);
    // Recording a service updates the odometer if it's a new high reading.
    final i = _vehicles.indexWhere((e) => e.id == record.vehicleId);
    if (i >= 0 && record.odometerKm > _vehicles[i].odometerKm) {
      _vehicles[i] = _vehicles[i]
          .copyWith(odometerKm: record.odometerKm, odometerUpdatedAt: record.date);
      _pushVehicles();
    }
    _pushHistory();
  }

  @override
  Future<void> deleteServiceRecord(String vehicleId, String recordId) async {
    _history.removeWhere((e) => e.id == recordId);
    _pushHistory();
  }
}
