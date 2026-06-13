import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../maintenance/models/service_type.dart';
import 'verified_spec.dart';

/// Maps an app ServiceType to the verified-interval item name(s) used in the
/// dataset, so a computed schedule row can be matched to its official source.
const Map<ServiceType, List<String>> kServiceToVerifiedItem = {
  ServiceType.oilChange: ['Engine Oil & Filter', 'Engine Oil'],
  ServiceType.oilFilter: ['Engine Oil & Filter', 'Oil Filter'],
  ServiceType.airFilter: ['Engine Air Filter', 'Air Filter'],
  ServiceType.sparkPlugs: ['Spark Plugs'],
  ServiceType.coolant: ['Engine Coolant', 'Coolant'],
  ServiceType.transmissionFluid: [
    'Transmission Fluid (CVT)',
    'Transmission Fluid',
    'Transmission'
  ],
  ServiceType.timingBelt: ['Timing Belt', 'Timing Belt/Chain'],
};

VerifiedInterval? matchInterval(VerifiedSpec? spec, ServiceType type) {
  if (spec == null) return null;
  final names = kServiceToVerifiedItem[type];
  if (names == null) return null;
  for (final iv in spec.maintenance) {
    for (final n in names) {
      if (iv.item.toLowerCase() == n.toLowerCase()) return iv;
    }
  }
  return null;
}

/// Small green "✓ Verified" pill with the market scope, tappable to open the
/// source citation. Use ONLY on values that are genuinely verified Grade-A.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    super.key,
    required this.marketScope,
    this.sourceDoc,
    this.sourcePage,
    this.sourceUrl,
    this.publisher,
    this.verifiedDate = '2026-06-12',
  });
  final String marketScope;
  final String? sourceDoc;
  final String? sourcePage;
  final String? sourceUrl;
  final String? publisher;
  final String verifiedDate;

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
              const Icon(Icons.verified, color: AppColors.healthGood, size: 22),
              const SizedBox(width: 8),
              Text('Official source',
                  style: Theme.of(ctx).textTheme.titleMedium),
            ]),
            const SizedBox(height: 14),
            _row('Source', sourceDoc ?? '—'),
            if (publisher != null) _row('Publisher', publisher!),
            _row('Page / section', sourcePage ?? '—'),
            _row('Market', marketScope),
            _row('Verified', '$verifiedDate · Grade A (official manufacturer)'),
            const SizedBox(height: 14),
            Text(
              'From the official $marketScope owner’s manual. Siyyarte shows '
              'maintenance and fluid data only from official manufacturer sources.',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            if (sourceUrl != null && sourceUrl!.startsWith('http')) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(sourceUrl!),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('View source document'),
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
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12.5))),
            Expanded(child: Text(v, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showSource(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.healthGood.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, size: 13, color: AppColors.healthGood),
            const SizedBox(width: 4),
            Text('Verified · $marketScope',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.healthGood)),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right,
                size: 13, color: AppColors.healthGood),
          ],
        ),
      ),
    );
  }
}

/// Neutral "General schedule" label for computed (non-verified) values.
class GeneralScheduleNote extends StatelessWidget {
  const GeneralScheduleNote({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calculate_outlined,
            size: 13, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 4),
        Flexible(
          child: Text('General schedule — not manufacturer-verified for this car',
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

/// "Manufacturer-verified specs" card: cited fluids + key attributes for the
/// resolved market. Only verified values appear here (golden rule).
class VerifiedSpecsCard extends StatelessWidget {
  const VerifiedSpecsCard(
      {super.key, required this.spec, this.marketAmbiguous = false});
  final VerifiedSpec spec;
  final bool marketAmbiguous;

  @override
  Widget build(BuildContext context) {
    final fields = [...spec.fluids, ...spec.attributes]
        .where((f) => (f.value ?? '').isNotEmpty)
        .toList();
    if (fields.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.verified, color: AppColors.healthGood, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Manufacturer-verified specs',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.primaryNavy.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(spec.marketScope,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy)),
              ),
            ]),
            if (marketAmbiguous)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Showing ${spec.marketScope} values. Values differ for '
                  'US-import vs GCC — confirm your car’s market if unsure.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 6),
            ...fields.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 96,
                            child: Text(f.label,
                                style: const TextStyle(
                                    fontSize: 12.5, color: Colors.grey)),
                          ),
                          Expanded(
                            child: Text(f.value ?? '',
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 96),
                          child: f.hasCitation
                              ? VerifiedBadge(
                                  marketScope: spec.marketScope,
                                  sourceDoc: f.sourceDoc,
                                  sourcePage: f.sourcePage,
                                  sourceUrl: f.sourceUrl,
                                  publisher: f.publisher,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 20),
            Text(
              'Tap any “Verified” badge to view the official source and page. '
              'Siyyarte is a reference, not a replacement for your owner’s '
              'manual or a qualified mechanic.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
