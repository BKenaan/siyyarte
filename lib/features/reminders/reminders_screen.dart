import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../maintenance/models/scheduled_service.dart';
import '../maintenance/models/service_type.dart';
import '../premium/premium_controller.dart';
import '../premium/siyyarte_plus_screen.dart';

class _Reminder {
  final String title;
  final String body;
  final DateTime when;
  final IconData icon;
  const _Reminder(this.title, this.body, this.when, this.icon);
}

/// Lists upcoming reminders for the selected vehicle (time-based services +
/// insurance & Mécanique expiry) and schedules them as offline local
/// notifications. Reminders fire 14 days before the due date.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  static const _leadDays = 14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final vehicle = ref.watch(selectedVehicleProvider);
    if (vehicle == null) {
      return Center(child: Text(t.noVehiclesBody));
    }

    final history = ref.watch(historyProvider(vehicle.id)).valueOrNull ?? const [];
    final engine = ref.watch(maintenanceEngineProvider);
    final schedule = engine.buildSchedule(
        vehicle: vehicle, history: history, now: DateTime.now());

    final reminders = <_Reminder>[
      for (final s in schedule)
        if (s.nextDueDate != null && s.status != HealthStatus.good)
          _Reminder(
            s.type.label(t),
            dueText(s, t),
            s.nextDueDate!.subtract(const Duration(days: _leadDays)),
            s.type.icon,
          ),
      if (vehicle.insuranceExpiry != null)
        _Reminder(
          t.insuranceReminder,
          DateFormat.yMMMd().format(vehicle.insuranceExpiry!),
          vehicle.insuranceExpiry!.subtract(const Duration(days: 30)),
          Icons.shield_outlined,
        ),
      if (vehicle.inspectionExpiry != null)
        _Reminder(
          t.inspectionReminder,
          DateFormat.yMMMd().format(vehicle.inspectionExpiry!),
          vehicle.inspectionExpiry!.subtract(const Duration(days: 30)),
          Icons.fact_check_outlined,
        ),
    ]..sort((a, b) => a.when.compareTo(b.when));

    final isPremium = ref.watch(isPremiumProvider);
    return Scaffold(
      body: reminders.isEmpty
          ? Center(child: Text(t.healthGood))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Reminders are automatic & free — scheduled on-device for all
                // cars. Nudge free users to Plus for cross-device push.
                Card(
                  color: Colors.green.withValues(alpha: 0.08),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active_outlined,
                        color: Colors.green),
                    title: const Text('Reminders are on'),
                    subtitle: Text(isPremium
                        ? 'Alerts fire on your phone and across your devices.'
                        : 'Alerts fire on this phone automatically. Upgrade to '
                            'Plus for cross-device push.'),
                    trailing: isPremium
                        ? null
                        : TextButton(
                            onPressed: () => SiyyartePlusScreen.show(context),
                            child: const Text('Plus')),
                  ),
                ),
                const SizedBox(height: 8),
                ...reminders.map((r) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Icon(r.icon)),
                        title: Text(r.title),
                        subtitle: Text(r.body),
                        trailing: Text(DateFormat.MMMd().format(r.when)),
                      ),
                    )),
              ],
            ),
    );
  }

  String dueText(ScheduledService s, AppLocalizations t) {
    final km = s.kmRemaining;
    if (km != null && km <= 0) return t.overdueByKm(-km);
    if (km != null) return t.dueInKm(km);
    return s.nextDueDate == null
        ? ''
        : DateFormat.yMMMd().format(s.nextDueDate!);
  }
}
