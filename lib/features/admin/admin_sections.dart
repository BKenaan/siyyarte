import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/money.dart';
import '../costs/cost_catalog.dart';
import '../maintenance/models/maintenance_rule.dart';
import '../vehicles/data/spec_repository.dart';
import '../vehicles/data/vehicle_catalog.dart';
import '../vehicles/data/vehicle_specs.dart';
import 'admin_app.dart';

/// --- Catalog: makes / models / trims ---
class CatalogSection extends StatelessWidget {
  const CatalogSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Vehicle catalog',
      subtitle:
          'Makes, models and trims. Edits sync to catalog_makes / catalog_models when Firebase is enabled.',
      child: ListView(
        children: [
          for (final make in AdminData.makes)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: const Icon(Icons.directions_car_filled),
                title: Text(make.name),
                subtitle: Text(make.market),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final model in make.models)
                        Chip(label: Text(model)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// --- Vehicle specs editor (curate trims the VIN/US data misses) ---
class SpecsSection extends ConsumerWidget {
  const SpecsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curated = ref.watch(curatedSpecsProvider);
    return _Section(
      title: 'Vehicle specs',
      subtitle:
          'Curate make/model/year → trim → engine/fuel/transmission. These '
          'layer on top of the built-in seed and the VIN decoder, so the app '
          'tailors factory service to MENA-specific trims.',
      child: Stack(
        children: [
          curated.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (specs) => specs.isEmpty
                ? const Center(
                    child: Text('No curated specs yet. Tap + to add one.'))
                : ListView(
                    children: [
                      for (final s in specs)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.directions_car_filled),
                            title: Text('${s.make} ${s.model}'),
                            subtitle: Text(
                                '${s.yearStart}–${s.yearEnd} · '
                                '${s.trims.map((t) => t.trim).join(", ")}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () =>
                                      _openEditor(context, ref, s),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => ref
                                      .read(specRepositoryProvider)
                                      .delete(s.id!),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton.extended(
              onPressed: () => _openEditor(context, ref, null),
              icon: const Icon(Icons.add),
              label: const Text('Add spec'),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref, ModelSpec? existing) {
    showDialog(
      context: context,
      builder: (_) => _SpecEditor(
        existing: existing,
        onSave: (spec) => ref.read(specRepositoryProvider).upsert(spec),
      ),
    );
  }
}

class _SpecEditor extends StatefulWidget {
  const _SpecEditor({required this.existing, required this.onSave});
  final ModelSpec? existing;
  final Future<void> Function(ModelSpec) onSave;

  @override
  State<_SpecEditor> createState() => _SpecEditorState();
}

class _SpecEditorState extends State<_SpecEditor> {
  late final TextEditingController _make;
  late final TextEditingController _model;
  late final TextEditingController _yearStart;
  late final TextEditingController _yearEnd;
  late List<_TrimRow> _trims;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _make = TextEditingController(text: e?.make ?? '');
    _model = TextEditingController(text: e?.model ?? '');
    _yearStart = TextEditingController(text: e?.yearStart.toString() ?? '');
    _yearEnd = TextEditingController(text: e?.yearEnd.toString() ?? '');
    _trims = (e?.trims ?? const [])
        .map((t) => _TrimRow.fromSpec(t))
        .toList();
    if (_trims.isEmpty) _trims = [_TrimRow()];
  }

  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _yearStart.dispose();
    _yearEnd.dispose();
    for (final t in _trims) {
      t.dispose();
    }
    super.dispose();
  }

  void _save() {
    final spec = ModelSpec(
      _make.text.trim(),
      _model.text.trim(),
      int.tryParse(_yearStart.text) ?? 1990,
      int.tryParse(_yearEnd.text) ?? 2100,
      _trims
          .where((t) => t.trim.text.trim().isNotEmpty)
          .map((t) => t.toSpec())
          .toList(),
      id: widget.existing?.id,
    );
    widget.onSave(spec);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add spec' : 'Edit spec'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: _make,
                          decoration:
                              const InputDecoration(labelText: 'Make'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: _model,
                          decoration:
                              const InputDecoration(labelText: 'Model'))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: _yearStart,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Year from'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: _yearEnd,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Year to'))),
                ],
              ),
              const Divider(height: 24),
              const Align(
                  alignment: Alignment.centerLeft, child: Text('Trims')),
              const SizedBox(height: 8),
              for (var i = 0; i < _trims.length; i++)
                _TrimRowEditor(
                  row: _trims[i],
                  onRemove: _trims.length > 1
                      ? () => setState(() => _trims.removeAt(i).dispose())
                      : null,
                ),
              TextButton.icon(
                onPressed: () => setState(() => _trims.add(_TrimRow())),
                icon: const Icon(Icons.add),
                label: const Text('Add trim'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _TrimRow {
  final TextEditingController trim;
  final TextEditingController engine;
  String fuel;
  String transmission;

  _TrimRow()
      : trim = TextEditingController(),
        engine = TextEditingController(),
        fuel = 'Petrol',
        transmission = 'Automatic';

  _TrimRow.fromSpec(TrimSpec s)
      : trim = TextEditingController(text: s.trim),
        engine = TextEditingController(text: s.engine),
        fuel = s.fuel,
        transmission = s.transmission;

  TrimSpec toSpec() =>
      TrimSpec(trim.text.trim(), engine.text.trim(), fuel, transmission);

  void dispose() {
    trim.dispose();
    engine.dispose();
  }
}

class _TrimRowEditor extends StatefulWidget {
  const _TrimRowEditor({required this.row, required this.onRemove});
  final _TrimRow row;
  final VoidCallback? onRemove;

  @override
  State<_TrimRowEditor> createState() => _TrimRowEditorState();
}

class _TrimRowEditorState extends State<_TrimRowEditor> {
  @override
  Widget build(BuildContext context) {
    final r = widget.row;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
                controller: r.trim,
                decoration: const InputDecoration(labelText: 'Trim')),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
                controller: r.engine,
                decoration: const InputDecoration(labelText: 'Engine')),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 96,
            child: DropdownButtonFormField<String>(
              value: r.fuel,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Fuel'),
              items: VehicleCatalog.fuelTypes
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => setState(() => r.fuel = v ?? r.fuel),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 110,
            child: DropdownButtonFormField<String>(
              value: r.transmission,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Trans.'),
              items: VehicleCatalog.transmissions
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => r.transmission = v ?? r.transmission),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}

/// --- Maintenance intervals (factory) ---
class IntervalsSection extends StatelessWidget {
  const IntervalsSection({super.key});

  String _basis(IntervalBasis b) => switch (b) {
        IntervalBasis.factory => 'Factory',
        IntervalBasis.wearEstimate => 'Estimate',
        IntervalBasis.regulatory => 'Regulatory',
      };

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Maintenance intervals',
      subtitle:
          'Factory-sourced normal/severe intervals. Cascade: trim → model → make → global.',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Scope')),
              DataColumn(label: Text('Service')),
              DataColumn(label: Text('Normal km')),
              DataColumn(label: Text('Severe km')),
              DataColumn(label: Text('Normal mo')),
              DataColumn(label: Text('Severe mo')),
              DataColumn(label: Text('Basis')),
              DataColumn(label: Text('Source')),
            ],
            rows: [
              for (final r in AdminData.rules)
                DataRow(cells: [
                  DataCell(Text(r.make ?? 'Global')),
                  DataCell(Text(r.type.name)),
                  DataCell(Text(r.normalKm?.toString() ?? '—')),
                  DataCell(Text(r.severeKm?.toString() ?? '—')),
                  DataCell(Text(r.normalMonths?.toString() ?? '—')),
                  DataCell(Text(r.severeMonths?.toString() ?? '—')),
                  DataCell(Text(_basis(r.basis))),
                  DataCell(SizedBox(width: 240, child: Text(r.source))),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- Costs (editable, shared with the app) ---
class CostsSection extends ConsumerWidget {
  const CostsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(costCatalogProvider);
    return _Section(
      title: 'Estimated tariffs & costs',
      subtitle: 'Default USD/LBP estimates. Updatable — prices vary widely.',
      child: ListView(
        children: [
          for (final item in items)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item.id),
                trailing: Wrap(
                  spacing: 16,
                  children: [
                    Text(Money.usd(item.usd).formatted()),
                    Text(Money.lbp(item.lbp).formatted()),
                  ],
                ),
                onTap: () => _edit(context, ref, item.id, item.usd, item.lbp),
              ),
            ),
        ],
      ),
    );
  }

  void _edit(BuildContext context, WidgetRef ref, String id, double usd,
      double lbp) {
    final usdCtrl = TextEditingController(text: usd.toStringAsFixed(0));
    final lbpCtrl = TextEditingController(text: lbp.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usdCtrl,
              decoration: const InputDecoration(labelText: 'USD'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lbpCtrl,
              decoration: const InputDecoration(labelText: 'LBP'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(costCatalogProvider.notifier).update(
                    id,
                    usd: double.tryParse(usdCtrl.text),
                    lbp: double.tryParse(lbpCtrl.text),
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// --- Users (admin-only directory) ---
class UsersSection extends StatelessWidget {
  const UsersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Users',
      subtitle:
          'Reads admin_user_index (admin-claim only). Per-user vehicle data stays isolated and is never exposed here.',
      child: Center(
        child: Text(
          'Connect Firebase to list users.\n'
          'Backed by the admin_user_index collection + admin custom claim.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// --- Announcements ---
class AnnouncementsSection extends StatefulWidget {
  const AnnouncementsSection({super.key});
  @override
  State<AnnouncementsSection> createState() => _AnnouncementsSectionState();
}

class _AnnouncementsSectionState extends State<AnnouncementsSection> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Announcements',
      subtitle: 'Publish an app-wide message (writes to announcements + FCM).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Connect Firebase to publish + send FCM')),
            ),
            icon: const Icon(Icons.send),
            label: const Text('Publish'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const Divider(height: 24),
        Expanded(child: child),
      ],
    );
  }
}
