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
