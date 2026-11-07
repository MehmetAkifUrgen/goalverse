import 'package:firebase_auth/firebase_auth.dart';

import 'app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<UserCredential> signInAnonymously();
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithApple();
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  });
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<AppUser?> reloadUser();
  Future<void> updateDisplayName(String displayName);
  Future<void> linkAnonymousWithGoogle();
  Future<void> linkAnonymousWithApple();
  Future<void> linkAnonymousWithEmail({
    required String email,
    required String password,
    String? displayName,
  });
  Future<void> deleteAccount({String? currentPassword});
  Future<void> signOut();
}
