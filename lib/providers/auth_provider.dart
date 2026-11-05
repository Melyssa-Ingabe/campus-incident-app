import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { checking, signedOut, needsVerification, signedIn }

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<User?>? _subscription;

  AuthStatus _status = AuthStatus.checking;
  AppUser? _appUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? service}) : _service = service ?? AuthService() {
    _subscription = _service.authStateChanges.listen(_onAuthChanged);
  }

  AuthStatus get status => _status;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isStaff => _appUser?.isStaff ?? false;
  String? get currentEmail => _service.currentUser?.email;

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      _appUser = null;
      _status = AuthStatus.signedOut;
      notifyListeners();
      return;
    }

    if (!user.emailVerified) {
      _appUser = null;
      _status = AuthStatus.needsVerification;
      notifyListeners();
      return;
    }

    await _loadProfile(user.uid);
  }

  Future<void> _loadProfile(String uid) async {
    try {
      final profile = await _service.fetchUser(uid);
      if (profile == null) {
        _errorMessage = 'Your profile could not be found. Please register again.';
        await _service.logout();
        return;
      }
      _appUser = profile;
      _status = AuthStatus.signedIn;
    } catch (_) {
      _errorMessage = 'Could not load your profile. Check your connection.';
      await _service.logout();
      return;
    }
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _run(() => _service.register(
          fullName: fullName,
          email: email,
          password: password,
        ));
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final ok = await _run(
      () => _service.login(email: email, password: password),
    );
    if (ok) await _onAuthChanged(_service.currentUser);
    return ok;
  }

  Future<bool> resendVerification() {
    return _run(() => _service.resendVerification());
  }

  Future<bool> sendPasswordReset(String email) {
    return _run(() => _service.sendPasswordReset(email));
  }

  Future<bool> checkVerified() async {
    final verified = await _service.reloadAndCheckVerified();
    if (verified) await _onAuthChanged(_service.currentUser);
    return verified;
  }

  Future<void> logout() => _service.logout();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}