import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const List<String> allowedDomains = [
    '@alustudent.com',
    '@alueducation.com',
  ];

  static bool isAllowedEmail(String email) {
    final value = email.trim().toLowerCase();
    return allowedDomains.any((domain) => value.endsWith(domain));
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (!isAllowedEmail(cleanEmail)) {
      throw AuthException('Please use your ALU email address.');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final user = credential.user!;

      await user.updateDisplayName(fullName.trim());

      final appUser = AppUser(
        uid: user.uid,
        email: cleanEmail,
        fullName: fullName.trim(),
        role: UserRole.student,
      );
      await _db.collection('users').doc(user.uid).set(appUser.toMap());

      await user.sendEmailVerification();
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = credential.user!;
      await user.reload();

      if (!_auth.currentUser!.emailVerified) {
        throw AuthException(
          'Your email is not verified yet. Check your inbox for the verification link.',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  Future<void> resendVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  Future<bool> reloadAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}