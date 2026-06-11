import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/siyyarte_logo.dart';
import '../../l10n/app_localizations.dart';
import '../ads/ads.dart';
import '../premium/premium_controller.dart';
import '../costs/cost_center_screen.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../reminders/reminders_screen.dart';
import '../settings/screens/settings_screen.dart';
import '../vehicles/screens/vehicles_screen.dart';

/// Bottom-nav container. Uses an IndexedStack so tab state is preserved and
/// the offline data stays warm when switching tabs.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        // Clean wordmark in the app bar (the detailed badge is reserved for the
        // login hero, splash and launcher icon). The bottom bar labels the tab.
        title: const SiyyarteWordmark(fontSize: 20),
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                DashboardScreen(),
                VehiclesScreen(),
                CostCenterScreen(),
                RemindersScreen(),
                SettingsScreen(),
              ],
            ),
          ),
          // Free tier sees a banner ad; Plus removes it.
          if (!ref.watch(isPremiumProvider)) const AdBanner(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: t.dashboard),
          NavigationDestination(
              icon: const Icon(Icons.directions_car_outlined),
              selectedIcon: const Icon(Icons.directions_car),
              label: t.vehicles),
          NavigationDestination(
              icon: const Icon(Icons.payments_outlined),
              selectedIcon: const Icon(Icons.payments),
              label: t.costs),
          NavigationDestination(
              icon: const Icon(Icons.notifications_outlined),
              selectedIcon: const Icon(Icons.notifications),
              label: t.reminders),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: t.settings),
        ],
      ),
    );
  }
}
