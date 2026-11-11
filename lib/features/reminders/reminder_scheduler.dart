import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../maintenance/models/scheduled_service.dart';
import '../maintenance/models/service_type.dart';
import 'notification_service.dart';

/// Schedules on-device maintenance reminders for ALL of the user's vehicles,
/// automatically — free for everyone (local notifications cost nothing).
/// Cross-device push (the server sweep) stays the Plus differentiator.
///
/// Called on app open (and after the user changes data): it cancels the old
/// schedule and lays down a fresh one, so reminders stay in sync with the
/// current service state without the user ever tapping "schedule".
abstract class ReminderScheduler {
  static const _serviceLeadDays = 14;
  static const _expiryLeadDays = 30;

  static Future<void> syncAll(WidgetRef ref, AppLocalizations t) async {
    if (kIsWeb) return;
    final svc = NotificationService.instance;
    await svc.requestPermissions();

    final repo = ref.read(garageRepositoryProvider);
    final engine = ref.read(maintenanceEngineProvider);
    final vehicles = await repo.watchVehicles().first;

    // Rebuild the whole schedule from scratch so stale reminders don't linger.
    await svc.cancelAll();
    final now = DateTime.now();

    for (final v in vehicles) {
      final history = await repo.watchHistory(v.id).first;
      final schedule =
          engine.buildSchedule(vehicle: v, history: history, now: now);

      Future<void> put(String key, String title, String body, DateTime when) =>
          svc.scheduleReminder(
            id: '${v.id}:$key'.hashCode & 0x7fffffff,
            title: '${v.displayName} — $title',
            body: body,
            whenLocal: when,
          );

      for (final s in schedule) {
        if (s.nextDueDate != null && s.status != HealthStatus.good) {
          await put(
            s.type.name,
            s.type.label(t),
            _dueText(s, t),
            s.nextDueDate!.subtract(const Duration(days: _serviceLeadDays)),
          );
        }
      }
      if (v.insuranceExpiry != null) {
        await put('insurance', t.insuranceReminder,
            t.insuranceReminder,
            v.insuranceExpiry!.subtract(const Duration(days: _expiryLeadDays)));
      }
      if (v.inspectionExpiry != null) {
        await put('inspection', t.inspectionReminder, t.inspectionReminder,
            v.inspectionExpiry!.subtract(const Duration(days: _expiryLeadDays)));
      }
    }
  }

  static String _dueText(ScheduledService s, AppLocalizations t) {
    final km = s.kmRemaining;
    if (km != null && km <= 0) return t.overdueByKm(-km);
    if (km != null) return t.dueInKm(km);
    return '';
  }
}
