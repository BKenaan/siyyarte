import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/lebanon.dart';
import '../../core/models/money.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../maintenance/models/service_record.dart';
import '../maintenance/models/service_type.dart';
import '../maintenance/screens/mark_service_done_sheet.dart';
import '../vehicles/models/vehicle.dart';

/// Operating costs: what the user has ACTUALLY spent on each car, aggregated
/// from their service-history records (not editable estimates). USD and LBP are
/// kept separate — there is no assumed exchange rate.
class CostCenterScreen extends ConsumerWidget {
  const CostCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? const [];

    if (vehicles.isEmpty) {
      return Scaffold(body: Center(child: Text(t.noVehiclesBody)));
    }

    final perVehicle = [
      for (final v in vehicles)
        (
          vehicle: v,
          costs: _Costs.from(
              ref.watch(historyProvider(v.id)).valueOrNull ?? const []),
        ),
    ];

    final grand = _Costs.combine([for (final e in perVehicle) e.costs]);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _logCost(context, ref, vehicles),
        icon: const Icon(Icons.add),
        label: Text(t.logCost),
      ),
      body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t.operatingCosts,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(t.operatingCostsBody,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),

        // Grand total across all cars.
        if (grand.hasAny)
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.charcoalGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.allVehicles,
                        style: const TextStyle(
                            color: AppColors.textSecondaryDark, fontSize: 13)),
                    const SizedBox(height: 6),
                    _TotalsText(grand, big: true),
                  ],
                ),
                Text(t.servicesLogged(grand.count),
                    style: const TextStyle(
                        color: AppColors.textSecondaryDark, fontSize: 12)),
              ],
            ),
          ),
        const SizedBox(height: 16),

        ...perVehicle.map((e) => _VehicleCostCard(
              vehicle: e.vehicle,
              costs: e.costs,
              t: t,
            )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// Log a non-maintenance operating cost (fuel, insurance, registration…).
  void _logCost(BuildContext context, WidgetRef ref, List<Vehicle> vehicles) {
    var vehicleId =
        ref.read(selectedVehicleProvider)?.id ?? vehicles.first.id;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        final t = AppLocalizations.of(sheetCtx);
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.logCost,
                    style: Theme.of(sheetCtx).textTheme.titleLarge),
                const SizedBox(height: 14),
                if (vehicles.length > 1)
                  DropdownButtonFormField<String>(
                    value: vehicleId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: t.vehicles),
                    items: vehicles
                        .map((v) => DropdownMenuItem(
                            value: v.id, child: Text(v.displayName)))
                        .toList(),
                    onChanged: (v) =>
                        setSheet(() => vehicleId = v ?? vehicleId),
                  ),
                const SizedBox(height: 8),
                Text(t.category,
                    style: Theme.of(sheetCtx).textTheme.labelLarge),
                ...kExpenseTypes.map((type) => ListTile(
                      leading: Icon(type.icon),
                      title: Text(type.label(t)),
                      onTap: () {
                        final v =
                            vehicles.firstWhere((e) => e.id == vehicleId);
                        Navigator.pop(sheetCtx);
                        MarkServiceDoneSheet.show(
                          context,
                          vehicleId: v.id,
                          type: type,
                          currentOdometerKm: v.odometerKm,
                        );
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehicleCostCard extends StatelessWidget {
  const _VehicleCostCard(
      {required this.vehicle, required this.costs, required this.t});
  final Vehicle vehicle;
  final _Costs costs;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.directions_car_filled),
          title: Text(vehicle.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: costs.hasAny
              ? _TotalsText(costs)
              : Text(t.noCostsYet,
                  style: Theme.of(context).textTheme.bodySmall),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: costs.hasAny
              ? [
                  // Per-1,000 km, where computable.
                  if (vehicle.odometerKm > 0 && costs.usd > 0)
                    _row(
                      context,
                      t.perThousandKm,
                      Money.usd(costs.usd / (vehicle.odometerKm / 1000))
                          .formatted(),
                    ),
                  const Divider(height: 16),
                  // Breakdown by service type.
                  ...costs.sortedTypes.map((type) {
                    final u = costs.usdByType[type] ?? 0;
                    final l = costs.lbpByType[type] ?? 0;
                    return _row(
                      context,
                      type.label(t),
                      [
                        if (u > 0) Money.usd(u).formatted(),
                        if (l > 0) Money.lbp(l).formatted(),
                      ].join(' · '),
                    );
                  }),
                ]
              : const [],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _TotalsText extends StatelessWidget {
  const _TotalsText(this.costs, {this.big = false});
  final _Costs costs;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (costs.usd > 0) Money.usd(costs.usd).formatted(),
      if (costs.lbp > 0) Money.lbp(costs.lbp).formatted(),
    ];
    return Text(
      parts.isEmpty ? '—' : parts.join('  +  '),
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: big ? 22 : 14,
        color: big ? AppColors.textPrimaryDark : null,
      ),
    );
  }
}

/// Aggregated actual costs from service records.
class _Costs {
  double usd = 0;
  double lbp = 0;
  int count = 0;
  final Map<ServiceType, double> usdByType = {};
  final Map<ServiceType, double> lbpByType = {};

  bool get hasAny => usd > 0 || lbp > 0;

  List<ServiceType> get sortedTypes {
    final types = {...usdByType.keys, ...lbpByType.keys}.toList();
    types.sort((a, b) {
      final ta = (usdByType[a] ?? 0) + (lbpByType[a] ?? 0);
      final tb = (usdByType[b] ?? 0) + (lbpByType[b] ?? 0);
      return tb.compareTo(ta);
    });
    return types;
  }

  static _Costs from(List<ServiceRecord> history) {
    final c = _Costs();
    for (final r in history) {
      final cost = r.cost;
      if (cost == null) continue;
      c.count++;
      if (cost.currency == Currency.usd) {
        c.usd += cost.amount;
        c.usdByType[r.type] = (c.usdByType[r.type] ?? 0) + cost.amount;
      } else {
        c.lbp += cost.amount;
        c.lbpByType[r.type] = (c.lbpByType[r.type] ?? 0) + cost.amount;
      }
    }
    return c;
  }

  static _Costs combine(List<_Costs> all) {
    final c = _Costs();
    for (final x in all) {
      c.usd += x.usd;
      c.lbp += x.lbp;
      c.count += x.count;
    }
    return c;
  }
}
