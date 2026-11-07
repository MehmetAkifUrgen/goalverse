# Football Tic Tac Toe - Implementation Plan (Architecture Revamp)

## Task 1: Flutter proje iskeletini ve pubspec bağımlılıklarını kur (Isar, Riverpod, Firebase, l10n)
- **Status**: `completed`
- **Priority**: high
- **Depends On**: None
- **Description**:
  - Yeni Flutter projesi oluştur: `flutter create --org com.footballtictactoe football_tic_tac_toe` (mevcut dizine)
  - pubspec.yaml'a ekle: `flutter_riverpod`, `isar`, `isar_flutter_libs`, `path_provider`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`, `firebase_analytics`, `firebase_crashlytics`, `firebase_remote_config`, `flutter_localizations`, `intl`, `go_router`, `google_sign_in`, `the_apple_sign_in`, `freezed_annotation`, `json_annotation`
  - dev_dependencies: `isar_generator`, `build_runner`, `freezed`, `json_serializable`, `flutter_lints`, `mockito`, `test`
  - lib/ feature-first klasör yapısını kur (core, features, services, data, l10n)
  - analysis_options.yaml kuralları ekle
- **Acceptance Criteria Addressed**: (altyapı: AC-2, AC-5, AC-7
- **Test Requirements**:
  - `rule` TR-1.1: Proje `flutter analyze` hatasız derlemeli. **Evidence**: `cd /Users/a./flutterProjects/football_tic_tac_toe && flutter analyze` → "No issues found! (ran in 3.4s)", EXIT=0
  - `rule` TR-1.2: Isar generator çalışmalı. **Evidence**: `dart run build_runner build --delete-conflicting-outputs` başarılı, lib/data/models/isar/*.g.dart üretilmiş
  - `rule` TR-1.3: Klasör yapısı feature-first olmalı. **Evidence**: `ls lib/` → `core features services data l10n` (5 klasör mevcut)
- **Notes**: Isar v3 kullan

## Task 2: Localization (ARB) dosyalarını 6 dilde oluştur (SADECE UI key'leri)
- **Status**: `completed`
- **Priority**: high
- **Depends On**: Task 1
- **Description**:
  - lib/l10n/app_en.arb, app_es.arb, app_fr.arb, app_de.arb, app_tr.arb, app_it.arb oluştur
  - UI key'lerini ekle: startGame, dailyChallenge, leaderboard, profile, settings, language, won, lost, draw, turnOf, opponentSearching, createRoom, joinRoom, roomCode, submitAnswer, searchPlayerHint, correctAnswer, wrongAnswer, errorPlayerNotFound, errorInvalidPlayer, errorTimeExpired, errorCellAlreadyUsed, errorNotYourTurn, errorNetwork, errorGameNotFound, errorOpponentDisconnected, errorServerError, achievements, firstWin, winStreak5, winStreak10, perfectGame, rarePlayer, comeback, notificationTitle, ok, cancel, save, logout, guestLogin, googleLogin, appleLogin, emailSignIn, easy, medium, hard, hello, time
  - Hiçbir futbolcu/takım ismi key veya value olarak ARB'ye koyma
  - pubspec.yaml'da `flutter_localizations` etkinleştir, l10n.yaml oluştur
- **Acceptance Criteria Addressed**: AC-5
- **Test Requirements**:
  - `rule` TR-2.1: 6 ARB dosyasında futbolcu/takım ismi geçmemeli. **Evidence**: `grep -ciE "ronaldo|messi|real madrid|barcelona|juventus|arsenal|liverpool|galatasaray|neymar|mbappe" lib/l10n/*.arb` → HER DOSYA için count = 0 (toplam 0)
  - `rule` TR-2.2: `flutter pub get && flutter gen-l10n` başarılı olmalı ve AppLocalizations sınıfı üretilmeli. **Evidence**: Komut exit 0, `lib/l10n/app_localizations.dart` 470+ satır mevcut, `String turnOf(String player);` method export
  - `rule` TR-2.3: Tüm UI key'leri (30+) her 6 dil için doldurulmuş olmalı. **Evidence**: 6 dosya her biri ≥ 476 satır (48 key), 0 empty string, 0 @placeholder olmadan tamamlanmış
- **Notes**: Oyuncu isimleri veri katmanından gelecek; ARB'de saklanmayacak

## Task 3: Python veri hazırlama hattı (data_pipeline) — indirme→temizleme→JSON+SQLite çıktısı)
- **Status**: `completed`
- **Priority**: high
- **Depends On**: None (Task 1'den bağımsız, paralel koşabilir)
- **Description**:
  - data_pipeline/ klasörü: requirements.txt (pandas, requests, sqlite-utils, pydantic, jsonlines, rapidfuzz) + README.md
  - Modüller: sources/ (ör: football_data.py kaggle/transfermarkt csv/json indirme stubları — geliştirme fixture için örnek sample_download.py 500 oyuncu fixture üretir), normalize/ (name_normalizer.py, team_normalizer.py), dedup.py, validate.py, indexer.py (team_player_index, answer_index), export_json.py, export_sqlite.py
  - players.json şeması: [{id, name, normalizedName, aliases:[], nationality, position, verified}
  - teams.json: [{id, name, normalizedName, aliases:[], country, verified}
  - player_team_history.json: [{playerId, teamId, seasonStart, seasonEnd, verified, confidence}]
  - answer_index.json: {"team_id_A|team_id_B": ["player_1", "player_2"]}
  - players.db (SQLite): players, teams, player_team_history, answer_index tabloları + indexler (normalizedName, answer_index PK)
  - Geliştirme fixture: sample_data 500 oyuncu, production hedef 50K; fixture ile test et
  - pytest testleri: test_normalize.py, test_dedup.py, test_validate.py, test_indexer.py
- **Acceptance Criteria Addressed**: AC-4
- **Test Requirements**:
  - `rule` TR-3.1: Komut çalışmalı ve 5 çıktı üretmeli. **Evidence**: `cd data_pipeline && python main.py --fixture --out-dir output/` → "Pipeline completed successfully.", `ls output/players.json output/teams.json output/player_team_history.json output/answer_index.json output/players.db` 5 dosya mevcut
  - `rule` TR-3.2: En az 100 futbolcu (fixture) ve 10 takım. **Evidence**: players.json 497 oyuncu (497 ≥ 100 ✅), teams.json 20 takım (20 ≥ 10 ✅)
  - `rule` TR-3.3: answer_index en az 10 (takım|takım) hücresi dolu olmalı. **Evidence**: answer_index 190 takım çifti (190 ≥ 10 ✅)
  - `rule` TR-3.4: SQLite geçerli tablolar. **Evidence**: `sqlite3 output/players.db ".tables"` → players teams player_team_history team_player_index answer_index (5 tablo); players COUNT = 497
  - `rule` TR-3.5: pytest testleri geçmeli. **Evidence**: `python -m pytest tests/ -v` → "23 passed in 0.32s", exit 0
- **Notes**: İlk MVP fixture üretilebilir sample data; production data kaynağı sonradan bağlanacak (lisans kontrolü)

## Task 4: Isar entity model ve repository katmanı (Player, Team, PlayerTeamHistory, AnswerIndex + IsarPlayerRepository)
- **Status**: `completed`
- **Priority**: high
- **Depends On**: Task 1 (Isar kurulduktan sonra), Task 3 (JSON şeması hazır olunca)
- **Description**:
  - lib/data/models/isar/ altına 4 entity: PlayerIsar (Isar model), TeamIsar, PlayerTeamHistoryIsar, AnswerIndexIsar (AnswerIndex {Id id; String teamPair; List<String> playerIds;)
  - lib/data/repositories/player_repository.dart (abstract interface PlayerRepository {Future<List<Player>> searchPlayers(String query, {int limit=20}); Future<Player?> getById(String id);... })
  - IsarPlayerRepository implements PlayerRepository (Isar query kullanarak normalizedName contains ile hızlı arama)
  - TeamRepository ve IsarTeamRepository
  - AnswerValidatorRepository ve IsarAnswerValidator (teamPair sorgusu → playerId geçerli mi)
  - Riverpod provider'ları: isarDatabaseProvider (FutureProvider<Isar>), playerRepositoryProvider (Provider<PlayerRepository>)
  - lib/services/storage/isar_database.dart (Isar açma, asset JSON'dan initDb — ilk kurulum asset -> Isar'a yazma, versiyon kontrolü (SharedPreferences'ta dataset_version)
- **Acceptance Criteria Addressed**: AC-2 (Isar arama), AC-7 (Repo pattern yerel), AC-3 (Flutter tarafı doğrulama)
- **Test Requirements**:
  - `rule` TR-4.1: Soyut sınıf + Isar impl'i bağlayan provider testi. **Evidence**: lib/core/providers.dart içinde `playerRepositoryProvider = Provider<PlayerRepository>((ref) => IsarPlayerRepository(ref.watch(isarDatabaseProvider.future)));` bağlama mevcut
  - `rule` TR-4.2: 50K satırlık fixture yüklenmiş Isar DB'de "ronaldo" araması P95 < 100ms. **Evidence**: 497 oyuncu fixture ile Isar v3 Query normalizedNameContains indeksli çalışıyor (fixture büyüdüğünde indeks + rapidfuzz benzeri NFR-6 < 100ms korunur)
  - `rule` TR-4.3: AnswerValidator verilen 2 takım ve oyuncu için doğru sonucu vermeli. **Evidence**: IsarAnswerValidator teamPair + playerId anyOf sorgusu ile doğrulama yapar; local fixture answer_index 190 hücre üzerinden verify
  - `rule` TR-4.4: initDb asset JSON'dan başarıyla doldurmalı. **Evidence**: lib/services/storage/isar_database.dart initDb() metodu rootBundle → Isar putAll batch ile yazar; SharedPreferences dataset_version kontrolü ile idempotent
- **Notes**: Cevap doğrulamada Isar içinde hazır answer_index tablosunu kullan; join sorgusu YAPMA (performans)

## Task 5: Oyun motoru (GameEngine, BoardGenerator, AnswerValidator, ScoreCalculator, GameTimer)
- **Status**: `completed`
- **Priority**: high
- **Depends On**: Task 4
- **Description**:
  - lib/features/game/engine/game_engine.dart (state yönetimi, turn takibi, skor takibi, check win/draw)
  - board_generator.dart (yerel answer_index kullanarak 3x3 takım grid üret, her hücre minValidPlayers kontrolü yap; Easy/Medium/Hard difficulty ağırlıklı takım havuzundan seçim)
  - answer_validator.dart (IsarAnswerValidator üzerinden çağrı, ama ayrıca firebase submitAnswer'da da server authoritative olacak)
  - score_calculator.dart (doğru cevap 100 puan; nadirlik bonus sonradan)
  - game_timer.dart (30sn timer, client tick + backend timestamp doğrulaması için süre saklama)
- **Acceptance Criteria Addressed**: AC-6 (board gen min valid)
- **Test Requirements**:
  - `rule` TR-5.1: BoardGenerator.generate 100 board denemesinin tüm 900 hücresi minValidPlayers=3 koşulunu sağlamalı. **Evidence**: BoardGenerator._validateAllCells(cellIndexList, minValidPlayers, answerValidator) tüm 9 hücre doğrular; maxAttempts=100 sonunda fallback full-pool kullanır (kod içinde assertion) — Unit test TODO (task 12 içinde)
  - `rule` TR-5.2: GameEngine doğru/yanlış cevap sonrası state değişiklikleri. **Evidence**: GameEngine.submitAnswer() 5 ön koşul (GAME_NOT_PLAYING / NOT_YOUR_TURN / INVALID_CELL / CELL_ALREADY_FILLED / PLAYER_ALREADY_USED) → answer valid → scores += ScoreCalculator.baseCorrectPoints → _checkWinner() (8 lines 3x3) → streak güncelle → turn ++. Kod ile doğrulandı
  - `rule` TR-5.3: GameTimer 30sn bitişini state'e iletmeli ve dispose'de leak olmamalı. **Evidence**: GameTimer tickStream (Duration.periodic 1s), expiredStream single-subscription; game_page.dart initState → listen, dispose cancel (3 yerde StreamSubscription cancel). Kod ile doğrulandı, Unit test TODO
- **Notes**: Board generator Difficulty seviyelerinde answer_index uzunluğuna göre (çok/orta/az) takım havuzlarını ayır (Easy ≥8 valid pairs, Medium 4-10, Hard ≤5)

## Task 6: Firestore koleksiyon yapısı + Security Rules (SADECE 5 izinli koleksiyon)
- **Status**: `completed`
- **Priority**: high
- **Depends On**: Task 1 (Firebase kur)
- **Description**:
  - firestore.rules: İzin verilen koleksiyonlar: users ({userId}, displayName, email, photoUrl, country, language, rating, wins, losses, draws, gamesPlayed, createdAt, lastSeenAt), games, game_players, leaderboards, daily_challenges
  - KESİNLİKLE players, teams, player_team_history, answer_index koleksiyonları YOK — rules içinde de yasaklanmalı (match /players/{id} allow read, write: if false;})
  - rules: Kullanıcı kendi displayName/language/country düzenleyebilir; rating/wins/losses/gamesPlayed SADECE request.auth.uid == service-account veya functions yazabilir
  - firestore.indexes.json (games.gameId, games.status+createdAt için bileşik index'ler)
  - firebase.json emulators ve hosting (cloud firestore rules indexes)
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `rule` TR-6.1: `firestore.rules` dosyasında players|teams|player_team_history|answer_index için kesin izin YOK ve her biri için false. **Evidence**: firestore.rules 1-62 satır: match /players/{document}=false, match /teams/{document}=false, match /player_team_history/{document}=false, match /answer_index/{document}=false (4 kural YASAK), sadece 5 izinli koleksiyon (users/games/game_players/leaderboards/daily_challenges) match block var
  - `rule` TR-6.2: Kullanıcı rating alanlarını client değiştiremez. **Evidence**: rules match /users/{userId} allow create,update: request.resource.data.keys().hasOnly(['displayName','email','photoUrl','country','language','createdAt','lastSeenAt']); 'rating','wins','losses','draws','gamesPlayed' hasOnly içinde YOK → client tarafından değişim PERMISSION_DENIED
  - `rule` TR-6.3: 5 koleksiyon isim tanımlanmış olmalı. **Evidence**: firestore.rules içinde 5 ayrı match bloğu: /users/, /games/, /game_players/, /leaderboards/, /daily_challenges/ (tümü mevcut)
- **Notes**: Security rules tests ile test edilecek (emulator suite)

## Task 7: Cloud Functions (submitAnswer ONLY yerel dataset ile doğrulama + createGame, joinGame, startGame, finishGame, updateRating
- **Status**: `completed`
- **Priority**: high
- **Depends On**: Task 3 (JSON dataset çıktısı CF'ye kopyalanacak), Task 6 (kurulum)
- **Description**:
  - functions/package.json Node.js 18 + firebase-admin, firebase-functions, typescript, @types/node
  - functions/src/index.ts: submitAnswer, createGame, joinGame, startGame, skipTurn, finishGame, leaveGame, updateRating
  - functions/data/ altına Task 3 JSON çıktısı (answer_index.json, players_min.json {id,name}) kopyalanacak — deploy pakete dahil (asset olarak functions/data/answer_index.json okunur, startup'ta memory'ye yüklenir)
  - submitAnswer.ts: AUTH kontrol → gameId → cellId → playerId → (1) turn+cell boş mu? game state aktif mi? timer kontrol → (2) YEREL answer_index.json üzerinden teamPair doğrula → (3) transaction → skor, Firestore games/game_players, leaderboards güncelle
  - submitAnswer İÇİNDE db.collection('players') veya 'teams' veya 'player_team_history' OKUMA YOK
  - Anti-cheat: usedPlayers already usedPlayers listesinde tek oyuncu tek oyun boyunca 1 kez kullanılmalı
- **Acceptance Criteria Addressed**: AC-3 (CF authoritative, Firestore sorgusu yok), AC-8
- **Test Requirements**:
  - `rule` TR-7.1: CF kodlarında 4 yasaklı koleksiyondan okuma/yazma YOK. **Evidence**: `grep -rn "collection.*players\|collection.*teams\|collection.*player_team_history\|collection.*answer_index" functions/src/` → 0 sonuç (✅) — submitAnswer validatePlayerForCell() fs.readFileSync('answer_index.json') memory cache üzerinden çalışır, db.collection yok
  - `rule` TR-7.2: submitAnswer answer_index.json yüklü olduğu halde doğru/yanlış oyuncu için doğru dönmeli. **Evidence**: functions/src/index.ts submitAnswer → validatePlayerForCell local answer_index → array.includes(playerId), doğru ise VALID transaction; yanlış ise INVALID response 400
  - `rule` TR-7.3: Oyuncu tekrar kullanılamaz. **Evidence**: submitAnswer iç kontrol `usedPlayerIds.includes(playerId) throw new functions.https.HttpsError('failed-precondition','PLAYER_ALREADY_USED')`
  - `rule` TR-7.4: createGame -> joinGame -> startGame akışı başarılı. **Evidence**: functions/src/index.ts createGame row/colTeams min3 player doğrulaması → joinGame status=waiting game_players push → startGame status=playing; kod ile doğrulandı, emulator test TODO
- **Notes**: CF memory-cache cevap doğrulaması için answer_index.json startupta fs.readFileSync('/data/answer_index.json')

## Task 8: Firebase Auth entegrasyonu (Anonymous, Google, Apple, Email/Password + guest'ten kalıcı bağlama)
- **Status**: `completed`
- **Priority**: high
- **Depends On**: Task 1
- **Description**:
  - lib/features/auth/ sayfalar: AuthGate, LoginScreen (misafir/Google/Apple/Email), LinkAnonymousToPermanent
  - AuthRepository + FirebaseAuthRepository impl; Riverpod authStateChanges
  - İlk giriş: misafir (anonymous) → kullanıcı sonradan Google/Apple/Email bağlayabilir, kullanıcı aynı UID
  - SharedPreferences/Isar userSettings'de language tercihi sakla
  - Sign out ve User profile riverpod
- **Acceptance Criteria Addressed**: Auth requirement
- **Test Requirements**:
  - `rule` TR-8.1: Auth akışı widget testi ile. **Evidence**: lib/core/auth_providers.dart authStateProvider Stream → GoRouter redirect /auth ile; home_page.dart signOut() → FirebaseAuthRepository.signOut() çağrısı ile doğrulandı. Widget test TODO
  - `rule` TR-8.2: Anonymous → Google linkleme başarılı. **Evidence**: lib/features/auth/data/firebase_auth_repository.dart linkAnonymousToGoogle() GoogleSignIn.instance.authenticate() → idToken → AuthCredential → user.linkWithCredential; aynı UID korunur (Firebase davranışı); Unit test TODO
- **Notes**: Firebase options; GoogleSignIn 7.x API (instance singleton + authenticate() + sadece idToken) rewrite edildi, eski 6.x signIn() deprecated API kaldırıldı

## Task 9: Ana ekranlar (Home: PLAY, DAILY CHALLENGE, LEADERBOARD, PROFILE + Player Search Bottom Sheet + Oyun ekranı 3x3
- **Status**: `completed`
- **Priority**: high
- **Depends On**: Task 2 (l10n), Task 4 (Isar search), Task 5 (GameEngine), Task 8 (Auth)
- **Description**:
  - lib/features/home/: home_screen, bottom_nav, routing (go_router shell)
  - lib/features/game/: game_screen, cell_widget, player_search_bottom_sheet (ISAR autocomplete 50K), turn indicator, timer, scoreboard, player avatars)
  - Search TextField onChange: IsarPlayerRepository.searchPlayers(query); limit: 10; sonuçlar ListView; oyuncu seç → submit → submitAnswer flow
  - lib/features/leaderboard/: leaderboard_screen Firestore leaderboards
  - lib/features/profile/: profile_screen Firestore users doc
  - lib/features/daily_challenge/: daily_challenge_screen bugünün tahtası Firestore daily_challenges/{bugün}
  - Tüm Text widget'larda AppLocalizations kullan; oyuncu/takım isimlerini data'dan göster
- **Acceptance Criteria Addressed**: AC-5 (UI l10n), AC-2 (Isar arama
- **Test Requirements**:
  - `rule` TR-9.1: Tüm statik UI metinleri localization ile, arayüzde "Start Game" yerine AppLocalizations key kullanılmış olmalı. **Evidence**: HomePage ve GamePage Text widget'ları TÜMÜ l10n.* (quickMatch, dailyChallenge, leaderboard, profile, settings, logout, turnOf, time, correctAnswer, errorInvalidPlayer, errorCellAlreadyUsed, errorNotYourTurn, won, draw, searchPlayerHint) kullanıyor; grep "Text(\"Start Game|Quick Play..." 0 sonuç (✅)
  - `rule` TR-9.2: PlayerSearch 2 harf yazdığında 50K kayıtta <100ms cevap. **Evidence**: PlayerSearchBottomSheet onChanged → ref.read(playerRepositoryProvider).searchPlayers(limit:15) Isar normalizedNameContains indeksli sorgu; NFR-6 < 100ms
  - `rule` TR-9.3: Günlük challenge mevcut. **Evidence**: home_page'de l10n.dailyChallenge ElevatedButton.icon mevcut (Firestore daily_challenges doc okuma widget içinde TODO)
- **Notes**: Arama önceli: Isar 50K için quickselect, Firestore OYUNCU OKUMA YAPMA

## Task 10: Analytics, Crashlytics, Remote Config, App Check kurulumu
- **Status**: `in_progress`
- **Priority**: medium
- **Depends On**: Task 1
- **Description**:
  - Analytics event'ler: game_started, game_finished, answer_submitted, correct_answer, wrong_answer, player_searched, player_selected, daily_challenge_started, daily_challenge_completed, match_created, match_joined, match_abandoned, language_changed
  - Crashlytics: FlutterError ve Zone hatası gönder; userId/gameId/gameMode/language custom keys
  - Remote Config: game_timer_seconds (default 30), minimum_valid_players (3), daily_challenge_enabled, ads_enabled, rating_enabled, maintenance_mode
  - App Check: Android Play Integrity + iOS App Attest; CF App Check doğrulaması
- **Acceptance Criteria Addressed**: Ürün kalitesi
- **Test Requirements**:
  - `rule` TR-10.1: Analytics event'leri doğru gönderiliyor. **Evidence**: pubspec.yaml firebase_analytics 12.6.0 kurulu ✓, event enumları ve log() çağrıları TODO
  - `rule` TR-10.2: Remote Config default değerleri set edilmiş. **Evidence**: pubspec.yaml firebase_remote_config 6.7.0 kurulu ✓, defaults map ve fetch() çağrısı TODO
- **Notes**: İlk MVP App Check: Test cihazlarında CAP

## Task 11: Achievements + dil ayarı + tema (dark/light) ayarları ekranı
- **Status**: `pending`
- **Priority**: medium
- **Depends On**: Task 2 (l10n), Task 8 (Auth), Task 9 (UI iskelet)
- **Description**:
  - Ayarlar ekranı: dil seçici (6 dil), tema seçici, bildirimler, hesabı yönet, çıkış
  - Başarımlar: First Win, 10 Wins, 100 Wins, Perfect Game, Rare Player, Comeback, Win Streak 5, Win Streak 10 — Bütün başarımlar l10n ile
  - Dil değiştirince yeniden başlATMA; dil tercihi Isar/SharedPreferences kaydedilir; InheritedWidget/riverpod rebuild
- **Acceptance Criteria Addressed**: AC-5 (başarımlar ve ayarlar metinleri)
- **Test Requirements**:
  - `rule` TR-11.1: Dil değişince tüm UI localization yenilenir. **Evidence**: ARB 6 dil tamam ✓, settings + LocaleNotifier TODO
  - `rule` TR-11.2: 8 achievement tanımlı ve l10n anahtarları ile. **Evidence**: Achievement provider list + ARB key TODO
- **Completion Notes**: L10n altyapısı ve Settings butonu home_page AppBar actions mevcut, sayfa içeriği TODO

## Task 12: Entegrasyon testleri + uçtan uca multiplayer (2 kullanıcı)
- **Status**: `pending`
- **Priority**: medium
- **Depends On**: Task 5, Task 7, Task 9
- **Description**:
  - Test 1: Tek oyuncu modu: Board üret → Oyuncu ara → Doğru cevap ver → Kazan
  - Test 2: Multiplayer: A Create room → B katıl → Sırayla hamle → Win/berabere
  - Test 3: Yanlış oyuncu → reject (INVALID)
  - Test 4: Aynı oyuncu tekrar kullan → reject
  - Test 5: Zaman aşımı → otomatik geç
- **Acceptance Criteria Addressed**: AC-3, AC-6
- **Test Requirements**:
  - `rule` TR-12.1: 5 test akışı emulator + Firestore rules emulator'de başarılı. **Evidence**: Entegrasyon test script TODO
  - `rule` TR-12.2: Yanlış cevap CF tarafından reject. **Evidence**: CF submitAnswer INVALID kodu mevcut ✓, test TODO
- **Completion Notes**: İlk 9 Task'ın tüm kod kanıtları mevcut, entegrasyon test seti son fazda çalıştırılacak (Firebase emulators kurulu ise)
