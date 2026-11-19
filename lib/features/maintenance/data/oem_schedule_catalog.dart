// Canonical OEM maintenance-schedule catalog + adapter layer.
//
// The repo ships FIVE sourced research datasets, each of which REDEFINES its own
// `OemGrade` / `OemSeverity` / `OemInterval` / `OemModelSchedule` (or
// `OemSchedule`) types with slightly different fields:
//
//   * oem_schedules_japanese.dart   — kOemJapaneseSchedules   (OemModelSchedule,
//       has firstKm, no conditionBased)
//   * oem_schedules_japanese2.dart  — kOemJapaneseSchedules2  (OemModelSchedule,
//       has firstKm, schedule-level conditionBased)
//   * oem_schedules_chinese.dart    — kOemChineseSchedules    (OemModelSchedule,
//       has firstKm, INTERVAL-level conditionBased)
//   * oem_schedules_german_american.dart — kOemSchedulesGermanAmerican
//       (OemSchedule, no firstKm, schedule-level conditionBased, non-null fuel)
//   * oem_schedules_euro_american_extra.dart — kOemSchedulesEuroAmericanExtra
//       (OemSchedule, no firstKm, schedule-level conditionBased, non-null fuel)
//
// This file imports all five with prefixes and reconciles them into a single
// [OemScheduleEntry] shape, then exposes [oemScheduleFor] for loose make/model/
// year + engine/fuel matching (same spirit as the common-faults matcher). The
// DATA FILES ARE NEVER EDITED here — other agents append entries to them, and
// this adapter simply reads whatever each exported list currently contains.
//
// SAFETY: nothing is fabricated. Every entry carries the source's own cited
// provenance + confidence grade. Where a source omits a dimension it stays null,
// and the engine falls back to the generic computed schedule.
library;

import '../models/oem_citation.dart';
import '../models/service_type.dart';

import 'oem_schedules_japanese.dart' as jp1;
import 'oem_schedules_japanese2.dart' as jp2;
import 'oem_schedules_chinese.dart' as cn;
import 'oem_schedules_german_american.dart' as de;
import 'oem_schedules_euro_american_extra.dart' as eu;

/// A single reconciled OEM maintenance interval for one service item on a
/// make/model/year(/engine/fuel) scope. Normal and severe figures for the same
/// service item are MERGED into one entry so the engine can prefer severe.
class OemScheduleEntry {
  final String make;
  final String model;
  final int? yearStart;
  final int? yearEnd;
  final String? engine;
  final String? fuel;

  /// Original OEM service-item label (free text, e.g. "Engine oil & filter").
  final String service;

  final int? normalKm;
  final int? normalMonths;
  final int? severeKm;
  final int? severeMonths;

  /// Condition-based / flexible-service baseline (never shown as "varies").
  final bool conditionBased;

  final OemSourceGrade grade;
  final String sourceLabel;
  final String? sourceUrl;

  /// App ServiceType this item maps to, or null when it has no app equivalent
  /// (cabin filter, transfer case, differential, generic "scheduled service"…).
  final ServiceType? mappedType;

  const OemScheduleEntry({
    required this.make,
    required this.model,
    this.yearStart,
    this.yearEnd,
    this.engine,
    this.fuel,
    required this.service,
    this.normalKm,
    this.normalMonths,
    this.severeKm,
    this.severeMonths,
    required this.conditionBased,
    required this.grade,
    required this.sourceLabel,
    this.sourceUrl,
    required this.mappedType,
  });

  /// True when the model string is an explicit make-wide schedule ("All …"),
  /// which should apply to any model of the make. Generic/single-market tables
  /// ("General range (Brunei PMS)") are deliberately NOT treated as make-wide.
  bool get isMakeWide => model.toLowerCase().trim().startsWith('all ');

  bool matches({
    required String make,
    required String model,
    required int year,
    String? engine,
    String? fuel,
  }) {
    return _makeMatches(this.make, make) &&
        _modelMatches(this.model, model) &&
        _yearMatches(yearStart, yearEnd, year) &&
        _fuelMatches(this.fuel, fuel);
  }
}

// ---------------------------------------------------------------------------
// Matching helpers (loose, case-insensitive; mirror the common-faults matcher
// but with make-token overlap for combined makes like "Chevrolet/GMC").
// ---------------------------------------------------------------------------

Set<String> _tokens(String s) => s
    .toLowerCase()
    .split(RegExp(r'[^a-z0-9]+'))
    .where((t) => t.isNotEmpty)
    .toSet();

bool _makeMatches(String entryMake, String vehicleMake) {
  final e = entryMake.toLowerCase().trim();
  final v = vehicleMake.toLowerCase().trim();
  if (e == v) return true;
  // Combined makes ("Chevrolet/GMC", "GWM (Haval)") share a token with either.
  return _tokens(e).intersection(_tokens(v)).isNotEmpty;
}

bool _modelMatches(String entryModel, String vehicleModel) {
  final a = entryModel.toLowerCase().trim();
  final b = vehicleModel.toLowerCase().trim();
  if (a.startsWith('all ')) return true; // explicit make-wide schedule
  if (a.isEmpty || b.isEmpty) return false;
  return a == b || a.contains(b) || b.contains(a);
}

bool _yearMatches(int? start, int? end, int year) {
  if (start != null && year < start) return false;
  if (end != null && year > end) return false;
  return true;
}

String _normFuel(String f) {
  final s = f.toLowerCase();
  if (s.contains('plug')) return 'phev';
  if (s.contains('electric') || s == 'ev' || s.contains('bev')) return 'electric';
  if (s.contains('hybrid') || s.contains('hev')) return 'hybrid';
  if (s.contains('diesel')) return 'diesel';
  return 'petrol'; // petrol / gasoline / lpg / cng → petrol-based ICE
}

/// Soft powertrain gate. A petrol/agnostic schedule may apply to a petrol or
/// unknown-fuel vehicle; a powertrain-specific schedule (hybrid/diesel/EV/PHEV)
/// requires an EXACT powertrain match — so a hybrid-only table never lands on a
/// plain petrol (or unknown) car, and diesel intervals never land on a petrol.
bool _fuelMatches(String? entryFuel, String? vehicleFuel) {
  if (entryFuel == null) return true; // dataset says the table is fuel-agnostic
  final e = _normFuel(entryFuel);
  if (e == 'petrol') {
    if (vehicleFuel == null) return true;
    return _normFuel(vehicleFuel) == 'petrol';
  }
  if (vehicleFuel == null) return false;
  return _normFuel(vehicleFuel) == e;
}

// ---------------------------------------------------------------------------
// Service-name → app ServiceType mapping. Conservative and ordered so the more
// specific item wins; anything with no honest app equivalent returns null.
// ---------------------------------------------------------------------------

bool _isCabinFilter(String s) =>
    s.contains('cabin') ||
    s.contains('pollen') ||
    s.contains('a-c filter') ||
    s.contains('a/c filter') ||
    s.contains('hvac') ||
    s.contains('micro') ||
    s.contains('hepa') ||
    s.contains('combination filter') ||
    s.contains('passenger compartment') ||
    s.contains('fresh air');

ServiceType? mapOemServiceToType(String service) {
  final s = service.toLowerCase();

  if (s.contains('spark plug')) return ServiceType.sparkPlugs;
  if (s.contains('timing belt')) return ServiceType.timingBelt; // chains excluded
  if (s.contains('brake fluid') ||
      s.contains('brake / clutch') ||
      s.contains('brake/clutch')) {
    return ServiceType.brakeFluid;
  }
  if (s.contains('disc brake') || s.contains('brake pad')) {
    return ServiceType.brakePads;
  }
  if (s.contains('fuel filter')) return ServiceType.fuelFilter;

  // Engine oil (incl. "oil & filter" and oil-bearing scheduled services).
  if (s.contains('engine oil')) return ServiceType.oilChange;

  // Engine air filter only — never cabin/pollen/EVAP filters.
  if ((s.contains('air filter') || s.contains('air cleaner')) &&
      !_isCabinFilter(s)) {
    return ServiceType.airFilter;
  }

  if (s.contains('coolant')) return ServiceType.coolant;

  // Transmission family (ATF/CVT/transaxle/gearbox/reducer/DHT) — but NOT the
  // transfer case, differential or axle, which have no app ServiceType.
  final isTransmission = s.contains('transmission') ||
      s.contains('transaxle') ||
      s.contains('cvt') ||
      s.contains('atf') ||
      s.contains('reducer') ||
      s.contains('reduction gear') ||
      s.contains('gearbox') ||
      s.contains('dht');
  final isDriveline = s.contains('transfer') ||
      s.contains('differential') ||
      s.contains('axle');
  if (isTransmission && !isDriveline) return ServiceType.transmissionFluid;

  return null; // cabin filter, transfer case, differential, generic service…
}

// ---------------------------------------------------------------------------
// Adapter plumbing: normalize each dataset's intervals, then merge normal +
// severe rows of the same service item into one [OemScheduleEntry].
// ---------------------------------------------------------------------------

class _Raw {
  final String service;
  final int? km;
  final int? months;
  final bool severe;
  final bool conditionBased;
  final OemSourceGrade grade;
  final String source;
  const _Raw(this.service, this.km, this.months, this.severe,
      this.conditionBased, this.grade, this.source);
}

/// Split a dataset source string into (label, url). Japanese/Chinese datasets
/// embed the URL ("Publisher — Doc — https://…"); the German/American datasets
/// store only a short label (full cite in a companion SOURCES.md).
({String label, String? url}) _splitSource(String s) {
  final i = s.indexOf('http');
  if (i < 0) return (label: s.trim(), url: null);
  var label = s.substring(0, i);
  label = label.replaceAll(RegExp(r'[\s—–\-]+$'), '').trim();
  final url = s.substring(i).trim();
  return (label: label.isEmpty ? s.trim() : label, url: url);
}

List<OemScheduleEntry> _assemble({
  required String make,
  required String model,
  int? yearStart,
  int? yearEnd,
  String? engine,
  String? fuel,
  required List<_Raw> raws,
}) {
  final byService = <String, List<_Raw>>{};
  for (final r in raws) {
    byService.putIfAbsent(r.service.toLowerCase(), () => []).add(r);
  }

  final out = <OemScheduleEntry>[];
  byService.forEach((_, group) {
    final service = group.first.service;
    _Raw? normal;
    _Raw? severe;
    for (final r in group) {
      if (r.severe) {
        severe ??= r;
      } else {
        normal ??= r;
      }
    }
    // Prefer the severe row's provenance/grade since Lebanon applies severe.
    final primary = severe ?? normal!;
    final conditionBased = group.any((r) => r.conditionBased);
    final src = _splitSource(primary.source);

    out.add(OemScheduleEntry(
      make: make,
      model: model,
      yearStart: yearStart,
      yearEnd: yearEnd,
      engine: engine,
      fuel: fuel,
      service: service,
      normalKm: normal?.km,
      normalMonths: normal?.months,
      severeKm: severe?.km,
      severeMonths: severe?.months,
      conditionBased: conditionBased,
      grade: primary.grade,
      sourceLabel: src.label,
      sourceUrl: src.url,
      mappedType: mapOemServiceToType(service),
    ));
  });
  return out;
}

OemSourceGrade _g(int index) => OemSourceGradeX.fromIndex(index);

// ---- Per-dataset adapters ----------------------------------------------------

List<OemScheduleEntry> _fromJapanese() {
  final out = <OemScheduleEntry>[];
  for (final s in jp1.kOemJapaneseSchedules) {
    out.addAll(_assemble(
      make: s.make,
      model: s.model,
      yearStart: s.yearStart,
      yearEnd: s.yearEnd,
      engine: s.engine,
      fuel: s.fuel,
      raws: [
        for (final iv in s.intervals)
          _Raw(
            iv.service,
            iv.intervalKm ?? iv.firstKm,
            iv.intervalMonths,
            iv.severity == jp1.OemSeverity.severe,
            false,
            _g(iv.grade.index),
            iv.source,
          ),
      ],
    ));
  }
  return out;
}

List<OemScheduleEntry> _fromJapanese2() {
  final out = <OemScheduleEntry>[];
  for (final s in jp2.kOemJapaneseSchedules2) {
    out.addAll(_assemble(
      make: s.make,
      model: s.model,
      yearStart: s.yearStart,
      yearEnd: s.yearEnd,
      engine: s.engine,
      fuel: s.fuel,
      raws: [
        for (final iv in s.intervals)
          _Raw(
            iv.service,
            iv.intervalKm ?? iv.firstKm,
            iv.intervalMonths,
            iv.severity == jp2.OemSeverity.severe,
            s.conditionBased,
            _g(iv.grade.index),
            iv.source,
          ),
      ],
    ));
  }
  return out;
}

List<OemScheduleEntry> _fromChinese() {
  final out = <OemScheduleEntry>[];
  for (final s in cn.kOemChineseSchedules) {
    out.addAll(_assemble(
      make: s.make,
      model: s.model,
      yearStart: s.yearStart,
      yearEnd: s.yearEnd,
      engine: s.engine,
      fuel: s.fuel,
      raws: [
        for (final iv in s.intervals)
          _Raw(
            iv.service,
            iv.intervalKm ?? iv.firstKm,
            iv.intervalMonths,
            iv.severity == cn.OemSeverity.severe,
            iv.conditionBased,
            _g(iv.grade.index),
            iv.source,
          ),
      ],
    ));
  }
  return out;
}

List<OemScheduleEntry> _fromGerman() {
  final out = <OemScheduleEntry>[];
  for (final s in de.kOemSchedulesGermanAmerican) {
    out.addAll(_assemble(
      make: s.make,
      model: s.model,
      yearStart: s.yearStart,
      yearEnd: s.yearEnd,
      engine: s.engine,
      fuel: s.fuel,
      raws: [
        for (final iv in s.intervals)
          _Raw(
            iv.service,
            iv.intervalKm,
            iv.intervalMonths,
            iv.severity == de.OemSeverity.severe,
            s.conditionBased,
            _g(iv.grade.index),
            iv.source,
          ),
      ],
    ));
  }
  return out;
}

List<OemScheduleEntry> _fromEuro() {
  final out = <OemScheduleEntry>[];
  for (final s in eu.kOemSchedulesEuroAmericanExtra) {
    out.addAll(_assemble(
      make: s.make,
      model: s.model,
      yearStart: s.yearStart,
      yearEnd: s.yearEnd,
      engine: s.engine,
      fuel: s.fuel,
      raws: [
        for (final iv in s.intervals)
          _Raw(
            iv.service,
            iv.intervalKm,
            iv.intervalMonths,
            iv.severity == eu.OemSeverity.severe,
            s.conditionBased,
            _g(iv.grade.index),
            iv.source,
          ),
      ],
    ));
  }
  return out;
}

// ---- Public API --------------------------------------------------------------

List<OemScheduleEntry>? _catalogCache;

/// The full reconciled catalog, built once and cached.
List<OemScheduleEntry> get oemScheduleCatalog => _catalogCache ??= [
      ..._fromJapanese(),
      ..._fromJapanese2(),
      ..._fromChinese(),
      ..._fromGerman(),
      ..._fromEuro(),
    ];

/// All sourced OEM entries that apply to a vehicle identity, via loose matching
/// (make token overlap + loose model + year range + soft fuel gate). Returns an
/// empty list when nothing is sourced for the vehicle — the engine then keeps
/// its computed schedule.
List<OemScheduleEntry> oemScheduleFor({
  required String make,
  required String model,
  required int year,
  String? engine,
  String? fuel,
}) {
  return oemScheduleCatalog
      .where((e) => e.matches(
            make: make,
            model: model,
            year: year,
            engine: engine,
            fuel: fuel,
          ))
      .toList();
}
