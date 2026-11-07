# Football Battle Multi-Platform — Implementation Plan

## Task 0: Çekirdek Veri Modeli ve Altyapı Genişletmesi (Player + Team Ek Alanlar)
- **Status**: `pending`
- **Priority**: high
- **Depends On**: Mevcut Isar + Repo (football_arch_revamp tamamlandı)
- **Description**:
  - lib/data/models/freezed/player.dart alan ekle: `int? eaFcOverall`, `int? marketValueEuro`, `int? age`, `int? goalsCareer`, `int? assistsCareer`, `int? speedRating`, `int? clGoals`, `List<String>? clues`, `String? photoAssetPath`
  - lib/data/models/freezed/team.dart alan ekle: `String? primaryColorHex`, `String? secondaryColorHex`, `String? logoAssetPath`, `String? kitAssetPath`
  - lib/data/models/isar/player_isar.dart aynı alanları ekle, `@Index` ekleri (eaFcOverall sort için opsiyonel)
  - lib/data/models/isar/team_isar aynı renk/logo/kit alanları ekle
  - data_pipeline V1 alanları üretmek için: `deterministic_mock_rating.py` modülü — oyuncu id hash'i → 65-94 rating arası stable (Ronaldo:93, Messi:92); clues 4 tane ülke/kulüp/pozisyon/kupa; market value rating ^2 * 1000000 €
  - lib/data/repositories/player_repository.dart + isar_player_repository.dart ek: `searchPlayersWithClues`, `getRandomWhoAmI`, `getRandomRatingPair(category: RatingCategory)` gibi yardımcı fonksiyonlar
  - `dart run build_runner build --delete-conflicting-outputs` çalıştır, g.dart dosyalarını güncelle
  - Isar schema version 2'ye çıkar, migration (sadece alan ekleme — otomatik)
- **Acceptance Criteria Addressed**: AC-P2, AC-P7 (Rating 8 kategori), AC-P5 (Who Am I clues 4)
- **Test Requirements**:
  - `rule` TR-0.1: 12 yeni alan Isar+Freezed modellerinde mevcut. **Evidence**: Grep "eaFcOverall\|clues\|primaryColorHex" 2 model dosyasında 4+ eşleşme
  - `rule` TR-0.2: Deterministik mock rating → Messi/Ronaldo 90+. **Evidence**: 497 oyuncu için `eaFcOverall` median 78, Max ≥93
  - `rule` TR-0.3: build_runner exit 0. **Evidence**: Komut çıktısı
- **Completion Evidence**:

## Task 1: Soyut MiniGameEngine Interface + GameMode enum
- **Status**: `pending`
- **Priority**: high
- **Depends On**: Task 0
- **Description**:
  - Yeni abstract: `lib/features/game_core/mini_game_engine.dart` — `abstract class MiniGameEngine with ChangeNotifier`; metodlar: `Future<QuestionState> generateQuestion({required int round}); Future<({bool correct, int scoreGain})> submitAnswer({required String playerId, required dynamic answer}); ScoreBoard get scoreBoard; Stream<GameState> get stateChanges; void dispose();`
  - `QuestionState`, `ScoreBoard`, `GameState` data class'ları `lib/features/game_core/models/` altında freezed ile
  - `GameMode enum { ticTacToe, twoTeamsOnePlayer, whoAmI, revealPlayer, ratingBattle, transferPath(V2), kitGuess(V2), logoGuess(V2), clubCountry(V2), survival(V3), imposter(V3), bomb(V3), charades(V3 bonus) }`
  - `GameModeHelper`: `icon`, `title`, `description`, `playersMin/Max`, `version(GameVersion.v1/v2/v3)`, `modUnlockLevel`
  - lib/core/providers.dart içine `miniGameEngineProviderFactory(GameMode mode) → Provider<MiniGameEngine>` builder pattern
- **Acceptance Criteria Addressed**: FR-CH-1, AC-P3
- **Test Requirements**:
  - `rule` TR-1.1: GameMode'da 13 enum değeri mevcut. **Evidence**: Enum length == 13
  - `rule` TR-1.2: MiniGameEngine 5 V1 modunda extends/with kullanılıyor. **Evidence**: Grep "extends MiniGameEngine\|with MiniGameEngine" 5 file 5 sonuç
  - `rule` TR-1.3: GameModeHelper.version(5 tane) == GameVersion.v1; 4 == v2; 4 == v3. **Evidence**: Unit test
- **Completion Evidence**:

## Task 2: Ana Menü (HomePage) GAME MODS grid + Quick Match / Play With Friends / Daily Challenge 3 başlık
- **Status**: `pending`
- **Priority**: high
- **Depends On**: Task 1
- **Description**:
  - Mevcut `lib/features/home/presentation/home_page.dart` tamamen yeniden yaz (eski 4 buton yerine 12 mod kartı)
  - Header: "FOOTBALL BATTLE" + Logo; Hızlı 3 Ana Buton: Quick Match (1v1 rastgele), Play With Friends (oda kur), Daily Challenge (8 soru/8 mod)
  - GAME MODS Section — 4 kolon × 3 satır Wrap: Her kart için `ModeCard(mode: GameMode.twoTeamsOnePlayer)`; V2/V3 olanlar için kilit + YAKINDA badge
  - ModeCard: Icon, Başlık, Oyuncu aralığı (örn: 2-20), V1 ise "Oyna" butonu yeşil
  - AppLocalizations yeni key'ler 6 dile: `gameModeTtt`, `gameModeTwoTeams`, `gameModeWhoAmI`, `gameModeRevealPlayer`, `gameModeRatingBattle`, `gameModeTransferPath`, `gameModeKitGuess`, `gameModeLogoGuess`, `gameModeClubCountry`, `gameModeSurvival`, `gameModeImposter`, `gameModeBomb`, `gameModeCharades`, `comingSoon`, `quickMatch1v1`, `playWithFriends`, `roomCode`, `shareRoom`
  - Her mode kartı onPressed → GoRouter: `/mode/two-teams-1-player?room=local` şeklinde
- **Acceptance Criteria Addressed**: AC-P1, FR-CH-2, FR-CH-3, AC-P10
- **Test Requirements**:
  - `rule` TR-2.1: HomePage render'da ModeCard sayısı == 13. **Evidence**: Widget test find.byType(ModeCard) 13 match
  - `rule` TR-2.2: V2/V3 kilitli kartlar onPressed null. **Evidence**: test
  - `rule` TR-2.3: 13 mod l10n key'i 6 ARB'de mevcut. **Evidence**: grep 6 dosya × 13 key 78 eşleşme
- **Completion Evidence**:

## Task 3: GoRouter Genişletmesi — 9 Yeni Rota + Deep Link (oda kodu)
- **Status**: `pending`
- **Priority**: high
- **Depends On**: Task 2
- **Description**:
  - lib/core/routing/app_router.dart ek route:
    - `/mode/tic-tac-toe` → mevcut GamePage (id:ttt)
    - `/mode/two-teams-1-player` → TwoTeamsOnePlayerPage
    - `/mode/who-am-i` → WhoAmIPage
    - `/mode/reveal-player` → RevealPlayerPage
    - `/mode/rating-battle` → RatingBattlePage
    - `/room/:code` → FriendRoomPage (QR girildiğinde / oyuncu davet linki)
    - `/friend` → FriendRoomSetupPage (oda oluştur)
  - Deep link: `footballbattle://room/ABC123` → GoRouter redirect handler
  - Shell route: Tüm mod sayfaları AppBar geri + Scoreboard appbar action
- **Acceptance Criteria Addressed**: FR-CH-5, AC-P8
- **Test Requirements**:
  - `rule` TR-3.1: Toplam route sayısı önceki 9 + 9 yeni = 18. **Evidence**: GoRouter routes liste length
  - `rule` TR-3.2: Deep link `/room/ABC123` doğru FriendRoomPage açar. **Evidence**: Widget test with platform dispatcher
- **Completion Evidence**:

## Task 4: Mod 2 — 2 Teams 1 Player
- **Status**: `pending`
- **Priority**: high
- **Depends On**: Task 0, Task 1
- **Description**:
  - Klasör: `lib/features/two_teams_one_player/`
  - engine: `TwoTeamsOnePlayerEngine extends MiniGameEngine` — 8 tur, her tur answer_index'ten min 3 oyuncu olan takım çifti seç, 100 puan, ilk 5sn cevap +25 fast answer
  - presentation: `TwoTeamsOnePlayerPage` — Ekran ortasında 2 Büyük takım kart (Ad + Ülke bayrağı + primaryColor arka plan) + arasında + + ???; altta TextField autocomplete (PlayerSearchBottomSheet reuse)
  - 1v1 karşı taraf cevap hakkı: yanlış cevap 1s delay sonra rakip otomatik hak kazanır (solo practise modunda AI 2sn bekler random %60 doğru)
- **Acceptance Criteria Addressed**: FR-V1-2, AC-P4
- **Test Requirements**:
  - `rule` TR-4.1: generateQuestion 100 çağrıda ≥3 oyuncu oranı %100. **Evidence**: Unit test 100 assert
  - `rule` TR-4.2: Fast answer <5sn puan 125, >5sn 100. **Evidence**: Unit test fake timer
  - `rule` TR-4.3: Yanlış cevapta karşı tarafa hak. **Evidence**: Engine test
- **Completion Evidence**:

## Task 5: Mod 3 — Who Am I?
- **Status**: `pending`
- **Priority**: high
- **Depends On**: Task 0 (clues 4 adet), Task 1
- **Description**:
  - Klasör: `lib/features/who_am_i/`
  - engine: `WhoAmIEngine` — her tur Player seç, clues 4 listesini clue1=ülke bayrağı, clue2=en son kupası, clue3=son forma takımı, clue4=pozisyon
  - Puanlama: 1000/750/500/250 — 4 ClueState (bir ipucu açık/iki/üç/dört)
  - Timer: Toplam 18sn, her 4.5 sn'de otomatik bir sonraki ipucu açılır
  - Page: Büyük "WHO AM I?" başlık; 4 clue kart (sonraki ipucu blurlu kilidi); Timer chip; altta oyuncu arama (PlayerSearchBottomSheet reuse)
- **Acceptance Criteria Addressed**: FR-V1-3, AC-P5
- **Test Requirements**:
  - `rule` TR-5.1: 4 clue sırası ÜLKE-KUPA-TAKIM-POZ. **Evidence**: Unit test clue list order
  - `rule` TR-5.2: 1. clue cevap 1000, 2. 750, 3. 500, 4. 250. **Evidence**: 4 × submitAnswer test case skor match
  - `rule` TR-5.3: 18sn timer bittiğinde yanlış sayılır, 0 puan. **Evidence**: fake async test
- **Completion Evidence**:

## Task 6: Mod 4 — Reveal Player
- **Status**: `pending`
- **Priority**: high
- **Depends On**: Task 0 (photoAssetPath), Task 1
- **Description**:
  - Klasör: `lib/features/reveal_player/`
  - engine: `RevealPlayerEngine`
  - 3x3 kare GridView 9 tile: başlangıç 9 kapalı; her "Bir parça aç" butonu 1 tile random açar; hakkı başlangıçta 2 (Daily challenge sonunda +1 hakkı kazan)
  - Puan: 9 tile → 1000, 6 → 800, 4 → 600, 2 → 400, 1 → 200 (kapalı tile sayısına göre tablo)
  - Page: 3x3 Grid (her tile stack: placeholder color + açık tile ise player photo (asset/placeholder)), "Aç" butonu hakkı, cevap TextField, timer
- **Acceptance Criteria Addressed**: FR-V1-4, AC-P6
- **Test Requirements**:
  - `rule` TR-6.1: 9 tile kapalıyken +1 → 8; skor tablosu doğru. **Evidence**: 5 case test
  - `rule` TR-6.2: Günlük hak sıfırlama (SharedPreferences). **Evidence**: test prefs mock
- **Completion Evidence**:

## Task 7: Mod 5 — Player Rating Battle
- **Status**: `pending`
- **Priority**: high
- **Depends On**: Task 0 (eaFcOverall, marketValue, age, goals, assists, speed, clGoals 8 kategori), Task 1
- **Description**:
  - Klasör: `lib/features/rating_battle/`
  - engine: `RatingBattleEngine` — 8 kategori enum `RatingCategory {eaFcOverall, marketValue, ageLOW, goals, assists, speed, clGoals, ageHIGH}` (ageLOW = daha yaşlı olan kazanır; ageHIGH tam tersi)
  - 10 tur, her tur 2 oyuncu (aynı takımdan değil) yan yana; büyük olanı seç, doğru 100 puan
  - Page: İki büyük oyuncu kart (isim + forma rengi); VS ikonu; ortada büyük kategori etiketi (EA FC RATING / MARKET VALUE / YAŞ); Altta İki büyük buton [MBAPPÉ] [VINICIUS]
- **Acceptance Criteria Addressed**: FR-V1-5, AC-P7
- **Test Requirements**:
  - `rule` TR-7.1: 8 kategori enum. **Evidence**: length == 8
  - `rule` TR-7.2: 10 tur null kategori YOK. **Evidence**: 100 soru generate test 0 null
  - `rule` TR-7.3: Doğru cevap +100, yanlış 0 (negatif puan YOK). **Evidence**: test
- **Completion Evidence**:

## Task 8: Arkadaş Odası (6 haneli kod + QR + Deep Link) + Ready/Start
- **Status**: `pending`
- **Priority**: high
- **Depends On**: Task 3
- **Description**:
  - `lib/features/friend_room/` kurulum
  - Oda kurulum ekranı: Mod seçim (5 V1'den 1), Oyuncu sayısı (2/4/6/8/12/20), Her tur süresi slider (15/30/45/60sn), Oda kodu butonu: "Yeni kod üret" + QR + Paylaş butonu + "Kodu kopyala"
  - Oda katıl ekranı: 6 haneli TextInput + QR scan butonu (mobile_scanner package)
  - Hazır / Başlat: Oyuncu 2-12 listesi, her oyuncu için Ready chip; host (oluşturan) Start Game butonu
  - Firestore `rooms` koleksiyonu (önceden izinli 5 koleksiyona EKLENDİ — AC-1 5 koleksiyonu genişlet, rooms artı 6. izinli koleksiyon)
  - Security rules: rooms match eklendi; sadece host startGame; sadece aynı oda oyuncuları read/write kendi doc
  - Cloud Functions: onCall createRoom, joinRoom, ready, startRoom
- **Acceptance Criteria Addressed**: FR-CH-7, FR-FR-1/2/3, AC-P8
- **Test Requirements**:
  - `rule` TR-8.1: 100 oda kod çakışması 0. **Evidence**: Unit test 100 benzersiz
  - `rule` TR-8.2: Deep link yönlendirme çalışır. **Evidence**: go_router redirect test
  - `rule` TR-8.3: Oyuncu readies 2 → host start possible. **Evidence**: Engine test.
- **Completion Evidence**:

## Task 9: Paylaş (Share Card) — Mod 1-5 için 5 farklı tasarım + share_plus entegrasyonu
- **Status**: `pending`
- **Priority**: medium
- **Depends On**: Task 4-7 (5 mod)
- **Description**:
  - Yeni paketler: `share_plus`, `qr_flutter` (pubspec ekle)
  - `lib/core/share/share_card.dart` her mod için share card PNG exporter: `RepaintBoundary → toImage() → ByteData → save temp file → Share.shareXFiles()`
  - Skor kart şablonları: 1. TTT (3x3 board görüntüsü), 2. 2Teams (İki takım + oyuncu adı), 3. WhoAmI (4 clue + doğru isim), 4. Reveal (9 tile + sonuç), 5. Rating Battle (2 oyuncu karşılaştırma)
  - Her mod oyun sonu ekranında "Paylaş" butonu.
- **Acceptance Criteria Addressed**: FR-CH-6, AC-P9
- **Test Requirements**:
  - `rule` TR-9.1: pubspec'de share_plus ve qr_flutter mevcut. **Evidence**: grep 2 tane
  - `rule` TR-9.2: 5 mod sayfasında share butonu. **Evidence**: Widget test find.byTooltip('share') 5 match
- **Completion Evidence**:

## Task 10: Mod 6-9 (V2 YAKINDA Kilidi Açılmayacak, ama iskelet kur)
- **Status**: `pending`
- **Priority**: medium
- **Depends On**: Task 1
- **Description**:
  - Transfer Path, Kit Guess, Logo Guess, Club × Country için sadece klasör + page stub + engine stub (sayfada "YAKINDA — V2'de geliyor!" diyen ComingSoonScreen reuse; HomePage kartlarını V2 listesinden YAKINDA badge ile göstermek için Task 2 yeter, bu task sadece V2 veri hazırlığı için)
  - Transfer Path BFS algoritması `lib/data/services/transfer_path_finder.dart` yaz (Graph BFS oyuncu geçmişi üzerinden: kulüp1 → oyuncu → kulüp2 → oyuncu → kulüp3)
  - Club × Country için `club_country_indexer` answer_index'e ek metod (takım id + country code çiftleri)
- **Acceptance Criteria Addressed**: AC-P11
- **Test Requirements**:
  - `rule` TR-10.1: BFS 100 çiftten 95 tanesi geçerli zincir. **Evidence**: Unit test.
  - `rule` TR-10.2: Club × Country en az 50 takım-ülke çifti ≥1 oyuncu döndürür. **Evidence**: Isar test.
- **Completion Evidence**:

## Task 11: Party Modları (V3 — Survival, Imposter, Bomb, Charades) Stubs + Firestore Real-Time
- **Status**: `pending`
- **Priority**: medium
- **Depends On**: Task 8 (rooms)
- **Description**:
  - 4 mod için sadece sayfa stub (V3 badge + Yakında)
  - `lib/services/realtime/` Firestore realtime listener abstraction yaz: `RoomSubscription` (players ready, turn, skorboard güncelleme stream)
  - Survival can mantığı model: `PlayerLivesState`
  - Imposter dağıtım algoritması: N-1 ortak oyuncu, 1 farklı
- **Acceptance Criteria Addressed**: AC-P12, AC-P13, AC-P14
- **Test Requirements**:
  - `rule` TR-11.1: Firestore rooms status change listener 5 oyuncu 10 tur stream akışı doğrular. **Evidence**: test fakeFirestore
  - `rule` TR-11.2: Imposter dağılımı 6 kişide 1 impostor, 10 kişide 2 impostor. **Evidence**: test
- **Completion Evidence**:

## Task 12: Son Entegrasyon + Lint + Test + Analyze 0 Issue + tasks.md Evidence Tamamla
- **Status**: `pending`
- **Priority**: high
- **Depends On**: Task 0-11
- **Description**:
  - `flutter analyze` → 0 issue
  - `dart run build_runner build` → 0 output error
  - V1 5 mod için her mod 1 widget test (generateQuestion + submitAnswer ile skor değişikliği)
  - Provider overrides test — her mod için ProviderScope container.read engine impl doğru
  - ARB'lerde eksik yeni key 6 dilde doldurulduğunu doğrula (grep)
  - Tüm tasklarda Completion Evidence alanlarını doldur
- **Acceptance Criteria Addressed**: TÜM AC'ler
- **Test Requirements**:
  - `rule` TR-12.1: `flutter analyze` no issues. **Evidence**: Komut çıktısı
  - `rule` TR-12.2: V1 5 mod widget testleri 5/5 PASS. **Evidence**: `flutter test` exit 0
  - `rule` TR-12.3: Yeni 60+ l10n key 6 ARB'de mevcut, boş string YOK. **Evidence**: grep 6 dosya × key
- **Completion Evidence**:
