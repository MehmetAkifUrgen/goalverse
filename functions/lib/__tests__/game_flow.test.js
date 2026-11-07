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
const mockSet = jest.fn();
const mockUpdate = jest.fn();
const mockGet = jest.fn();
const mockDoc = jest.fn();
const mockCollection = jest.fn();
const mockRunTransaction = jest.fn();
const mockWhere = jest.fn();
const mockLimit = jest.fn();
const mockServerTimestamp = jest.fn(() => ({ _mock: 'timestamp' }));
const mockTimestampNow = jest.fn(() => ({ toMillis: () => Date.now(), _seconds: 1, _nanoseconds: 0 }));
const adminMocks = {
    firestore: {
        FieldValue: { serverTimestamp: mockServerTimestamp },
        Timestamp: { now: () => mockTimestampNow() },
    },
};
jest.mock('firebase-admin', () => ({
    initializeApp: jest.fn(),
    firestore: jest.fn(() => ({
        collection: mockCollection,
        runTransaction: mockRunTransaction,
    })),
}));
jest.mock('firebase-functions', () => {
    return {
        https: {
            onCall: (handler) => handler,
        },
    };
});
describe('Game Flow: createGame -> joinGame -> startGame -> submitAnswer', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });
    describe('createGame', () => {
        it('authsuz kullanici UNAUTHENTICATED firlatir', async () => {
            const { createGame } = await Promise.resolve().then(() => __importStar(require('../index')));
            await expect(createGame({ mode: 'public' }, { auth: undefined })).rejects.toThrow();
        });
        it('gecersiz mod ile INVALID_MODE firlatir', async () => {
            const { createGame } = await Promise.resolve().then(() => __importStar(require('../index')));
            try {
                await createGame({ mode: 'weird' }, { auth: { uid: 'u1' } });
                fail('hata bekleniyordu');
            }
            catch (e) {
                expect(e.message).toBe('INVALID_MODE');
            }
        });
        it('dokuman olusturur ve roomCode ile gameId doner', async () => {
            const fakeSnapEmpty = { empty: true };
            mockLimit.mockReturnValue(fakeSnapEmpty);
            mockWhere.mockReturnValue({ limit: mockLimit });
            const setPromise = Promise.resolve();
            mockSet.mockReturnValue(setPromise);
            const fakeRef = { id: 'GAME_MOCK_1', set: mockSet };
            mockDoc.mockReturnValue(fakeRef);
            mockCollection.mockReturnValue({ doc: mockDoc, where: mockWhere });
            jest.resetModules();
            jest.doMock('firebase-admin', () => adminMocks);
            const mod = await Promise.resolve().then(() => __importStar(require('../index')));
            const res = await mod.createGame({ mode: 'public', difficulty: 'medium' }, { auth: { uid: 'u1' } });
            expect(res).toHaveProperty('gameId');
            expect(res).toHaveProperty('roomCode');
            expect(res.roomCode).toMatch(/^\d{6}$/);
            expect(mockSet).toHaveBeenCalledTimes(1);
            const written = mockSet.mock.calls[0][0];
            expect(written.status).toBe('waiting');
            expect(written.player1Id).toBe('u1');
            expect(written.rowTeams.length).toBe(3);
            expect(written.colTeams.length).toBe(3);
            expect(written.board.length).toBe(9);
            expect(written.usedPlayers).toEqual([]);
            expect(written.scores).toEqual({});
            expect(written.currentTurn).toBeNull();
        });
    });
    describe('joinGame transaction', () => {
        it('transaction ici status=waiting oyuncu2yi ekler ve ready yapar', async () => {
            const gameSnap = {
                exists: true,
                data: () => ({
                    status: 'waiting',
                    player1Id: 'u1',
                    player2Id: null,
                }),
            };
            const fakeRef = { id: 'GAME_ID_2' };
            mockRunTransaction.mockImplementation(async (cb) => {
                const tx = {
                    get: jest.fn().mockResolvedValue(gameSnap),
                    update: jest.fn(),
                };
                const result = await cb(tx);
                expect(tx.update).toHaveBeenCalledWith(fakeRef, { player2Id: 'u2', status: 'ready' });
                return result;
            });
            mockCollection.mockReturnValue({ doc: () => fakeRef });
            jest.resetModules();
            const mod = await Promise.resolve().then(() => __importStar(require('../index')));
            const res = await mod.joinGame({ gameId: 'GAME_ID_2' }, { auth: { uid: 'u2' } });
            expect(res.gameId).toBe('GAME_ID_2');
        });
    });
    describe('startGame transaction', () => {
        it('hazir oyunda statusu playing yapar ve sira player1de baslar', async () => {
            const gameSnap = {
                exists: true,
                data: () => ({
                    status: 'ready',
                    player1Id: 'u1',
                    player2Id: 'u2',
                }),
            };
            const fakeRef = { id: 'GAME_ID_3' };
            mockRunTransaction.mockImplementation(async (cb) => {
                const tx = {
                    get: jest.fn().mockResolvedValue(gameSnap),
                    update: jest.fn(),
                };
                await cb(tx);
                expect(tx.update).toHaveBeenCalledWith(fakeRef, {
                    status: 'playing',
                    currentTurn: 'u1',
                    startedAt: expect.anything(),
                });
                return { ok: true };
            });
            mockCollection.mockReturnValue({ doc: () => fakeRef });
            jest.resetModules();
            const mod = await Promise.resolve().then(() => __importStar(require('../index')));
            const res = await mod.startGame({ gameId: 'GAME_ID_3' }, { auth: { uid: 'u1' } });
            expect(res.ok).toBe(true);
        });
    });
    describe('submitAnswer dogrulama (transaction disi saf mantik)', () => {
        it('validatePlayerForCell ile INVALID_PLAYER', async () => {
            jest.resetModules();
            const mod = await Promise.resolve().then(() => __importStar(require('../index')));
            const mockIdx = {
                'team_A|team_B': ['p1', 'p2'],
            };
            const result = mod.validatePlayerForCell(mockIdx, ['team_A', 'X', 'Y'], ['team_B', 'Z', 'T'], 0, 'p999', []);
            expect(result.valid).toBe(false);
            expect(result.error).toBe('INVALID_PLAYER');
        });
        it('validatePlayerForCell ile dogru oyuncu VALID', async () => {
            jest.resetModules();
            const mod = await Promise.resolve().then(() => __importStar(require('../index')));
            const mockIdx = {
                'team_A|team_B': ['p1', 'p2'],
            };
            const result = mod.validatePlayerForCell(mockIdx, ['team_A', 'X', 'Y'], ['team_B', 'Z', 'T'], 0, 'p1', []);
            expect(result.valid).toBe(true);
        });
        it('checkWinner 3 satir X kazanan', async () => {
            jest.resetModules();
            const mod = await Promise.resolve().then(() => __importStar(require('../index')));
            const cell = (u, m) => ({
                playerId: 'p', byUserId: u, timestamp: 0, mark: m,
            });
            const board = Array(9).fill(null);
            board[0] = cell('u1', 'X');
            board[1] = cell('u1', 'X');
            board[2] = cell('u1', 'X');
            expect(mod.checkWinner(board).winnerUserId).toBe('u1');
        });
    });
});
//# sourceMappingURL=game_flow.test.js.map