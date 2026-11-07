const mockSet = jest.fn();
const mockUpdate = jest.fn();
const mockGet = jest.fn();
const mockDoc = jest.fn();
const mockCollection = jest.fn();
const mockRunTransaction = jest.fn();
const mockWhere = jest.fn();
const mockLimit = jest.fn();
const mockServerTimestamp = jest.fn(() => ({ _mock: 'timestamp' }));
let currentNowMs = 1700000000000;
const mockTimestampNow = jest.fn(() => ({
  toMillis: () => currentNowMs,
  _seconds: Math.floor(currentNowMs / 1000),
  _nanoseconds: 0,
}));

const firestoreFn = Object.assign(
  jest.fn(() => ({
    collection: mockCollection,
    runTransaction: mockRunTransaction,
  })),
  {
    FieldValue: { serverTimestamp: mockServerTimestamp },
    Timestamp: { now: () => mockTimestampNow() },
  }
);

const adminMocks = {
  initializeApp: jest.fn(),
  firestore: firestoreFn,
  default: {
    initializeApp: jest.fn(),
    firestore: firestoreFn,
  },
};

jest.mock('firebase-admin', () => adminMocks);

class HttpsError extends Error {
  code: string;
  constructor(code: string, message: string) {
    super(message);
    this.code = code;
  }
}

jest.mock('firebase-functions', () => ({
  __esModule: true,
  https: {
    onCall: (handler: any) => handler,
    HttpsError: HttpsError,
  },
  default: {
    https: {
      onCall: (handler: any) => handler,
      HttpsError: HttpsError,
    },
  },
}));

describe('Game Flow: createGame -> joinGame -> startGame -> submitAnswer -> passTurn -> offerDraw', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    currentNowMs = 1700000000000;
  });

  describe('createGame', () => {
    it('authsuz kullanici UNAUTHENTICATED firlatir', async () => {
      const { createGame } = await import('../index');
      await expect((createGame as any)({ mode: 'public' }, { auth: undefined })).rejects.toThrow();
    });

    it('gecersiz mod ile INVALID_MODE firlatir', async () => {
      const { createGame } = await import('../index');
      try {
        await (createGame as any)({ mode: 'weird' }, { auth: { uid: 'u1' } });
        fail('hata bekleniyordu');
      } catch (e: any) {
        expect(e.message).toBe('INVALID_MODE');
      }
    });

    it('dokuman olusturur ve roomCode ile gameId doner', async () => {
      const fakeSnapEmpty = { empty: true };
      mockLimit.mockReturnValue({ get: jest.fn().mockResolvedValue(fakeSnapEmpty) });
      mockWhere.mockReturnValue({ limit: mockLimit });

      const setPromise = Promise.resolve();
      mockSet.mockReturnValue(setPromise);
      const fakeRef = { id: 'GAME_MOCK_1', set: mockSet };
      mockDoc.mockReturnValue(fakeRef);
      mockCollection.mockReturnValue({ doc: mockDoc, where: mockWhere });

      jest.resetModules();
      jest.doMock('firebase-admin', () => adminMocks);
      const mod = await import('../index');
      const res = await (mod.createGame as any)(
        { mode: 'public', difficulty: 'medium' },
        { auth: { uid: 'u1' } } as any,
      );

      expect(res).toHaveProperty('gameId');
      expect(res).toHaveProperty('roomCode');
      expect(res.roomCode).toMatch(/^\d{6}$/);
      expect(mockSet).toHaveBeenCalledTimes(1);
      const written: any = mockSet.mock.calls[0][0];
      expect(written.status).toBe('waiting');
      expect(written.player1Id).toBe('u1');
      expect(written.rowTeams.length).toBe(3);
      expect(written.colTeams.length).toBe(3);
      expect(written.board.length).toBe(9);
      expect(written.usedPlayers).toEqual([]);
      expect(written.passesUsed).toEqual({ u1: 0 });
      expect(written.moveHistory).toEqual([]);
      expect(written.drawOffer).toBeNull();
      expect(written.scores).toEqual({});
      expect(written.currentTurn).toBeNull();
    });
  });

  describe('passTurn transaction (2 pas hakki)', () => {
    it('sirasi gelen oyuncu pas gecebilir, pas hakki azalir ve sira rakibe gecer', async () => {
      const gameSnap = {
        exists: true,
        data: () => ({
          status: 'playing',
          player1Id: 'u1',
          player2Id: 'u2',
          currentTurn: 'u1',
          passesUsed: { u1: 0, u2: 0 },
          moveHistory: [],
        }),
      };
      const fakeRef = { id: 'GAME_PASS_1' };
      mockRunTransaction.mockImplementation(async (cb: any) => {
        const tx = {
          get: jest.fn().mockResolvedValue(gameSnap),
          update: jest.fn(),
        };
        const res = await cb(tx);
        expect(tx.update).toHaveBeenCalledWith(
          fakeRef,
          expect.objectContaining({
            passesUsed: { u1: 1, u2: 0 },
            currentTurn: 'u2',
          }),
        );
        return res;
      });
      mockCollection.mockReturnValue({ doc: () => fakeRef });
      jest.resetModules();
      const mod = await import('../index');
      const res = await (mod.passTurn as any)(
        { gameId: 'GAME_PASS_1' },
        { auth: { uid: 'u1' } } as any,
      );
      expect(res.ok).toBe(true);
      expect(res.passesRemaining).toBe(1);
      expect(res.currentTurn).toBe('u2');
    });

    it('2 pas hakkini bitiren oyuncu 3. kez pas gecemez (NO_PASSES_LEFT)', async () => {
      const gameSnap = {
        exists: true,
        data: () => ({
          status: 'playing',
          player1Id: 'u1',
          player2Id: 'u2',
          currentTurn: 'u1',
          passesUsed: { u1: 2, u2: 0 },
        }),
      };
      const fakeRef = { id: 'GAME_PASS_2' };
      mockRunTransaction.mockImplementation(async (cb: any) => {
        const tx = {
          get: jest.fn().mockResolvedValue(gameSnap),
          update: jest.fn(),
        };
        return await cb(tx);
      });
      mockCollection.mockReturnValue({ doc: () => fakeRef });
      jest.resetModules();
      const mod = await import('../index');
      await expect(
        (mod.passTurn as any)({ gameId: 'GAME_PASS_2' }, { auth: { uid: 'u1' } } as any),
      ).rejects.toThrow('NO_PASSES_LEFT');
    });
  });

  describe('offerDraw & respondDrawOffer transaction', () => {
    it('beraberlik teklifi olusturur (30s gecerlilik) ve 60s icinde tekrar teklifi engeller', async () => {
      let stateData: any = {
        status: 'playing',
        player1Id: 'u1',
        player2Id: 'u2',
        currentTurn: 'u1',
        drawOffer: null,
        lastDrawOfferAtByUser: {},
        moveHistory: [],
      };
      const fakeRef = { id: 'GAME_DRAW_1' };
      mockRunTransaction.mockImplementation(async (cb: any) => {
        const tx = {
          get: jest.fn().mockResolvedValue({ exists: true, data: () => stateData }),
          update: jest.fn((_ref: any, updates: any) => {
            stateData = { ...stateData, ...updates };
          }),
          set: jest.fn(),
        };
        return await cb(tx);
      });
      mockCollection.mockReturnValue({ doc: () => fakeRef });
      jest.resetModules();
      const mod = await import('../index');

      const offerRes = await (mod.offerDraw as any)(
        { gameId: 'GAME_DRAW_1' },
        { auth: { uid: 'u1' } } as any,
      );
      expect(offerRes.ok).toBe(true);
      expect(stateData.drawOffer.status).toBe('pending');
      expect(stateData.drawOffer.expiresAtMs).toBe(currentNowMs + 30000);

      // Opponent rejects the offer
      currentNowMs += 5000;
      const rejectRes = await (mod.respondDrawOffer as any)(
        { gameId: 'GAME_DRAW_1', accept: false },
        { auth: { uid: 'u2' } } as any,
      );
      expect(rejectRes.ok).toBe(true);
      expect(rejectRes.status).toBe('playing');
      expect(stateData.drawOffer.status).toBe('rejected');

      // Sender u1 tries to offer again within 60s -> blocked by cooldown
      currentNowMs += 10000;
      await expect(
        (mod.offerDraw as any)({ gameId: 'GAME_DRAW_1' }, { auth: { uid: 'u1' } } as any),
      ).rejects.toThrow('DRAW_OFFER_COOLDOWN');
    });
  });
});
