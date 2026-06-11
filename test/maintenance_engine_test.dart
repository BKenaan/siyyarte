import 'package:flutter_test/flutter_test.dart';
import 'package:garagi/features/maintenance/engine/maintenance_engine.dart';
import 'package:garagi/features/maintenance/models/maintenance_rule.dart';
import 'package:garagi/features/maintenance/models/scheduled_service.dart';
import 'package:garagi/features/maintenance/models/service_record.dart';
import 'package:garagi/features/maintenance/models/service_type.dart';
import 'package:garagi/features/vehicles/models/vehicle.dart';

void main() {
  const engine = MaintenanceEngine();

  Vehicle vehicle({required int odo, DateTime? created}) => Vehicle(
        id: 'v1',
        make: 'Toyota',
        model: 'Corolla',
        year: 2018,
        odometerKm: odo,
        odometerUpdatedAt: DateTime(2026, 6, 11),
        createdAt: created ?? DateTime(2024, 1, 1),
      );

  group('MaintenanceEngine', () {
    test('oil change becomes overdue past the 5,000 km interval', () {
      final history = [
        ServiceRecord(
          id: 'r1',
          vehicleId: 'v1',
          type: ServiceType.oilChange,
          date: DateTime(2026, 1, 1),
          odometerKm: 90000,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];
      final schedule = engine.buildSchedule(
        vehicle: vehicle(odo: 96000), // 6,000 km since last → overdue
        history: history,
        now: DateTime(2026, 6, 11),
      );
      final oil = schedule.firstWhere((s) => s.type == ServiceType.oilChange);

      expect(oil.nextDueOdometerKm, 95000);
      expect(oil.kmRemaining, -1000);
      expect(oil.status, HealthStatus.overdue);
    });

    test('marking a service done pushes the next due forward', () {
      final beforeOdo = 96000;
      final after = engine.buildSchedule(
        vehicle: vehicle(odo: beforeOdo),
        history: [
          ServiceRecord(
            id: 'r2',
            vehicleId: 'v1',
            type: ServiceType.oilChange,
            date: DateTime(2026, 6, 11),
            odometerKm: beforeOdo,
            createdAt: DateTime(2026, 6, 11),
          ),
        ],
        now: DateTime(2026, 6, 11),
      ).firstWhere((s) => s.type == ServiceType.oilChange);

      expect(after.nextDueOdometerKm, beforeOdo + 5000);
      expect(after.status, HealthStatus.good);
    });

    test('overall health is the worst individual status', () {
      final schedule = engine.buildSchedule(
        vehicle: vehicle(odo: 200000, created: DateTime(2015, 1, 1)),
        history: const [],
        now: DateTime(2026, 6, 11),
      );
      // A never-serviced 2015 car at 200k km should have overdue items.
      expect(engine.overallHealth(schedule), HealthStatus.overdue);
    });

    test('severe schedule shortens the oil interval vs normal', () {
      // Anchored to a real service record so the interval (not milestones) is
      // what's being compared.
      final history = [
        ServiceRecord(
          id: 'o',
          vehicleId: 'v1',
          type: ServiceType.oilChange,
          date: DateTime(2026, 1, 1),
          odometerKm: 50000,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];
      ScheduledService oilFor(DrivingSeverity sev) => engine
          .buildSchedule(
            vehicle: vehicle(odo: 50000),
            history: history,
            now: DateTime(2026, 6, 11),
            severity: sev,
          )
          .firstWhere((s) => s.type == ServiceType.oilChange);

      expect(oilFor(DrivingSeverity.severe).nextDueOdometerKm, 55000);
      expect(oilFor(DrivingSeverity.normal).nextDueOdometerKm, 60000);
    });

    test('used car at 100k km surfaces the major service as due (no history)',
        () {
      final schedule = engine.buildSchedule(
        vehicle: vehicle(odo: 100000, created: DateTime(2009, 1, 1)),
        history: const [],
        now: DateTime(2026, 6, 11),
      );
      ScheduledService s(ServiceType t) =>
          schedule.firstWhere((e) => e.type == t);

      // The 100k "major service" items are due/overdue — NOT reset to far out.
      expect(s(ServiceType.sparkPlugs).kmRemaining! <= 0, isTrue);
      expect(s(ServiceType.coolant).kmRemaining! <= 0, isTrue);
      expect(s(ServiceType.transmissionFluid).kmRemaining! <= 0, isTrue);
      expect(s(ServiceType.timingBelt).kmRemaining! <= 0, isTrue);
    });

    test('fuel type tailors the schedule (diesel/EV exclusions)', () {
      Vehicle fuel(String f) => Vehicle(
            id: 'v',
            make: 'Toyota',
            model: 'X',
            year: 2020,
            fuelType: f,
            odometerKm: 50000,
            odometerUpdatedAt: DateTime(2026, 6, 11),
            createdAt: DateTime(2026, 6, 11),
          );
      List<ServiceType> types(Vehicle v) => engine
          .buildSchedule(
              vehicle: v, history: const [], now: DateTime(2026, 6, 11))
          .map((s) => s.type)
          .toList();

      expect(types(fuel('Diesel')).contains(ServiceType.sparkPlugs), isFalse);
      final ev = types(fuel('Electric'));
      expect(ev.contains(ServiceType.oilChange), isFalse);
      expect(ev.contains(ServiceType.sparkPlugs), isFalse);
    });

    test('per-make override applies (Toyota iridium plugs ~100,000 km)', () {
      final toyota = Vehicle(
        id: 'v2',
        make: 'Toyota',
        model: 'Corolla',
        year: 2020,
        odometerKm: 0,
        odometerUpdatedAt: DateTime(2026, 6, 11),
        createdAt: DateTime(2026, 6, 11),
      );
      final plugs = engine
          .buildSchedule(
            vehicle: toyota,
            history: const [],
            now: DateTime(2026, 6, 11),
            severity: DrivingSeverity.severe,
          )
          .firstWhere((s) => s.type == ServiceType.sparkPlugs);

      // Toyota override keeps severe plugs at 100,000 km (vs 80,000 global).
      expect(plugs.nextDueOdometerKm, 100000);
      expect(plugs.basis, IntervalBasis.factory);
    });

    test('tires are flagged as wear-based, not factory-scheduled', () {
      final tires = engine
          .buildSchedule(
            vehicle: vehicle(odo: 50000),
            history: const [],
            now: DateTime(2026, 6, 11),
          )
          .firstWhere((s) => s.type == ServiceType.tires);
      expect(tires.basis, IntervalBasis.wearEstimate);
    });

    test('time-only inspection rule still produces a due date', () {
      final schedule = engine.buildSchedule(
        vehicle: vehicle(odo: 96000, created: DateTime(2024, 1, 1)),
        history: const [],
        now: DateTime(2026, 6, 11),
      );
      final inspection =
          schedule.firstWhere((s) => s.type == ServiceType.inspection);
      expect(inspection.nextDueDate, isNotNull);
      expect(inspection.kmRemaining, isNull);
    });
  });
}
