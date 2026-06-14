import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap.dart';
import '../vehicles/models/vehicle.dart';
import 'verified_spec.dart';

/// Fetches the manufacturer-verified spec record (if any) for a vehicle from
/// Firestore `verified_specs`, applying simple market routing for Lebanon's
/// mixed-import fleet.
class VerifiedSpecRepository {
  VerifiedSpecRepository(this._db);
  final FirebaseFirestore _db;

  /// All verified records for a make/model (any market), year-filtered.
  Future<List<VerifiedSpec>> _candidates(
      String make, String model, int year) async {
    final key = '${make.toLowerCase()}|${model.toLowerCase()}';
    final snap = await _db
        .collection('verified_specs')
        .where('lookupKey', isEqualTo: key)
        .get();
    return snap.docs
        .map((d) => VerifiedSpec.fromMap(d.id, d.data()))
        .where((s) => s.coversYear(year))
        .toList();
  }

  Future<VerifiedSpecResult?> resolveVehicle(Vehicle v) =>
      resolve(make: v.make, model: v.model, year: v.year, engine: v.engineType);

  /// Resolve the best verified spec for a vehicle's identity.
  ///
  /// Market routing (Lebanon's fleet is mixed-import): prefer a GCC record
  /// (the most common source for Lebanese cars), then North America (US
  /// imports), then anything available. When an engine is known, prefer the
  /// matching engine; otherwise return the first market match (callers can
  /// still show fluids that are engine-independent).
  Future<VerifiedSpecResult?> resolve({
    required String make,
    required String model,
    required int year,
    String? engine,
  }) async {
    if (!kUseFirebase) return null;
    final all = await _candidates(make, model, year);
    if (all.isEmpty) return null;

    const marketRank = {'GCC': 0, 'North America': 1, 'Europe': 2, 'Japan': 3};
    all.sort((a, b) =>
        (marketRank[a.market] ?? 9).compareTo(marketRank[b.market] ?? 9));

    final markets = all.map((s) => s.market).toSet();
    final chosenMarket = all.first.market;
    final inMarket = all.where((s) => s.market == chosenMarket).toList();

    // Prefer an engine match within the chosen market when we can infer it.
    VerifiedSpec best = inMarket.first;
    if (engine != null && engine.isNotEmpty) {
      final eng = engine.toLowerCase();
      best = inMarket.firstWhere(
        (s) => (s.engineName ?? '').toLowerCase().contains(eng) ||
            eng.contains((s.engineName ?? '###').toLowerCase()),
        orElse: () => inMarket.first,
      );
    }

    return VerifiedSpecResult(
      spec: best,
      // More than one source-market exists for this model → the displayed
      // market scope is an assumption the user may want to confirm.
      marketAmbiguous: markets.length > 1,
      availableMarkets: markets.toList(),
    );
  }
}

class VerifiedSpecResult {
  final VerifiedSpec spec;
  final bool marketAmbiguous;
  final List<String> availableMarkets;
  const VerifiedSpecResult({
    required this.spec,
    this.marketAmbiguous = false,
    this.availableMarkets = const [],
  });
}

final verifiedSpecRepositoryProvider =
    Provider<VerifiedSpecRepository>((ref) =>
        VerifiedSpecRepository(FirebaseFirestore.instance));

/// Stable lookup key — a record has structural equality, so the family is not
/// re-created on every Firestore snapshot (which would refetch and flicker).
typedef VerifiedSpecKey = ({String make, String model, int year, String? engine});

/// Resolves the verified spec for a given vehicle identity (null = none).
final verifiedSpecProvider =
    FutureProvider.family<VerifiedSpecResult?, VerifiedSpecKey>((ref, k) async {
  return ref
      .read(verifiedSpecRepositoryProvider)
      .resolve(make: k.make, model: k.model, year: k.year, engine: k.engine);
});
