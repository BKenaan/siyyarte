import '../data/oem_schedule_catalog.dart';
import '../models/maintenance_rule.dart';
import '../models/oem_citation.dart';
import '../models/scheduled_service.dart';
import '../models/service_record.dart';
import '../models/service_type.dart';
import '../../vehicles/models/vehicle.dart';

/// The smart maintenance recommendation engine.
///
/// Pure, deterministic, and side-effect free so it runs identically on-device
/// (offline) and inside the server-side validation Cloud Function. Given a
/// vehicle, its service history, and a set of interval rules, it computes the
/// next-due mileage/date and a health status for every service.
class MaintenanceEngine {
  /// Thresholds (tunable) for when "good" becomes "upcoming".
  static const int _kmSoonThreshold = 1000; // within 1,000 km → upcoming
  static const int _daysSoonThreshold = 30; // within 30 days → upcoming

  final List<MaintenanceRule> rules;

  const MaintenanceEngine({this.rules = DefaultMaintenanceRules.all});

  /// Resolve the rule for a service for this vehicle, honoring the
  /// trim → model → make → global cascade. Most specific match wins.
  MaintenanceRule? _ruleFor(ServiceType type, Vehicle v) {
    MaintenanceRule? best;
    var bestScore = -1;
    for (final r in rules) {
      if (r.type != type) continue;
      var score = 0;
      if (r.make != null) {
        if (r.make != v.make) continue;
        score += 1;
      }
      if (r.model != null) {
        if (r.model != v.model) continue;
        score += 2;
      }
      if (r.trim != null) {
        if (r.trim != v.trim) continue;
        score += 4;
      }
      if (score > bestScore) {
        bestScore = score;
        best = r;
      }
    }
    return best;
  }

  /// Pick the best sourced OEM interval for [type] from the vehicle's matched
  /// entries, preferring the SEVERE figure (Lebanon). Returns null when nothing
  /// sourced maps to this service — the caller then uses the computed rule.
  _OemResolved? _resolveOem(
    List<OemScheduleEntry> matches,
    ServiceType type,
    DrivingSeverity severity,
  ) {
    // Oil filter is serviced with the oil change, so it reuses oil entries.
    final lookupType =
        type == ServiceType.oilFilter ? ServiceType.oilChange : type;

    final candidates =
        matches.where((e) => e.mappedType == lookupType).toList();
    if (candidates.isEmpty) return null;

    // Deterministic, safety-biased ordering: most specific model first, then
    // best source grade, then entries that actually carry a severe figure, then
    // the most conservative (smallest) resulting km.
    int? kmFor(OemScheduleEntry e) => severity == DrivingSeverity.severe
        ? (e.severeKm ?? e.normalKm)
        : (e.normalKm ?? e.severeKm);

    candidates.sort((a, b) {
      final wild = (a.isMakeWide ? 1 : 0).compareTo(b.isMakeWide ? 1 : 0);
      if (wild != 0) return wild;
      final grade = a.grade.index.compareTo(b.grade.index);
      if (grade != 0) return grade;
      final aSevere = (a.severeKm != null || a.severeMonths != null) ? 0 : 1;
      final bSevere = (b.severeKm != null || b.severeMonths != null) ? 0 : 1;
      if (aSevere != bSevere) return aSevere.compareTo(bSevere);
      final ak = kmFor(a) ?? 1 << 30;
      final bk = kmFor(b) ?? 1 << 30;
      return ak.compareTo(bk);
    });

    final best = candidates.first;
    final severe = severity == DrivingSeverity.severe;
    final km = severe ? (best.severeKm ?? best.normalKm) : (best.normalKm ?? best.severeKm);
    final months = severe
        ? (best.severeMonths ?? best.normalMonths)
        : (best.normalMonths ?? best.severeMonths);

    // No usable number for this severity → let the computed rule handle it.
    if (km == null && months == null) return null;

    final usedSevere =
        severe && (best.severeKm != null || best.severeMonths != null);
    return _OemResolved(entry: best, km: km, months: months, usedSevere: usedSevere);
  }

  /// Build the full schedule for a vehicle from its history.
  ///
  /// [severity] selects the factory normal vs. severe interval; it defaults to
  /// [DrivingSeverity.severe] because Lebanese conditions (dust, heat, short
  /// trips, stop-and-go) meet every OEM's "special operating conditions".
  /// [now] is injectable for testability and server/client parity.
  List<ScheduledService> buildSchedule({
    required Vehicle vehicle,
    required List<ServiceRecord> history,
    required DateTime now,
    DrivingSeverity severity = DrivingSeverity.severe,
  }) {
    final result = <ScheduledService>[];

    // Sourced OEM entries for this exact vehicle (computed once). When a service
    // has a matching sourced interval we PREFER it (severe-biased for Lebanon);
    // otherwise we keep the computed make-level rule as the fallback.
    final oemMatches = oemScheduleFor(
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      engine: vehicle.engineType,
      fuel: vehicle.fuelType,
    );

    for (final type in ServiceType.values) {
      // Skip services that don't apply to this fuel type (e.g. a diesel has no
      // spark plugs; an EV has no oil change, plugs, ATF or timing belt).
      if (!_appliesToFuel(type, vehicle.fuelType)) continue;

      final rule = _ruleFor(type, vehicle);
      final oem = _resolveOem(oemMatches, type, severity);

      // No sourced entry AND no computed rule → nothing to schedule.
      if (oem == null && rule == null) continue;

      final int? intervalKm;
      final int? intervalMonths;
      final IntervalBasis basis;
      final String source;
      final OemCitation? citation;

      if (oem != null) {
        // Sourced OEM interval wins, tagged with its source + grade.
        intervalKm = oem.km;
        intervalMonths = oem.months;
        basis = IntervalBasis.factory;
        source = oem.entry.sourceLabel;
        citation = OemCitation(
          sourceLabel: oem.entry.sourceLabel,
          sourceUrl: oem.entry.sourceUrl,
          grade: oem.entry.grade,
          conditionBased: oem.entry.conditionBased,
          serviceLabel: oem.entry.service,
          intervalKm: oem.km,
          intervalMonths: oem.months,
          usedSevere: oem.usedSevere,
        );
      } else {
        // Computed fallback (unchanged behaviour).
        intervalKm = rule!.km(severity);
        intervalMonths = rule.months(severity);
        basis = rule.basis;
        source = rule.source;
        citation = null;
      }

      final last = _latestRecord(history, type);

      int? nextDueOdo;
      int? kmRemaining;
      if (intervalKm != null) {
        // With a record, the next service is one interval after it. Without
        // one, anchor to the FACTORY mileage milestones (multiples of the
        // interval) and assume the most recent milestone has NOT been done —
        // so a used car bought at 100,000 km correctly shows the spark-plug /
        // coolant / timing-belt "major service" as due, not freshly reset.
        if (last != null) {
          nextDueOdo = last.odometerKm + intervalKm;
        } else {
          final odo = vehicle.odometerKm;
          nextDueOdo = odo < intervalKm
              ? intervalKm // first interval not reached yet
              : (odo ~/ intervalKm) * intervalKm; // most recent milestone (due)
        }
        kmRemaining = nextDueOdo - vehicle.odometerKm;
      }

      DateTime? nextDueDate;
      int? daysRemaining;
      if (intervalMonths != null) {
        if (last != null) {
          nextDueDate = _addMonths(last.date, intervalMonths);
        } else {
          // No record: anchor to the model year (best proxy for the car's age)
          // and roll to the most recent due milestone.
          nextDueDate =
              _timeMilestone(DateTime(vehicle.year), intervalMonths, now);
        }
        daysRemaining = nextDueDate.difference(_dateOnly(now)).inDays;
      }

      result.add(ScheduledService(
        type: type,
        lastDoneDate: last?.date,
        lastDoneOdometerKm: last?.odometerKm,
        nextDueOdometerKm: nextDueOdo,
        nextDueDate: nextDueDate,
        kmRemaining: kmRemaining,
        daysRemaining: daysRemaining,
        status: _status(kmRemaining, daysRemaining),
        basis: basis,
        source: source,
        oemCitation: citation,
      ));
    }

    // Sort by urgency: overdue first, then soonest due.
    result.sort((a, b) => _urgency(a).compareTo(_urgency(b)));
    return result;
  }

  /// Overall vehicle health = worst service status.
  HealthStatus overallHealth(List<ScheduledService> schedule) {
    if (schedule.any((s) => s.status == HealthStatus.overdue)) {
      return HealthStatus.overdue;
    }
    if (schedule.any((s) => s.status == HealthStatus.upcoming)) {
      return HealthStatus.upcoming;
    }
    return HealthStatus.good;
  }

  /// The single most urgent service (or null if all good with nothing due).
  ScheduledService? nextService(List<ScheduledService> schedule) =>
      schedule.isEmpty ? null : schedule.first;

  // --- internals ---

  /// Whether a service applies to a given fuel type. Electric and diesel
  /// drivetrains skip engine-specific services they don't have.
  static bool _appliesToFuel(ServiceType type, String? fuel) {
    if (fuel == null) return true;
    final f = fuel.toLowerCase();
    if (f == 'electric') {
      const evExcluded = {
        ServiceType.oilChange,
        ServiceType.oilFilter,
        ServiceType.sparkPlugs,
        ServiceType.airFilter,
        ServiceType.transmissionFluid,
        ServiceType.fuelFilter,
        ServiceType.timingBelt,
        ServiceType.coolant,
      };
      return !evExcluded.contains(type);
    }
    if (f == 'diesel') {
      return type != ServiceType.sparkPlugs; // diesels use glow plugs
    }
    return true; // petrol, hybrid, plug-in hybrid, LPG keep the full schedule
  }

  /// The most recent time-based due date at or before [now], anchored to
  /// [inService]. If the car is younger than one interval, returns the first
  /// upcoming due date instead (so new cars aren't flagged overdue).
  static DateTime _timeMilestone(
      DateTime inService, int intervalMonths, DateTime now) {
    final elapsedMonths =
        (now.year - inService.year) * 12 + (now.month - inService.month);
    final periods = elapsedMonths ~/ intervalMonths;
    return _addMonths(
        inService, (periods == 0 ? 1 : periods) * intervalMonths);
  }

  ServiceRecord? _latestRecord(List<ServiceRecord> history, ServiceType type) {
    ServiceRecord? latest;
    for (final r in history) {
      if (r.type != type) continue;
      if (latest == null || r.date.isAfter(latest.date)) latest = r;
    }
    return latest;
  }

  HealthStatus _status(int? kmRemaining, int? daysRemaining) {
    final overdue = (kmRemaining != null && kmRemaining <= 0) ||
        (daysRemaining != null && daysRemaining <= 0);
    if (overdue) return HealthStatus.overdue;

    final soon = (kmRemaining != null && kmRemaining <= _kmSoonThreshold) ||
        (daysRemaining != null && daysRemaining <= _daysSoonThreshold);
    if (soon) return HealthStatus.upcoming;

    return HealthStatus.good;
  }

  /// Lower = more urgent. Overdue services sort before upcoming, etc.
  double _urgency(ScheduledService s) {
    final ratios = <double>[];
    if (s.kmRemaining != null) {
      ratios.add(s.kmRemaining! / _kmSoonThreshold);
    }
    if (s.daysRemaining != null) {
      ratios.add(s.daysRemaining! / _daysSoonThreshold);
    }
    if (ratios.isEmpty) return double.maxFinite;
    return ratios.reduce((a, b) => a < b ? a : b);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Calendar-correct month addition (clamps day for short months).
  static DateTime _addMonths(DateTime d, int months) {
    final totalMonth = d.month - 1 + months;
    final year = d.year + totalMonth ~/ 12;
    final month = totalMonth % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, d.day > lastDay ? lastDay : d.day);
  }
}

/// A resolved sourced OEM interval chosen for one service.
class _OemResolved {
  final OemScheduleEntry entry;
  final int? km;
  final int? months;
  final bool usedSevere;
  const _OemResolved({
    required this.entry,
    required this.km,
    required this.months,
    required this.usedSevere,
  });
}
