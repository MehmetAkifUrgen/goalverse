# Football Tic Tac Toe - Product Requirements Document (Architecture Revamp)

## Overview
- **Summary**: 50.000+ futbolcu verisini Firestore oyun-sorgusu yerine yerel (Isar/JSON/SQLite) veritabanında tutan; Firebase'i yalnızca Auth, Multiplayer, Leaderboard, Profile ve Daily Challenge için kullanan 6 dilli Flutter mobil oyununun mimari yeniden tasarımı.
- **Purpose**: Firestore okuma maliyetlerini ciddi ölçüde düşürmek, oyun sırasında futbolcu arama ve cevap doğrulama performansını artırmak (hedef <100ms), ve 6 dil çeviri yükünü sadece UI seviyesine çekmek.
- **Target Users**: Mobil oyuncular (Android/iOS), Tek kişilik ve multiplayer mod kullanıcıları, 6 dilde (en/es/fr/de/tr/it) uygulama deneyimi yaşayanlar.

## Goals
- 50.000 futbolcu verisini oyun sırasında yerel DB'den sorgulayarak <100ms arama ve <100ms cevap doğrulama performansı sağlamak
- Firestore'u yalnızca Auth, Multiplayer, Leaderboard, Profile, Daily Challenge, Cloud Functions ile sınırlandırmak; futbolcu/team/player_team_history collection'larını Firestore'dan kaldırmak
- Çeviri sistemini futbolcu/takım isimleri dışında tutmak; sadece menü, buton, hata, başarım, açıklama gibi UI metinlerini 6 dile çevirmek
- Python veri hazırlama hattı ile ham veriden JSON/SQLite çıkışı üretip Flutter varlığı olarak paketlenmesini sağlamak
- Repository pattern ile veri katmanını soyutlayarak LocalPlayerRepository öncelikli, cache-first mimari kurmak

## Non-Goals
- Futbolcu veya takım isimlerini 6 dile çevirmek (Cristiano Ronaldo her dilde aynı kalacak)
- Firestore'da 50.000 futbolcu dokümanı tutmak ve oyun sırasında sorgulamak
- Supabase veya Firebase dışı bir backend kullanmak
- Oyun sırasında offline olmayan (multiplayer) senaryoda network bağımsızlığı sunmak

## Background & Context
Özgün spec (FOOTBALL T...txt, 1373 satır):
- Firestore'da players, teams, player_team_history, answer_index collection'ları tutuluyordu ve oyun sırasında submitAnswer CF üzerinden Firestore sorguları ile doğrulama yapılıyordu
- 50.000 futbolcu ölçeğinde bu yaklaşım hem okuma maliyeti (20K free/day sonrası $0.06/100K) hem de network round-trip gecikmesi açısından ölçeklenmiyor
- 6 dil çevirisi kuralı tüm veri katmanına uygulanıyordu ancak futbolcu isimleri Latin asıllı olduğundan çeviri ihtiyacı yok ve hataya açık

Yeni kararlar (kullanıcının mimari revizyonu):
1. Veri hazırlama: GitHub/Açık veri → Python → temizleme → JSON/SQLite
2. Mobil uygulama: JSON/SQLite/Isar → hızlı oyuncu arama + cevap kontrolü
3. Firebase: Auth + Multiplayer + Leaderboard + Profile + Daily Challenge + Cloud Functions
4. Futbolcu/takım isimleri 6 dile çevrilmeyecek; sadece arayüz, hata mesajları, menüler, achievement'lar ve açıklamalar çevrilecek

## Functional Requirements
- **FR-1**: Python veri hazırlama hattı (data_pipeline/) futbolcu, takım, kariyer geçmişi, team_player, answer_index verilerini ham kaynaktan indirip normalize, deduplicate, validate edip JSON ve SQLite formatlarında çıktı üretebilmeli
- **FR-2**: Flutter uygulaması ilk açılışta asset içindeki football_dataset.json veya players.db dosyasını Isar veritabanına yükleyebilmeli (initDb metodu) ve versiyon kontrolü yapmalı
- **FR-3**: Oyuncu arama (autocomplete) Isar üzerinde normalizedName alanında full-text veya prefix sorgusu yapmalı ve 50.000 kayıtta <100ms sonuç dönmeli
- **FR-4**: Cevap doğrulama (bir oyuncu row_team + col_team ikilisinde oynamış mı?) yerel Isar answer_index tablosu üzerinden yapılmalı, oyuncular ısrarla aynı turnuva için tekrar Firestore'a istek atmamalı
- **FR-5**: Multiplayer submitAnswer akışında Cloud Function hala anti-cheat ve authoritative doğrulama yapmalı, ancak bu doğrulama CF kendi içindeki yerel/sabit answer_index (aynı dataset) üzerinden yapmalı; her doğrulama için players/team_history Firestore sorgusu ATILMAMALI
- **FR-6**: Firestore koleksiyon yapısı şunlarla sınırlı olmalı: users, games, game_players, leaderboards, daily_challenges; players, teams, player_team_history, teams koleksiyonları FIRESTORE'DA OLMAMALI
- **FR-7**: Localization sistemi (ARB) 6 dilde (en/es/fr/de/tr/it) sadece UI key'lerini içermeli; futbolcu/takım adı hiçbir ARB dosyasında yer almamalı
- **FR-8**: Board generator (rastgele 3x3 takım grid'i) yerel answer_index üzerinden minimum N geçerli oyuncu kontrolünü yapmalı ve çözülemez hücre üretmemeli
- **FR-9**: Repository soyutlaması şunu garanti etmeli: PlayerRepository ve TeamRepository öncelikle Isar/Local impl döner, remote Firebase impl'i veri katmanında players/teams için kullanılmaz

## Non-Functional Requirements
- **NFR-1**: Oyuncu arama (50K kayıt): P95 < 100ms
- **NFR-2**: Answer validation (yerel): P95 < 100ms
- **NFR-3**: Board generation (3x3 grid, min 3 valid oyuncu/hücre): < 200ms
- **NFR-4**: Multiplayer submitAnswer round-trip (CF çağrısı + Firestore realtime update): yalniz network latency'si kadar olmalı, ekstra Firestore players sorgusu eklenmemeli
- **NFR-5**: App ilk kurulum veri yükleme (Isar init): < 2 saniye (50K oyuncu kaydı)
- **NFR-6**: Isar dataset asset boyutu (sıkıştırılmamış JSON): < 15 MB; SQLite: < 10 MB

## Constraints
- **Teknik**: Flutter, Dart, Riverpod, Isar tercih (Hive değil), Firebase (Auth, Firestore, CF, Analytics, Crashlytics, Remote Config, App Check), Cloud Functions Node.js/TypeScript veya Python, veri hattı Python 3.11+, SQLite
- **İş**: Backend olarak Supabase KULLANILMAYACAK; Firebase zorunlu; production kodunda placeholder/dummy futbolcu verisi YOK
- **Bağımlılıklar**: Açık futbolcu veri kaynağı (ör: Transfermarkt açık veri, football-data.co.uk, Kaggle FBref, GitHub'daki topluluk datasetleri — lisans kontrolü şart)

## Assumptions
- Uygulama paketleme anında football_dataset.json veya players.db Flutter asset olarak dahil edilir (build-time bundle). Runtime güncelleme ilk MVP'de zorunlu değil, sonradan Remote Config + asset delta patch eklenebilir
- Cloud Functions aynı dataset'i kendi storage'ında (ör: source JSON yüklenmiş) taşır ve doğrulamayı local olarak yapar (players/team_history için Firestore sorgusu atılmaz)
- Oyuncu isimleri Latin karakterlidir; Türkçe'de İ/I, İspanyolca Ñ gibi karakter normalizasyonu Python hattında ve Isar normalizedName'de tutarlı şekilde yapılır

## Acceptance Criteria

### AC-1: Firestore'da futbolcu/takım koleksiyonu yok kuralı
- **Type**: `rule`
- **Given**: Kurulum tamamlanmış ve firestore.rules + Firebase deploy edilmiş ortam
- **When**: Firestore console'da koleksiyon listesi açılır ya da `firebase firestore:list-collections` çalıştırılır
- **Then**: players, teams, player_team_history, answer_index isimli koleksiyonlar listede görünmemeli; sadece users, games, game_players, leaderboards, daily_challenges görünmeli
- **Pass Condition**: 4 yasaklı koleksiyondan hiçbirinin doküman sayısı > 0 OLMAMALI, izin verilen 5 koleksiyon mevcut olmalı
- **Evidence**: Firestore rules dosyasının içeriği, `firebase firestore:list-collections` çıktısı, spec ile karşılaştırma

### AC-2: Oyuncu arama yerel DB (Isar) ve <100ms hedefi
- **Type**: `rubric`
- **Dimension**: 50K futbolcu kaydı üzerinde yerel arama performansı ve veri kaynağı doğruluğu
- **Scale**: 1-5
  - 1 = Arama Firestore üzerinden yapılıyor veya > 500ms
  - 3 = Arama Isar'dan yapılıyor ama P95 200-500ms arasında veya dataset sadece 10K
  - 5 = Arama Isar normalizedName üzerinden yapılıyor, 50K kayıt var, P95 ölçümü < 100ms ve Firestore çağrısı hiç yapılmıyor (network log ile kanıtlanabilir)
- **Pass Threshold**: >= 4
- **Evidence**: Flutter devtools timeline ölçümü, Isar query açıklaması, paket network profili (no Firestore players çağrısı)

### AC-3: Cevap doğrulaması yerel + CF authoritative (ikisi de Firestore players sorgusu YOK)
- **Type**: `rule`
- **Given**: Aktif multiplayer oyun ve submitAnswer çağrısı
- **When**: Oyuncu bir hücreye futbolcu seçip submit eder; hem Flutter app hem de Cloud Function tarafında cevap doğrulaması tetiklenir
- **Then**: (1) Flutter Doğrulama: Isar answer_index kullanılır, `players` veya `player_team_history` için Firestore get/sorgusu YOK; (2) CF Doğrulama: CF kendi asset/dataset JSON/SQLite'ından bakar, Firestore'dan oyuncu/takım dokümanı OKUMAZ; (3) CF hala authoritative sonuç döner ve score/turn güncellemesini transaction yapar
- **Pass Condition**: Uygulama network logunda oyun esnasında players/team_id ile Firestore sorgusu görünmemeli; CF source kodunda `db.collection('players')` veya `db.collection('player_team_history')` .get çağrısı YOK
- **Evidence**: Flutter network profili (Charles/devtools), Cloud Function submitAnswer source kodu incelemesi

### AC-4: Python veri hattı JSON + SQLite çıktısı üretir
- **Type**: `rule`
- **Given**: data_pipeline/ Python projesi ve requirements kurulu
- **When**: `python main.py --all --out-dir output/` çalıştırılır
- **Then**: output/ altında şu dosyalar oluşmalı ve geçerli şema doğrulanmalı: players.json, teams.json, player_team_history.json, answer_index.json, players.db (SQLite tabloları: players, teams, player_team_history, answer_index); her dosya 0 satır YOK (en az 100 futbolcu geliştirme fixture'ı ile test; production 50K hedef)
- **Pass Condition**: 5 dosya mevcut, şema JSON schema veya SQLite PRAGMA ile doğrulandı, players.json en az 100 kayıt, answer_index takım|takım key formatında en az 10 hücre
- **Evidence**: `ls -la output/`, `python -m pytest tests/` komutu, JSON dosyasının `jq '. | length'` ile sayımı, SQLite `.tables` ve `SELECT COUNT(*) FROM players` çıktısı

### AC-5: Localization sadece UI için — futbolcu/takım ismi ARB'de yok
- **Type**: `rule`
- **Given**: lib/l10n/ altındaki 6 adet ARB dosyası (app_en.arb, app_es.arb, app_fr.arb, app_de.arb, app_tr.arb, app_it.arb)
- **When**: ARB dosyaları içerisinde futbolcu veya takım isimleri (ör: "Cristiano Ronaldo", "Real Madrid", "Barcelona", "Juventus", "Arsenal", "Liverpool", "Galatasaray", "Messi", "Pele", "Maradona", "Neymar", "Mbappe") aranır
- **Then**: Hiçbir futbolcu veya takım ismi ARB dosyasının key veya value kısmında geçmemeli; yalnızca UI key'leri (startGame, won, lost, draw, settings, profile, achievements, leaderboard, errorPlayerNotFound vb.) bulunmalı
- **Pass Condition**: 10 anahtar isim aramasının tamamı 0 sonuç dönmeli; localization kullanımı widgetlarda Text("Cristiano Ronaldo") şeklinde hard-coded OLMAMALI, oyuncu isimleri data'dan gelmeli
- **Evidence**: `grep -ri "cristiano\|real madrid\|barcelona\|messi" lib/l10n/` çıktısı (boş olmalı); widget ağacında random oyuncu adı hard-coded araması

### AC-6: Board generator minimum valid oyuncu kuralı (yerel answer_index)
- **Type**: `rule`
- **Given**: 50K oyuncu + answer_index yüklenmiş Isar ve BoardGenerator sınıfı
- **When**: `BoardGenerator.generate(difficulty: Easy, minValidPlayersPerCell: 3)` çağrılır ve N=100 board üretilir
- **Then**: Üretilen 100 board'un 100%'ünde her hücrenin (row_team, col_team) ikilisi için answer_index'te en az 3 oyuncu listelenmeli; tek bir hücre bile 0 oyuncu içeremez
- **Pass Condition**: 100 board * 9 hücre = 900 hücrenin tamamında minValidPlayers >= 3
- **Evidence**: Unit test `board_generator_test.dart` 100 iterasyon çalıştırma çıktısı ve tüm hücre doğrulama sayımı

### AC-7: Repository pattern — PlayerRepository öncelikli yerel
- **Type**: `rubric`
- **Dimension**: Veri katmanı soyutlama ve yerel/remote önceliği
- **Scale**: 1-5
  - 1 = PlayerRepository doğrudan Firestore çağırıyor, soyutlama yok
  - 3 = Soyut interface var ama FirebasePlayerRepository implementasyonu varsayılan
  - 5 = `abstract class PlayerRepository` + `IsarPlayerRepository extends PlayerRepository` varsayılan wire; FirebasePlayerRepository players/teams için VAR YOK veya hiçbir yerde çağrılmıyor; Riverpod provider `playerRepositoryProvider` Isar impl döner
- **Pass Threshold**: >= 4
- **Evidence**: lib/data/repositories/ dizini yapısı, Riverpod provider binding'i, arama ve doğrulama metodlarının çağrı yığını

### AC-8: Cloud Functions minimal Firestore kullanımı (sadece users/games/game_players/leaderboards/daily_challenges)
- **Type**: `rule`
- **Given**: functions/src/ altındaki tüm CF source kodları
- **When**: Kod tabanında Firestore koleksiyon isimleri (players, teams, player_team_history, answer_index) aranır
- **Then**: Bu 4 koleksiyondan hiçbiri CF kodlarında okunmaz veya yazılmaz; sadece 5 izin verilen koleksiyon (users, games, game_players, leaderboards, daily_challenges) işlenir
- **Pass Condition**: 4 yasaklı koleksiyon ismi için `db.collection('...')` 0 eşleşme
- **Evidence**: `grep -rn "collection.*players\|collection.*teams\|collection.*player_team_history\|collection.*answer_index" functions/` çıktısı (0 sonuç)

## Open Questions
- [ ] Cloud Functions dataset'i kendi storage'ında nasıl taşıyacak? (Seçenek A: functions/data/ altına JSON dosyasını kopyala + deploy; Seçenek B: CF başlangıçta Storage'dan indirip memory-cache; İlk MVP için Seçenek A)
- [ ] Flutter asset olarak JSON mı SQLite mı tercih edilecek? (Öncelik: JSON asset → Isar init; SQLite alternatif fallback)
- [ ] Dataset versiyonlama ve runtime güncelleme mekanizması MVP kapsamında mı? (Ön varsayım: HAYIR, build-time bundle; 2. fazda delta patch)
