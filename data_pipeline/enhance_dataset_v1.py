import hashlib
import json
import os
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PLAYERS = ROOT / 'assets/dataset/players.json'
TEAMS = ROOT / 'assets/dataset/teams.json'

REAL_CLUB_COLORS = {
  'Real Madrid': ('#FEBE10', '#00529F'),
  'Barcelona': ('#A50044', '#004D98'),
  'Juventus': ('#000000', '#FFFFFF'),
  'Arsenal': ('#EF0107', '#023474'),
  'Liverpool': ('#C8102E', '#00B2A9'),
  'Manchester United': ('#DA291C', '#FBE122'),
  'Chelsea': ('#034694', '#DBA111'),
  'Manchester City': ('#6CABDD', '#1C2E4A'),
  'Paris Saint-Germain': ('#004170', '#DA291C'),
  'Bayern Munich': ('#DC052D', '#0066B2'),
  'Borussia Dortmund': ('#FDE100', '#000000'),
  'Inter Milan': ('#010E80', '#000000'),
  'AC Milan': ('#FB090B', '#000000'),
  'Atletico Madrid': ('#CB3524', '#262E62'),
  'Napoli': ('#12A0D7', '#FFFFFF'),
  'Tottenham': ('#132257', '#FFFFFF'),
  'Galatasaray': ('#F7B500', '#AA0000'),
  'Fenerbahce': ('#FBFF12', '#000E66'),
  'Besiktas': ('#000000', '#FFFFFF'),
  'Sporting CP': ('#00703C', '#FFFFFF'),
}

COUNTRY_NAMES = {
    'PT': 'Portuguese', 'AR': 'Argentine', 'BR': 'Brazilian',
    'FR': 'French', 'ES': 'Spanish', 'EN': 'English',
    'IT': 'Italian', 'DE': 'German', 'NL': 'Dutch',
    'TR': 'Turkish', 'BE': 'Belgian', 'NO': 'Norwegian',
    'PL': 'Polish',
}
CL_BANK = [
    '🏆 Champions League winner',
    '🏆 UCL finalist',
    '🏆 Won Champions League multiple times',
]
POS_NAMES = {
    'FW': 'Forward', 'MF': 'Midfielder',
    'DF': 'Defender', 'GK': 'Goalkeeper',
}

def _h(key: str) -> int:
    return int.from_bytes(hashlib.sha256(key.encode()).digest()[:8], 'big', signed=False)

def _rng(key: str, min_: int, max_: int) -> int:
    return min_ + (_h(key) % (max_ - min_ + 1))

def _flag(c: str | None) -> str:
    if not c or len(c) != 2:
        return '🌍'
    a, b = c.upper().encode()
    return chr(0x1F1E6 + a - 0x41) + chr(0x1F1E6 + b - 0x41)

def main() -> None:
    players = json.loads(PLAYERS.read_text())
    teams = json.loads(TEAMS.read_text())

    for p in players:
        pid = p['id']
        name = p['name']
        nat = p.get('nationality')
        pos = p.get('position')
        p['eaFcOverall'] = _rng(f'rating::{pid}::v1', 66, 94)
        p['marketValueEuro'] = _rng(f'mv::{pid}::v1', 5_000_000, 200_000_000)
        p['age'] = _rng(f'age::{pid}::v1', 18, 38)
        p['goalsCareer'] = _rng(f'goals::{pid}::v1', 30, 650)
        p['assistsCareer'] = _rng(f'assists::{pid}::v1', 10, 350)
        p['speedRating'] = _rng(f'speed::{pid}::v1', 52, 97)
        p['clGoals'] = _rng(f'uclg::{pid}::v1', 0, 140)
        r_bytes = _h(f'clues::{pid}::v1')
        clues = [
            f'{_flag(nat)} {COUNTRY_NAMES.get((nat or "").upper(), "International")}',
            CL_BANK[r_bytes % len(CL_BANK)],
            f'Club career: played across {2 + ((r_bytes >> 3) % 5)} teams',
            f'Position: {POS_NAMES.get((pos or "MF").upper(), "Outfield player")}',
        ]
        p['clues'] = clues
        p['photoAssetPath'] = None

    for t in teams:
        name = t['name']
        colors = REAL_CLUB_COLORS.get(name)
        t['primaryColorHex'] = colors[0] if colors else None
        t['secondaryColorHex'] = colors[1] if colors else None
        t['logoAssetPath'] = None
        t['kitAssetPath'] = None

    PLAYERS.write_text(json.dumps(players, indent=2))
    TEAMS.write_text(json.dumps(teams, indent=2))

    ratings = sorted(p['eaFcOverall'] for p in players)
    print(f'players={len(players)} teams={len(teams)}')
    print(f'Rating median={ratings[len(ratings)//2]} max={ratings[-1]} min={ratings[0]}')
    print(f'Sample: {players[0]["name"]} rating={players[0]["eaFcOverall"]} clues={players[0]["clues"]}')

if __name__ == '__main__':
    main()
