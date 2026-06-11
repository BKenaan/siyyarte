import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/lebanon.dart';
import '../../l10n/app_localizations.dart';
import 'profile_controller.dart';

/// First-run profile setup (name, city, currency). Also reused for editing —
/// pass [isEdit] true to show a back button instead of the onboarding framing.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key, this.isEdit = false});
  final bool isEdit;

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _name;
  String? _city;
  Currency _currency = Currency.usd;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider);
    _name = TextEditingController(text: user?.name ?? '');
    _city = user?.city;
    _currency = user?.preferredCurrency ?? Currency.usd;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canSave => _name.text.trim().isNotEmpty && _city != null;

  void _save() {
    ref.read(profileProvider.notifier).save(
          name: _name.text.trim(),
          city: _city,
          currency: _currency,
        );
    if (widget.isEdit && mounted) Navigator.of(context).pop();
    // In setup mode the root router rebuilds and advances to the home shell.
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: widget.isEdit ? AppBar(title: Text(t.editProfile)) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.isEdit) ...[
                const SizedBox(height: 16),
                Text(t.profileSetup,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(t.profileSetupBody,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
              ],
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: t.fullName),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _city,
                isExpanded: true,
                decoration: InputDecoration(labelText: t.selectCity),
                items: Lebanon.cities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _city = v),
              ),
              const SizedBox(height: 16),
              Text(t.preferredCurrency,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<Currency>(
                segments: const [
                  ButtonSegment(value: Currency.usd, label: Text('USD \$')),
                  ButtonSegment(value: Currency.lbp, label: Text('LBP L.L.')),
                ],
                selected: {_currency},
                onSelectionChanged: (s) =>
                    setState(() => _currency = s.first),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _canSave ? _save : null,
                child: Text(widget.isEdit ? t.save : t.finish),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
