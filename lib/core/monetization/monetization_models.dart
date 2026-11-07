import 'package:flutter/material.dart';

/// Official Store Product Identifiers for Google Play Console & App Store Connect.
class MonetizationProductIds {
  MonetizationProductIds._();

  // Subscriptions
  static const String proMonthly = 'football_sos_pro_monthly';
  static const String proYearly = 'football_sos_pro_yearly';
  static const String revenueCatEntitlementId = 'football_sos_pro';

  static const List<String> subscriptionIds = <String>[proMonthly, proYearly];

  // One-Time Cosmetic Product IDs (Non-Consumable)
  static const String pitchChampionsNight = 'cosmetic_pitch_champions_night';
  static const String pitchGoldenArena = 'cosmetic_pitch_golden_arena';
  static const String boardNeonTactical = 'cosmetic_board_neon_tactical';
  static const String boardRoyalGold = 'cosmetic_board_royal_gold';
  static const String frameBallonDor = 'cosmetic_frame_ballon_dor';
  static const String frameEmeraldCaptain = 'cosmetic_frame_emerald_captain';
  static const String avatarStriker9 = 'cosmetic_avatar_striker_9';
  static const String avatarMaestro10 = 'cosmetic_avatar_maestro_10';
  static const String badgeTacticalGenius = 'cosmetic_badge_tactical_genius';
  static const String badgeUnbeatenKing = 'cosmetic_badge_unbeaten_king';
  static const String season1DerbyPack = 'cosmetic_season1_derby_pack';
  static const String season1TrophyAura = 'cosmetic_season1_trophy_aura';

  static const List<String> allCosmeticProductIds = <String>[
    pitchChampionsNight,
    pitchGoldenArena,
    boardNeonTactical,
    boardRoyalGold,
    frameBallonDor,
    frameEmeraldCaptain,
    avatarStriker9,
    avatarMaestro10,
    badgeTacticalGenius,
    badgeUnbeatenKing,
    season1DerbyPack,
    season1TrophyAura,
  ];
}

enum SubscriptionStatus {
  none,
  active,
  activeUntilExpiry,
  gracePeriod,
  billingRetry,
  expired,
  pending;

  static SubscriptionStatus fromString(String? raw) {
    return switch (raw) {
      'active' => SubscriptionStatus.active,
      'active_until_expiry' => SubscriptionStatus.activeUntilExpiry,
      'grace_period' => SubscriptionStatus.gracePeriod,
      'billing_retry' => SubscriptionStatus.billingRetry,
      'expired' => SubscriptionStatus.expired,
      'pending' => SubscriptionStatus.pending,
      _ => SubscriptionStatus.none,
    };
  }

  String get wireValue => switch (this) {
    SubscriptionStatus.none => 'none',
    SubscriptionStatus.active => 'active',
    SubscriptionStatus.activeUntilExpiry => 'active_until_expiry',
    SubscriptionStatus.gracePeriod => 'grace_period',
    SubscriptionStatus.billingRetry => 'billing_retry',
    SubscriptionStatus.expired => 'expired',
    SubscriptionStatus.pending => 'pending',
  };
}

/// Dynamic product quote fetched at runtime from App Store / Google Play / RevenueCat.
/// Never hardcode prices in UI widgets; always render [formattedPrice] from the store quote.
class StoreProductQuote {
  final String productId;
  final String title;
  final String description;
  final String formattedPrice;
  final double rawPrice;
  final String currencyCode;
  final String? billingPeriodIso;
  final String? introductoryPrice;
  final bool isSubscription;
  final bool isAvailable;

  const StoreProductQuote({
    required this.productId,
    required this.title,
    required this.description,
    required this.formattedPrice,
    required this.rawPrice,
    required this.currencyCode,
    this.billingPeriodIso,
    this.introductoryPrice,
    this.isSubscription = false,
    this.isAvailable = true,
  });
}

/// Server-verified Premium Entitlement state synced with Firestore and RevenueCat.
class PremiumEntitlementState {
  final bool isVerifiedByServer;
  final SubscriptionStatus status;
  final String? subscriptionProductId;
  final int? expiresAtMs;
  final int? gracePeriodExpiresAtMs;
  final bool willRenew;
  final String? storeSource; // 'play_store', 'app_store', 'revenuecat'
  final int? serverVerifiedAtMs;
  final String? verificationSignature;

  const PremiumEntitlementState({
    this.isVerifiedByServer = false,
    this.status = SubscriptionStatus.none,
    this.subscriptionProductId,
    this.expiresAtMs,
    this.gracePeriodExpiresAtMs,
    this.willRenew = false,
    this.storeSource,
    this.serverVerifiedAtMs,
    this.verificationSignature,
  });

  /// Returns whether Football SOS Pro is currently active at [nowMs].
  /// - Requires [isVerifiedByServer] to be true (client-side unverified flags are rejected).
  /// - Cancelled subscriptions ([SubscriptionStatus.activeUntilExpiry]) remain active until [expiresAtMs].
  /// - Grace period subscriptions ([SubscriptionStatus.gracePeriod]) remain active until [gracePeriodExpiresAtMs] or [expiresAtMs].
  /// - Once [nowMs] reaches [expiresAtMs], automatically becomes inactive.
  bool isActiveAt(int nowMs) {
    if (!isVerifiedByServer) return false;

    if (status == SubscriptionStatus.active ||
        status == SubscriptionStatus.activeUntilExpiry) {
      if (expiresAtMs == null) return false;
      return nowMs < expiresAtMs!;
    }

    if (status == SubscriptionStatus.gracePeriod) {
      final effectiveExpiry = gracePeriodExpiresAtMs ?? expiresAtMs;
      if (effectiveExpiry == null) return false;
      return nowMs < effectiveExpiry;
    }

    return false;
  }

  /// Resolves the effective status at [nowMs] (auto-transitioning to [SubscriptionStatus.expired]
  /// if the period has elapsed).
  SubscriptionStatus effectiveStatusAt(int nowMs) {
    if (!isVerifiedByServer) return SubscriptionStatus.none;
    if (status == SubscriptionStatus.active ||
        status == SubscriptionStatus.activeUntilExpiry ||
        status == SubscriptionStatus.gracePeriod) {
      if (!isActiveAt(nowMs)) {
        return SubscriptionStatus.expired;
      }
    }
    return status;
  }

  int get maxMatchHistoryItems =>
      isVerifiedByServer &&
          (status == SubscriptionStatus.active ||
              status == SubscriptionStatus.activeUntilExpiry ||
              status == SubscriptionStatus.gracePeriod)
      ? 50
      : 5;

  PremiumEntitlementState copyWith({
    bool? isVerifiedByServer,
    SubscriptionStatus? status,
    String? subscriptionProductId,
    int? expiresAtMs,
    int? gracePeriodExpiresAtMs,
    bool? willRenew,
    String? storeSource,
    int? serverVerifiedAtMs,
    String? verificationSignature,
  }) {
    return PremiumEntitlementState(
      isVerifiedByServer: isVerifiedByServer ?? this.isVerifiedByServer,
      status: status ?? this.status,
      subscriptionProductId:
          subscriptionProductId ?? this.subscriptionProductId,
      expiresAtMs: expiresAtMs ?? this.expiresAtMs,
      gracePeriodExpiresAtMs:
          gracePeriodExpiresAtMs ?? this.gracePeriodExpiresAtMs,
      willRenew: willRenew ?? this.willRenew,
      storeSource: storeSource ?? this.storeSource,
      serverVerifiedAtMs: serverVerifiedAtMs ?? this.serverVerifiedAtMs,
      verificationSignature:
          verificationSignature ?? this.verificationSignature,
    );
  }

  Map<String, dynamic> toMap() => {
    'isVerifiedByServer': isVerifiedByServer,
    'status': status.wireValue,
    'subscriptionProductId': subscriptionProductId,
    'expiresAtMs': expiresAtMs,
    'gracePeriodExpiresAtMs': gracePeriodExpiresAtMs,
    'willRenew': willRenew,
    'storeSource': storeSource,
    'serverVerifiedAtMs': serverVerifiedAtMs,
    if (verificationSignature != null)
      'verificationSignature': verificationSignature,
  };

  factory PremiumEntitlementState.fromFirestoreUserMap(
    Map<String, dynamic> userDoc,
  ) {
    final rawEntitlement = userDoc['premiumEntitlement'];
    if (rawEntitlement is! Map) {
      // Security: Ignore any raw top-level `isPremium: true` written by an untrusted client
      // unless a server-verified `premiumEntitlement` object with `serverVerifiedAtMs` exists.
      return const PremiumEntitlementState();
    }
    final map = Map<String, dynamic>.from(rawEntitlement);
    final serverVerifiedAt = (map['serverVerifiedAtMs'] as num?)?.toInt();
    final isVerified =
        (map['isVerifiedByServer'] as bool? ?? false) &&
        serverVerifiedAt != null &&
        serverVerifiedAt > 0;

    return PremiumEntitlementState(
      isVerifiedByServer: isVerified,
      status: SubscriptionStatus.fromString(map['status'] as String?),
      subscriptionProductId:
          (map['subscriptionProductId'] ?? userDoc['subscriptionProductId'])
              as String?,
      expiresAtMs:
          ((map['expiresAtMs'] ?? userDoc['premiumExpiresAtMs']) as num?)
              ?.toInt(),
      gracePeriodExpiresAtMs: (map['gracePeriodExpiresAtMs'] as num?)?.toInt(),
      willRenew: map['willRenew'] as bool? ?? false,
      storeSource: map['storeSource'] as String?,
      serverVerifiedAtMs: serverVerifiedAt,
      verificationSignature: map['verificationSignature'] as String?,
    );
  }
}

enum CosmeticCategory {
  pitchTheme,
  boardTheme,
  profileFrame,
  avatar,
  badge,
  seasonal;

  String get wireKey => switch (this) {
    CosmeticCategory.pitchTheme => 'pitch_theme',
    CosmeticCategory.boardTheme => 'board_theme',
    CosmeticCategory.profileFrame => 'profile_frame',
    CosmeticCategory.avatar => 'avatar',
    CosmeticCategory.badge => 'badge',
    CosmeticCategory.seasonal => 'seasonal',
  };
}

class CosmeticItem {
  final String id;
  final String productId;
  final CosmeticCategory category;
  final String titleKey;
  final String subtitleKey;
  final List<Color> previewColors;
  final IconData icon;
  final bool includedWithPro;
  final int? rewardedAdsRequired;

  const CosmeticItem({
    required this.id,
    required this.productId,
    required this.category,
    required this.titleKey,
    required this.subtitleKey,
    required this.previewColors,
    required this.icon,
    this.includedWithPro = false,
    this.rewardedAdsRequired,
  });
}

class EquippedCosmetics {
  final String pitchThemeId;
  final String boardThemeId;
  final String profileFrameId;
  final String avatarId;
  final String badgeId;
  final String? seasonalEffectId;

  const EquippedCosmetics({
    this.pitchThemeId = 'default_pitch',
    this.boardThemeId = 'default_board',
    this.profileFrameId = 'default_frame',
    this.avatarId = 'default_avatar',
    this.badgeId = 'default_badge',
    this.seasonalEffectId,
  });

  EquippedCosmetics copyWith({
    String? pitchThemeId,
    String? boardThemeId,
    String? profileFrameId,
    String? avatarId,
    String? badgeId,
    String? seasonalEffectId,
  }) {
    return EquippedCosmetics(
      pitchThemeId: pitchThemeId ?? this.pitchThemeId,
      boardThemeId: boardThemeId ?? this.boardThemeId,
      profileFrameId: profileFrameId ?? this.profileFrameId,
      avatarId: avatarId ?? this.avatarId,
      badgeId: badgeId ?? this.badgeId,
      seasonalEffectId: seasonalEffectId ?? this.seasonalEffectId,
    );
  }

  String equippedForCategory(CosmeticCategory category) {
    return switch (category) {
      CosmeticCategory.pitchTheme => pitchThemeId,
      CosmeticCategory.boardTheme => boardThemeId,
      CosmeticCategory.profileFrame => profileFrameId,
      CosmeticCategory.avatar => avatarId,
      CosmeticCategory.badge => badgeId,
      CosmeticCategory.seasonal => seasonalEffectId ?? 'default_seasonal',
    };
  }

  Map<String, dynamic> toMap() => {
    'pitchThemeId': pitchThemeId,
    'boardThemeId': boardThemeId,
    'profileFrameId': profileFrameId,
    'avatarId': avatarId,
    'badgeId': badgeId,
    if (seasonalEffectId != null) 'seasonalEffectId': seasonalEffectId,
  };

  factory EquippedCosmetics.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const EquippedCosmetics();
    return EquippedCosmetics(
      pitchThemeId: map['pitchThemeId'] as String? ?? 'default_pitch',
      boardThemeId: map['boardThemeId'] as String? ?? 'default_board',
      profileFrameId: map['profileFrameId'] as String? ?? 'default_frame',
      avatarId: map['avatarId'] as String? ?? 'default_avatar',
      badgeId: map['badgeId'] as String? ?? 'default_badge',
      seasonalEffectId: map['seasonalEffectId'] as String?,
    );
  }
}

/// Central remote configuration for ads, premium feature list, and cosmetic store availability.
class MonetizationRemoteConfig {
  final bool adsEnabled;
  final bool bannerAdsEnabled;
  final int interstitialFrequency;
  final bool rewardedAdsEnabled;
  final List<String> premiumFeatureKeys;
  final Set<String> disabledProductIds;

  const MonetizationRemoteConfig({
    this.adsEnabled = true,
    this.bannerAdsEnabled = true,
    this.interstitialFrequency = 3,
    this.rewardedAdsEnabled = true,
    this.premiumFeatureKeys = const <String>[
      'pro_benefit_no_ads',
      'pro_benefit_frames',
      'pro_benefit_badge',
      'pro_benefit_board_themes',
      'pro_benefit_detailed_stats',
      'pro_benefit_extended_history',
      'pro_benefit_profile_customization',
    ],
    this.disabledProductIds = const <String>{},
  });

  bool isProductActive(String productId) =>
      !disabledProductIds.contains(productId);

  MonetizationRemoteConfig copyWith({
    bool? adsEnabled,
    bool? bannerAdsEnabled,
    int? interstitialFrequency,
    bool? rewardedAdsEnabled,
    List<String>? premiumFeatureKeys,
    Set<String>? disabledProductIds,
  }) {
    return MonetizationRemoteConfig(
      adsEnabled: adsEnabled ?? this.adsEnabled,
      bannerAdsEnabled: bannerAdsEnabled ?? this.bannerAdsEnabled,
      interstitialFrequency:
          (interstitialFrequency ?? this.interstitialFrequency).clamp(1, 20),
      rewardedAdsEnabled: rewardedAdsEnabled ?? this.rewardedAdsEnabled,
      premiumFeatureKeys: premiumFeatureKeys ?? this.premiumFeatureKeys,
      disabledProductIds: disabledProductIds ?? this.disabledProductIds,
    );
  }
}

enum PurchaseResultStatus {
  success,
  cancelled,
  alreadyOwned,
  pending,
  paymentFailed,
  productUnavailable,
  unauthenticated,
  verificationFailed,
}

class PurchaseOperationResult {
  final PurchaseResultStatus status;
  final String? productId;
  final String? transactionId;
  final String? messageKey;

  const PurchaseOperationResult({
    required this.status,
    this.productId,
    this.transactionId,
    this.messageKey,
  });

  bool get isSuccess => status == PurchaseResultStatus.success;
}
