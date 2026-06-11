import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bootstrap.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/data/mock_auth_repository.dart';
import '../features/auth/models/app_user.dart';
import '../features/vehicles/data/firestore_garage_repository.dart';
import '../features/vehicles/data/garage_repository.dart';
import '../features/vehicles/data/in_memory_garage_repository.dart';
import '../features/vehicles/models/vehicle.dart';
import '../features/maintenance/engine/maintenance_engine.dart';
import '../features/maintenance/models/service_record.dart';

/// --- Repositories ------------------------------------------------------
///
/// Swap these two overrides for FirebaseAuthRepository / FirestoreGarage
/// Repository once `kUseFirebase` is true. Nothing else in the app changes.

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (kUseFirebase) return FirebaseAuthRepository();
  final repo = MockAuthRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  return kUseFirebase
      ? FirestoreGarageRepository()
      : InMemoryGarageRepository();
});

final maintenanceEngineProvider =
    Provider<MaintenanceEngine>((ref) => const MaintenanceEngine());

/// --- Auth state --------------------------------------------------------

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// --- Vehicles ----------------------------------------------------------

final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(garageRepositoryProvider).watchVehicles();
});

/// Currently selected vehicle id (defaults to the first vehicle).
final selectedVehicleIdProvider = StateProvider<String?>((ref) => null);

final selectedVehicleProvider = Provider<Vehicle?>((ref) {
  final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? const [];
  if (vehicles.isEmpty) return null;
  final id = ref.watch(selectedVehicleIdProvider);
  return vehicles.firstWhere(
    (v) => v.id == id,
    orElse: () => vehicles.first,
  );
});

final historyProvider =
    StreamProvider.family<List<ServiceRecord>, String>((ref, vehicleId) {
  return ref.watch(garageRepositoryProvider).watchHistory(vehicleId);
});

/// --- Locale ------------------------------------------------------------

const _localeKey = 'app_locale';

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main() with the loaded prefs'),
);

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs)
      : super(Locale(_prefs.getString(_localeKey) ?? 'en'));

  final SharedPreferences _prefs;

  void setLocale(String code) {
    state = Locale(code);
    _prefs.setString(_localeKey, code);
  }

  void toggle() => setLocale(state.languageCode == 'en' ? 'ar' : 'en');
}

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(ref.watch(sharedPrefsProvider));
});

/// Whether the one-time onboarding has been completed.
const onboardingSeenKey = 'onboarding_seen';

final onboardingSeenProvider = StateProvider<bool>((ref) {
  return ref.watch(sharedPrefsProvider).getBool(onboardingSeenKey) ?? false;
});
