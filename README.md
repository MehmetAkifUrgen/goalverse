# GOALVERSE — Futbol Bilgi ve Çok Oyunculu Rekabet Evreni

**Goalverse**, futbol bilgisini, kulüp tarihini, transfer rotalarını ve oyuncu istatistiklerini 7 farklı rekabetçi oyun modunda birleştiren çok oyunculu mobil futbol oyun platformudur.

- **Resmî Marka Adı:** `GOALVERSE` (Normal metin ve mağaza adı: `Goalverse`, teknik sabit: `goalverse`)
- **Platformlar:** Android, iOS, Web
- **Mimari:** Feature-First + Repository Pattern + Riverpod + GoRouter + Firebase

---

## 1. Oyun Modları (7 Rekabetçi Mod)

1. **Football SOS (3×3 Kulüp Kesişimi):** Satır ve sütundaki iki kulüpte de oynamış ortak yıldız futbolcuları bularak 3×3 tabloda üçlü çizgiyi tamamla (vs Akıllı Bot, 2P Aynı Cihaz & Canlı Online Oda).
2. **Rating Battle (Kart Düellosu):** EA FC Overall, piyasa değeri ve kariyer gollerinde üstün olan futbolcu kartını süre dolmadan seç.
3. **2 Takım 1 Oyuncu:** İki dev kulübün kesişimindeki ortak yıldız futbolcuyu bul.
4. **Ben Kimim? (Kariyer İpuçları):** Zordan kolaya açılan 5 kariyer ipucuyla gizli futbol efsanesini en yüksek puanla tahmin et.
5. **Imposter (Ajan Kim?):** 4 futbolcu arasından hedef kulüpte hiç forma giymemiş sahtekâr oyuncuyu yakala.
6. **Transfer Yolu (Kariyer Rotası):** Kronolojik kulüp geçmişini ve sezonları takip ederek gizli futbolcuyu bul.
7. **Futbol Bombası (Parti Modu):** Bomba patlamadan kulüp veya ülke şartına uyan futbolcuyu söyle.

---

## 2. Teknoloji Yığını ve Tasarım Sistemi

- **Framework:** Flutter & Dart
- **State Management:** `flutter_riverpod`
- **Navigasyon:** `go_router` (Oturum ve e-posta doğrulama yönlendirme korumalı)
- **Backend & Gerçek Zamanlı Senkronizasyon:**
  - Firebase Authentication (Google Sign-In, E-posta/Şifre, Şifre Sıfırlama, E-posta Doğrulama, Misafir & Hesap Bağlama)
  - Cloud Firestore (`users`, `games`, `leaderboards`)
  - Firebase Cloud Functions (`createGame`, `joinGame`, `startGame`, `submitAnswer`, `finishGame`, `leaveGame`)
- **Görsel Kimlik (Neon Volt Stadium):**
  - Background: `#101316` | Surface: `#191E23` | Elevated Surface: `#222930`
  - Primary Neon Volt: `#C9FD06` | Primary Text: `#101316` | Foreground: `#F5F7F8` | Muted: `#A0A8AF` | Border: `#303940`
  - Tipografi: `BarlowCondensed` (Başlıklar & Mod Kartları), `SpaceGrotesk` (Tabular Figures Skor/ELO/Süre), `Inter` (Gövde ve Form Metinleri)
- **Çoklu Dil Desteği (6 Dil):** Türkçe (`tr`), İngilizce (`en`), İspanyolca (`es`), Fransızca (`fr`), Almanca (`de`), İtalyanca (`it`)

---

## 3. Kurulum ve Çalıştırma Adımları

```bash
# 1. Bağımlılıkları yükle
flutter pub get

# 2. Kod formatlama ve statik analiz
dart format .
flutter analyze

# 3. Birim ve widget testlerini çalıştır
flutter test

# 4. Uygulamayı geliştirme modunda çalıştır
flutter run
```

---

## 4. Android & iOS Build Komutları

```bash
# Android Debug APK
flutter build apk --debug

# Android Release APK
flutter build apk --release

# Google Play Store Release App Bundle (.aab)
flutter build appbundle --release
```

> **Not:** Android Release imzalama ayarları yerel `android/key.properties` dosyasından okunur (`.gitignore` ile korunmaktadır). Mevcut Firebase ve mağaza uyumluluğunu korumak için `applicationId` (`com.example.football_tic_tac_toe`) ve iOS `PRODUCT_BUNDLE_IDENTIFIER` (`com.example.footballTicTacToe`) sabit tutulmuştur.

---

## 5. Mağaza Metinleri (Google Play & App Store Metadata)

### Türkçe (TR)
- **Uygulama Adı:** Goalverse
- **Alt Başlık / Kısa Açıklama (80 krk):**
  `Futbol bilgini 7 rekabetçi modda kanıtla! Canlı online odalar, SOS ve düello.`
- **Tanıtım Metni (Promotional Text):**
  `Goalverse evreninde sahaya çık! Football SOS, Rating Battle, Transfer Yolu ve canlı 1v1 odalarda rakiplerini yenerek ELO liderlik tablosunda zirveye yüksel.`
- **Uzun Açıklama:**
  `Goalverse, futbol tutkunları için tasarlanmış kapsamlı bir futbol bilgi ve gerçek zamanlı rekabet evrenidir. Tek bir quiz uygulamasından çok daha fazlası olan Goalverse'te 7 farklı oyun modunda tek başına antrenman yapabilir, aynı cihazda arkadaşınla düello atabilir veya 6 haneli oda koduyla canlı online maçlara katılabilirsin.`
  - `Football SOS: 3×3 kulüp kesişim tablosunda ortak yıldızları bul ve stratejik hamlelerle kazan.`
  - `Rating Battle: Futbolcu kartlarının reyting, gol ve piyasa değerlerini karşılaştır.`
  - `Transfer Yolu, Ben Kimim?, Imposter, 2 Takım 1 Oyuncu ve Futbol Bombası modlarıyla futbol kültürünü her açıdan test et.`
  - `Global ELO Sıralaması ve Günlük Mücadeleler ile her gün yeni ödüller kazan!`
- **Anahtar Kelimeler (Keywords):**
  `goalverse, futbol oyunu, futbol quiz, football sos, futbol bilgi yarışması, transfer tahmini, online futbol düello, futbolcu bilmece`

### English (EN)
- **App Name:** Goalverse
- **Subtitle / Short Description:**
  `Prove your football IQ across 7 competitive modes! Live 1v1 rooms & trivia.`
- **Promotional Text:**
  `Step onto the pitch in Goalverse! Compete in Football SOS, Rating Battle, Transfer Path, and live multiplayer rooms to climb the global ELO leaderboard.`
- **Full Description:**
  `Goalverse is the ultimate competitive football gaming universe. Built for true football fans, Goalverse combines tactical grid strategy, player card battles, career path deduction, and real-time multiplayer rooms in one sleek stadium experience.`
  - `Football SOS: Connect clubs on a 3×3 tactical board by naming players who played for both teams.`
  - `Rating Battle: Pick the higher-rated footballer card before the shot clock expires.`
  - `7 Distinct Game Modes: Play Solo vs AI, 2-Player Pass & Play, Quick Match, or Private 6-Digit Online Rooms.`
  - `Climb the Global ELO Leaderboard and complete Daily Challenges!`
- **Keywords:**
  `goalverse, football trivia, soccer quiz, football tic tac toe, transfer path, player rating battle, multiplayer football game`
