import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/lebanon.dart';
import '../../../core/models/money.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../uploads/ai_scan_service.dart';
import '../../uploads/invoice_storage.dart';
import '../models/service_record.dart';
import '../models/service_type.dart';
import '../widgets/part_quality_ui.dart';

/// Bottom sheet to record a completed service. Writing the record causes the
/// engine to recompute the next-due mileage/date automatically.
class MarkServiceDoneSheet extends ConsumerStatefulWidget {
  const MarkServiceDoneSheet({
    super.key,
    required this.vehicleId,
    required this.type,
    required this.currentOdometerKm,
  });

  final String vehicleId;
  final ServiceType type;
  final int currentOdometerKm;

  static Future<void> show(
    BuildContext context, {
    required String vehicleId,
    required ServiceType type,
    required int currentOdometerKm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) => Padding(
        // Read from the sheet's own context so the panel lifts reactively as
        // the keyboard animates (the outer context's inset never updates).
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: MarkServiceDoneSheet(
          vehicleId: vehicleId,
          type: type,
          currentOdometerKm: currentOdometerKm,
        ),
      ),
    );
  }

  @override
  ConsumerState<MarkServiceDoneSheet> createState() =>
      _MarkServiceDoneSheetState();
}

class _MarkServiceDoneSheetState extends ConsumerState<MarkServiceDoneSheet> {
  late final TextEditingController _odometer =
      TextEditingController(text: widget.currentOdometerKm.toString());
  final _garage = TextEditingController();
  final _cost = TextEditingController();
  final _notes = TextEditingController();
  Currency _currency = Currency.usd;
  PartQuality? _partQuality; // optional grade of the part used
  DateTime _date = DateTime.now();
  String? _invoiceUrl;
  bool _busy = false;
  bool _scanning = false;
  bool _scanned = false; // data was read from a photographed invoice (evidence)

  Future<void> _scanInvoice() async {
    setState(() => _scanning = true);
    try {
      final data = await ref.read(aiScanServiceProvider).scanInvoice();
      if (data == null) return; // cancelled
      setState(() {
        _scanned = true; // record is backed by a photographed invoice
        final d = data['date'];
        if (d is String) {
          final dt = DateTime.tryParse(d);
          if (dt != null) _date = dt;
        }
        final odo = data['odometerKm'];
        if (odo is num) _odometer.text = odo.toInt().toString();
        final g = data['garageName'];
        if (g is String && g.isNotEmpty) _garage.text = g;
        final amt = data['amount'];
        if (amt is num) {
          _cost.text = amt == amt.roundToDouble()
              ? amt.toInt().toString()
              : amt.toString();
        }
        final cur = data['currency'];
        if (cur == 'LBP') _currency = Currency.lbp;
        if (cur == 'USD') _currency = Currency.usd;
        final n = data['notes'];
        if (n is String && n.isNotEmpty) _notes.text = n;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).scanFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  void dispose() {
    _odometer.dispose();
    _garage.dispose();
    _cost.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final odo = int.tryParse(_odometer.text);
    if (odo == null) return;
    setState(() => _busy = true);

    final costValue = double.tryParse(_cost.text);
    final record = ServiceRecord(
      id: 'r-${DateTime.now().microsecondsSinceEpoch}',
      vehicleId: widget.vehicleId,
      type: widget.type,
      date: _date,
      odometerKm: odo,
      garageName: _garage.text.trim().isEmpty ? null : _garage.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      cost: costValue == null ? null : Money(costValue, _currency),
      invoiceUrl: _invoiceUrl,
      source: _scanned
          ? RecordSource.invoiceScan
          : (_invoiceUrl != null
              ? RecordSource.invoicePhoto
              : RecordSource.manual),
      partQuality: _partQuality,
      createdAt: DateTime.now(),
    );

    await ref.read(garageRepositoryProvider).addServiceRecord(record);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(widget.type.icon),
                const SizedBox(width: 10),
                Text(widget.type.label(t),
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            if (ref.read(aiScanServiceProvider).available) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: (_busy || _scanning) ? null : _scanInvoice,
                icon: _scanning
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.document_scanner_outlined),
                label: Text(_scanning ? t.scanning : t.scanInvoice),
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(t.serviceDate),
              subtitle: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            TextField(
              controller: _odometer,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(labelText: '${t.odometer} (km)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _garage,
              decoration: InputDecoration(
                  labelText: '${t.garageName} (${t.optional})'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cost,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: '${t.cost} (${t.optional})'),
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<Currency>(
                  segments: const [
                    ButtonSegment(value: Currency.usd, label: Text('USD')),
                    ButtonSegment(value: Currency.lbp, label: Text('LBP')),
                  ],
                  selected: {_currency},
                  onSelectionChanged: (s) =>
                      setState(() => _currency = s.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: InputDecoration(
                  labelText: '${t.notes} (${t.optional})'),
            ),
            // Part-quality grade — only relevant when an actual part/service is
            // being logged, not for pure operating costs (fuel, parking, ...).
            if (!kExpenseTypes.contains(widget.type)) ...[
              const SizedBox(height: 16),
              Text('${t.partQualityLabel} (${t.optional})',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<PartQuality>(
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                segments: [
                  for (final q in PartQuality.values)
                    ButtonSegment(
                      value: q,
                      icon: Icon(q.icon, color: q.color),
                      label: Text(q.label(t)),
                    ),
                ],
                selected: _partQuality == null ? const {} : {_partQuality!},
                onSelectionChanged: (s) => setState(
                    () => _partQuality = s.isEmpty ? null : s.first),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () async {
                      final url = await ref
                          .read(invoiceStorageProvider)
                          .pickAndUpload();
                      if (url != null) setState(() => _invoiceUrl = url);
                    },
              icon: Icon(_invoiceUrl == null
                  ? Icons.photo_camera_outlined
                  : Icons.check_circle_outline),
              label: Text(_invoiceUrl == null
                  ? t.attachInvoice
                  : '${t.attachInvoice} ✓'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(t.markDone),
            ),
          ],
        ),
      ),
    );
  }
}
