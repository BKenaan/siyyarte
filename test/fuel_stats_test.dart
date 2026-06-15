import 'package:flutter_test/flutter_test.dart';
import 'package:garagi/core/constants/lebanon.dart';
import 'package:garagi/core/models/money.dart';
import 'package:garagi/features/fuel/fuel_stats.dart';
import 'package:garagi/features/maintenance/models/service_record.dart';
import 'package:garagi/features/maintenance/models/service_type.dart';

ServiceRecord fuel(int odo, double liters, bool full, {double? price}) =>
    ServiceRecord(
      id: 'f$odo',
      vehicleId: 'v1',
      type: ServiceType.fuel,
      date: DateTime(2026, 1, 1).add(Duration(days: odo)),
      odometerKm: odo,
      liters: liters,
      fullTank: full,
      cost: price != null ? Money(price, Currency.usd) : null,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  test('full-to-full consumption, averages and totals', () {
    final history = [
      fuel(1000, 40, true, price: 40),
      fuel(1500, 35, true, price: 35), // 35L / 500km -> 7.0 L/100km
      fuel(2000, 45, true, price: 45), // 45L / 500km -> 9.0 L/100km
    ];
    final s = FuelCalculator.compute(history);
    expect(s.avgConsumption, closeTo(8.0, 0.001));
    expect(s.bestConsumption, closeTo(7.0, 0.001));
    expect(s.worstConsumption, closeTo(9.0, 0.001));
    expect(s.totalLiters, closeTo(120, 0.001));
    expect(s.distanceKm, 1000);
    expect(s.spentByCurrency[Currency.usd], closeTo(120, 0.001));
    // avg price/L = 120 / 120 = 1.0
    expect(s.avgPricePerLiter[Currency.usd], closeTo(1.0, 0.001));
    // newest first for display
    expect(s.fillUps.first.odometerKm, 2000);
  });

  test('partial fill-ups do not create consumption segments', () {
    final history = [
      fuel(1000, 40, true),
      fuel(1300, 20, false), // partial — not a segment endpoint
      fuel(1600, 50, true), // 50L / 600km -> ~8.33
    ];
    final s = FuelCalculator.compute(history);
    expect(s.avgConsumption, closeTo(50 / 600 * 100, 0.001));
    expect(s.totalLiters, closeTo(110, 0.001));
  });

  test('single fill-up has no consumption yet', () {
    final s = FuelCalculator.compute([fuel(1000, 40, true)]);
    expect(s.avgConsumption, isNull);
    expect(s.fillUps.length, 1);
  });
}
