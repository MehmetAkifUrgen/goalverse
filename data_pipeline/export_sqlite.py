import os
from typing import Any, Dict

import sqlite_utils
from sqlite_utils.db import Table


def _flatten_index(index: Dict[str, list], key_field: str, value_field: str):
    rows = []
    for k, v_list in index.items():
        for v in v_list:
            rows.append({key_field: k, value_field: v})
    return rows


def export_sqlite(data: Dict[str, Any], db_path: str) -> str:
    os.makedirs(os.path.dirname(db_path) or ".", exist_ok=True)

    if os.path.exists(db_path):
        os.remove(db_path)

    db = sqlite_utils.Database(db_path)

    players = data.get("players", [])
    teams = data.get("teams", [])
    history = data.get("player_team_history", [])
    answer_index = data.get("answer_index", {})

    player_rows = []
    for p in players:
        row = dict(p)
        aliases = row.get("aliases") or []
        row["aliases"] = ",".join(aliases) if isinstance(aliases, list) else str(aliases)
        player_rows.append(row)

    db["players"].insert_all(player_rows, pk="id")
    db["players"].create_index(["normalizedName"])

    db["teams"].insert_all(teams, pk="id")

    db["player_team_history"].insert_all(history, pk="id")

    answer_rows = _flatten_index(answer_index, "team_pair", "player_id")
    db["answer_index"].insert_all(answer_rows, pk=("team_pair", "player_id"))
    db["answer_index"].create_index(["team_pair"])

    db.close()
    return db_path
