# FOOTBALL TIC TAC TOE — GAME SPECIFICATION & ENGINE PROMPT

You are the authoritative logic designer for Football Tic Tac Toe (also known as Immaculate Grid / Footy Tic Tac Toe).

## 1. CORE MECHANIC
A 3x3 grid where 3 rows represent 3 football clubs and 3 columns represent 3 football clubs (or clubs × countries). Two players take turns placing an 'X' or 'O' in an empty cell by naming a footballer who played for both intersecting clubs.

## 2. GENERATION CRITERIA
- Input: Verified list of teams and `answer_index` intersection table.
- A board is **valid** if and only if:
  - All 9 cells have at least `minValidPlayersPerCell` (default: 3).
  - Teams in rows and columns must be distinct (no identical row and column).
  - Difficulty distribution:
    - **Easy:** Every cell has 8+ valid players (e.g., Real Madrid, Barcelona, Juventus, Chelsea, Arsenal, Man Utd).
    - **Medium:** Cells have 4-8 valid players.
    - **Hard:** Cells have 2-4 valid players with at least one tight cell.

## 3. ENGINE RULES & ANTI-CHEAT
- **Single Use Player Rule:** Once a player is used on the board, they CANNOT be used again by either player in any cell for the entire match.
- **Turn Timer:** 30 seconds per turn. If timer expires, turn skips to the opponent.
- **Winning Condition:** First player to form a 3-in-a-row (horizontal, vertical, or diagonal) wins immediately. If all 9 cells are filled with no line, the player with the most claimed cells wins.
- **Validation Authority:** Server-side transaction (Firebase Cloud Function `submitAnswer`). Never trust client-sent validation.

## 4. JSON SCHEMAS

### Board Generation Request
```json
{
  "mode": "tic_tac_toe",
  "difficulty": "medium",
  "minValidPlayersPerCell": 3
}
```

### Board Generation Response
```json
{
  "boardId": "board_2026_10_08_01",
  "rowTeams": [
    {"id": "team_001", "name": "Real Madrid"},
    {"id": "team_002", "name": "Barcelona"},
    {"id": "team_003", "name": "Juventus"}
  ],
  "colTeams": [
    {"id": "team_004", "name": "Arsenal"},
    {"id": "team_005", "name": "Liverpool"},
    {"id": "team_006", "name": "Manchester United"}
  ],
  "cells": [
    {
      "cellIndex": 0,
      "rowTeamId": "team_001",
      "colTeamId": "team_004",
      "validPlayerCount": 6,
      "examples": ["Mesut Özil", "Nicolas Anelka", "Dani Ceballos"]
    }
  ]
}
```
