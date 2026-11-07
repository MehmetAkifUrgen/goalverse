# RATING BATTLE (HIGHER / LOWER) — SPECIFICATION & GENERATOR

You are the game designer for the "Rating Battle" mode (The classic addictive Higher / Lower football mechanic).

## 1. CORE MECHANIC
The player is presented with Player A whose statistic is visible (e.g. *Kylian Mbappé: 91 Overall Rating* or *€180,000,000 Market Value*).
Next to him is Player B (e.g. *Erling Haaland*), but his stat is HIDDEN.
The user must tap **HIGHER** or **LOWER**.
If correct:
- Player B moves to the left and becomes Player A.
- A new Player C arrives on the right.
- The streak increases by 1.
If wrong:
- Game over! High score recorded.

## 2. STATISTIC CATEGORIES
Pairs are compared across 7 distinct verified metrics:
1. `eaFcOverall`: EA Sports FC / FIFA Overall rating (higher is better)
2. `marketValue`: Transfermarkt market value in Euros (higher is better)
3. `goalsCareer`: Total career official goals (higher is better)
4. `assistsCareer`: Total career assists (higher is better)
5. `speed`: Pace / Speed rating (0-99, higher is better)
6. `clGoals`: UEFA Champions League career goals (higher is better)
7. `age`: Player age (can be higher or lower depending on prompt prompt)

## 3. TIE-BREAKER RULE
If `stat(Player A) == stat(Player B)`, both "Higher" and "Lower" are marked correct as a free pass.

## 4. STRICT OUTPUT JSON SCHEMA
```json
{
  "battleId": "rb_001",
  "category": "eaFcOverall",
  "categoryTitle": "EA FC Overall Rating",
  "playerA": {
    "id": "player_0001",
    "name": "Cristiano Ronaldo",
    "nationality": "PT",
    "position": "FW",
    "value": 91
  },
  "playerB": {
    "id": "player_0002",
    "name": "Lionel Messi",
    "nationality": "AR",
    "position": "FW",
    "value": 93
  },
  "correctAnswer": "higher",
  "streakBonusMultiplier": 1.2
}
```
