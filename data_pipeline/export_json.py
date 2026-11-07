import json
import os
from typing import Any, Dict


def _write_json(obj: Any, path: str) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)


def export_json(data: Dict[str, Any], out_dir: str) -> Dict[str, str]:
    os.makedirs(out_dir, exist_ok=True)
    players = data.get("players", [])
    teams = data.get("teams", [])
    history = data.get("player_team_history", [])
    team_player_index = data.get("team_player_index", {})
    answer_index = data.get("answer_index", {})

    paths = {
        "players": os.path.join(out_dir, "players.json"),
        "teams": os.path.join(out_dir, "teams.json"),
        "player_team_history": os.path.join(out_dir, "player_team_history.json"),
        "team_player_index": os.path.join(out_dir, "team_player_index.json"),
        "answer_index": os.path.join(out_dir, "answer_index.json"),
    }

    _write_json(players, paths["players"])
    _write_json(teams, paths["teams"])
    _write_json(history, paths["player_team_history"])
    _write_json(team_player_index, paths["team_player_index"])
    _write_json(answer_index, paths["answer_index"])

    return paths
