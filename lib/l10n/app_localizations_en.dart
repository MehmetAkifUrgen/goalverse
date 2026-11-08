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
}
