from typing import List, Dict, Any, Set
from itertools import combinations


def build_team_player_index(history: List[Dict[str, Any]]) -> Dict[str, List[str]]:
    team_players: Dict[str, Set[str]] = {}
    for entry in history:
        tid = entry.get("team_id")
        pid = entry.get("player_id")
        if not tid or not pid:
            continue
        if tid not in team_players:
            team_players[tid] = set()
        team_players[tid].add(pid)
    return {tid: sorted(list(pids)) for tid, pids in team_players.items()}


def build_answer_index(team_player_index: Dict[str, List[str]]) -> Dict[str, List[str]]:
    team_players_sets: Dict[str, Set[str]] = {
        tid: set(pids) for tid, pids in team_player_index.items()
    }
    team_ids = sorted(team_player_index.keys())
    answer: Dict[str, List[str]] = {}
    for ta, tb in combinations(team_ids, 2):
        pair_key = "|".join(sorted([ta, tb]))
        common = sorted(list(team_players_sets[ta] & team_players_sets[tb]))
        if common:
            answer[pair_key] = common
    return answer
