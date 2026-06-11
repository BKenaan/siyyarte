import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../premium/premium_controller.dart';
import '../../premium/siyyarte_plus_screen.dart';
import '../../maintenance/models/service_record.dart';
import '../../profile/data_export.dart';
import '../../profile/profile_controller.dart';
import '../../profile/profile_setup_screen.dart';
import '../../vehicles/models/vehicle.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final auth = ref.read(authRepositoryProvider);
    final user = ref.watch(profileProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Account ---
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(user?.name ?? t.profile),
                subtitle: Text(user?.email ?? user?.phone ?? ''),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(t.editProfile),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ProfileSetupScreen(isEdit: true))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- Siyyarte Plus ---
        Builder(builder: (context) {
          final isPremium = ref.watch(isPremiumProvider);
          return Card(
            child: ListTile(
              leading: Icon(Icons.workspace_premium_outlined,
                  color: isPremium
                      ? AppColors.healthGood
                      : AppColors.tailLightRed),
              title: Text(t.siyyartePlus),
              subtitle:
                  Text(isPremium ? t.premiumActive : t.premiumFree),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => SiyyartePlusScreen.show(context),
            ),
          );
        }),
        const SizedBox(height: 16),

        // --- Preferences ---
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: Text(t.language),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(t.english)),
                ButtonSegment(value: 'ar', label: Text(t.arabic)),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (s) =>
                  ref.read(localeProvider.notifier).setLocale(s.first),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // --- Data & account ---
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(t.exportData),
                subtitle: Text(t.exportDataBody),
                onTap: () => _exportData(context, ref, user),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(t.logout),
                onTap: auth.signOut,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error),
                title: Text(t.deleteAccountTitle,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(t.costDisclaimer,
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  Future<void> _exportData(
      BuildContext context, WidgetRef ref, user) async {
    if (user == null) return;
    final repo = ref.read(garageRepositoryProvider);
    final vehicles = await repo.watchVehicles().first;
    final data = <VehicleWithHistory>[];
    for (final Vehicle v in vehicles) {
      final List<ServiceRecord> h = await repo.watchHistory(v.id).first;
      data.add((vehicle: v, history: h));
    }
    await AccountDataPdf.export(user, data);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.deleteAccountTitle),
        content: Text(t.deleteAccountWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              ref.read(profileProvider.notifier).clear();
              await ref.read(authRepositoryProvider).deleteAccount();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(t.deleteAccountConfirm),
          ),
        ],
      ),
    );
  }
}
