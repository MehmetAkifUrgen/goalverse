import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_tic_tac_toe/core/constants/app_constants.dart';
import 'package:football_tic_tac_toe/core/providers/auth_providers.dart';
import 'package:football_tic_tac_toe/core/routing/app_router.dart';
import 'package:football_tic_tac_toe/core/theme/app_theme.dart';
import 'package:football_tic_tac_toe/features/auth/domain/app_user.dart';
import 'package:football_tic_tac_toe/features/auth/domain/auth_error_mapper.dart';
import 'package:football_tic_tac_toe/features/auth/domain/auth_repository.dart';
import 'package:football_tic_tac_toe/features/auth/presentation/email_verification_screen.dart';
import 'package:football_tic_tac_toe/features/auth/presentation/forgot_password_screen.dart';
import 'package:football_tic_tac_toe/features/auth/presentation/login_screen.dart';
import 'package:football_tic_tac_toe/l10n/app_localizations.dart';

class FakeAuthRepository implements AuthRepository {
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  Object? nextError;
  String? lastSignInEmail;
  String? lastSignUpEmail;
  String? lastSignUpName;
  String? lastResetEmail;
  int verificationEmailsSent = 0;
  bool reloadMarksVerified = false;

  FakeAuthRepository({AppUser? initialUser}) : _currentUser = initialUser;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  AppUser? get currentUser => _currentUser;

  void _emit(AppUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  void _throwIfNeeded() {
    if (nextError != null) {
      final err = nextError!;
      nextError = null;
      throw err;
    }
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    _throwIfNeeded();
    _emit(
      const AppUser(
        uid: 'guest_1',
        displayName: 'Misafir Oyuncu',
        isAnonymous: true,
        emailVerified: false,
        providerId: 'anonymous',
      ),
    );
    return _FakeUserCredential();
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    _throwIfNeeded();
    _emit(
      const AppUser(
        uid: 'google_1',
        displayName: 'Arda Güler',
        email: 'arda@example.com',
        photoUrl: 'https://example.com/photo.png',
        isAnonymous: false,
        emailVerified: true,
        providerId: 'google.com',
      ),
    );
    return _FakeUserCredential();
  }

  @override
  Future<UserCredential> signInWithApple() async {
    _throwIfNeeded();
    _emit(
      const AppUser(
        uid: 'apple_1',
        displayName: 'Hakan Çalhanoğlu',
        email: 'hakan@example.com',
        isAnonymous: false,
        emailVerified: true,
        providerId: 'apple.com',
      ),
    );
    return _FakeUserCredential();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _throwIfNeeded();
    lastSignInEmail = email;
    _emit(
      AppUser(
        uid: 'email_1',
        displayName: 'Test Oyuncu',
        email: email,
        isAnonymous: false,
        emailVerified: true,
        providerId: 'password',
      ),
    );
    return _FakeUserCredential();
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    _throwIfNeeded();
    lastSignUpEmail = email;
    lastSignUpName = displayName;
    verificationEmailsSent++;
    _emit(
      AppUser(
        uid: 'new_email_1',
        displayName: displayName,
        email: email,
        isAnonymous: false,
        emailVerified: false,
        providerId: 'password',
      ),
    );
    return _FakeUserCredential();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    _throwIfNeeded();
    lastResetEmail = email;
  }

  @override
  Future<void> sendEmailVerification() async {
    _throwIfNeeded();
    verificationEmailsSent++;
  }

  @override
  Future<AppUser?> reloadUser() async {
    _throwIfNeeded();
    if (_currentUser != null && reloadMarksVerified) {
      _emit(_currentUser!.copyWith(emailVerified: true));
    }
    return _currentUser;
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    _throwIfNeeded();
    if (_currentUser != null) {
      _emit(_currentUser!.copyWith(displayName: displayName));
    }
  }

  @override
  Future<void> linkAnonymousWithGoogle() async {
    _throwIfNeeded();
  }

  @override
  Future<void> linkAnonymousWithApple() async {
    _throwIfNeeded();
  }

  @override
  Future<void> linkAnonymousWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _throwIfNeeded();
  }

  @override
  Future<void> deleteAccount({String? currentPassword}) async {
    _throwIfNeeded();
    _emit(null);
  }

  @override
  Future<void> signOut() async {
    _emit(null);
  }
}

class _FakeUserCredential implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _buildTestApp({
  required Widget child,
  required FakeAuthRepository fakeRepo,
  AppUser? currentUser,
  Locale locale = const Locale('tr'),
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(fakeRepo),
      authStateProvider.overrideWith(
        (ref) => Stream<AppUser?>.value(currentUser ?? fakeRepo.currentUser),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  group('1. AppUser & Email Verification Rules', () {
    test(
      'Google, Apple, and Guest users do not require email verification',
      () {
        const googleUser = AppUser(
          uid: 'g1',
          email: 'user@gmail.com',
          isAnonymous: false,
          emailVerified: false,
          providerId: 'google.com',
        );
        const guestUser = AppUser(
          uid: 'anon1',
          isAnonymous: true,
          emailVerified: false,
          providerId: 'anonymous',
        );
        const unverifiedEmailUser = AppUser(
          uid: 'e1',
          email: 'user@domain.com',
          isAnonymous: false,
          emailVerified: false,
          providerId: 'password',
        );
        const verifiedEmailUser = AppUser(
          uid: 'e2',
          email: 'user@domain.com',
          isAnonymous: false,
          emailVerified: true,
          providerId: 'password',
        );

        expect(googleUser.requiresEmailVerification, isFalse);
        expect(guestUser.requiresEmailVerification, isFalse);
        expect(unverifiedEmailUser.requiresEmailVerification, isTrue);
        expect(verifiedEmailUser.requiresEmailVerification, isFalse);
      },
    );
  });

  group('2. GoRouter Auth Redirect Logic (computeAuthRedirect)', () {
    test(
      'Unauthenticated users are redirected to /auth from protected routes',
      () {
        const unauth = AsyncValue<AppUser?>.data(null);
        expect(
          computeAuthRedirect(authState: unauth, matchedLocation: '/home'),
          equals('/auth'),
        );
        expect(
          computeAuthRedirect(authState: unauth, matchedLocation: '/profile'),
          equals('/auth'),
        );
        expect(
          computeAuthRedirect(authState: unauth, matchedLocation: '/auth'),
          isNull,
        );
        expect(
          computeAuthRedirect(
            authState: unauth,
            matchedLocation: '/forgot-password',
          ),
          isNull,
        );
      },
    );

    test('Unverified password users are redirected to /verify-email', () {
      const unverified = AsyncValue<AppUser?>.data(
        AppUser(
          uid: 'u1',
          email: 'test@example.com',
          isAnonymous: false,
          emailVerified: false,
          providerId: 'password',
        ),
      );
      expect(
        computeAuthRedirect(authState: unverified, matchedLocation: '/home'),
        equals('/verify-email'),
      );
      expect(
        computeAuthRedirect(authState: unverified, matchedLocation: '/auth'),
        equals('/verify-email'),
      );
      expect(
        computeAuthRedirect(
          authState: unverified,
          matchedLocation: '/verify-email',
        ),
        isNull,
      );
    });

    test(
      'Verified or Google users are redirected to /home from /auth and /verify-email',
      () {
        const googleUser = AsyncValue<AppUser?>.data(
          AppUser(
            uid: 'g1',
            email: 'arda@gmail.com',
            isAnonymous: false,
            emailVerified: true,
            providerId: 'google.com',
          ),
        );
        expect(
          computeAuthRedirect(authState: googleUser, matchedLocation: '/auth'),
          equals('/home'),
        );
        expect(
          computeAuthRedirect(
            authState: googleUser,
            matchedLocation: '/verify-email',
          ),
          equals('/home'),
        );
        expect(
          computeAuthRedirect(authState: googleUser, matchedLocation: '/home'),
          isNull,
        );
      },
    );
  });

  group('3. AuthErrorMapper & User Cancellation Handling', () {
    test(
      'Canceled Google/Apple sign-in is detected and not treated as fatal error',
      () {
        final aborted = FirebaseAuthException(code: 'aborted');
        final wrongPass = FirebaseAuthException(code: 'wrong-password');
        expect(AuthErrorMapper.isUserCanceled(aborted), isTrue);
        expect(AuthErrorMapper.isUserCanceled(wrongPass), isFalse);
      },
    );
  });

  group('4. Login, Register, Forgot Password & Verification Widget Tests', () {
    testWidgets('Login form validates empty/invalid email and short password', (
      tester,
    ) async {
      final repo = FakeAuthRepository();
      await tester.pumpWidget(
        _buildTestApp(child: const LoginScreen(), fakeRepo: repo),
      );
      await tester.pumpAndSettle();

      expect(find.text('GOALVERSE'), findsOneWidget);
      expect(find.text('FOOTBALL ARENA'), findsNothing);
      expect(find.byKey(const Key('auth_submit_button')), findsOneWidget);
      expect(AppConstants.appName, equals('Goalverse'));
      expect(AppConstants.appBrandUpper, equals('GOALVERSE'));

      expect(find.text('GOALVERSE'), findsOneWidget);
      expect(find.text('FOOTBALL ARENA'), findsNothing);
      expect(find.byKey(const Key('auth_submit_button')), findsOneWidget);
      expect(AppConstants.appName, equals('Goalverse'));
      expect(AppConstants.appBrandUpper, equals('GOALVERSE'));

      await tester.tap(find.byKey(const Key('auth_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Geçersiz e-posta adresi'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('auth_email_field')),
        'oyuncu@futbol.com',
      );
      await tester.enterText(
        find.byKey(const Key('auth_password_field')),
        '123',
      );
      expect(find.text('GOALVERSE'), findsOneWidget);
      expect(find.text('FOOTBALL ARENA'), findsNothing);
      expect(find.byKey(const Key('auth_submit_button')), findsOneWidget);
      expect(AppConstants.appName, equals('Goalverse'));
      expect(AppConstants.appBrandUpper, equals('GOALVERSE'));

      expect(find.text('GOALVERSE'), findsOneWidget);
      expect(find.text('FOOTBALL ARENA'), findsNothing);
      expect(find.byKey(const Key('auth_submit_button')), findsOneWidget);
      expect(AppConstants.appName, equals('Goalverse'));
      expect(AppConstants.appBrandUpper, equals('GOALVERSE'));

      await tester.tap(find.byKey(const Key('auth_submit_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('En az 6 karakter'), findsOneWidget);
    });

    testWidgets(
      'Register form validates Full Name, Confirm Password match, and Terms approval',
      (tester) async {
        final repo = FakeAuthRepository();
        await tester.pumpWidget(
          _buildTestApp(
            child: const LoginScreen(initialRegisterMode: true),
            fakeRepo: repo,
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('register_name_field')),
          'Arda Güler',
        );
        await tester.enterText(
          find.byKey(const Key('auth_email_field')),
          'arda@realmadrid.com',
        );
        await tester.enterText(
          find.byKey(const Key('auth_password_field')),
          'secret123',
        );
        await tester.enterText(
          find.byKey(const Key('register_confirm_password_field')),
          'different123',
        );

        final submitFinder = find.byKey(const Key('auth_submit_button'));
        await tester.ensureVisible(submitFinder);
        await tester.pumpAndSettle();
        await tester.tap(submitFinder);
        await tester.pumpAndSettle();

        expect(find.text('Şifreler birbiriyle eşleşmiyor.'), findsOneWidget);

        // Fix confirm password, leave terms unchecked
        await tester.enterText(
          find.byKey(const Key('register_confirm_password_field')),
          'secret123',
        );
        await tester.ensureVisible(submitFinder);
        await tester.pumpAndSettle();
        await tester.tap(submitFinder);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('auth_error_banner')), findsOneWidget);
        expect(repo.lastSignUpEmail, isNull);
      },
    );

    testWidgets('Canceled Google sign-in does not show an error banner', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..nextError = FirebaseAuthException(code: 'aborted');
      await tester.pumpWidget(
        _buildTestApp(child: const LoginScreen(), fakeRepo: repo),
      );
      await tester.pumpAndSettle();

      final googleBtn = find.byKey(const Key('google_sign_in_button'));
      await tester.ensureVisible(googleBtn);
      await tester.pumpAndSettle();
      await tester.tap(googleBtn);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth_error_banner')), findsNothing);
    });

    testWidgets(
      'ForgotPasswordScreen sends password reset email and shows confirmation view',
      (tester) async {
        final repo = FakeAuthRepository();
        await tester.pumpWidget(
          _buildTestApp(
            child: const ForgotPasswordScreen(initialEmail: 'kaptan@arena.com'),
            fakeRepo: repo,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sıfırlama Bağlantısı Gönder'));
        await tester.pumpAndSettle();

        expect(repo.lastResetEmail, equals('kaptan@arena.com'));
        expect(find.text('Sıfırlama Bağlantısı Gönderildi'), findsOneWidget);
      },
    );

    testWidgets(
      'EmailVerificationScreen displays user email and cooldown state',
      (tester) async {
        const unverified = AppUser(
          uid: 'u99',
          email: 'dogrula@arena.com',
          isAnonymous: false,
          emailVerified: false,
          providerId: 'password',
        );
        final repo = FakeAuthRepository(initialUser: unverified);
        await tester.pumpWidget(
          _buildTestApp(
            child: const EmailVerificationScreen(),
            fakeRepo: repo,
            currentUser: unverified,
          ),
        );
        await tester.pump();

        expect(find.textContaining('dogrula@arena.com'), findsOneWidget);
        expect(find.textContaining('Tekrar Gönder ('), findsOneWidget);
      },
    );
  });
}
