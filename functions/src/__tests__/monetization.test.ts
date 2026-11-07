const mockSet = jest.fn();
const mockUpdate = jest.fn();
const mockGet = jest.fn();
const mockDoc = jest.fn();
const mockCollection = jest.fn();
const mockRunTransaction = jest.fn();
const mockServerTimestamp = jest.fn(() => ({ _mock: 'timestamp' }));
const mockArrayUnion = jest.fn((val: any) => ({ _arrayUnion: val }));

const firestoreFn = Object.assign(
  jest.fn(() => ({
    collection: mockCollection,
    runTransaction: mockRunTransaction,
  })),
  {
    FieldValue: {
      serverTimestamp: mockServerTimestamp,
      arrayUnion: mockArrayUnion,
    },
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

describe('Football SOS Monetization Cloud Functions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('rejects client purchase verification without receipt token (prevents raw boolean spoofing)', async () => {
    const { verifyPurchaseReceipt } = await import('../index');
    await expect(
      (verifyPurchaseReceipt as any)(
        { isPremium: true, productId: 'football_sos_pro_monthly' },
        { auth: { uid: 'u1' } }
      )
    ).rejects.toThrow('RECEIPT_REQUIRED');
  });

  it('verifies subscription receipt and writes server-verified premiumEntitlement to users/{uid}', async () => {
    const fakeUserRef = { id: 'u1', set: mockSet };
    mockDoc.mockReturnValue(fakeUserRef);
    mockCollection.mockReturnValue({ doc: mockDoc });

    const txSet = jest.fn();
    mockRunTransaction.mockImplementation(async (cb: any) => {
      const tx = {
        get: jest.fn().mockResolvedValue({ exists: true, data: () => ({ uid: 'u1', purchasedCosmeticIds: [] }) }),
        set: txSet,
        update: mockUpdate,
      };
      return await cb(tx);
    });

    const { verifyPurchaseReceipt } = await import('../index');
    const nowMs = 1700000000000;
    const expiresAtMs = nowMs + 30 * 86400000;
    const res = await (verifyPurchaseReceipt as any)(
      {
        productId: 'football_sos_pro_monthly',
        transactionId: 'tx_play_001',
        verificationToken: 'token_play_001',
        storeSource: 'play_store',
        nowMs,
        expiresAtMs,
        willRenew: true,
      },
      { auth: { uid: 'u1' } }
    );

    expect(res.verified).toBe(true);
    expect(res.isPremium).toBe(true);
    expect(res.premiumEntitlement.isVerifiedByServer).toBe(true);
    expect(res.premiumEntitlement.status).toBe('active');
    expect(txSet).toHaveBeenCalledTimes(1);
  });

  it('processes RevenueCat webhook lifecycle: INITIAL_PURCHASE -> CANCELLATION -> EXPIRATION', async () => {
    const fakeUserRef = { id: 'u_rc', set: mockSet };
    mockDoc.mockReturnValue(fakeUserRef);
    mockCollection.mockReturnValue({ doc: mockDoc });

    const { processRevenueCatWebhookEvent } = await import('../index');
    const t0 = 1700000000000;
    const expiry = t0 + 365 * 86400000;

    // 1. Initial Purchase
    const r1 = await processRevenueCatWebhookEvent({
      type: 'INITIAL_PURCHASE',
      app_user_id: 'u_rc',
      product_id: 'football_sos_pro_yearly',
      expiration_at_ms: expiry,
      nowMs: t0,
    });
    expect(r1.isPremium).toBe(true);
    expect(r1.status).toBe('active');

    // 2. Cancellation -> remains active until expiry
    const r2 = await processRevenueCatWebhookEvent({
      type: 'CANCELLATION',
      app_user_id: 'u_rc',
      product_id: 'football_sos_pro_yearly',
      expiration_at_ms: expiry,
      nowMs: t0 + 10000,
    });
    expect(r2.isPremium).toBe(true);
    expect(r2.status).toBe('active_until_expiry');

    // 3. Expiration -> automatically deactivates
    const r3 = await processRevenueCatWebhookEvent({
      type: 'EXPIRATION',
      app_user_id: 'u_rc',
      product_id: 'football_sos_pro_yearly',
      expiration_at_ms: expiry,
      nowMs: expiry + 1000,
    });
    expect(r3.isPremium).toBe(false);
    expect(r3.status).toBe('expired');
  });

  it('validates Rewarded Ad SSV claim and rejects missing SSV token', async () => {
    const { claimRewardedAdReward } = await import('../index');
    await expect(
      (claimRewardedAdReward as any)(
        { productId: 'cosmetic_board_royal_gold', ssvToken: '' },
        { auth: { uid: 'u1' } }
      )
    ).rejects.toThrow('INVALID_REWARD_CLAIM');

    const okRes = await (claimRewardedAdReward as any)(
      { productId: 'cosmetic_board_royal_gold', ssvToken: 'ssv_valid_token_123' },
      { auth: { uid: 'u1' } }
    );
    expect(okRes.ok).toBe(true);
    expect(okRes.verifiedSsvToken).toBe('ssv_valid_token_123');
  });
});

