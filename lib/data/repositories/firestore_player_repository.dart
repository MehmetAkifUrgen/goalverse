import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/freezed/entity_models.dart';
import 'player_repository.dart';
import 'rating_category.dart';

class FirestorePlayerRepository implements PlayerRepository {
  final FirebaseFirestore _firestore;
  final PlayerRepository? _localFallback;

  FirestorePlayerRepository({
    FirebaseFirestore? firestore,
    PlayerRepository? localFallback,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _localFallback = localFallback;

  @override
  Future<List<Player>> searchPlayers(String query, {int limit = 20}) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    // 1. Always search verified local dataset first (instant, complete stats/clues/clubs, zero duplicates)
    if (_localFallback != null) {
      final localResults = await _localFallback.searchPlayers(
        query,
        limit: limit,
      );
      if (localResults.isNotEmpty) {
        return localResults;
      }
    }

    try {
      final tokens = clean
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty)
          .toList();
      if (tokens.isEmpty) return [];

      final tokenSnap = await _firestore
          .collection('players')
          .where('searchTokens', arrayContains: tokens.first)
          .limit(limit * 2)
          .get();

      if (tokenSnap.docs.isNotEmpty) {
        final seen = <String>{};
        final deduped = <Player>[];
        for (final doc in tokenSnap.docs) {
          final p = _mapDocToPlayer(doc);
          if (RegExp(r'\d').hasMatch(p.name)) continue;
          final norm = (p.normalizedName.isNotEmpty ? p.normalizedName : p.name)
              .trim()
              .toLowerCase();
          if (seen.contains(norm)) continue;
          if (tokens.every((t) => norm.contains(t))) {
            seen.add(norm);
            deduped.add(p);
            if (deduped.length >= limit) break;
          }
        }
        return deduped;
      }
    } catch (e) {
      debugPrint('Firestore search error: $e');
    }

    return [];
  }

  @override
  Future<Player?> getById(String playerId) async {
    if (_localFallback != null) {
      final local = await _localFallback.getById(playerId);
      if (local != null) return local;
    }

    try {
      final doc = await _firestore.collection('players').doc(playerId).get();
      if (doc.exists) {
        return _mapDocToPlayer(doc);
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<List<Player>> getByIds(List<String> playerIds) async {
    if (playerIds.isEmpty) return [];
    if (_localFallback != null) {
      final local = await _localFallback.getByIds(playerIds);
      if (local.length == playerIds.length) return local;
    }

    try {
      final chunks = <List<String>>[];
      for (var i = 0; i < playerIds.length; i += 10) {
        chunks.add(
          playerIds.sublist(
            i,
            i + 10 > playerIds.length ? playerIds.length : i + 10,
          ),
        );
      }

      final results = <Player>[];
      for (final chunk in chunks) {
        final snap = await _firestore
            .collection('players')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        results.addAll(snap.docs.map(_mapDocToPlayer));
      }
      if (results.isNotEmpty) return results;
    } catch (_) {}

    if (_localFallback != null) {
      return _localFallback.getByIds(playerIds);
    }
    return [];
  }

  @override
  Future<List<Player>> searchPlayersWithClues(String query, {int limit = 20}) {
    return searchPlayers(query, limit: limit);
  }

  @override
  Future<Player?> getRandomWhoAmI({int? seed}) async {
    if (_localFallback != null) {
      return _localFallback.getRandomWhoAmI(seed: seed);
    }
    return null;
  }

  @override
  Future<(Player a, Player b)> getRandomRatingPair({
    RatingCategory? category,
    int? seed,
  }) async {
    if (_localFallback != null) {
      return _localFallback.getRandomRatingPair(category: category, seed: seed);
    }
    throw UnsupportedError('Rating pair requires local cache fallback.');
  }

  Player _mapDocToPlayer(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final clubsList =
        (data['clubs'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const [];
    return Player(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown',
      normalizedName: data['normalizedName'] as String? ?? '',
      nationality: data['nationality'] as String?,
      position: data['position'] as String?,
      eaFcOverall: (data['eaFcOverall'] as num?)?.toInt(),
      marketValueEuro: (data['marketValueEuro'] as num?)?.toInt(),
      photoAssetPath: data['photoUrl'] as String?,
      clubs: clubsList,
      verified: true,
    );
  }
}
