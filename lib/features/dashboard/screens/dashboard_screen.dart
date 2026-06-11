import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../maintenance/models/scheduled_service.dart';
import '../../maintenance/models/service_type.dart';
import '../widgets/health_gauge.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final vehicle = ref.watch(selectedVehicleProvider);

    if (vehicle == null) {
      return _EmptyState(t: t);
    }

    final historyAsync = ref.watch(historyProvider(vehicle.id));
    final engine = ref.watch(maintenanceEngineProvider);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (history) {
        final schedule = engine.buildSchedule(
          vehicle: vehicle,
          history: history,
          now: DateTime.now(),
        );
        final overall = engine.overallHealth(schedule);
        final next = engine.nextService(schedule);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Premium hero: vehicle + odometer + health gauge on charcoal.
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.charcoalGradient,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                    color: AppColors.tailLightRed.withValues(alpha: 0.18)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              AppColors.tailLightRed.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.directions_car_filled,
                            color: AppColors.tailLightRed, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vehicle.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: AppColors.textPrimaryDark,
                                        fontWeight: FontWeight.w700)),
                            Text(
                              '${NumberFormat.decimalPattern().format(vehicle.odometerKm)} km',
                              style: const TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  HealthGauge(status: overall),
                  const SizedBox(height: 6),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Next service
            if (next != null) ...[
              Text(t.nextService,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _ServiceTile(service: next, t: t),
              const SizedBox(height: 16),
            ],

            // Upcoming reminders (next few)
            Text(t.upcomingReminders,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...schedule
                .where((s) => s.status != HealthStatus.good)
                .take(5)
                .map((s) => _ServiceTile(service: s, t: t)),
            if (schedule.every((s) => s.status == HealthStatus.good))
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle,
                      color: AppColors.healthGood),
                  title: Text(t.healthGood),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.t});

  final ScheduledService service;
  final AppLocalizations t;

  Color get _color => switch (service.status) {
        HealthStatus.good => AppColors.healthGood,
        HealthStatus.upcoming => AppColors.healthUpcoming,
        HealthStatus.overdue => AppColors.healthOverdue,
      };

  String _subtitle() {
    final km = service.kmRemaining;
    if (km != null) {
      return km <= 0 ? t.overdueByKm(-km) : t.dueInKm(km);
    }
    final date = service.nextDueDate;
    if (date != null) {
      return t.dueOn(DateFormat.yMMMd().format(date));
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color.withValues(alpha: 0.12),
          child: Icon(service.type.icon, color: _color),
        ),
        title: Text(service.type.label(t)),
        subtitle: Text(_subtitle()),
        trailing: Icon(Icons.circle, size: 12, color: _color),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.t});
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_car_outlined, size: 72),
            const SizedBox(height: 16),
            Text(t.noVehicles,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(t.noVehiclesBody, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
