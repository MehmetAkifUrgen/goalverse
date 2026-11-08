import json
import os

NEW_TRANSLATIONS = {
    "leagueLegend": {
        "en": "Legend League",
        "tr": "Efsane Lig",
        "de": "Legenden-Liga",
        "es": "Liga Leyenda",
        "fr": "Ligue Légende",
        "it": "Lega Leggenda",
        "desc": "Legend league division name"
    },
    "leagueElite": {
        "en": "Elite League",
        "tr": "Elit Lig",
        "de": "Elite-Liga",
        "es": "Liga Élite",
        "fr": "Ligue Élite",
        "it": "Lega Elite",
        "desc": "Elite league division name"
    },
    "leaguePro": {
        "en": "Pro League",
        "tr": "Pro Lig",
        "de": "Profi-Liga",
        "es": "Liga Pro",
        "fr": "Ligue Pro",
        "it": "Lega Pro",
        "desc": "Pro league division name"
    },
    "leagueStarter": {
        "en": "Starter League",
        "tr": "Başlangıç Ligi",
        "de": "Starter-Liga",
        "es": "Liga Inicial",
        "fr": "Ligue Débutant",
        "it": "Lega Iniziale",
        "desc": "Starter league division name"
    },
    "defaultCaptainName": {
        "en": "Goalverse Captain",
        "tr": "Goalverse Kaptanı",
        "de": "Goalverse-Kapitän",
        "es": "Capitán Goalverse",
        "fr": "Capitaine Goalverse",
        "it": "Capitano Goalverse",
        "desc": "Default player display name"
    },
    "seasonDerbyWeek": {
        "en": "SEASON 1 DERBY WEEK",
        "tr": "SEZON 1 DERBİ HAFTASI",
        "de": "SAISON 1 DERBY-WOCHE",
        "es": "TEMPORADA 1 SEMANA DE DERBI",
        "fr": "SAISON 1 SEMAINE DU DERBY",
        "it": "STAGIONE 1 SETTIMANA DEL DERBY",
        "desc": "Live event banner in hero stage"
    },
    "heroHeadline": {
        "en": "Step onto the Pitch,\nProve Your Knowledge.",
        "tr": "Sahaya Çık,\nFutbol Bilgini Kanıtla.",
        "de": "Betritt den Rasen,\nBeweise dein Wissen.",
        "es": "Salta al Campo,\nDemuestra tu Saber.",
        "fr": "Entrez sur le Terrain,\nProuvez votre Savoir.",
        "it": "Scendi in Campo,\nDimostra il tuo Sapere.",
        "desc": "Hero section main headline"
    },
    "heroSubtitle": {
        "en": "Practice solo, dive into live 1v1 matchmaking, or create a private room to duel friends in the Goalverse football gaming universe.",
        "tr": "Goalverse futbol oyun evreninde tek başına pratik yap, canlı 1v1 eşleşmeye gir veya özel oda kurarak arkadaşlarınla düello at.",
        "de": "Übe solo, starte 1v1-Matches oder erstelle einen privaten Raum für Duelle im Goalverse-Fußballuniversum.",
        "es": "Practica en solitario, juega 1c1 en vivo o crea una sala privada para retar a amigos en el universo de Goalverse.",
        "fr": "Entraînez-vous en solo, lancez un 1v1 ou créez un salon privé pour affronter vos amis dans l'univers Goalverse.",
        "it": "Allenati da solo, gioca 1v1 dal vivo o crea una stanza privata per sfidare gli amici nell'universo calcistico di Goalverse.",
        "desc": "Hero section description"
    },
    "soloPlay": {
        "en": "Play Solo",
        "tr": "Solo Oyna",
        "de": "Solo Spielen",
        "es": "Jugar en Solitario",
        "fr": "Jouer en Solo",
        "it": "Gioca da Solo",
        "desc": "Solo play CTA button"
    },
    "onlineMatch": {
        "en": "Online Match",
        "tr": "Online Eşleşme",
        "de": "Online-Match",
        "es": "Partida Online",
        "fr": "Match en Ligne",
        "it": "Partita Online",
        "desc": "Online matchmaking CTA button"
    },
    "createPrivateRoom": {
        "en": "Create Room",
        "tr": "Özel Oda Kur",
        "de": "Raum Erstellen",
        "es": "Crear Sala",
        "fr": "Créer un Salon",
        "it": "Crea Stanza",
        "desc": "Private room creation pill"
    },
    "joinWithCode": {
        "en": "Join with Code",
        "tr": "Oda Koduna Katıl",
        "de": "Mit Code Beitreten",
        "es": "Unirse con Código",
        "fr": "Rejoindre avec Code",
        "it": "Unisciti con Codice",
        "desc": "Join room with code pill"
    },
    "featuredModes": {
        "en": "Featured Modes",
        "tr": "Öne Çıkan Modlar",
        "de": "Hervorgehobene Modi",
        "es": "Modos Destacados",
        "fr": "Modes Vedettes",
        "it": "Modalità in Evidenza",
        "desc": "Featured game modes section title"
    },
    "featuredModesSubtitle": {
        "en": "Signature Goalverse competitive experiences",
        "tr": "Goalverse imza rekabet deneyimleri",
        "de": "Typische Goalverse-Wettkampferlebnisse",
        "es": "Experiencias competitivas de Goalverse",
        "fr": "Expériences compétitives Goalverse",
        "it": "Esperienze competitive Goalverse",
        "desc": "Featured modes section subtitle"
    },
    "badgePopular": {
        "en": "POPULAR",
        "tr": "POPÜLER",
        "de": "BELIEBT",
        "es": "POPULAR",
        "fr": "POPULAIRE",
        "it": "POPOLARE",
        "desc": "Popular badge tag"
    },
    "sosCardSubtitle": {
        "en": "Find shared stars in the 3×3 club grid and complete a three-in-a-row.",
        "tr": "3×3 kulüp kesişim tablosunda ortak yıldızları bul, üçlü çizgiyi tamamla.",
        "de": "Finde gemeinsame Stars im 3×3-Vereinsgitter und schließe die Reihe ab.",
        "es": "Encuentra estrellas compartidas en la cuadrícula 3×3 y completa la línea.",
        "fr": "Trouvez les étoiles communes sur la grille 3×3 et complétez la ligne.",
        "it": "Trova le stelle condivise nella griglia 3×3 e completa il tris.",
        "desc": "Subtitle for Football SOS game card"
    },
    "playNow": {
        "en": "Play Now",
        "tr": "Hemen Oyna",
        "de": "Jetzt Spielen",
        "es": "Jugar Ahora",
        "fr": "Jouer Maintenant",
        "it": "Gioca Ora",
        "desc": "Play now primary button"
    },
    "ratingBattleSubtitle": {
        "en": "Pick the card with superior overall, market value, or career goals.",
        "tr": "Overall, piyasa değeri ve kariyer gollerinde üstün olan kartı seç.",
        "de": "Wähle die Karte mit besseren Werten, Marktwert oder Karrieretoren.",
        "es": "Elige la carta superior en valoración, valor de mercado o goles.",
        "fr": "Choisissez la carte supérieure en note générale, valeur ou buts.",
        "it": "Scegli la carta superiore per valutazione generale, valore o gol.",
        "desc": "Subtitle for Rating Battle card"
    },
    "arcadeModes": {
        "en": "Arcade Modes",
        "tr": "Arcade Modları",
        "de": "Arcade-Modi",
        "es": "Modos Arcade",
        "fr": "Modes Arcade",
        "it": "Modalità Arcade",
        "desc": "Arcade game modes section title"
    },
    "arcadeModesSubtitle": {
        "en": "Test your football culture with distinct rules",
        "tr": "Farklı kurallarla futbol kültürünü sına",
        "de": "Teste deine Fußballkultur mit verschiedenen Regeln",
        "es": "Pon a prueba tu cultura futbolística con diversas reglas",
        "fr": "Testez votre culture foot avec différentes règles",
        "it": "Metti alla prova la tua cultura calcistica con regole diverse",
        "desc": "Arcade modes section subtitle"
    },
    "badgeModesCount": {
        "en": "5 MODES",
        "tr": "5 MOD",
        "de": "5 MODI",
        "es": "5 MODOS",
        "fr": "5 MODES",
        "it": "5 MODALITÀ",
        "desc": "5 Modes badge tag"
    },
    "twoTeamsTitle": {
        "en": "2 Clubs 1 Player",
        "tr": "2 Takım 1 Oyuncu",
        "de": "2 Vereine 1 Spieler",
        "es": "2 Clubes 1 Jugador",
        "fr": "2 Clubs 1 Joueur",
        "it": "2 Club 1 Giocatore",
        "desc": "Two clubs one player mode title"
    },
    "twoTeamsSubtitle": {
        "en": "Find the shared star footballer who played for both clubs.",
        "tr": "İki dev kulüpte de forma giymiş ortak yıldız futbolcuyu bul.",
        "de": "Finde den gemeinsamen Star, der für beide Vereine spielte.",
        "es": "Encuentra al futbolista estrella que jugó en ambos clubes.",
        "fr": "Trouvez la star qui a joué dans les deux clubs.",
        "it": "Trova la stella che ha giocato per entrambi i club.",
        "desc": "Two clubs one player mode subtitle"
    },
    "twoTeamsStatus": {
        "en": "Shared Star",
        "tr": "Ortak Yıldız",
        "de": "Gemeinsamer Star",
        "es": "Estrella Común",
        "fr": "Star Commune",
        "it": "Stella Comune",
        "desc": "Shared star pill tag"
    },
    "whoAmITitle": {
        "en": "Who Am I?",
        "tr": "Ben Kimim?",
        "de": "Wer bin ich?",
        "es": "¿Quién soy?",
        "fr": "Qui suis-je ?",
        "it": "Chi sono?",
        "desc": "Who am I mode title"
    },
    "whoAmISubtitle": {
        "en": "Guess the secret legend with 5 career clues revealed from hard to easy.",
        "tr": "Zordan kolaya açılan 5 kariyer ipucuyla gizli efsaneyi tahmin et.",
        "de": "Errate die Legende mit 5 Karriere-Hinweisen von schwer bis leicht.",
        "es": "Adivina la leyenda secreta con 5 pistas de carrera de difícil a fácil.",
        "fr": "Devinez la légende avec 5 indices de carrière du plus dur au plus facile.",
        "it": "Indovina la leggenda con 5 indizi di carriera dal più difficile al più facile.",
        "desc": "Who am I mode subtitle"
    },
    "whoAmIStatus": {
        "en": "Mystery Card",
        "tr": "Gizemli Kart",
        "de": "Geheimniskarte",
        "es": "Carta Misteriosa",
        "fr": "Carte Mystère",
        "it": "Carta Misteriosa",
        "desc": "Mystery card pill tag"
    },
    "fiveClues": {
        "en": "5 Clues",
        "tr": "5 İpucu",
        "de": "5 Hinweise",
        "es": "5 Pistas",
        "fr": "5 Indices",
        "it": "5 Indizi",
        "desc": "5 Clues duration label"
    },
    "imposterTitle": {
        "en": "Imposter",
        "tr": "Imposter (Ajan)",
        "de": "Hochstapler",
        "es": "Impostor",
        "fr": "Imposteur",
        "it": "Impostore",
        "desc": "Imposter mode title"
    },
    "imposterSubtitle": {
        "en": "Catch the imposter who never played for the target club among 4 players.",
        "tr": "4 futbolcu arasından hedef kulüpte hiç oynamamış sahtekârı yakala.",
        "de": "Entlarve unter 4 Spielern denjenigen, der nie für den Verein spielte.",
        "es": "Atrapa al impostor que nunca jugó en el club objetivo entre 4 futbolistas.",
        "fr": "Démasquez l'imposteur qui n'a jamais joué pour le club parmi 4 joueurs.",
        "it": "Smaschera l'impostore che non ha mai giocato per il club bersaglio tra 4 giocatori.",
        "desc": "Imposter mode subtitle"
    },
    "imposterStatus": {
        "en": "1 Imposter",
        "tr": "1 Sahtekâr",
        "de": "1 Hochstapler",
        "es": "1 Impostor",
        "fr": "1 Imposteur",
        "it": "1 Impostore",
        "desc": "1 Imposter status tag"
    },
    "transferPathTitle": {
        "en": "Transfer Path",
        "tr": "Transfer Yolu",
        "de": "Transferpfad",
        "es": "Ruta de Fichajes",
        "fr": "Chemin des Transferts",
        "it": "Percorso Trasferimenti",
        "desc": "Transfer path mode title"
    },
    "transferPathSubtitle": {
        "en": "Find the player by following their chronological club history and seasons.",
        "tr": "Kronolojik kulüp geçmişini ve sezonları takip ederek oyuncuyu bul.",
        "de": "Finde den Spieler anhand seiner chronologischen Vereinsstationen.",
        "es": "Encuentra al jugador siguiendo su historial de clubes y temporadas.",
        "fr": "Trouvez le joueur en suivant son historique de clubs et saisons.",
        "it": "Trova il giocatore seguendo la cronologia dei suoi club e stagioni.",
        "desc": "Transfer path mode subtitle"
    },
    "transferPathStatus": {
        "en": "Career Route",
        "tr": "Kariyer Rotası",
        "de": "Karriere-Route",
        "es": "Ruta de Carrera",
        "fr": "Route de Carrière",
        "it": "Percorso di Carriera",
        "desc": "Career route status tag"
    },
    "threePlusClubs": {
        "en": "3+ Clubs",
        "tr": "3+ Kulüp",
        "de": "3+ Vereine",
        "es": "3+ Clubes",
        "fr": "3+ Clubs",
        "it": "3+ Club",
        "desc": "3+ clubs label"
    },
    "footballBombTitle": {
        "en": "Football Bomb",
        "tr": "Futbol Bombası",
        "de": "Fußballbombe",
        "es": "Bomba de Fútbol",
        "fr": "Bombe de Football",
        "it": "Bomba Calcio",
        "desc": "Football bomb mode title"
    },
    "footballBombSubtitle": {
        "en": "Name a player matching the club or country criteria before the bomb explodes.",
        "tr": "Bomba patlamadan kulüp veya ülke şartına uyan futbolcuyu söyle.",
        "de": "Nenne einen passenden Spieler, bevor die Bombe explodiert.",
        "es": "Nombra a un jugador válido antes de que explote la bomba.",
        "fr": "Nommez un joueur valide avant que la bombe n'explose.",
        "it": "Nomina un giocatore valido prima che la bomba esploda.",
        "desc": "Football bomb mode subtitle"
    },
    "footballBombStatus": {
        "en": "Countdown",
        "tr": "Geri Sayım",
        "de": "Countdown",
        "es": "Cuenta Atrás",
        "fr": "Compte à Rebours",
        "it": "Conto alla Rovescia",
        "desc": "Countdown status tag"
    },
    "partyModeLabel": {
        "en": "1-8P • Party",
        "tr": "1-8P • Parti",
        "de": "1-8S • Party",
        "es": "1-8J • Fiesta",
        "fr": "1-8J • Fête",
        "it": "1-8G • Party",
        "desc": "Party mode playerCount label"
    },
    "oneToTwoOnlineLabel": {
        "en": "1-2P • Online",
        "tr": "1-2P • Online",
        "de": "1-2S • Online",
        "es": "1-2J • Online",
        "fr": "1-2J • En Ligne",
        "it": "1-2G • Online",
        "desc": "1-2 player online label"
    },
    "roomPlayAction": {
        "en": "Room",
        "tr": "Oda",
        "de": "Raum",
        "es": "Sala",
        "fr": "Salon",
        "it": "Stanza",
        "desc": "Room play action prefix"
    },
    "playAction": {
        "en": "Play",
        "tr": "Oyna",
        "de": "Spielen",
        "es": "Jugar",
        "fr": "Jouer",
        "it": "Gioca",
        "desc": "Play action suffix"
    },
    "dailyAndRanking": {
        "en": "Daily Quest & Ranking",
        "tr": "Günlük Görev & Sıralama",
        "de": "Tagesquest & Rangliste",
        "es": "Misión Diaria y Clasificación",
        "fr": "Quête Quotidienne & Classement",
        "it": "Missione Giornaliera & Classifica",
        "desc": "Daily quest and ranking section header"
    },
    "dailyAndRankingSubtitle": {
        "en": "Claim rewards, rise to the global podium",
        "tr": "Ödülleri topla, global podyuma yüksel",
        "de": "Sammle Belohnungen, steige auf das weltweite Podium",
        "es": "Consigue recompensas y sube al podio mundial",
        "fr": "Récupérez les récompenses et montez sur le podium mondial",
        "it": "Ottieni ricompense e sali sul podio globale",
        "desc": "Daily quest and ranking section subtitle"
    },
    "seasonOne": {
        "en": "SEASON 1",
        "tr": "SEZON 1",
        "de": "SAISON 1",
        "es": "TEMPORADA 1",
        "fr": "SAISON 1",
        "it": "STAGIONE 1",
        "desc": "Season 1 badge"
    },
    "activeQuest": {
        "en": "ACTIVE QUEST",
        "tr": "AKTİF GÖREV",
        "de": "AKTIVE QUEST",
        "es": "MISIÓN ACTIVA",
        "fr": "QUÊTE ACTIVE",
        "it": "MISSIONE ATTIVA",
        "desc": "Active quest badge"
    },
    "dailyChallengeSubtitle": {
        "en": "Complete today's 3×3 grid to earn extra rewards.",
        "tr": "Günün özel 3×3 kulüp tablosunu tamamla ve ekstra ödül kazan.",
        "de": "Schließe das heutige 3×3-Gitter ab für zusätzliche Belohnungen.",
        "es": "Completa la cuadrícula 3×3 de hoy y gana recompensas extra.",
        "fr": "Complétez la grille 3×3 du jour pour remporter des récompenses.",
        "it": "Completa la griglia 3×3 di oggi per guadagnare ricompense extra.",
        "desc": "Daily challenge card description"
    },
    "startQuest": {
        "en": "Start Quest",
        "tr": "Görevi Başlat",
        "de": "Quest Starten",
        "es": "Iniciar Misión",
        "fr": "Lancer la Quête",
        "it": "Inizia Missione",
        "desc": "Start quest action button"
    },
    "leaderboardSubtitle": {
        "en": "Global Top 100 & Season Podium",
        "tr": "Global Top 100 & Sezon Podyumu",
        "de": "Globale Top 100 & Saison-Podium",
        "es": "Top 100 Mundial y Podio de Temporada",
        "fr": "Top 100 Mondial & Podium de Saison",
        "it": "Top 100 Globale & Podio Stagionale",
        "desc": "Leaderboard card subtitle"
    },
    "rankElite": {
        "en": "Elite",
        "tr": "Elit",
        "de": "Elite",
        "es": "Élite",
        "fr": "Élite",
        "it": "Elite",
        "desc": "Rank elite title"
    },
    "rankCaptain": {
        "en": "Captain",
        "tr": "Kaptan",
        "de": "Kapitän",
        "es": "Capitán",
        "fr": "Capitaine",
        "it": "Capitano",
        "desc": "Rank captain title"
    },
    "rankStar": {
        "en": "Star",
        "tr": "Yıldız",
        "de": "Stern",
        "es": "Estrella",
        "fr": "Étoile",
        "it": "Stella",
        "desc": "Rank star title"
    },
    "youPlayerPrefix": {
        "en": "You",
        "tr": "Sen",
        "de": "Du",
        "es": "Tú",
        "fr": "Vous",
        "it": "Tu",
        "desc": "You player indicator label"
    },
    "navArena": {
        "en": "ARENA",
        "tr": "ARENA",
        "de": "ARENA",
        "es": "ARENA",
        "fr": "ARÈNE",
        "it": "ARENA",
        "desc": "Bottom navigation arena tab"
    },
    "navOnline": {
        "en": "ONLINE",
        "tr": "ONLINE",
        "de": "ONLINE",
        "es": "ONLINE",
        "fr": "EN LIGNE",
        "it": "ONLINE",
        "desc": "Bottom navigation online tab"
    },
    "navDaily": {
        "en": "DAILY",
        "tr": "GÜNLÜK",
        "de": "TÄGLICH",
        "es": "DIARIO",
        "fr": "QUOTIDIEN",
        "it": "GIORNALIERO",
        "desc": "Bottom navigation daily tab"
    },
    "navRanking": {
        "en": "RANKING",
        "tr": "SIRALAMA",
        "de": "RANGLISTE",
        "es": "RANKING",
        "fr": "CLASSEMENT",
        "it": "CLASSIFICA",
        "desc": "Bottom navigation ranking tab"
    },
    "navProfile": {
        "en": "PROFILE",
        "tr": "PROFİL",
        "de": "PROFIL",
        "es": "PERFIL",
        "fr": "PROFIL",
        "it": "PROFILO",
        "desc": "Bottom navigation profile tab"
    },
    "forgotPasswordQuestion": {
        "en": "Forgot Password?",
        "tr": "Şifremi Unuttum?",
        "de": "Passwort vergessen?",
        "es": "¿Has olvidado tu contraseña?",
        "fr": "Mot de passe oublié ?",
        "it": "Password dimenticata?",
        "desc": "Forgot password link button"
    },
    "confirmPasswordLabel": {
        "en": "Confirm Password",
        "tr": "Şifre Tekrarı",
        "de": "Passwort bestätigen",
        "es": "Confirmar Contraseña",
        "fr": "Confirmer le Mot de Passe",
        "it": "Conferma Password",
        "desc": "Confirm password field label"
    },
    "confirmPasswordHint": {
        "en": "Re-enter your password",
        "tr": "Şifrenizi tekrar girin",
        "de": "Passwort erneut eingeben",
        "es": "Vuelve a introducir tu contraseña",
        "fr": "Entrez à nouveau votre mot de passe",
        "it": "Reinserisci la tua password",
        "desc": "Confirm password placeholder hint"
    },
    "termsAcceptPrefix": {
        "en": "I have read and accept the ",
        "tr": "",
        "de": "Ich habe die ",
        "es": "He leído y acepto los ",
        "fr": "J'ai lu et j'accepte les ",
        "it": "Ho letto e accetto i ",
        "desc": "Terms checkbox prefix"
    },
    "termsAcceptLink": {
        "en": "Terms of Service and Privacy Policy",
        "tr": "Kullanım Koşulları ve Gizlilik Politikasını",
        "de": "Nutzungsbedingungen und Datenschutzrichtlinie",
        "es": "Términos de Servicio y Política de Privacidad",
        "fr": "Conditions Générales et Politique de Confidentialité",
        "it": "Termini di Servizio e Informativa sulla Privacy",
        "desc": "Terms link text"
    },
    "termsAcceptSuffix": {
        "en": ".",
        "tr": " okudum ve kabul ediyorum.",
        "de": " gelesen und stimme zu.",
        "es": ".",
        "fr": ".",
        "it": ".",
        "desc": "Terms checkbox suffix"
    },
    "thirtySeconds": {
        "en": "30s",
        "tr": "30 sn",
        "de": "30s",
        "es": "30s",
        "fr": "30s",
        "it": "30s",
        "desc": "30 seconds duration"
    },
    "fifteenSeconds": {
        "en": "15s",
        "tr": "15 sn",
        "de": "15s",
        "es": "15s",
        "fr": "15s",
        "it": "15s",
        "desc": "15 seconds duration"
    },
    "twentySeconds": {
        "en": "20s",
        "tr": "20 sn",
        "de": "20s",
        "es": "20s",
        "fr": "20s",
        "it": "20s",
        "desc": "20 seconds duration"
    },
    "twentyFiveSeconds": {
        "en": "25s",
        "tr": "25 sn",
        "de": "25s",
        "es": "25s",
        "fr": "25s",
        "it": "25s",
        "desc": "25 seconds duration"
    },
    "eighteenSeconds": {
        "en": "18s",
        "tr": "18 sn",
        "de": "18s",
        "es": "18s",
        "fr": "18s",
        "it": "18s",
        "desc": "18 seconds duration"
    },
    "oneVsOneSoloOnline": {
        "en": "1v1 • Solo • Online",
        "tr": "1v1 • Solo • Online",
        "de": "1v1 • Solo • Online",
        "es": "1c1 • Solo • Online",
        "fr": "1v1 • Solo • En Ligne",
        "it": "1v1 • Solo • Online",
        "desc": "1v1 solo online mode label"
    },
    "higherLower": {
        "en": "Higher / Lower",
        "tr": "Higher / Lower",
        "de": "Höher / Tiefer",
        "es": "Mayor / Menor",
        "fr": "Plus Haut / Plus Bas",
        "it": "Più Alto / Più Basso",
        "desc": "Higher lower game mode tag"
    },
    "leagueLabel": {
        "en": "League",
        "tr": "Lig",
        "de": "Liga",
        "es": "Liga",
        "fr": "Ligue",
        "it": "Lega",
        "desc": "League metric label"
    },
    "streakLabel": {
        "en": "Streak",
        "tr": "Seri",
        "de": "Serie",
        "es": "Racha",
        "fr": "Série",
        "it": "Serie",
        "desc": "Streak metric label"
    },
    "streakMatchesCount": {
        "en": "{count} Matches",
        "tr": "{count} Maç",
        "de": "{count} Spiele",
        "es": "{count} Partidos",
        "fr": "{count} Matchs",
        "it": "{count} Partite",
        "desc": "Streak count suffix"
    },
    "completedBadge": {
        "en": "COMPLETED",
        "tr": "TAMAMLANDI",
        "de": "ABGESCHLOSSEN",
        "es": "COMPLETADO",
        "fr": "TERMINÉ",
        "it": "COMPLETATO",
        "desc": "Completed quest badge"
    },
    "rewardClaimed": {
        "en": "Claimed ✓",
        "tr": "Ödül Alındı ✓",
        "de": "Erhalten ✓",
        "es": "Reclamado ✓",
        "fr": "Récupéré ✓",
        "it": "Riscossa ✓",
        "desc": "Reward claimed button text"
    },
    "liveOneVsOne": {
        "en": "Live 1v1",
        "tr": "Canlı 1v1",
        "de": "Live 1v1",
        "es": "1c1 en Vivo",
        "fr": "1v1 en Direct",
        "it": "1v1 dal Vivo",
        "desc": "Live 1v1 action label"
    }
}

LOCALES = ["en", "tr", "de", "es", "fr", "it"]

def main():
    for loc in LOCALES:
        path = f"lib/l10n/app_{loc}.arb"
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)

        for key, info in NEW_TRANSLATIONS.items():
            data[key] = info[loc]
            if loc == "en":
                desc_obj = {"description": info["desc"]}
                if "{" in info["en"]:
                    desc_obj["placeholders"] = {"count": {"type": "int"}}
                data[f"@{key}"] = desc_obj

        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
        print(f"Updated {path} with {len(NEW_TRANSLATIONS)} new keys.")

if __name__ == "__main__":
    main()
