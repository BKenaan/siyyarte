import 'dart:async';

import '../models/app_user.dart';
import 'auth_repository.dart';

/// In-memory auth used until a Firebase project is configured. Lets the whole
/// app run and be demoed offline. Accepts any credentials.
class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  void _emit(AppUser? u) {
    _user = u;
    _controller.add(u);
  }

  AppUser _fakeUser({String? name, String? email, String? phone}) => AppUser(
        uid: 'mock-${DateTime.now().microsecondsSinceEpoch}',
        name: name ?? 'Demo Driver',
        email: email,
        phone: phone,
      );

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final u = _fakeUser(email: email);
    _emit(u);
    return u;
  }

  @override
  Future<AppUser> signUpWithEmail(
      String name, String email, String password) async {
    final u = _fakeUser(name: name, email: email);
    _emit(u);
    return u;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final u = _fakeUser(name: 'Google User', email: 'user@gmail.com');
    _emit(u);
    return u;
  }

  @override
  Future<AppUser> signInWithApple() async {
    final u = _fakeUser(name: 'Apple User');
    _emit(u);
    return u;
  }

  @override
  Future<String> startPhoneSignIn(String phone) async => 'mock-verification-id';

  @override
  Future<AppUser> confirmOtp(String verificationId, String smsCode) async {
    final u = _fakeUser(phone: '+961 70 000 000');
    _emit(u);
    return u;
  }

  @override
  Future<void> signOut() async => _emit(null);

  @override
  Future<void> deleteAccount() async => _emit(null);

  void dispose() => _controller.close();
}
