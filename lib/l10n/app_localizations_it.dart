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
}
