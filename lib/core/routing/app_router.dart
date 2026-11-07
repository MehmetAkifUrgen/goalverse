import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/app_user.dart';
import '../../features/auth/presentation/email_verification_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/link_account_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/daily_challenge/presentation/daily_challenge_page.dart';
import '../../features/football_bomb/presentation/football_bomb_page.dart';
import '../../features/game/presentation/game_page.dart';
import '../../features/game/presentation/online_game_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/imposter/presentation/imposter_page.dart';
import '../../features/leaderboard/presentation/leaderboard_page.dart';
import '../../features/monetization/presentation/cosmetic_store_page.dart';
import '../../features/monetization/presentation/premium_paywall_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/rating_battle/presentation/rating_battle_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/transfer_path/presentation/transfer_path_page.dart';
import '../../features/two_teams/presentation/two_teams_page.dart';
import '../../features/who_am_i/presentation/who_am_i_page.dart';
import '../providers/auth_providers.dart';

/// Pure helper function for computing auth redirects, exposed for unit testing
/// and GoRouter redirect evaluation.
String? computeAuthRedirect({
  required AsyncValue<AppUser?> authState,
  required String matchedLocation,
}) {
  if (authState.isLoading || authState.isRefreshing) {
    return null;
  }

  final user = authState.valueOrNull;
  final isPublicAuthRoute =
      matchedLocation == '/auth' ||
      matchedLocation == '/register' ||
      matchedLocation == '/forgot-password';
  final isVerifyRoute = matchedLocation == '/verify-email';

  if (user == null) {
    return isPublicAuthRoute ? null : '/auth';
  }

  if (user.requiresEmailVerification) {
    return isVerifyRoute ? null : '/verify-email';
  }

  if (isPublicAuthRoute || isVerifyRoute) {
    return '/home';
  }

  return null;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRefreshNotifier = ValueNotifier<int>(0);
  ref.onDispose(authRefreshNotifier.dispose);

  ref.listen<AsyncValue<AppUser?>>(authStateProvider, (_, _) {
    authRefreshNotifier.value++;
  });

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: authRefreshNotifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      return computeAuthRedirect(
        authState: authState,
        matchedLocation: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) =>
            const LoginScreen(initialRegisterMode: true),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => ForgotPasswordScreen(
          initialEmail: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/game/:id',
        name: 'game',
        builder: (context, state) {
          final matchId = state.pathParameters['id'] ?? '';
          final roundsParam = int.tryParse(
            state.uri.queryParameters['rounds'] ?? '',
          );
          return GamePage(
            matchId: matchId,
            initialTotalRounds: (roundsParam == 5 || roundsParam == 3)
                ? roundsParam!
                : 3,
          );
        },
      ),
      GoRoute(
        path: '/online-game/:id',
        name: 'online-game',
        builder: (context, state) {
          final gameId = state.pathParameters['id'] ?? '';
          return OnlineGamePage(gameId: gameId);
        },
      ),
      GoRoute(
        path: '/rating-battle',
        name: 'rating-battle',
        builder: (context, state) => RatingBattlePage(
          roomId: state.uri.queryParameters['roomId'],
          initialDuel: state.uri.queryParameters['duel'] == '1',
        ),
      ),
      GoRoute(
        path: '/two-teams',
        name: 'two-teams',
        builder: (context, state) => TwoTeamsPage(
          roomId: state.uri.queryParameters['roomId'],
          initialDuel: state.uri.queryParameters['duel'] == '1',
        ),
      ),
      GoRoute(
        path: '/who-am-i',
        name: 'who-am-i',
        builder: (context, state) => WhoAmIPage(
          roomId: state.uri.queryParameters['roomId'],
          initialDuel: state.uri.queryParameters['duel'] == '1',
        ),
      ),
      GoRoute(
        path: '/imposter',
        name: 'imposter',
        builder: (context, state) => ImposterPage(
          roomId: state.uri.queryParameters['roomId'],
          initialDuel: state.uri.queryParameters['duel'] == '1',
        ),
      ),
      GoRoute(
        path: '/transfer-path',
        name: 'transfer-path',
        builder: (context, state) => TransferPathPage(
          roomId: state.uri.queryParameters['roomId'],
          initialDuel: state.uri.queryParameters['duel'] == '1',
        ),
      ),
      GoRoute(
        path: '/football-bomb',
        name: 'football-bomb',
        builder: (context, state) => FootballBombPage(
          roomId: state.uri.queryParameters['roomId'],
          initialDuel: state.uri.queryParameters['duel'] == '1',
        ),
      ),
      GoRoute(
        path: '/daily-challenge',
        name: 'daily-challenge',
        builder: (context, state) => const DailyChallengePage(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumPaywallPage(),
      ),
      GoRoute(
        path: '/store',
        name: 'store',
        builder: (context, state) => const CosmeticStorePage(),
      ),
      GoRoute(
        path: '/link-account',
        name: 'link-account',
        builder: (context, state) => const LinkAccountScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.error}'))),
  );
});

@Deprecated('Use appRouterProvider instead for auth-aware routing')
class AppRouter {
  static GoRouter get router =>
      throw UnsupportedError('Use appRouterProvider from Riverpod instead.');
}
