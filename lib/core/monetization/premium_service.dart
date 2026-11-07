import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_providers.dart';
import 'monetization_models.dart';

/// Central service managing Football SOS Pro entitlement state.
///
/// Security rules:
/// - Never trusts an unverified client boolean (`isPremium: true`).
/// - Requires [PremiumEntitlementState.isVerifiedByServer] and a valid future
///   [PremiumEntitlementState.expiresAtMs] (or grace period expiry).
/// - Synchronizes in real time across the user's devices via Firestore `users/{uid}`
///   (which is write-protected in `firestore.rules` so only Firebase Admin SDK /
///   RevenueCat webhooks / Cloud Functions can update entitlement fields).
class PremiumService extends StateNotifier<PremiumEntitlementState> {
  static const String _cacheKeyPrefix = 'verified_premium_entitlement_v1';

  final String? _uid;
  final FirebaseFirestore? _firestore;
  final int Function() _clockMs;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  Timer? _expiryCheckTimer;

  PremiumService({
    required String? uid,
    FirebaseFirestore? firestore,
    int Function()? clockMs,
    PremiumEntitlementState? initialState,
  }) : _uid = uid,
       _firestore = firestore,
       _clockMs = clockMs ?? (() => DateTime.now().millisecondsSinceEpoch),
       super(initialState ?? const PremiumEntitlementState()) {
    _initialize();
  }

  String get _scopedCacheKey => (_uid != null && _uid.isNotEmpty)
      ? '${_cacheKeyPrefix}_$_uid'
      : _cacheKeyPrefix;

  /// Returns whether the user currently has active Football SOS Pro access.
  bool get isPremiumActive => state.isActiveAt(_clockMs());

  /// Returns the effective subscription status at the current time.
  SubscriptionStatus get effectiveStatus => state.effectiveStatusAt(_clockMs());

  Future<void> _initialize() async {
    await _loadCachedVerifiedState();
    _subscribeToUserEntitlement();
    _startPeriodicExpiryEvaluation();
  }

  Future<void> _loadCachedVerifiedState() async {
    if (_uid == null || _uid.isEmpty) {
      state = const PremiumEntitlementState();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_scopedCacheKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final loaded = PremiumEntitlementState.fromFirestoreUserMap({
          'premiumEntitlement': decoded,
        });
        state = _normalizeForCurrentTime(loaded);
      }
    } catch (_) {}
  }

  Future<void> _saveCachedVerifiedState(
    PremiumEntitlementState entitlement,
  ) async {
    if (_uid == null || _uid.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_scopedCacheKey, jsonEncode(entitlement.toMap()));
    } catch (_) {}
  }

  void _subscribeToUserEntitlement() {
    _userSub?.cancel();
    if (_uid == null || _uid.isEmpty) return;

    final fs = _firestore ?? _tryGetDefaultFirestore();
    if (fs == null) return;

    try {
      _userSub = fs.collection('users').doc(_uid).snapshots().listen((
        snapshot,
      ) {
        final data = snapshot.data();
        if (data == null) return;
        final parsed = PremiumEntitlementState.fromFirestoreUserMap(data);
        final normalized = _normalizeForCurrentTime(parsed);
        state = normalized;
        _saveCachedVerifiedState(normalized);
      }, onError: (_) {});
    } catch (_) {}
  }

  FirebaseFirestore? _tryGetDefaultFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  void _startPeriodicExpiryEvaluation() {
    _expiryCheckTimer?.cancel();
    _expiryCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      refreshExpiryEvaluation();
    });
  }

  PremiumEntitlementState _normalizeForCurrentTime(
    PremiumEntitlementState input,
  ) {
    final now = _clockMs();
    final effective = input.effectiveStatusAt(now);
    if (effective != input.status) {
      return input.copyWith(status: effective, willRenew: false);
    }
    return input;
  }

  /// Re-evaluates whether the subscription has expired at the current clock timestamp.
  void refreshExpiryEvaluation({int? nowMsOverride}) {
    final now = nowMsOverride ?? _clockMs();
    final effective = state.effectiveStatusAt(now);
    if (effective != state.status) {
      state = state.copyWith(status: effective, willRenew: false);
    }
  }

  /// Applies a server-verified entitlement payload returned from Cloud Functions
  /// (`verifyPurchaseReceipt`, `restoreUserPurchases`) or RevenueCat CustomerInfo.
  /// Rejects any payload that is not marked `isVerifiedByServer: true` with a valid timestamp.
  Future<bool> applyServerVerifiedEntitlement(
    Map<String, dynamic> rawServerPayload,
  ) async {
    final candidate = PremiumEntitlementState.fromFirestoreUserMap({
      'premiumEntitlement': rawServerPayload,
    });
    if (!candidate.isVerifiedByServer) {
      // Security guard: reject untrusted client-side payload
      return false;
    }
    final normalized = _normalizeForCurrentTime(candidate);
    state = normalized;
    await _saveCachedVerifiedState(normalized);
    return true;
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _expiryCheckTimer?.cancel();
    super.dispose();
  }
}

final premiumServiceProvider =
    StateNotifierProvider<PremiumService, PremiumEntitlementState>((ref) {
      final user = ref.watch(currentUserProvider);
      return PremiumService(uid: user?.uid);
    });

/// Convenience provider returning a boolean of whether Football SOS Pro is currently active.
final isPremiumActiveProvider = Provider<bool>((ref) {
  final entitlement = ref.watch(premiumServiceProvider);
  return entitlement.isActiveAt(DateTime.now().millisecondsSinceEpoch);
});
