import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../models/maintenance_rule.dart';
import '../models/scheduled_service.dart';

/// Shared UI helpers for rendering schedule status and interval provenance.
extension HealthStatusUi on HealthStatus {
  Color get color => switch (this) {
        HealthStatus.good => AppColors.healthGood,
        HealthStatus.upcoming => AppColors.healthUpcoming,
        HealthStatus.overdue => AppColors.healthOverdue,
      };
}

extension IntervalBasisUi on IntervalBasis {
  String label(AppLocalizations t) => switch (this) {
        IntervalBasis.factory => t.factoryBased,
        IntervalBasis.wearEstimate => t.estimateBasis,
        IntervalBasis.regulatory => t.regulatoryBasis,
      };

  IconData get icon => switch (this) {
        IntervalBasis.factory => Icons.verified_outlined,
        IntervalBasis.wearEstimate => Icons.straighten_outlined,
        IntervalBasis.regulatory => Icons.gavel_outlined,
      };
}

/// Localized "due in X km" / "due {date}" subtitle for a scheduled service.
String dueSubtitle(ScheduledService s, AppLocalizations t) {
  final km = s.kmRemaining;
  if (km != null) {
    return km <= 0 ? t.overdueByKm(-km) : t.dueInKm(km);
  }
  final d = s.nextDueDate;
  if (d != null) {
    return t.dueOn(
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
  }
  return '';
}
