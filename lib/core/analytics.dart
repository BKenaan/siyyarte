import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'bootstrap.dart';

/// Thin, fail-safe wrapper over Firebase Analytics. Every call no-ops when
/// Firebase is off or on web, and swallows errors — analytics must never crash
/// a user flow. Event names/params follow GA4 conventions (snake_case).
abstract class Analytics {
  static bool get _on => kUseFirebase && !kIsWeb;

  static FirebaseAnalytics get instance => FirebaseAnalytics.instance;

  /// Navigator observer for automatic screen_view events on pushed routes.
  static final observer = _on
      ? FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      : null;

  static Future<void> log(String name, [Map<String, Object>? params]) async {
    if (!_on) return;
    try {
      await FirebaseAnalytics.instance
          .logEvent(name: name, parameters: params);
    } catch (_) {/* never let telemetry break a flow */}
  }

  // --- Funnel helpers (the events worth watching at launch) ---
  static Future<void> addVehicle(String make, String model) =>
      log('add_vehicle', {'make': make, 'model': model});
  static Future<void> logService(String type) =>
      log('log_service', {'service_type': type});
  static Future<void> logFuel() => log('log_fuel');
  static Future<void> scanCard(String mode) =>
      log('scan_card', {'mode': mode});
  static Future<void> viewPaywall(String source) =>
      log('view_paywall', {'source': source});
  static Future<void> exportPassport() => log('export_passport');
}
