import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/bootstrap.dart';

/// Client for the VIN ownership-transfer flow. When a car was sold, the buyer
/// requests a transfer here; the CURRENT owner receives a confirmation email
/// (requestVinTransfer Cloud Function) and the car moves accounts only after
/// they approve.
class VinTransferService {
  /// Returns the server's status: 'requested' (email sent), 'free' (the VIN
  /// is unclaimed — just save again), or 'already_yours'.
  Future<String> requestTransfer(String vin) async {
    if (!kUseFirebase) {
      throw StateError('Ownership transfer needs the Firebase backend.');
    }
    final callable =
        FirebaseFunctions.instance.httpsCallable('requestVinTransfer');
    final res = await callable.call<Map<dynamic, dynamic>>({'vin': vin});
    return (res.data['status'] as String?) ?? 'unknown';
  }
}

final vinTransferServiceProvider =
    Provider<VinTransferService>((ref) => VinTransferService());
