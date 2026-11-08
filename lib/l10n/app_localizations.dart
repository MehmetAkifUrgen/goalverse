import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('tr'),
  ];

  /// Application title displayed in the app bar and launcher
  ///
  /// In en, this message translates to:
  /// **'Goalverse'**
  String get appTitle;

  /// Button label to begin a new game
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// Menu item for the daily challenge mode
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// Menu item and page title for the leaderboard screen
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// Menu item and page title for the user profile screen
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Menu item and page title for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Generic button label to start playing
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Game mode to find a random opponent quickly
  ///
  /// In en, this message translates to:
  /// **'Quick Match'**
  String get quickMatch;

  /// Button to create a private multiplayer room
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoom;

  /// Button to join a private multiplayer room using a code
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get joinRoom;

  /// Label for the room code input field
  ///
  /// In en, this message translates to:
  /// **'Room Code'**
  String get roomCode;

  /// Button label to copy the room code to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// Button label for anonymous guest login
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get guestLogin;

  /// Button label for Google authentication
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleLogin;

  /// Button label for Apple authentication
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get appleLogin;

  /// Button label for email/password authentication
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get emailSignIn;

  /// Button label for new user registration
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Button label to sign in an existing user
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Button label to sign out the current user
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Button label to connect an additional auth provider
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get linkAccount;

  /// Button label to dismiss or cancel an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button label to confirm an action or dialog
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Button label to persist changes
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button label to close a dialog or screen
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button label to submit a form or answer
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Search button label and search bar hint title
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Placeholder text inside the player search input
  ///
  /// In en, this message translates to:
  /// **'Search for a player...'**
  String get searchPlayerHint;

  /// Message displayed when a search returns no matches
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Feedback shown when the user selects a correct answer
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correctAnswer;

  /// Feedback shown when the user selects an incorrect answer
  ///
  /// In en, this message translates to:
  /// **'Wrong answer'**
  String get wrongAnswer;

  /// Error message when a searched player does not exist
  ///
  /// In en, this message translates to:
  /// **'Player not found'**
  String get errorPlayerNotFound;

  /// Error message when the selected player is not valid for the turn
  ///
  /// In en, this message translates to:
  /// **'Invalid player selection'**
  String get errorInvalidPlayer;

  /// Error message when the turn timer reaches zero
  ///
  /// In en, this message translates to:
  /// **'Time is up'**
  String get errorTimeExpired;

  /// Error message when tapping an occupied board cell
  ///
  /// In en, this message translates to:
  /// **'This cell is already taken'**
  String get errorCellAlreadyUsed;

  /// Error message when a player acts out of turn
  ///
  /// In en, this message translates to:
  /// **'It is not your turn'**
  String get errorNotYourTurn;

  /// Error message for connectivity problems
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get errorNetwork;

  /// Error message when a game session no longer exists
  ///
  /// In en, this message translates to:
  /// **'Game not found'**
  String get errorGameNotFound;

  /// Error message when the opponent leaves the game
  ///
  /// In en, this message translates to:
  /// **'Opponent disconnected'**
  String get errorOpponentDisconnected;

  /// Error message for an unexpected backend failure
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServerError;

  /// Error message when the user lacks required permissions
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get errorPermissionDenied;

  /// Victory message shown at the end of a game
  ///
  /// In en, this message translates to:
  /// **'You Won!'**
  String get won;

  /// Defeat message shown at the end of a game
  ///
  /// In en, this message translates to:
  /// **'You Lost'**
  String get lost;

  /// Message shown when the game ends in a tie
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// Indicator of whose turn it is
  ///
  /// In en, this message translates to:
  /// **'{player}\'s Turn'**
  String turnOf(String player);

  /// Message shown while matchmaking is in progress
  ///
  /// In en, this message translates to:
  /// **'Finding an opponent...'**
  String get opponentSearching;

  /// Message shown in a private room waiting for the second player
  ///
  /// In en, this message translates to:
  /// **'Waiting for opponent...'**
  String get waitingForOpponent;

  /// Notification banner when the game begins
  ///
  /// In en, this message translates to:
  /// **'Game Started'**
  String get gameStarted;

  /// Indicator that it is the local player's turn
  ///
  /// In en, this message translates to:
  /// **'Your Turn'**
  String get yourTurn;

  /// Indicator that it is the opponent's turn
  ///
  /// In en, this message translates to:
  /// **'Opponent\'s Turn'**
  String get opponentTurn;

  /// Label next to the turn countdown timer
  ///
  /// In en, this message translates to:
  /// **'Time Left'**
  String get timeLeft;

  /// Label for the score display
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// Statistics label for the total number of wins
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// Statistics label for the total number of losses
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// Statistics label for the total number of draws
  ///
  /// In en, this message translates to:
  /// **'Draws'**
  String get draws;

  /// Statistics label for total completed games
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// Statistics label for the win percentage
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// Statistics label for the highest score achieved
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get bestScore;

  /// Statistics label for the consecutive win/loss streak
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Label for the skill rating or elo value
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Section title for the list of achievements
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Achievement name for winning the first game
  ///
  /// In en, this message translates to:
  /// **'First Victory'**
  String get firstWin;

  /// Achievement name for reaching 10 total wins
  ///
  /// In en, this message translates to:
  /// **'10 Wins'**
  String get wins10;

  /// Achievement name for reaching 100 total wins
  ///
  /// In en, this message translates to:
  /// **'100 Wins'**
  String get wins100;

  /// Achievement name for a flawless victory
  ///
  /// In en, this message translates to:
  /// **'Perfect Game'**
  String get perfectGame;

  /// Achievement name for using a rare or unusual player selection
  ///
  /// In en, this message translates to:
  /// **'Rare Player'**
  String get rarePlayer;

  /// Achievement name for winning from a losing position
  ///
  /// In en, this message translates to:
  /// **'Comeback Kid'**
  String get comeback;

  /// Achievement name for winning 5 games in a row
  ///
  /// In en, this message translates to:
  /// **'5-Game Streak'**
  String get winStreak5;

  /// Achievement name for winning 10 games in a row
  ///
  /// In en, this message translates to:
  /// **'10-Game Streak'**
  String get winStreak10;

  /// Settings label for changing the app language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Settings label for selecting the visual theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark theme option label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// Light theme option label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// Theme option that follows the OS system setting
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemMode;

  /// Settings label for notification preferences
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Status text when notifications are turned on
  ///
  /// In en, this message translates to:
  /// **'Notifications are enabled'**
  String get notificationsEnabled;

  /// Status text when notifications are turned off
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled'**
  String get notificationsDisabled;

  /// Easy difficulty level label
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// Medium difficulty level label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Hard difficulty level label
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// Settings label for AI difficulty selection
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Message when there is no active daily challenge
  ///
  /// In en, this message translates to:
  /// **'No daily challenge available today'**
  String get noDailyChallenge;

  /// Message when the user finishes today's challenge
  ///
  /// In en, this message translates to:
  /// **'Daily challenge completed!'**
  String get dailyChallengeCompleted;

  /// Call to action after completing the daily challenge
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for a new challenge'**
  String get comeBackTomorrow;

  /// Leaderboard column label for the rank position
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// Label for the user's country or country filter option
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Message displayed when the friend list is empty
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriends;

  /// Leaderboard filter option for showing all players
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Leaderboard filter option for the worldwide ranking
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// Leaderboard filter option for the friends ranking
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// Button label to send a game invitation to a friend
  ///
  /// In en, this message translates to:
  /// **'Invite Friend'**
  String get inviteFriend;

  /// Button label to share content (room code, app etc.)
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Settings menu item for the about page
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Label for the application version number
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Settings menu item for the help page
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Settings menu item for customer support
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Settings menu item for the privacy policy page
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// Settings menu item for the terms of service page
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms;

  /// Label for the email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for the password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Placeholder text for the email input field
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get hintEmail;

  /// Placeholder text for the password input field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get hintPassword;

  /// Error message when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get errorInvalidEmail;

  /// Error message when password is incorrect
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get errorWrongPassword;

  /// Error message when password does not meet strength requirements
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get errorWeakPassword;

  /// Error message when registering with an existing email
  ///
  /// In en, this message translates to:
  /// **'Email is already in use'**
  String get errorEmailAlreadyInUse;

  /// Error message when no user matches the given credentials
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get errorUserNotFound;

  /// Error message when the user account is disabled
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get errorUserDisabled;

  /// Error message for forbidden authentication operations
  ///
  /// In en, this message translates to:
  /// **'Operation not allowed'**
  String get errorOperationNotAllowed;

  /// Error message when rate limit is exceeded
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later'**
  String get errorTooManyRequests;

  /// Fallback error message for unknown failures
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again'**
  String get errorUnknown;

  /// Error message when user cancels third-party sign in flow
  ///
  /// In en, this message translates to:
  /// **'Sign in was cancelled'**
  String get errorAborted;

  /// Title for the account linking screen
  ///
  /// In en, this message translates to:
  /// **'Make your account permanent'**
  String get linkAccountTitle;

  /// Subtitle explaining the benefit of linking an account
  ///
  /// In en, this message translates to:
  /// **'Link your account to save progress and never lose your data'**
  String get linkAccountSubtitle;

  /// Success message when account linking completes
  ///
  /// In en, this message translates to:
  /// **'Account linked successfully!'**
  String get accountLinkedSuccess;

  /// Separator text between groups of login options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Greeting shown on the home page with the user's name
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Label next to the turn countdown timer
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Button label to pass the current turn
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get passTurn;

  /// Label showing remaining pass count
  ///
  /// In en, this message translates to:
  /// **'Passes Left: {count}'**
  String passesRemaining(int count);

  /// Message when a player has used all pass rights
  ///
  /// In en, this message translates to:
  /// **'No passes left!'**
  String get noPassesLeft;

  /// Notification when a player passes their turn
  ///
  /// In en, this message translates to:
  /// **'{player} passed their turn!'**
  String playerPassedTurn(String player);

  /// Button label to offer a draw to the opponent
  ///
  /// In en, this message translates to:
  /// **'Offer Draw'**
  String get offerDraw;

  /// Banner shown to sender while draw offer is pending
  ///
  /// In en, this message translates to:
  /// **'Draw offer sent ({seconds}s)'**
  String drawOfferSent(int seconds);

  /// Prompt shown to recipient when opponent offers a draw
  ///
  /// In en, this message translates to:
  /// **'{player} offers a draw ({seconds}s)'**
  String drawOfferReceived(String player, int seconds);

  /// Button label to accept a draw offer
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptDraw;

  /// Button label to reject a draw offer
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get rejectDraw;

  /// Message shown when a draw offer is accepted
  ///
  /// In en, this message translates to:
  /// **'Draw offer accepted! The match ended in a draw.'**
  String get drawAcceptedMessage;

  /// Message shown when a draw offer is rejected
  ///
  /// In en, this message translates to:
  /// **'Draw offer declined. The match continues!'**
  String get drawRejectedMessage;

  /// Message shown when a draw offer expires without response
  ///
  /// In en, this message translates to:
  /// **'Draw offer expired (30s).'**
  String get drawOfferExpiredMessage;

  /// Message shown when draw offer is on 60s cooldown
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds}s before offering a draw again.'**
  String drawOfferCooldownMessage(int seconds);

  /// Title for the match move history sheet
  ///
  /// In en, this message translates to:
  /// **'Match History'**
  String get matchHistoryTitle;

  /// Legend league division name
  ///
  /// In en, this message translates to:
  /// **'Legend League'**
  String get leagueLegend;

  /// Elite league division name
  ///
  /// In en, this message translates to:
  /// **'Elite League'**
  String get leagueElite;

  /// Pro league division name
  ///
  /// In en, this message translates to:
  /// **'Pro League'**
  String get leaguePro;

  /// Starter league division name
  ///
  /// In en, this message translates to:
  /// **'Starter League'**
  String get leagueStarter;

  /// Default player display name
  ///
  /// In en, this message translates to:
  /// **'Goalverse Captain'**
  String get defaultCaptainName;

  /// Live event banner in hero stage
  ///
  /// In en, this message translates to:
  /// **'SEASON 1 DERBY WEEK'**
  String get seasonDerbyWeek;

  /// Hero section main headline
  ///
  /// In en, this message translates to:
  /// **'Step onto the Pitch,\nProve Your Knowledge.'**
  String get heroHeadline;

  /// Hero section description
  ///
  /// In en, this message translates to:
  /// **'Practice solo, dive into live 1v1 matchmaking, or create a private room to duel friends in the Goalverse football gaming universe.'**
  String get heroSubtitle;

  /// Solo play CTA button
  ///
  /// In en, this message translates to:
  /// **'Play Solo'**
  String get soloPlay;

  /// Online matchmaking CTA button
  ///
  /// In en, this message translates to:
  /// **'Online Match'**
  String get onlineMatch;

  /// Private room creation pill
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createPrivateRoom;

  /// Join room with code pill
  ///
  /// In en, this message translates to:
  /// **'Join with Code'**
  String get joinWithCode;

  /// Featured game modes section title
  ///
  /// In en, this message translates to:
  /// **'Featured Modes'**
  String get featuredModes;

  /// Featured modes section subtitle
  ///
  /// In en, this message translates to:
  /// **'Signature Goalverse competitive experiences'**
  String get featuredModesSubtitle;

  /// Popular badge tag
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get badgePopular;

  /// Subtitle for Football SOS game card
  ///
  /// In en, this message translates to:
  /// **'Find shared stars in the 3×3 club grid and complete a three-in-a-row.'**
  String get sosCardSubtitle;

  /// Play now primary button
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get playNow;

  /// Subtitle for Rating Battle card
  ///
  /// In en, this message translates to:
  /// **'Pick the card with superior overall, market value, or career goals.'**
  String get ratingBattleSubtitle;

  /// Arcade game modes section title
  ///
  /// In en, this message translates to:
  /// **'Arcade Modes'**
  String get arcadeModes;

  /// Arcade modes section subtitle
  ///
  /// In en, this message translates to:
  /// **'Test your football culture with distinct rules'**
  String get arcadeModesSubtitle;

  /// 5 Modes badge tag
  ///
  /// In en, this message translates to:
  /// **'5 MODES'**
  String get badgeModesCount;

  /// Two clubs one player mode title
  ///
  /// In en, this message translates to:
  /// **'2 Clubs 1 Player'**
  String get twoTeamsTitle;

  /// Two clubs one player mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Find the shared star footballer who played for both clubs.'**
  String get twoTeamsSubtitle;

  /// Shared star pill tag
  ///
  /// In en, this message translates to:
  /// **'Shared Star'**
  String get twoTeamsStatus;

  /// Who am I mode title
  ///
  /// In en, this message translates to:
  /// **'Who Am I?'**
  String get whoAmITitle;

  /// Who am I mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Guess the secret legend with 5 career clues revealed from hard to easy.'**
  String get whoAmISubtitle;

  /// Mystery card pill tag
  ///
  /// In en, this message translates to:
  /// **'Mystery Card'**
  String get whoAmIStatus;

  /// 5 Clues duration label
  ///
  /// In en, this message translates to:
  /// **'5 Clues'**
  String get fiveClues;

  /// Imposter mode title
  ///
  /// In en, this message translates to:
  /// **'Imposter'**
  String get imposterTitle;

  /// Imposter mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Catch the imposter who never played for the target club among 4 players.'**
  String get imposterSubtitle;

  /// 1 Imposter status tag
  ///
  /// In en, this message translates to:
  /// **'1 Imposter'**
  String get imposterStatus;

  /// Transfer path mode title
  ///
  /// In en, this message translates to:
  /// **'Transfer Path'**
  String get transferPathTitle;

  /// Transfer path mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Find the player by following their chronological club history and seasons.'**
  String get transferPathSubtitle;

  /// Career route status tag
  ///
  /// In en, this message translates to:
  /// **'Career Route'**
  String get transferPathStatus;

  /// 3+ clubs label
  ///
  /// In en, this message translates to:
  /// **'3+ Clubs'**
  String get threePlusClubs;

  /// Football bomb mode title
  ///
  /// In en, this message translates to:
  /// **'Football Bomb'**
  String get footballBombTitle;

  /// Football bomb mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Name a player matching the club or country criteria before the bomb explodes.'**
  String get footballBombSubtitle;

  /// Countdown status tag
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get footballBombStatus;

  /// Party mode playerCount label
  ///
  /// In en, this message translates to:
  /// **'1-8P • Party'**
  String get partyModeLabel;

  /// 1-2 player online label
  ///
  /// In en, this message translates to:
  /// **'1-2P • Online'**
  String get oneToTwoOnlineLabel;

  /// Room play action prefix
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get roomPlayAction;

  /// Play action suffix
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playAction;

  /// Daily quest and ranking section header
  ///
  /// In en, this message translates to:
  /// **'Daily Quest & Ranking'**
  String get dailyAndRanking;

  /// Daily quest and ranking section subtitle
  ///
  /// In en, this message translates to:
  /// **'Claim rewards, rise to the global podium'**
  String get dailyAndRankingSubtitle;

  /// Season 1 badge
  ///
  /// In en, this message translates to:
  /// **'SEASON 1'**
  String get seasonOne;

  /// Active quest badge
  ///
  /// In en, this message translates to:
  /// **'ACTIVE QUEST'**
  String get activeQuest;

  /// Daily challenge card description
  ///
  /// In en, this message translates to:
  /// **'Complete today\'s 3×3 grid to earn extra rewards.'**
  String get dailyChallengeSubtitle;

  /// Start quest action button
  ///
  /// In en, this message translates to:
  /// **'Start Quest'**
  String get startQuest;

  /// Leaderboard card subtitle
  ///
  /// In en, this message translates to:
  /// **'Global Top 100 & Season Podium'**
  String get leaderboardSubtitle;

  /// Rank elite title
  ///
  /// In en, this message translates to:
  /// **'Elite'**
  String get rankElite;

  /// Rank captain title
  ///
  /// In en, this message translates to:
  /// **'Captain'**
  String get rankCaptain;

  /// Rank star title
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get rankStar;

  /// You player indicator label
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youPlayerPrefix;

  /// Bottom navigation arena tab
  ///
  /// In en, this message translates to:
  /// **'ARENA'**
  String get navArena;

  /// Bottom navigation online tab
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get navOnline;

  /// Bottom navigation daily tab
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get navDaily;

  /// Bottom navigation ranking tab
  ///
  /// In en, this message translates to:
  /// **'RANKING'**
  String get navRanking;

  /// Bottom navigation profile tab
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get navProfile;

  /// Forgot password link button
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordQuestion;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// Confirm password placeholder hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// Terms checkbox prefix
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the '**
  String get termsAcceptPrefix;

  /// Terms link text
  ///
  /// In en, this message translates to:
  /// **'Terms of Service and Privacy Policy'**
  String get termsAcceptLink;

  /// Terms checkbox suffix
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsAcceptSuffix;

  /// 30 seconds duration
  ///
  /// In en, this message translates to:
  /// **'30s'**
  String get thirtySeconds;

  /// 15 seconds duration
  ///
  /// In en, this message translates to:
  /// **'15s'**
  String get fifteenSeconds;

  /// 20 seconds duration
  ///
  /// In en, this message translates to:
  /// **'20s'**
  String get twentySeconds;

  /// 25 seconds duration
  ///
  /// In en, this message translates to:
  /// **'25s'**
  String get twentyFiveSeconds;

  /// 18 seconds duration
  ///
  /// In en, this message translates to:
  /// **'18s'**
  String get eighteenSeconds;

  /// 1v1 solo online mode label
  ///
  /// In en, this message translates to:
  /// **'1v1 • Solo • Online'**
  String get oneVsOneSoloOnline;

  /// Higher lower game mode tag
  ///
  /// In en, this message translates to:
  /// **'Higher / Lower'**
  String get higherLower;

  /// League metric label
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get leagueLabel;

  /// Streak metric label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// Streak count suffix
  ///
  /// In en, this message translates to:
  /// **'{count} Matches'**
  String streakMatchesCount(int count);

  /// Completed quest badge
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completedBadge;

  /// Reward claimed button text
  ///
  /// In en, this message translates to:
  /// **'Claimed ✓'**
  String get rewardClaimed;

  /// Live 1v1 action label
  ///
  /// In en, this message translates to:
  /// **'Live 1v1'**
  String get liveOneVsOne;

  /// Settings section header for difficulty and controls
  ///
  /// In en, this message translates to:
  /// **'Difficulty & Controls'**
  String get difficultyAndControls;

  /// Settings indicator for turn duration and score multiplier
  ///
  /// In en, this message translates to:
  /// **'Time: {seconds}s • Multiplier: {multiplier}x'**
  String turnDurationAndMultiplier(int seconds, String multiplier);

  /// Settings switch title for vibration
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback (Vibration)'**
  String get hapticsTitle;

  /// Settings switch subtitle for vibration
  ///
  /// In en, this message translates to:
  /// **'Tactile feedback on correct and wrong guesses'**
  String get hapticsSubtitle;

  /// Settings switch title for audio
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffectsTitle;

  /// Settings switch subtitle for audio
  ///
  /// In en, this message translates to:
  /// **'Stadium atmosphere and in-game sound effects'**
  String get soundEffectsSubtitle;

  /// Settings account tile to send reset email
  ///
  /// In en, this message translates to:
  /// **'Send Password Reset Link'**
  String get sendPasswordResetLink;

  /// Settings danger zone tile
  ///
  /// In en, this message translates to:
  /// **'Delete Account Permanently'**
  String get deleteAccountPermanently;

  /// Settings danger zone subtitle
  ///
  /// In en, this message translates to:
  /// **'Permanently erase your profile data and account'**
  String get deleteAccountSubtitle;

  /// Delete account confirmation dialog warning message
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Your ELO rating, match history, and user profile will be permanently erased.'**
  String get deleteAccountWarning;

  /// Password confirmation input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to confirm'**
  String get currentPasswordPrompt;

  /// Validation error for empty password in account deletion
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password.'**
  String get pleaseEnterPassword;

  /// Account deletion confirm action button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountButton;

  /// Account deletion progress indicator text
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deletingAccount;

  /// Title of online multiplayer lobby dialog
  ///
  /// In en, this message translates to:
  /// **'Live Multiplayer Lobby'**
  String get liveMultiplayerLobby;

  /// Subtitle of online multiplayer lobby dialog
  ///
  /// In en, this message translates to:
  /// **'Quick Match • Private Room • 6-Digit Code'**
  String get lobbySubtitle;

  /// Header label for game mode selector in lobby
  ///
  /// In en, this message translates to:
  /// **'Select Game Mode'**
  String get selectGameMode;

  /// Validation error for incomplete room code
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete 6-digit room code.'**
  String get roomCodeMustBe6Digits;

  /// Best of 3 rounds option title
  ///
  /// In en, this message translates to:
  /// **'3 ROUNDS – 2 WINS'**
  String get format3RoundsTitle;

  /// Best of 3 rounds option description
  ///
  /// In en, this message translates to:
  /// **'Best of 3 rounds, first to 2 wins takes the match'**
  String get format3RoundsDesc;

  /// Best of 5 rounds option title
  ///
  /// In en, this message translates to:
  /// **'5 ROUNDS – 3 WINS'**
  String get format5RoundsTitle;

  /// Best of 5 rounds option description
  ///
  /// In en, this message translates to:
  /// **'Best of 5 rounds, first to 3 wins takes the match'**
  String get format5RoundsDesc;

  /// Match format header in lobby
  ///
  /// In en, this message translates to:
  /// **'MATCH FORMAT (FOOTBALL SOS SERIES)'**
  String get matchFormatSos;

  /// Matchmaking loading status
  ///
  /// In en, this message translates to:
  /// **'Searching for open rooms and opponents...'**
  String get searchingRoomsAndOpponent;

  /// Matchmaking room created message
  ///
  /// In en, this message translates to:
  /// **'Match Room Created — Waiting for Opponent'**
  String get matchRoomWaitingOpponent;

  /// Quick match prompt description with mode name
  ///
  /// In en, this message translates to:
  /// **'Instantly join an open room or enter matchmaking for {mode}.'**
  String quickMatchPrompt(String mode);

  /// Quick match action button
  ///
  /// In en, this message translates to:
  /// **'Start Quick Match'**
  String get startQuickMatch;

  /// Room creation progress text
  ///
  /// In en, this message translates to:
  /// **'Preparing private room and match data...'**
  String get preparingPrivateRoom;

  /// Share code instruction
  ///
  /// In en, this message translates to:
  /// **'Share the 6-Digit Code with your Friend:'**
  String get shareRoomCodeWithFriend;

  /// Create room prompt description
  ///
  /// In en, this message translates to:
  /// **'Create a 6-digit private room in {mode} and invite your friend.'**
  String createPrivateRoomPrompt(String mode);

  /// Turn timer label
  ///
  /// In en, this message translates to:
  /// **'Turn Duration:'**
  String get turnDuration;

  /// Create room button text
  ///
  /// In en, this message translates to:
  /// **'Create 6-Digit Private Room'**
  String get create6DigitPrivateRoom;

  /// Snackbar text when copying room code
  ///
  /// In en, this message translates to:
  /// **'Room code copied: {code}'**
  String roomCodeCopied(Object code);

  /// Waiting for opponent status message
  ///
  /// In en, this message translates to:
  /// **'Match starts automatically when opponent joins...'**
  String get matchStartsWhenOpponentJoins;

  /// Enter room action button
  ///
  /// In en, this message translates to:
  /// **'Enter Room Now (Connects Live When Opponent Joins)'**
  String get enterRoomNowAction;

  /// Join room input prompt
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit room code shared by your friend:'**
  String get enterFriendRoomCodePrompt;

  /// Paste code button label
  ///
  /// In en, this message translates to:
  /// **'Paste from Clipboard'**
  String get pasteFromClipboard;

  /// Join room button label
  ///
  /// In en, this message translates to:
  /// **'Join Room & Start Match'**
  String get joinRoomAndStartMatch;

  /// Local solo play button
  ///
  /// In en, this message translates to:
  /// **'Play Solo'**
  String get playSoloAction;

  /// Local multiplayer button
  ///
  /// In en, this message translates to:
  /// **'2 Players (Same Device)'**
  String get playSameDeviceAction;

  /// Locked match format indicator
  ///
  /// In en, this message translates to:
  /// **'Format: {rounds} ROUNDS – {wins} WINS (Locked)'**
  String lockedFormatPrefix(int rounds, int wins);

  /// 2-Player duel toggle label
  ///
  /// In en, this message translates to:
  /// **'2P Duel'**
  String get duelMode2P;

  /// 1-Player solo toggle label
  ///
  /// In en, this message translates to:
  /// **'1P Solo'**
  String get duelMode1P;

  /// Active live room badge
  ///
  /// In en, this message translates to:
  /// **'Live Room'**
  String get onlineRoomLive;

  /// Online room button
  ///
  /// In en, this message translates to:
  /// **'Online Room'**
  String get onlineRoom;

  /// Player 1 turn indicator
  ///
  /// In en, this message translates to:
  /// **'Turn: P1'**
  String get turnP1;

  /// Player 2 turn indicator
  ///
  /// In en, this message translates to:
  /// **'Turn: P2'**
  String get turnP2;

  /// Duel draw result title
  ///
  /// In en, this message translates to:
  /// **'Duel Draw'**
  String get duelDraw;

  /// Player 1 won title
  ///
  /// In en, this message translates to:
  /// **'Player 1 Won'**
  String get player1Won;

  /// Player 2 won title
  ///
  /// In en, this message translates to:
  /// **'Player 2 Won'**
  String get player2Won;

  /// Duel summary modal subtitle
  ///
  /// In en, this message translates to:
  /// **'2 Player Duel Result'**
  String get twoPlayerDuelResult;

  /// Return to main menu button
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenuButton;

  /// Play again rematch button
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgainButton;

  /// Empty state message for leaderboard
  ///
  /// In en, this message translates to:
  /// **'No competitors on the leaderboard yet. Be the first to claim the podium!'**
  String get noRankingPlayersYet;

  /// Edit profile dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Player name input label
  ///
  /// In en, this message translates to:
  /// **'Player Name'**
  String get playerName;

  /// Country selector label
  ///
  /// In en, this message translates to:
  /// **'Country / Flag:'**
  String get countryFlag;

  /// Achievement description for first victory
  ///
  /// In en, this message translates to:
  /// **'Earn your first victory in any game mode.'**
  String get achievementFirstWinHowTo;

  /// Achievement description for 10 wins
  ///
  /// In en, this message translates to:
  /// **'Win 10 total matches.'**
  String get achievementWins10HowTo;

  /// Achievement description for 100 wins
  ///
  /// In en, this message translates to:
  /// **'Win 100 total matches to become a legend.'**
  String get achievementWins100HowTo;

  /// Achievement description for perfect game
  ///
  /// In en, this message translates to:
  /// **'Score 900+ points in a single match or guess on the 1st clue in Who Am I!'**
  String get achievementPerfectGameHowTo;

  /// Achievement description for rare player
  ///
  /// In en, this message translates to:
  /// **'Correctly guess a difficult club intersection with 4 or fewer possible answers!'**
  String get achievementRarePlayerHowTo;

  /// Achievement description for comeback
  ///
  /// In en, this message translates to:
  /// **'Come from behind to win a Football SOS match!'**
  String get achievementComebackHowTo;

  /// Achievement description for 5 match streak
  ///
  /// In en, this message translates to:
  /// **'Win 5 matches in a row.'**
  String get achievementStreak5HowTo;

  /// Achievement description for 10 match streak
  ///
  /// In en, this message translates to:
  /// **'Win 10 matches in a row to forge an invincible streak.'**
  String get achievementStreak10HowTo;

  /// Turn timer expired dialog title
  ///
  /// In en, this message translates to:
  /// **'⏰ Time\'s Up!'**
  String get timeExpired;

  /// Duel finished title
  ///
  /// In en, this message translates to:
  /// **'Duel Finished!'**
  String get duelFinished;

  /// Streak label in game modes
  ///
  /// In en, this message translates to:
  /// **'Correct Guess Streak'**
  String get correctStreakLabel;

  /// Best streak summary stats
  ///
  /// In en, this message translates to:
  /// **'Best Streak: {best} • +{points} Pts'**
  String bestStreakStats(int best, int points);

  /// Exit dialog button
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitAction;

  /// Reveal answers button
  ///
  /// In en, this message translates to:
  /// **'See Answers'**
  String get seeAnswers;

  /// Next match button
  ///
  /// In en, this message translates to:
  /// **'Next Match'**
  String get nextMatch;

  /// Multiplayer round winner dialog title
  ///
  /// In en, this message translates to:
  /// **'🎉 Player {player} Got It! +{points} Pts'**
  String playerGuessedCorrect(int player, int points);

  /// Solo round winner dialog title
  ///
  /// In en, this message translates to:
  /// **'🎉 Great Guess! +{points} Pts'**
  String greatGuessSolo(int points);

  /// Player shared club confirmation sentence
  ///
  /// In en, this message translates to:
  /// **'played for both {teamA} and {teamB}!'**
  String playedForBothClubs(String teamA, String teamB);

  /// Daily challenge stage banner
  ///
  /// In en, this message translates to:
  /// **'STAGE {stage} / 4 • 1.5x DAILY TOURNAMENT MULTIPLIER'**
  String dailyStageHeader(int stage);

  /// Skip stage button
  ///
  /// In en, this message translates to:
  /// **'Skip This Stage ➔'**
  String get skipThisStage;

  /// Daily challenge completion dialog title
  ///
  /// In en, this message translates to:
  /// **'DAILY CHALLENGE COMPLETED!'**
  String get dailyChallengeCompletedTitle;

  /// Daily challenge completion dialog message
  ///
  /// In en, this message translates to:
  /// **'You successfully completed all stages for today. Return tomorrow for new challenges!'**
  String get dailyChallengeCompletedDesc;

  /// Claim reward and exit action button
  ///
  /// In en, this message translates to:
  /// **'Claim Reward & Return to Home'**
  String get claimDailyRewardAndExit;

  /// Accessibility label for player command header
  ///
  /// In en, this message translates to:
  /// **'Player Profile: {name}, Level {level}'**
  String profileSemanticLabel(String name, int level);

  /// Accessibility label for leaderboard card
  ///
  /// In en, this message translates to:
  /// **'{title}, Your Rating: {rating} ELO'**
  String leaderboardCardSemanticLabel(String title, int rating);

  /// Notification when player timer expires
  ///
  /// In en, this message translates to:
  /// **'⏰ Time expired! Turn passed to opponent.'**
  String get timeExpiredTurnPasses;

  /// Round start notification banner
  ///
  /// In en, this message translates to:
  /// **'⚽ Round {round} started! New club grid ready.'**
  String roundStartedClubsReady(int round);

  /// AI move announcement
  ///
  /// In en, this message translates to:
  /// **'🤖 Bot made a move: {player}'**
  String botMadeMove(String player);

  /// AI pass notification
  ///
  /// In en, this message translates to:
  /// **'🤖 Bot passed their turn.'**
  String get botPassedTurn;

  /// Empty move history message
  ///
  /// In en, this message translates to:
  /// **'No moves made yet.'**
  String get noMovesYet;

  /// Cell answers header
  ///
  /// In en, this message translates to:
  /// **'Verified {count} players for this cell:'**
  String verifiedPlayersForCell(int count);

  /// Invalid player guess error message
  ///
  /// In en, this message translates to:
  /// **'❌ {player} did not play for both clubs! Turn passed.'**
  String playerDidNotPlayForBoth(String player);

  /// Bot victory message
  ///
  /// In en, this message translates to:
  /// **'🤖 Bot Won!'**
  String get botWon;

  /// Player 1 X victory title
  ///
  /// In en, this message translates to:
  /// **'🏆 Player 1 (X) Won!'**
  String get player1WonX;

  /// Player 2 O victory title
  ///
  /// In en, this message translates to:
  /// **'🏆 Player 2 (O) Won!'**
  String get player2WonO;

  /// Match end dialog header
  ///
  /// In en, this message translates to:
  /// **'MATCH END • {total} ROUNDS ({wins} WINS)'**
  String matchEndSummary(int total, int wins);

  /// Rounds won stat label
  ///
  /// In en, this message translates to:
  /// **'Rounds Won'**
  String get roundsWon;

  /// Correct answers stat label
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get correctAnswers;

  /// Wrong answers stat label
  ///
  /// In en, this message translates to:
  /// **'Wrong Answers'**
  String get wrongAnswers;

  /// Passes used stat label
  ///
  /// In en, this message translates to:
  /// **'Passes Used'**
  String get passesUsed;

  /// Match duration stat label
  ///
  /// In en, this message translates to:
  /// **'Match Duration'**
  String get matchDuration;

  /// ELO rating change label
  ///
  /// In en, this message translates to:
  /// **'ELO Change'**
  String get eloChange;

  /// Post-match hint message
  ///
  /// In en, this message translates to:
  /// **'💡 Tip: Close this dialog and tap any cell on the grid to inspect all verified valid footballers!'**
  String get inspectBoardHint;

  /// Inspect board button
  ///
  /// In en, this message translates to:
  /// **'Inspect Board'**
  String get inspectBoard;

  /// 2-Player SOS title
  ///
  /// In en, this message translates to:
  /// **'Football SOS • 2 Players'**
  String get footballSos2P;

  /// Format selector tooltip
  ///
  /// In en, this message translates to:
  /// **'Select Match Format'**
  String get selectMatchFormatTooltip;

  /// Mode selector tooltip
  ///
  /// In en, this message translates to:
  /// **'Change Game Mode'**
  String get changeGameModeTooltip;

  /// Solo vs Bot menu item
  ///
  /// In en, this message translates to:
  /// **'🤖 Solo (vs Smart AI)'**
  String get modeSoloVsBot;

  /// 2-Player local menu item
  ///
  /// In en, this message translates to:
  /// **'👥 2-Player Duel (Same Device)'**
  String get mode2PlayerLocal;

  /// Round draw banner
  ///
  /// In en, this message translates to:
  /// **'ROUND {round} ENDED IN A DRAW'**
  String roundEndedInDraw(int round);

  /// Next round series prompt
  ///
  /// In en, this message translates to:
  /// **'Next: ROUND {round} (First to {wins} wins takes the match)'**
  String nextRoundBanner(int round, int wins);

  /// Start next round button
  ///
  /// In en, this message translates to:
  /// **'Start Round {round}'**
  String startNextRound(int round);

  /// Scoreboard current user tag
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get scoreboardYou;

  /// Scoreboard bot tag
  ///
  /// In en, this message translates to:
  /// **'BOT'**
  String get scoreboardBot;

  /// Scoreboard player 1 tag
  ///
  /// In en, this message translates to:
  /// **'PLAYER 1'**
  String get scoreboardPlayer1;

  /// Scoreboard player 2 tag
  ///
  /// In en, this message translates to:
  /// **'PLAYER 2'**
  String get scoreboardPlayer2;

  /// Scoreboard finished tag
  ///
  /// In en, this message translates to:
  /// **'FINISHED'**
  String get scoreboardFinished;

  /// Scoreboard draw tag
  ///
  /// In en, this message translates to:
  /// **'DRAW'**
  String get scoreboardDraw;

  /// Scoreboard AI thinking status
  ///
  /// In en, this message translates to:
  /// **'AI THINKING'**
  String get scoreboardAiThinking;

  /// Turn X indicator
  ///
  /// In en, this message translates to:
  /// **'TURN: X'**
  String get scoreboardTurnX;

  /// Turn O indicator
  ///
  /// In en, this message translates to:
  /// **'TURN: O'**
  String get scoreboardTurnO;

  /// Cell action to select empty cell
  ///
  /// In en, this message translates to:
  /// **'SELECT'**
  String get cellActionSelect;

  /// Cell action to view filled cell
  ///
  /// In en, this message translates to:
  /// **'VIEW'**
  String get cellActionView;

  /// Leave match confirmation title
  ///
  /// In en, this message translates to:
  /// **'Leave Match?'**
  String get leaveMatchTitle;

  /// Leave match confirmation body
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the active multiplayer match?'**
  String get leaveMatchConfirm;

  /// Stay in match button
  ///
  /// In en, this message translates to:
  /// **'Continue Match'**
  String get continueMatch;

  /// Leave match button
  ///
  /// In en, this message translates to:
  /// **'Leave Match'**
  String get leaveMatch;

  /// Match victory modal message
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You reached {wins} wins and took the match!'**
  String congratsMatchWon(int wins);

  /// Series draw modal message
  ///
  /// In en, this message translates to:
  /// **'The series ended in a draw.'**
  String get seriesDraw;

  /// Opponent victory modal message
  ///
  /// In en, this message translates to:
  /// **'{opponent} reached {wins} wins and took the match.'**
  String opponentMatchWon(String opponent, int wins);

  /// Connecting status label
  ///
  /// In en, this message translates to:
  /// **'Connecting to live match...'**
  String get connectingToLiveMatch;

  /// Round completion transition message
  ///
  /// In en, this message translates to:
  /// **'ROUND {round} COMPLETED • NEW ROUND STARTING'**
  String roundCompletedNewStarting(int round);

  /// User turn prompt
  ///
  /// In en, this message translates to:
  /// **'YOUR TURN! Select a cell'**
  String get yourTurnSelectCell;

  /// Opponent turn prompt
  ///
  /// In en, this message translates to:
  /// **'Opponent is thinking ({name})...'**
  String opponentThinking(String name);

  /// Grid full draw explanation
  ///
  /// In en, this message translates to:
  /// **'Grid is full, neither player achieved a 3-in-a-row.'**
  String get boardFullNoSeries;

  /// User won the round message
  ///
  /// In en, this message translates to:
  /// **'Round Loser: {opponent} • You took the lead in the series!'**
  String loserOpponentAhead(String opponent);

  /// User lost the round message
  ///
  /// In en, this message translates to:
  /// **'Round Loser: {me} • Level the score in the next round!'**
  String loserYouTieNext(String me);

  /// Next round countdown banner
  ///
  /// In en, this message translates to:
  /// **'Next: ROUND {round} ({seconds}s)'**
  String nextRoundCountdown(int round, int seconds);

  /// Board load error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load board.'**
  String get boardLoadFailed;

  /// Round noun
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get roundLabel;

  /// New grid action
  ///
  /// In en, this message translates to:
  /// **'New Grid'**
  String get newGrid;

  /// Opponent noun
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get opponentLabel;

  /// No description provided for @onlineMatchConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to live room...'**
  String get onlineMatchConnecting;

  /// No description provided for @liveRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'LIVE ROOM #{code}'**
  String liveRoomTitle(Object code);

  /// No description provided for @waitingOpponent.
  ///
  /// In en, this message translates to:
  /// **'⏳ Waiting for Opponent'**
  String get waitingOpponent;

  /// No description provided for @opponentFinished.
  ///
  /// In en, this message translates to:
  /// **'✓ Opponent Finished'**
  String get opponentFinished;

  /// No description provided for @opponentRound.
  ///
  /// In en, this message translates to:
  /// **'⚡ Opponent Round {round}'**
  String opponentRound(Object round);

  /// No description provided for @onlineVictoryTitle.
  ///
  /// In en, this message translates to:
  /// **'🏆 ONLINE DUEL VICTORY!'**
  String get onlineVictoryTitle;

  /// No description provided for @onlineDrawTitle.
  ///
  /// In en, this message translates to:
  /// **'🤝 ONLINE MATCH DRAW!'**
  String get onlineDrawTitle;

  /// No description provided for @onlineDefeatTitle.
  ///
  /// In en, this message translates to:
  /// **'💔 ONLINE MATCH LOST'**
  String get onlineDefeatTitle;

  /// No description provided for @roomLiveScoreboard.
  ///
  /// In en, this message translates to:
  /// **'Room #{code} • Live Scoreboard'**
  String roomLiveScoreboard(Object code);

  /// No description provided for @changeNameAndFlag.
  ///
  /// In en, this message translates to:
  /// **'Change Name & Flag'**
  String get changeNameAndFlag;

  /// No description provided for @eloRatingBadge.
  ///
  /// In en, this message translates to:
  /// **'{rating} ELO RATING'**
  String eloRatingBadge(Object rating);

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @achievementUnlockedDesc.
  ///
  /// In en, this message translates to:
  /// **'✅ Unlocked!\n\n{desc}'**
  String achievementUnlockedDesc(Object desc);

  /// No description provided for @achievementLockedDesc.
  ///
  /// In en, this message translates to:
  /// **'🔒 Still locked.\n\nHow to unlock: {desc}'**
  String achievementLockedDesc(Object desc);

  /// No description provided for @totalPassCount.
  ///
  /// In en, this message translates to:
  /// **'Total Passes Used'**
  String get totalPassCount;

  /// No description provided for @drawAgreements.
  ///
  /// In en, this message translates to:
  /// **'Draw Agreements'**
  String get drawAgreements;

  /// No description provided for @matchHistoryCapacity.
  ///
  /// In en, this message translates to:
  /// **'Match History Capacity'**
  String get matchHistoryCapacity;

  /// No description provided for @correctPredictionStreak.
  ///
  /// In en, this message translates to:
  /// **'Correct Guess Streak'**
  String get correctPredictionStreak;

  /// No description provided for @peakMarketValue.
  ///
  /// In en, this message translates to:
  /// **'Peak Market Value'**
  String get peakMarketValue;

  /// No description provided for @careerGoals.
  ///
  /// In en, this message translates to:
  /// **'Career Goals'**
  String get careerGoals;

  /// No description provided for @careerAssists.
  ///
  /// In en, this message translates to:
  /// **'Career Assists'**
  String get careerAssists;

  /// No description provided for @sprintSpeedRating.
  ///
  /// In en, this message translates to:
  /// **'Speed / Sprint Rating'**
  String get sprintSpeedRating;

  /// No description provided for @championsLeagueGoals.
  ///
  /// In en, this message translates to:
  /// **'Champions League Goals'**
  String get championsLeagueGoals;

  /// No description provided for @playerAge.
  ///
  /// In en, this message translates to:
  /// **'Player Age'**
  String get playerAge;

  /// No description provided for @comparedStat.
  ///
  /// In en, this message translates to:
  /// **'COMPARED STAT: {stat}'**
  String comparedStat(Object stat);

  /// No description provided for @correctGuess.
  ///
  /// In en, this message translates to:
  /// **'CORRECT GUESS!'**
  String get correctGuess;

  /// No description provided for @wrongGuess.
  ///
  /// In en, this message translates to:
  /// **'WRONG GUESS'**
  String get wrongGuess;

  /// No description provided for @higher.
  ///
  /// In en, this message translates to:
  /// **'Higher'**
  String get higher;

  /// No description provided for @lower.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get lower;

  /// No description provided for @correctTransferPath.
  ///
  /// In en, this message translates to:
  /// **'🎯 Correct Transfer Path!'**
  String get correctTransferPath;

  /// No description provided for @earnedPoints.
  ///
  /// In en, this message translates to:
  /// **'You earned +{points} Points!'**
  String earnedPoints(Object points);

  /// No description provided for @wrongPlayerNextTurn.
  ///
  /// In en, this message translates to:
  /// **'❌ Not {name}! Turn passes to Player {player}.'**
  String wrongPlayerNextTurn(Object name, Object player);

  /// No description provided for @wrongPlayerCheckHistory.
  ///
  /// In en, this message translates to:
  /// **'❌ Not {name}! Check the club history again.'**
  String wrongPlayerCheckHistory(Object name);

  /// No description provided for @answerRevealed.
  ///
  /// In en, this message translates to:
  /// **'🏳️ Answer Revealed'**
  String get answerRevealed;

  /// No description provided for @transferPathOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner of this transfer history:'**
  String get transferPathOwner;

  /// No description provided for @nextCareerPath.
  ///
  /// In en, this message translates to:
  /// **'Next Career Path ➔'**
  String get nextCareerPath;

  /// No description provided for @transferPathQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which footballer does this chronological transfer history belong to?'**
  String get transferPathQuestion;

  /// No description provided for @cluePositionAndCountry.
  ///
  /// In en, this message translates to:
  /// **'💡 Clue: Position {pos} • Country {country}'**
  String cluePositionAndCountry(Object country, Object pos);

  /// No description provided for @presentDay.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get presentDay;

  /// No description provided for @clubsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Clubs'**
  String clubsCountLabel(Object count);

  /// No description provided for @hintPenalty.
  ///
  /// In en, this message translates to:
  /// **'Hint (-150p)'**
  String get hintPenalty;

  /// No description provided for @whoAmIBullseye.
  ///
  /// In en, this message translates to:
  /// **'🎯 BULLSEYE!'**
  String get whoAmIBullseye;

  /// No description provided for @potentialPoints.
  ///
  /// In en, this message translates to:
  /// **'Potential Reward:'**
  String get potentialPoints;

  /// No description provided for @lockedClue.
  ///
  /// In en, this message translates to:
  /// **'🔒 Locked Clue'**
  String get lockedClue;

  /// No description provided for @unlockNextClueRemaining.
  ///
  /// In en, this message translates to:
  /// **'Unlock Next Clue ({count} left)'**
  String unlockNextClueRemaining(Object count);

  /// No description provided for @unlockNextClue.
  ///
  /// In en, this message translates to:
  /// **'Unlock Next Clue'**
  String get unlockNextClue;

  /// No description provided for @twoTeamsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Find the footballer who played for both clubs!'**
  String get twoTeamsPrompt;

  /// No description provided for @twoTeamsDatabaseCandidates.
  ///
  /// In en, this message translates to:
  /// **'There are {count} stars in the database who played for both clubs'**
  String twoTeamsDatabaseCandidates(Object count);

  /// No description provided for @selectPlayerPlayerTurn.
  ///
  /// In en, this message translates to:
  /// **'Player {player}: Select Player'**
  String selectPlayerPlayerTurn(Object player);

  /// No description provided for @searchAndSelectPlayer.
  ///
  /// In en, this message translates to:
  /// **'Search & Select Player'**
  String get searchAndSelectPlayer;

  /// No description provided for @showAnswers.
  ///
  /// In en, this message translates to:
  /// **'Show Answers'**
  String get showAnswers;

  /// No description provided for @passRound.
  ///
  /// In en, this message translates to:
  /// **'Pass Turn'**
  String get passRound;

  /// No description provided for @newMatchup.
  ///
  /// In en, this message translates to:
  /// **'New Matchup'**
  String get newMatchup;

  /// No description provided for @bombExplodedTitle.
  ///
  /// In en, this message translates to:
  /// **'💥 BOOM! Bomb Exploded!'**
  String get bombExplodedTitle;

  /// No description provided for @bombWonTitle.
  ///
  /// In en, this message translates to:
  /// **'🏆 {winner} Won!'**
  String bombWonTitle(Object winner);

  /// No description provided for @bombEliminatedDesc.
  ///
  /// In en, this message translates to:
  /// **'The bomb exploded while in {player}\'s hands and was ELIMINATED!'**
  String bombEliminatedDesc(Object player);

  /// No description provided for @totalSuccessfulPasses.
  ///
  /// In en, this message translates to:
  /// **'Total Successful Passes: {count}'**
  String totalSuccessfulPasses(Object count);

  /// No description provided for @playerCount.
  ///
  /// In en, this message translates to:
  /// **'Player Count'**
  String get playerCount;

  /// No description provided for @bombPassAction.
  ///
  /// In en, this message translates to:
  /// **'Name a Player and Pass the Bomb!'**
  String get bombPassAction;

  /// No description provided for @imposterCaughtTitle.
  ///
  /// In en, this message translates to:
  /// **'🕵️ Imposter Caught! +{points} Points'**
  String imposterCaughtTitle(Object points);

  /// No description provided for @imposterWrongSuspect.
  ///
  /// In en, this message translates to:
  /// **'❌ Wrong Suspect!'**
  String get imposterWrongSuspect;

  /// No description provided for @imposterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select the footballer who NEVER played for this club:'**
  String get imposterPrompt;

  /// No description provided for @imposterBadgeNeverPlayed.
  ///
  /// In en, this message translates to:
  /// **'🕵️ IMPOSTER! Never Played'**
  String get imposterBadgeNeverPlayed;

  /// No description provided for @dailyStage1.
  ///
  /// In en, this message translates to:
  /// **'⚡ Stage 1: 2 Teams 1 Player'**
  String get dailyStage1;

  /// No description provided for @dailyStage2.
  ///
  /// In en, this message translates to:
  /// **'🧩 Stage 2: Who Am I?'**
  String get dailyStage2;

  /// No description provided for @dailyStage3.
  ///
  /// In en, this message translates to:
  /// **'🕵️ Stage 3: Find the Imposter'**
  String get dailyStage3;

  /// No description provided for @dailyStage4.
  ///
  /// In en, this message translates to:
  /// **'✈️ Stage 4: Transfer Path'**
  String get dailyStage4;

  /// No description provided for @dailyCompletedTournaments.
  ///
  /// In en, this message translates to:
  /// **'📅 COMPLETED DAILY TOURNAMENTS'**
  String get dailyCompletedTournaments;

  /// No description provided for @searchAndSubmitPlayer.
  ///
  /// In en, this message translates to:
  /// **'Search and Submit Player'**
  String get searchAndSubmitPlayer;

  /// No description provided for @twoTeamsPlayedBoth.
  ///
  /// In en, this message translates to:
  /// **'played for both {teamA} and {teamB}!'**
  String twoTeamsPlayedBoth(Object teamA, Object teamB);

  /// No description provided for @twoTeamsWrongBoth.
  ///
  /// In en, this message translates to:
  /// **'❌ {name} did not play for both {teamA} and {teamB}!'**
  String twoTeamsWrongBoth(Object name, Object teamA, Object teamB);

  /// No description provided for @feedbackDrawProposed.
  ///
  /// In en, this message translates to:
  /// **'{user} proposed a draw.'**
  String feedbackDrawProposed(Object user);

  /// No description provided for @feedbackDrawRejected.
  ///
  /// In en, this message translates to:
  /// **'Draw offer declined. Match continues!'**
  String get feedbackDrawRejected;

  /// No description provided for @feedbackDrawTimeout.
  ///
  /// In en, this message translates to:
  /// **'Draw offer timed out (30s).'**
  String get feedbackDrawTimeout;

  /// No description provided for @feedbackPassed.
  ///
  /// In en, this message translates to:
  /// **'{user} passed! Turn passes to opponent.'**
  String feedbackPassed(Object user);

  /// No description provided for @feedbackTimeExpired.
  ///
  /// In en, this message translates to:
  /// **'Time expired! Turn passed to opponent.'**
  String get feedbackTimeExpired;

  /// No description provided for @giveUpAction.
  ///
  /// In en, this message translates to:
  /// **'Give Up'**
  String get giveUpAction;

  /// No description provided for @clubLabel.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get clubLabel;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get statisticsTitle;

  /// No description provided for @playerDefault.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get playerDefault;

  /// No description provided for @guessMysteryPlayer.
  ///
  /// In en, this message translates to:
  /// **'Guess Mystery Player'**
  String get guessMysteryPlayer;

  /// No description provided for @secondsSuffix.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get secondsSuffix;

  /// Imposter question prompt
  ///
  /// In en, this message translates to:
  /// **'Which player NEVER played for {team}?'**
  String whichPlayerNeverPlayedFor(String team);

  /// Imposter answer explanation
  ///
  /// In en, this message translates to:
  /// **'{player} never played for {team} in their career (Clubs: {clubs}).'**
  String neverPlayedForTeamExplanation(
    String player,
    String team,
    String clubs,
  );

  /// Popular searches label in player search
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearches;

  /// Cell label
  ///
  /// In en, this message translates to:
  /// **'CELL'**
  String get cellLabel;

  /// Selected cell label
  ///
  /// In en, this message translates to:
  /// **'SELECTED CELL'**
  String get selectedCellLabel;

  /// Football bomb challenge team prompt
  ///
  /// In en, this message translates to:
  /// **'Name a footballer who played for {team}!'**
  String bombNamePlayerForTeam(String team);

  /// Football bomb challenge nationality prompt
  ///
  /// In en, this message translates to:
  /// **'Name a footballer from {nat}!'**
  String bombNamePlayerFromNationality(String nat);

  /// Football bomb challenge any player prompt
  ///
  /// In en, this message translates to:
  /// **'Name any footballer in the database!'**
  String get bombNameAnyPlayer;

  /// Clue 1: Nationality and Position
  ///
  /// In en, this message translates to:
  /// **'Nationality: {nat} | Position: {pos}'**
  String clueNationalityPosition(String nat, String pos);

  /// Clue 2: Career goals and assists
  ///
  /// In en, this message translates to:
  /// **'Recorded {goals} goals and {assists} assists in career (Overall: {ovr}).'**
  String clueCareerStats(String goals, String assists, String ovr);

  /// Clue 3: Clubs played for
  ///
  /// In en, this message translates to:
  /// **'Clubs played for: {clubs}'**
  String clueClubsPlayed(String clubs);

  /// Clue 5: Initials and name length
  ///
  /// In en, this message translates to:
  /// **'Initials: {initials} ({letters} letters)'**
  String clueInitialsAndLength(String initials, String letters);

  /// Help modal game modes explanation
  ///
  /// In en, this message translates to:
  /// **'Football SOS • 7 Game Modes:\n\n• Football SOS: 3x3 Grid (vs Smart Bot, 2P Duel & Online)\n• Rating Battle: 1P Streak & 2P Duel\n• 2 Teams 1 Player: Find the shared footballer\n• Who Am I?: Guess the mystery footballer from 5 clues\n• Imposter: Spot the player who never played for the club\n• Transfer Path: Identify the footballer from their career history\n• Football Bomb: Pass the bomb before time runs out!'**
  String get helpGameModesContent;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// Winner title
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winnerTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
