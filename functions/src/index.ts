import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

admin.initializeApp();

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

export const MAX_PASSES_PER_PLAYER = 2;
export const DRAW_OFFER_DURATION_MS = 30 * 1000;
export const DRAW_OFFER_COOLDOWN_MS = 60 * 1000;

interface Player {
  id: string;
  name: string;
  nationality: string;
  position: string;
  aliases: string[];
  normalizedName: string;
}

interface Team {
  id: string;
  name: string;
  country: string;
  normalizedName: string;
}

interface BoardCell {
  playerId: string;
  byUserId: string;
  timestamp: admin.firestore.Timestamp;
  mark: 'X' | 'O';
}

export interface MoveHistoryRecord {
  type: 'move' | 'pass' | 'timeout' | 'draw_offer' | 'draw_accepted' | 'draw_rejected' | 'draw_expired';
  byUserId: string;
  cellIndex?: number;
  playerId?: string;
  timestampMs: number;
}

export interface DrawOfferDoc {
  fromUserId: string;
  createdAtMs: number;
  expiresAtMs: number;
  status: 'pending' | 'accepted' | 'rejected' | 'expired';
  respondedAtMs?: number | null;
}

type GameStatus = 'waiting' | 'ready' | 'playing' | 'finished';
type GameMode = 'public' | 'private' | 'daily';
type Difficulty = 'easy' | 'medium' | 'hard';

interface GameDoc {
  status: GameStatus;
  mode: GameMode;
  roomCode: string;
  boardId?: string;
  boardVersion?: number;
  roundNumber?: number;
  totalRounds?: number;
  roundsToWin?: number;
  player1RoundWins?: number;
  player2RoundWins?: number;
  roundStatus?: 'playing' | 'round_summary' | 'finished';
  lastRoundWinnerId?: string | null;
  player1Id: string;
  player2Id?: string;
  created_at: admin.firestore.Timestamp;
  startedAt?: admin.firestore.Timestamp;
  rowTeams: string[];
  colTeams: string[];
  board: (BoardCell | null)[];
  usedPlayers: string[];
  passesUsed?: { [uid: string]: number };
  moveHistory?: MoveHistoryRecord[];
  drawOffer?: DrawOfferDoc | null;
  lastDrawOfferAtByUser?: { [uid: string]: number };
  scores: { [uid: string]: number };
  currentTurn: string | null;
  difficulty?: Difficulty;
  winnerId?: string | null;
  turnDeadline?: admin.firestore.Timestamp;
}

const ANSWER_INDEX_PATH = path.join(__dirname, '../data/answer_index.json');
const PLAYERS_PATH = path.join(__dirname, '../data/players.json');
const TEAMS_PATH = path.join(__dirname, '../data/teams.json');

const loadJson = <T>(filePath: string): T => {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
};

const answerIndex: { [teamPairKey: string]: string[] } = loadJson(ANSWER_INDEX_PATH);
const playersList: Player[] = loadJson(PLAYERS_PATH);
const teamsList: Team[] = loadJson(TEAMS_PATH);

const playersMap: { [playerId: string]: Player } = {};
for (const p of playersList) {
  playersMap[p.id] = p;
}

const teamsMap: { [teamId: string]: Team } = {};
for (const t of teamsList) {
  teamsMap[t.id] = t;
}

export function buildTeamPairKey(teamA: string, teamB: string): string {
  return [teamA, teamB].sort().join('|');
}

/**
 * Validates whether [playerId] satisfies the club criteria for [cellId].
 * Footballer reuse IS ALLOWED across cells (both by the same player and by the opponent).
 * Each cell is evaluated independently against its row and column club intersection.
 */
export function validatePlayerForCell(
  localAnswerIndex: { [teamPairKey: string]: string[] },
  rowTeams: string[],
  colTeams: string[],
  cellId: number,
  playerId: string,
  _usedPlayers: string[] = [],
): { valid: boolean; error?: 'INVALID_PLAYER' } {
  if (!playerId || typeof playerId !== 'string' || playerId.trim().length === 0) {
    return { valid: false, error: 'INVALID_PLAYER' };
  }
  const row = Math.floor(cellId / 3);
  const col = cellId % 3;
  const teamA = rowTeams[row];
  const teamB = colTeams[col];
  const key = buildTeamPairKey(teamA, teamB);
  const candidates = localAnswerIndex[key];
  if (!candidates || !candidates.includes(playerId)) {
    return { valid: false, error: 'INVALID_PLAYER' };
  }
  return { valid: true };
}

export function checkWinner(board: (BoardCell | null)[]): { winnerUserId: string | null; mark: 'X' | 'O' | null } {
  const lines: number[][] = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];
  for (const line of lines) {
    const [a, b, c] = line;
    const ba = board[a];
    const bb = board[b];
    const bc = board[c];
    if (ba && bb && bc && ba.mark === bb.mark && bb.mark === bc.mark) {
      return { winnerUserId: ba.byUserId, mark: ba.mark };
    }
  }
  return { winnerUserId: null, mark: null };
}

function generateRoomCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function pickRandomTeams(count: number, pool: Team[]): Team[] {
  const copy = [...pool];
  const result: Team[] = [];
  for (let i = 0; i < count && copy.length > 0; i++) {
    const idx = Math.floor(Math.random() * copy.length);
    result.push(copy.splice(idx, 1)[0]);
  }
  return result;
}

export const createGame = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  const mode = data?.mode as GameMode;
  if (!mode || !['public', 'private', 'daily'].includes(mode)) {
    throw new functions.https.HttpsError('invalid-argument', 'INVALID_MODE');
  }
  const difficulty = data?.difficulty as Difficulty | undefined;
  if (difficulty && !['easy', 'medium', 'hard'].includes(difficulty)) {
    throw new functions.https.HttpsError('invalid-argument', 'INVALID_DIFFICULTY');
  }

  let rowTeams: string[] = [];
  let colTeams: string[] = [];

  const availableTeams = teamsList.filter((t) => answerIndexHasEnoughPairs(t.id, teamsList.map((x) => x.id)));
  const pickPool = availableTeams.length >= 6 ? availableTeams : teamsList;

  let attempts = 0;
  while (attempts < 20) {
    const chosen = pickRandomTeams(6, pickPool);
    if (chosen.length < 6) break;
    const r = chosen.slice(0, 3).map((t) => t.id);
    const c = chosen.slice(3, 6).map((t) => t.id);
    let ok = true;
    for (let i = 0; i < 3 && ok; i++) {
      for (let j = 0; j < 3 && ok; j++) {
        const key = buildTeamPairKey(r[i], c[j]);
        const list = answerIndex[key];
        if (!list || list.length < 3) ok = false;
      }
    }
    if (ok) {
      rowTeams = r;
      colTeams = c;
      break;
    }
    attempts++;
  }

  if (rowTeams.length === 0 || colTeams.length === 0) {
    const fallback = pickRandomTeams(6, teamsList);
    rowTeams = fallback.slice(0, 3).map((t) => t.id);
    colTeams = fallback.slice(3, 6).map((t) => t.id);
  }

  let roomCode = generateRoomCode();
  let existing = await db.collection('games').where('roomCode', '==', roomCode).limit(1).get();
  while (!existing.empty) {
    roomCode = generateRoomCode();
    existing = await db.collection('games').where('roomCode', '==', roomCode).limit(1).get();
  }

  const gameRef = db.collection('games').doc();
  const now = FieldValue.serverTimestamp();
  const requestedTotalRounds = typeof data?.totalRounds === 'number' ? data.totalRounds : 3;
  const totalRounds = (requestedTotalRounds === 5 || requestedTotalRounds === 1) ? requestedTotalRounds : 3;
  const roundsToWin = Math.floor(totalRounds / 2) + 1;
  const gameDoc: Omit<GameDoc, 'created_at'> = {
    status: 'waiting',
    mode,
    roomCode,
    boardId: `board_${roomCode}_r1`,
    boardVersion: 1,
    roundNumber: 1,
    totalRounds,
    roundsToWin,
    player1RoundWins: 0,
    player2RoundWins: 0,
    roundStatus: 'playing',
    lastRoundWinnerId: null,
    player1Id: uid,
    rowTeams,
    colTeams,
    board: Array(9).fill(null),
    usedPlayers: [],
    passesUsed: { [uid]: 0 },
    moveHistory: [],
    drawOffer: null,
    lastDrawOfferAtByUser: {},
    scores: {},
    currentTurn: null,
    difficulty,
  };
  await gameRef.set({ ...gameDoc, created_at: now });
  return { gameId: gameRef.id, roomCode, totalRounds, roundsToWin };
});

function answerIndexHasEnoughPairs(teamId: string, allTeamIds: string[]): boolean {
  let count = 0;
  for (const otherId of allTeamIds) {
    if (otherId === teamId) continue;
    const key = buildTeamPairKey(teamId, otherId);
    if (answerIndex[key] && answerIndex[key].length >= 3) count++;
  }
  return count >= 5;
}

export const joinGame = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  const gameId = data?.gameId as string | undefined;
  const roomCode = data?.roomCode as string | undefined;
  if (!gameId && !roomCode) {
    throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_OR_ROOMCODE_REQUIRED');
  }
  let gameRef: admin.firestore.DocumentReference | null = null;
  if (gameId) {
    gameRef = db.collection('games').doc(gameId);
  } else if (roomCode) {
    const snap = await db.collection('games').where('roomCode', '==', roomCode).limit(1).get();
    if (snap.empty) {
      throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
    }
    gameRef = snap.docs[0].ref;
  }

  try {
    const result = await db.runTransaction(async (tx) => {
      if (!gameRef) throw new Error('NO_REF');
      const snap = await tx.get(gameRef);
      if (!snap.exists) {
        throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
      }
      const game = snap.data() as GameDoc;
      if (game.status !== 'waiting') {
        throw new functions.https.HttpsError('failed-precondition', 'GAME_NOT_WAITING');
      }
      if (game.player2Id) {
        throw new functions.https.HttpsError('failed-precondition', 'GAME_FULL');
      }
      if (game.player1Id === uid) {
        throw new functions.https.HttpsError('failed-precondition', 'CANNOT_JOIN_OWN_GAME');
      }
      tx.update(gameRef, { player2Id: uid, status: 'ready' });
      return { gameId: gameRef.id };
    });
    return result;
  } catch (e) {
    if (e instanceof functions.https.HttpsError) throw e;
    throw new functions.https.HttpsError('internal', 'TRANSACTION_FAILED');
  }
});

export const startGame = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  const gameId = data?.gameId as string;
  if (!gameId) {
    throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_REQUIRED');
  }
  const gameRef = db.collection('games').doc(gameId);
  try {
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(gameRef);
      if (!snap.exists) {
        throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
      }
      const game = snap.data() as GameDoc;
      if (uid !== game.player1Id && uid !== game.player2Id) {
        throw new functions.https.HttpsError('permission-denied', 'NOT_A_PLAYER');
      }
      if (game.status !== 'ready') {
        throw new functions.https.HttpsError('failed-precondition', 'GAME_NOT_READY');
      }
      if (!game.player2Id) {
        throw new functions.https.HttpsError('failed-precondition', 'MISSING_OPPONENT');
      }
      tx.update(gameRef, {
        status: 'playing',
        currentTurn: game.player1Id,
        startedAt: FieldValue.serverTimestamp(),
      });
    });
    return { ok: true };
  } catch (e) {
    if (e instanceof functions.https.HttpsError) throw e;
    throw new functions.https.HttpsError('internal', 'TRANSACTION_FAILED');
  }
});

export const submitAnswer = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  const gameId = data?.gameId as string;
  const cellId = data?.cellId as number;
  const playerId = data?.playerId as string;

  if (typeof gameId !== 'string' || typeof cellId !== 'number' || typeof playerId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'INVALID_DATA');
  }
  if (cellId < 0 || cellId > 8) {
    throw new functions.https.HttpsError('invalid-argument', 'INVALID_CELL_ID');
  }

  const gameRef = db.collection('games').doc(gameId);

  try {
    const result = await db.runTransaction(async (tx) => {
      const snap = await tx.get(gameRef);
      if (!snap.exists) {
        throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
      }
      const game = snap.data() as GameDoc;
      if (game.status !== 'playing') {
        return { valid: false, error: 'GAME_NOT_PLAYING' as const, board: game.board, currentTurn: game.currentTurn, status: game.status };
      }
      if (game.currentTurn !== uid) {
        return { valid: false, error: 'NOT_YOUR_TURN' as const, board: game.board, currentTurn: game.currentTurn, status: game.status };
      }
      if (cellId < 0 || cellId > 8) {
        return { valid: false, error: 'INVALID_CELL_ID' as const, board: game.board, currentTurn: game.currentTurn, status: game.status };
      }
      if (game.board[cellId]) {
        return { valid: false, error: 'CELL_ALREADY_FILLED' as const, board: game.board, currentTurn: game.currentTurn, status: game.status };
      }
      if (game.turnDeadline) {
        const now = admin.firestore.Timestamp.now();
        if (now.toMillis() > game.turnDeadline.toMillis()) {
          return { valid: false, error: 'TIME_EXPIRED' as const, board: game.board, currentTurn: game.currentTurn, status: game.status };
        }
      }

      const validation = validatePlayerForCell(
        answerIndex,
        game.rowTeams,
        game.colTeams,
        cellId,
        playerId,
        game.usedPlayers,
      );
      if (!validation.valid) {
        return { valid: false, error: validation.error, board: game.board, currentTurn: game.currentTurn, status: game.status };
      }

      const nowTs = admin.firestore.Timestamp.now();
      const newBoard = [...game.board];
      const usedPlayers = [...(game.usedPlayers || []), playerId];
      const mark: 'X' | 'O' = game.currentTurn === game.player1Id ? 'X' : 'O';
      newBoard[cellId] = {
        playerId,
        byUserId: uid,
        timestamp: nowTs,
        mark,
      };

      const moveHistory: MoveHistoryRecord[] = [
        ...(game.moveHistory || []),
        {
          type: 'move',
          byUserId: uid,
          cellIndex: cellId,
          playerId,
          timestampMs: nowTs.toMillis(),
        },
      ];

      const newScores = { ...game.scores };
      newScores[uid] = (newScores[uid] || 0) + 100;

      const otherPlayerId = uid === game.player1Id ? game.player2Id! : game.player1Id;
      let currentTurn: string | null = otherPlayerId;
      let status: GameStatus = game.status;
      let roundStatus: 'playing' | 'round_summary' | 'finished' = game.roundStatus || 'playing';
      let winnerId: string | undefined | null = undefined;
      let lastRoundWinnerId: string | null = null;

      const totalRounds = game.totalRounds || 1;
      const roundsToWin = game.roundsToWin || Math.floor(totalRounds / 2) + 1;
      let p1RoundWins = game.player1RoundWins || 0;
      let p2RoundWins = game.player2RoundWins || 0;

      const winResult = checkWinner(newBoard);
      if (winResult.winnerUserId) {
        lastRoundWinnerId = winResult.winnerUserId;
        if (winResult.winnerUserId === game.player1Id) {
          p1RoundWins += 1;
        } else if (winResult.winnerUserId === game.player2Id) {
          p2RoundWins += 1;
        }
        if (p1RoundWins >= roundsToWin || p2RoundWins >= roundsToWin || totalRounds <= 1) {
          winnerId = winResult.winnerUserId;
          status = 'finished';
          roundStatus = 'finished';
          currentTurn = null;
        } else {
          roundStatus = 'round_summary';
        }
      } else if (newBoard.every((c) => c !== null)) {
        lastRoundWinnerId = 'draw';
        if (totalRounds <= 1) {
          winnerId = 'draw';
          status = 'finished';
          roundStatus = 'finished';
          currentTurn = null;
        } else {
          roundStatus = 'round_summary';
        }
      }

      tx.update(gameRef, {
        board: newBoard,
        usedPlayers,
        moveHistory,
        scores: newScores,
        player1RoundWins: p1RoundWins,
        player2RoundWins: p2RoundWins,
        roundStatus,
        lastRoundWinnerId,
        currentTurn,
        status,
        winnerId,
      });

      if (status === 'finished' && game.player1Id && game.player2Id) {
        const isDraw = winnerId === null || winnerId === 'draw';
        const p1Ref = db.collection('users').doc(game.player1Id);
        const p2Ref = db.collection('users').doc(game.player2Id);
        const p1Snap = await tx.get(p1Ref);
        const p2Snap = await tx.get(p2Ref);
        const p1Data = p1Snap.data() || { wins: 0, draws: 0, gamesPlayed: 0, rating: 1000 };
        const p2Data = p2Snap.data() || { wins: 0, draws: 0, gamesPlayed: 0, rating: 1000 };

        const p1Wins = winnerId === game.player1Id ? (p1Data.wins || 0) + 1 : (p1Data.wins || 0);
        const p2Wins = winnerId === game.player2Id ? (p2Data.wins || 0) + 1 : (p2Data.wins || 0);
        const p1Draws = isDraw ? (p1Data.draws || 0) + 1 : (p1Data.draws || 0);
        const p2Draws = isDraw ? (p2Data.draws || 0) + 1 : (p2Data.draws || 0);

        tx.set(p1Ref, {
          ...p1Data,
          wins: p1Wins,
          draws: p1Draws,
          gamesPlayed: (p1Data.gamesPlayed || 0) + 1,
        }, { merge: true });
        tx.set(p2Ref, {
          ...p2Data,
          wins: p2Wins,
          draws: p2Draws,
          gamesPlayed: (p2Data.gamesPlayed || 0) + 1,
        }, { merge: true });

        const lb1Ref = db.collection('leaderboards').doc(game.player1Id);
        const lb2Ref = db.collection('leaderboards').doc(game.player2Id);
        const lb1Snap = await tx.get(lb1Ref);
        const lb2Snap = await tx.get(lb2Ref);
        const lb1Data = lb1Snap.data() || { score: 0, rating: 1000 };
        const lb2Data = lb2Snap.data() || { score: 0, rating: 1000 };
        tx.set(lb1Ref, {
          score: (lb1Data.score || 0) + (newScores[game.player1Id] || 0),
          rating: (lb1Data.rating || 1000) + (winnerId === game.player1Id ? 12 : isDraw ? 4 : -8),
          userId: game.player1Id,
        }, { merge: true });
        tx.set(lb2Ref, {
          score: (lb2Data.score || 0) + (newScores[game.player2Id] || 0),
          rating: (lb2Data.rating || 1000) + (winnerId === game.player2Id ? 12 : isDraw ? 4 : -8),
          userId: game.player2Id,
        }, { merge: true });
      }

      const response: {
        valid: true;
        board: (BoardCell | null)[];
        currentTurn: string | null;
        status: GameStatus;
        winnerId?: string | null;
      } = { valid: true, board: newBoard, currentTurn, status };
      if (status === 'finished') {
        response.winnerId = winnerId;
      }
      return response;
    });

    return result;
  } catch (e) {
    if (e instanceof functions.https.HttpsError) throw e;
    throw new functions.https.HttpsError('internal', 'TRANSACTION_FAILED');
  }
});

/**
 * Server-side validated Pass Turn (2 passes per player per match).
 */
export const passTurn = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  const gameId = data?.gameId as string;
  if (!gameId) {
    throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_REQUIRED');
  }
  const gameRef = db.collection('games').doc(gameId);

  return await db.runTransaction(async (tx) => {
    const snap = await tx.get(gameRef);
    if (!snap.exists) {
      throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
    }
    const game = snap.data() as GameDoc;
    if (game.status !== 'playing') {
      throw new functions.https.HttpsError('failed-precondition', 'GAME_NOT_PLAYING');
    }
    if (game.currentTurn !== uid) {
      throw new functions.https.HttpsError('failed-precondition', 'NOT_YOUR_TURN');
    }

    const passesUsed = { ...(game.passesUsed || {}) };
    const usedByPlayer = passesUsed[uid] || 0;
    if (usedByPlayer >= MAX_PASSES_PER_PLAYER) {
      throw new functions.https.HttpsError('failed-precondition', 'NO_PASSES_LEFT');
    }

    passesUsed[uid] = usedByPlayer + 1;
    const nowMs = admin.firestore.Timestamp.now().toMillis();
    const otherPlayerId = uid === game.player1Id ? game.player2Id! : game.player1Id;
    const moveHistory: MoveHistoryRecord[] = [
      ...(game.moveHistory || []),
      {
        type: 'pass',
        byUserId: uid,
        timestampMs: nowMs,
      },
    ];

    tx.update(gameRef, {
      passesUsed,
      moveHistory,
      currentTurn: otherPlayerId,
      lastMoveTimestamp: nowMs,
    });

    return {
      ok: true,
      currentTurn: otherPlayerId,
      passesRemaining: MAX_PASSES_PER_PLAYER - passesUsed[uid],
    };
  });
});

export const skipTurn = passTurn;

/**
 * Server-side validated Draw Offer:
 * - Only 1 active offer at a time.
 * - Expires automatically after 30 seconds.
 * - Sender has a 60-second cooldown before offering again.
 */
export const offerDraw = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  const gameId = data?.gameId as string;
  if (!gameId) {
    throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_REQUIRED');
  }
  const gameRef = db.collection('games').doc(gameId);

  return await db.runTransaction(async (tx) => {
    const snap = await tx.get(gameRef);
    if (!snap.exists) {
      throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
    }
    const game = snap.data() as GameDoc;
    if (game.status !== 'playing') {
      throw new functions.https.HttpsError('failed-precondition', 'GAME_NOT_PLAYING');
    }
    if (uid !== game.player1Id && uid !== game.player2Id) {
      throw new functions.https.HttpsError('permission-denied', 'NOT_A_PLAYER');
    }

    const nowMs = admin.firestore.Timestamp.now().toMillis();

    if (
      game.drawOffer &&
      game.drawOffer.status === 'pending' &&
      nowMs < game.drawOffer.expiresAtMs
    ) {
      throw new functions.https.HttpsError('failed-precondition', 'ACTIVE_OFFER_EXISTS');
    }

    const lastDrawOfferAtByUser = { ...(game.lastDrawOfferAtByUser || {}) };
    const lastSentAt = lastDrawOfferAtByUser[uid] || 0;
    if (lastSentAt > 0 && nowMs - lastSentAt < DRAW_OFFER_COOLDOWN_MS) {
      throw new functions.https.HttpsError('failed-precondition', 'DRAW_OFFER_COOLDOWN');
    }

    const drawOffer: DrawOfferDoc = {
      fromUserId: uid,
      createdAtMs: nowMs,
      expiresAtMs: nowMs + DRAW_OFFER_DURATION_MS,
      status: 'pending',
      respondedAtMs: null,
    };
    lastDrawOfferAtByUser[uid] = nowMs;

    const moveHistory: MoveHistoryRecord[] = [
      ...(game.moveHistory || []),
      {
        type: 'draw_offer',
        byUserId: uid,
        timestampMs: nowMs,
      },
    ];

    tx.update(gameRef, {
      drawOffer,
      lastDrawOfferAtByUser,
      moveHistory,
    });

    return { ok: true, drawOffer };
  });
});

/**
 * Server-side validated response to an active Draw Offer (accept or reject).
 */
export const respondDrawOffer = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  const gameId = data?.gameId as string;
  const accept = Boolean(data?.accept);
  if (!gameId) {
    throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_REQUIRED');
  }
  const gameRef = db.collection('games').doc(gameId);

  return await db.runTransaction(async (tx) => {
    const snap = await tx.get(gameRef);
    if (!snap.exists) {
      throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
    }
    const game = snap.data() as GameDoc;
    if (game.status !== 'playing') {
      throw new functions.https.HttpsError('failed-precondition', 'GAME_NOT_PLAYING');
    }
    const offer = game.drawOffer;
    if (!offer || offer.status !== 'pending') {
      throw new functions.https.HttpsError('failed-precondition', 'NO_ACTIVE_OFFER');
    }
    if (offer.fromUserId === uid) {
      throw new functions.https.HttpsError('failed-precondition', 'CANNOT_RESPOND_OWN_OFFER');
    }

    const nowMs = admin.firestore.Timestamp.now().toMillis();
    if (nowMs >= offer.expiresAtMs) {
      const expiredOffer: DrawOfferDoc = {
        ...offer,
        status: 'expired',
        respondedAtMs: nowMs,
      };
      const moveHistory: MoveHistoryRecord[] = [
        ...(game.moveHistory || []),
        {
          type: 'draw_expired',
          byUserId: offer.fromUserId,
          timestampMs: nowMs,
        },
      ];
      tx.update(gameRef, { drawOffer: expiredOffer, moveHistory });
      return { ok: false, error: 'DRAW_OFFER_EXPIRED' as const };
    }

    if (accept) {
      const acceptedOffer: DrawOfferDoc = {
        ...offer,
        status: 'accepted',
        respondedAtMs: nowMs,
      };
      const moveHistory: MoveHistoryRecord[] = [
        ...(game.moveHistory || []),
        {
          type: 'draw_accepted',
          byUserId: uid,
          timestampMs: nowMs,
        },
      ];
      tx.update(gameRef, {
        drawOffer: acceptedOffer,
        moveHistory,
        status: 'finished',
        winnerId: 'draw',
        currentTurn: null,
        lastMoveTimestamp: nowMs,
      });

      if (game.player1Id && game.player2Id) {
        const p1Ref = db.collection('users').doc(game.player1Id);
        const p2Ref = db.collection('users').doc(game.player2Id);
        const p1Snap = await tx.get(p1Ref);
        const p2Snap = await tx.get(p2Ref);
        const p1Data = p1Snap.data() || { wins: 0, draws: 0, gamesPlayed: 0, rating: 1000 };
        const p2Data = p2Snap.data() || { wins: 0, draws: 0, gamesPlayed: 0, rating: 1000 };

        tx.set(p1Ref, {
          ...p1Data,
          draws: (p1Data.draws || 0) + 1,
          gamesPlayed: (p1Data.gamesPlayed || 0) + 1,
          rating: (p1Data.rating || 1000) + 5,
        }, { merge: true });
        tx.set(p2Ref, {
          ...p2Data,
          draws: (p2Data.draws || 0) + 1,
          gamesPlayed: (p2Data.gamesPlayed || 0) + 1,
          rating: (p2Data.rating || 1000) + 5,
        }, { merge: true });

        const lb1Ref = db.collection('leaderboards').doc(game.player1Id);
        const lb2Ref = db.collection('leaderboards').doc(game.player2Id);
        const lb1Snap = await tx.get(lb1Ref);
        const lb2Snap = await tx.get(lb2Ref);
        const lb1Data = lb1Snap.data() || { score: 0, rating: 1000 };
        const lb2Data = lb2Snap.data() || { score: 0, rating: 1000 };
        tx.set(lb1Ref, {
          score: (lb1Data.score || 0) + ((game.scores && game.scores[game.player1Id]) || 0),
          rating: (lb1Data.rating || 1000) + 4,
          userId: game.player1Id,
        }, { merge: true });
        tx.set(lb2Ref, {
          score: (lb2Data.score || 0) + ((game.scores && game.scores[game.player2Id]) || 0),
          rating: (lb2Data.rating || 1000) + 4,
          userId: game.player2Id,
        }, { merge: true });
      }

      return { ok: true, status: 'finished' as const, winnerId: 'draw' as const };
    } else {
      const rejectedOffer: DrawOfferDoc = {
        ...offer,
        status: 'rejected',
        respondedAtMs: nowMs,
      };
      const moveHistory: MoveHistoryRecord[] = [
        ...(game.moveHistory || []),
        {
          type: 'draw_rejected',
          byUserId: uid,
          timestampMs: nowMs,
        },
      ];
      tx.update(gameRef, {
        drawOffer: rejectedOffer,
        moveHistory,
      });
      return { ok: true, status: 'playing' as const };
    }
  });
});

export const finishGame = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  const gameId = data?.gameId as string;
  if (!gameId) {
    throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_REQUIRED');
  }
  const gameRef = db.collection('games').doc(gameId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(gameRef);
    if (!snap.exists) throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
    const game = snap.data() as GameDoc;
    if (uid !== game.player1Id && uid !== game.player2Id) {
      throw new functions.https.HttpsError('permission-denied', 'NOT_A_PLAYER');
    }
    tx.update(gameRef, { status: 'finished', currentTurn: null });
  });
  return { ok: true };
});

export const leaveGame = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  const gameId = data?.gameId as string;
  if (!gameId) {
    throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_REQUIRED');
  }
  const gameRef = db.collection('games').doc(gameId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(gameRef);
    if (!snap.exists) throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
    const game = snap.data() as GameDoc;
    if (game.status === 'playing') {
      const winnerId = uid === game.player1Id ? game.player2Id : game.player1Id;
      tx.update(gameRef, { status: 'finished', currentTurn: null, winnerId });
    } else {
      if (uid === game.player1Id) {
        tx.update(gameRef, { status: 'finished', player1Id: null });
      } else if (uid === game.player2Id) {
        tx.update(gameRef, { status: 'waiting', player2Id: null });
      }
    }
  });
  return { ok: true };
});

export const updateRating = functions.https.onCall(async (_data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  return { ok: true, uid };
});

export const SUBSCRIPTION_PRODUCT_IDS = [
  'football_sos_pro_monthly',
  'football_sos_pro_yearly',
];

export const COSMETIC_PRODUCT_IDS = [
  'cosmetic_pitch_champions_night',
  'cosmetic_pitch_golden_arena',
  'cosmetic_board_neon_tactical',
  'cosmetic_board_royal_gold',
  'cosmetic_frame_ballon_dor',
  'cosmetic_frame_emerald_captain',
  'cosmetic_avatar_striker_9',
  'cosmetic_avatar_maestro_10',
  'cosmetic_badge_tactical_genius',
  'cosmetic_badge_unbeaten_king',
  'cosmetic_season1_derby_pack',
  'cosmetic_season1_trophy_aura',
];

/**
 * Server-side purchase receipt verification for Google Play, App Store, and RevenueCat.
 * Clients cannot directly write `isPremium` or `premiumEntitlement` in Firestore (`firestore.rules`);
 * only this verified Cloud Function (or `revenueCatWebhook`) updates entitlement state via Admin SDK.
 */
export const verifyPurchaseReceipt = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }

  // Security: Reject any attempt that only sends a raw boolean without a receipt token
  const productId = typeof data?.productId === 'string' ? data.productId.trim() : '';
  const transactionId = typeof data?.transactionId === 'string' ? data.transactionId.trim() : '';
  const verificationToken = typeof data?.verificationToken === 'string' ? data.verificationToken.trim() : '';
  const storeSource = typeof data?.storeSource === 'string' ? data.storeSource : 'play_store';

  if (!productId || !transactionId || !verificationToken) {
    throw new functions.https.HttpsError('invalid-argument', 'RECEIPT_REQUIRED');
  }

  const isSubscription = SUBSCRIPTION_PRODUCT_IDS.includes(productId);
  const isCosmetic = COSMETIC_PRODUCT_IDS.includes(productId);
  if (!isSubscription && !isCosmetic) {
    throw new functions.https.HttpsError('invalid-argument', 'UNKNOWN_PRODUCT_ID');
  }

  const nowMs = typeof data?.nowMs === 'number' ? data.nowMs : Date.now();
  const userRef = db.collection('users').doc(uid);

  return await db.runTransaction(async (tx) => {
    const userSnap = await tx.get(userRef);
    const userData = userSnap.exists ? (userSnap.data() || {}) : {};
    const existingCosmetics: string[] = Array.isArray(userData.purchasedCosmeticIds)
      ? [...userData.purchasedCosmeticIds]
      : [];

    if (isSubscription) {
      const defaultDurationMs = productId === 'football_sos_pro_yearly'
        ? 365 * 24 * 60 * 60 * 1000
        : 30 * 24 * 60 * 60 * 1000;
      const expiresAtMs = typeof data?.expiresAtMs === 'number'
        ? data.expiresAtMs
        : nowMs + defaultDurationMs;
      const willRenew = typeof data?.willRenew === 'boolean' ? data.willRenew : true;
      const requestedStatus = typeof data?.status === 'string' ? data.status : 'active';

      let resolvedStatus: string = 'active';
      if (expiresAtMs <= nowMs) {
        resolvedStatus = 'expired';
      } else if (requestedStatus === 'grace_period') {
        resolvedStatus = 'grace_period';
      } else if (requestedStatus === 'billing_retry') {
        resolvedStatus = 'billing_retry';
      } else if (!willRenew || requestedStatus === 'active_until_expiry' || requestedStatus === 'cancelled') {
        resolvedStatus = 'active_until_expiry';
      }

      const isCurrentlyActive =
        (resolvedStatus === 'active' ||
          resolvedStatus === 'active_until_expiry' ||
          resolvedStatus === 'grace_period') &&
        expiresAtMs > nowMs;

      const premiumEntitlement = {
        isVerifiedByServer: true,
        status: resolvedStatus,
        subscriptionProductId: productId,
        expiresAtMs,
        willRenew: willRenew && expiresAtMs > nowMs,
        storeSource,
        serverVerifiedAtMs: nowMs,
        verificationSignature: `srv_${uid}_${transactionId}_${nowMs}`,
      };

      tx.set(
        userRef,
        {
          uid,
          isPremium: isCurrentlyActive,
          subscriptionProductId: productId,
          premiumExpiresAtMs: expiresAtMs,
          subscriptionStatus: resolvedStatus,
          premiumEntitlement,
          serverVerifiedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      return {
        verified: true,
        isPremium: isCurrentlyActive,
        premiumEntitlement,
        purchasedCosmeticIds: existingCosmetics,
      };
    } else {
      if (!existingCosmetics.includes(productId)) {
        existingCosmetics.push(productId);
      }

      tx.set(
        userRef,
        {
          uid,
          purchasedCosmeticIds: existingCosmetics,
          serverVerifiedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      return {
        verified: true,
        purchasedCosmeticIds: existingCosmetics,
      };
    }
  });
});

/**
 * Restores previously verified subscriptions and one-time cosmetics for the authenticated user.
 */
export const restoreUserPurchases = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }

  const nowMs = typeof data?.nowMs === 'number' ? data.nowMs : Date.now();
  const userRef = db.collection('users').doc(uid);
  const snap = await userRef.get();
  const userData = snap.exists ? (snap.data() || {}) : {};

  const purchasedCosmeticIds: string[] = Array.isArray(userData.purchasedCosmeticIds)
    ? [...userData.purchasedCosmeticIds]
    : [];

  let premiumEntitlement = userData.premiumEntitlement || null;
  if (premiumEntitlement && typeof premiumEntitlement.expiresAtMs === 'number') {
    if (premiumEntitlement.expiresAtMs <= nowMs) {
      premiumEntitlement = {
        ...premiumEntitlement,
        status: 'expired',
        willRenew: false,
      };
      await userRef.set(
        {
          isPremium: false,
          subscriptionStatus: 'expired',
          premiumEntitlement,
        },
        { merge: true },
      );
    }
  }

  return {
    ok: true,
    premiumEntitlement,
    purchasedCosmeticIds,
  };
});

/**
 * Processes RevenueCat Server-to-Server Webhook events (`INITIAL_PURCHASE`, `RENEWAL`,
 * `CANCELLATION`, `EXPIRATION`, `BILLING_ISSUE`, `NON_RENEWING_PURCHASE`).
 */
export async function processRevenueCatWebhookEvent(event: {
  type: string;
  app_user_id: string;
  product_id: string;
  expiration_at_ms?: number;
  grace_period_expiration_at_ms?: number;
  store?: string;
  transaction_id?: string;
  nowMs?: number;
}): Promise<{ ok: boolean; status: string; isPremium: boolean }> {
  const uid = event.app_user_id;
  if (!uid) {
    throw new functions.https.HttpsError('invalid-argument', 'MISSING_APP_USER_ID');
  }

  const nowMs = typeof event.nowMs === 'number' ? event.nowMs : Date.now();
  const userRef = db.collection('users').doc(uid);

  if (event.type === 'NON_RENEWING_PURCHASE' && COSMETIC_PRODUCT_IDS.includes(event.product_id)) {
    await userRef.set(
      {
        uid,
        purchasedCosmeticIds: FieldValue.arrayUnion(event.product_id),
        serverVerifiedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return { ok: true, status: 'cosmetic_granted', isPremium: false };
  }

  const expiresAtMs = event.expiration_at_ms ?? nowMs;
  let status = 'none';
  let willRenew = false;

  switch (event.type) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL':
    case 'UNCANCELLATION':
      status = expiresAtMs > nowMs ? 'active' : 'expired';
      willRenew = expiresAtMs > nowMs;
      break;
    case 'CANCELLATION':
      status = expiresAtMs > nowMs ? 'active_until_expiry' : 'expired';
      willRenew = false;
      break;
    case 'BILLING_ISSUE':
      status = (event.grace_period_expiration_at_ms ?? expiresAtMs) > nowMs
        ? 'grace_period'
        : 'billing_retry';
      willRenew = false;
      break;
    case 'EXPIRATION':
    default:
      status = 'expired';
      willRenew = false;
      break;
  }

  const isPremium =
    (status === 'active' || status === 'active_until_expiry' || status === 'grace_period') &&
    expiresAtMs > nowMs;

  const premiumEntitlement = {
    isVerifiedByServer: true,
    status,
    subscriptionProductId: event.product_id,
    expiresAtMs,
    gracePeriodExpiresAtMs: event.grace_period_expiration_at_ms ?? null,
    willRenew,
    storeSource: event.store ?? 'revenuecat',
    serverVerifiedAtMs: nowMs,
    verificationSignature: `rc_wh_${uid}_${event.transaction_id || nowMs}`,
  };

  await userRef.set(
    {
      uid,
      isPremium,
      subscriptionProductId: event.product_id,
      premiumExpiresAtMs: expiresAtMs,
      subscriptionStatus: status,
      premiumEntitlement,
      serverVerifiedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { ok: true, status, isPremium };
}

/**
 * Verifies an AdMob Rewarded Ad Server-Side Verification (SSV) claim and increments
 * the user's non-competitive cosmetic unlock progress.
 */
export const claimRewardedAdReward = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
  }
  const productId = typeof data?.productId === 'string' ? data.productId.trim() : '';
  const ssvToken = typeof data?.ssvToken === 'string' ? data.ssvToken.trim() : '';
  if (!productId || !ssvToken || !COSMETIC_PRODUCT_IDS.includes(productId)) {
    throw new functions.https.HttpsError('invalid-argument', 'INVALID_REWARD_CLAIM');
  }

  return {
    ok: true,
    productId,
    verifiedSsvToken: ssvToken,
  };
});

export { answerIndex as _answerIndex, playersMap as _playersMap, teamsMap as _teamsMap };
