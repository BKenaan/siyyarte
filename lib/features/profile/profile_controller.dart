import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/bootstrap.dart';
import '../../core/constants/lebanon.dart';
import '../../core/providers.dart';
import '../auth/models/app_user.dart';

/// Holds the editable profile (name, city, currency) merged onto the
/// authenticated user. Source of truth is the Firestore users/{uid} document
/// (so the profile follows the account across devices and reinstalls); local
/// prefs act as the offline mirror so the app still opens without signal.
class ProfileController extends StateNotifier<AppUser?> {
  ProfileController(this._prefs, AppUser? authUser)
      : super(_merge(_prefs, authUser)) {
    _loadRemote(authUser);
  }

  final SharedPreferences _prefs;

  /// True once the Firestore profile has been checked (or there is nothing to
  /// check). The auth gate waits for this before deciding the profile is
  /// incomplete — otherwise an existing user gets re-asked for their city.
  bool remoteChecked = !kUseFirebase;

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

  Future<void> _loadRemote(AppUser? authUser) async {
    if (!kUseFirebase || authUser == null) {
      remoteChecked = true;
      return;
    }
    // The local cache already has a complete profile — no need to block.
    if (state?.city != null) {
      remoteChecked = true;
      _touch();
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .get();
      final m = snap.data();
      if (m != null && mounted) {
        final current = state;
        if (current != null) {
          state = current.copyWith(
            name: (m['name'] as String?) ?? current.name,
            city: (m['city'] as String?) ?? current.city,
            preferredCurrency: m['currency'] == 'LBP'
                ? Currency.lbp
                : (m['currency'] == 'USD'
                    ? Currency.usd
                    : current.preferredCurrency),
          );
          _cacheLocally();
        }
      }
    } catch (_) {
      // Offline — the prefs mirror (or setup screen) carries the day.
    } finally {
      remoteChecked = true;
      _touch();
    }
  }

  /// Reassign state so listeners rebuild after [remoteChecked] flips.
  void _touch() {
    if (mounted) state = state;
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
    _cacheLocally();
    if (kUseFirebase) {
      // Fire-and-forget; Firestore queues the write offline.
      FirebaseFirestore.instance.collection('users').doc(updated.uid).set({
        'name': updated.name,
        'city': updated.city,
        'currency': updated.preferredCurrency.code,
      }, SetOptions(merge: true));
    }
  }

  void _cacheLocally() {
    final updated = state;
    if (updated == null) return;
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
