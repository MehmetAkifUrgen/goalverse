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
}
