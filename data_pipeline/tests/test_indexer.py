import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from indexer import build_team_player_index, build_answer_index


def test_team_player_index_groups_by_team():
    history = [
        {"player_id": "p1", "team_id": "tA"},
        {"player_id": "p2", "team_id": "tA"},
        {"player_id": "p3", "team_id": "tB"},
    ]
    idx = build_team_player_index(history)
    assert idx == {"tA": ["p1", "p2"], "tB": ["p3"]}


def test_team_player_index_dedupes_players():
    history = [
        {"player_id": "p1", "team_id": "tA"},
        {"player_id": "p1", "team_id": "tA"},
    ]
    idx = build_team_player_index(history)
    assert idx == {"tA": ["p1"]}


def test_answer_index_lexicographic_key():
    tpi = {
        "t001": ["p_ronaldo", "p_else"],
        "t007": ["p_ronaldo", "p_other"],
        "t009": ["p_ronaldo"],
    }
    ans = build_answer_index(tpi)
    expected_key_17 = "|".join(sorted(["t001", "t007"]))
    expected_key_19 = "|".join(sorted(["t001", "t009"]))
    expected_key_79 = "|".join(sorted(["t007", "t009"]))
    assert expected_key_17 in ans
    assert "p_ronaldo" in ans[expected_key_17]
    assert expected_key_19 in ans
    assert "p_ronaldo" in ans[expected_key_19]
    assert expected_key_79 in ans
    assert "p_ronaldo" in ans[expected_key_79]


def test_answer_index_empty_without_common_players():
    tpi = {
        "tA": ["p1", "p2"],
        "tB": ["p3", "p4"],
    }
    ans = build_answer_index(tpi)
    assert ans == {}


def test_answer_index_ronaldo_in_two_teams_from_fixture_style():
    tpi = {
        "team_007": ["player_0001", "p_mu_other"],
        "team_001": ["player_0001", "p_rm_other"],
    }
    ans = build_answer_index(tpi)
    key = "|".join(sorted(["team_001", "team_007"]))
    assert key in ans
    assert "player_0001" in ans[key]
