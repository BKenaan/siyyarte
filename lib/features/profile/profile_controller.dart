import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/lebanon.dart';
import '../../core/providers.dart';
import '../auth/models/app_user.dart';

/// Holds the editable profile (name, city, currency) merged onto the
/// authenticated user. Persisted locally per-uid so it survives restarts and
/// works offline. When Firebase is enabled this is where a Firestore
/// users/{uid} document sync would hook in (the prefs cache stays as the
/// offline mirror).
class ProfileController extends StateNotifier<AppUser?> {
  ProfileController(this._prefs, AppUser? authUser)
      : super(_merge(_prefs, authUser));

  final SharedPreferences _prefs;

  static String _key(String uid) => 'profile_$uid';

  static AppUser? _merge(SharedPreferences prefs, AppUser? authUser) {
    if (authUser == null) return null;
    final raw = prefs.getString(_key(authUser.uid));
    if (raw == null) return authUser;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return AppUser(
      uid: authUser.uid,
      name: (m['name'] as String?) ?? authUser.name,
      email: authUser.email,
      phone: authUser.phone,
      language: (m['language'] as String?) ?? authUser.language,
      city: m['city'] as String?,
      preferredCurrency:
          m['currency'] == 'LBP' ? Currency.lbp : Currency.usd,
    );
  }

  /// True once the user has completed the minimum profile (a city set).
  bool get isComplete => state?.city != null;

  void save({String? name, String? city, Currency? currency}) {
    final current = state;
    if (current == null) return;
    final updated = current.copyWith(
      name: name,
      city: city,
      preferredCurrency: currency,
    );
    state = updated;
    _prefs.setString(
      _key(updated.uid),
      jsonEncode({
        'name': updated.name,
        'city': updated.city,
        'language': updated.language,
        'currency': updated.preferredCurrency.code,
      }),
    );
  }

  void clear() {
    final uid = state?.uid;
    if (uid != null) _prefs.remove(_key(uid));
  }
}

final profileProvider =
    StateNotifierProvider<ProfileController, AppUser?>((ref) {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  return ProfileController(ref.watch(sharedPrefsProvider), authUser);
});
