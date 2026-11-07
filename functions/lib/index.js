"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports._teamsMap = exports._playersMap = exports._answerIndex = exports.updateRating = exports.leaveGame = exports.finishGame = exports.respondDrawOffer = exports.offerDraw = exports.skipTurn = exports.passTurn = exports.submitAnswer = exports.startGame = exports.joinGame = exports.createGame = exports.DRAW_OFFER_COOLDOWN_MS = exports.DRAW_OFFER_DURATION_MS = exports.MAX_PASSES_PER_PLAYER = void 0;
exports.buildTeamPairKey = buildTeamPairKey;
exports.validatePlayerForCell = validatePlayerForCell;
exports.checkWinner = checkWinner;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
admin.initializeApp();
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
exports.MAX_PASSES_PER_PLAYER = 2;
exports.DRAW_OFFER_DURATION_MS = 30 * 1000;
exports.DRAW_OFFER_COOLDOWN_MS = 60 * 1000;
const ANSWER_INDEX_PATH = path.join(__dirname, '../data/answer_index.json');
const PLAYERS_PATH = path.join(__dirname, '../data/players.json');
const TEAMS_PATH = path.join(__dirname, '../data/teams.json');
const loadJson = (filePath) => {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
};
const answerIndex = loadJson(ANSWER_INDEX_PATH);
exports._answerIndex = answerIndex;
const playersList = loadJson(PLAYERS_PATH);
const teamsList = loadJson(TEAMS_PATH);
const playersMap = {};
exports._playersMap = playersMap;
for (const p of playersList) {
    playersMap[p.id] = p;
}
const teamsMap = {};
exports._teamsMap = teamsMap;
for (const t of teamsList) {
    teamsMap[t.id] = t;
}
function buildTeamPairKey(teamA, teamB) {
    return [teamA, teamB].sort().join('|');
}
/**
 * Validates whether [playerId] satisfies the club criteria for [cellId].
 * Footballer reuse IS ALLOWED across cells (both by the same player and by the opponent).
 * Each cell is evaluated independently against its row and column club intersection.
 */
function validatePlayerForCell(localAnswerIndex, rowTeams, colTeams, cellId, playerId, _usedPlayers = []) {
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
function checkWinner(board) {
    const lines = [
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
function generateRoomCode() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}
function pickRandomTeams(count, pool) {
    const copy = [...pool];
    const result = [];
    for (let i = 0; i < count && copy.length > 0; i++) {
        const idx = Math.floor(Math.random() * copy.length);
        result.push(copy.splice(idx, 1)[0]);
    }
    return result;
}
exports.createGame = functions.https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
    }
    const mode = data?.mode;
    if (!mode || !['public', 'private', 'daily'].includes(mode)) {
        throw new functions.https.HttpsError('invalid-argument', 'INVALID_MODE');
    }
    const difficulty = data?.difficulty;
    if (difficulty && !['easy', 'medium', 'hard'].includes(difficulty)) {
        throw new functions.https.HttpsError('invalid-argument', 'INVALID_DIFFICULTY');
    }
    let rowTeams = [];
    let colTeams = [];
    const availableTeams = teamsList.filter((t) => answerIndexHasEnoughPairs(t.id, teamsList.map((x) => x.id)));
    const pickPool = availableTeams.length >= 6 ? availableTeams : teamsList;
    let attempts = 0;
    while (attempts < 20) {
        const chosen = pickRandomTeams(6, pickPool);
        if (chosen.length < 6)
            break;
        const r = chosen.slice(0, 3).map((t) => t.id);
        const c = chosen.slice(3, 6).map((t) => t.id);
        let ok = true;
        for (let i = 0; i < 3 && ok; i++) {
            for (let j = 0; j < 3 && ok; j++) {
                const key = buildTeamPairKey(r[i], c[j]);
                const list = answerIndex[key];
                if (!list || list.length < 3)
                    ok = false;
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
    const gameDoc = {
        status: 'waiting',
        mode,
        roomCode,
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
    return { gameId: gameRef.id, roomCode };
});
function answerIndexHasEnoughPairs(teamId, allTeamIds) {
    let count = 0;
    for (const otherId of allTeamIds) {
        if (otherId === teamId)
            continue;
        const key = buildTeamPairKey(teamId, otherId);
        if (answerIndex[key] && answerIndex[key].length >= 3)
            count++;
    }
    return count >= 5;
}
exports.joinGame = functions.https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
    }
    const gameId = data?.gameId;
    const roomCode = data?.roomCode;
    if (!gameId && !roomCode) {
        throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_OR_ROOMCODE_REQUIRED');
    }
    let gameRef = null;
    if (gameId) {
        gameRef = db.collection('games').doc(gameId);
    }
    else if (roomCode) {
        const snap = await db.collection('games').where('roomCode', '==', roomCode).limit(1).get();
        if (snap.empty) {
            throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
        }
        gameRef = snap.docs[0].ref;
    }
    try {
        const result = await db.runTransaction(async (tx) => {
            if (!gameRef)
                throw new Error('NO_REF');
            const snap = await tx.get(gameRef);
            if (!snap.exists) {
                throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
            }
            const game = snap.data();
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
    }
    catch (e) {
        if (e instanceof functions.https.HttpsError)
            throw e;
        throw new functions.https.HttpsError('internal', 'TRANSACTION_FAILED');
    }
});
exports.startGame = functions.https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
    }
    const gameId = data?.gameId;
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
            const game = snap.data();
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
    }
    catch (e) {
        if (e instanceof functions.https.HttpsError)
            throw e;
        throw new functions.https.HttpsError('internal', 'TRANSACTION_FAILED');
    }
});
exports.submitAnswer = functions.https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
    }
    const gameId = data?.gameId;
    const cellId = data?.cellId;
    const playerId = data?.playerId;
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
            const game = snap.data();
            if (game.status !== 'playing') {
                return { valid: false, error: 'GAME_NOT_PLAYING', board: game.board, currentTurn: game.currentTurn, status: game.status };
            }
            if (game.currentTurn !== uid) {
                return { valid: false, error: 'NOT_YOUR_TURN', board: game.board, currentTurn: game.currentTurn, status: game.status };
            }
            if (cellId < 0 || cellId > 8) {
                return { valid: false, error: 'INVALID_CELL_ID', board: game.board, currentTurn: game.currentTurn, status: game.status };
            }
            if (game.board[cellId]) {
                return { valid: false, error: 'CELL_ALREADY_FILLED', board: game.board, currentTurn: game.currentTurn, status: game.status };
            }
            if (game.turnDeadline) {
                const now = admin.firestore.Timestamp.now();
                if (now.toMillis() > game.turnDeadline.toMillis()) {
                    return { valid: false, error: 'TIME_EXPIRED', board: game.board, currentTurn: game.currentTurn, status: game.status };
                }
            }
            const validation = validatePlayerForCell(answerIndex, game.rowTeams, game.colTeams, cellId, playerId, game.usedPlayers);
            if (!validation.valid) {
                return { valid: false, error: validation.error, board: game.board, currentTurn: game.currentTurn, status: game.status };
            }
            const nowTs = admin.firestore.Timestamp.now();
            const newBoard = [...game.board];
            const usedPlayers = [...(game.usedPlayers || []), playerId];
            const mark = game.currentTurn === game.player1Id ? 'X' : 'O';
            newBoard[cellId] = {
                playerId,
                byUserId: uid,
                timestamp: nowTs,
                mark,
            };
            const moveHistory = [
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
            const otherPlayerId = uid === game.player1Id ? game.player2Id : game.player1Id;
            let currentTurn = otherPlayerId;
            let status = game.status;
            let winnerId = undefined;
            const winResult = checkWinner(newBoard);
            if (winResult.winnerUserId) {
                winnerId = winResult.winnerUserId;
                status = 'finished';
                currentTurn = null;
            }
            else if (newBoard.every((c) => c !== null)) {
                winnerId = 'draw';
                status = 'finished';
                currentTurn = null;
            }
            tx.update(gameRef, {
                board: newBoard,
                usedPlayers,
                moveHistory,
                scores: newScores,
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
            const response = { valid: true, board: newBoard, currentTurn, status };
            if (status === 'finished') {
                response.winnerId = winnerId;
            }
            return response;
        });
        return result;
    }
    catch (e) {
        if (e instanceof functions.https.HttpsError)
            throw e;
        throw new functions.https.HttpsError('internal', 'TRANSACTION_FAILED');
    }
});
/**
 * Server-side validated Pass Turn (2 passes per player per match).
 */
exports.passTurn = functions.https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
    }
    const gameId = data?.gameId;
    if (!gameId) {
        throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_REQUIRED');
    }
    const gameRef = db.collection('games').doc(gameId);
    return await db.runTransaction(async (tx) => {
        const snap = await tx.get(gameRef);
        if (!snap.exists) {
            throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
        }
        const game = snap.data();
        if (game.status !== 'playing') {
            throw new functions.https.HttpsError('failed-precondition', 'GAME_NOT_PLAYING');
        }
        if (game.currentTurn !== uid) {
            throw new functions.https.HttpsError('failed-precondition', 'NOT_YOUR_TURN');
        }
        const passesUsed = { ...(game.passesUsed || {}) };
        const usedByPlayer = passesUsed[uid] || 0;
        if (usedByPlayer >= exports.MAX_PASSES_PER_PLAYER) {
            throw new functions.https.HttpsError('failed-precondition', 'NO_PASSES_LEFT');
        }
        passesUsed[uid] = usedByPlayer + 1;
        const nowMs = admin.firestore.Timestamp.now().toMillis();
        const otherPlayerId = uid === game.player1Id ? game.player2Id : game.player1Id;
        const moveHistory = [
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
            passesRemaining: exports.MAX_PASSES_PER_PLAYER - passesUsed[uid],
        };
    });
});
exports.skipTurn = exports.passTurn;
/**
 * Server-side validated Draw Offer:
 * - Only 1 active offer at a time.
 * - Expires automatically after 30 seconds.
 * - Sender has a 60-second cooldown before offering again.
 */
exports.offerDraw = functions.https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
    }
    const gameId = data?.gameId;
    if (!gameId) {
        throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_REQUIRED');
    }
    const gameRef = db.collection('games').doc(gameId);
    return await db.runTransaction(async (tx) => {
        const snap = await tx.get(gameRef);
        if (!snap.exists) {
            throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
        }
        const game = snap.data();
        if (game.status !== 'playing') {
            throw new functions.https.HttpsError('failed-precondition', 'GAME_NOT_PLAYING');
        }
        if (uid !== game.player1Id && uid !== game.player2Id) {
            throw new functions.https.HttpsError('permission-denied', 'NOT_A_PLAYER');
        }
        const nowMs = admin.firestore.Timestamp.now().toMillis();
        if (game.drawOffer &&
            game.drawOffer.status === 'pending' &&
            nowMs < game.drawOffer.expiresAtMs) {
            throw new functions.https.HttpsError('failed-precondition', 'ACTIVE_OFFER_EXISTS');
        }
        const lastDrawOfferAtByUser = { ...(game.lastDrawOfferAtByUser || {}) };
        const lastSentAt = lastDrawOfferAtByUser[uid] || 0;
        if (lastSentAt > 0 && nowMs - lastSentAt < exports.DRAW_OFFER_COOLDOWN_MS) {
            throw new functions.https.HttpsError('failed-precondition', 'DRAW_OFFER_COOLDOWN');
        }
        const drawOffer = {
            fromUserId: uid,
            createdAtMs: nowMs,
            expiresAtMs: nowMs + exports.DRAW_OFFER_DURATION_MS,
            status: 'pending',
            respondedAtMs: null,
        };
        lastDrawOfferAtByUser[uid] = nowMs;
        const moveHistory = [
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
exports.respondDrawOffer = functions.https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
    }
    const gameId = data?.gameId;
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
        const game = snap.data();
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
            const expiredOffer = {
                ...offer,
                status: 'expired',
                respondedAtMs: nowMs,
            };
            const moveHistory = [
                ...(game.moveHistory || []),
                {
                    type: 'draw_expired',
                    byUserId: offer.fromUserId,
                    timestampMs: nowMs,
                },
            ];
            tx.update(gameRef, { drawOffer: expiredOffer, moveHistory });
            return { ok: false, error: 'DRAW_OFFER_EXPIRED' };
        }
        if (accept) {
            const acceptedOffer = {
                ...offer,
                status: 'accepted',
                respondedAtMs: nowMs,
            };
            const moveHistory = [
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
            return { ok: true, status: 'finished', winnerId: 'draw' };
        }
        else {
            const rejectedOffer = {
                ...offer,
                status: 'rejected',
                respondedAtMs: nowMs,
            };
            const moveHistory = [
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
            return { ok: true, status: 'playing' };
        }
    });
});
exports.finishGame = functions.https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
    }
    const gameId = data?.gameId;
    if (!gameId) {
        throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_REQUIRED');
    }
    const gameRef = db.collection('games').doc(gameId);
    await db.runTransaction(async (tx) => {
        const snap = await tx.get(gameRef);
        if (!snap.exists)
            throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
        const game = snap.data();
        if (uid !== game.player1Id && uid !== game.player2Id) {
            throw new functions.https.HttpsError('permission-denied', 'NOT_A_PLAYER');
        }
        tx.update(gameRef, { status: 'finished', currentTurn: null });
    });
    return { ok: true };
});
exports.leaveGame = functions.https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
    }
    const gameId = data?.gameId;
    if (!gameId) {
        throw new functions.https.HttpsError('invalid-argument', 'GAME_ID_REQUIRED');
    }
    const gameRef = db.collection('games').doc(gameId);
    await db.runTransaction(async (tx) => {
        const snap = await tx.get(gameRef);
        if (!snap.exists)
            throw new functions.https.HttpsError('not-found', 'GAME_NOT_FOUND');
        const game = snap.data();
        if (game.status === 'playing') {
            const winnerId = uid === game.player1Id ? game.player2Id : game.player1Id;
            tx.update(gameRef, { status: 'finished', currentTurn: null, winnerId });
        }
        else {
            if (uid === game.player1Id) {
                tx.update(gameRef, { status: 'finished', player1Id: null });
            }
            else if (uid === game.player2Id) {
                tx.update(gameRef, { status: 'waiting', player2Id: null });
            }
        }
    });
    return { ok: true };
});
exports.updateRating = functions.https.onCall(async (_data, context) => {
    const uid = context.auth?.uid;
    if (!uid) {
        throw new functions.https.HttpsError('unauthenticated', 'UNAUTHENTICATED');
    }
    return { ok: true, uid };
});
//# sourceMappingURL=index.js.map