import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../maintenance/models/maintenance_rule.dart';
import '../maintenance/models/service_type.dart';
import '../vehicles/data/vehicle_catalog.dart';
import 'admin_sections.dart';

/// Garagi admin panel — a Flutter Web app sharing the mobile app's models and
/// (when live) the same Firestore catalogs. Run with:
///   flutter run -d chrome -t lib/main_admin.dart
///
/// Writes to Firestore catalogs require the Firebase `admin` custom claim
/// (enforced by firestore.rules); the gate below requires sign-in, and the
/// rules reject non-admins.
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siyyarte Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const _AdminGate(),
    );
  }
}

class _AdminGate extends ConsumerWidget {
  const _AdminGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kUseFirebase) return const _AdminShell(); // local/dev: open directly
    final auth = ref.watch(authStateProvider);
    return auth.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (user) => user == null ? const _AdminLogin() : const _AdminShell(),
    );
  }
}

class _AdminLogin extends ConsumerStatefulWidget {
  const _AdminLogin();
  @override
  ConsumerState<_AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends ConsumerState<_AdminLogin> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmail(_email.text.trim(), _password.text);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Siyyarte Admin',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Admin sign-in',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    onSubmitted: (_) => _signIn(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _signIn,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Sign in'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You must have the admin custom claim. Catalog writes are '
                    'rejected otherwise.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminShell extends ConsumerStatefulWidget {
  const _AdminShell();
  @override
  ConsumerState<_AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<_AdminShell> {
  int _index = 0;

  static const _dests = [
    (icon: Icons.directions_car, label: 'Catalog'),
    (icon: Icons.build_circle_outlined, label: 'Specs'),
    (icon: Icons.tune, label: 'Intervals'),
    (icon: Icons.payments, label: 'Costs'),
    (icon: Icons.people, label: 'Users'),
    (icon: Icons.campaign, label: 'Announcements'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const CatalogSection(),
      const SpecsSection(),
      const IntervalsSection(),
      const CostsSection(),
      const UsersSection(),
      const AnnouncementsSection(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Siyyarte — Admin Panel'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (kUseFirebase)
            IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
            ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 900,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              for (final d in _dests)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: pages[_index],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared read-only data exposed to admin sections.
abstract class AdminData {
  static List<VehicleMake> get makes => VehicleCatalog.makes;
  static List<MaintenanceRule> get rules => DefaultMaintenanceRules.all;
  static List<ServiceType> get serviceTypes => ServiceType.values;
}
