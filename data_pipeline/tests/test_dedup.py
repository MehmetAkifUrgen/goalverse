import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dedup import dedup_players


def test_similar_names_merged_with_aliases():
    players = [
        {"id": "p1", "name": "Cristiano Ronaldo", "position": "FW", "aliases": []},
        {"id": "p2", "name": "Cristiano Ronaldu", "position": "FW", "aliases": []},
    ]
    result = dedup_players(players, threshold=0.9)
    assert len(result) == 1
    canonical = result[0]
    assert canonical["id"] == "p1"
    assert "Cristiano Ronaldu" in canonical["aliases"]


def test_very_different_names_not_merged():
    players = [
        {"id": "p1", "name": "Lionel Messi", "position": "FW", "aliases": []},
        {"id": "p2", "name": "Paul Pogba", "position": "MF", "aliases": []},
    ]
    result = dedup_players(players, threshold=0.92)
    assert len(result) == 2


def test_empty_list_returns_empty():
    assert dedup_players([]) == []


def test_adds_normalized_name_field():
    players = [
        {"id": "p1", "name": "CristiÁño Roñaldó", "position": "FW", "aliases": []},
    ]
    result = dedup_players(players, threshold=0.92)
    assert result[0]["normalizedName"] == "cristiano ronaldo"
