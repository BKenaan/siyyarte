import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/siyyarte_logo.dart';
import '../../l10n/app_localizations.dart';
import 'premium_controller.dart';

/// Siyyarte Plus paywall. Shown when a free user taps a premium feature.
class SiyyartePlusScreen extends ConsumerWidget {
  const SiyyartePlusScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SiyyartePlusScreen()),
    );
  }

  Future<void> _subscribe(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(purchaseServiceProvider);
    if (!service.available) {
      messenger.showSnackBar(SnackBar(content: Text(t.billingComingSoon)));
      return;
    }
    try {
      final ok = await service.purchase();
      if (ok) {
        await ref.read(isPremiumProvider.notifier).setPremium(true);
        if (context.mounted) Navigator.of(context).maybePop();
      } else {
        messenger.showSnackBar(SnackBar(content: Text(t.purchaseFailed)));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.purchaseFailed)));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(purchaseServiceProvider);
    if (!service.available) {
      messenger.showSnackBar(SnackBar(content: Text(t.billingComingSoon)));
      return;
    }
    final ok = await service.restore();
    await ref.read(isPremiumProvider.notifier).setPremium(ok);
    messenger.showSnackBar(
        SnackBar(content: Text(ok ? t.premiumActive : t.premiumFree)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final isPremium = ref.watch(isPremiumProvider);

    final benefits = <(IconData, String)>[
      (Icons.block, t.plusBenefitNoAds),
      (Icons.picture_as_pdf_outlined, t.plusBenefitPassport),
      (Icons.directions_car_outlined, t.plusBenefitUnlimited),
      (Icons.notifications_active_outlined, t.plusBenefitPriority),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          // Hero
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.charcoalGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: AppColors.tailLightRed.withValues(alpha: 0.25)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Column(
              children: [
                const SiyyarteMark(size: 64),
                const SizedBox(height: 14),
                Text(t.siyyartePlus,
                    style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(t.plusTagline,
                    style: const TextStyle(
                        color: AppColors.textSecondaryDark, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Benefits
          ...benefits.map((b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.tailLightRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(b.$1,
                          color: AppColors.tailLightRed, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(b.$2,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    const Icon(Icons.check, color: AppColors.healthGood),
                  ],
                ),
              )),
          const SizedBox(height: 24),

          if (isPremium)
            _ActiveCard(t: t)
          else ...[
            FutureBuilder<String?>(
              future: ref.read(purchaseServiceProvider).priceString(),
              builder: (context, snap) => Center(
                child: Text(snap.data ?? t.plusPrice,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _subscribe(context, ref),
              child: Text(t.subscribe),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _restore(context, ref),
              child: Text(t.restorePurchase),
            ),
            // Debug-only: simulate a purchase to test the gated features.
            if (kDebugMode)
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(isPremiumProvider.notifier).setPremium(true),
                icon: const Icon(Icons.science_outlined),
                label: Text(t.activateTest),
              ),
          ],
          const SizedBox(height: 16),
          Text(
            t.costDisclaimer,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActiveCard extends ConsumerWidget {
  const _ActiveCard({required this.t});
  final AppLocalizations t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.verified, color: AppColors.healthGood),
            title: Text(t.siyyartePlus),
            subtitle: Text(t.premiumActive),
          ),
          if (kDebugMode)
            TextButton(
              onPressed: () =>
                  ref.read(isPremiumProvider.notifier).setPremium(false),
              child: Text(t.deactivateTest),
            ),
        ],
      ),
    );
  }
}
