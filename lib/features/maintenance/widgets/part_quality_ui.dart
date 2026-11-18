import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/service_record.dart';

/// Presentation helpers for [PartQuality]: localized label, icon and a color
/// that signals the grade (green = original, blue = good aftermarket,
/// amber = cheap commercial-market part).
extension PartQualityUi on PartQuality {
  String label(AppLocalizations t) => switch (this) {
        PartQuality.oemGenuine => t.partQualityOem,
        PartQuality.qualityAftermarket => t.partQualityAftermarket,
        PartQuality.tijariye => t.partQualityTijariye,
      };

  IconData get icon => switch (this) {
        PartQuality.oemGenuine => Icons.verified_outlined,
        PartQuality.qualityAftermarket => Icons.thumb_up_outlined,
        PartQuality.tijariye => Icons.savings_outlined,
      };

  MaterialColor get color => switch (this) {
        PartQuality.oemGenuine => Colors.green,
        PartQuality.qualityAftermarket => Colors.blue,
        PartQuality.tijariye => Colors.amber,
      };
}

/// Small labeled chip shown in the service-history timeline entry.
class PartQualityChip extends StatelessWidget {
  const PartQualityChip({super.key, required this.quality});

  final PartQuality quality;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final color = quality.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(quality.icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            quality.label(t),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
