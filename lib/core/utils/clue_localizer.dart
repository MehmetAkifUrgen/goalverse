import 'package:flutter/widgets.dart';

import '../../data/models/freezed/entity_models.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'trivia_en.dart';

/// Multilingual clue generator for 'Who Am I?' and 'Daily Challenge' game modes.
/// Ensures zero Turkish leaks when playing in English, German, Spanish, French, or Italian.
class ClueLocalizer {
  ClueLocalizer._();

  /// Returns the localized clue for [player] at [clueIndex] (0 to 4).
  static String getClue(Player player, int clueIndex, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.maybeLocaleOf(context);
    final lang = (locale?.languageCode ?? 'tr').toLowerCase();

    switch (clueIndex) {
      case 0:
        return _buildClue0(player, lang, l10n);
      case 1:
        return _buildClue1(player, lang, l10n);
      case 2:
        return _buildClue2(player, lang, l10n);
      case 3:
        return _buildClue3(player, lang);
      case 4:
        return _buildClue4(player, lang, l10n);
      default:
        if (clueIndex < player.clues.length) {
          return player.clues[clueIndex];
        }
        return '';
    }
  }

  /// Clue 0: Nationality & Position
  static String _buildClue0(Player player, String lang, AppLocalizations? l10n) {
    final nat = player.nationality ?? '?';
    final flag = AppTheme.nationalityFlag(nat);
    final posName = getPositionName(player.position, lang);
    final natDisplay = '$flag $nat';

    if (l10n != null) {
      return l10n.clueNationalityPosition(natDisplay, posName);
    }

    switch (lang) {
      case 'en':
        return 'Nationality: $natDisplay | Position: $posName';
      case 'de':
        return 'Nationalität: $natDisplay | Position: $posName';
      case 'es':
        return 'Nacionalidad: $natDisplay | Posición: $posName';
      case 'fr':
        return 'Nationalité : $natDisplay | Poste : $posName';
      case 'it':
        return 'Nazionalità: $natDisplay | Ruolo: $posName';
      case 'tr':
      default:
        return 'Uyruk: $natDisplay | Mevki: $posName';
    }
  }

  /// Clue 1: Career Goals, Assists, and Overall
  static String _buildClue1(Player player, String lang, AppLocalizations? l10n) {
    final goals = (player.goalsCareer ?? 0).toString();
    final assists = (player.assistsCareer ?? 0).toString();
    final ovr = (player.eaFcOverall ?? 80).toString();

    if (l10n != null) {
      return l10n.clueCareerStats(goals, assists, ovr);
    }

    switch (lang) {
      case 'en':
        return 'Recorded $goals goals and $assists assists in career (Overall: $ovr).';
      case 'de':
        return 'Erzielte $goals Tore und $assists Vorlagen in der Karriere (Gesamt: $ovr).';
      case 'es':
        return 'Registró $goals goles y $assists asistencias en su carrera (Media: $ovr).';
      case 'fr':
        return 'A inscrit $goals buts et délivré $assists passes décisives en carrière (Général : $ovr).';
      case 'it':
        return 'Ha collezionato $goals gol e $assists assist in carriera (Totale: $ovr).';
      case 'tr':
      default:
        return 'Kariyerinde $goals gol ve $assists asist üretti (Overall: $ovr).';
    }
  }

  /// Clue 2: Clubs played for
  static String _buildClue2(Player player, String lang, AppLocalizations? l10n) {
    final clubs = player.clubs.isNotEmpty
        ? player.clubs.join(', ')
        : (player.clues.length > 2
            ? player.clues[2].replaceFirst(RegExp(r'^[^\:]+\:\s*'), '')
            : '');

    if (l10n != null) {
      return l10n.clueClubsPlayed(clubs);
    }

    switch (lang) {
      case 'en':
        return 'Clubs played for: $clubs';
      case 'de':
        return 'Vereine in der Karriere: $clubs';
      case 'es':
        return 'Clubes en los que jugó: $clubs';
      case 'fr':
        return 'Clubs où il a évolué : $clubs';
      case 'it':
        return 'Squadre in cui ha giocato: $clubs';
      case 'tr':
      default:
        return 'Oynadığı kulüpler: $clubs';
    }
  }

  /// Clue 3: Player Career Trivia & Highlights
  static String _buildClue3(Player player, String lang) {
    // If Turkish, use original Turkish clue
    if (lang == 'tr') {
      if (player.clues.length > 3 && player.clues[3].isNotEmpty) {
        return player.clues[3];
      }
    }

    // For EN, DE, ES, FR, IT: Use English trivia dictionary to prevent Turkish leaks
    final enTrivia = playerTriviaEn[player.id];
    if (enTrivia != null && enTrivia.isNotEmpty) {
      return enTrivia;
    }

    // Fallback to original clue if present
    if (player.clues.length > 3 && player.clues[3].isNotEmpty) {
      return player.clues[3];
    }

    return player.name;
  }

  /// Clue 4: Initials & Letter count
  static String _buildClue4(Player player, String lang, AppLocalizations? l10n) {
    final parts = player.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    final initials = parts.map((p) => '${p[0].toUpperCase()}.').join();
    final letterCount = player.name
        .replaceAll(RegExp(r'[^a-zA-Z0-9\u00C0-\u024F\u1E00-\u1EFF]'), '')
        .length
        .toString();

    if (l10n != null) {
      return l10n.clueInitialsAndLength(initials, letterCount);
    }

    switch (lang) {
      case 'en':
        return 'Initials: $initials ($letterCount letters)';
      case 'de':
        return 'Initialen: $initials ($letterCount Buchstaben)';
      case 'es':
        return 'Iniciales: $initials ($letterCount letras)';
      case 'fr':
        return 'Initiales : $initials ($letterCount lettres)';
      case 'it':
        return 'Iniziali: $initials ($letterCount lettere)';
      case 'tr':
      default:
        return 'Baş harfleri: $initials ($letterCount harfli)';
    }
  }

  /// Localized position title by position code (FW, MF, DF, GK).
  static String getPositionName(String? position, String lang) {
    final pos = (position ?? '').toUpperCase().trim();

    if (pos == 'FW' || pos.contains('FORVET') || pos.contains('HÜCUM')) {
      switch (lang) {
        case 'en':
          return 'Forward / Attacker';
        case 'de':
          return 'Stürmer / Angriff';
        case 'es':
          return 'Delantero / Atacante';
        case 'fr':
          return 'Attaquant';
        case 'it':
          return 'Attaccante';
        case 'tr':
        default:
          return 'Forvet / Hücum';
      }
    }

    if (pos == 'MF' || pos.contains('ORTA SAHA') || pos.contains('MID')) {
      switch (lang) {
        case 'en':
          return 'Midfielder';
        case 'de':
          return 'Mittelfeld';
        case 'es':
          return 'Centrocampista';
        case 'fr':
          return 'Milieu de terrain';
        case 'it':
          return 'Centrocampista';
        case 'tr':
        default:
          return 'Orta Saha';
      }
    }

    if (pos == 'DF' || pos.contains('DEFANS') || pos.contains('STOPER') || pos.contains('BEK')) {
      switch (lang) {
        case 'en':
          return 'Defender';
        case 'de':
          return 'Verteidiger';
        case 'es':
          return 'Defensa';
        case 'fr':
          return 'Défenseur';
        case 'it':
          return 'Difensore';
        case 'tr':
        default:
          return 'Defans / Stoper';
      }
    }

    if (pos == 'GK' || pos.contains('KALECI') || pos.contains('KALECİ')) {
      switch (lang) {
        case 'en':
          return 'Goalkeeper';
        case 'de':
          return 'Torwart';
        case 'es':
          return 'Portero';
        case 'fr':
          return 'Gardien de but';
        case 'it':
          return 'Portiere';
        case 'tr':
        default:
          return 'Kaleci';
      }
    }

    return pos.isNotEmpty ? pos : '-';
  }
}
