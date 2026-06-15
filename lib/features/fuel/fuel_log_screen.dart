import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/money.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import 'add_fuel_sheet.dart';
import 'fuel_stats.dart';

/// Per-vehicle fuel log: economy stats + a list of fill-ups. Fuel is the
/// highest-frequency expense in Lebanon, so this is the app's daily-touch hook.
class FuelLogScreen extends ConsumerWidget {
  const FuelLogScreen(
      {super.key, required this.vehicleId, required this.currentOdometerKm});
  final String vehicleId;
  final int currentOdometerKm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider(vehicleId));
    return Scaffold(
      appBar: AppBar(title: const Text('Fuel log')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddFuelSheet.show(context,
            vehicleId: vehicleId, currentOdometerKm: currentOdometerKm),
        icon: const Icon(Icons.local_gas_station),
        label: const Text('Log fill-up'),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (history) {
          final stats = FuelCalculator.compute(history);
          if (!stats.hasData) return const _EmptyFuel();
          final df = DateFormat.yMMMd();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _StatsCard(stats: stats),
              const SizedBox(height: 16),
              Text('Fill-ups',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...stats.fillUps.map((f) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.accentOrange.withValues(alpha: 0.12),
                        child: const Icon(Icons.local_gas_station,
                            color: AppColors.accentOrange),
                      ),
                      title: Text(
                          '${f.liters?.toStringAsFixed(1) ?? '—'} L'
                          '${f.cost != null ? '  ·  ${f.cost!.formatted()}' : ''}'),
                      subtitle: Text(
                          '${df.format(f.date)}  ·  '
                          '${NumberFormat.decimalPattern().format(f.odometerKm)} km'
                          '${f.station != null ? '  ·  ${f.station}' : ''}'
                          '${!f.fullTank ? '  ·  partial' : ''}'),
                      trailing: f.consumption != null
                          ? Text('${f.consumption!.toStringAsFixed(1)}\nL/100',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy))
                          : null,
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});
  final FuelStats stats;

  @override
  Widget build(BuildContext context) {
    final spent = stats.spentByCurrency.entries
        .map((e) => Money(e.value, e.key).formatted())
        .join('  +  ');
    final price = stats.avgPricePerLiter.entries
        .map((e) => '${Money(e.value, e.key).formatted()}/L')
        .join('  ·  ');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _big(
                  context,
                  stats.avgConsumption?.toStringAsFixed(1) ?? '—',
                  'L/100km avg'),
              const SizedBox(width: 24),
              _big(
                  context,
                  stats.totalLiters > 0
                      ? stats.totalLiters.toStringAsFixed(0)
                      : '—',
                  'litres total'),
              const SizedBox(width: 24),
              _big(context, '${stats.fillUps.length}', 'fill-ups'),
            ],
          ),
          if (stats.bestConsumption != null) ...[
            const SizedBox(height: 12),
            Text(
              'Best ${stats.bestConsumption!.toStringAsFixed(1)} · '
              'worst ${stats.worstConsumption!.toStringAsFixed(1)} L/100km'
              '${stats.distanceKm > 0 ? '  ·  ${NumberFormat.decimalPattern().format(stats.distanceKm)} km tracked' : ''}',
              style: const TextStyle(
                  color: AppColors.textSecondaryDark, fontSize: 12),
            ),
          ],
          if (spent.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Spent $spent${price.isNotEmpty ? '   ·   avg $price' : ''}',
                style: const TextStyle(
                    color: AppColors.textSecondaryDark, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _big(BuildContext context, String value, String label) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondaryDark, fontSize: 11)),
        ],
      );
}

class _EmptyFuel extends StatelessWidget {
  const _EmptyFuel();
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_gas_station_outlined, size: 64),
              const SizedBox(height: 16),
              Text('No fill-ups yet',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(
                'Log every fill-up to track your fuel economy (L/100km) and '
                'spend. Keep "filled the tank full" on for accurate numbers.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
