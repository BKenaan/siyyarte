import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';

/// An editable cost estimate for a car-related item, in both USD and LBP.
/// Lebanese prices move constantly, so every value is user-overridable.
class CostItem {
  final String id;
  final double usd;
  final double lbp;

  const CostItem({required this.id, required this.usd, required this.lbp});

  CostItem copyWith({double? usd, double? lbp}) =>
      CostItem(id: id, usd: usd ?? this.usd, lbp: lbp ?? this.lbp);

  Map<String, dynamic> toMap() => {'usd': usd, 'lbp': lbp};
}

/// Seed estimates (USD; LBP shown as indicative at ~89,500 L.L./USD). These are
/// starting points only — the disclaimer makes clear they vary widely.
const _seed = <String, ({double usd, double lbp})>{
  'oilChange': (usd: 35, lbp: 3130000),
  'oilFilter': (usd: 8, lbp: 716000),
  'airFilter': (usd: 12, lbp: 1074000),
  'sparkPlugs': (usd: 40, lbp: 3580000),
  'brakePads': (usd: 90, lbp: 8055000),
  'tires': (usd: 280, lbp: 25060000),
  'battery': (usd: 110, lbp: 9845000),
  'coolant': (usd: 25, lbp: 2237000),
  'transmissionFluid': (usd: 70, lbp: 6265000),
  'timingBelt': (usd: 220, lbp: 19690000),
  'labor': (usd: 20, lbp: 1790000),
  'registrationFees': (usd: 90, lbp: 8055000),
  'insuranceCost': (usd: 130, lbp: 11635000),
  'inspectionFees': (usd: 25, lbp: 2237000),
  'parkingOther': (usd: 30, lbp: 2685000),
};

class CostCatalogController extends StateNotifier<List<CostItem>> {
  CostCatalogController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;
  static const _key = 'cost_overrides';

  static List<CostItem> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    final overrides = raw == null
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
    return _seed.entries.map((e) {
      final o = overrides[e.key] as Map<String, dynamic>?;
      return CostItem(
        id: e.key,
        usd: (o?['usd'] as num?)?.toDouble() ?? e.value.usd,
        lbp: (o?['lbp'] as num?)?.toDouble() ?? e.value.lbp,
      );
    }).toList();
  }

  void update(String id, {double? usd, double? lbp}) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(usd: usd, lbp: lbp) else item
    ];
    _persist();
  }

  void _persist() {
    final map = {for (final i in state) i.id: i.toMap()};
    _prefs.setString(_key, jsonEncode(map));
  }

  CostItem? byId(String id) =>
      state.where((i) => i.id == id).firstOrNull;
}

final costCatalogProvider =
    StateNotifierProvider<CostCatalogController, List<CostItem>>((ref) {
  return CostCatalogController(ref.watch(sharedPrefsProvider));
});
