import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/bootstrap.dart';
import 'vehicle_specs.dart';

/// Storage for admin-curated vehicle specs (the `vehicle_specs` catalog).
/// These layer on top of the built-in [VehicleSpecs.seed] so the owner can fill
/// trims the free VIN/US data misses — especially MENA-specific variants.
abstract class SpecRepository {
  Stream<List<ModelSpec>> watchSpecs();
  Future<void> upsert(ModelSpec spec);
  Future<void> delete(String id);
}

class FirestoreSpecRepository implements SpecRepository {
  final _col = FirebaseFirestore.instance.collection('vehicle_specs');

  @override
  Stream<List<ModelSpec>> watchSpecs() => _col.snapshots().map((snap) =>
      snap.docs.map((d) => ModelSpec.fromMap(d.id, d.data())).toList());

  @override
  Future<void> upsert(ModelSpec spec) => spec.id == null
      ? _col.add(spec.toMap())
      : _col.doc(spec.id).set(spec.toMap());

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}

class EmptySpecRepository implements SpecRepository {
  @override
  Stream<List<ModelSpec>> watchSpecs() async* {
    yield const [];
  }

  @override
  Future<void> upsert(ModelSpec spec) async {}

  @override
  Future<void> delete(String id) async {}
}

final specRepositoryProvider = Provider<SpecRepository>((ref) {
  return kUseFirebase ? FirestoreSpecRepository() : EmptySpecRepository();
});

/// Just the admin-curated specs (with Firestore ids) — for the admin editor.
final curatedSpecsProvider = StreamProvider<List<ModelSpec>>((ref) {
  return ref.watch(specRepositoryProvider).watchSpecs();
});

/// All model specs = built-in seed + admin-curated (Firestore) specs.
final modelSpecsProvider = StreamProvider<List<ModelSpec>>((ref) async* {
  final repo = ref.watch(specRepositoryProvider);
  await for (final custom in repo.watchSpecs()) {
    yield [...VehicleSpecs.seed, ...custom];
  }
});
