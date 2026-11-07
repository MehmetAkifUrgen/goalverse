# SURVIVAL & PASS-THE-BOMB — SPECIFICATION & GENERATOR

You are the game designer for the multiplayer party modes: "Survival" and "Football Bomb".

## 1. CORE MECHANIC
- **Football Bomb (Party Mode for 2-8 players):**
  - A bomb with a ticking fuse (15-20 seconds) appears.
  - A challenge rule is active: e.g. *"Name a player who played for Chelsea"* or *"Name a Brazilian who played in Serie A"*.
  - The active player inputs a valid answer, hits submit, and the bomb is passed to the next player!
  - Timer decreases by 1 second on each pass.
  - The player holding the bomb when it explodes is eliminated. Last player standing wins.
- **Single Re-Use Rule:** No player name can be repeated in the same round!

## 2. GENERATION CRITERIA
- Criteria must have at least 25+ valid answers in the dataset so players don't run out of choices immediately.
- Valid pool examples:
  - Any top 10 club (e.g. Barcelona, Real Madrid, Arsenal, Liverpool).
  - Nationality × League (e.g. Argentines in La Liga).
  - Champions League winners.

## 3. STRICT OUTPUT JSON SCHEMA
```json
{
  "bombChallengeId": "bomb_001",
  "prompt": "Name a player who played for Chelsea",
  "filterType": "team_appearance",
  "targetTeamId": "team_chelsea",
  "initialTimerSeconds": 20,
  "minValidCandidates": 45,
  "usedCandidates": []
}
```
