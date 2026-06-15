import '../../core/constants/lebanon.dart';
import '../../core/models/money.dart';
import '../maintenance/models/service_record.dart';
import '../maintenance/models/service_type.dart';

/// A single fuel fill-up derived from a fuel ServiceRecord.
class FuelFillUp {
  final DateTime date;
  final int odometerKm;
  final double? liters;
  final bool fullTank;
  final Money? cost;
  final String? station; // garageName reused
  FuelFillUp({
    required this.date,
    required this.odometerKm,
    required this.liters,
    required this.fullTank,
    this.cost,
    this.station,
  });

  /// L/100km for the segment ending at this fill-up, computed against the
  /// previous full-tank fill-up. Null unless both ends are usable.
  double? consumption;

  /// Price per litre for this fill-up (in its own currency).
  double? get pricePerLiter =>
      (cost != null && liters != null && liters! > 0)
          ? cost!.amount / liters!
          : null;
}

/// Aggregate fuel stats for one vehicle. Consumption is currency-independent;
/// money totals are kept per currency (Lebanese owners mix USD and LBP).
class FuelStats {
  final List<FuelFillUp> fillUps; // newest first
  final double? avgConsumption; // L/100km across full-tank segments
  final double? bestConsumption;
  final double? worstConsumption;
  final double totalLiters;
  final int distanceKm; // first → last fill-up
  final Map<Currency, double> spentByCurrency;
  final Map<Currency, double> avgPricePerLiter;
  const FuelStats({
    required this.fillUps,
    required this.avgConsumption,
    required this.bestConsumption,
    required this.worstConsumption,
    required this.totalLiters,
    required this.distanceKm,
    required this.spentByCurrency,
    required this.avgPricePerLiter,
  });

  bool get hasData => fillUps.isNotEmpty;
}

abstract class FuelCalculator {
  /// Builds fuel stats from a vehicle's service history. Consumption uses the
  /// full-to-full method: between two consecutive full-tank fill-ups, the litres
  /// added at the LATER one over the distance covered = that segment's L/100km.
  static FuelStats compute(List<ServiceRecord> history) {
    final fills = history
        .where((r) => r.type == ServiceType.fuel)
        .map((r) => FuelFillUp(
              date: r.date,
              odometerKm: r.odometerKm,
              liters: r.liters,
              fullTank: r.fullTank ?? false,
              cost: r.cost,
              station: r.garageName,
            ))
        .toList()
      // chronological for the segment math
      ..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));

    double totalLiters = 0;
    final spent = <Currency, double>{};
    final litersByCurrency = <Currency, double>{};
    final costByCurrency = <Currency, double>{};
    for (final f in fills) {
      if (f.liters != null) totalLiters += f.liters!;
      final c = f.cost;
      if (c != null) {
        spent[c.currency] = (spent[c.currency] ?? 0) + c.amount;
        if (f.liters != null) {
          litersByCurrency[c.currency] =
              (litersByCurrency[c.currency] ?? 0) + f.liters!;
          costByCurrency[c.currency] =
              (costByCurrency[c.currency] ?? 0) + c.amount;
        }
      }
    }

    // Full-tank-to-full-tank consumption segments.
    final segments = <double>[];
    FuelFillUp? lastFull;
    for (final f in fills) {
      if (f.fullTank) {
        if (lastFull != null &&
            f.liters != null &&
            f.odometerKm > lastFull.odometerKm) {
          final dist = f.odometerKm - lastFull.odometerKm;
          final lp100 = f.liters! / dist * 100;
          f.consumption = lp100;
          segments.add(lp100);
        }
        lastFull = f;
      }
    }

    double? avg, best, worst;
    if (segments.isNotEmpty) {
      avg = segments.reduce((a, b) => a + b) / segments.length;
      best = segments.reduce((a, b) => a < b ? a : b); // lower L/100km = better
      worst = segments.reduce((a, b) => a > b ? a : b);
    }

    final avgPrice = <Currency, double>{};
    for (final cur in litersByCurrency.keys) {
      final l = litersByCurrency[cur]!;
      if (l > 0) avgPrice[cur] = costByCurrency[cur]! / l;
    }

    final distance =
        fills.length >= 2 ? fills.last.odometerKm - fills.first.odometerKm : 0;

    return FuelStats(
      fillUps: fills.reversed.toList(), // newest first for display
      avgConsumption: avg,
      bestConsumption: best,
      worstConsumption: worst,
      totalLiters: totalLiters,
      distanceKm: distance,
      spentByCurrency: spent,
      avgPricePerLiter: avgPrice,
    );
  }
}
