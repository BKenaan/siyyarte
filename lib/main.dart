import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/bootstrap.dart';
import 'core/providers.dart';
import 'features/ads/ads.dart';
import 'features/premium/premium_controller.dart';
import 'features/reminders/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(); // no-op until Firebase is configured
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

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SiyyarteApp(),
    ),
  );
}
