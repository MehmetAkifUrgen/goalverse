# Goalverse: Football SOS — Tam Otomatik App Store & Google Play Yayın ve CI/CD Kılavuzu

Bu doküman, **Goalverse: Football SOS** Flutter projesinin Google Play Console ve Apple App Store Connect süreçlerini otomatikleştiren CI/CD, Fastlane, mağaza metinleri (6 dil), otomatik ekran görüntüsü üretimi ve yayın öncesi kalite kontrol (Pre-Flight Gate) mimarisini açıklar.

---

## 1. Mimari Özeti ve Üretilen Dosyalar

| Bileşen | Dosya Yolu | Açıklama |
|---|---|---|
| **Codemagic CI/CD** | `codemagic.yaml` | Android Internal Testing, iOS TestFlight, Unified Staging ve Manuel Onay Korumalı (`CONFIRM_PRODUCTION_RELEASE=true`) Production iş akışları |
| **Android Fastlane** | `android/Gemfile`, `android/fastlane/Appfile`, `android/fastlane/Fastfile` | Google Play Developer API (`supply`) ile AAB, 6 dil mağaza açıklaması, sürüm notu ve ekran görüntüsü yükleme |
| **iOS Fastlane** | `ios/Gemfile`, `ios/fastlane/Appfile`, `ios/fastlane/Fastfile` | App Store Connect API (`pilot` & `deliver`) ile TestFlight, 6 dil metadata ve 6.7" ekran görüntüsü yükleme |
| **6 Dil Mağaza Metinleri** | `scripts/generate_store_metadata.dart`<br>`android/fastlane/metadata/android/*`<br>`ios/fastlane/metadata/*` | Türkçe (`tr-TR`/`tr`), İngilizce (`en-US`), İspanyolca (`es-ES`), Fransızca (`fr-FR`), Almanca (`de-DE`) ve İtalyanca (`it-IT`/`it`) mağaza başlıkları, kısa/uzun açıklamalar, anahtar kelimeler, URL'ler ve sürüm notları |
| **İçerik Derecelendirme & İletişim** | `store_metadata/store_compliance_and_rating.json` | IELTS/IARC ve App Store yaş sınırı (4+ / PEGI 3 / Everyone) anket yanıtları, kategori önerileri ve iletişim bilgileri |
| **Otomatik Ekran Görüntüsü Üretici** | `test/store_screenshots_generator_test.dart` | Uygulamanın gerçek arayüz bileşenlerinden (`HomePage`, `ProfilePage`, Football SOS 3×3 Tahtası, Canlı 1v1 Online Maç, Futbolcu Arama, Seri Sonucu, Liderlik Tablosu, Günlük Görevler) **6 dilde toplam 96 adet** mağaza görseli (`1080×1920` Android & `1290×2796` iOS 6.7") üretir |
| **Sürüm Artırma & Kalite Kontrol** | `scripts/bump_version.dart`<br>`scripts/ci_preflight_check.dart` | Otomatik versiyon/build numarası artırma ve yayın öncesi zorunlu doğrulama kapısı |

---

## 2. Mağaza Bilgileri ve Kategori / Derecelendirme Özeti

- **Uygulama Adı:** `Goalverse: Football SOS` (30 karakter sınırı altında: 23 karakter)
- **Kategori Önerisi:**
  - **Google Play:** Oyunlar → Bilgi Yarışması (*Games → Trivia*) / İkincil: Spor (*Sports*)
  - **Apple App Store:** Birincil: *Games (Trivia)* + *Games (Sports)* / İkincil: *Sports*
- **Gizlilik Politikası URL'si:** `https://goalverse.app/privacy`
- **Destek URL'si:** `https://goalverse.app/support`
- **Pazarlama URL'si:** `https://goalverse.app`
- **İletişim E-postası:** `support@goalverse.app`
- **İçerik Derecelendirmesi (IARC / App Store Age Rating):**
  - Şiddet, kumar, para ödüllü bahis, yetişkin içerik veya küfür **yoktur** (`false`).
  - Uygulama içi satın alımlar (**Football SOS Pro** abonelik ve kozmetik ürünler) **vardır** (`true`, tamamen adil oyun / sıfır rekabet avantajı).
  - Çevrimiçi 1v1 eşleşme vardır; serbest metinli sohbet yoktur (yalnızca yapılandırılmış hamle, pas ve beraberlik teklifi butonları).

Mağaza metinlerini yeniden üretmek için:
```bash
dart run scripts/generate_store_metadata.dart
```

---

## 3. Otomatik Ekran Görüntüsü Üretimi (96 Görsel — 6 Dil × 8 Ekran × 2 Platform)

`test/store_screenshots_generator_test.dart` testi, uygulamanın gerçek Flutter widget'larını stadyum arka planı, telefon çerçevesi ve 6 dilde pazarlama başlıklarıyla (`tr`, `en`, `es`, `fr`, `de`, `it`) render ederek mağaza boyutlarında kaydeder:

1. `01_home_arena.png` — Ana ekran (`HomePage`)
2. `02_football_sos_board.png` — Çok turlu 3×3 Football SOS oyun ekranı
3. `03_online_match.png` — Canlı 1v1 Online Maç & Beraberlik Teklifi ekranı
4. `04_player_search.png` — Futbolcu seçme & tekrar kullanım arama ekranı
5. `05_match_result.png` — Çok turlu maç/seri sonucu ve tur analizi ekranı
6. `06_leaderboard.png` — Küresel ELO liderlik tablosu ekranı
7. `07_profile.png` — Profil, kariyer istatistikleri ve Football SOS Pro ekranı (`ProfilePage`)
8. `08_daily_challenge.png` — 4 aşamalı günlük görevler ekranı

Görselleri tek komutla üretmek için:
```bash
flutter test test/store_screenshots_generator_test.dart
```

Üretilen dosyalar otomatik olarak Fastlane dizinlerine yerleştirilir:
- **Google Play (`1080×1920`):** `android/fastlane/metadata/android/<locale>/images/phoneScreenshots/01_home_arena.png ... 08_daily_challenge.png`
- **Apple App Store 6.7" (`1290×2796`):** `ios/fastlane/screenshots/<locale>/01_home_arena.png ... 08_daily_challenge.png`

---

## 4. Yayın Öncesi Kalite Kontrol Kapısı (`ci_preflight_check.dart`)

Her yayın öncesinde aşağıdaki komut çalıştırılır:
```bash
# Internal Testing / TestFlight için:
dart run scripts/ci_preflight_check.dart

# Production yayını için (CONFIRM_PRODUCTION_RELEASE=true zorunludur):
CONFIRM_PRODUCTION_RELEASE=true dart run scripts/ci_preflight_check.dart --track=production
```

Bu script şu kontrolleri yapar ve herhangi biri başarısız olursa yayını durdurur:
1. `pubspec.yaml` içindeki `version: X.Y.Z+B` formatı ve build numarası kontrolü.
2. Android (`mipmap-*`) ve iOS (`AppIcon.appiconset`) uygulama ikonlarının varlığı.
3. Android ve iOS splash screen yapılandırmalarının varlığı.
4. `applicationId` ve `PRODUCT_BUNDLE_IDENTIFIER` kontrolü (`com.example.*` kullanılıyorsa staging'de uyarır, production'da yayını engeller).
5. 6 dildeki tüm mağaza metinlerinin karakter sınırı kontrolü (Başlık ≤ 30, Kısa Açıklama ≤ 80, Tam Açıklama ≤ 4000, Sürüm Notu ≤ 500, iOS Anahtar Kelime ≤ 100).
6. 96 adet ekran görüntüsünün PNG başlıklarından gerçek piksel çözünürlüğü (`1080×1920` ve `1290×2796`) doğrulaması.

---

## 5. Codemagic Ortam Değişkeni Grupları (Environment Variable Groups)

Hiçbir gizli anahtar kod deposuna yazılmaz. Codemagic panelinde aşağıdaki değişken gruplarını tanımlayın:

### A. `android_signing`
- `CM_KEYSTORE`: Base64 kodlu release `.jks` / `.keystore` dosyası
- `CM_KEYSTORE_PATH`: `/tmp/keystore.jks`
- `CM_KEYSTORE_PASSWORD`: Keystore şifresi
- `CM_KEY_ALIAS`: Key alias adı
- `CM_KEY_PASSWORD`: Key şifresi

### B. `google_play_credentials`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS`: Google Play Console → API Erişimi üzerinden yetkilendirilmiş Service Account JSON içeriği

### C. `app_store_credentials`
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API Key ID (Örn: `2X9R4H...`)
- `APP_STORE_CONNECT_ISSUER_ID`: App Store Connect Issuer ID (UUID)
- `APP_STORE_CONNECT_API_KEY_BASE64`: `.p8` özel anahtar dosyasının Base64 hali
- `APPLE_DEVELOPER_TEAM_ID`: Apple Developer Team ID
- `APP_STORE_CONNECT_TEAM_ID`: App Store Connect Team ID

### D. `release_config`
- `ANDROID_PACKAGE_NAME`: Canlı mağaza paket adı (Örn: `com.goalverse.footballsos`)
- `IOS_BUNDLE_ID`: Canlı mağaza Bundle ID (Örn: `com.goalverse.footballsos`)
- `CONFIRM_PRODUCTION_RELEASE`: Varsayılan `"false"`. Yalnızca canlı yayına çıkarken `"true"` olarak ayarlanır.

---

## 6. Manuel Yapılması Gereken Konsol İşlemleri (Şeffaf Durum Raporu)

1. **Paket Adı (`applicationId`) ve Bundle ID (`PRODUCT_BUNDLE_IDENTIFIER`) Geçişi:**
   - Mevcut projede Firebase `google-services.json` ve `GoogleService-Info.plist` dosyaları `com.example.football_tic_tac_toe` ve `com.example.footballTicTacToe` kimliklerine bağlıdır.
   - Google Play Console ve App Store Connect, `com.example.*` uzantılı paket adlarını canlı mağaza kaydında kabul etmez.
   - Canlı mağaza yayını öncesinde Firebase Console (`flutterfootbalquiz`) üzerinde `com.goalverse.footballsos` (veya seçeceğiniz kurumsal domain) ile Android ve iOS uygulamalarını kaydedip yeni `google-services.json` ve `GoogleService-Info.plist` dosyalarını projeye ekleyin; ardından `ANDROID_PACKAGE_NAME` ve `IOS_BUNDLE_ID` ortam değişkenlerini tanımlayın.
2. **İlk Mağaza Uygulama Kaydı:**
   - Google Play Console'da uygulamanın ilk oluşturulması ve ilk `.aab` dosyasının yüklenmesi (Google Play API kısıtlaması gereği) bir kez konsol arayüzünden yapılmalıdır. Sonraki tüm `internal` ve `production` sürümleri Fastlane/Codemagic tarafından tam otomatik yüklenir.
   - App Store Connect üzerinde uygulama kaydı (`New App`) oluşturulduktan sonra TestFlight ve App Store gönderimleri Fastlane `pilot` ve `deliver` ile tam otomatik çalışır.
3. **Gizlilik Politikası ve Destek Sayfalarının Yayına Alınması:**
   - `https://goalverse.app/privacy` ve `https://goalverse.app/support` adreslerinin mağaza incelemesi öncesinde erişilebilir olduğundan emin olun.

