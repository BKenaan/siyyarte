import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/bootstrap.dart';
import 'core/providers.dart';
import 'features/admin/admin_app.dart';

/// Admin panel entry point (Flutter Web).
/// Run: flutter run -d chrome -t lib/main_admin.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const AdminApp(),
    ),
  );
}
