import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'monetization_models.dart';

/// Manages remote configuration via Firebase Remote Config so ad frequency,
/// ad placements, premium feature flags, and store item availability can be
/// updated without shipping a new app binary.
class MonetizationRemoteConfigService
    extends StateNotifier<MonetizationRemoteConfig> {
  final FirebaseRemoteConfig? _remoteConfig;

  MonetizationRemoteConfigService({
    FirebaseRemoteConfig? remoteConfig,
    MonetizationRemoteConfig? initialConfig,
  }) : _remoteConfig = remoteConfig,
       super(initialConfig ?? const MonetizationRemoteConfig());

  Future<void> initializeAndFetch() async {
    final rc = _remoteConfig ?? _tryGetDefaultRemoteConfig();
    if (rc == null) return;

    try {
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(minutes: 15),
        ),
      );
      await rc.setDefaults(const <String, dynamic>{
        'ads_enabled': true,
        'banner_ads_enabled': true,
        'interstitial_frequency': 3,
        'rewarded_ads_enabled': true,
        'premium_feature_keys_json':
            '["pro_benefit_no_ads","pro_benefit_frames","pro_benefit_badge","pro_benefit_board_themes","pro_benefit_detailed_stats","pro_benefit_extended_history","pro_benefit_profile_customization"]',
        'disabled_store_product_ids_json': '[]',
      });

      await rc.fetchAndActivate();
      _applyFromRemoteConfig(rc);
    } catch (_) {
      // Safe fallback to defaults if offline or Firebase is not initialized in unit tests
    }
  }

  FirebaseRemoteConfig? _tryGetDefaultRemoteConfig() {
    try {
      return FirebaseRemoteConfig.instance;
    } catch (_) {
      return null;
    }
  }

  void _applyFromRemoteConfig(FirebaseRemoteConfig rc) {
    final adsEnabled = rc.getBool('ads_enabled');
    final bannerEnabled = rc.getBool('banner_ads_enabled');
    final freq = rc.getInt('interstitial_frequency');
    final rewardedEnabled = rc.getBool('rewarded_ads_enabled');
    final featuresJson = rc.getString('premium_feature_keys_json');
    final disabledProductsJson = rc.getString(
      'disabled_store_product_ids_json',
    );

    List<String> parsedFeatures = state.premiumFeatureKeys;
    if (featuresJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(featuresJson);
        if (decoded is List) {
          final list = decoded.map((e) => e.toString()).toList();
          if (list.isNotEmpty) parsedFeatures = list;
        }
      } catch (_) {}
    }

    Set<String> parsedDisabled = state.disabledProductIds;
    if (disabledProductsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(disabledProductsJson);
        if (decoded is List) {
          parsedDisabled = decoded.map((e) => e.toString()).toSet();
        }
      } catch (_) {}
    }

    state = MonetizationRemoteConfig(
      adsEnabled: adsEnabled,
      bannerAdsEnabled: bannerEnabled,
      interstitialFrequency: (freq <= 0 ? 3 : freq).clamp(1, 20),
      rewardedAdsEnabled: rewardedEnabled,
      premiumFeatureKeys: parsedFeatures,
      disabledProductIds: parsedDisabled,
    );
  }

  /// Allows administrative or test overrides in memory.
  void updateConfig(MonetizationRemoteConfig newConfig) {
    state = newConfig;
  }
}

final monetizationRemoteConfigProvider =
    StateNotifierProvider<
      MonetizationRemoteConfigService,
      MonetizationRemoteConfig
    >((ref) {
      final service = MonetizationRemoteConfigService();
      service.initializeAndFetch();
      return service;
    });
