import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// Firebase-backed authentication repository for Google, Apple, Email/Password,
/// and Guest (anonymous) sessions with automatic Firestore `users/{uid}` sync.
class FirebaseAuthRepository implements AuthRepository {
  /// Web OAuth 2.0 Client ID from `google-services.json` (`client_type: 3`)
  /// used as `serverClientId` on Android to guarantee ID token generation
  /// across both Debug and Release builds.
  static const String kAndroidServerClientId =
      '290994395081-e264r5151650pr8iiltutrfdp2anqdgj.apps.googleusercontent.com';

  final FirebaseAuth _auth;
  final FirebaseFirestore? _firestore;
  final GoogleSignIn _googleSignIn;
  final StreamController<AppUser?> _manualReloadController =
      StreamController<AppUser?>.broadcast();
  Future<void>? _googleInitFuture;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  bool get _isApplePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  String _resolveProviderId(User user) {
    if (user.isAnonymous) return 'anonymous';
    for (final info in user.providerData) {
      final pid = info.providerId;
      if (pid == 'google.com' || pid == 'apple.com' || pid == 'password') {
        return pid;
      }
    }
    if (user.providerData.isNotEmpty) {
      return user.providerData.first.providerId;
    }
    return 'password';
  }

  AppUser? _firebaseUserToAppUser(User? user) {
    if (user == null) return null;
    String? displayName = user.displayName;
    String? email = user.email;
    String? photoUrl = user.photoURL;

    for (final info in user.providerData) {
      if ((displayName == null || displayName.isEmpty) &&
          (info.displayName?.isNotEmpty ?? false)) {
        displayName = info.displayName;
      }
      if ((email == null || email.isEmpty) &&
          (info.email?.isNotEmpty ?? false)) {
        email = info.email;
      }
      if ((photoUrl == null || photoUrl.isEmpty) &&
          (info.photoURL?.isNotEmpty ?? false)) {
        photoUrl = info.photoURL;
      }
    }

    return AppUser(
      uid: user.uid,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      isAnonymous: user.isAnonymous,
      emailVerified: user.emailVerified,
      providerId: _resolveProviderId(user),
    );
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return Stream<AppUser?>.multi((controller) {
      final sub1 = _auth.userChanges().listen(
        (user) => controller.add(_firebaseUserToAppUser(user)),
        onError: controller.addError,
      );
      final sub2 = _manualReloadController.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      controller.onCancel = () async {
        await sub1.cancel();
        await sub2.cancel();
      };
    });
  }

  @override
  AppUser? get currentUser => _firebaseUserToAppUser(_auth.currentUser);

  /// Synchronizes the authenticated user's profile document at `users/{uid}`
  /// without overwriting existing game statistics (ELO, wins, losses, streak).
  Future<void> _syncUserProfileToFirestore(
    User user, {
    String? explicitDisplayName,
    String? explicitProvider,
  }) async {
    try {
      final docRef = _db.collection('users').doc(user.uid);
      final snapshot = await docRef.get();
      final existing = snapshot.data() ?? <String, dynamic>{};

      final provider = explicitProvider ?? _resolveProviderId(user);
      final resolvedName =
          (explicitDisplayName != null && explicitDisplayName.trim().isNotEmpty)
          ? explicitDisplayName.trim()
          : (existing['customDisplayName'] as String?)?.isNotEmpty == true
          ? existing['customDisplayName'] as String
          : (user.displayName?.isNotEmpty == true)
          ? user.displayName!
          : (existing['displayName'] as String?)?.isNotEmpty == true
          ? existing['displayName'] as String
          : (user.email?.isNotEmpty == true)
          ? user.email!.split('@').first
          : (user.isAnonymous ? 'Misafir Oyuncu' : 'Futbol Menajeri');

      final int gamesPlayed = (existing['gamesPlayed'] as num?)?.toInt() ?? 0;
      final int wins = (existing['wins'] as num?)?.toInt() ?? 0;
      final int losses = (existing['losses'] as num?)?.toInt() ?? 0;
      final int draws = (existing['draws'] as num?)?.toInt() ?? 0;
      final int streak =
          (existing['currentStreak'] as num?)?.toInt() ??
          (existing['streak'] as num?)?.toInt() ??
          0;
      final int bestStreak = (existing['bestStreak'] as num?)?.toInt() ?? 0;
      final int bestScore = (existing['bestScore'] as num?)?.toInt() ?? 0;
      final int elo =
          (existing['rating'] as num?)?.toInt() ??
          (existing['elo'] as num?)?.toInt() ??
          AppConstants.initialRating;
      final int xp =
          (existing['xp'] as num?)?.toInt() ??
          ((gamesPlayed * 40) + (wins * 80));
      final int level =
          (existing['level'] as num?)?.toInt() ?? ((xp ~/ 200) + 1);

      final payload = <String, dynamic>{
        'uid': user.uid,
        'displayName': resolvedName,
        'email': user.email ?? existing['email'],
        'photoURL': user.photoURL ?? existing['photoURL'],
        'provider': provider,
        'emailVerified': user.emailVerified || provider == 'google.com',
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Preserve existing game stats or initialize defaults on first sign-up
        'elo': elo,
        'rating': elo,
        'level': level,
        'xp': xp,
        'gamesPlayed': gamesPlayed,
        'wins': wins,
        'losses': losses,
        'draws': draws,
        'streak': streak,
        'currentStreak': streak,
        'bestStreak': bestStreak,
        'bestScore': bestScore,
        'country': existing['country'] as String? ?? 'TR',
      };

      if (!snapshot.exists || existing['createdAt'] == null) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(payload, SetOptions(merge: true));
    } catch (_) {
      // Offline or Firestore rules restricted in test environment; non-fatal.
    }
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    if (cred.user != null) {
      await _syncUserProfileToFirestore(
        cred.user!,
        explicitProvider: 'anonymous',
      );
    }
    return cred;
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In (Debug & Release Production Ready)
  // ---------------------------------------------------------------------------

  Future<void> _ensureGoogleInitialized() {
    return _googleInitFuture ??= _googleSignIn.initialize(
      serverClientId: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? kAndroidServerClientId
          : null,
    );
  }

  Future<OAuthCredential> _obtainGoogleCredential() async {
    await _ensureGoogleInitialized();
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        throw FirebaseAuthException(
          code: 'google-sign-in-config-error',
          message: 'Google kimlik doğrulama anahtarı (idToken) alınamadı.',
        );
      }
      return GoogleAuthProvider.credential(idToken: googleAuth.idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw FirebaseAuthException(
          code: 'aborted',
          message: 'Google ile giriş iptal edildi.',
        );
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw FirebaseAuthException(
          code: 'google-sign-in-config-error',
          message:
              'Google OAuth / SHA sertifika yapılandırma hatası: ${e.description ?? e.code.name}',
        );
      }
      if (e.code == GoogleSignInExceptionCode.uiUnavailable) {
        throw FirebaseAuthException(
          code: 'google-play-services-unavailable',
          message: 'Google Play Hizmetleri kullanılamıyor.',
        );
      }
      final desc = (e.description ?? '').toLowerCase();
      if (desc.contains('network') || desc.contains('7:')) {
        throw FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Ağ bağlantısı hatası.',
        );
      }
      if (desc.contains('10:') || desc.contains('developer_error')) {
        throw FirebaseAuthException(
          code: 'google-sign-in-config-error',
          message:
              'Google Sign-In SHA-1 / OAuth yapılandırma hatası (DEVELOPER_ERROR).',
        );
      }
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google ile giriş başarısız: ${e.description ?? e.code.name}',
      );
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      final msg = (e.message ?? '').toLowerCase();
      if (code.contains('cancel') ||
          msg.contains('cancel') ||
          msg.contains('12501')) {
        throw FirebaseAuthException(
          code: 'aborted',
          message: 'Google ile giriş iptal edildi.',
        );
      }
      if (code.contains('network') || msg.contains('network')) {
        throw FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Ağ bağlantısı hatası.',
        );
      }
      if (msg.contains('10:') || msg.contains('developer_error')) {
        throw FirebaseAuthException(
          code: 'google-sign-in-config-error',
          message: 'Google Sign-In SHA-1 / OAuth yapılandırma hatası.',
        );
      }
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: e.message ?? 'Google ile giriş başarısız.',
      );
    }
  }

  GoogleAuthProvider get _googleWebProvider => GoogleAuthProvider()
    ..addScope('email')
    ..addScope('profile')
    ..setCustomParameters({'prompt': 'select_account'});

  @override
  Future<UserCredential> signInWithGoogle() async {
    UserCredential cred;
    if (kIsWeb) {
      cred = await _auth.signInWithPopup(_googleWebProvider);
    } else {
      final credential = await _obtainGoogleCredential();
      // If currently signed in anonymously, try linking first; if the Google
      // account already exists, seamlessly sign into that existing account.
      final current = _auth.currentUser;
      if (current != null && current.isAnonymous) {
        try {
          cred = await current.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' ||
              e.code == 'email-already-in-use' ||
              e.code == 'account-exists-with-different-credential') {
            cred = await _auth.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      } else {
        cred = await _auth.signInWithCredential(credential);
      }
    }

    if (cred.user != null) {
      await _syncUserProfileToFirestore(
        cred.user!,
        explicitProvider: 'google.com',
      );
      _manualReloadController.add(_firebaseUserToAppUser(_auth.currentUser));
    }
    return cred;
  }

  // ---------------------------------------------------------------------------
  // Apple Sign-In
  // ---------------------------------------------------------------------------

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  AppleAuthProvider get _appleProvider => AppleAuthProvider()
    ..addScope('email')
    ..addScope('name');

  Future<OAuthCredential> _obtainNativeAppleCredential() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      return OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw FirebaseAuthException(
          code: 'aborted',
          message: 'Apple ile giriş iptal edildi.',
        );
      }
      throw FirebaseAuthException(
        code: 'apple-sign-in-failed',
        message: 'Apple ile giriş başarısız: ${e.message}',
      );
    }
  }

  Future<void> _updateAppleDisplayNameIfMissing(UserCredential cred) async {
    final user = cred.user;
    if (user == null) return;
    if ((user.displayName ?? '').isEmpty && (user.email ?? '').isNotEmpty) {
      await user.updateDisplayName(user.email!.split('@').first);
    }
  }

  @override
  Future<UserCredential> signInWithApple() async {
    UserCredential cred;
    if (kIsWeb) {
      cred = await _auth.signInWithPopup(_appleProvider);
    } else if (_isApplePlatform) {
      final credential = await _obtainNativeAppleCredential();
      cred = await _auth.signInWithCredential(credential);
    } else {
      cred = await _auth.signInWithProvider(_appleProvider);
    }
    await _updateAppleDisplayNameIfMissing(cred);
    if (cred.user != null) {
      await _syncUserProfileToFirestore(
        cred.user!,
        explicitProvider: 'apple.com',
      );
      _manualReloadController.add(_firebaseUserToAppUser(_auth.currentUser));
    }
    return cred;
  }

  // ---------------------------------------------------------------------------
  // Email & Password Sign-In, Registration, Password Reset & Verification
  // ---------------------------------------------------------------------------

  @override
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (cred.user != null) {
      await _syncUserProfileToFirestore(
        cred.user!,
        explicitProvider: 'password',
      );
      _manualReloadController.add(_firebaseUserToAppUser(_auth.currentUser));
    }
    return cred;
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedName = displayName?.trim();

    final cred = await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final user = cred.user;
    if (user != null) {
      if (trimmedName != null && trimmedName.isNotEmpty) {
        await user.updateDisplayName(trimmedName);
        await user.reload();
      }

      final refreshedUser = _auth.currentUser ?? user;
      await _syncUserProfileToFirestore(
        refreshedUser,
        explicitDisplayName: trimmedName,
        explicitProvider: 'password',
      );

      if (!refreshedUser.emailVerified) {
        try {
          await refreshedUser.sendEmailVerification();
        } catch (_) {
          // Do not fail registration if verification email hits rate-limit;
          // user can resend on the verification screen.
        }
      }
      _manualReloadController.add(_firebaseUserToAppUser(_auth.currentUser));
    }

    return cred;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'Şu anda giriş yapmış bir kullanıcı yok.',
      );
    }
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<AppUser?> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload();
    final updated = _auth.currentUser;
    if (updated != null) {
      await _syncUserProfileToFirestore(updated);
    }
    final appUser = _firebaseUserToAppUser(updated);
    _manualReloadController.add(appUser);
    return appUser;
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return;
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(trimmed);
    await user.reload();
    final updated = _auth.currentUser;
    if (updated != null) {
      await _syncUserProfileToFirestore(updated, explicitDisplayName: trimmed);
    }
    _manualReloadController.add(_firebaseUserToAppUser(updated));
  }

  // ---------------------------------------------------------------------------
  // Guest -> Permanent Account Linking
  // ---------------------------------------------------------------------------

  User _requireAnonymousUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'Şu anda giriş yapmış bir kullanıcı yok.',
      );
    }
    if (!user.isAnonymous) {
      throw FirebaseAuthException(
        code: 'not-anonymous',
        message: 'Bu hesap zaten kalıcı bir hesaba bağlı.',
      );
    }
    return user;
  }

  @override
  Future<void> linkAnonymousWithGoogle() async {
    final user = _requireAnonymousUser();
    if (kIsWeb) {
      await user.linkWithPopup(_googleWebProvider);
    } else {
      final credential = await _obtainGoogleCredential();
      await user.linkWithCredential(credential);
    }
    await user.reload();
    if (_auth.currentUser != null) {
      await _syncUserProfileToFirestore(
        _auth.currentUser!,
        explicitProvider: 'google.com',
      );
      _manualReloadController.add(_firebaseUserToAppUser(_auth.currentUser));
    }
  }

  @override
  Future<void> linkAnonymousWithApple() async {
    final user = _requireAnonymousUser();
    if (kIsWeb) {
      await user.linkWithPopup(_appleProvider);
    } else if (_isApplePlatform) {
      final credential = await _obtainNativeAppleCredential();
      await user.linkWithCredential(credential);
    } else {
      await user.linkWithProvider(_appleProvider);
    }
    await user.reload();
    if (_auth.currentUser != null) {
      await _syncUserProfileToFirestore(
        _auth.currentUser!,
        explicitProvider: 'apple.com',
      );
      _manualReloadController.add(_firebaseUserToAppUser(_auth.currentUser));
    }
  }

  @override
  Future<void> linkAnonymousWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final user = _requireAnonymousUser();
    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );
    await user.linkWithCredential(credential);
    if (displayName != null && displayName.trim().isNotEmpty) {
      await user.updateDisplayName(displayName.trim());
    }
    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed != null) {
      await _syncUserProfileToFirestore(
        refreshed,
        explicitDisplayName: displayName,
        explicitProvider: 'password',
      );
      try {
        await refreshed.sendEmailVerification();
      } catch (_) {}
      _manualReloadController.add(_firebaseUserToAppUser(refreshed));
    }
  }

  // ---------------------------------------------------------------------------
  // Account Deletion & Sign Out
  // ---------------------------------------------------------------------------

  @override
  Future<void> deleteAccount({String? currentPassword}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'Şu anda giriş yapmış bir kullanıcı yok.',
      );
    }

    final uid = user.uid;
    final provider = _resolveProviderId(user);

    // Re-authenticate if required
    if (provider == 'password' &&
        user.email != null &&
        currentPassword != null &&
        currentPassword.isNotEmpty) {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
    } else if (provider == 'google.com' && !kIsWeb) {
      try {
        final cred = await _obtainGoogleCredential();
        await user.reauthenticateWithCredential(cred);
      } catch (_) {
        // Proceed to delete; if token is still fresh, delete() will succeed.
      }
    }

    // Delete user profile & leaderboard entry from Firestore first while still authenticated
    try {
      await _db.collection('users').doc(uid).delete();
      await _db.collection('leaderboards').doc(uid).delete();
    } catch (_) {}

    await user.delete();

    if (!kIsWeb) {
      try {
        await _ensureGoogleInitialized();
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    _manualReloadController.add(null);
  }

  @override
  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _ensureGoogleInitialized();
        await _googleSignIn.signOut();
      } catch (_) {
        // Google may not be signed in; ignore.
      }
    }
    await _auth.signOut();
    _manualReloadController.add(null);
  }
}
