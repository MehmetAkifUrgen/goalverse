from typing import List, Dict, Any
from rapidfuzz import process, fuzz

from normalize.name_normalizer import normalize_name


def dedup_players(players: List[Dict[str, Any]], threshold: float = 0.92) -> List[Dict[str, Any]]:
    if not players:
        return []

    for p in players:
        if "normalizedName" not in p:
            p["normalizedName"] = normalize_name(p.get("name", ""))
        if "aliases" not in p:
            p["aliases"] = []

    used = [False] * len(players)
    result: List[Dict[str, Any]] = []
    normalized_names = [p["normalizedName"] for p in players]

    for i in range(len(players)):
        if used[i]:
            continue
        canonical = dict(players[i])
        canonical["aliases"] = list(players[i].get("aliases", []))
        canonical_name = canonical["normalizedName"]
        used[i] = True

        candidates = []
        for j in range(i + 1, len(players)):
            if used[j]:
                continue
            candidate_name = normalized_names[j]
            if not candidate_name:
                continue
            ratio = fuzz.ratio(canonical_name, candidate_name) / 100.0
            if ratio >= threshold:
                candidates.append((j, ratio))

        for j, _ in candidates:
            used[j] = True
            alias_player = players[j]
            original_name = alias_player.get("name", "")
            if original_name and original_name != canonical.get("name", ""):
                canonical["aliases"].append(original_name)

        result.append(canonical)

    return result
