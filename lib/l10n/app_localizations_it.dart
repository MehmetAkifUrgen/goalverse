// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Goalverse';

  @override
  String get startGame => 'Inizia Partita';

  @override
  String get dailyChallenge => 'Sfida Giornaliera';

  @override
  String get leaderboard => 'Classifica';

  @override
  String get profile => 'Profilo';

  @override
  String get settings => 'Impostazioni';

  @override
  String get play => 'Gioca';

  @override
  String get quickMatch => 'Partita Veloce';

  @override
  String get createRoom => 'Crea Stanza';

  @override
  String get joinRoom => 'Entra nella Stanza';

  @override
  String get roomCode => 'Codice Stanza';

  @override
  String get copyCode => 'Copia Codice';

  @override
  String get guestLogin => 'Continua come Ospite';

  @override
  String get googleLogin => 'Accedi con Google';

  @override
  String get appleLogin => 'Accedi con Apple';

  @override
  String get emailSignIn => 'Accedi con Email';

  @override
  String get createAccount => 'Crea Account';

  @override
  String get login => 'Accedi';

  @override
  String get logout => 'Esci';

  @override
  String get linkAccount => 'Collega Account';

  @override
  String get cancel => 'Annulla';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Salva';

  @override
  String get close => 'Chiudi';

  @override
  String get submit => 'Invia';

  @override
  String get search => 'Cerca';

  @override
  String get searchPlayerHint => 'Cerca un giocatore...';

  @override
  String get noResults => 'Nessun risultato';

  @override
  String get correctAnswer => 'Corretto!';

  @override
  String get wrongAnswer => 'Risposta sbagliata';

  @override
  String get errorPlayerNotFound => 'Giocatore non trovato';

  @override
  String get errorInvalidPlayer => 'Selezione giocatore non valida';

  @override
  String get errorTimeExpired => 'Tempo scaduto';

  @override
  String get errorCellAlreadyUsed => 'Questa casella è già occupata';

  @override
  String get errorNotYourTurn => 'Non è il tuo turno';

  @override
  String get errorNetwork => 'Errore di rete. Riprova.';

  @override
  String get errorGameNotFound => 'Partita non trovata';

  @override
  String get errorOpponentDisconnected => 'L\'avversario si è disconnesso';

  @override
  String get errorServerError => 'Errore del server. Riprova più tardi.';

  @override
  String get errorPermissionDenied => 'Autorizzazione negata';

  @override
  String get won => 'Hai Vinto!';

  @override
  String get lost => 'Hai Perso';

  @override
  String get draw => 'Pareggio';

  @override
  String turnOf(String player) {
    return 'Turno di $player';
  }

  @override
  String get opponentSearching => 'Ricerca avversario...';

  @override
  String get waitingForOpponent => 'In attesa dell\'avversario...';

  @override
  String get gameStarted => 'Partita Iniziata';

  @override
  String get yourTurn => 'Il Tuo Turno';

  @override
  String get opponentTurn => 'Turno dell\'Avversario';

  @override
  String get timeLeft => 'Tempo Rimasto';

  @override
  String get score => 'Punteggio';

  @override
  String get wins => 'Vittorie';

  @override
  String get losses => 'Sconfitte';

  @override
  String get draws => 'Pareggi';

  @override
  String get gamesPlayed => 'Partite Giocate';

  @override
  String get winRate => 'Tasso di Vittoria';

  @override
  String get bestScore => 'Punteggio Migliore';

  @override
  String get currentStreak => 'Serie Attuale';

  @override
  String get rating => 'Valutazione';

  @override
  String get achievements => 'Obiettivi';

  @override
  String get firstWin => 'Prima Vittoria';

  @override
  String get wins10 => '10 Vittorie';

  @override
  String get wins100 => '100 Vittorie';

  @override
  String get perfectGame => 'Partita Perfetta';

  @override
  String get rarePlayer => 'Giocatore Raro';

  @override
  String get comeback => 'Rimonta';

  @override
  String get winStreak5 => 'Serie di 5';

  @override
  String get winStreak10 => 'Serie di 10';

  @override
  String get language => 'Lingua';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Scuro';

  @override
  String get lightMode => 'Chiaro';

  @override
  String get systemMode => 'Predefinito di Sistema';

  @override
  String get notifications => 'Notifiche';

  @override
  String get notificationsEnabled => 'Notifiche attive';

  @override
  String get notificationsDisabled => 'Notifiche disattivate';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difficile';

  @override
  String get difficulty => 'Difficoltà';

  @override
  String get noDailyChallenge =>
      'Oggi non è disponibile alcuna sfida giornaliera';

  @override
  String get dailyChallengeCompleted => 'Sfida giornaliera completata!';

  @override
  String get comeBackTomorrow => 'Torna domani per una nuova sfida';

  @override
  String get rank => 'Posizione';

  @override
  String get country => 'Paese';

  @override
  String get noFriends => 'Ancora nessun amico';

  @override
  String get filterAll => 'Tutti';

  @override
  String get global => 'Globale';

  @override
  String get friends => 'Amici';

  @override
  String get inviteFriend => 'Invita un Amico';

  @override
  String get share => 'Condividi';

  @override
  String get about => 'Informazioni';

  @override
  String get version => 'Versione';

  @override
  String get help => 'Aiuto';

  @override
  String get support => 'Supporto';

  @override
  String get privacy => 'Informativa sulla Privacy';

  @override
  String get terms => 'Termini di Servizio';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get hintEmail => 'Inserisci la tua email';

  @override
  String get hintPassword => 'Inserisci la tua password';

  @override
  String get errorInvalidEmail => 'Indirizzo email non valido';

  @override
  String get errorWrongPassword => 'Password errata';

  @override
  String get errorWeakPassword => 'La password è troppo debole';

  @override
  String get errorEmailAlreadyInUse => 'L\'email è già in uso';

  @override
  String get errorUserNotFound => 'Utente non trovato';

  @override
  String get errorUserDisabled => 'Questo account è stato disattivato';

  @override
  String get errorOperationNotAllowed => 'Operazione non consentita';

  @override
  String get errorTooManyRequests => 'Troppe richieste. Riprova più tardi';

  @override
  String get errorUnknown => 'Si è verificato un errore. Riprova';

  @override
  String get errorAborted => 'L\'accesso è stato annullato';

  @override
  String get linkAccountTitle => 'Rendi il tuo account permanente';

  @override
  String get linkAccountSubtitle =>
      'Collega il tuo account per salvare i progressi e non perdere mai i tuoi dati';

  @override
  String get accountLinkedSuccess => 'Account collegato con successo!';

  @override
  String get or => 'o';

  @override
  String get hello => 'Ciao';

  @override
  String get time => 'Tempo';

  @override
  String get passTurn => 'Passa';

  @override
  String passesRemaining(int count) {
    return 'Passaggi rimasti: $count';
  }

  @override
  String get noPassesLeft => 'Nessun passaggio rimasto!';

  @override
  String playerPassedTurn(String player) {
    return '$player ha passato il turno!';
  }

  @override
  String get offerDraw => 'Offri Pareggio';

  @override
  String drawOfferSent(int seconds) {
    return 'Offerta di pareggio inviata (${seconds}s)';
  }

  @override
  String drawOfferReceived(String player, int seconds) {
    return '$player offre il pareggio (${seconds}s)';
  }

  @override
  String get acceptDraw => 'Accetta';

  @override
  String get rejectDraw => 'Rifiuta';

  @override
  String get drawAcceptedMessage =>
      'Offerta di pareggio accettata! La partita è finita in pareggio.';

  @override
  String get drawRejectedMessage =>
      'Offerta di pareggio rifiutata. La partita continua!';

  @override
  String get drawOfferExpiredMessage => 'Offerta di pareggio scaduta (30s).';

  @override
  String drawOfferCooldownMessage(int seconds) {
    return 'Attendi ${seconds}s prima di offrire nuovamente il pareggio.';
  }

  @override
  String get matchHistoryTitle => 'Cronologia Partita';

  @override
  String get leagueLegend => 'Lega Leggenda';

  @override
  String get leagueElite => 'Lega Elite';

  @override
  String get leaguePro => 'Lega Pro';

  @override
  String get leagueStarter => 'Lega Iniziale';

  @override
  String get defaultCaptainName => 'Capitano Goalverse';

  @override
  String get seasonDerbyWeek => 'STAGIONE 1 SETTIMANA DEL DERBY';

  @override
  String get heroHeadline => 'Scendi in Campo,\nDimostra il tuo Sapere.';

  @override
  String get heroSubtitle =>
      'Allenati da solo, gioca 1v1 dal vivo o crea una stanza privata per sfidare gli amici nell\'universo calcistico di Goalverse.';

  @override
  String get soloPlay => 'Gioca da Solo';

  @override
  String get onlineMatch => 'Partita Online';

  @override
  String get createPrivateRoom => 'Crea Stanza';

  @override
  String get joinWithCode => 'Unisciti con Codice';

  @override
  String get featuredModes => 'Modalità in Evidenza';

  @override
  String get featuredModesSubtitle => 'Esperienze competitive Goalverse';

  @override
  String get badgePopular => 'POPOLARE';

  @override
  String get sosCardSubtitle =>
      'Trova le stelle condivise nella griglia 3×3 e completa il tris.';

  @override
  String get playNow => 'Gioca Ora';

  @override
  String get ratingBattleSubtitle =>
      'Scegli la carta superiore per valutazione generale, valore o gol.';

  @override
  String get arcadeModes => 'Modalità Arcade';

  @override
  String get arcadeModesSubtitle =>
      'Metti alla prova la tua cultura calcistica con regole diverse';

  @override
  String get badgeModesCount => '5 MODALITÀ';

  @override
  String get twoTeamsTitle => '2 Club 1 Giocatore';

  @override
  String get twoTeamsSubtitle =>
      'Trova la stella che ha giocato per entrambi i club.';

  @override
  String get twoTeamsStatus => 'Stella Comune';

  @override
  String get whoAmITitle => 'Chi sono?';

  @override
  String get whoAmISubtitle =>
      'Indovina la leggenda con 5 indizi di carriera dal più difficile al più facile.';

  @override
  String get whoAmIStatus => 'Carta Misteriosa';

  @override
  String get fiveClues => '5 Indizi';

  @override
  String get imposterTitle => 'Impostore';

  @override
  String get imposterSubtitle =>
      'Smaschera l\'impostore che non ha mai giocato per il club bersaglio tra 4 giocatori.';

  @override
  String get imposterStatus => '1 Impostore';

  @override
  String get transferPathTitle => 'Percorso Trasferimenti';

  @override
  String get transferPathSubtitle =>
      'Trova il giocatore seguendo la cronologia dei suoi club e stagioni.';

  @override
  String get transferPathStatus => 'Percorso di Carriera';

  @override
  String get threePlusClubs => '3+ Club';

  @override
  String get footballBombTitle => 'Bomba Calcio';

  @override
  String get footballBombSubtitle =>
      'Nomina un giocatore valido prima che la bomba esploda.';

  @override
  String get footballBombStatus => 'Conto alla Rovescia';

  @override
  String get partyModeLabel => '1-8G • Party';

  @override
  String get oneToTwoOnlineLabel => '1-2G • Online';

  @override
  String get roomPlayAction => 'Stanza';

  @override
  String get playAction => 'Gioca';

  @override
  String get dailyAndRanking => 'Missione Giornaliera & Classifica';

  @override
  String get dailyAndRankingSubtitle =>
      'Ottieni ricompense e sali sul podio globale';

  @override
  String get seasonOne => 'STAGIONE 1';

  @override
  String get activeQuest => 'MISSIONE ATTIVA';

  @override
  String get dailyChallengeSubtitle =>
      'Completa la griglia 3×3 di oggi per guadagnare ricompense extra.';

  @override
  String get startQuest => 'Inizia Missione';

  @override
  String get leaderboardSubtitle => 'Top 100 Globale & Podio Stagionale';

  @override
  String get rankElite => 'Elite';

  @override
  String get rankCaptain => 'Capitano';

  @override
  String get rankStar => 'Stella';

  @override
  String get youPlayerPrefix => 'Tu';

  @override
  String get navArena => 'ARENA';

  @override
  String get navOnline => 'ONLINE';

  @override
  String get navDaily => 'GIORNALIERO';

  @override
  String get navRanking => 'CLASSIFICA';

  @override
  String get navProfile => 'PROFILO';

  @override
  String get forgotPasswordQuestion => 'Password dimenticata?';

  @override
  String get confirmPasswordLabel => 'Conferma Password';

  @override
  String get confirmPasswordHint => 'Reinserisci la tua password';

  @override
  String get termsAcceptPrefix => 'Ho letto e accetto i ';

  @override
  String get termsAcceptLink =>
      'Termini di Servizio e Informativa sulla Privacy';

  @override
  String get termsAcceptSuffix => '.';

  @override
  String get thirtySeconds => '30s';

  @override
  String get fifteenSeconds => '15s';

  @override
  String get twentySeconds => '20s';

  @override
  String get twentyFiveSeconds => '25s';

  @override
  String get eighteenSeconds => '18s';

  @override
  String get oneVsOneSoloOnline => '1v1 • Solo • Online';

  @override
  String get higherLower => 'Più Alto / Più Basso';

  @override
  String get leagueLabel => 'Lega';

  @override
  String get streakLabel => 'Serie';

  @override
  String streakMatchesCount(int count) {
    return '$count Partite';
  }

  @override
  String get completedBadge => 'COMPLETATO';

  @override
  String get rewardClaimed => 'Riscossa ✓';

  @override
  String get liveOneVsOne => '1v1 dal Vivo';

  @override
  String get difficultyAndControls => 'Difficoltà e Controlli';

  @override
  String turnDurationAndMultiplier(int seconds, String multiplier) {
    return 'Tempo: ${seconds}s • Moltiplicatore: ${multiplier}x';
  }

  @override
  String get hapticsTitle => 'Feedback Aptico (Vibrazione)';

  @override
  String get hapticsSubtitle =>
      'Feedback tattile su risposte corrette ed errate';

  @override
  String get soundEffectsTitle => 'Effetti Sonori';

  @override
  String get soundEffectsSubtitle =>
      'Atmosfera dello stadio ed effetti di gioco';

  @override
  String get sendPasswordResetLink => 'Invia link per reimpostare la password';

  @override
  String get deleteAccountPermanently => 'Elimina definitivamente l\'account';

  @override
  String get deleteAccountSubtitle =>
      'Elimina definitivamente il tuo profilo e il tuo account';

  @override
  String get deleteAccountWarning =>
      'Questa azione non può essere annullata. Il tuo punteggio ELO, cronologia partite e profilo saranno cancellati.';

  @override
  String get currentPasswordPrompt =>
      'Inserisci la tua password attuale per confermare';

  @override
  String get pleaseEnterPassword =>
      'Per favore inserisci la tua password attuale.';

  @override
  String get deleteAccountButton => 'Elimina Account';

  @override
  String get deletingAccount => 'Eliminazione...';

  @override
  String get liveMultiplayerLobby => 'Lobby Multigiocatore dal Vivo';

  @override
  String get lobbySubtitle =>
      'Partita Rapida • Stanza Privata • Codice a 6 Cifre';

  @override
  String get selectGameMode => 'Seleziona Modalità di Gioco';

  @override
  String get roomCodeMustBe6Digits =>
      'Inserisci il codice stanza completo a 6 cifre.';

  @override
  String get format3RoundsTitle => '3 ROUND – 2 VITTORIE';

  @override
  String get format3RoundsDesc =>
      'Massimo 3 round, chi ne vince 2 vince la partita';

  @override
  String get format5RoundsTitle => '5 ROUND – 3 VITTORIE';

  @override
  String get format5RoundsDesc =>
      'Massimo 5 round, chi ne vince 3 vince la partita';

  @override
  String get matchFormatSos => 'FORMATO PARTITA (SERIE FOOTBALL SOS)';

  @override
  String get searchingRoomsAndOpponent =>
      'Ricerca di stanze aperte e avversari...';

  @override
  String get matchRoomWaitingOpponent =>
      'Stanza Creata — In attesa dell\'avversario';

  @override
  String quickMatchPrompt(String mode) {
    return 'Unisciti all\'istante a una stanza aperta o avvia il matchmaking per $mode.';
  }

  @override
  String get startQuickMatch => 'Avvia Partita Rapida';

  @override
  String get preparingPrivateRoom =>
      'Creazione della stanza privata e dei dati partita...';

  @override
  String get shareRoomCodeWithFriend =>
      'Condividi il codice a 6 cifre con il tuo amico:';

  @override
  String createPrivateRoomPrompt(String mode) {
    return 'Crea una stanza privata a 6 cifre in $mode e invita il tuo amico.';
  }

  @override
  String get turnDuration => 'Tempo per Turno:';

  @override
  String get create6DigitPrivateRoom => 'Crea Stanza Privata a 6 Cifre';

  @override
  String roomCodeCopied(Object code) {
    return 'Codice stanza copiato: $code';
  }

  @override
  String get matchStartsWhenOpponentJoins =>
      'La partita inizia automaticamente quando entra l\'avversario...';

  @override
  String get enterRoomNowAction =>
      'Entra nella Stanza Ora (Si Connette dal Vivo)';

  @override
  String get enterFriendRoomCodePrompt =>
      'Inserisci il codice a 6 cifre condiviso dal tuo amico:';

  @override
  String get pasteFromClipboard => 'Incolla dagli Appunti';

  @override
  String get joinRoomAndStartMatch => 'Entra nella Stanza e Gioca';

  @override
  String get playSoloAction => 'Gioca da Solo';

  @override
  String get playSameDeviceAction => '2 Giocatori (Stesso Dispositivo)';

  @override
  String lockedFormatPrefix(int rounds, int wins) {
    return 'Formato: $rounds ROUND – $wins VITTORIE (Bloccato)';
  }

  @override
  String get duelMode2P => 'Duello 2G';

  @override
  String get duelMode1P => '1G Solo';

  @override
  String get onlineRoomLive => 'Stanza dal Vivo';

  @override
  String get onlineRoom => 'Stanza Online';

  @override
  String get turnP1 => 'Turno: G1';

  @override
  String get turnP2 => 'Turno: G2';

  @override
  String get duelDraw => 'Pareggio nel Duello';

  @override
  String get player1Won => 'Ha vinto il Giocatore 1';

  @override
  String get player2Won => 'Ha vinto il Giocatore 2';

  @override
  String get twoPlayerDuelResult => 'Risultato del Duello a 2 Giocatori';

  @override
  String get mainMenuButton => 'Menu Principale';

  @override
  String get playAgainButton => 'Gioca di Nuovo';

  @override
  String get noRankingPlayersYet =>
      'Nessun giocatore in classifica per ora. Sii il primo sul podio!';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get playerName => 'Nome Giocatore';

  @override
  String get countryFlag => 'Paese / Bandiera:';

  @override
  String get achievementFirstWinHowTo =>
      'Ottieni la tua prima vittoria in qualsiasi modalità.';

  @override
  String get achievementWins10HowTo => 'Vinci 10 partite in totale.';

  @override
  String get achievementWins100HowTo =>
      'Vinci 100 partite per diventare una leggenda.';

  @override
  String get achievementPerfectGameHowTo =>
      'Ottieni 900+ punti in una partita o indovina al 1° indizio in Chi sono!';

  @override
  String get achievementRarePlayerHowTo =>
      'Indovina un incrocio di club difficile con 4 o meno risposte possibili!';

  @override
  String get achievementComebackHowTo =>
      'Rimonta e vinci una partita di Football SOS dopo essere stato in svantaggio!';

  @override
  String get achievementStreak5HowTo => 'Vinci 5 partite consecutive.';

  @override
  String get achievementStreak10HowTo =>
      'Vinci 10 partite consecutive per una striscia invincibile.';

  @override
  String get timeExpired => '⏰ Tempo scaduto!';

  @override
  String get duelFinished => 'Duello terminato!';

  @override
  String get correctStreakLabel => 'Striscia di Risposte Esatte';

  @override
  String bestStreakStats(int best, int points) {
    return 'Miglior Striscia: $best • +$points Punti';
  }

  @override
  String get exitAction => 'Esci';

  @override
  String get seeAnswers => 'Vedi Risposte';

  @override
  String get nextMatch => 'Prossima Partita';

  @override
  String playerGuessedCorrect(int player, int points) {
    return '🎉 Il Giocatore $player ha indovinato! +$points Pti';
  }

  @override
  String greatGuessSolo(int points) {
    return '🎉 Ottima Risposta! +$points Pti';
  }

  @override
  String playedForBothClubs(String teamA, String teamB) {
    return 'ha giocato sia per $teamA che per $teamB!';
  }

  @override
  String dailyStageHeader(int stage) {
    return 'TAPPA $stage / 4 • 1.5x MOLTIPLICATORE TORNEO GIORNALIERO';
  }

  @override
  String get skipThisStage => 'Salta questa tappa ➔';

  @override
  String get dailyChallengeCompletedTitle => 'SFIDA GIORNALIERA COMPLETATA!';

  @override
  String get dailyChallengeCompletedDesc =>
      'Hai completato con successo tutte le tappe di oggi. Torna domani per nuove sfide!';

  @override
  String get claimDailyRewardAndExit =>
      'Riscatta la Ricompensa e Torna alla Home';

  @override
  String profileSemanticLabel(String name, int level) {
    return 'Profilo Giocatore: $name, Livello $level';
  }

  @override
  String leaderboardCardSemanticLabel(String title, int rating) {
    return '$title, Il tuo Punteggio: $rating ELO';
  }

  @override
  String get timeExpiredTurnPasses => '⏰ Tempo scaduto! Turno all\'avversario.';

  @override
  String roundStartedClubsReady(int round) {
    return '⚽ Round $round iniziato! Nuova griglia di club pronta.';
  }

  @override
  String botMadeMove(String player) {
    return '🤖 Il bot ha fatto la sua mossa: $player';
  }

  @override
  String get botPassedTurn => '🤖 Il bot ha passato il turno.';

  @override
  String get noMovesYet => 'Nessuna mossa ancora effettuata.';

  @override
  String verifiedPlayersForCell(int count) {
    return '$count calciatori verificati per questa casella:';
  }

  @override
  String playerDidNotPlayForBoth(String player) {
    return '❌ $player non ha giocato per entrambi i club! Turno passato.';
  }

  @override
  String get botWon => '🤖 Il Bot ha vinto!';

  @override
  String get player1WonX => '🏆 Il Giocatore 1 (X) ha vinto!';

  @override
  String get player2WonO => '🏆 Il Giocatore 2 (O) ha vinto!';

  @override
  String matchEndSummary(int total, int wins) {
    return 'FINE PARTITA • $total ROUND ($wins VITTORIE)';
  }

  @override
  String get roundsWon => 'Round Vinti';

  @override
  String get correctAnswers => 'Risposte Esatte';

  @override
  String get wrongAnswers => 'Errori';

  @override
  String get passesUsed => 'Passaggi Usati';

  @override
  String get matchDuration => 'Durata della Partita';

  @override
  String get eloChange => 'Variazione ELO';

  @override
  String get inspectBoardHint =>
      '💡 Consiglio: Chiudi questa finestra e tocca una casella per scoprire tutti i calciatori validi!';

  @override
  String get inspectBoard => 'Ispeziona Tabellone';

  @override
  String get footballSos2P => 'Football SOS • 2 Giocatori';

  @override
  String get selectMatchFormatTooltip => 'Seleziona Formato Partita';

  @override
  String get changeGameModeTooltip => 'Cambia Modalità';

  @override
  String get modeSoloVsBot => '🤖 Singolo (vs IA Intelligente)';

  @override
  String get mode2PlayerLocal => '👥 Duello a 2 Giocatori (Stesso Dispositivo)';

  @override
  String roundEndedInDraw(int round) {
    return 'ROUND $round FINITO IN PAREGGIO';
  }

  @override
  String nextRoundBanner(int round, int wins) {
    return 'Prossimo: ROUND $round (Chi raggiunge $wins vittorie vince la sfida)';
  }

  @override
  String startNextRound(int round) {
    return 'Inizia Round $round';
  }

  @override
  String get scoreboardYou => 'TU';

  @override
  String get scoreboardBot => 'BOT';

  @override
  String get scoreboardPlayer1 => 'GIOCATORE 1';

  @override
  String get scoreboardPlayer2 => 'GIOCATORE 2';

  @override
  String get scoreboardFinished => 'FINITO';

  @override
  String get scoreboardDraw => 'PARI';

  @override
  String get scoreboardAiThinking => 'L\'IA PENSA';

  @override
  String get scoreboardTurnX => 'TURNO: X';

  @override
  String get scoreboardTurnO => 'TURNO: O';

  @override
  String get cellActionSelect => 'SCEGLI';

  @override
  String get cellActionView => 'VEDI';

  @override
  String get leaveMatchTitle => 'Abbandonare la Partita?';

  @override
  String get leaveMatchConfirm =>
      'Sei sicuro di voler abbandonare la partita multigiocatore in corso?';

  @override
  String get continueMatch => 'Continua Partita';

  @override
  String get leaveMatch => 'Abbandona';

  @override
  String congratsMatchWon(int wins) {
    return 'Congratulazioni! Hai raggiunto $wins vittorie e vinto la partita!';
  }

  @override
  String get seriesDraw => 'La serie è terminata in parità.';

  @override
  String opponentMatchWon(String opponent, int wins) {
    return '$opponent ha raggiunto $wins vittorie e vinto la partita.';
  }

  @override
  String get connectingToLiveMatch => 'Connessione alla partita in diretta...';

  @override
  String roundCompletedNewStarting(int round) {
    return 'ROUND $round COMPLETATO • NUOVO ROUND INIZIATO';
  }

  @override
  String get yourTurnSelectCell => 'IL TUO TURNO! Seleziona una casella';

  @override
  String opponentThinking(String name) {
    return 'L\'avversario sta pensando ($name)...';
  }

  @override
  String get boardFullNoSeries =>
      'Tabellone pieno, nessun giocatore ha realizzato un tris.';

  @override
  String loserOpponentAhead(String opponent) {
    return 'Sconfitto del round: $opponent • Sei in vantaggio nella serie!';
  }

  @override
  String loserYouTieNext(String me) {
    return 'Sconfitto del round: $me • Pareggia i conti nel prossimo round!';
  }

  @override
  String nextRoundCountdown(int round, int seconds) {
    return 'Prossimo: ROUND $round (${seconds}s)';
  }

  @override
  String get boardLoadFailed => 'Impossibile caricare il tabellone.';

  @override
  String get roundLabel => 'Round';

  @override
  String get newGrid => 'Nuova Griglia';

  @override
  String get opponentLabel => 'Avversario';

  @override
  String get onlineMatchConnecting => 'Connessione alla stanza live...';

  @override
  String liveRoomTitle(Object code) {
    return 'STANZA LIVE #$code';
  }

  @override
  String get waitingOpponent => '⏳ In attesa dell\'avversario';

  @override
  String get opponentFinished => '✓ Avversario terminato';

  @override
  String opponentRound(Object round) {
    return '⚡ Avversario Round $round';
  }

  @override
  String get onlineVictoryTitle => '🏆 VITTORIA NEL DUELLO ONLINE!';

  @override
  String get onlineDrawTitle => '🤝 PAREGGIO PARTITA ONLINE!';

  @override
  String get onlineDefeatTitle => '💔 PARTITA ONLINE PERSA';

  @override
  String roomLiveScoreboard(Object code) {
    return 'Stanza #$code • Tabellone dal vivo';
  }

  @override
  String get changeNameAndFlag => 'Cambia nome e bandiera';

  @override
  String eloRatingBadge(Object rating) {
    return 'RATING ELO: $rating';
  }

  @override
  String get bestStreak => 'Miglior striscia';

  @override
  String achievementUnlockedDesc(Object desc) {
    return '✅ Sbloccato!\n\n$desc';
  }

  @override
  String achievementLockedDesc(Object desc) {
    return '🔒 Ancora bloccato.\n\nCome sbloccare: $desc';
  }

  @override
  String get totalPassCount => 'Passaggi totali usati';

  @override
  String get drawAgreements => 'Accordi di pareggio';

  @override
  String get matchHistoryCapacity => 'Capacità cronologia partite';

  @override
  String get correctPredictionStreak => 'Striscia di risposte esatte';

  @override
  String get peakMarketValue => 'Valore di mercato record';

  @override
  String get careerGoals => 'Gol in carriera';

  @override
  String get careerAssists => 'Assist in carriera';

  @override
  String get sprintSpeedRating => 'Velocità / Valutazione sprint';

  @override
  String get championsLeagueGoals => 'Gol in Champions League';

  @override
  String get playerAge => 'Età del giocatore';

  @override
  String comparedStat(Object stat) {
    return 'STATISTICA CONFRONTATA: $stat';
  }

  @override
  String get correctGuess => 'INDOVINATO!';

  @override
  String get wrongGuess => 'SBAGLIATO';

  @override
  String get higher => 'Più alto';

  @override
  String get lower => 'Più basso';

  @override
  String get correctTransferPath => '🎯 Percorso di trasferimento corretto!';

  @override
  String earnedPoints(Object points) {
    return 'Hai guadagnato +$points punti!';
  }

  @override
  String wrongPlayerNextTurn(Object name, Object player) {
    return '❌ Non è $name! Tocca al Giocatore $player.';
  }

  @override
  String wrongPlayerCheckHistory(Object name) {
    return '❌ Non è $name! Ricontrolla la storia dei club.';
  }

  @override
  String get answerRevealed => '🏳️ Risposta rivelata';

  @override
  String get transferPathOwner =>
      'Proprietario di questa carriera di trasferimenti:';

  @override
  String get nextCareerPath => 'Prossimo percorso ➔';

  @override
  String get transferPathQuestion =>
      'A quale calciatore appartiene questa cronologia di trasferimenti?';

  @override
  String cluePositionAndCountry(Object country, Object pos) {
    return '💡 Indizio: Ruolo $pos • Paese $country';
  }

  @override
  String get presentDay => 'Presente';

  @override
  String clubsCountLabel(Object count) {
    return '$count Club';
  }

  @override
  String get hintPenalty => 'Indizio (-150p)';

  @override
  String get whoAmIBullseye => '🎯 BERSAGLIO!';

  @override
  String get potentialPoints => 'Ricompensa potenziale:';

  @override
  String get lockedClue => '🔒 Indizio bloccato';

  @override
  String unlockNextClueRemaining(Object count) {
    return 'Sblocca prossimo indizio (Mancano: $count)';
  }

  @override
  String get unlockNextClue => 'Sblocca prossimo indizio';

  @override
  String get twoTeamsPrompt =>
      'Trova il calciatore che ha giocato in entrambi i club!';

  @override
  String twoTeamsDatabaseCandidates(Object count) {
    return 'Ci sono $count stelle nel database che hanno giocato per entrambi i club';
  }

  @override
  String selectPlayerPlayerTurn(Object player) {
    return 'Giocatore $player: Seleziona giocatore';
  }

  @override
  String get searchAndSelectPlayer => 'Cerca e seleziona calciatore';

  @override
  String get showAnswers => 'Mostra risposte';

  @override
  String get passRound => 'Passa turno';

  @override
  String get newMatchup => 'Nuova sfida';

  @override
  String get bombExplodedTitle => '💥 BOOM! La bomba è esplosa!';

  @override
  String bombWonTitle(Object winner) {
    return '🏆 $winner ha vinto!';
  }

  @override
  String bombEliminatedDesc(Object player) {
    return 'La bomba è esplosa in mano a $player ed è stato ELIMINATO!';
  }

  @override
  String totalSuccessfulPasses(Object count) {
    return 'Totale passaggi riusciti: $count';
  }

  @override
  String get playerCount => 'Numero di giocatori';

  @override
  String get bombPassAction => 'Nomina un giocatore e passa la bomba!';

  @override
  String imposterCaughtTitle(Object points) {
    return '🕵️ Impostore smascherato! +$points punti';
  }

  @override
  String get imposterWrongSuspect => '❌ Sospettato errato!';

  @override
  String get imposterPrompt =>
      'Seleziona il calciatore che non ha MAI giocato in questo club:';

  @override
  String get imposterBadgeNeverPlayed => '🕵️ IMPOSTORE! Non ha mai giocato';

  @override
  String get dailyStage1 => '⚡ Fase 1: 2 Squadre 1 Giocatore';

  @override
  String get dailyStage2 => '🧩 Fase 2: Chi sono?';

  @override
  String get dailyStage3 => '🕵️ Fase 3: Trova l\'impostore';

  @override
  String get dailyStage4 => '✈️ Fase 4: Percorso trasferimenti';

  @override
  String get dailyCompletedTournaments => '📅 TORNEI GIORNALIERI COMPLETATI';

  @override
  String get searchAndSubmitPlayer => 'Cerca e invia calciatore';

  @override
  String twoTeamsPlayedBoth(Object teamA, Object teamB) {
    return 'ha giocato sia per $teamA che per $teamB!';
  }

  @override
  String twoTeamsWrongBoth(Object name, Object teamA, Object teamB) {
    return '❌ $name non ha giocato per entrambi i club!';
  }

  @override
  String feedbackDrawProposed(Object user) {
    return '$user ha proposto un pareggio.';
  }

  @override
  String get feedbackDrawRejected =>
      'Proposta di pareggio rifiutata. La partita continua!';

  @override
  String get feedbackDrawTimeout => 'Offerta di pareggio scaduta (30s).';

  @override
  String feedbackPassed(Object user) {
    return '$user ha passato! Tocca all\'avversario.';
  }

  @override
  String get feedbackTimeExpired => 'Tempo scaduto! Tocca all\'avversario.';

  @override
  String get giveUpAction => 'Arrendersi';

  @override
  String get clubLabel => 'Club';

  @override
  String get statisticsTitle => 'STATISTICHE';

  @override
  String get playerDefault => 'Giocatore';

  @override
  String get guessMysteryPlayer => 'Indovina il calciatore misterioso';

  @override
  String get secondsSuffix => 's';

  @override
  String whichPlayerNeverPlayedFor(String team) {
    return 'Quale giocatore non ha MAI giocato nel $team?';
  }

  @override
  String neverPlayedForTeamExplanation(
    String player,
    String team,
    String clubs,
  ) {
    return '$player non ha mai giocato per il $team in carriera (Squadre: $clubs).';
  }

  @override
  String get popularSearches => 'Ricerche Popolari';

  @override
  String get cellLabel => 'CASELLA';

  @override
  String get selectedCellLabel => 'CASELLA SELEZIONATA';

  @override
  String bombNamePlayerForTeam(String team) {
    return 'Nomina un calciatore che ha giocato per il $team!';
  }

  @override
  String bombNamePlayerFromNationality(String nat) {
    return 'Nomina un calciatore proveniente da $nat!';
  }

  @override
  String get bombNameAnyPlayer =>
      'Nomina un qualsiasi calciatore dal database!';

  @override
  String clueNationalityPosition(String nat, String pos) {
    return 'Nazionalità: $nat | Ruolo: $pos';
  }

  @override
  String clueCareerStats(String goals, String assists, String ovr) {
    return 'Ha collezionato $goals gol e $assists assist in carriera (Totale: $ovr).';
  }

  @override
  String clueClubsPlayed(String clubs) {
    return 'Squadre in cui ha giocato: $clubs';
  }

  @override
  String clueInitialsAndLength(String initials, String letters) {
    return 'Iniziali: $initials ($letters lettere)';
  }

  @override
  String get helpGameModesContent =>
      'Football SOS • 7 Modalità di Gioco:\n\n• Football SOS: Griglia 3x3 (vs Bot, Duello 2P e Online)\n• Rating Battle: Serie 1P e Duello 2P\n• 2 Squadre 1 Giocatore: Trova il giocatore comune\n• Chi Sono?: Indovina il calciatore con 5 indizi\n• Impostore: Trova il giocatore che non ha mai giocato nel club\n• Percorso di Trasferimento: Indovina il giocatore dalla carriera\n• Bomba di Calcio: Passa la bomba prima dell\'esplosione!';

  @override
  String get errorTitle => 'Errore';

  @override
  String get winnerTitle => 'Vincitore';
}
