"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const index_1 = require("../index");
const makeMockAnswerIndex = () => {
    return {
        'team_A|team_B': ['player_1', 'player_2', 'player_3'],
        'team_A|team_C': ['player_4', 'player_5'],
        'team_A|team_D': ['player_6'],
        'team_B|team_C': ['player_7', 'player_8'],
        'team_B|team_D': ['player_9', 'player_10'],
        'team_C|team_D': ['player_11'],
        'team_A|team_E': ['player_12', 'player_13', 'player_14'],
        'team_B|team_E': ['player_15'],
        'team_C|team_E': ['player_16', 'player_17'],
        'team_D|team_E': ['player_18'],
    };
};
const makeCell = (userId, mark, playerId = 'p') => ({
    playerId,
    byUserId: userId,
    timestamp: { toMillis: () => 0 },
    mark,
});
describe('buildTeamPairKey', () => {
    it('iki takimi lexicographically sort edip | ile birlestirir', () => {
        expect((0, index_1.buildTeamPairKey)('team_B', 'team_A')).toBe('team_A|team_B');
        expect((0, index_1.buildTeamPairKey)('team_A', 'team_B')).toBe('team_A|team_B');
        expect((0, index_1.buildTeamPairKey)('team_002', 'team_001')).toBe('team_001|team_002');
    });
});
describe('validatePlayerForCell', () => {
    const answerIndex = makeMockAnswerIndex();
    const rowTeams = ['team_A', 'team_B', 'team_C'];
    const colTeams = ['team_D', 'team_E', 'team_B'];
    it('hucre icin dogru oyuncu geldiginde valid:true doner', () => {
        const cellId = 0;
        const result = (0, index_1.validatePlayerForCell)(answerIndex, rowTeams, colTeams, cellId, 'player_6', []);
        expect(result).toEqual({ valid: true });
    });
    it('hucre icin yanlis oyuncu geldiginde INVALID_PLAYER doner', () => {
        const cellId = 0;
        const result = (0, index_1.validatePlayerForCell)(answerIndex, rowTeams, colTeams, cellId, 'player_999', []);
        expect(result).toEqual({ valid: false, error: 'INVALID_PLAYER' });
    });
    it('daha once kullanilmis oyuncu geldiginde PLAYER_ALREADY_USED doner', () => {
        const cellId = 0;
        const result = (0, index_1.validatePlayerForCell)(answerIndex, rowTeams, colTeams, cellId, 'player_6', ['player_6']);
        expect(result).toEqual({ valid: false, error: 'PLAYER_ALREADY_USED' });
    });
    it('diger hucreler icin dogru oyunculari dogrular: (1,0) -> B-D -> player_9', () => {
        const cellId = 3;
        const result = (0, index_1.validatePlayerForCell)(answerIndex, rowTeams, colTeams, cellId, 'player_9', []);
        expect(result).toEqual({ valid: true });
    });
    it('hucre (2,1) C-E player_17 gecerli', () => {
        const cellId = 7;
        const result = (0, index_1.validatePlayerForCell)(answerIndex, rowTeams, colTeams, cellId, 'player_17', []);
        expect(result).toEqual({ valid: true });
    });
});
describe('checkWinner', () => {
    it('ilk satirda 3 X oldugunda X kullanicisini kazanan ilan eder', () => {
        const board = Array(9).fill(null);
        board[0] = makeCell('u1', 'X');
        board[1] = makeCell('u1', 'X');
        board[2] = makeCell('u1', 'X');
        const result = (0, index_1.checkWinner)(board);
        expect(result.winnerUserId).toBe('u1');
        expect(result.mark).toBe('X');
    });
    it('ikinci sutunda 3 O oldugunda O kullanicisini kazanan ilan eder', () => {
        const board = Array(9).fill(null);
        board[1] = makeCell('u2', 'O');
        board[4] = makeCell('u2', 'O');
        board[7] = makeCell('u2', 'O');
        const result = (0, index_1.checkWinner)(board);
        expect(result.winnerUserId).toBe('u2');
        expect(result.mark).toBe('O');
    });
    it('sol ustten sag alta diyagonal X kazanir', () => {
        const board = Array(9).fill(null);
        board[0] = makeCell('u1', 'X');
        board[4] = makeCell('u1', 'X');
        board[8] = makeCell('u1', 'X');
        const result = (0, index_1.checkWinner)(board);
        expect(result.winnerUserId).toBe('u1');
    });
    it('sag ustten sol alta diyagonal O kazanir', () => {
        const board = Array(9).fill(null);
        board[2] = makeCell('u2', 'O');
        board[4] = makeCell('u2', 'O');
        board[6] = makeCell('u2', 'O');
        const result = (0, index_1.checkWinner)(board);
        expect(result.winnerUserId).toBe('u2');
    });
    it('ucuncu satir kazanir', () => {
        const board = Array(9).fill(null);
        board[6] = makeCell('u1', 'X');
        board[7] = makeCell('u1', 'X');
        board[8] = makeCell('u1', 'X');
        expect((0, index_1.checkWinner)(board).winnerUserId).toBe('u1');
    });
    it('karisik dizilimde kazanan yoksa null doner', () => {
        const board = Array(9).fill(null);
        board[0] = makeCell('u1', 'X');
        board[1] = makeCell('u2', 'O');
        board[2] = makeCell('u1', 'X');
        board[3] = makeCell('u2', 'O');
        expect((0, index_1.checkWinner)(board).winnerUserId).toBeNull();
        expect((0, index_1.checkWinner)(board).mark).toBeNull();
    });
    it('tum hucreler dolu ama uc siralma yoksa berabere (kazanan null)', () => {
        const board = [
            makeCell('u1', 'X'), makeCell('u2', 'O'), makeCell('u1', 'X'),
            makeCell('u1', 'X'), makeCell('u2', 'O'), makeCell('u2', 'O'),
            makeCell('u2', 'O'), makeCell('u1', 'X'), makeCell('u1', 'X'),
        ];
        expect((0, index_1.checkWinner)(board).winnerUserId).toBeNull();
    });
});
//# sourceMappingURL=submitAnswer.test.js.map