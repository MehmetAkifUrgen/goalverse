import 'package:cloud_firestore/cloud_firestore.dart';
import 'answer_validator_repository.dart';

class FirestoreAnswerValidatorRepository implements AnswerValidatorRepository {
  final FirebaseFirestore _firestore;
  final AnswerValidatorRepository? _localFallback;

  FirestoreAnswerValidatorRepository({
    FirebaseFirestore? firestore,
    AnswerValidatorRepository? localFallback,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _localFallback = localFallback;

  @override
  Future<bool> isPlayerInTeamPair(
    String playerId,
    String teamIdA,
    String teamIdB,
  ) async {
    if (_localFallback != null) {
      final localValid = await _localFallback.isPlayerInTeamPair(
        playerId,
        teamIdA,
        teamIdB,
      );
      if (localValid) return true;
    }

    try {
      final doc = await _firestore.collection('players').doc(playerId).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final clubs = List<String>.from(data['clubs'] ?? []);
        final hasA = clubs.contains(teamIdA);
        final hasB = clubs.contains(teamIdB);
        if (hasA && hasB) return true;
      }
    } catch (_) {}

    return false;
  }

  @override
  Future<List<String>> getPlayersForTeamPair(
    String teamIdA,
    String teamIdB,
  ) async {
    if (_localFallback != null) {
      final localPlayers = await _localFallback.getPlayersForTeamPair(
        teamIdA,
        teamIdB,
      );
      if (localPlayers.isNotEmpty) {
        return localPlayers;
      }
    }

    try {
      final snap = await _firestore
          .collection('players')
          .where('clubs', arrayContains: teamIdA)
          .limit(50)
          .get();

      final result = <String>[];
      for (final doc in snap.docs) {
        final clubs = List<String>.from(doc.data()['clubs'] ?? []);
        if (clubs.contains(teamIdB)) {
          result.add(doc.id);
        }
      }
      if (result.isNotEmpty) {
        return result;
      }
    } catch (_) {}

    return [];
  }
}
