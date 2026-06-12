import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenuecat_config.dart';

/// RevenueCat-backed purchases for Android/iOS. After a successful purchase or
/// restore, the active-entitlement check drives [PurchaseService] callbacks,
/// which the app maps onto [isPremiumProvider].
class PurchaseService {
  String get _key => Platform.isIOS ? kRevenueCatIosKey : kRevenueCatAndroidKey;

  bool get available => _key.isNotEmpty;

  bool _isPlus(CustomerInfo info) =>
      info.entitlements.active.containsKey(kPlusEntitlementId);

  Future<void> init(void Function(bool isPremium) onEntitlement) async {
    if (!available) return;
    try {
      await Purchases.configure(PurchasesConfiguration(_key));
      Purchases.addCustomerInfoUpdateListener(
          (info) => onEntitlement(_isPlus(info)));
      final info = await Purchases.getCustomerInfo();
      onEntitlement(_isPlus(info));
    } catch (e) {
      debugPrint('RevenueCat init failed: $e');
    }
  }

  /// Ties the RevenueCat identity to the Firebase uid so server-side webhook
  /// events carry the uid (drives the users/{uid}.plus flag). Pass null on
  /// sign-out.
  Future<void> identify(String? uid) async {
    if (!available) return;
    try {
      if (uid != null) {
        await Purchases.logIn(uid);
      } else if (!(await Purchases.isAnonymous)) {
        await Purchases.logOut();
      }
    } catch (e) {
      debugPrint('RevenueCat identify failed: $e');
    }
  }

  Future<Package?> _package() async {
    final offerings = await Purchases.getOfferings();
    final packages = offerings.current?.availablePackages ?? const [];
    return packages.isEmpty ? null : packages.first;
  }

  Future<String?> priceString() async {
    if (!available) return null;
    try {
      return (await _package())?.storeProduct.priceString;
    } catch (_) {
      return null;
    }
  }

  /// Buys the current offering's package; returns true if Plus is now active.
  /// Throws on platform errors (caller handles user-cancel etc.).
  Future<bool> purchase() async {
    if (!available) return false;
    final pkg = await _package();
    if (pkg == null) return false;
    await Purchases.purchasePackage(pkg);
    final info = await Purchases.getCustomerInfo();
    return _isPlus(info);
  }

  Future<bool> restore() async {
    if (!available) return false;
    await Purchases.restorePurchases();
    final info = await Purchases.getCustomerInfo();
    return _isPlus(info);
  }
}
