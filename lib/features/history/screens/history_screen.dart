import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../maintenance/models/service_type.dart';
import '../pdf_export.dart';

/// Chronological service-history timeline with PDF export and per-record undo.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key, required this.vehicleId});
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? const [];
    final vehicle = vehicles.where((v) => v.id == vehicleId).firstOrNull;
    final historyAsync = ref.watch(historyProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.serviceHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: t.exportPdf,
            onPressed: () {
              // Your own records export freely; the branded, cited resale
              // Passport is the premium document.
              final history = historyAsync.valueOrNull ?? const [];
              if (vehicle != null && history.isNotEmpty) {
                ServiceHistoryPdf.export(vehicle, history);
              }
            },
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (history) {
          if (history.isEmpty) {
            return Center(child: Text(t.noHistory));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, i) {
              final r = history[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Icon(r.type.icon)),
                  title: Text(r.type.label(t)),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(r.date)} · '
                    '${NumberFormat.decimalPattern().format(r.odometerKm)} km'
                    '${r.garageName != null ? ' · ${r.garageName}' : ''}'
                    '${r.cost != null ? ' · ${r.cost!.formatted()}' : ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: t.undo,
                    onPressed: () => ref
                        .read(garageRepositoryProvider)
                        .deleteServiceRecord(vehicleId, r.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
