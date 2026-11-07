import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../data/repositories/answer_validator_repository.dart';
import '../data/repositories/firestore_answer_validator_repository.dart';
import '../data/repositories/firestore_player_repository.dart';
import '../data/repositories/firestore_team_repository.dart';
import '../data/repositories/player_repository.dart';
import '../data/repositories/team_repository.dart';
import '../data/repositories/web_data_store.dart';

/// Initializes the cross-platform in-memory dataset store (teams, players,
/// career history, and answer index) from bundled JSON assets on all platforms
/// (Android, iOS, macOS, and Web), avoiding Isar native FFI collection schema errors.
final isarDatabaseProvider = FutureProvider<Isar?>((ref) async {
  await WebDataStore.instance.init();
  return null;
});

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  ref.watch(isarDatabaseProvider);
  return FirestorePlayerRepository(
    localFallback: WebDataStore.instance.playerRepo,
  );
});

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  ref.watch(isarDatabaseProvider);
  return FirestoreTeamRepository(localFallback: WebDataStore.instance.teamRepo);
});

final answerValidatorRepositoryProvider = Provider<AnswerValidatorRepository>((
  ref,
) {
  ref.watch(isarDatabaseProvider);
  return FirestoreAnswerValidatorRepository(
    localFallback: WebDataStore.instance.answerRepo,
  );
});
