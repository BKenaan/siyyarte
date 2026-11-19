import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../models/oem_citation.dart';

/// Tappable citation badge for a schedule row backed by a SOURCED OEM interval.
/// Mirrors the verified-spec / common-faults citation pattern: a small pill that
/// opens a bottom sheet with the interval, source + confidence grade, a
/// condition-based note where relevant, and a link to the source document.
class OemSourceBadge extends StatelessWidget {
  const OemSourceBadge({super.key, required this.citation});
  final OemCitation citation;

  static String _intervalText(OemCitation c, AppLocalizations t) {
    final parts = <String>[];
    if (c.intervalKm != null) {
      parts.add('${NumberFormat.decimalPattern().format(c.intervalKm)} km');
    }
    if (c.intervalMonths != null) {
      parts.add('${c.intervalMonths} ${_moLabel(c.intervalMonths!)}');
    }
    return parts.isEmpty ? '—' : parts.join(' / ');
  }

  static String _moLabel(int months) => months % 12 == 0 && months >= 12
      ? '${months ~/ 12} yr'
      : 'mo';

  String _gradeText(AppLocalizations t) => switch (citation.grade) {
        OemSourceGrade.a => t.oemScheduleGradeA,
        OemSourceGrade.b => t.oemScheduleGradeB,
        OemSourceGrade.c => t.oemScheduleGradeC,
        OemSourceGrade.d => t.oemScheduleGradeD,
      };

  void _showSource(BuildContext context) {
    final t = AppLocalizations.of(context);
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
              const Icon(Icons.verified_outlined,
                  color: AppColors.primaryNavy, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(t.oemScheduleSheetTitle,
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
            ]),
            const SizedBox(height: 14),
            _row(t.oemScheduleServiceItem, citation.serviceLabel),
            _row(
              t.oemScheduleIntervalLabel,
              '${_intervalText(citation, t)}'
              '${citation.usedSevere ? ' · ${t.oemScheduleSevereNote}' : ''}',
            ),
            _row(t.oemScheduleGradeLabel, _gradeText(t)),
            _row(t.oemScheduleSourceField, citation.sourceLabel),
            if (citation.conditionBased) ...[
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.tune_outlined,
                    size: 16, color: AppColors.accentOrange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(t.oemScheduleConditionBasedNote,
                      style: Theme.of(ctx).textTheme.bodySmall),
                ),
              ]),
            ],
            const SizedBox(height: 12),
            Text(t.oemScheduleDisclaimer,
                style: Theme.of(ctx).textTheme.bodySmall),
            if (citation.sourceUrl != null &&
                citation.sourceUrl!.startsWith('http')) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(citation.sourceUrl!),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(t.oemScheduleViewSource),
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
                width: 110,
                child: Text(k,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12.5))),
            Expanded(child: Text(v, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const color = AppColors.primaryNavy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The concrete interval, always a number — never "varies".
        Text(
          '${t.oemScheduleIntervalLabel}: ${_intervalText(citation, t)}'
          '${citation.usedSevere ? ' · ${t.oemScheduleSevereNote}' : ''}',
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showSource(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_outlined,
                        size: 13, color: color),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '${t.oemScheduleBadge} · ${citation.grade.letter}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right, size: 13, color: color),
                  ],
                ),
              ),
            ),
            if (citation.conditionBased)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune_outlined,
                        size: 12, color: AppColors.accentOrange),
                    const SizedBox(width: 4),
                    Text(t.oemScheduleConditionBased,
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentOrange)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
