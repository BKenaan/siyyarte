import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_detail_screen.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(t.addVehicle),
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Center(child: Text(t.noVehiclesBody));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            itemBuilder: (context, i) {
              final v = vehicles[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    ref.read(selectedVehicleIdProvider.notifier).state = v.id;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VehicleDetailScreen(vehicleId: v.id),
                      ),
                    );
                  },
                  leading: const Icon(Icons.directions_car_filled),
                  title: Text(v.displayName),
                  subtitle: Text(
                      '${NumberFormat.decimalPattern().format(v.odometerKm)} km'
                      '${v.plateNumber != null ? ' · ${v.plateNumber}' : ''}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
