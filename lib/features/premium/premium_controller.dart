import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import 'purchase_service.dart';

/// Whether the user has an active "Siyyarte Plus" subscription.
///
/// Persisted locally so gating works offline. When a real purchase SDK is wired
/// (Google Play Billing / App Store via `in_app_purchase` or RevenueCat), a
/// verified purchase calls [setPremium], and ideally also mirrors the flag to
/// `users/{uid}.premium` in Firestore for cross-device entitlement. The UI
/// depends only on this provider, so the billing backend can be swapped in
/// without touching the paywall or the gated features.
class PremiumController extends StateNotifier<bool> {
  PremiumController(this._prefs) : super(_prefs.getBool(_key) ?? false);

  final SharedPreferences _prefs;
  static const _key = 'premium_active';

  Future<void> setPremium(bool active) async {
    state = active;
    await _prefs.setBool(_key, active);
  }
}

final isPremiumProvider =
    StateNotifierProvider<PremiumController, bool>((ref) {
  return PremiumController(ref.watch(sharedPrefsProvider));
});

/// The store-purchase service (RevenueCat on mobile, no-op stub elsewhere).
final purchaseServiceProvider =
    Provider<PurchaseService>((ref) => PurchaseService());
