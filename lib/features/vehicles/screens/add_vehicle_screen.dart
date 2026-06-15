import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/widgets/combo_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../uploads/registration_card_service.dart';
import '../data/garage_repository.dart';
import '../data/spec_repository.dart';
import '../data/vin_transfer_service.dart';
import '../data/vehicle_catalog.dart';
import '../data/vehicle_specs.dart';
import '../data/vin_decoder.dart';
import '../models/vehicle.dart';

/// Guided add/edit vehicle flow. A 3-step Stepper: Identity → Specs → Status.
/// Make and model are editable combos (pick or type) so grey-market imports
/// that aren't in the catalog can still be entered. Pass [vehicle] to edit.
class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key, this.vehicle});
  final Vehicle? vehicle;

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  int _step = 0;

  final _vin = TextEditingController();
  bool _decoding = false;
  final _make = TextEditingController();
  final _model = TextEditingController();
  int? _year;
  final _trim = TextEditingController();
  final _engine = TextEditingController();
  String? _fuel;
  String? _transmission;
  final _odometer = TextEditingController();
  final _plate = TextEditingController();
  DateTime? _insurance;
  DateTime? _inspection;

  // Registration card (دفتر السيارة) — required ownership evidence for new
  // vehicles; the AI reads holder, VIN, make, model and year off it.
  String? _regCardUrl;
  String? _regCardBackUrl;
  String? _regHolder;
  String? _regVin;
  bool _regBusy = false;

  bool get _editing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    // Refresh model suggestions when the make changes; keep the registration
    // tile's VIN-match status live as the VIN field is edited.
    _make.addListener(() => setState(() {}));
    _vin.addListener(() => setState(() {}));
    final v = widget.vehicle;
    if (v != null) {
      _make.text = v.make;
      _model.text = v.model;
      _year = v.year;
      _trim.text = v.trim ?? '';
      _engine.text = v.engineType ?? '';
      _fuel = v.fuelType;
      _transmission = v.transmission;
      _odometer.text = v.odometerKm.toString();
      _plate.text = v.plateNumber ?? '';
      _insurance = v.insuranceExpiry;
      _inspection = v.inspectionExpiry;
      _vin.text = v.vin ?? '';
      _regCardUrl = v.registrationCardUrl;
      _regCardBackUrl = v.registrationCardBackUrl;
      _regHolder = v.regHolderName;
      _regVin = v.regCardVin;
    }
  }

  @override
  void dispose() {
    _vin.dispose();
    _make.dispose();
    _model.dispose();
    _trim.dispose();
    _engine.dispose();
    _odometer.dispose();
    _plate.dispose();
    super.dispose();
  }

  // New vehicles must come with their registration card AND a VIN — the VIN
  // is what stops the same car living in two accounts. Legacy vehicles being
  // edited are exempt (but the tile nags to attach one).
  bool get _canSave =>
      _make.text.trim().isNotEmpty &&
      _model.text.trim().isNotEmpty &&
      _year != null &&
      int.tryParse(_odometer.text) != null &&
      (_editing || (_regCardUrl != null && _vinNorm.isNotEmpty));

  String get _vinNorm =>
      _vin.text.trim().replaceAll(RegExp(r'\s'), '').toUpperCase();

  RegStatus get _regStatus {
    if (_regCardUrl == null) return RegStatus.none;
    if (_regVin != null && _vinNorm.isNotEmpty) {
      return _regVin == _vinNorm ? RegStatus.verified : RegStatus.mismatch;
    }
    return RegStatus.cardOnFile;
  }

  Future<void> _save() async {
    final repo = ref.read(garageRepositoryProvider);
    final existing = widget.vehicle;
    final vehicle = Vehicle(
      id: existing?.id ?? 'v-${DateTime.now().microsecondsSinceEpoch}',
      make: _make.text.trim(),
      model: _model.text.trim(),
      year: _year!,
      trim: _trim.text.trim().isEmpty ? null : _trim.text.trim(),
      engineType: _engine.text.trim().isEmpty ? null : _engine.text.trim(),
      fuelType: _fuel,
      transmission: _transmission,
      odometerKm: int.parse(_odometer.text),
      odometerUpdatedAt: DateTime.now(),
      plateNumber: _plate.text.trim().isEmpty ? null : _plate.text.trim(),
      insuranceExpiry: _insurance,
      inspectionExpiry: _inspection,
      photoUrl: existing?.photoUrl,
      vin: _vinNorm.isEmpty ? null : _vinNorm,
      registrationCardUrl: _regCardUrl,
      registrationCardBackUrl: _regCardBackUrl,
      regHolderName: _regHolder,
      regCardVin: _regVin,
      regStatus: _regStatus,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    try {
      await repo.upsertVehicle(vehicle);
    } on VinAlreadyClaimedException {
      // The car lives in someone else's account — offer the transfer flow.
      if (mounted) _showTransferDialog(vehicle.vin!);
      return;
    }
    ref.read(selectedVehicleIdProvider.notifier).state = vehicle.id;
    if (mounted) Navigator.of(context).pop();
  }

  /// The same car cannot exist in two accounts. If it was sold, the new owner
  /// requests a transfer — the current owner approves by email.
  void _showTransferDialog(String vin) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.swap_horiz_outlined),
        title: const Text('Car already registered'),
        content: Text(
            'A car with VIN $vin is already in another Siyyarte account — the '
            'same car can only live in one account at a time.\n\n'
            'If you bought this car, request an ownership transfer: the '
            'current owner will receive a confirmation email, and once they '
            'approve, you can add the car here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final status = await ref
                    .read(vinTransferServiceProvider)
                    .requestTransfer(vin);
                messenger.showSnackBar(SnackBar(
                    content: Text(switch (status) {
                  'requested' =>
                    'Request sent — the current owner received a confirmation '
                        'email. Try adding the car again once they approve.',
                  'free' =>
                    'The car has been released in the meantime — save again.',
                  'already_yours' =>
                    'This VIN is already registered to your own account.',
                  _ => 'Transfer request status: $status',
                })));
              } catch (e) {
                messenger.showSnackBar(SnackBar(
                    content: Text('Could not request the transfer: $e')));
              }
            },
            child: const Text('Request transfer'),
          ),
        ],
      ),
    );
  }

  /// Attach + AI-read the registration card, FRONT then BACK (the Lebanese
  /// دفتر السيارة spreads its fields across both faces). Auto-fills VIN, make,
  /// model, year and plate from whatever the AI reads.
  Future<void> _captureRegCard() async {
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(registrationCardServiceProvider);

    // Prefer the document scanner (auto edge-detect, de-skew, crop — best OCR
    // input). Camera/gallery remain as fallbacks.
    final mode = await showModalBottomSheet<CardCaptureMode>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: const Text('Scan card'),
              subtitle: const Text(
                  'Best — auto-detects edges, crops and sharpens the card'),
              onTap: () => Navigator.pop(ctx, CardCaptureMode.scan),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, CardCaptureMode.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, CardCaptureMode.gallery),
            ),
          ],
        ),
      ),
    );
    if (mode == null) return; // dismissed

    setState(() => _regBusy = true);
    try {
      // FRONT (required).
      final front = await service.captureAndRead(mode: mode);
      if (front == null) return; // cancelled
      if (front.scanned && !front.looksLikeCard) {
        messenger.showSnackBar(const SnackBar(
            content: Text(
                "This doesn't look like a vehicle registration card — photograph "
                'the دفتر السيارة clearly, showing the holder name and VIN.')));
        return;
      }

      // BACK (recommended, skippable).
      RegCardCapture? back;
      if (mounted) {
        final wantsBack = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Add the back side'),
            content: const Text(
                'Now photograph the BACK of the card — some details (VIN, '
                'model, year) are printed there.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Skip')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Add back side')),
            ],
          ),
        );
        if (wantsBack == true) {
          back = await service.captureAndRead(mode: mode);
        }
      }

      final merged = front.mergeWith(back);
      setState(() {
        _regCardUrl = front.url;
        _regCardBackUrl = back?.url;
        _regHolder = merged.holderName;
        _regVin = merged.vin;
        // Auto-fill everything the card gave us (without clobbering edits).
        if (merged.vin != null && _vin.text.trim().isEmpty) {
          _vin.text = merged.vin!;
        }
        if (merged.plateNumber != null && _plate.text.trim().isEmpty) {
          _plate.text = merged.plateNumber!;
        }
        if (merged.make != null && _make.text.trim().isEmpty) {
          _make.text = merged.make!;
        }
        if (merged.model != null && _model.text.trim().isEmpty) {
          _model.text = merged.model!;
        }
        if (merged.year != null && _year == null) _year = merged.year;
        // Fuel from the card's قوة المحرّك line (بنزين/ديزل), if in the catalog.
        if (merged.fuelType != null &&
            _fuel == null &&
            VehicleCatalog.fuelTypes.contains(merged.fuelType)) {
          _fuel = merged.fuelType;
        }
      });
      _maybeAutoSpec();
      if (!merged.scanned) {
        messenger.showSnackBar(SnackBar(
            content: Text(merged.scanError ??
                'Card saved. Enter the details manually if they did not fill.')));
      }
    } catch (e) {
      messenger
          .showSnackBar(SnackBar(content: Text('Could not attach card: $e')));
    } finally {
      if (mounted) setState(() => _regBusy = false);
    }
  }

  /// When make/model/year identify exactly ONE known factory trim, adopt its
  /// engine/fuel/transmission automatically — the "linked specs" behavior.
  void _maybeAutoSpec() {
    final specs =
        ref.read(modelSpecsProvider).valueOrNull ?? VehicleSpecs.seed;
    final trims = VehicleSpecs.trimsFrom(
        specs, _make.text.trim(), _model.text.trim(), _year);
    if (trims.length != 1) return;
    final spec = trims.single;
    setState(() {
      if (_trim.text.trim().isEmpty) _trim.text = spec.trim;
      if (_engine.text.trim().isEmpty) _engine.text = spec.engine;
      if (_fuel == null && VehicleCatalog.fuelTypes.contains(spec.fuel)) {
        _fuel = spec.fuel;
      }
      if (_transmission == null &&
          VehicleCatalog.transmissions.contains(spec.transmission)) {
        _transmission = spec.transmission;
      }
    });
  }

  /// Decode the VIN with NHTSA vPIC and fill whatever fields it returns.
  Future<void> _decodeVin() async {
    final vin = _vin.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (vin.length < 11) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Enter a full VIN (17 characters)')));
      return;
    }
    setState(() => _decoding = true);
    try {
      final r = await VinDecoder.decode(vin);
      final maxYear = DateTime.now().year + 1;
      setState(() {
        if (r.make != null) _make.text = r.make!;
        if (r.model != null) _model.text = r.model!;
        if (r.year != null && r.year! >= 1990 && r.year! <= maxYear) {
          _year = r.year;
        }
        if (r.trim != null) _trim.text = r.trim!;
        if (r.engine != null) _engine.text = r.engine!;
        if (r.fuel != null) _fuel = r.fuel;
        if (r.transmission != null) _transmission = r.transmission;
      });
      _maybeAutoSpec();
      messenger.showSnackBar(
          const SnackBar(content: Text('Specs loaded from VIN ✓')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('VIN lookup failed: $e')));
    } finally {
      if (mounted) setState(() => _decoding = false);
    }
  }

  /// Auto-fill engine / fuel / transmission from the factory spec for a trim.
  void _applyTrim(String trimName) {
    final specs =
        ref.read(modelSpecsProvider).valueOrNull ?? VehicleSpecs.seed;
    final spec = VehicleSpecs.specFrom(
        specs, _make.text.trim(), _model.text.trim(), _year, trimName);
    if (spec == null) return;
    setState(() {
      _engine.text = spec.engine;
      // Only adopt curated values the dropdowns can actually show, else the
      // Step-2 DropdownButtonFormField asserts on an off-list value.
      if (VehicleCatalog.fuelTypes.contains(spec.fuel)) _fuel = spec.fuel;
      if (VehicleCatalog.transmissions.contains(spec.transmission)) {
        _transmission = spec.transmission;
      }
    });
  }

  Future<DateTime?> _pickDate(DateTime? initial) => showDatePicker(
        context: context,
        initialDate: initial ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final year = DateTime.now().year;
    // Model suggestions follow the make (empty/unknown make still allows typing).
    final modelOptions = VehicleCatalog.modelsFor(_make.text.trim());
    // Known factory trims (seed + admin-curated) for this make/model/year.
    final specs =
        ref.watch(modelSpecsProvider).valueOrNull ?? VehicleSpecs.seed;
    final knownTrims = VehicleSpecs.trimsFrom(
        specs, _make.text.trim(), _model.text.trim(), _year);

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? t.editVehicle : t.addVehicle)),
      body: Stepper(
        currentStep: _step,
        onStepTapped: (s) => setState(() => _step = s),
        onStepContinue: () {
          if (_step < 2) {
            setState(() => _step++);
          } else if (_canSave) {
            _save();
          } else {
            // Say WHY save is blocked instead of doing nothing.
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(!_editing && _regCardUrl == null
                    ? 'Attach the vehicle registration card (step 1) — '
                        'required for every new vehicle.'
                    : !_editing && _vinNorm.isEmpty
                        ? 'Enter the VIN (chassis number) from the '
                            'registration card — required for every new vehicle.'
                        : 'Fill in make, model, year and odometer first.')));
          }
        },
        onStepCancel: _step == 0 ? null : () => setState(() => _step--),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              // Expanded gives the full-width themed button a bounded width
              // inside this Row (otherwise its min width is infinite).
              Expanded(
                child: FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(_step == 2 ? t.save : t.next),
                ),
              ),
              if (_step > 0) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(t.cancel),
                ),
              ],
            ],
          ),
        ),
        steps: [
          Step(
            title: Text(t.make),
            isActive: _step >= 0,
            content: Column(
              children: [
                // Ownership evidence first: the registration card is required
                // for every new vehicle, and scanning it fills VIN + plate.
                _RegCardTile(
                  url: _regCardUrl,
                  holder: _regHolder,
                  status: _regStatus,
                  isRequired: !_editing,
                  busy: _regBusy,
                  onAttach: _captureRegCard,
                ),
                const SizedBox(height: 12),
                // VIN decode — the fast path: fills make/model/year/trim/
                // engine/fuel/transmission for (almost) any vehicle.
                TextField(
                  controller: _vin,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: _editing
                        ? 'VIN (auto-fills specs)'
                        : 'VIN — required, as printed on the card',
                    hintText: '17-character chassis number',
                    prefixIcon: const Icon(Icons.qr_code_2_outlined),
                    suffixIcon: _decoding
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _decodeVin,
                          ),
                  ),
                  onSubmitted: (_) => _decodeVin(),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                ComboField(
                  controller: _make,
                  label: t.make,
                  options: VehicleCatalog.makeNames(),
                  onSelected: (_) => _model.clear(),
                ),
                const SizedBox(height: 16),
                ComboField(
                  controller: _model,
                  label: t.model,
                  options: modelOptions,
                  onSelected: (_) => _maybeAutoSpec(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _year,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: t.year),
                  items: [
                    for (var y = year + 1; y >= 1990; y--)
                      DropdownMenuItem(value: y, child: Text('$y')),
                    // Keep an out-of-range stored year (classic/imported car)
                    // selectable so the dropdown doesn't assert.
                    if (_year != null && (_year! > year + 1 || _year! < 1990))
                      DropdownMenuItem(value: _year, child: Text('${_year!}')),
                  ],
                  onChanged: (v) {
                    setState(() => _year = v);
                    _maybeAutoSpec();
                  },
                ),
                const SizedBox(height: 16),
                // Known trims → pick to auto-fill specs; otherwise free text.
                if (knownTrims.isNotEmpty)
                  ComboField(
                    controller: _trim,
                    label: t.trim,
                    options: knownTrims.map((e) => e.trim).toList(),
                    onSelected: _applyTrim,
                  )
                else
                  TextField(
                    controller: _trim,
                    decoration: InputDecoration(
                        labelText: '${t.trim} (${t.optional})'),
                  ),
                if (knownTrims.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_outlined, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Engine, fuel & transmission auto-fill from the factory spec.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Step(
            title: Text(t.engineType),
            isActive: _step >= 1,
            content: Column(
              children: [
                TextField(
                  controller: _engine,
                  decoration: InputDecoration(
                      labelText: '${t.engineType} (${t.optional})',
                      hintText: '1.6L I4'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _fuel,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: t.fuelType),
                  items: VehicleCatalog.fuelTypes
                      .map((f) =>
                          DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() => _fuel = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _transmission,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: t.transmission),
                  items: VehicleCatalog.transmissions
                      .map((tr) =>
                          DropdownMenuItem(value: tr, child: Text(tr)))
                      .toList(),
                  onChanged: (v) => setState(() => _transmission = v),
                ),
              ],
            ),
          ),
          Step(
            title: Text(t.odometer),
            isActive: _step >= 2,
            content: Column(
              children: [
                TextField(
                  controller: _odometer,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: '${t.odometer} (km)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _plate,
                  decoration: InputDecoration(
                      labelText: '${t.plateNumber} (${t.optional})'),
                ),
                const SizedBox(height: 12),
                _DateRow(
                  label: t.insuranceExpiry,
                  value: _insurance,
                  onPick: () async {
                    final d = await _pickDate(_insurance);
                    if (d != null) setState(() => _insurance = d);
                  },
                ),
                _DateRow(
                  label: t.inspectionExpiry,
                  value: _inspection,
                  onPick: () async {
                    final d = await _pickDate(_inspection);
                    if (d != null) setState(() => _inspection = d);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "registration card" requirement tile. Shows attach state and the
/// holder/VIN verification outcome so fraud signals are visible immediately.
class _RegCardTile extends StatelessWidget {
  const _RegCardTile({
    required this.url,
    required this.holder,
    required this.status,
    required this.isRequired,
    required this.busy,
    required this.onAttach,
  });

  final String? url;
  final String? holder;
  final RegStatus status;
  final bool isRequired;
  final bool busy;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, color, text) = switch (status) {
      RegStatus.none => (
          Icons.badge_outlined,
          isRequired ? cs.error : cs.onSurfaceVariant,
          'Photo of the registration card (دفتر السيارة) showing the holder '
              'name and VIN${isRequired ? ' — required' : ''}.',
        ),
      RegStatus.cardOnFile => (
          Icons.task_outlined,
          cs.onSurfaceVariant,
          holder == null
              ? 'Card on file (not yet machine-verified).'
              : 'Card on file — holder: $holder.',
        ),
      RegStatus.verified => (
          Icons.verified_outlined,
          Colors.green.shade700,
          'Verified — ${holder ?? 'holder on card'}; VIN on card matches.',
        ),
      RegStatus.mismatch => (
          Icons.report_outlined,
          cs.error,
          'VIN on the card does NOT match the VIN entered — double-check.',
        ),
    };

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: status == RegStatus.mismatch ? cs.error : cs.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: const Text('Registration card'),
        subtitle: Text(text, style: TextStyle(color: color, fontSize: 12)),
        trailing: busy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : TextButton(
                onPressed: onAttach,
                child: Text(url == null ? 'Attach' : 'Replace'),
              ),
        onTap: busy ? null : onAttach,
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow(
      {required this.label, required this.value, required this.onPick});
  final String label;
  final DateTime? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(label),
      subtitle: Text(value == null
          ? '—'
          : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'),
      trailing: const Icon(Icons.edit_calendar_outlined),
      onTap: onPick,
    );
  }
}
