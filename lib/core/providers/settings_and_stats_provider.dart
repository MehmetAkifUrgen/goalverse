import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'auth_providers.dart';

class AppSettingsState {
  final ThemeMode themeMode;
  final Locale? locale;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final String difficulty; // 'easy', 'medium', 'hard'

  const AppSettingsState({
    this.themeMode = ThemeMode.dark,
    this.locale,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.difficulty = 'medium',
  });

  int get turnSeconds => switch (difficulty) {
    'easy' => 25,
    'hard' => 12,
    _ => 18,
  };

  double get scoreMultiplier => switch (difficulty) {
    'easy' => 1.0,
    'hard' => 1.5,
    _ => 1.2,
  };

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
    String? difficulty,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  static const _themeKey = 'settings_theme_mode';
  static const _localeKey = 'settings_locale';
  static const _notifKey = 'settings_notifications';
  static const _soundKey = 'settings_sound';
  static const _hapticsKey = 'settings_haptics';
  static const _difficultyKey = 'settings_difficulty';

  AppSettingsNotifier() : super(const AppSettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_themeKey) ?? 'dark';
    final localeStr = prefs.getString(_localeKey);
    final notif = prefs.getBool(_notifKey) ?? true;
    final sound = prefs.getBool(_soundKey) ?? true;
    final haptics = prefs.getBool(_hapticsKey) ?? true;
    final diff = prefs.getString(_difficultyKey) ?? 'medium';

    final themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    state = AppSettingsState(
      themeMode: themeMode,
      locale: (localeStr != null && localeStr.isNotEmpty)
          ? Locale(localeStr)
          : null,
      notificationsEnabled: notif,
      soundEnabled: sound,
      hapticsEnabled: haptics,
      difficulty: diff,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeKey, str);
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: locale, clearLocale: locale == null);
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, enabled);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, enabled);
  }

  Future<void> setDifficulty(String difficulty) async {
    state = state.copyWith(difficulty: difficulty);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_difficultyKey, difficulty);
  }

  void triggerSuccessHaptic() {
    if (state.hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void triggerErrorHaptic() {
    if (state.hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
      return AppSettingsNotifier();
    });

class MatchHistorySummary {
  final String outcome; // 'win', 'draw', 'loss'
  final int score;
  final int ratingDelta;
  final int passesUsed;
  final bool endedByDrawOffer;
  final int timestampMs;

  const MatchHistorySummary({
    required this.outcome,
    required this.score,
    required this.ratingDelta,
    this.passesUsed = 0,
    this.endedByDrawOffer = false,
    required this.timestampMs,
  });

  Map<String, dynamic> toJson() => {
    'outcome': outcome,
    'score': score,
    'ratingDelta': ratingDelta,
    'passesUsed': passesUsed,
    'endedByDrawOffer': endedByDrawOffer,
    'timestampMs': timestampMs,
  };

  factory MatchHistorySummary.fromJson(Map<String, dynamic> json) {
    return MatchHistorySummary(
      outcome: json['outcome'] as String? ?? 'draw',
      score: (json['score'] as num?)?.toInt() ?? 0,
      ratingDelta: (json['ratingDelta'] as num?)?.toInt() ?? 0,
      passesUsed: (json['passesUsed'] as num?)?.toInt() ?? 0,
      endedByDrawOffer: json['endedByDrawOffer'] as bool? ?? false,
      timestampMs: (json['timestampMs'] as num?)?.toInt() ?? 0,
    );
  }
}

class UserStatsState {
  final int gamesPlayed;
  final int wins;
  final int losses;
  final int draws;
  final int bestScore;
  final int currentStreak;
  final int bestStreak;
  final int rating;
  final String country;
  final String? customDisplayName;
  final Set<String> unlockedAchievements;
  final Map<String, int> completedDailyChallenges;
  final List<MatchHistorySummary> recentMatches;

  const UserStatsState({
    this.gamesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.bestScore = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.rating = AppConstants.initialRating,
    this.country = 'TR',
    this.customDisplayName,
    this.unlockedAchievements = const {},
    this.completedDailyChallenges = const {},
    this.recentMatches = const [],
  });

  double get winRate => gamesPlayed == 0 ? 0.0 : (wins / gamesPlayed) * 100.0;

  bool isDailyCompleted(String dateKey) =>
      completedDailyChallenges.containsKey(dateKey);

  UserStatsState copyWith({
    int? gamesPlayed,
    int? wins,
    int? losses,
    int? draws,
    int? bestScore,
    int? currentStreak,
    int? bestStreak,
    int? rating,
    String? country,
    String? customDisplayName,
    Set<String>? unlockedAchievements,
    Map<String, int>? completedDailyChallenges,
    List<MatchHistorySummary>? recentMatches,
  }) {
    return UserStatsState(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      bestScore: bestScore ?? this.bestScore,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      rating: rating ?? this.rating,
      country: country ?? this.country,
      customDisplayName: customDisplayName ?? this.customDisplayName,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      completedDailyChallenges:
          completedDailyChallenges ?? this.completedDailyChallenges,
      recentMatches: recentMatches ?? this.recentMatches,
    );
  }

  Map<String, dynamic> toJson() => {
    'gamesPlayed': gamesPlayed,
    'wins': wins,
    'losses': losses,
    'draws': draws,
    'bestScore': bestScore,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'rating': rating,
    'country': country,
    if (customDisplayName != null) 'customDisplayName': customDisplayName,
    'unlockedAchievements': unlockedAchievements.toList(),
    'completedDailyChallenges': completedDailyChallenges,
    'recentMatches': recentMatches.map((m) => m.toJson()).toList(),
  };

  factory UserStatsState.fromJson(Map<String, dynamic> json) {
    final rawDaily =
        json['completedDailyChallenges'] as Map<String, dynamic>? ?? {};
    final rawMatches = json['recentMatches'] as List<dynamic>? ?? const [];
    return UserStatsState(
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? AppConstants.initialRating,
      country: json['country'] as String? ?? 'TR',
      customDisplayName: json['customDisplayName'] as String?,
      unlockedAchievements:
          (json['unlockedAchievements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          const {},
      completedDailyChallenges: rawDaily.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      recentMatches: rawMatches
          .whereType<Map>()
          .map(
            (e) => MatchHistorySummary.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}

class UserStatsNotifier extends StateNotifier<UserStatsState> {
  static const _storageKey = 'user_stats_v1';
  final String? _uid;

  UserStatsNotifier({String? uid}) : _uid = uid, super(const UserStatsState()) {
    _load();
  }

  String get _scopedStorageKey =>
      (_uid != null && _uid.isNotEmpty) ? '${_storageKey}_$_uid' : _storageKey;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw =
        prefs.getString(_scopedStorageKey) ?? prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        state = UserStatsState.fromJson(decoded);
      } catch (_) {}
    }

    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {
      user = null;
    }

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final remote = UserStatsState.fromJson(data);
          if (remote.gamesPlayed >= state.gamesPlayed ||
              (remote.customDisplayName?.isNotEmpty ?? false)) {
            state = remote;
            await _saveLocal();
          } else {
            await _syncRemote();
          }
        } else {
          await _syncRemote();
        }
      } catch (_) {}
    }
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.toJson());
    await prefs.setString(_scopedStorageKey, encoded);
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> _syncRemote() async {
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {
      return;
    }
    if (user == null) return;
    try {
      final resolvedName = (state.customDisplayName?.isNotEmpty ?? false)
          ? state.customDisplayName!
          : (user.displayName ??
                (user.isAnonymous
                    ? 'Goalverse Oyuncusu'
                    : user.email?.split('@').first ?? 'Player'));
      final xp = (state.gamesPlayed * 40) + (state.wins * 80);
      final level = (xp ~/ 200) + 1;
      final provider = user.isAnonymous
          ? 'anonymous'
          : (user.providerData.isNotEmpty
                ? user.providerData.first.providerId
                : 'password');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        ...state.toJson(),
        'uid': user.uid,
        'displayName': resolvedName,
        'email': user.email,
        'photoURL': user.photoURL,
        'provider': provider,
        'emailVerified': user.emailVerified || provider == 'google.com',
        'elo': state.rating,
        'level': level,
        'xp': xp,
        'streak': state.currentStreak,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> recordGameResult({
    required bool won,
    bool draw = false,
    required int score,
    bool isPerfect = false,
    bool isRare = false,
    bool isComeback = false,
    int passesUsed = 0,
    bool endedByDrawOffer = false,
  }) async {
    final newGames = state.gamesPlayed + 1;
    final newWins = won ? state.wins + 1 : state.wins;
    final newLosses = (!won && !draw) ? state.losses + 1 : state.losses;
    final newDraws = draw ? state.draws + 1 : state.draws;
    final newStreak = won
        ? state.currentStreak + 1
        : (draw ? state.currentStreak : 0);
    final newBestStreak = newStreak > state.bestStreak
        ? newStreak
        : state.bestStreak;
    final newBestScore = score > state.bestScore ? score : state.bestScore;

    final ratingDelta = won ? 25 : (draw ? 5 : -15);
    final newRating = (state.rating + ratingDelta).clamp(100, 9999);

    final achievements = Set<String>.from(state.unlockedAchievements);
    if (newWins >= 1) achievements.add('firstWin');
    if (newWins >= 10) achievements.add('wins10');
    if (newWins >= 100) achievements.add('wins100');
    if (newStreak >= 5) achievements.add('winStreak5');
    if (newStreak >= 10) achievements.add('winStreak10');
    if (isPerfect || score >= 900) achievements.add('perfectGame');
    if (isRare) achievements.add('rarePlayer');
    if (isComeback) achievements.add('comeback');

    final outcome = won ? 'win' : (draw ? 'draw' : 'loss');
    final entry = MatchHistorySummary(
      outcome: outcome,
      score: score,
      ratingDelta: ratingDelta,
      passesUsed: passesUsed,
      endedByDrawOffer: endedByDrawOffer,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
    final updatedMatches = [entry, ...state.recentMatches].take(50).toList();

    state = state.copyWith(
      gamesPlayed: newGames,
      wins: newWins,
      losses: newLosses,
      draws: newDraws,
      bestScore: newBestScore,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      rating: newRating,
      unlockedAchievements: achievements,
      recentMatches: updatedMatches,
    );

    await _saveLocal();
    await _syncRemote();
  }

  Future<void> completeDailyChallenge(String dateKey, int score) async {
    final updatedDaily = Map<String, int>.from(state.completedDailyChallenges);
    updatedDaily[dateKey] = score;

    state = state.copyWith(completedDailyChallenges: updatedDaily);
    await recordGameResult(won: true, score: score, isPerfect: score >= 1200);
  }

  Future<void> setCountry(String countryCode) async {
    state = state.copyWith(country: countryCode);
    await _saveLocal();
    await _syncRemote();
  }

  Future<void> setCustomDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(customDisplayName: trimmed);
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(trimmed);
    } catch (_) {}
    await _saveLocal();
    await _syncRemote();
  }
}

final userStatsProvider =
    StateNotifierProvider<UserStatsNotifier, UserStatsState>((ref) {
      final user = ref.watch(currentUserProvider);
      return UserStatsNotifier(uid: user?.uid);
    });
