// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Goalverse';

  @override
  String get startGame => 'Start Game';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get play => 'Play';

  @override
  String get quickMatch => 'Quick Match';

  @override
  String get createRoom => 'Create Room';

  @override
  String get joinRoom => 'Join Room';

  @override
  String get roomCode => 'Room Code';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get guestLogin => 'Continue as Guest';

  @override
  String get googleLogin => 'Sign in with Google';

  @override
  String get appleLogin => 'Sign in with Apple';

  @override
  String get emailSignIn => 'Sign in with Email';

  @override
  String get createAccount => 'Create Account';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get linkAccount => 'Link Account';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get submit => 'Submit';

  @override
  String get search => 'Search';

  @override
  String get searchPlayerHint => 'Search for a player...';

  @override
  String get noResults => 'No results found';

  @override
  String get correctAnswer => 'Correct!';

  @override
  String get wrongAnswer => 'Wrong answer';

  @override
  String get errorPlayerNotFound => 'Player not found';

  @override
  String get errorInvalidPlayer => 'Invalid player selection';

  @override
  String get errorTimeExpired => 'Time is up';

  @override
  String get errorCellAlreadyUsed => 'This cell is already taken';

  @override
  String get errorNotYourTurn => 'It is not your turn';

  @override
  String get errorNetwork => 'Network error. Please try again.';

  @override
  String get errorGameNotFound => 'Game not found';

  @override
  String get errorOpponentDisconnected => 'Opponent disconnected';

  @override
  String get errorServerError => 'Server error. Please try again later.';

  @override
  String get errorPermissionDenied => 'Permission denied';

  @override
  String get won => 'You Won!';

  @override
  String get lost => 'You Lost';

  @override
  String get draw => 'Draw';

  @override
  String turnOf(String player) {
    return '$player\'s Turn';
  }

  @override
  String get opponentSearching => 'Finding an opponent...';

  @override
  String get waitingForOpponent => 'Waiting for opponent...';

  @override
  String get gameStarted => 'Game Started';

  @override
  String get yourTurn => 'Your Turn';

  @override
  String get opponentTurn => 'Opponent\'s Turn';

  @override
  String get timeLeft => 'Time Left';

  @override
  String get score => 'Score';

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get draws => 'Draws';

  @override
  String get gamesPlayed => 'Games Played';

  @override
  String get winRate => 'Win Rate';

  @override
  String get bestScore => 'Best Score';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get rating => 'Rating';

  @override
  String get achievements => 'Achievements';

  @override
  String get firstWin => 'First Victory';

  @override
  String get wins10 => '10 Wins';

  @override
  String get wins100 => '100 Wins';

  @override
  String get perfectGame => 'Perfect Game';

  @override
  String get rarePlayer => 'Rare Player';

  @override
  String get comeback => 'Comeback Kid';

  @override
  String get winStreak5 => '5-Game Streak';

  @override
  String get winStreak10 => '10-Game Streak';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark';

  @override
  String get lightMode => 'Light';

  @override
  String get systemMode => 'System Default';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Notifications are enabled';

  @override
  String get notificationsDisabled => 'Notifications are disabled';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get noDailyChallenge => 'No daily challenge available today';

  @override
  String get dailyChallengeCompleted => 'Daily challenge completed!';

  @override
  String get comeBackTomorrow => 'Come back tomorrow for a new challenge';

  @override
  String get rank => 'Rank';

  @override
  String get country => 'Country';

  @override
  String get noFriends => 'No friends yet';

  @override
  String get filterAll => 'All';

  @override
  String get global => 'Global';

  @override
  String get friends => 'Friends';

  @override
  String get inviteFriend => 'Invite Friend';

  @override
  String get share => 'Share';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get help => 'Help';

  @override
  String get support => 'Support';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get terms => 'Terms of Service';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get hintEmail => 'Enter your email';

  @override
  String get hintPassword => 'Enter your password';

  @override
  String get errorInvalidEmail => 'Invalid email address';

  @override
  String get errorWrongPassword => 'Wrong password';

  @override
  String get errorWeakPassword => 'Password is too weak';

  @override
  String get errorEmailAlreadyInUse => 'Email is already in use';

  @override
  String get errorUserNotFound => 'User not found';

  @override
  String get errorUserDisabled => 'This account has been disabled';

  @override
  String get errorOperationNotAllowed => 'Operation not allowed';

  @override
  String get errorTooManyRequests =>
      'Too many requests. Please try again later';

  @override
  String get errorUnknown => 'An error occurred. Please try again';

  @override
  String get errorAborted => 'Sign in was cancelled';

  @override
  String get linkAccountTitle => 'Make your account permanent';

  @override
  String get linkAccountSubtitle =>
      'Link your account to save progress and never lose your data';

  @override
  String get accountLinkedSuccess => 'Account linked successfully!';

  @override
  String get or => 'or';

  @override
  String get hello => 'Hello';

  @override
  String get time => 'Time';

  @override
  String get passTurn => 'Pass';

  @override
  String passesRemaining(int count) {
    return 'Passes Left: $count';
  }

  @override
  String get noPassesLeft => 'No passes left!';

  @override
  String playerPassedTurn(String player) {
    return '$player passed their turn!';
  }

  @override
  String get offerDraw => 'Offer Draw';

  @override
  String drawOfferSent(int seconds) {
    return 'Draw offer sent (${seconds}s)';
  }

  @override
  String drawOfferReceived(String player, int seconds) {
    return '$player offers a draw (${seconds}s)';
  }

  @override
  String get acceptDraw => 'Accept';

  @override
  String get rejectDraw => 'Decline';

  @override
  String get drawAcceptedMessage =>
      'Draw offer accepted! The match ended in a draw.';

  @override
  String get drawRejectedMessage => 'Draw offer declined. The match continues!';

  @override
  String get drawOfferExpiredMessage => 'Draw offer expired (30s).';

  @override
  String drawOfferCooldownMessage(int seconds) {
    return 'Wait ${seconds}s before offering a draw again.';
  }

  @override
  String get matchHistoryTitle => 'Match History';

  @override
  String get leagueLegend => 'Legend League';

  @override
  String get leagueElite => 'Elite League';

  @override
  String get leaguePro => 'Pro League';

  @override
  String get leagueStarter => 'Starter League';

  @override
  String get defaultCaptainName => 'Goalverse Captain';

  @override
  String get seasonDerbyWeek => 'SEASON 1 DERBY WEEK';

  @override
  String get heroHeadline => 'Step onto the Pitch,\nProve Your Knowledge.';

  @override
  String get heroSubtitle =>
      'Practice solo, dive into live 1v1 matchmaking, or create a private room to duel friends in the Goalverse football gaming universe.';

  @override
  String get soloPlay => 'Play Solo';

  @override
  String get onlineMatch => 'Online Match';

  @override
  String get createPrivateRoom => 'Create Room';

  @override
  String get joinWithCode => 'Join with Code';

  @override
  String get featuredModes => 'Featured Modes';

  @override
  String get featuredModesSubtitle =>
      'Signature Goalverse competitive experiences';

  @override
  String get badgePopular => 'POPULAR';

  @override
  String get sosCardSubtitle =>
      'Find shared stars in the 3×3 club grid and complete a three-in-a-row.';

  @override
  String get playNow => 'Play Now';

  @override
  String get ratingBattleSubtitle =>
      'Pick the card with superior overall, market value, or career goals.';

  @override
  String get arcadeModes => 'Arcade Modes';

  @override
  String get arcadeModesSubtitle =>
      'Test your football culture with distinct rules';

  @override
  String get badgeModesCount => '5 MODES';

  @override
  String get twoTeamsTitle => '2 Clubs 1 Player';

  @override
  String get twoTeamsSubtitle =>
      'Find the shared star footballer who played for both clubs.';

  @override
  String get twoTeamsStatus => 'Shared Star';

  @override
  String get whoAmITitle => 'Who Am I?';

  @override
  String get whoAmISubtitle =>
      'Guess the secret legend with 5 career clues revealed from hard to easy.';

  @override
  String get whoAmIStatus => 'Mystery Card';

  @override
  String get fiveClues => '5 Clues';

  @override
  String get imposterTitle => 'Imposter';

  @override
  String get imposterSubtitle =>
      'Catch the imposter who never played for the target club among 4 players.';

  @override
  String get imposterStatus => '1 Imposter';

  @override
  String get transferPathTitle => 'Transfer Path';

  @override
  String get transferPathSubtitle =>
      'Find the player by following their chronological club history and seasons.';

  @override
  String get transferPathStatus => 'Career Route';

  @override
  String get threePlusClubs => '3+ Clubs';

  @override
  String get footballBombTitle => 'Football Bomb';

  @override
  String get footballBombSubtitle =>
      'Name a player matching the club or country criteria before the bomb explodes.';

  @override
  String get footballBombStatus => 'Countdown';

  @override
  String get partyModeLabel => '1-8P • Party';

  @override
  String get oneToTwoOnlineLabel => '1-2P • Online';

  @override
  String get roomPlayAction => 'Room';

  @override
  String get playAction => 'Play';

  @override
  String get dailyAndRanking => 'Daily Quest & Ranking';

  @override
  String get dailyAndRankingSubtitle =>
      'Claim rewards, rise to the global podium';

  @override
  String get seasonOne => 'SEASON 1';

  @override
  String get activeQuest => 'ACTIVE QUEST';

  @override
  String get dailyChallengeSubtitle =>
      'Complete today\'s 3×3 grid to earn extra rewards.';

  @override
  String get startQuest => 'Start Quest';

  @override
  String get leaderboardSubtitle => 'Global Top 100 & Season Podium';

  @override
  String get rankElite => 'Elite';

  @override
  String get rankCaptain => 'Captain';

  @override
  String get rankStar => 'Star';

  @override
  String get youPlayerPrefix => 'You';

  @override
  String get navArena => 'ARENA';

  @override
  String get navOnline => 'ONLINE';

  @override
  String get navDaily => 'DAILY';

  @override
  String get navRanking => 'RANKING';

  @override
  String get navProfile => 'PROFILE';

  @override
  String get forgotPasswordQuestion => 'Forgot Password?';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get termsAcceptPrefix => 'I have read and accept the ';

  @override
  String get termsAcceptLink => 'Terms of Service and Privacy Policy';

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
  String get higherLower => 'Higher / Lower';

  @override
  String get leagueLabel => 'League';

  @override
  String get streakLabel => 'Streak';

  @override
  String streakMatchesCount(int count) {
    return '$count Matches';
  }

  @override
  String get completedBadge => 'COMPLETED';

  @override
  String get rewardClaimed => 'Claimed ✓';

  @override
  String get liveOneVsOne => 'Live 1v1';

  @override
  String get difficultyAndControls => 'Difficulty & Controls';

  @override
  String turnDurationAndMultiplier(int seconds, String multiplier) {
    return 'Time: ${seconds}s • Multiplier: ${multiplier}x';
  }

  @override
  String get hapticsTitle => 'Haptic Feedback (Vibration)';

  @override
  String get hapticsSubtitle => 'Tactile feedback on correct and wrong guesses';

  @override
  String get soundEffectsTitle => 'Sound Effects';

  @override
  String get soundEffectsSubtitle =>
      'Stadium atmosphere and in-game sound effects';

  @override
  String get sendPasswordResetLink => 'Send Password Reset Link';

  @override
  String get deleteAccountPermanently => 'Delete Account Permanently';

  @override
  String get deleteAccountSubtitle =>
      'Permanently erase your profile data and account';

  @override
  String get deleteAccountWarning =>
      'This action cannot be undone. Your ELO rating, match history, and user profile will be permanently erased.';

  @override
  String get currentPasswordPrompt => 'Enter your current password to confirm';

  @override
  String get pleaseEnterPassword => 'Please enter your current password.';

  @override
  String get deleteAccountButton => 'Delete Account';

  @override
  String get deletingAccount => 'Deleting...';

  @override
  String get liveMultiplayerLobby => 'Live Multiplayer Lobby';

  @override
  String get lobbySubtitle => 'Quick Match • Private Room • 6-Digit Code';

  @override
  String get selectGameMode => 'Select Game Mode';

  @override
  String get roomCodeMustBe6Digits =>
      'Please enter the complete 6-digit room code.';

  @override
  String get format3RoundsTitle => '3 ROUNDS – 2 WINS';

  @override
  String get format3RoundsDesc =>
      'Best of 3 rounds, first to 2 wins takes the match';

  @override
  String get format5RoundsTitle => '5 ROUNDS – 3 WINS';

  @override
  String get format5RoundsDesc =>
      'Best of 5 rounds, first to 3 wins takes the match';

  @override
  String get matchFormatSos => 'MATCH FORMAT (FOOTBALL SOS SERIES)';

  @override
  String get searchingRoomsAndOpponent =>
      'Searching for open rooms and opponents...';

  @override
  String get matchRoomWaitingOpponent =>
      'Match Room Created — Waiting for Opponent';

  @override
  String quickMatchPrompt(String mode) {
    return 'Instantly join an open room or enter matchmaking for $mode.';
  }

  @override
  String get startQuickMatch => 'Start Quick Match';

  @override
  String get preparingPrivateRoom => 'Preparing private room and match data...';

  @override
  String get shareRoomCodeWithFriend =>
      'Share the 6-Digit Code with your Friend:';

  @override
  String createPrivateRoomPrompt(String mode) {
    return 'Create a 6-digit private room in $mode and invite your friend.';
  }

  @override
  String get turnDuration => 'Turn Duration:';

  @override
  String get create6DigitPrivateRoom => 'Create 6-Digit Private Room';

  @override
  String roomCodeCopied(Object code) {
    return 'Room code copied: $code';
  }

  @override
  String get matchStartsWhenOpponentJoins =>
      'Match starts automatically when opponent joins...';

  @override
  String get enterRoomNowAction =>
      'Enter Room Now (Connects Live When Opponent Joins)';

  @override
  String get enterFriendRoomCodePrompt =>
      'Enter the 6-digit room code shared by your friend:';

  @override
  String get pasteFromClipboard => 'Paste from Clipboard';

  @override
  String get joinRoomAndStartMatch => 'Join Room & Start Match';

  @override
  String get playSoloAction => 'Play Solo';

  @override
  String get playSameDeviceAction => '2 Players (Same Device)';

  @override
  String lockedFormatPrefix(int rounds, int wins) {
    return 'Format: $rounds ROUNDS – $wins WINS (Locked)';
  }

  @override
  String get duelMode2P => '2P Duel';

  @override
  String get duelMode1P => '1P Solo';

  @override
  String get onlineRoomLive => 'Live Room';

  @override
  String get onlineRoom => 'Online Room';

  @override
  String get turnP1 => 'Turn: P1';

  @override
  String get turnP2 => 'Turn: P2';

  @override
  String get duelDraw => 'Duel Draw';

  @override
  String get player1Won => 'Player 1 Won';

  @override
  String get player2Won => 'Player 2 Won';

  @override
  String get twoPlayerDuelResult => '2 Player Duel Result';

  @override
  String get mainMenuButton => 'Main Menu';

  @override
  String get playAgainButton => 'Play Again';

  @override
  String get noRankingPlayersYet =>
      'No competitors on the leaderboard yet. Be the first to claim the podium!';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get playerName => 'Player Name';

  @override
  String get countryFlag => 'Country / Flag:';

  @override
  String get achievementFirstWinHowTo =>
      'Earn your first victory in any game mode.';

  @override
  String get achievementWins10HowTo => 'Win 10 total matches.';

  @override
  String get achievementWins100HowTo =>
      'Win 100 total matches to become a legend.';

  @override
  String get achievementPerfectGameHowTo =>
      'Score 900+ points in a single match or guess on the 1st clue in Who Am I!';

  @override
  String get achievementRarePlayerHowTo =>
      'Correctly guess a difficult club intersection with 4 or fewer possible answers!';

  @override
  String get achievementComebackHowTo =>
      'Come from behind to win a Football SOS match!';

  @override
  String get achievementStreak5HowTo => 'Win 5 matches in a row.';

  @override
  String get achievementStreak10HowTo =>
      'Win 10 matches in a row to forge an invincible streak.';

  @override
  String get timeExpired => '⏰ Time\'s Up!';

  @override
  String get duelFinished => 'Duel Finished!';

  @override
  String get correctStreakLabel => 'Correct Guess Streak';

  @override
  String bestStreakStats(int best, int points) {
    return 'Best Streak: $best • +$points Pts';
  }

  @override
  String get exitAction => 'Exit';

  @override
  String get seeAnswers => 'See Answers';

  @override
  String get nextMatch => 'Next Match';

  @override
  String playerGuessedCorrect(int player, int points) {
    return '🎉 Player $player Got It! +$points Pts';
  }

  @override
  String greatGuessSolo(int points) {
    return '🎉 Great Guess! +$points Pts';
  }

  @override
  String playedForBothClubs(String teamA, String teamB) {
    return 'played for both $teamA and $teamB!';
  }

  @override
  String dailyStageHeader(int stage) {
    return 'STAGE $stage / 4 • 1.5x DAILY TOURNAMENT MULTIPLIER';
  }

  @override
  String get skipThisStage => 'Skip This Stage ➔';

  @override
  String get dailyChallengeCompletedTitle => 'DAILY CHALLENGE COMPLETED!';

  @override
  String get dailyChallengeCompletedDesc =>
      'You successfully completed all stages for today. Return tomorrow for new challenges!';

  @override
  String get claimDailyRewardAndExit => 'Claim Reward & Return to Home';

  @override
  String profileSemanticLabel(String name, int level) {
    return 'Player Profile: $name, Level $level';
  }

  @override
  String leaderboardCardSemanticLabel(String title, int rating) {
    return '$title, Your Rating: $rating ELO';
  }

  @override
  String get timeExpiredTurnPasses =>
      '⏰ Time expired! Turn passed to opponent.';

  @override
  String roundStartedClubsReady(int round) {
    return '⚽ Round $round started! New club grid ready.';
  }

  @override
  String botMadeMove(String player) {
    return '🤖 Bot made a move: $player';
  }

  @override
  String get botPassedTurn => '🤖 Bot passed their turn.';

  @override
  String get noMovesYet => 'No moves made yet.';

  @override
  String verifiedPlayersForCell(int count) {
    return 'Verified $count players for this cell:';
  }

  @override
  String playerDidNotPlayForBoth(String player) {
    return '❌ $player did not play for both clubs! Turn passed.';
  }

  @override
  String get botWon => '🤖 Bot Won!';

  @override
  String get player1WonX => '🏆 Player 1 (X) Won!';

  @override
  String get player2WonO => '🏆 Player 2 (O) Won!';

  @override
  String matchEndSummary(int total, int wins) {
    return 'MATCH END • $total ROUNDS ($wins WINS)';
  }

  @override
  String get roundsWon => 'Rounds Won';

  @override
  String get correctAnswers => 'Correct Answers';

  @override
  String get wrongAnswers => 'Wrong Answers';

  @override
  String get passesUsed => 'Passes Used';

  @override
  String get matchDuration => 'Match Duration';

  @override
  String get eloChange => 'ELO Change';

  @override
  String get inspectBoardHint =>
      '💡 Tip: Close this dialog and tap any cell on the grid to inspect all verified valid footballers!';

  @override
  String get inspectBoard => 'Inspect Board';

  @override
  String get footballSos2P => 'Football SOS • 2 Players';

  @override
  String get selectMatchFormatTooltip => 'Select Match Format';

  @override
  String get changeGameModeTooltip => 'Change Game Mode';

  @override
  String get modeSoloVsBot => '🤖 Solo (vs Smart AI)';

  @override
  String get mode2PlayerLocal => '👥 2-Player Duel (Same Device)';

  @override
  String roundEndedInDraw(int round) {
    return 'ROUND $round ENDED IN A DRAW';
  }

  @override
  String nextRoundBanner(int round, int wins) {
    return 'Next: ROUND $round (First to $wins wins takes the match)';
  }

  @override
  String startNextRound(int round) {
    return 'Start Round $round';
  }

  @override
  String get scoreboardYou => 'YOU';

  @override
  String get scoreboardBot => 'BOT';

  @override
  String get scoreboardPlayer1 => 'PLAYER 1';

  @override
  String get scoreboardPlayer2 => 'PLAYER 2';

  @override
  String get scoreboardFinished => 'FINISHED';

  @override
  String get scoreboardDraw => 'DRAW';

  @override
  String get scoreboardAiThinking => 'AI THINKING';

  @override
  String get scoreboardTurnX => 'TURN: X';

  @override
  String get scoreboardTurnO => 'TURN: O';

  @override
  String get cellActionSelect => 'SELECT';

  @override
  String get cellActionView => 'VIEW';

  @override
  String get leaveMatchTitle => 'Leave Match?';

  @override
  String get leaveMatchConfirm =>
      'Are you sure you want to leave the active multiplayer match?';

  @override
  String get continueMatch => 'Continue Match';

  @override
  String get leaveMatch => 'Leave Match';

  @override
  String congratsMatchWon(int wins) {
    return 'Congratulations! You reached $wins wins and took the match!';
  }

  @override
  String get seriesDraw => 'The series ended in a draw.';

  @override
  String opponentMatchWon(String opponent, int wins) {
    return '$opponent reached $wins wins and took the match.';
  }

  @override
  String get connectingToLiveMatch => 'Connecting to live match...';

  @override
  String roundCompletedNewStarting(int round) {
    return 'ROUND $round COMPLETED • NEW ROUND STARTING';
  }

  @override
  String get yourTurnSelectCell => 'YOUR TURN! Select a cell';

  @override
  String opponentThinking(String name) {
    return 'Opponent is thinking ($name)...';
  }

  @override
  String get boardFullNoSeries =>
      'Grid is full, neither player achieved a 3-in-a-row.';

  @override
  String loserOpponentAhead(String opponent) {
    return 'Round Loser: $opponent • You took the lead in the series!';
  }

  @override
  String loserYouTieNext(String me) {
    return 'Round Loser: $me • Level the score in the next round!';
  }

  @override
  String nextRoundCountdown(int round, int seconds) {
    return 'Next: ROUND $round (${seconds}s)';
  }

  @override
  String get boardLoadFailed => 'Failed to load board.';

  @override
  String get roundLabel => 'Round';

  @override
  String get newGrid => 'New Grid';

  @override
  String get opponentLabel => 'Opponent';

  @override
  String get onlineMatchConnecting => 'Connecting to live room...';

  @override
  String liveRoomTitle(Object code) {
    return 'LIVE ROOM #$code';
  }

  @override
  String get waitingOpponent => '⏳ Waiting for Opponent';

  @override
  String get opponentFinished => '✓ Opponent Finished';

  @override
  String opponentRound(Object round) {
    return '⚡ Opponent Round $round';
  }

  @override
  String get onlineVictoryTitle => '🏆 ONLINE DUEL VICTORY!';

  @override
  String get onlineDrawTitle => '🤝 ONLINE MATCH DRAW!';

  @override
  String get onlineDefeatTitle => '💔 ONLINE MATCH LOST';

  @override
  String roomLiveScoreboard(Object code) {
    return 'Room #$code • Live Scoreboard';
  }

  @override
  String get changeNameAndFlag => 'Change Name & Flag';

  @override
  String eloRatingBadge(Object rating) {
    return '$rating ELO RATING';
  }

  @override
  String get bestStreak => 'Best Streak';

  @override
  String achievementUnlockedDesc(Object desc) {
    return '✅ Unlocked!\n\n$desc';
  }

  @override
  String achievementLockedDesc(Object desc) {
    return '🔒 Still locked.\n\nHow to unlock: $desc';
  }

  @override
  String get totalPassCount => 'Total Passes Used';

  @override
  String get drawAgreements => 'Draw Agreements';

  @override
  String get matchHistoryCapacity => 'Match History Capacity';

  @override
  String get correctPredictionStreak => 'Correct Guess Streak';

  @override
  String get peakMarketValue => 'Peak Market Value';

  @override
  String get careerGoals => 'Career Goals';

  @override
  String get careerAssists => 'Career Assists';

  @override
  String get sprintSpeedRating => 'Speed / Sprint Rating';

  @override
  String get championsLeagueGoals => 'Champions League Goals';

  @override
  String get playerAge => 'Player Age';

  @override
  String comparedStat(Object stat) {
    return 'COMPARED STAT: $stat';
  }

  @override
  String get correctGuess => 'CORRECT GUESS!';

  @override
  String get wrongGuess => 'WRONG GUESS';

  @override
  String get higher => 'Higher';

  @override
  String get lower => 'Lower';

  @override
  String get correctTransferPath => '🎯 Correct Transfer Path!';

  @override
  String earnedPoints(Object points) {
    return 'You earned +$points Points!';
  }

  @override
  String wrongPlayerNextTurn(Object name, Object player) {
    return '❌ Not $name! Turn passes to Player $player.';
  }

  @override
  String wrongPlayerCheckHistory(Object name) {
    return '❌ Not $name! Check the club history again.';
  }

  @override
  String get answerRevealed => '🏳️ Answer Revealed';

  @override
  String get transferPathOwner => 'Owner of this transfer history:';

  @override
  String get nextCareerPath => 'Next Career Path ➔';

  @override
  String get transferPathQuestion =>
      'Which footballer does this chronological transfer history belong to?';

  @override
  String cluePositionAndCountry(Object country, Object pos) {
    return '💡 Clue: Position $pos • Country $country';
  }

  @override
  String get presentDay => 'Present';

  @override
  String clubsCountLabel(Object count) {
    return '$count Clubs';
  }

  @override
  String get hintPenalty => 'Hint (-150p)';

  @override
  String get whoAmIBullseye => '🎯 BULLSEYE!';

  @override
  String get potentialPoints => 'Potential Reward:';

  @override
  String get lockedClue => '🔒 Locked Clue';

  @override
  String unlockNextClueRemaining(Object count) {
    return 'Unlock Next Clue ($count left)';
  }

  @override
  String get unlockNextClue => 'Unlock Next Clue';

  @override
  String get twoTeamsPrompt => 'Find the footballer who played for both clubs!';

  @override
  String twoTeamsDatabaseCandidates(Object count) {
    return 'There are $count stars in the database who played for both clubs';
  }

  @override
  String selectPlayerPlayerTurn(Object player) {
    return 'Player $player: Select Player';
  }

  @override
  String get searchAndSelectPlayer => 'Search & Select Player';

  @override
  String get showAnswers => 'Show Answers';

  @override
  String get passRound => 'Pass Turn';

  @override
  String get newMatchup => 'New Matchup';

  @override
  String get bombExplodedTitle => '💥 BOOM! Bomb Exploded!';

  @override
  String bombWonTitle(Object winner) {
    return '🏆 $winner Won!';
  }

  @override
  String bombEliminatedDesc(Object player) {
    return 'The bomb exploded while in $player\'s hands and was ELIMINATED!';
  }

  @override
  String totalSuccessfulPasses(Object count) {
    return 'Total Successful Passes: $count';
  }

  @override
  String get playerCount => 'Player Count';

  @override
  String get bombPassAction => 'Name a Player and Pass the Bomb!';

  @override
  String imposterCaughtTitle(Object points) {
    return '🕵️ Imposter Caught! +$points Points';
  }

  @override
  String get imposterWrongSuspect => '❌ Wrong Suspect!';

  @override
  String get imposterPrompt =>
      'Select the footballer who NEVER played for this club:';

  @override
  String get imposterBadgeNeverPlayed => '🕵️ IMPOSTER! Never Played';

  @override
  String get dailyStage1 => '⚡ Stage 1: 2 Teams 1 Player';

  @override
  String get dailyStage2 => '🧩 Stage 2: Who Am I?';

  @override
  String get dailyStage3 => '🕵️ Stage 3: Find the Imposter';

  @override
  String get dailyStage4 => '✈️ Stage 4: Transfer Path';

  @override
  String get dailyCompletedTournaments => '📅 COMPLETED DAILY TOURNAMENTS';

  @override
  String get searchAndSubmitPlayer => 'Search and Submit Player';

  @override
  String twoTeamsPlayedBoth(Object teamA, Object teamB) {
    return 'played for both $teamA and $teamB!';
  }

  @override
  String twoTeamsWrongBoth(Object name, Object teamA, Object teamB) {
    return '❌ $name did not play for both $teamA and $teamB!';
  }

  @override
  String feedbackDrawProposed(Object user) {
    return '$user proposed a draw.';
  }

  @override
  String get feedbackDrawRejected => 'Draw offer declined. Match continues!';

  @override
  String get feedbackDrawTimeout => 'Draw offer timed out (30s).';

  @override
  String feedbackPassed(Object user) {
    return '$user passed! Turn passes to opponent.';
  }

  @override
  String get feedbackTimeExpired => 'Time expired! Turn passed to opponent.';

  @override
  String get giveUpAction => 'Give Up';

  @override
  String get clubLabel => 'Club';

  @override
  String get statisticsTitle => 'STATISTICS';

  @override
  String get playerDefault => 'Player';

  @override
  String get guessMysteryPlayer => 'Guess Mystery Player';

  @override
  String get secondsSuffix => 's';
}
