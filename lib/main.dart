import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/bootstrap.dart';
import 'core/providers.dart';
import 'core/secure_screen.dart';
import 'features/ads/ads.dart';
import 'features/premium/premium_controller.dart';
import 'features/reminders/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(); // no-op until Firebase is configured

  // Crash reporting — route Flutter + platform errors to Crashlytics (mobile
  // only; Crashlytics has no web support). Must run after Firebase.initializeApp.
  if (kUseFirebase && !kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await NotificationService.instance.init();
  await initAds(); // no-op on web; initializes AdMob on mobile
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
  // Hydrate subscription entitlement (RevenueCat on mobile; no-op elsewhere).
  await container.read(purchaseServiceProvider).init(
        (isPremium) =>
            container.read(isPremiumProvider.notifier).setPremium(isPremium),
      );
  // Free plan: block screenshots/recording (Android FLAG_SECURE). Follows the
  // premium state live, so upgrading lifts it immediately.
  setSecureScreen(!container.read(isPremiumProvider));
  container.listen<bool>(isPremiumProvider,
      (_, premium) => setSecureScreen(!premium));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SiyyarteApp(),
    ),
  );
}
