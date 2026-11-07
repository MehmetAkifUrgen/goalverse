# Football Battle — Multiplayer Party Football Knowledge Platform

## Overview
- **Summary**: "Football Tic Tac Toe" tek modundan **12 modlu futbol bilgi yarışması partisi** haline gelir. 1v1 düellodan 20 kişilik canlı quiz partisine (Party: Survival, Imposter, Football Bomb, Charades) kadar ölçeklenir; TikTok/YouTube Shorts viral içerik formatıyla (Reveal Player, Who Am I, Transfer Path) kullanıcı tutunması hedeflenir.
- **Purpose**: (1) Ürünü tek TTT mekaniği sıkışıklığından kurtarmak; (2) Mevcut **Isar 497 oyuncu / 20 takım / 1513 tarihçe / 190 cevap indeksi** veri setini 12 modun HEPSİNDE **paylaşarak** minimum kod maliyetiyle çok modlu MVP çıkarmak; (3) Arkadaş odası, özel oda ve 2-8 kişi grup modları ile multiplayer davet katsayısını artırmak.
- **Target Users**: Futbol severler 16-35 yaş (Android/iOS), YouTube/TikTok short form tüketen oyuncular, arkadaş grubuyla party oyun arayanlar, EA FC/FIFA topluluğu (rating battle, transfer path).

## Goals
1. **Mod Genişlemesi**: V1'de 5 mod (Tic Tac Toe, 2 Teams 1 Player, Who Am I, Reveal Player, Rating Battle), V2'de 4, V3'te 4 Party = **toplam 12 mod**.
2. **1 Veri Seti × 12 Mod**: Mevcut Player/Team/PlayerTeamHistory + answer_index'i RAAK kullan — Rating (EA FC), Transfer Value, Club × Country ek alanlar 1 kez veri setine eklensin, bütün modlar tüketin.
3. **Maksimum 100ms Performans**: Bütün modların soru hazırlama (soru oluşturma, ipuçları, fotoğraf tile maskesi, transfer path BFS) Isar localde < 100ms P95.
4. **Viral içerik dostu**: Reveal Player 3x3 tile açılımı, Who Am I artan ipuçları, Transfer Path gizli orta kulüpler — her modun "Paylaş" butonu ile tek frame PNG paylaşımı (Paylaş → Clipboard + share_plus).
5. **Party ölçeklenmesi**: 1v1 (2 oyuncu) → 2-4 kişi Mini Party → 5-20 kişi Büyük Canlı Quiz (Survival / Imposter / Bomb).

## Non-Goals
- Gerçek zamanlı VOIP (ses sohbeti) MVP kapsamında değil.
- Canlı maç verisi (flashscore) eklemek — sadece statik futbolcu/kulüp/tarihçe veri seti.
- FIFA lisansı + gerçek forma/fotoğraf telif hakkı (V1 assetler SVG/placeholder; V2 lisanslı data API bağlantısı planlanır ama şimdilik DEĞİL).
- Web/desktop build — yalnız mobil (Android/iOS).
- Tek oyuncu modundan vazgeçmek — bütün modlar **hem solo practise hem 1v1 hem party** olarak oynanabilmeli.

## Background & Context
Mevcut football_arch_revamp spec (TTT) altyapısı:
- Isar v3 4 entity: PlayerIsar, TeamIsar, PlayerTeamHistoryIsar, AnswerIndexIsar
- 497 oyuncu / 20 takım / 1513 tarihçe / 190 answer_index hücresi
- Riverpod 2.x Provider bağlama (playerRepositoryProvider gibi soyut → Isar)
- Firebase Auth + 5 koleksiyon Firestore (users, games, game_players, leaderboards, daily_challenges) + Cloud Functions authoritative submitAnswer
- 6 dil ARB sadece UI, oyuncu/takım ismi ARB'de YOK

**Güncel 2026 futbol bilgi oyunu örnekleri (rakip analizi)**:
1. Football Quiz: Ultimate Test — FIFA rating, 2 Teams 1 Player, TTT, forma, transfer, Who Am I, logo
2. Football Quiz Live — 20 kişilik canlı quiz, Survival, Imposter (Among Us futbol uyarlama), Who Has the Bomb
3. Head-to-Head Football — 1v1 Rating Battle, Kit Guess, Logo Guess
4. Sports Trivia Legends — Reveal Player (fotoğraf kademeli açılım), TikTok paylaşımı

**Karar**: Mevcut TTT'yi tek mod tutmak yerine **aynı veri setini 12 kere farklı açıdan tüketen platform** yap; TTT = modlardan sadece 1 tanesi.

## Functional Requirements

### Kategori 1 — Çekirdek (V1 ve sonrası ZORUNLU)
- **FR-CH-1**: Her mod için `GameMode` enum + abstract `MiniGameEngine` interface: `generateQuestion() → QuestionState`, `submitAnswer(playerId, answer) → SubmitResult`, `getScoreBoard() → ScoreBoard`.
- **FR-CH-2**: Ana menü GAME MODES grid listesi — 12 mod kartı; V1'de 5 kart etkin yeşil overlay, V2/V3 kilitli kilit ikonu + "YAKINDA".
- **FR-CH-3**: Quick Match (1v1 rastgele rakip Firestore oyun + AI fallback), Play With Friends (oda kodu 6 haneli QR + davet bağlantısı deep link), Daily Challenge (her gün 8 soru 8 mod sırayla).
- **FR-CH-4**: Veri modeli genişlemesi — Player entity alan ekleri: `eaFcOverall?`, `marketValueEuro?`, `age?`, `goalsCareer?`, `assistsCareer?`, `speed?`, `championsLeagueGoals?`; Team entity ek: `primaryColor/secondaryColor` + kit/club logo asset path `logoAssetPath?`, `kitAssetPath?`; Player ek: `clue1..clue4`, `photoAssetPath?`.
- **FR-CH-5**: Mod bazlı Provider (riverpod) + Route: her mod `lib/features/<mode_id>/` klasörlenir; `/mode/two-teams-one-player`, `/mode/who-am-i` rota.
- **FR-CH-6**: Paylaş (Share) mekanizması: her modun soru ekranında `share_plus` ile tek frame PNG / skor card paylaşımı.
- **FR-CH-7**: Arkadaş odası + oda kodu: 6 haneli oda kodu (letters/digits) + QR encode; deep link `footballbattle://room/ABC123`.

### Kategori 2 — V1 Modları (İlk Lansman, 5 Mod)
- **FR-V1-1 (Mod 1: Tic Tac Toe)**: Mevcut `features/game/engine` + `game_page.dart` koruruz; 3x3 takım grid 9 hücre, min 3 oyuncu/hücre, hamle arası 30sn, 1v1 veya 2-4 kişi sırayla.
- **FR-V1-2 (Mod 2: 2 Teams 1 Player)**: Difficulty.easy 12 zorluk seviyesi takım çiftinden rastgele seç; ekran Real Madrid + Juventus ortasında ???; TextField oyuncu ismi, ilk doğru 100 puan; hızlı cevap bonusu (+25 ilk 5sn); yanlış cevapta rakibe hak aktar (1v1'de).
- **FR-V1-3 (Mod 3: Who Am I?)**: Tek oyuncu için sıralı 4 ipucu (1) ülke bayrağı, (2) kupalar, (3) son takım, (4) ek sıra position/ayakkabı; her ipucu puan düşüşü: 1000/750/500/250, süre toplam 18sn; 8 soru tur.
- **FR-V1-4 (Mod 4: Reveal Player)**: 3x3 kareler kapalı, her açılım puan düşer: 9tile=1000, 6=800, 4=600, 2=400, 1=200; tile açma butonu (ücretsiz 2 hakkı + 1 hakkı günlük reklam/coin); ilk doğru cevap +100.
- **FR-V1-5 (Mod 5: Player Rating Battle)**: EA FC overall, market value, yaş, gol, asist, hız, şampiyonlar ligi golü — 8 kategori; 2 oyuncu yan yana, daha yüksek olanı seç; 10 tur * 100 puan.

### Kategori 3 — V2 Modları (İkinci Lansman, 4 Mod)
- **FR-V2-6 (Mod 6: Transfer Path)**: Başlangıç ve bitiş takım verilir, 2-4 ara takım gizli; oyuncu kariyer zincirini (BFS: Arsenal → ? → ? → Real Madrid → Özil doğru mu?) bulmaya çalışır; Her doğru adım +150, yanlış zincir kırma -50.
- **FR-V2-7 (Mod 7: Kit Guess)**: Forma SVG/asset gösterilir, A/B/C/D 4 takım şıkkı; ilk doğru cevap puan.
- **FR-V2-8 (Mod 8: Logo Guess)**: Takım logosu blur/pixelate; 4 şık; 5-20 kişi live quiz için çok uygun.
- **FR-V2-9 (Mod 9: Club × Country)**: Kulüp + Ülke bayrağı → ortak oyuncu (örn: Chelsea + 🇫🇷 → Kante). answer_index'te `teamId|COUNTRY_CODE` için yeni indeks + veri seti genişlemesi.

### Kategori 4 — V3 Party Modları (Üçüncü Lansman, 4 Mod)
- **FR-V3-10 (Mod 10: Survival)**: 8 kişi, herkes 3 can; soru 4 şık; yanlış → can -1; 0 can → ELIMINATED; son kalan kazanır.
- **FR-V3-11 (Mod 11: Imposter)**: 6 kişi, 5 kişi AYNI futbolcu, 1 kişi FARKLI (Imposter); 4 tur ipucu paylaşımı → oylama; Imposter kalmaması halinde 5 oyuncu kazanır, Imposter son kalırsa Imposter 2x puan kazanır.
- **FR-V3-12 (Mod 12: Football Bomb)**: Kategori örn: "Real Madrid'de oynayanlar"; oyuncular sırayla benzersiz futbolcu söyler; 5sn timer; cevap vermezse BOOM elenir; 2-20 kişi.
- **FR-V3-13 (Bonus Mod 13: Football Charades)**: Sonradan — bir oyuncuya 1 futbolcu kelimesi, diğerleri bilmez; 30sn anlatma + cevaplama turu.

### Kategori 5 — Arkadaş Odası / Çok Oyunculu
- **FR-FR-1**: Özel oda oluştur → host max oyuncu (2/4/6/8/12/20), mod seçimi, süre ayarı, oya daveti linki + QR.
- **FR-FR-2**: Oyuncu hazır (Ready) butonu → host Start Game tuşuna basınca başlar.
- **FR-FR-3**: Canlı Skorboard saydam overlay — her tur sonunda güncellenir.
- **FR-FR-4**: Eşzamansız turnuva: 8 oyuncu single elimination bracket, V2 sonrası.

## Non-Functional Requirements
- **NFR-1**: Mod sorusu hazırlama (herhangi 12 moddan biri) P95 < 100 ms (Isar local).
- **NFR-2**: Paylaşılabilir PNG export (share_plus) < 500 ms.
- **NFR-3**: Canlı party modlarında Firestore realtime listener ile güncelleme latency < 1 saniye (sadece network + Firestore).
- **NFR-4**: 12 modlu uygulama apk release boyutu < 80 MB.
- **NFR-5**: Arkadaş odası QR scan + 6 haneli kod girişinin kullanıcı başarı oranı > %95.
- **NFR-6**: L10n — bütün yeni mod UI key'leri 6 dile (en/es/fr/de/tr/it) çevrilecek; oyuncu/takım/ülke ismi yine ARB'de YOK.
- **NFR-7**: Memory — Modlar arası geçişte Isar close/open yapılmaz, açık tutulur; 12 moddan hiçbirinde backstack'te dispose çağrılmamış ChangeNotifier YOK.

## Constraints
- **Teknik**: Flutter 3.35+, Dart 3.9+, Riverpod 2.x **SADECE** GetX/BLoC YOK; Isar v3 **Hive DEĞİL**; Firebase (Auth, Firestore, CF, Analytics, Crashlytics, RC, App Check); share_plus, qr_flutter, mobile_scanner; cached_network_image (opsiyonel, ama asset ise YOK; V1 yalnız asset SVG/placeholder).
- **İş**: Supabase KULLANILMAYACAK. Tic Tac Toe modu ÜRÜNDEN KALDIRILMAYACAK — modlardan 1 numara olarak kalmalı. Yeni modlarda telif hakkı riskli içerik (gerçek forma foto, oyuncu fotoğrafı) V1'de placeholder/SVG ile geçilir.
- **Veri seti**: 1 mod için ayrı JSON/collection YOK — bütün modlar tek Isar dataset'inden beslenir; Rating/Value/Club×Country alanları 1 kez eklenir, herkes kullanır.

## Assumptions
- Player `eaFcOverall` gibi eksik alanlar V1'de nullabledır ve null ise Rating Battle modu o kategoriyi rastgele seçmez (bir fallback "genel" kategori döner).
- Kit Guess / Logo Guess modu V1'de kilitli (YAKINDA), V2 için assetler eklendikten sonra açılır.
- 5-20 kişi canlı modlar (Survival, Imposter, Bomb) Firestore dokümanına her oyuncu cevap realtime write + Cloud Functions authoritative merge ile çalışır.
- Oda kodu 6 karakter (uppercase letters + digits, karıştır, benzersiz yap).
- Deep link `footballbattle://room/ABC123` Android App Links + iOS Universal Link ile.

## Open Questions
- [ ] V1'de share_plus ile share card tasarımı — sabit template mi, mod temalı (Renk/Tema) mı? (Ön varsayım: Mod temalı — TTT yeşil, Rating Battle mavi)
- [ ] EA FC Rating / Market Value alanları — V1'de RANDOM mock veri (mevcut 497 oyuncu için deterministik hash-based: ronaldo → 93, messi → 92) mi asıl API mi? (Ön varsayım: **Hash-based stable mock** — hiçbir dış API bağımlılığı olmadan uygulama açılsın)
- [ ] Who Am I clue'ları — 4 adet (Ülke, Kupalar, Son Takım, Pozisyon) veya 6 (Ayrıca Yaş, Ayakkabı Marka) mı? (Ön varsayım: 4)
- [ ] Football Bomb modu "Kategori havuzu" — 200+ önceden tanımlı kategori (Real Madrid, Barcelona, PL, 2022 WC kadrosu) mi yoksa oyuncu seçimi mi? (Ön: 200 kategori + Club×Country otomatik türet)
- [ ] Imposter modu oylama — her oyuncu aynı anda mı oylar (realtime merge) yoksa tur bazında mı? (Ön: Tur sonu aynı anda submit)

## Acceptance Criteria

### AC-P1: Platform ana menüsü 12 mod kartı + 3 kilit seviyesi
- **Type**: `rule`
- **Given**: Uygulama açılıp AuthGate → HomePage girildi
- **When**: GAME MODS grid listesi açılır
- **Then**: 12 mod kartı listelenir; 5 tanesi yeşil ETKİN (V1), 4 tanesi kilit AMA V2 (YAKINDA gri), 3 tanesi kilit + V3 (Parti modu mor kilit)
- **Pass Condition**: HomePage build + Mod kartı sayısı = 12, ilk 5 onPressed aktif çalışır.
- **Evidence**: Widget test + Screenhot.

### AC-P2: Aynı veri seti 5 V1 modunda RAAK kullanılır
- **Type**: `rule`
- **Given**: Isar veritabanı yüklü
- **When**: V1'deki 5 modun hepsi 1 kez çalıştırılır, her biri bir soru üretir
- **Then**: Modların hiçbiri Firestore'dan oyuncu/takım VERİSİ çekmez (network log sadece auth/analytics); Isar okuma sayısı ≤ her soru başına 3 okuma
- **Pass Condition**: Charles / DevTools network trace + Isar debug logs.
- **Evidence**: Network trace + Isar query log.

### AC-P3: Mod bazlı soyutlama (MiniGameEngine interface) + 5 mod impl var
- **Type**: `rule`
- **Given**: lib/features/ klasör yapısı
- **When**: `ls lib/features` komutu çalıştırılır
- **Then**: `tic_tac_toe`, `two_teams_one_player`, `who_am_i`, `reveal_player`, `rating_battle` klasörleri mevcuttur; her birinde `<mod>_engine.dart` soyut interface'i impl eder
- **Pass Condition**: 5 klasör + 5 engine dosyası mevcut; `abstract class MiniGameEngine` her birinde `with` ya da `extends`.
- **Evidence**: Klasör ağacı + grep.

### AC-P4: 2 Teams 1 Player modu 12 takım çifti 3+ oyuncu garantisi
- **Type**: `rule`
- **Given**: answer_index 190 hücre mevcut
- **When**: 2 Teams 1 Player generateQuestion() 100 kez çağrılır
- **Then**: 100 sorunun da ortak oyuncu sayısı ≥ 3
- **Pass Condition**: 100 çağrıda 0 tane 0/1/2 oyuncu.
- **Evidence**: Unit test 100 assertion.

### AC-P5: Who Am I puan düşüşü (1000/750/500/250) doğru uygulanır
- **Type**: `rule`
- **Given**: Who Am I ekranı açık
- **When**: Kullanıcı 1. ipucundan cevaplar, 2. ipucundan, 3., 4.
- **Then**: Sonraki tur skorboard'da doğru cevaplar sırasıyla +1000, +750, +500, +250 olarak eklenir
- **Pass Condition**: Widget test 4 ayrı cevap sonrası skorlar match.
- **Evidence**: Unit test.

### AC-P6: Reveal Player tile açılımı puan tablosu doğru
- **Type**: `rule`
- **Given**: 3x3 kapalı kareler
- **When**: 9 tile açıkken cevap → 6 → 4 → 2 → 1
- **Then**: Skorlar 1000 / 800 / 600 / 400 / 200 olarak eklenir
- **Pass Condition**: 5 test case × 1 assertion = 5 PASS.
- **Evidence**: Unit test.

### AC-P7: Rating Battle 8 kategori null olmadan çalışır
- **Type**: `rule`
- **Given**: Rating Battle ekranı
- **When**: 10 tur boyunca kategoriler rast gelir
- **Then**: Hiçbir tur "null kategori" hatası YOK; Oyuncu A ve B değerleri karşılaştırılır, büyük olan +100 puan
- **Pass Condition**: 10 tur testi Hata 0, skor doğru.
- **Evidence**: Unit test.

### AC-P8: Arkadaş odası 6 haneli benzersiz kod + QR
- **Type**: `rule`
- **Given**: Play With Friends butonu
- **When**: Oda oluşturulur
- **Then**: 6 karakter (A-Z + 0-9) benzersiz (aynı anda 2 oda aynı kod YOK); QR ekranda gösterilir; deep link footballbattle://room/<kod> ile giriş yapılır
- **Pass Condition**: 100 oda oluştur → 0 kod çakışması; QR decode link ile aynı; deep link route açılır.
- **Evidence**: Unit test + Integration test.

### AC-P9: Share card (paylaş) her 5 V1 modunda çalışır
- **Type**: `rule`
- **Given**: Herhangi 1 V1 mod oyun sonu ekranı
- **When**: Paylaş butonuna basılır
- **Then**: share_plus paylaşım sheet'i açılır; skor + oyun sonu görseli sistem galerisine / uygulama içine paylaşılır; hata YOK
- **Pass Condition**: 5 mod × 1 kez share = 5 PASS.
- **Evidence**: Widget + manual test.

### AC-P10: 12 Mod L10n — Hiç futbolcu/takım ismi ARB'de yok
- **Type**: `rule`
- **Given**: 6 ARB dosyası
- **When**: Ronaldo/Messi/Real Madrid/Barcelona kelimeleri grep'lenir
- **Then**: 0 eşleşme — bütün yeni key'ler `modTwoTeamsTitle`, `whoAmILevel2` gibi UI formatı
- **Pass Condition**: grep count = 0.
- **Evidence**: Terminal grep çıktısı.

### AC-P11: Transfer Path V2 — BFS algoritması Arsenal→?→?→Real Madrid için geçerli en az 1 zincir
- **Type**: `rule`
- **Given**: 1513 tarihçe kayıtlı Isar
- **When**: Transfer Path 100 rastgele (Start Kulüp, Bitiş Kulüp) çifti üret
- **Then**: 100 çiftin en az 95 tanesi için geçerli oyuncu/ara kulüp zinciri BULUNUR (2-4 ara takım).
- **Pass Condition**: 95/100 geçerli path.
- **Evidence**: Unit test.

### AC-P12: Survival 8 kişi × 3 can doğru akış
- **Type**: `rubric`
- **Dimension**: Party modu canlılığı, hata oranı
- **Scale**: 1-5
  - 1 = Oylama / can düşüşleri %30+ yanlış
  - 3 = Elenme doğru ama sırama hataları var
  - 5 = 8 oyuncu × 10 tur testinde son kalan gerçekten en son doğru cevap verendir; canlar eşleşir
- **Pass Threshold**: >= 4
- **Evidence**: Integration test (8 dummy player) + Firestore emulator.

### AC-P13: Imposter modu 5 doğru + 1 imposter — tespit oranı
- **Type**: `rubric`
- **Dimension**: Oyun mekaniği denge, Imposter kazanma oranı
- **Scale**: 1-5
  - 1 = Imposter 10 turda %90+ kaybeder, oyun keyifsiz
  - 3 = Denge kararsız
  - 5 = 100 oyunda Imposter kazanma oranı %30-%40 aralığında; 5 oyuncu (gerçekler) kazanma %60-%70; keyifli
- **Pass Threshold**: >= 4
- **Evidence**: Simülasyon test + alpha kullanıcı testi.

### AC-P14: Football Bomb 8 kişi × "Kategori: Real Madrid oyuncuları" sırası doğru
- **Type**: `rule`
- **Given**: Football Bomb modu 8 oyuncu
- **When**: Real Madrid kategorisinde 8 oyuncu sırayla cevap verir (Ronaldo, Özil, Ramos, Benzema, Modric, Casillas, Zidane, Bale)
- **Then**: Bütün cevaplar benzersizdir; 9. oyuncu tekrar söylerse veya 5sn aşarsa BOOM elenir
- **Pass Condition**: Tekrar → Hemen yanlış; timeout → hemen yanlış.
- **Evidence**: Unit test.


Task 0: Player/Team model alanlarını genişlet (Freezed + Isar), deterministic mock rating üret, build_runner çalıştır
Task 1: MiniGameEngine soyut sınıf + QuestionState/ScoreBoard + GameMode 13 enum + GameModeHelper
Task 2: HomePage GAME MODS 13 kart grid + yeni ARB key 6 dil
Task 3: GoRouter 9 yeni rota + deep link handler
Task 4: Mod 2 — 2 Teams 1 Player engine + page
Task 5: Mod 3 — Who Am I engine + page + clues
Task 6: Mod 4 — Reveal Player 3x3 tile + page
Task 7: Mod 5 — Rating Battle 8 kategori + page