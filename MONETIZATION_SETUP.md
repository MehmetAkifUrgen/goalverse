# FOOTBALL SOS (GOALVERSE) – MONETIZATION KURULUM VE YÖNETİM REHBERİ

Bu doküman, **Football SOS Pro** abonelik sistemi, **Kozmetik Mağazası**, **AdMob Reklam Sistemi**, **RevenueCat** ve **Firebase Remote Config / Cloud Functions** altyapısının mağaza yayını öncesi manuel hesap yapılandırma adımlarını içerir.

> **Önemli Not:** Geliştirme ortamında uydurma üretim anahtarları kullanılmamıştır. Google AdMob'un resmî test birim kimlikleri (`ca-app-pub-3940256099942544/...`) ve Sandbox test faturalandırma katmanı tanımlanmıştır. Canlı yayına çıkarken aşağıdaki adımları tamamlayarak gerçek anahtarlarınızı `--dart-define` ile enjekte edebilirsiniz.

---

## 1. Google Play Console ve App Store Connect Ürün Tanımları

### A. Abonelik Ürün Kimlikleri (Subscriptions)
Her iki mağazada da aşağıdaki birebir ürün kimlikleriyle (Product ID) abonelik oluşturun:

| Plan | Ürün Kimliği (Product ID) | Yenilenme Süresi |
|---|---|---|
| Aylık Premium | `football_sos_pro_monthly` | 1 Ay (`P1M`) |
| Yıllık Premium | `football_sos_pro_yearly` | 1 Yıl (`P1Y`) |

### B. Tek Seferlik Kozmetik Ürün Kimlikleri (Non-Consumable In-App Products)
Her iki mağazada da **Tüketilemeyen (Non-Consumable)** uygulama içi ürün olarak aşağıdaki 12 ürünü tanımlayın:

1. **Saha Temaları (`pitch_theme`)**
   - `cosmetic_pitch_champions_night`
   - `cosmetic_pitch_golden_arena`
2. **Oyun Tahtası Temaları (`board_theme`)**
   - `cosmetic_board_neon_tactical`
   - `cosmetic_board_royal_gold`
3. **Profil Çerçeveleri (`profile_frame`)**
   - `cosmetic_frame_ballon_dor`
   - `cosmetic_frame_emerald_captain`
4. **Avatarlar (`avatar`)**
   - `cosmetic_avatar_striker_9`
   - `cosmetic_avatar_maestro_10`
5. **Özel Rozetler (`badge`)**
   - `cosmetic_badge_tactical_genius`
   - `cosmetic_badge_unbeaten_king`
6. **Sezonluk Kozmetikler (`seasonal`)**
   - `cosmetic_season1_derby_pack`
   - `cosmetic_season1_trophy_aura`

---

## 2. RevenueCat Yapılandırması

1. **RevenueCat Dashboard** üzerinde yeni bir proje oluşturun.
2. **Entitlements** sekmesinde `football_sos_pro` kimlikli yetkiyi oluşturun ve `football_sos_pro_monthly` ile `football_sos_pro_yearly` ürünlerini bu yetkiye bağlayın.
3. **Offerings** sekmesinde `default` offering içerisine aylık, yıllık ve kozmetik paketlerini ekleyin.
4. **Integrations > Webhooks** bölümünden Firebase Cloud Functions üzerindeki `processRevenueCatWebhookEvent` endpoint'ini tanımlayın (`INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`, `UNCANCELLATION`, `EXPIRATION`, `BILLING_ISSUE`, `NON_RENEWING_PURCHASE`).
5. Derleme sırasında API anahtarlarını iletin:
   ```bash
   flutter build appbundle --release \
     --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_xxxxxxxxxxxx \
     --dart-define=REVENUECAT_APPLE_API_KEY=appl_xxxxxxxxxxxx
   ```

---

## 3. Google AdMob Yapılandırması

Geliştirme ortamında [`AdMobConfig`](lib/core/monetization/ad_service.dart) içerisinde Google'ın resmî test reklam birimleri tanımlıdır:
- Android Banner Test ID: `ca-app-pub-3940256099942544/6300978111`
- Android Interstitial Test ID: `ca-app-pub-3940256099942544/1033173712`
- Android Rewarded Test ID: `ca-app-pub-3940256099942544/5224354917`
- iOS Banner Test ID: `ca-app-pub-3940256099942544/2934735716`
- iOS Interstitial Test ID: `ca-app-pub-3940256099942544/4411468910`
- iOS Rewarded Test ID: `ca-app-pub-3940256099942544/1712485313`

Canlı yayına geçerken:
1. [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml) içindeki `com.google.android.gms.ads.APPLICATION_ID` değerini kendi AdMob Android App ID'niz ile değiştirin.
2. [`ios/Runner/Info.plist`](ios/Runner/Info.plist) içindeki `GADApplicationIdentifier` değerini kendi AdMob iOS App ID'niz ile değiştirin.
3. Reklam birim kimliklerini `--dart-define` ile geçin:
   ```bash
   --dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-xxxx/xxxx
   --dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=ca-app-pub-xxxx/xxxx
   --dart-define=ADMOB_ANDROID_REWARDED_ID=ca-app-pub-xxxx/xxxx
   --dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-xxxx/xxxx
   --dart-define=ADMOB_IOS_INTERSTITIAL_ID=ca-app-pub-xxxx/xxxx
   --dart-define=ADMOB_IOS_REWARDED_ID=ca-app-pub-xxxx/xxxx
   ```

---

## 4. Firebase Remote Config Anahtarları

Uygulama yeni sürüm çıkmadan uzaktan aşağıdaki parametreleri [`MonetizationRemoteConfigService`](lib/core/monetization/remote_config_service.dart) üzerinden okur:

| Anahtar | Tür | Varsayılan | Açıklama |
|---|---|---|---|
| `ads_enabled` | Boolean | `true` | Tüm reklam sistemini açar/kapatır |
| `banner_ads_enabled` | Boolean | `true` | Ana ekran alt banner reklamını açar/kapatır |
| `interstitial_frequency` | Number | `3` | Kaç tamamlanmış maçta bir tam ekran reklam gösterileceği |
| `rewarded_ads_enabled` | Boolean | `true` | İsteğe bağlı ödüllü reklamları açar/kapatır |
| `premium_feature_keys_json` | JSON Array | `["pro_benefit_no_ads", ...]` | Premium ekranında listelenen avantajlar |
| `disabled_store_product_ids_json` | JSON Array | `[]` | Mağazada geçici olarak gizlenecek ürün kimlikleri |

---

## 5. Güvenlik ve Sunucu Doğrulaması (`firestore.rules` & Cloud Functions)

- [`firestore.rules`](firestore.rules) dosyasında istemcilerin `users/{userId}` belgesine doğrudan `isPremium`, `premiumEntitlement`, `subscriptionProductId`, `premiumExpiresAtMs`, `subscriptionStatus`, `purchasedCosmeticIds` veya `serverVerifiedAt` alanlarını yazması **kesin olarak engellenmiştir**.
- Bu alanlar yalnızca [`functions/src/index.ts`](functions/src/index.ts) içindeki `verifyPurchaseReceipt`, `restoreUserPurchases` ve `processRevenueCatWebhookEvent` fonksiyonları tarafından Firebase Admin SDK yetkisiyle güncellenir.

