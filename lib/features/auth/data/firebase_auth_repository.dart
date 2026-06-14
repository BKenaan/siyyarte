import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/app_user.dart';
import 'auth_repository.dart';

/// Real auth backed by Firebase Auth. Passwords are never handled by us —
/// Firebase performs secure hashing, token issuance and refresh. Enable this by
/// swapping the provider override once `flutterfire configure` has run.
class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  AppUser? _map(fb.User? u) => u == null
      ? null
      : AppUser(
          uid: u.uid,
          name: u.displayName,
          email: u.email,
          phone: u.phoneNumber,
        );

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.authStateChanges().map(_map);

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    return _map(cred.user)!;
  }

  @override
  Future<AppUser> signUpWithEmail(
      String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await cred.user?.updateDisplayName(name);
    await cred.user?.sendEmailVerification();
    return _map(cred.user)!;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final account = await GoogleSignIn().signIn();
    if (account == null) throw fb.FirebaseAuthException(code: 'aborted');
    final gAuth = await account.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return _map(cred.user)!;
  }

  @override
  Future<AppUser> signInWithApple() async {
    final apple = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ]);
    final credential = fb.OAuthProvider('apple.com').credential(
      idToken: apple.identityToken,
      accessToken: apple.authorizationCode,
    );
    final cred = await _auth.signInWithCredential(credential);
    return _map(cred.user)!;
  }

  @override
  Future<String> startPhoneSignIn(String phone) async {
    final completer = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (_) {},
      verificationFailed: completer.completeError,
      codeSent: (verificationId, _) => completer.complete(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  @override
  Future<AppUser> confirmOtp(String verificationId, String smsCode) async {
    final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    final cred = await _auth.signInWithCredential(credential);
    return _map(cred.user)!;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteAccount() async {
    // Server-side cascade (Admin SDK) deletes ALL data — vehicles, history,
    // photos, VIN claims — and the Auth user, avoiding the client
    // "requires-recent-login" error. Then clear the local session.
    await FirebaseFunctions.instance.httpsCallable('deleteAccount').call();
    await _auth.signOut();
  }
}
