import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/common_fault.dart';
import 'common_faults_data.dart';

/// Stable lookup key so the family isn't re-created on every rebuild.
typedef CommonFaultsKey = ({
  String make,
  String model,
  int year,
  String? engine,
});

/// Catalogued common faults for a vehicle identity (most-severe first).
///
/// Backed by the local, source-cited [kCommonFaults] dataset — no network — so
/// faults render instantly and offline, like the computed schedule.
final commonFaultsProvider =
    Provider.family<List<CommonFault>, CommonFaultsKey>((ref, k) {
  return commonFaultsFor(
    make: k.make,
    model: k.model,
    year: k.year,
    engine: k.engine,
  );
});
