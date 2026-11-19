import 'maintenance_rule.dart';
import 'oem_citation.dart';
import 'service_type.dart';

/// Health status of a scheduled service — drives the Green/Yellow/Red UI.
enum HealthStatus { good, upcoming, overdue }

/// A computed view of a single service's standing for a vehicle: when it was
/// last done and when it's next due, by both mileage and time.
class ScheduledService {
  final ServiceType type;

  final DateTime? lastDoneDate;
  final int? lastDoneOdometerKm;

  final int? nextDueOdometerKm;
  final DateTime? nextDueDate;

  /// Km remaining until due (negative = overdue). Null if mileage not tracked.
  final int? kmRemaining;

  /// Days remaining until due (negative = overdue). Null if time not tracked.
  final int? daysRemaining;

  final HealthStatus status;

  /// Where this interval comes from (factory / wear-estimate / regulatory).
  final IntervalBasis basis;

  /// Human-readable provenance for the interval (shown in the detail UI).
  final String source;

  /// Set when this row's interval came from a SOURCED OEM schedule (not the
  /// generic computed fallback). Drives the citation badge. Null for computed
  /// rows, which keep their "general schedule" note.
  final OemCitation? oemCitation;

  const ScheduledService({
    required this.type,
    this.lastDoneDate,
    this.lastDoneOdometerKm,
    this.nextDueOdometerKm,
    this.nextDueDate,
    this.kmRemaining,
    this.daysRemaining,
    required this.status,
    required this.basis,
    required this.source,
    this.oemCitation,
  });
}
