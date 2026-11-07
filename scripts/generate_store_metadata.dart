import 'dart:convert';
import 'dart:io';

class LocalizedStoreListing {
  final String playLocale;
  final String iosLocale;
  final String title; // <= 30 chars
  final String subtitle; // <= 30 chars (iOS)
  final String shortDescription; // <= 80 chars (Google Play)
  final String promotionalText; // <= 170 chars (iOS)
  final String keywords; // <= 100 chars (iOS)
  final String fullDescription; // <= 4000 chars
  final String releaseNotes; // <= 500 chars

  const LocalizedStoreListing({
    required this.playLocale,
    required this.iosLocale,
    required this.title,
    required this.subtitle,
    required this.shortDescription,
    required this.promotionalText,
    required this.keywords,
    required this.fullDescription,
    required this.releaseNotes,
  });
}

const String kPrivacyUrl = 'https://flutterfootbalquiz.web.app/privacy';
const String kSupportUrl = 'https://flutterfootbalquiz.web.app/support';
const String kMarketingUrl = 'https://flutterfootbalquiz.web.app';

const List<LocalizedStoreListing> kStoreListings = <LocalizedStoreListing>[
  // 1. TURKISH (tr-TR / tr)
  LocalizedStoreListing(
    playLocale: 'tr-TR',
    iosLocale: 'tr',
    title: 'Goalverse: Football SOS',
    subtitle: 'Futbol Trivia & 1v1 SOS Oyunu',
    shortDescription:
        '3x3 kulüp kesişimlerinde ortak futbolcuları bul, 7 farklı modda bilginle kazan!',
    promotionalText:
        'Çok turlu 1v1 Football SOS maçları, 6 farklı futbol quiz modu, günlük mücadeleler ve global ELO liderlik tablosu seni bekliyor!',
    keywords:
        'futbol,sos,tictactoe,quiz,trivia,futbolcu,tahmin,online,1v1,maç,lig',
    fullDescription: '''Goalverse: Football SOS, futbol bilgisini taktiksel hamlelerle birleştiren rekabetçi bir futbol trivia ve 1v1 strateji oyunudur.

ÖNE ÇIKAN ÖZELLİKLER VE OYUN MODLARI:

• FOOTBALL SOS (3×3 KULÜP TABLOSU):
Satır ve sütunlardaki iki kulüpte de forma giymiş ortak futbolcuyu bularak hücreyi ele geçir, yatay, dikey veya çapraz üçlü çizgiyi tamamla!
- 3 Tur (2 Galibiyet) ve 5 Tur (3 Galibiyet) çok turlu seri maç sistemi.
- Aynı futbolcuyu farklı uygun hücrelerde tekrar kullanabilme özgürlüğü.
- Her turda oyuncu başına 2 pas hakkı ve gerçek zamanlı beraberlik teklifi sistemi.
- Yapay zekâya karşı Solo mod, aynı cihazda 2 kişilik yerel düello veya 6 haneli oda koduyla Online 1v1 maçlar.

• 6 FARKLI FUTBOL ARCADE & QUIZ MODU:
1. Rating Battle (Higher / Lower): Overall, piyasa değeri, kariyer golleri, asist, hız ve Şampiyonlar Ligi gollerinde hangi yıldızın daha yüksek olduğunu tahmin et.
2. 2 Takım 1 Oyuncu: İki dev kulüpte de oynamış ortak yıldızı süre bitmeden bul.
3. Ben Kimim? (Who Am I?): Zordan kolaya açılan 5 kariyer ipucuyla gizemli futbolcuyu en yüksek puanla bil.
4. Imposter (Sahtekâr Ajan): 4 futbolcu arasından belirtilen kulüpte hiç oynamamış olan sahtekârı yakala.
5. Transfer Yolu: Kronolojik kulüp geçmişini takip ederek gizli futbolcuyu keşfet.
6. Futbol Bombası: Bomba patlamadan kulüp veya ülke kriterine uyan futbolcuları sırayla yaz.

• GÜNLÜK MÜCADELE & GLOBAL ELO SIRALAMASI:
- Her gün yenilenen özel 3×3 kulüp tablosunu tamamla, serini koru.
- Kazandığın maçlarla ELO puanını yükselt, Başlangıç Ligi'nden Efsane Lig'e çık ve global liderlik tablosunda yerini al.

• FOOTBALL SOS PRO & KOZMETİK MAĞAZASI:
- Reklamsız stadyum deneyimi, özel saha ve 3×3 oyun tahtası temaları, profil çerçeveleri, özel rozetler ve 50 maçlık detaylı istatistik geçmişi.
- %100 Adil Rekabet: Hiçbir abonelik veya kozmetik ürün oyun içi ELO, süre veya hamle avantajı sağlamaz.''',
    releaseNotes: '''• 3 Tur (2 Galibiyet) ve 5 Tur (3 Galibiyet) çok turlu Football SOS maç sistemi eklendi.
• Online multiplayer maçlarda senkronize oyun tahtası ve tur arası özet ekranı eklendi.
• Pas geçme (tur başına 2 hak) ve beraberlik teklifi sistemi eklendi.
• Yeni stadyum ve çim saha arayüz tasarımı, Football SOS Pro ve Kozmetik Mağazası eklendi.''',
  ),

  // 2. ENGLISH (en-US)
  LocalizedStoreListing(
    playLocale: 'en-US',
    iosLocale: 'en-US',
    title: 'Goalverse: Football SOS',
    subtitle: 'Football Grid & Trivia Duel',
    shortDescription:
        'Name footballers who played for both clubs in 3x3 SOS grids & 7 trivia modes!',
    promotionalText:
        'Play multi-round 1v1 Football SOS matches, master 6 arcade football quiz modes, complete daily challenges, and climb the global ELO leaderboard!',
    keywords:
        'football,soccer,grid,tictactoe,sos,trivia,quiz,multiplayer,1v1,transfer,player',
    fullDescription: '''Goalverse: Football SOS is a competitive football trivia and tactical 3×3 grid game built for true football fans.

KEY FEATURES & GAME MODES:

• FOOTBALL SOS (3×3 CLUB INTERSECTION GRID):
Claim cells by naming a footballer who has played for both the row club and column club, and complete a line of three horizontally, vertically, or diagonally!
- Multi-round series format: Best of 3 (First to 2 wins) and Best of 5 (First to 3 wins).
- Reusable footballers across valid cells, 2 tactical passes per player each round, and live draw offers.
- Play Solo vs AI, Local 2-Player Pass & Play, Quick Online Matchmaking, or Private 6-digit Room Codes.

• 6 ARCADE FOOTBALL QUIZ MODES:
1. Rating Battle (Higher / Lower): Compare players across Overall rating, market value, career goals, assists, speed, and Champions League goals.
2. 2 Teams 1 Player: Find the shared star who played for both featured clubs.
3. Who Am I?: Guess the mystery footballer using up to 5 progressive career clues.
4. Imposter: Spot the 1 player out of 4 who never played for the target club.
5. Transfer Path: Identify the footballer from their chronological club career history.
6. Football Bomb: Name valid footballers matching the club or nationality prompt before the timer explodes.

• DAILY CHALLENGES & GLOBAL ELO LEADERBOARD:
- Solve a fresh 3×3 daily football grid every day to build your win streak.
- Climb divisions from Rising Star to Elite Pro on the global and country ELO leaderboards.

• FOOTBALL SOS PRO & COSMETIC STORE:
- Ad-free stadium experience, exclusive pitch & 3×3 board themes, champion profile frames, custom badges, and 50-match analytics history.
- 100% Fair Play Guarantee: Subscriptions and cosmetics never grant ELO, timer, or gameplay advantages.''',
    releaseNotes: '''• Added Best-of-3 and Best-of-5 multi-round Football SOS series system.
• Enhanced real-time multiplayer board synchronization and inter-round summary screens.
• Added 2 tactical passes per round and live draw offer system.
• Introduced the new Football Stadium UI theme, Football SOS Pro, and Cosmetic Store.''',
  ),

  // 3. SPANISH (es-ES)
  LocalizedStoreListing(
    playLocale: 'es-ES',
    iosLocale: 'es-ES',
    title: 'Goalverse: Football SOS',
    subtitle: 'Trivia de Fútbol y Duelo 3x3',
    shortDescription:
        '¡Encuentra futbolistas comunes en el tablero 3x3 SOS y domina 7 modos de fútbol!',
    promotionalText:
        '¡Juega series multirronda 1v1 de Football SOS, supera 6 modos de trivia de fútbol y sube en la clasificación mundial ELO!',
    keywords:
        'futbol,sos,tresenraya,trivia,quiz,jugadores,fichajes,multijugador,duelo,liga',
    fullDescription: '''Goalverse: Football SOS es el juego competitivo de trivia de fútbol y estrategia en tablero 3×3 para verdaderos apasionados del fútbol.

CARACTERÍSTICAS Y MODOS DE JUEGO:

• FOOTBALL SOS (TABLERO 3×3 DE CLUBES):
Nombra a un futbolista que haya jugado tanto en el club de la fila como en el de la columna para conquistar la casilla y formar tres en línea.
- Series al mejor de 3 rondas (2 victorias) y 5 rondas (3 victorias).
- Reutilización de futbolistas en distintas casillas, 2 pases por ronda y ofertas de empate en tiempo real.
- Modo Solo contra IA, Duelo Local de 2 jugadores y Partidas Online 1v1 con código de sala.

• 6 MODOS ARCADE DE FÚTBOL:
1. Rating Battle: Compara valoración general, valor de mercado, goles, asistencias y velocidad.
2. 2 Equipos 1 Jugador: Encuentra al crack que vistió ambas camisetas.
3. ¿Quién Soy?: Adivina al jugador misterioso con 5 pistas progresivas.
4. Impostor: Detecta cuál de los 4 jugadores nunca jugó en el club objetivo.
5. Ruta de Fichajes: Adivina al futbolista siguiendo su historial cronológico de clubes.
6. Bomba de Fútbol: Nombra jugadores válidos antes de que explote el cronómetro.

• RETO DIARIO Y CLASIFICACIÓN ELO:
- Completa el desafío diario 3×3 y sube de división en el ranking global.

• FOOTBALL SOS PRO Y TIENDA COSMÉTICA:
- Experiencia sin anuncios, temas de césped y tablero 3×3, marcos de perfil e historial de 50 partidos sin ventajas competitivas (100% Fair Play).''',
    releaseNotes: '''• Sistema de series de 3 y 5 rondas para Football SOS.
• Sincronización multijugador mejorada, 2 pases por ronda y ofertas de empate.
• Nuevo diseño de estadio de fútbol, Football SOS Pro y Tienda Cosmética.''',
  ),

  // 4. FRENCH (fr-FR)
  LocalizedStoreListing(
    playLocale: 'fr-FR',
    iosLocale: 'fr-FR',
    title: 'Goalverse: Football SOS',
    subtitle: 'Quiz Foot & Grille 3x3 1v1',
    shortDescription:
        'Trouvez les joueurs communs sur la grille 3x3 SOS et défiez vos amis en 1v1 !',
    promotionalText:
        'Disputez des séries 1v1 Football SOS en 3 ou 5 manches, découvrez 6 modes quiz foot et grimpez au classement ELO mondial !',
    keywords:
        'football,foot,sos,morpion,quiz,trivia,joueur,transfert,multijoueur,1v1,ligue',
    fullDescription: '''Goalverse: Football SOS combine culture footballistique et stratégie sur une grille 3×3 compétitive.

FONCTIONNALITÉS ET MODES DE JEU :

• FOOTBALL SOS (GRILLE 3×3 DE CLUBS) :
Trouvez un footballeur ayant porté le maillot du club de la ligne et de la colonne pour remporter la case et aligner 3 symboles !
- Matchs en séries de 3 manches (2 victoires) ou 5 manches (3 victoires).
- Réutilisation des joueurs autorisée entre les cases, 2 passes par manche et proposition de match nul en direct.
- Jouez en Solo contre l'IA, à 2 sur le même écran ou en ligne 1v1 via code de salon.

• 6 MODES QUIZ & ARCADE :
1. Rating Battle : Comparez la note globale, la valeur marchande, les buts et la vitesse.
2. 2 Clubs 1 Joueur : Trouvez la star passée par les deux clubs.
3. Qui Suis-Je ? : Devinez le joueur mystère grâce à 5 indices de carrière.
4. Imposteur : Repérez l'intrus parmi 4 joueurs qui n'a jamais joué pour le club cible.
5. Parcours de Transferts : Reconnaissez le joueur via l'historique chronologique de ses clubs.
6. Bombe Foot : Citez des joueurs valides avant la fin du compte à rebours.

• DÉFI QUOTIDIEN, CLASSEMENT ELO & FOOTBALL SOS PRO :
- Grille quotidienne, classement ELO mondial, boutique cosmétique et abonnement Football SOS Pro sans publicité (100 % Fair-Play, aucun avantage compétitif).''',
    releaseNotes: '''• Matchs en séries de 3 et 5 manches pour Football SOS.
• Synchronisation multijoueur en temps réel, 2 passes par manche et offres de match nul.
• Nouvelle interface stade de football, Football SOS Pro et Boutique Cosmétique.''',
  ),

  // 5. GERMAN (de-DE)
  LocalizedStoreListing(
    playLocale: 'de-DE',
    iosLocale: 'de-DE',
    title: 'Goalverse: Football SOS',
    subtitle: 'Fußball-Quiz & 3x3 Taktik',
    shortDescription:
        'Finde gemeinsame Fußballprofis im 3x3-SOS-Raster und meistere 7 Fußball-Modi!',
    promotionalText:
        'Spiele spannende Best-of-3- und Best-of-5-Football-SOS-Duelle, 6 Arcade-Fußballquiz-Modi und erklimme die globale ELO-Bestenliste!',
    keywords:
        'fussball,fußball,sos,tictactoe,quiz,trivia,spieler,transfer,multiplayer,duell',
    fullDescription: '''Goalverse: Football SOS verbindet Fußballwissen mit taktischer 3×3-Spielfeldstrategie.

HIGHLIGHTS & SPIELMODI:

• FOOTBALL SOS (3×3-VEREINSRASTER):
Nenne einen Fußballspieler, der für beide Vereine (Zeile und Spalte) gespielt hat, sichere dir das Feld und bilde eine Dreierreihe!
- Mehrrunden-Serien: 3 Runden (2 Siege) oder 5 Runden (3 Siege).
- Wiederverwendung von Spielern auf verschiedenen Feldern, 2 Pässe pro Runde und Live-Remis-Angebote.
- Solo gegen KI, lokales 2-Spieler-Duell oder Online-1v1 mit Raumcode.

• 6 WEITERE FUSSBALL-ARCADE-MODI:
1. Rating Battle: Vergleiche Gesamtwert, Marktwert, Tore, Vorlagen und Tempo.
2. 2 Vereine 1 Spieler: Finde den gemeinsamen Star beider Klubs.
3. Wer Bin Ich?: Errate den gesuchten Profi anhand von 5 Karriere-Hinweisen.
4. Imposter: Entlarve unter 4 Spielern denjenigen, der nie beim Zielverein spielte.
5. Transfer-Pfad: Erkenne den Profi anhand seiner chronologischen Vereinsstationen.
6. Fußball-Bombe: Nenne passende Spieler, bevor die Zeit abläuft.

• TÄGLICHE HERAUSFORDERUNG, ELO-RANGLISTE & FOOTBALL SOS PRO:
- Tägliches 3×3-Rätsel, globale ELO-Rangliste, Kosmetik-Shop und werbefreies Football SOS Pro (100 % Fair Play ohne spielerische Vorteile).''',
    releaseNotes: '''• Mehrrunden-System (3 Runden / 5 Runden) für Football SOS.
• Verbesserte Echtzeit-Synchronisierung im Multiplayer, 2 Pässe pro Runde und Remis-Angebote.
• Neues Stadion-Design, Football SOS Pro und Kosmetik-Shop.''',
  ),

  // 6. ITALIAN (it-IT / it)
  LocalizedStoreListing(
    playLocale: 'it-IT',
    iosLocale: 'it',
    title: 'Goalverse: Football SOS',
    subtitle: 'Quiz Calcio & Griglia 3x3',
    shortDescription:
        'Trova i calciatori comuni nella griglia 3x3 SOS e sfida gli amici in 7 modalità!',
    promotionalText:
        'Gioca sfide 1v1 Football SOS al meglio di 3 o 5 round, scopri 6 modalità quiz sul calcio e scala la classifica mondiale ELO!',
    keywords:
        'calcio,sos,tris,quiz,trivia,calciatori,trasferimenti,multigiocatore,1v1,serie',
    fullDescription: '''Goalverse: Football SOS unisce cultura calcistica e strategia in una sfida su griglia 3×3.

CARATTERISTICHE E MODALITÀ DI GIOCO:

• FOOTBALL SOS (GRIGLIA 3×3 DEI CLUB):
Inserisci un calciatore che ha militato sia nel club della riga che in quello della colonna per conquistare la casella e completare un tris!
- Serie multi-round: 3 Round (2 vittorie) e 5 Round (3 vittorie).
- Riutilizzo dei calciatori in caselle diverse, 2 passaggi per round e proposte di pareggio in tempo reale.
- Gioca in Solo contro l'IA, in 2 sullo stesso dispositivo o Online 1v1 con codice stanza.

• 6 MODALITÀ QUIZ & ARCADE SUL CALCIO:
1. Rating Battle: Confronta overall, valore di mercato, gol, assist e velocità.
2. 2 Squadre 1 Giocatore: Trova il campione che ha giocato in entrambi i club.
3. Chi Sono?: Indovina il calciatore misterioso grazie a 5 indizi progressivi.
4. Impostore: Scopri quale dei 4 calciatori non ha mai giocato nel club indicato.
5. Percorso Trasferimenti: Riconosci il giocatore dalla cronologia dei suoi trasferimenti.
6. Bomba Calcio: Nomina calciatori validi prima che scada il tempo.

• SFIDA GIORNALIERA, CLASSIFICA ELO E FOOTBALL SOS PRO:
- Sfida 3×3 giornaliera, classifica ELO globale, Negozio Cosmetico e abbonamento Football SOS Pro senza pubblicità (100% Fair Play, nessun vantaggio competitivo).''',
    releaseNotes: '''• Serie multi-round da 3 e 5 round per Football SOS.
• Sincronizzazione multiplayer in tempo reale, 2 passaggi per round e offerte di pareggio.
• Nuovo design stadio, Football SOS Pro e Negozio Cosmetico.''',
  ),
];

void main() {
  for (final item in kStoreListings) {
    // Validate character limits
    assert(item.title.length <= 30, 'Title too long for ${item.playLocale}');
    assert(
      item.subtitle.length <= 30,
      'Subtitle too long for ${item.iosLocale}',
    );
    assert(
      item.shortDescription.length <= 80,
      'Short description too long for ${item.playLocale}: ${item.shortDescription.length}',
    );
    assert(
      item.promotionalText.length <= 170,
      'Promo text too long for ${item.iosLocale}',
    );
    assert(
      item.keywords.length <= 100,
      'Keywords too long for ${item.iosLocale}: ${item.keywords.length}',
    );
    assert(
      item.fullDescription.length <= 4000,
      'Full description too long for ${item.playLocale}',
    );
    assert(
      item.releaseNotes.length <= 500,
      'Release notes too long for ${item.playLocale}',
    );

    // 1. Write Google Play Fastlane metadata
    final playDir = Directory(
      'android/fastlane/metadata/android/${item.playLocale}',
    );
    playDir.createSync(recursive: true);
    File('${playDir.path}/title.txt').writeAsStringSync('${item.title}\n');
    File(
      '${playDir.path}/short_description.txt',
    ).writeAsStringSync('${item.shortDescription}\n');
    File(
      '${playDir.path}/full_description.txt',
    ).writeAsStringSync('${item.fullDescription}\n');

    final changelogDir = Directory('${playDir.path}/changelogs');
    changelogDir.createSync(recursive: true);
    File(
      '${changelogDir.path}/default.txt',
    ).writeAsStringSync('${item.releaseNotes}\n');
    File(
      '${changelogDir.path}/2.txt',
    ).writeAsStringSync('${item.releaseNotes}\n');

    // Ensure screenshot folders exist
    Directory(
      '${playDir.path}/images/phoneScreenshots',
    ).createSync(recursive: true);

    // 2. Write iOS App Store Fastlane metadata
    final iosDir = Directory('ios/fastlane/metadata/${item.iosLocale}');
    iosDir.createSync(recursive: true);
    File('${iosDir.path}/name.txt').writeAsStringSync('${item.title}\n');
    File('${iosDir.path}/subtitle.txt').writeAsStringSync('${item.subtitle}\n');
    File(
      '${iosDir.path}/promotional_text.txt',
    ).writeAsStringSync('${item.promotionalText}\n');
    File(
      '${iosDir.path}/description.txt',
    ).writeAsStringSync('${item.fullDescription}\n');
    File('${iosDir.path}/keywords.txt').writeAsStringSync('${item.keywords}\n');
    File(
      '${iosDir.path}/release_notes.txt',
    ).writeAsStringSync('${item.releaseNotes}\n');
    File('${iosDir.path}/privacy_url.txt').writeAsStringSync('$kPrivacyUrl\n');
    File('${iosDir.path}/support_url.txt').writeAsStringSync('$kSupportUrl\n');
    File(
      '${iosDir.path}/marketing_url.txt',
    ).writeAsStringSync('$kMarketingUrl\n');

    Directory(
      'ios/fastlane/screenshots/${item.iosLocale}',
    ).createSync(recursive: true);
  }

  // Write shared compliance, rating questionnaire & contact metadata
  final complianceDir = Directory('store_metadata');
  complianceDir.createSync(recursive: true);
  File('${complianceDir.path}/store_compliance_and_rating.json')
      .writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'appName': 'Goalverse: Football SOS',
          'defaultLanguage': 'tr-TR',
          'supportedLocales': ['tr-TR', 'en-US', 'es-ES', 'fr-FR', 'de-DE', 'it-IT'],
          'categories': {
            'googlePlay': {
              'applicationType': 'GAME',
              'primaryCategory': 'GAME_SPORTS',
              'secondaryCategory': 'GAME_TRIVIA',
              'tags': ['Football', 'Soccer', 'Trivia', 'Multiplayer', 'Board'],
            },
            'appStoreConnect': {
              'primaryCategory': 'GAMES',
              'primarySubcategoryOne': 'GAMES_SPORTS',
              'primarySubcategoryTwo': 'GAMES_TRIVIA',
              'secondaryCategory': 'SPORTS',
            },
          },
          'urls': {
            'privacyPolicyUrl': kPrivacyUrl,
            'supportUrl': kSupportUrl,
            'marketingUrl': kMarketingUrl,
            'termsOfUseUrl': 'https://goalverse.app/terms',
          },
          'contactInformation': {
            'supportEmail': 'support@goalverse.app',
            'pressAndMarketingEmail': 'hello@goalverse.app',
            'website': kMarketingUrl,
            'phone': '+90 212 000 0000',
          },
          'contentRatingQuestionnaire': {
            'targetAgeRating': {
              'appleAgeRating': '4+',
              'pegi': 'PEGI 3',
              'esrb': 'Everyone (E)',
              'usk': 'USK 0',
            },
            'declarations': {
              'violence': 'NONE',
              'sexuality': 'NONE',
              'profanity': 'NONE',
              'controlledSubstances': 'NONE',
              'gamblingOrSimulatedGambling': 'NONE',
              'userGeneratedContent': 'LIMITED_DISPLAY_NAMES_AND_ROOM_CODES',
              'onlineMultiplayerInteraction': true,
              'inAppPurchases': true,
              'digitalSubscriptions': [
                'football_sos_pro_monthly',
                'football_sos_pro_yearly',
              ],
              'advertising': 'ADMOB_NON_INTRUSIVE_REMOVABLE_WITH_PRO',
            },
          },
        }),
      );

  stdout.writeln(
    'Generated 6-language store metadata for Google Play and App Store Connect.',
  );
}
