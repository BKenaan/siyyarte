import '../models/app_user.dart';

/// Auth abstraction. The app depends only on this interface; swap the mock for
/// the Firebase implementation by flipping a single provider (see
/// `lib/core/providers.dart`). No screen knows which backend is in use.
abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;

  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUpWithEmail(
      String name, String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithApple();

  /// Phone OTP — returns a verificationId; complete with [confirmOtp].
  Future<String> startPhoneSignIn(String phone);
  Future<AppUser> confirmOtp(String verificationId, String smsCode);

  Future<void> signOut();
  Future<void> deleteAccount();
}
