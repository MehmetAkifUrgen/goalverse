import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/freezed/entity_models.dart';
import '../../data/models/isar/answer_index_isar.dart';
import '../../data/models/isar/player_isar.dart';
import '../../data/models/isar/player_team_history_isar.dart';
import '../../data/models/isar/team_isar.dart';

class IsarDatabase {
  static final IsarDatabase instance = IsarDatabase._internal();
  IsarDatabase._internal();

  Isar? _isar;
  Future<Isar>? _openFuture;

  static const String _datasetVersionKey = 'DATASET_VERSION';

  Future<Isar> open() {
    if (_isar != null && _isar!.isOpen) {
      return Future.value(_isar!);
    }
    _openFuture ??= _doOpen();
    return _openFuture!;
  }

  Future<Isar> _doOpen() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar =
        Isar.getInstance() ??
        await Isar.open([
          PlayerIsarSchema,
          TeamIsarSchema,
          PlayerTeamHistoryIsarSchema,
          AnswerIndexIsarSchema,
        ], directory: dir.path);

    await initDb();
    return _isar!;
  }

  Isar get isar {
    if (_isar == null || !_isar!.isOpen) {
      throw StateError('Isar not opened. Call open() first.');
    }
    return _isar!;
  }

  Future<void> initDb() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(_datasetVersionKey);

    if (savedVersion == AppConstants.datasetVersion) {
      return;
    }

    await _clearAllCollections();
    await _loadDatasetFromAssets();

    await prefs.setInt(_datasetVersionKey, AppConstants.datasetVersion);
  }

  Future<void> _clearAllCollections() async {
    final current = _isar;
    if (current == null) return;

    await current.writeTxn(() async {
      await current.playerIsars.clear();
      await current.teamIsars.clear();
      await current.playerTeamHistoryIsars.clear();
      await current.answerIndexIsars.clear();
    });
  }

  Future<void> _loadDatasetFromAssets() async {
    final current = isar;

    final playersJson = await _loadAssetJson('assets/dataset/players.json');
    final teamsJson = await _loadAssetJson('assets/dataset/teams.json');
    final historyJson = await _loadAssetJson(
      'assets/dataset/player_team_history.json',
    );
    final answerIndexRaw = await rootBundle.loadString(
      'assets/dataset/answer_index.json',
    );
    final answerIndexJson = jsonDecode(answerIndexRaw) as Map<String, dynamic>;

    final List<Player> playersList = (playersJson as List)
        .map<Player>((dynamic e) => Player.fromJson(e as Map<String, dynamic>))
        .toList();

    final List<Team> teamsList = (teamsJson as List)
        .map<Team>((dynamic e) => Team.fromJson(e as Map<String, dynamic>))
        .toList();

    final List<PlayerTeamHistory> historyList = (historyJson as List)
        .map<PlayerTeamHistory>(
          (dynamic e) => PlayerTeamHistory.fromJson(e as Map<String, dynamic>),
        )
        .toList();

    final answerIndexEntries = <AnswerIndexIsar>[];
    answerIndexJson.forEach((key, value) {
      final playerIds = (value as List).cast<String>();
      answerIndexEntries.add(
        AnswerIndexIsar()
          ..teamPair = key
          ..playerIds = playerIds,
      );
    });

    await current.writeTxn(() async {
      final playerIsars = playersList.map((p) {
        return PlayerIsar()
          ..playerId = p.id
          ..name = p.name
          ..normalizedName = p.normalizedName
          ..aliases = p.aliases
          ..nationality = p.nationality
          ..position = p.position
          ..verified = p.verified
          ..eaFcOverall = p.eaFcOverall
          ..marketValueEuro = p.marketValueEuro
          ..age = p.age
          ..goalsCareer = p.goalsCareer
          ..assistsCareer = p.assistsCareer
          ..speedRating = p.speedRating
          ..clGoals = p.clGoals
          ..clues = p.clues
          ..photoAssetPath = p.photoAssetPath;
      }).toList();
      await current.playerIsars.putAll(playerIsars);

      final teamIsars = teamsList.map((t) {
        return TeamIsar()
          ..teamId = t.id
          ..name = t.name
          ..normalizedName = t.normalizedName
          ..aliases = t.aliases
          ..country = t.country
          ..verified = t.verified
          ..primaryColorHex = t.primaryColorHex
          ..secondaryColorHex = t.secondaryColorHex
          ..logoAssetPath = t.logoAssetPath
          ..kitAssetPath = t.kitAssetPath;
      }).toList();
      await current.teamIsars.putAll(teamIsars);

      final historyIsars = historyList.map((h) {
        return PlayerTeamHistoryIsar()
          ..playerId = h.playerId
          ..teamId = h.teamId
          ..seasonStart = h.seasonStart
          ..seasonEnd = h.seasonEnd
          ..verified = h.verified
          ..confidence = h.confidence;
      }).toList();
      await current.playerTeamHistoryIsars.putAll(historyIsars);

      await current.answerIndexIsars.putAll(answerIndexEntries);
    });
  }

  Future<dynamic> _loadAssetJson(String path) async {
    final raw = await rootBundle.loadString(path);
    return jsonDecode(raw);
  }
}
