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

  group('MaintenanceEngine — sourced OEM schedules', () {
    // A GM full-size SUV covered by the sourced Chevrolet/GMC Middle-East
    // owner's manual (Tahoe/Suburban/Yukon, 2021–2026).
    Vehicle tahoe({int odo = 0}) => Vehicle(
          id: 'gm1',
          make: 'Chevrolet',
          model: 'Tahoe',
          year: 2023,
          fuelType: 'Petrol',
          odometerKm: odo,
          odometerUpdatedAt: DateTime(2026, 6, 11),
          createdAt: DateTime(2026, 6, 11),
        );

    test('prefers the sourced SEVERE transmission interval (GM Tahoe 70,000 km)',
        () {
      final tx = engine
          .buildSchedule(
            vehicle: tahoe(),
            history: const [],
            now: DateTime(2026, 6, 11),
            // Default severity is already severe; stated here for clarity.
            severity: DrivingSeverity.severe,
          )
          .firstWhere((s) => s.type == ServiceType.transmissionFluid);

      // The ME-edition manual publishes transmission fluid ONLY as a severe
      // (70,000 km) item; Lebanon = severe, so that cited value must win over
      // the generic computed 60,000 km severe fallback.
      expect(tx.basis, IntervalBasis.factory);
      expect(tx.oemCitation, isNotNull);
      expect(tx.oemCitation!.usedSevere, isTrue);
      expect(tx.oemCitation!.intervalKm, 70000);
      expect(tx.oemCitation!.sourceLabel, contains('GM Tahoe'));
      // With no history and odo 0, first due lands exactly on the interval.
      expect(tx.nextDueOdometerKm, 70000);
    });

    test('condition-based make surfaces a concrete baseline + indicator', () {
      final oil = engine
          .buildSchedule(
            vehicle: tahoe(),
            history: const [],
            now: DateTime(2026, 6, 11),
          )
          .firstWhere((s) => s.type == ServiceType.oilChange);

      // GM uses the Oil Life System; the sourced row still carries a concrete
      // baseline (12 months) and is flagged condition-based — never "varies".
      expect(oil.oemCitation, isNotNull);
      expect(oil.oemCitation!.conditionBased, isTrue);
      expect(oil.oemCitation!.intervalMonths, 12);
    });

    test('un-sourced vehicle still gets the computed fallback schedule', () {
      // Renault is in no sourced dataset — the engine must keep its computed
      // make-level rule, with no OEM citation.
      final renault = Vehicle(
        id: 'rx',
        make: 'Renault',
        model: 'Clio',
        year: 2019,
        fuelType: 'Petrol',
        odometerKm: 0,
        odometerUpdatedAt: DateTime(2026, 6, 11),
        createdAt: DateTime(2026, 6, 11),
      );
      final oil = engine
          .buildSchedule(
            vehicle: renault,
            history: const [],
            now: DateTime(2026, 6, 11),
          )
          .firstWhere((s) => s.type == ServiceType.oilChange);

      expect(oil.oemCitation, isNull);
      // Computed global severe oil interval is 5,000 km → first due at 5,000.
      expect(oil.nextDueOdometerKm, 5000);
      expect(oil.basis, IntervalBasis.factory);
    });

    test('Toyota Corolla (unknown fuel) does not match the hybrid-only table',
        () {
      // The only loosely-matching Toyota table is powertrain-specific (Hybrid);
      // an unknown-fuel Corolla must fall back to computed, keeping legacy
      // behaviour (severe plugs at the Toyota override of 100,000 km).
      final plugs = engine
          .buildSchedule(
            vehicle: vehicle(odo: 0),
            history: const [],
            now: DateTime(2026, 6, 11),
          )
          .firstWhere((s) => s.type == ServiceType.sparkPlugs);
      expect(plugs.oemCitation, isNull);
      expect(plugs.nextDueOdometerKm, 100000);
    });
  });
}
