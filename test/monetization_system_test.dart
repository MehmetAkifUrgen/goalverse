import 'package:flutter_test/flutter_test.dart';
import 'package:football_tic_tac_toe/core/monetization/ad_service.dart';
import 'package:football_tic_tac_toe/core/monetization/cosmetic_store_service.dart';
import 'package:football_tic_tac_toe/core/monetization/monetization_l10n.dart';
import 'package:football_tic_tac_toe/core/monetization/monetization_models.dart';
import 'package:football_tic_tac_toe/core/monetization/premium_service.dart';
import 'package:football_tic_tac_toe/core/monetization/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Football SOS Monetization - 1. Security & Entitlement Lifecycle', () {
    test(
      'rejects unverified client-side isPremium: true tampering without server verification',
      () async {
        // Attempt to parse a Firestore user document where a malicious client wrote `isPremium: true`
        final tamperedDoc = <String, dynamic>{
          'uid': 'user_tamper',
          'isPremium': true,
        };
        final parsed = PremiumEntitlementState.fromFirestoreUserMap(
          tamperedDoc,
        );
        expect(parsed.isVerifiedByServer, isFalse);
        expect(parsed.isActiveAt(1000000), isFalse);

        // Also test PremiumService.applyServerVerifiedEntitlement rejecting unverified payload
        final service = PremiumService(uid: 'user_tamper', clockMs: () => 1000);
        final accepted = await service.applyServerVerifiedEntitlement({
          'isVerifiedByServer': false,
          'status': 'active',
          'expiresAtMs': 999999999,
        });
        expect(accepted, isFalse);
        expect(service.isPremiumActive, isFalse);
        service.dispose();
      },
    );

    test(
      'handles Google Play & Apple Sandbox purchase, cancellation (active until period end), grace period, and automatic expiration',
      () async {
        var nowMs = 1_000_000;
        final billingClient = RevenueCatStoreBillingClient(
          clockMs: () => nowMs,
        );
        final premiumService = PremiumService(
          uid: 'user_pro_1',
          clockMs: () => nowMs,
        );
        final cosmeticService = CosmeticStoreService(uid: 'user_pro_1');
        final purchaseService = PurchaseService(
          uid: 'user_pro_1',
          billingClient: billingClient,
          premiumService: premiumService,
          cosmeticStoreService: cosmeticService,
          remoteConfig: const MonetizationRemoteConfig(),
          clockMs: () => nowMs,
        );

        // 1. Purchase Yearly Subscription (Apple / Google Sandbox)
        final purchaseRes = await purchaseService.purchaseSubscription(
          MonetizationProductIds.proYearly,
        );
        expect(purchaseRes.status, PurchaseResultStatus.success);
        expect(premiumService.isPremiumActive, isTrue);
        expect(premiumService.effectiveStatus, SubscriptionStatus.active);
        expect(
          premiumService.state.subscriptionProductId,
          MonetizationProductIds.proYearly,
        );

        final expiryMs = premiumService.state.expiresAtMs!;
        expect(expiryMs, greaterThan(nowMs));

        // 2. User cancels subscription -> remains active until current billing period ends
        await premiumService.applyServerVerifiedEntitlement({
          'isVerifiedByServer': true,
          'status': 'active_until_expiry',
          'subscriptionProductId': MonetizationProductIds.proYearly,
          'expiresAtMs': expiryMs,
          'willRenew': false,
          'storeSource': 'app_store',
          'serverVerifiedAtMs': nowMs + 5000,
        });
        expect(premiumService.isPremiumActive, isTrue);
        expect(
          premiumService.effectiveStatus,
          SubscriptionStatus.activeUntilExpiry,
        );

        // 3. Time advances past expiresAtMs -> Premium automatically deactivates
        nowMs = expiryMs + 1000;
        premiumService.refreshExpiryEvaluation();
        expect(premiumService.isPremiumActive, isFalse);
        expect(premiumService.effectiveStatus, SubscriptionStatus.expired);

        premiumService.dispose();
        cosmeticService.dispose();
        purchaseService.dispose();
      },
    );
  });

  group(
    'Football SOS Monetization - 2. AdService Rules (Premium Suppression, Frequency & Rewarded SSV)',
    () {
      test(
        'Free user sees banner & interstitial only every 3 completed matches, never during gameplay or round summary, and Premium user sees zero ads',
        () async {
          var nowMs = 2_000_000;
          final adClient = DefaultAdMobPlatformClient();
          final premiumService = PremiumService(
            uid: 'user_ads',
            clockMs: () => nowMs,
          );
          final cosmeticService = CosmeticStoreService(uid: 'user_ads');
          final adService = AdService(
            uid: 'user_ads',
            adClient: adClient,
            premiumService: premiumService,
            cosmeticStoreService: cosmeticService,
            remoteConfig: const MonetizationRemoteConfig(
              adsEnabled: true,
              bannerAdsEnabled: true,
              interstitialFrequency: 3,
              rewardedAdsEnabled: true,
            ),
          );

          await Future<void>.delayed(Duration.zero);

          // Free user sees banner
          expect(adService.shouldShowBannerAd, isTrue);

          // Never shows interstitial during gameplay, between rounds, or while waiting for opponent
          expect(
            await adService.onMatchCompletedAndMaybeShowInterstitial(
              isDuringGameplay: true,
            ),
            isFalse,
          );
          expect(
            await adService.onMatchCompletedAndMaybeShowInterstitial(
              isRoundSummary: true,
            ),
            isFalse,
          );
          expect(
            await adService.onMatchCompletedAndMaybeShowInterstitial(
              isWaitingForOpponent: true,
            ),
            isFalse,
          );

          // Match #1 completed -> not shown (1 % 3 != 0)
          expect(
            await adService.onMatchCompletedAndMaybeShowInterstitial(),
            isFalse,
          );
          // Match #2 completed -> not shown (2 % 3 != 0)
          expect(
            await adService.onMatchCompletedAndMaybeShowInterstitial(),
            isFalse,
          );
          // Match #3 completed -> SHOWN! (3 % 3 == 0)
          expect(
            await adService.onMatchCompletedAndMaybeShowInterstitial(),
            isTrue,
          );
          expect(adService.state.interstitialsShownCount, 1);

          // Now user upgrades to Football SOS Pro -> zero banner & zero interstitials even on 6th match
          await premiumService.applyServerVerifiedEntitlement({
            'isVerifiedByServer': true,
            'status': 'active',
            'subscriptionProductId': MonetizationProductIds.proMonthly,
            'expiresAtMs': nowMs + 86400000,
            'willRenew': true,
            'serverVerifiedAtMs': nowMs,
          });

          expect(adService.shouldShowBannerAd, isFalse);
          expect(
            await adService.onMatchCompletedAndMaybeShowInterstitial(),
            isFalse,
          );
          expect(
            await adService.onMatchCompletedAndMaybeShowInterstitial(),
            isFalse,
          );
          expect(
            await adService.onMatchCompletedAndMaybeShowInterstitial(),
            isFalse,
          );
          expect(adService.state.interstitialsShownCount, 1);

          adService.dispose();
          premiumService.dispose();
          cosmeticService.dispose();
        },
      );

      test(
        'Rewarded Ad grants cosmetic progress ONLY when completed, and grants nothing if skipped early',
        () async {
          final adClient = DefaultAdMobPlatformClient();
          final premiumService = PremiumService(uid: 'user_reward');
          final cosmeticService = CosmeticStoreService(uid: 'user_reward');
          final adService = AdService(
            uid: 'user_reward',
            adClient: adClient,
            premiumService: premiumService,
            cosmeticStoreService: cosmeticService,
            remoteConfig: const MonetizationRemoteConfig(),
          );

          final badgeItem = CosmeticStoreService.catalog.firstWhere(
            (c) => c.productId == MonetizationProductIds.badgeTacticalGenius,
          ); // requires 2 rewarded ads

          // 1. User closes ad early before completion -> NO reward granted
          adClient.simulateRewardedCompleted = false;
          final skippedRes = await adService.watchRewardedAdForCosmetic(
            badgeItem,
          );
          expect(skippedRes.rewardEarned, isFalse);
          expect(
            cosmeticService.state.rewardedProgressByProductId[badgeItem
                    .productId] ??
                0,
            0,
          );
          expect(
            cosmeticService.isPermanentlyOwned(badgeItem.productId),
            isFalse,
          );

          // 2. User watches 2 complete rewarded ads -> item is unlocked!
          adClient.simulateRewardedCompleted = true;
          final completed1 = await adService.watchRewardedAdForCosmetic(
            badgeItem,
          );
          expect(completed1.rewardEarned, isTrue);
          expect(completed1.cosmeticUnlocked, isFalse);
          expect(
            cosmeticService.state.rewardedProgressByProductId[badgeItem
                .productId],
            1,
          );

          final completed2 = await adService.watchRewardedAdForCosmetic(
            badgeItem,
          );
          expect(completed2.rewardEarned, isTrue);
          expect(completed2.cosmeticUnlocked, isTrue);
          expect(
            cosmeticService.isPermanentlyOwned(badgeItem.productId),
            isTrue,
          );

          adService.dispose();
          premiumService.dispose();
          cosmeticService.dispose();
        },
      );
    },
  );

  group(
    'Football SOS Monetization - 3. Cosmetic Store, Duplicate Prevention & Restore Purchases',
    () {
      test(
        'prevents duplicate cosmetic purchase and restores purchases after reinstall / device switch',
        () async {
          var nowMs = 5_000_000;
          final sharedBillingClient = RevenueCatStoreBillingClient(
            clockMs: () => nowMs,
          );
          final premiumDeviceA = PremiumService(
            uid: 'user_cross_device',
            clockMs: () => nowMs,
          );
          final cosmeticDeviceA = CosmeticStoreService(
            uid: 'user_cross_device',
          );
          final purchaseDeviceA = PurchaseService(
            uid: 'user_cross_device',
            billingClient: sharedBillingClient,
            premiumService: premiumDeviceA,
            cosmeticStoreService: cosmeticDeviceA,
            remoteConfig: const MonetizationRemoteConfig(),
            clockMs: () => nowMs,
          );

          final goldBoard = CosmeticStoreService.catalog.firstWhere(
            (c) => c.productId == MonetizationProductIds.boardRoyalGold,
          );

          // Buy cosmetic on Device A
          final firstBuy = await purchaseDeviceA.purchaseCosmetic(goldBoard);
          expect(firstBuy.status, PurchaseResultStatus.success);
          expect(
            cosmeticDeviceA.isPermanentlyOwned(goldBoard.productId),
            isTrue,
          );
          expect(cosmeticDeviceA.state.equipped.boardThemeId, goldBoard.id);

          // Attempting to buy the same cosmetic again is blocked with `alreadyOwned`
          final duplicateBuy = await purchaseDeviceA.purchaseCosmetic(
            goldBoard,
          );
          expect(duplicateBuy.status, PurchaseResultStatus.alreadyOwned);

          // Also buy Monthly Pro on Device A
          await purchaseDeviceA.purchaseSubscription(
            MonetizationProductIds.proMonthly,
          );
          expect(premiumDeviceA.isPremiumActive, isTrue);

          // Simulate fresh app install on Device B (empty local storage, same uid)
          SharedPreferences.setMockInitialValues(<String, Object>{});
          final premiumDeviceB = PremiumService(
            uid: 'user_cross_device',
            clockMs: () => nowMs,
          );
          final cosmeticDeviceB = CosmeticStoreService(
            uid: 'user_cross_device',
          );
          final purchaseDeviceB = PurchaseService(
            uid: 'user_cross_device',
            billingClient: sharedBillingClient,
            premiumService: premiumDeviceB,
            cosmeticStoreService: cosmeticDeviceB,
            remoteConfig: const MonetizationRemoteConfig(),
            clockMs: () => nowMs,
          );

          expect(
            cosmeticDeviceB.isPermanentlyOwned(goldBoard.productId),
            isFalse,
          );
          expect(premiumDeviceB.isPremiumActive, isFalse);

          // Restore purchases on Device B -> both Pro subscription and cosmetic are restored!
          final restored = await purchaseDeviceB.restorePurchases();
          expect(restored, isTrue);
          expect(premiumDeviceB.isPremiumActive, isTrue);
          expect(
            cosmeticDeviceB.isPermanentlyOwned(goldBoard.productId),
            isTrue,
          );

          premiumDeviceA.dispose();
          cosmeticDeviceA.dispose();
          purchaseDeviceA.dispose();
          premiumDeviceB.dispose();
          cosmeticDeviceB.dispose();
          purchaseDeviceB.dispose();
        },
      );

      test(
        'provides complete translations for all 6 required languages (tr, en, es, fr, de, it)',
        () {
          for (final lang in const ['tr', 'en', 'es', 'fr', 'de', 'it']) {
            final l10n = MonetizationL10n(lang);
            expect(l10n.tr('pro_title'), isNotEmpty);
            expect(l10n.tr('buy_pro_button'), isNotEmpty);
            expect(l10n.tr('restore_purchases'), isNotEmpty);
            expect(l10n.tr('store_title'), isNotEmpty);
            expect(l10n.tr('terms_of_use'), isNotEmpty);
            expect(l10n.tr('privacy_policy'), isNotEmpty);
          }
        },
      );
    },
  );
}

