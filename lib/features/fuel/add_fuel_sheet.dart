import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics.dart';
import '../../core/constants/lebanon.dart';
import '../../core/models/money.dart';
import '../../core/providers.dart';
import '../maintenance/models/service_record.dart';
import '../maintenance/models/service_type.dart';
import '../profile/profile_controller.dart';

/// Quick "log a fuel fill-up" sheet. Captures odometer, litres, price and the
/// full-tank flag (full-tank is what enables consumption tracking).
class AddFuelSheet extends ConsumerStatefulWidget {
  const AddFuelSheet(
      {super.key, required this.vehicleId, required this.currentOdometerKm});
  final String vehicleId;
  final int currentOdometerKm;

  static Future<void> show(BuildContext context,
      {required String vehicleId, required int currentOdometerKm}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddFuelSheet(
          vehicleId: vehicleId, currentOdometerKm: currentOdometerKm),
    );
  }

  @override
  ConsumerState<AddFuelSheet> createState() => _AddFuelSheetState();
}

class _AddFuelSheetState extends ConsumerState<AddFuelSheet> {
  late final TextEditingController _odometer =
      TextEditingController(text: widget.currentOdometerKm.toString());
  final _liters = TextEditingController();
  final _price = TextEditingController();
  final _station = TextEditingController();
  late Currency _currency;
  bool _fullTank = true;
  DateTime _date = DateTime.now();
  bool _busy = false;
  bool _curInit = false;

  @override
  void dispose() {
    _odometer.dispose();
    _liters.dispose();
    _price.dispose();
    _station.dispose();
    super.dispose();
  }

  bool get _valid =>
      (int.tryParse(_odometer.text) ?? -1) >= 0 &&
      (double.tryParse(_liters.text) ?? 0) > 0;

  Future<void> _save() async {
    final km = int.tryParse(_odometer.text);
    final liters = double.tryParse(_liters.text);
    if (km == null || liters == null) return;
    setState(() => _busy = true);
    final price = double.tryParse(_price.text);
    final record = ServiceRecord(
      id: 'f-${DateTime.now().microsecondsSinceEpoch}',
      vehicleId: widget.vehicleId,
      type: ServiceType.fuel,
      date: _date,
      odometerKm: km,
      garageName: _station.text.trim().isEmpty ? null : _station.text.trim(),
      cost: price != null ? Money(price, _currency) : null,
      liters: liters,
      fullTank: _fullTank,
      createdAt: DateTime.now(),
    );
    try {
      await ref.read(garageRepositoryProvider).addServiceRecord(record);
      Analytics.logFuel();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default the currency to the user's preference (once).
    if (!_curInit) {
      _currency =
          ref.read(profileProvider)?.preferredCurrency ?? Currency.usd;
      _curInit = true;
    }
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Icon(Icons.local_gas_station_outlined),
            const SizedBox(width: 8),
            Text('Log fuel fill-up',
                style: Theme.of(context).textTheme.titleMedium),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _odometer,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Odometer (km)', prefixIcon: Icon(Icons.speed)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _liters,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: 'Litres added',
                prefixIcon: Icon(Icons.water_drop_outlined)),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _price,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Total price',
                    prefixIcon: Icon(Icons.payments_outlined)),
              ),
            ),
            const SizedBox(width: 10),
            SegmentedButton<Currency>(
              segments: const [
                ButtonSegment(value: Currency.usd, label: Text('USD')),
                ButtonSegment(value: Currency.lbp, label: Text('LBP')),
              ],
              selected: {_currency},
              onSelectionChanged: (s) => setState(() => _currency = s.first),
            ),
          ]),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _fullTank,
            onChanged: (v) => setState(() => _fullTank = v),
            title: const Text('Filled the tank full'),
            subtitle: const Text(
                'Keep on for accurate fuel-economy (L/100km) tracking'),
          ),
          TextField(
            controller: _station,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                labelText: 'Station (optional)',
                prefixIcon: Icon(Icons.store_outlined)),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: (_valid && !_busy) ? _save : null,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save fill-up'),
          ),
        ],
      ),
    );
  }
}
