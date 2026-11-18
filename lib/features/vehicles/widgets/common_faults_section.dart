import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/common_faults_repository.dart';
import '../models/common_fault.dart';
import '../models/vehicle.dart';

/// "Common faults" section for the vehicle detail screen: the known issues a
/// specific vehicle is prone to, each as a collapsible, severity-coded card
/// with a cited source. Shows a tasteful empty state when nothing is
/// catalogued for the vehicle.
class CommonFaultsSection extends ConsumerWidget {
  const CommonFaultsSection({super.key, required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final faults = ref.watch(commonFaultsProvider((
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      engine: vehicle.engineType,
    )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.report_problem_outlined,
                size: 20, color: AppColors.accentOrange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(t.commonFaultsTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            if (faults.isNotEmpty)
              Text(t.commonFaultsCount(faults.length),
                  style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 2),
        Text(t.commonFaultsSubtitle,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        if (faults.isEmpty)
          const _EmptyFaults()
        else ...[
          ...faults.map((f) => _FaultCard(fault: f, t: t)),
          const SizedBox(height: 4),
          Text(t.commonFaultsDisclaimer,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _EmptyFaults extends StatelessWidget {
  const _EmptyFaults();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_user_outlined,
                size: 22, color: AppColors.healthGood),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.commonFaultsEmptyTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(t.commonFaultsEmptyBody,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaultCard extends StatelessWidget {
  const _FaultCard({required this.fault, required this.t});
  final CommonFault fault;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final color = fault.severity.color;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Hide the default ExpansionTile divider lines for a cleaner card.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          title: Text(fault.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _SeverityChip(severity: fault.severity, t: t),
          ),
          children: [
            Text(fault.description,
                style: const TextStyle(fontSize: 13.5, height: 1.35)),
            const SizedBox(height: 10),
            _Labelled(
              icon: Icons.warning_amber_rounded,
              label: t.commonFaultsSymptom,
              value: fault.symptom,
            ),
            if (fault.engine != null) ...[
              const SizedBox(height: 8),
              _Labelled(
                icon: Icons.settings_outlined,
                label: t.commonFaultsAffectedEngine,
                value: fault.engine!,
              ),
            ],
            if (fault.typicalMileageKm != null) ...[
              const SizedBox(height: 8),
              _Labelled(
                icon: Icons.speed_outlined,
                label: t.commonFaultsTypicalMileage,
                value:
                    '${NumberFormat.decimalPattern().format(fault.typicalMileageKm)} km',
              ),
            ],
            const SizedBox(height: 12),
            _FaultSourceBadge(source: fault.source, t: t),
          ],
        ),
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.severity, required this.t});
  final FaultSeverity severity;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final color = severity.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 5),
          Text(severity.label(t),
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
              const SizedBox(height: 1),
              Text(value, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tappable citation badge — opens a bottom sheet with the full source and a
/// link, mirroring the verified-spec "Official source" pattern.
class _FaultSourceBadge extends StatelessWidget {
  const _FaultSourceBadge({required this.source, required this.t});
  final FaultSource source;
  final AppLocalizations t;

  Color _tint() =>
      source.type.isOfficial ? AppColors.primaryNavy : AppColors.steel;

  void _showSource(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.fact_check_outlined, color: _tint(), size: 22),
              const SizedBox(width: 8),
              Text(t.commonFaultsSourceSheetTitle,
                  style: Theme.of(ctx).textTheme.titleMedium),
            ]),
            const SizedBox(height: 14),
            _row(t.commonFaultsSource, source.type.label(t)),
            _row('', source.publisher),
            _row('', source.reference),
            const SizedBox(height: 12),
            Text(t.commonFaultsDisclaimer,
                style: Theme.of(ctx).textTheme.bodySmall),
            if (source.hasUrl) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(source.url!),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(t.commonFaultsViewSource),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 90,
                child: Text(k,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12.5))),
            Expanded(child: Text(v, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final color = _tint();
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showSource(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fact_check_outlined, size: 13, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text('${t.commonFaultsSource}: ${source.publisher}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right, size: 13, color: color),
          ],
        ),
      ),
    );
  }
}
