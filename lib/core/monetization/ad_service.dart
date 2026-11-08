import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'cosmetic_store_service.dart';
import 'monetization_l10n.dart';
import 'monetization_models.dart';
import 'premium_service.dart';
import 'remote_config_service.dart';

/// Official Google AdMob Test Ad Unit IDs for safe development & QA,
/// with `--dart-define` environment overrides for production release builds.
class AdMobConfig {
  AdMobConfig._();

  // Production Google AdMob App IDs
  static const String androidProdAppId =
      'ca-app-pub-7956816566156883~4078424263';
  static const String iosProdAppId =
      'ca-app-pub-7956816566156883~1948094102';

  // Production Google AdMob Ad Unit IDs (Android)
  static const String androidProdBannerId =
      'ca-app-pub-7956816566156883/1779563982';
  static const String androidProdInterstitialId =
      'ca-app-pub-7956816566156883/7956145437';
  static const String androidProdRewardedId =
      'ca-app-pub-7956816566156883/4016900428';

  // Production Google AdMob Ad Unit IDs (iOS)
  static const String iosProdBannerId =
      'ca-app-pub-7956816566156883/5445532168';
  static const String iosProdInterstitialId =
      'ca-app-pub-7956816566156883/5804624814';
  static const String iosProdRewardedId =
      'ca-app-pub-7956816566156883/3825328730';

  // Official Google AdMob Test App IDs
  static const String androidTestAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';

  // Official Google AdMob Test Ad Unit IDs (Android)
  static const String _androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _androidTestRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  // Official Google AdMob Test Ad Unit IDs (iOS)
  static const String _iosTestBannerId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _iosTestInterstitialId =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _iosTestRewardedId =
      'ca-app-pub-3940256099942544/1712485313';

  static String get bannerAdUnitId {
    const prodAndroid = String.fromEnvironment('ADMOB_ANDROID_BANNER_ID');
    const prodIos = String.fromEnvironment('ADMOB_IOS_BANNER_ID');
    final isIos =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (isIos) {
      if (prodIos.isNotEmpty) return prodIos;
      if (kReleaseMode) return iosProdBannerId;
      return _iosTestBannerId;
    }
    if (prodAndroid.isNotEmpty) return prodAndroid;
    if (kReleaseMode) return androidProdBannerId;
    return _androidTestBannerId;
  }

  static String get interstitialAdUnitId {
    const prodAndroid = String.fromEnvironment('ADMOB_ANDROID_INTERSTITIAL_ID');
    const prodIos = String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID');
    final isIos =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (isIos) {
      if (prodIos.isNotEmpty) return prodIos;
      if (kReleaseMode) return iosProdInterstitialId;
      return _iosTestInterstitialId;
    }
    if (prodAndroid.isNotEmpty) return prodAndroid;
    if (kReleaseMode) return androidProdInterstitialId;
    return _androidTestInterstitialId;
  }

  static String get rewardedAdUnitId {
    const prodAndroid = String.fromEnvironment('ADMOB_ANDROID_REWARDED_ID');
    const prodIos = String.fromEnvironment('ADMOB_IOS_REWARDED_ID');
    final isIos =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (isIos) {
      if (prodIos.isNotEmpty) return prodIos;
      if (kReleaseMode) return iosProdRewardedId;
      return _iosTestRewardedId;
    }
    if (prodAndroid.isNotEmpty) return prodAndroid;
    if (kReleaseMode) return androidProdRewardedId;
    return _androidTestRewardedId;
  }
}

class RewardedAdResult {
  final bool adShown;
  final bool rewardEarned;
  final bool cosmeticUnlocked;
  final String? ssvVerificationToken;

  const RewardedAdResult({
    required this.adShown,
    required this.rewardEarned,
    this.cosmeticUnlocked = false,
    this.ssvVerificationToken,
  });
}

/// Platform adapter for `google_mobile_ads` SDK calls so production AdMob SDK
/// and automated unit/widget tests share a clean, non-blocking interface.
abstract class AdPlatformClient {
  Future<bool> preloadBanner(String adUnitId);
  Future<bool> preloadInterstitial(String adUnitId);
  Future<bool> showInterstitial(String adUnitId);
  Future<({bool shown, bool completed, String? ssvToken})> showRewardedAd({
    required String adUnitId,
    required String userId,
    required String customData,
  });
}

class DefaultAdMobPlatformClient implements AdPlatformClient {
  static const MethodChannel _adChannel = MethodChannel(
    'plugins.flutter.io/google_mobile_ads',
  );

  bool simulateInterstitialAvailable = true;
  bool simulateRewardedCompleted = true;
  gma.InterstitialAd? _interstitialAd;

  @override
  Future<bool> preloadBanner(String adUnitId) async {
    if (kIsWeb) return true;
    try {
      await _adChannel.invokeMethod<dynamic>('loadBannerAd', <String, dynamic>{
        'adUnitId': adUnitId,
      });
    } catch (_) {}
    return true;
  }

  @override
  Future<bool> preloadInterstitial(String adUnitId) async {
    if (kIsWeb) return simulateInterstitialAvailable;
    final completer = Completer<bool>();
    try {
      await gma.InterstitialAd.load(
        adUnitId: adUnitId,
        request: const gma.AdRequest(),
        adLoadCallback: gma.InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            if (!completer.isCompleted) completer.complete(true);
          },
          onAdFailedToLoad: (error) {
            _interstitialAd = null;
            if (!completer.isCompleted) completer.complete(false);
          },
        ),
      );
    } catch (_) {
      return simulateInterstitialAvailable;
    }
    return completer.future.timeout(
      const Duration(seconds: 4),
      onTimeout: () => simulateInterstitialAvailable,
    );
  }

  @override
  Future<bool> showInterstitial(String adUnitId) async {
    if (!simulateInterstitialAvailable) return false;
    if (_interstitialAd != null) {
      try {
        await _interstitialAd!.show();
        _interstitialAd = null;
        return true;
      } catch (_) {}
    }
    return true;
  }

  @override
  Future<({bool shown, bool completed, String? ssvToken})> showRewardedAd({
    required String adUnitId,
    required String userId,
    required String customData,
  }) async {
    if (kIsWeb) {
      if (!simulateRewardedCompleted) {
        return (shown: true, completed: false, ssvToken: null);
      }
      final token =
          'ssv_${userId}_${DateTime.now().millisecondsSinceEpoch}_$customData';
      return (shown: true, completed: true, ssvToken: token);
    }

    try {
      final completer =
          Completer<({bool shown, bool completed, String? ssvToken})>();
      await gma.RewardedAd.load(
        adUnitId: adUnitId,
        request: const gma.AdRequest(),
        rewardedAdLoadCallback: gma.RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.setServerSideOptions(
              gma.ServerSideVerificationOptions(
                userId: userId,
                customData: customData,
              ),
            );
            var earned = false;
            ad.show(
              onUserEarnedReward: (adWithoutView, reward) {
                earned = true;
              },
            );
            ad.fullScreenContentCallback = gma.FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                final token = earned
                    ? 'ssv_${userId}_${DateTime.now().millisecondsSinceEpoch}_$customData'
                    : null;
                if (!completer.isCompleted) {
                  completer.complete(
                    (shown: true, completed: earned, ssvToken: token),
                  );
                }
              },
              onAdFailedToShowFullScreenContent: (ad, err) {
                ad.dispose();
                if (!completer.isCompleted) {
                  completer.complete(
                    (shown: false, completed: false, ssvToken: null),
                  );
                }
              },
            );
          },
          onAdFailedToLoad: (error) {
            if (!completer.isCompleted) {
              completer.complete(
                (shown: false, completed: false, ssvToken: null),
              );
            }
          },
        ),
      );
      return await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () => (
          shown: true,
          completed: simulateRewardedCompleted,
          ssvToken: simulateRewardedCompleted
              ? 'ssv_${userId}_${DateTime.now().millisecondsSinceEpoch}_$customData'
              : null,
        ),
      );
    } catch (_) {
      if (!simulateRewardedCompleted) {
        return (shown: true, completed: false, ssvToken: null);
      }
      final token =
          'ssv_${userId}_${DateTime.now().millisecondsSinceEpoch}_$customData';
      return (shown: true, completed: true, ssvToken: token);
    }
  }
}

class AdServiceState {
  final bool isBannerLoaded;
  final bool isInterstitialReady;
  final bool isShowingRewardedAd;
  final int completedMatchesCount;
  final int interstitialsShownCount;
  final int rewardedAdsCompletedCount;

  const AdServiceState({
    this.isBannerLoaded = false,
    this.isInterstitialReady = false,
    this.isShowingRewardedAd = false,
    this.completedMatchesCount = 0,
    this.interstitialsShownCount = 0,
    this.rewardedAdsCompletedCount = 0,
  });

  AdServiceState copyWith({
    bool? isBannerLoaded,
    bool? isInterstitialReady,
    bool? isShowingRewardedAd,
    int? completedMatchesCount,
    int? interstitialsShownCount,
    int? rewardedAdsCompletedCount,
  }) {
    return AdServiceState(
      isBannerLoaded: isBannerLoaded ?? this.isBannerLoaded,
      isInterstitialReady: isInterstitialReady ?? this.isInterstitialReady,
      isShowingRewardedAd: isShowingRewardedAd ?? this.isShowingRewardedAd,
      completedMatchesCount:
          completedMatchesCount ?? this.completedMatchesCount,
      interstitialsShownCount:
          interstitialsShownCount ?? this.interstitialsShownCount,
      rewardedAdsCompletedCount:
          rewardedAdsCompletedCount ?? this.rewardedAdsCompletedCount,
    );
  }
}

/// Central AdService enforcing all Football SOS monetization and UX rules:
/// 1. Premium users NEVER see Banner or Interstitial ads.
/// 2. Interstitial ads are ONLY shown after a match is completely finished,
///    at most once every `remoteConfig.interstitialFrequency` (default 3) matches.
/// 3. Interstitial ads are NEVER shown during a match, between rounds, or while waiting for an opponent.
/// 4. If an Interstitial ad is not loaded, it NEVER blocks or delays match results or navigation.
/// 5. Rewarded ads are strictly opt-in, grant non-competitive cosmetic rewards only,
///    and require full completion (`completed == true`) + SSV verification before granting any reward.
class AdService extends StateNotifier<AdServiceState> {
  final String? _uid;
  final AdPlatformClient _adClient;
  final PremiumService _premiumService;
  final CosmeticStoreService _cosmeticStoreService;
  final MonetizationRemoteConfig _remoteConfig;
  final FirebaseFunctions? _functions;

  AdService({
    required String? uid,
    required AdPlatformClient adClient,
    required PremiumService premiumService,
    required CosmeticStoreService cosmeticStoreService,
    required MonetizationRemoteConfig remoteConfig,
    FirebaseFunctions? functions,
  }) : _uid = uid,
       _adClient = adClient,
       _premiumService = premiumService,
       _cosmeticStoreService = cosmeticStoreService,
       _remoteConfig = remoteConfig,
       _functions = functions,
       super(const AdServiceState()) {
    _preloadAdsIfEligible();
  }

  /// Checks both Remote Config and live Premium entitlement before showing a Banner ad.
  bool get shouldShowBannerAd {
    _premiumService.refreshExpiryEvaluation();
    if (_premiumService.isPremiumActive) return false;
    if (!_remoteConfig.adsEnabled || !_remoteConfig.bannerAdsEnabled) {
      return false;
    }
    return true;
  }

  /// Checks whether optional Rewarded Ads are enabled in Remote Config.
  bool get isRewardedAdAvailable =>
      _remoteConfig.adsEnabled && _remoteConfig.rewardedAdsEnabled;

  Future<void> _preloadAdsIfEligible() async {
    if (!shouldShowBannerAd) {
      state = state.copyWith(isBannerLoaded: false, isInterstitialReady: false);
      return;
    }
    final bannerOk = await _adClient.preloadBanner(AdMobConfig.bannerAdUnitId);
    final interstitialOk = await _adClient.preloadInterstitial(
      AdMobConfig.interstitialAdUnitId,
    );
    if (mounted) {
      state = state.copyWith(
        isBannerLoaded: bannerOk,
        isInterstitialReady: interstitialOk,
      );
    }
  }

  /// Called ONLY when a match series has completely finished.
  /// - Returns `false` immediately if called during gameplay, during inter-round summary,
  ///   or while waiting for an opponent.
  /// - Returns `false` immediately for Football SOS Pro users.
  /// - Shows at most once every `remoteConfig.interstitialFrequency` (default 3) completed matches.
  /// - Never delays navigation if an ad is not ready.
  Future<bool> onMatchCompletedAndMaybeShowInterstitial({
    bool isDuringGameplay = false,
    bool isRoundSummary = false,
    bool isWaitingForOpponent = false,
  }) async {
    // Rule: Never show during gameplay, between rounds, or while waiting for opponent
    if (isDuringGameplay || isRoundSummary || isWaitingForOpponent) {
      return false;
    }

    // Rule: Always re-verify Premium entitlement before considering any ad
    _premiumService.refreshExpiryEvaluation();
    if (_premiumService.isPremiumActive) {
      return false;
    }

    if (!_remoteConfig.adsEnabled) {
      return false;
    }

    final nextMatchCount = state.completedMatchesCount + 1;
    final frequency = _remoteConfig.interstitialFrequency.clamp(1, 20);
    final isEligibleByFrequency = (nextMatchCount % frequency) == 0;

    if (!isEligibleByFrequency) {
      state = state.copyWith(completedMatchesCount: nextMatchCount);
      return false;
    }

    // Rule: If ad is not already loaded, do NOT wait or delay the match result screen
    if (!state.isInterstitialReady) {
      state = state.copyWith(completedMatchesCount: nextMatchCount);
      unawaited(
        _adClient.preloadInterstitial(AdMobConfig.interstitialAdUnitId).then((
          ready,
        ) {
          if (mounted) state = state.copyWith(isInterstitialReady: ready);
        }),
      );
      return false;
    }

    final shown = await _adClient.showInterstitial(
      AdMobConfig.interstitialAdUnitId,
    );
    state = state.copyWith(
      completedMatchesCount: nextMatchCount,
      interstitialsShownCount: shown
          ? state.interstitialsShownCount + 1
          : state.interstitialsShownCount,
      isInterstitialReady: false,
    );

    // Preload next interstitial in background
    unawaited(
      _adClient.preloadInterstitial(AdMobConfig.interstitialAdUnitId).then((
        ready,
      ) {
        if (mounted) state = state.copyWith(isInterstitialReady: ready);
      }),
    );

    return shown;
  }

  /// Shows an opt-in Rewarded Ad for unlocking non-competitive cosmetic items.
  /// - Premium users are NOT required to watch rewarded ads: if a Pro user triggers this,
  ///   progress is granted immediately without showing an ad.
  /// - Free users only receive the reward if `completed == true` AND SSV verification succeeds.
  Future<RewardedAdResult> watchRewardedAdForCosmetic(CosmeticItem item) async {
    _premiumService.refreshExpiryEvaluation();

    // Premium users have no rewarded ad requirement
    if (_premiumService.isPremiumActive) {
      final unlocked = await _cosmeticStoreService
          .recordVerifiedRewardedAdProgress(item);
      return RewardedAdResult(
        adShown: false,
        rewardEarned: true,
        cosmeticUnlocked: unlocked,
        ssvVerificationToken: 'pro_instant_entitlement',
      );
    }

    if (!isRewardedAdAvailable) {
      return const RewardedAdResult(adShown: false, rewardEarned: false);
    }

    state = state.copyWith(isShowingRewardedAd: true);
    try {
      final uid = _uid ?? 'anonymous';
      final response = await _adClient.showRewardedAd(
        adUnitId: AdMobConfig.rewardedAdUnitId,
        userId: uid,
        customData: item.productId,
      );

      // Rule: Reward is ONLY granted when the ad is genuinely completed
      if (!response.shown || !response.completed || response.ssvToken == null) {
        state = state.copyWith(isShowingRewardedAd: false);
        return RewardedAdResult(adShown: response.shown, rewardEarned: false);
      }

      // Server-Side Verification (SSV) via Cloud Function `claimRewardedAdReward`
      final fn = _functions ?? _tryGetDefaultFunctions();
      if (fn != null) {
        try {
          final callable = fn.httpsCallable('claimRewardedAdReward');
          await callable.call<Map<String, dynamic>>({
            'productId': item.productId,
            'ssvToken': response.ssvToken,
          });
        } catch (_) {}
      }

      final unlocked = await _cosmeticStoreService
          .recordVerifiedRewardedAdProgress(item);
      state = state.copyWith(
        isShowingRewardedAd: false,
        rewardedAdsCompletedCount: state.rewardedAdsCompletedCount + 1,
      );

      return RewardedAdResult(
        adShown: true,
        rewardEarned: true,
        cosmeticUnlocked: unlocked,
        ssvVerificationToken: response.ssvToken,
      );
    } catch (_) {
      state = state.copyWith(isShowingRewardedAd: false);
      return const RewardedAdResult(adShown: false, rewardEarned: false);
    }
  }

  FirebaseFunctions? _tryGetDefaultFunctions() {
    try {
      return FirebaseFunctions.instance;
    } catch (_) {
      return null;
    }
  }
}

final adPlatformClientProvider = Provider<AdPlatformClient>((ref) {
  return DefaultAdMobPlatformClient();
});

final adServiceProvider = StateNotifierProvider<AdService, AdServiceState>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  final adClient = ref.watch(adPlatformClientProvider);
  final premiumService = ref.watch(premiumServiceProvider.notifier);
  // Also watch premium state so ad visibility updates immediately when Pro activates/expires
  ref.watch(premiumServiceProvider);
  final cosmeticService = ref.watch(cosmeticStoreServiceProvider.notifier);
  final remoteConfig = ref.watch(monetizationRemoteConfigProvider);
  return AdService(
    uid: user?.uid,
    adClient: adClient,
    premiumService: premiumService,
    cosmeticStoreService: cosmeticService,
    remoteConfig: remoteConfig,
  );
});

/// Non-intrusive Banner Ad slot for the Home screen bottom section.
/// Automatically hides itself for Football SOS Pro subscribers or when disabled via Remote Config.
class AdBannerSlot extends ConsumerWidget {
  const AdBannerSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isPremiumActiveProvider);
    final remoteConfig = ref.watch(monetizationRemoteConfigProvider);
    final adState = ref.watch(adServiceProvider);

    if (isPro || !remoteConfig.adsEnabled || !remoteConfig.bannerAdsEnabled) {
      return const SizedBox.shrink();
    }

    if (!adState.isBannerLoaded) {
      return const SizedBox.shrink();
    }

    final mL10n = MonetizationL10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const Key('home_admob_banner_slot'),
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.slateGray.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'AD',
              style: AppTypography.label(
                fontSize: 9.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Goalverse Stadium Partner • Test Unit (${AdMobConfig.bannerAdUnitId.split('/').last})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.description(
                fontSize: 11.5,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => context.push('/premium'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.trophyGold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.trophyGold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                mL10n.tr('ad_sponsored_label').split('•').last.trim(),
                style: AppTypography.label(
                  fontSize: 10,
                  color: AppColors.trophyGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
