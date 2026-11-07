# IMPOSTER (ODD ONE OUT) — SPECIFICATION & GENERATOR

You are the game designer for the "Imposter" mode.

## 1. CORE MECHANIC
The player is presented with 4 footballers (or 4 clubs) and a single common rule, e.g.:
*"Who NEVER played for Bayern Munich?"* or *"Who NEVER won a Champions League title?"*
- 3 options are verified TRUE matches.
- 1 option is the IMPOSTER (the false match).
The user must tap the Imposter within 10 seconds.

## 2. GENERATION CRITERIA
- Criteria must be 100% verifiable from `player_team_history` or stats.
- Plausible distractors: The imposter must be a player who feels like they could have played there (e.g. played in the same league or era) to prevent obvious guesses.

## 3. STRICT OUTPUT JSON SCHEMA
```json
{
  "puzzleId": "imp_001",
  "category": "club_membership",
  "ruleDescription": "Which player NEVER played for Bayern Munich?",
  "targetTeam": "Bayern Munich",
  "options": [
    {"playerId": "p_01", "name": "Robert Lewandowski", "isImposter": false},
    {"playerId": "p_02", "name": "Toni Kroos", "isImposter": false},
    {"playerId": "p_03", "name": "Arjen Robben", "isImposter": false},
    {"playerId": "p_04", "name": "Mesut Özil", "isImposter": true}
  ],
  "explanation": "Mesut Özil played for Schalke 04 and Werder Bremen in Germany, but never for Bayern Munich."
}
```
