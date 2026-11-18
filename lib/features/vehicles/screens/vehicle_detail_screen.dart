import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/analytics.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../maintenance/models/scheduled_service.dart';
import '../../maintenance/models/service_type.dart';
import '../../maintenance/screens/mark_service_done_sheet.dart';
import '../../maintenance/ui/maintenance_ui.dart';
import '../../history/resale_passport.dart';
import '../../history/screens/history_screen.dart';
import '../../fuel/fuel_log_screen.dart';
import '../../premium/premium_controller.dart';
import '../../premium/siyyarte_plus_screen.dart';
import '../../specs/verified_spec.dart';
import '../../specs/verified_spec_repository.dart';
import '../../specs/verified_widgets.dart';
import '../../uploads/ai_scan_service.dart';
import '../models/vehicle.dart';
import '../widgets/common_faults_section.dart';
import 'add_vehicle_screen.dart';

/// Full maintenance schedule for one vehicle, color-coded, with per-service
/// "mark done" and odometer updates.
class VehicleDetailScreen extends ConsumerWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? const [];
    final vehicle = vehicles.where((v) => v.id == vehicleId).firstOrNull;
    if (vehicle == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }

    final historyAsync = ref.watch(historyProvider(vehicleId));
    final engine = ref.watch(maintenanceEngineProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.displayName),
        actions: [
          IconButton(
            tooltip: 'Fuel log',
            icon: const Icon(Icons.local_gas_station_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FuelLogScreen(
                    vehicleId: vehicleId,
                    currentOdometerKm: vehicle.odometerKm))),
          ),
          IconButton(
            tooltip: t.serviceHistory,
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => HistoryScreen(vehicleId: vehicleId))),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddVehicleScreen(vehicle: vehicle)));
              } else if (value == 'odometer') {
                _updateOdometer(context, ref, vehicle.odometerKm);
              } else if (value == 'passport') {
                if (ref.read(isPremiumProvider)) {
                  final history =
                      ref.read(historyProvider(vehicleId)).valueOrNull ??
                          const [];
                  // Pull the manufacturer-verified spec (if any) so its cited
                  // values appear in the passport — a strong resale trust signal.
                  final verified = (await ref.read(verifiedSpecProvider((
                    make: vehicle.make,
                    model: vehicle.model,
                    year: vehicle.year,
                    engine: vehicle.engineType,
                  )).future))
                      ?.spec;
                  Analytics.exportPassport();
                  await ResalePassportPdf.export(vehicle, history,
                      verified: verified);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.premiumRequired)),
                  );
                  SiyyartePlusScreen.show(context);
                }
              } else if (value == 'delete') {
                await ref
                    .read(garageRepositoryProvider)
                    .deleteVehicle(vehicleId);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'odometer', child: Text(t.updateOdometer)),
              PopupMenuItem(
                value: 'passport',
                child: Row(
                  children: [
                    Expanded(child: Text(t.vehiclePassport)),
                    if (!ref.watch(isPremiumProvider))
                      const Icon(Icons.lock_outline, size: 16),
                  ],
                ),
              ),
              PopupMenuItem(value: 'edit', child: Text(t.editVehicle)),
              PopupMenuItem(value: 'delete', child: Text(t.deleteVehicle)),
            ],
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (history) {
          final schedule = engine.buildSchedule(
            vehicle: vehicle,
            history: history,
            now: DateTime.now(),
          );
          // Manufacturer-verified spec for this car+market (null while loading
          // or when none exists). Drives the field-level "Verified" overlay.
          final verifiedAsync = ref.watch(verifiedSpecProvider((
            make: vehicle.make,
            model: vehicle.model,
            year: vehicle.year,
            engine: vehicle.engineType,
          )));
          final verified = verifiedAsync.valueOrNull?.spec;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Ownership-verification state — the same signal the resale
              // passport reports, so the owner sees it (and fixes it) early.
              if (vehicle.regStatus != RegStatus.verified)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RegBanner(vehicle: vehicle),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.speed),
                  title: Text(
                      '${NumberFormat.decimalPattern().format(vehicle.odometerKm)} km'),
                  subtitle: Text(t.odometer),
                  trailing: TextButton(
                    onPressed: () =>
                        _updateOdometer(context, ref, vehicle.odometerKm),
                    child: Text(t.updateOdometer),
                  ),
                ),
              ),
              // Manufacturer-verified specs (cited fluids/capacities) for the
              // resolved market — appears only when a verified record exists.
              if (verified != null) ...[
                const SizedBox(height: 16),
                VerifiedSpecsCard(
                  spec: verified,
                  marketAmbiguous:
                      verifiedAsync.valueOrNull?.marketAmbiguous ?? false,
                ),
              ],
              const SizedBox(height: 16),
              // Known issues this specific vehicle is prone to — each cited to a
              // real recall / bulletin / reliability reference (or a tasteful
              // empty state when none are catalogued).
              CommonFaultsSection(vehicle: vehicle),
              const SizedBox(height: 16),
              Text(t.maintenanceSchedule,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...schedule.map((s) => _ScheduleCard(
                    service: s,
                    t: t,
                    verified: matchInterval(verified, s.type),
                    marketScope: verified?.marketScope,
                    onMarkDone: () => MarkServiceDoneSheet.show(
                      context,
                      vehicleId: vehicleId,
                      type: s.type,
                      currentOdometerKm: vehicle.odometerKm,
                    ),
                  )),
              const SizedBox(height: 12),
              Text(t.factoryNote,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          );
        },
      ),
    );
  }

  void _updateOdometer(BuildContext context, WidgetRef ref, int current) {
    final controller = TextEditingController(text: current.toString());
    final t = AppLocalizations.of(context);
    final scanner = ref.read(aiScanServiceProvider);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.updateOdometer),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '${t.odometer} (km)',
            suffixIcon: scanner.available
                ? IconButton(
                    tooltip: t.scanOdometer,
                    icon: const Icon(Icons.document_scanner_outlined),
                    onPressed: () async {
                      try {
                        final km = await scanner.scanOdometer();
                        if (km != null) controller.text = km.toString();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.scanFailed)),
                          );
                        }
                      }
                    },
                  )
                : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          FilledButton(
            onPressed: () {
              final km = int.tryParse(controller.text);
              if (km != null) {
                ref
                    .read(garageRepositoryProvider)
                    .updateOdometer(vehicleId, km);
              }
              Navigator.pop(context);
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard(
      {required this.service,
      required this.t,
      required this.onMarkDone,
      this.verified,
      this.marketScope});
  final ScheduledService service;
  final AppLocalizations t;
  final VoidCallback onMarkDone;
  final VerifiedInterval? verified;
  final String? marketScope;

  /// The official interval text (e.g. "Every 8,000 km / 6 mo (severe)").
  String? get _verifiedIntervalText {
    final v = verified;
    if (v == null) return null;
    String km(int? k) => '${(k! / 1000).toStringAsFixed(0)},000 km';
    if (v.severeKm != null) {
      return 'Severe: every ${km(v.severeKm)}'
          '${v.severeMonths != null ? ' / ${v.severeMonths} mo' : ''}'
          '${v.normalKm != null ? ' · Normal: ${km(v.normalKm)}' : ''}';
    }
    if (v.normalKm != null) {
      return 'Every ${km(v.normalKm)}'
          '${v.normalMonths != null ? ' / ${v.normalMonths} mo' : ''}';
    }
    if (v.firstKm != null) {
      return 'First ${km(v.firstKm)}'
          '${v.subsequentKm != null ? ', then ${km(v.subsequentKm)}' : ''}';
    }
    return v.notes;
  }

  @override
  Widget build(BuildContext context) {
    final color = service.status.color;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(service.type.icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.type.label(t),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(dueSubtitle(service, t),
                          style: TextStyle(color: color, fontSize: 13)),
                    ],
                  ),
                ),
                TextButton(
                    onPressed: onMarkDone, child: Text(t.markDone)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(service.basis.icon, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${service.basis.label(t)} · ${service.lastDoneDate == null ? t.never : '${t.lastDone}: ${DateFormat.yMMMd().format(service.lastDoneDate!)}'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Field-level verification state: official interval + source badge
            // where available, otherwise an honest "general schedule" label.
            if (verified != null) ...[
              if (_verifiedIntervalText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Official interval: $_verifiedIntervalText',
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              VerifiedBadge(
                marketScope: marketScope ?? '',
                sourceDoc: verified!.sourceDoc,
                sourcePage: verified!.sourcePage,
                sourceUrl: verified!.sourceUrl,
              ),
            ] else
              const GeneralScheduleNote(),
          ],
        ),
      ),
    );
  }
}

/// Surfaces a non-verified ownership state with a one-tap path to fix it
/// (attach/replace the registration card via the edit screen).
class _RegBanner extends ConsumerWidget {
  const _RegBanner({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final (icon, color, text) = switch (vehicle.regStatus) {
      RegStatus.none => (
          Icons.badge_outlined,
          cs.tertiary,
          'No registration card on file — attach one so the Service Booklet '
              'can verify ownership.',
        ),
      RegStatus.cardOnFile => (
          Icons.task_outlined,
          cs.tertiary,
          'Registration card on file, VIN not machine-verified yet — rescan '
              'to verify.',
        ),
      RegStatus.mismatch => (
          Icons.report_outlined,
          cs.error,
          'The VIN on the registration card does not match this vehicle\'s '
              'VIN — fix it before exporting a Service Booklet.',
        ),
      RegStatus.verified => (Icons.verified_outlined, cs.primary, ''),
    };

    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AddVehicleScreen(vehicle: vehicle))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text,
                    style: TextStyle(color: color, fontSize: 12.5)),
              ),
              Icon(Icons.chevron_right, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
