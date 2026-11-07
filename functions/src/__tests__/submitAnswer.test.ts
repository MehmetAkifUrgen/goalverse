import {
  buildTeamPairKey,
  validatePlayerForCell,
  checkWinner,
} from '../index';

type BoardCell = {
  playerId: string;
  byUserId: string;
  timestamp: any;
  mark: 'X' | 'O';
};

const makeMockAnswerIndex = () => {
  return {
    'team_A|team_B': ['player_1', 'player_2', 'player_3'],
    'team_A|team_C': ['player_4', 'player_5'],
    'team_A|team_D': ['player_6'],
    'team_B|team_C': ['player_7', 'player_8'],
    'team_B|team_D': ['player_9', 'player_10', 'player_6'],
    'team_C|team_D': ['player_11'],
    'team_A|team_E': ['player_12', 'player_13', 'player_14'],
    'team_B|team_E': ['player_15'],
    'team_C|team_E': ['player_16', 'player_17'],
    'team_D|team_E': ['player_18'],
  };
};

const makeCell = (userId: string, mark: 'X' | 'O', playerId: string = 'p'): BoardCell => ({
  playerId,
  byUserId: userId,
  timestamp: { toMillis: () => 0 },
  mark,
});

describe('buildTeamPairKey', () => {
  it('iki takimi lexicographically sort edip | ile birlestirir', () => {
    expect(buildTeamPairKey('team_B', 'team_A')).toBe('team_A|team_B');
    expect(buildTeamPairKey('team_A', 'team_B')).toBe('team_A|team_B');
    expect(buildTeamPairKey('team_002', 'team_001')).toBe('team_001|team_002');
  });
});

describe('validatePlayerForCell (Futbolcu Tekrar Kullanimi Destekli)', () => {
  const answerIndex = makeMockAnswerIndex();
  const rowTeams = ['team_A', 'team_B', 'team_C'];
  const colTeams = ['team_D', 'team_E', 'team_B'];

  it('hucre icin dogru oyuncu geldiginde valid:true doner', () => {
    const cellId = 0;
    const result = validatePlayerForCell(
      answerIndex, rowTeams, colTeams, cellId, 'player_6', [],
    );
    expect(result).toEqual({ valid: true });
  });

  it('hucre icin yanlis oyuncu geldiginde INVALID_PLAYER doner', () => {
    const cellId = 0;
    const result = validatePlayerForCell(
      answerIndex, rowTeams, colTeams, cellId, 'player_999', [],
    );
    expect(result).toEqual({ valid: false, error: 'INVALID_PLAYER' });
  });

  it('daha once kullanilmis oyuncu baska veya ayni kriterli hucrede TEKRAR kullanildiginda valid:true doner', () => {
    // player_6 was already used in cell 0 (A-D), and is also valid for cell 3 (B-D)
    const resultSameCellCheck = validatePlayerForCell(
      answerIndex, rowTeams, colTeams, 0, 'player_6', ['player_6'],
    );
    expect(resultSameCellCheck).toEqual({ valid: true });

    const resultAnotherCell = validatePlayerForCell(
      answerIndex, rowTeams, colTeams, 3, 'player_6', ['player_6'],
    );
    expect(resultAnotherCell).toEqual({ valid: true });
  });

  it('diger hucreler icin dogru oyunculari dogrular: (1,0) -> B-D -> player_9', () => {
    const cellId = 3;
    const result = validatePlayerForCell(
      answerIndex, rowTeams, colTeams, cellId, 'player_9', [],
    );
    expect(result).toEqual({ valid: true });
  });

  it('hucre (2,1) C-E player_17 gecerli', () => {
    const cellId = 7;
    const result = validatePlayerForCell(
      answerIndex, rowTeams, colTeams, cellId, 'player_17', [],
    );
    expect(result).toEqual({ valid: true });
  });
});

describe('checkWinner', () => {
  it('ilk satirda 3 X oldugunda X kullanicisini kazanan ilan eder', () => {
    const board: (BoardCell | null)[] = Array(9).fill(null);
    board[0] = makeCell('u1', 'X');
    board[1] = makeCell('u1', 'X');
    board[2] = makeCell('u1', 'X');
    const result = checkWinner(board);
    expect(result.winnerUserId).toBe('u1');
    expect(result.mark).toBe('X');
  });

  it('ikinci sutunda 3 O oldugunda O kullanicisini kazanan ilan eder', () => {
    const board: (BoardCell | null)[] = Array(9).fill(null);
    board[1] = makeCell('u2', 'O');
    board[4] = makeCell('u2', 'O');
    board[7] = makeCell('u2', 'O');
    const result = checkWinner(board);
    expect(result.winnerUserId).toBe('u2');
    expect(result.mark).toBe('O');
  });

  it('sol ustten sag alta diyagonal X kazanir', () => {
    const board: (BoardCell | null)[] = Array(9).fill(null);
    board[0] = makeCell('u1', 'X');
    board[4] = makeCell('u1', 'X');
    board[8] = makeCell('u1', 'X');
    const result = checkWinner(board);
    expect(result.winnerUserId).toBe('u1');
    expect(result.mark).toBe('X');
  });

  it('sag ustten sol alta diyagonal O kazanir', () => {
    const board: (BoardCell | null)[] = Array(9).fill(null);
    board[2] = makeCell('u2', 'O');
    board[4] = makeCell('u2', 'O');
    board[6] = makeCell('u2', 'O');
    const result = checkWinner(board);
    expect(result.winnerUserId).toBe('u2');
    expect(result.mark).toBe('O');
  });

  it('ucuncu satir kazanir', () => {
    const board: (BoardCell | null)[] = Array(9).fill(null);
    board[6] = makeCell('u1', 'X');
    board[7] = makeCell('u1', 'X');
    board[8] = makeCell('u1', 'X');
    expect(checkWinner(board).winnerUserId).toBe('u1');
  });

  it('karisik dizilimde kazanan yoksa null doner', () => {
    const board: (BoardCell | null)[] = Array(9).fill(null);
    board[0] = makeCell('u1', 'X');
    board[1] = makeCell('u2', 'O');
    board[2] = makeCell('u1', 'X');
    board[3] = makeCell('u2', 'O');
    expect(checkWinner(board).winnerUserId).toBeNull();
    expect(checkWinner(board).mark).toBeNull();
  });

  it('tum hucreler dolu ama uc siralma yoksa berabere (kazanan null)', () => {
    const board: (BoardCell | null)[] = [
      makeCell('u1', 'X'), makeCell('u2', 'O'), makeCell('u1', 'X'),
      makeCell('u1', 'X'), makeCell('u2', 'O'), makeCell('u2', 'O'),
      makeCell('u2', 'O'), makeCell('u1', 'X'), makeCell('u1', 'X'),
    ];
    expect(checkWinner(board).winnerUserId).toBeNull();
  });
});
