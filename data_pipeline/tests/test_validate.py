import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from validate import validate_career, validate_all


def test_season_start_after_end_is_invalid():
    entry = {
        "id": "h1",
        "player_id": "p1",
        "team_id": "t1",
        "seasonStart": 2020,
        "seasonEnd": 2015,
    }
    errors = validate_career(entry, {"p1"}, {"t1"})
    assert len(errors) >= 1
    assert any("seasonStart" in e.field or "greater" in e.message for e in errors)


def test_valid_career_returns_no_errors():
    entry = {
        "id": "h1",
        "player_id": "p1",
        "team_id": "t1",
        "seasonStart": 2018,
        "seasonEnd": 2022,
    }
    assert validate_career(entry, {"p1"}, {"t1"}) == []


def test_invalid_player_id_is_reported():
    entry = {
        "id": "h1",
        "player_id": "nonexistent",
        "team_id": "t1",
        "seasonStart": 2018,
        "seasonEnd": 2022,
    }
    errors = validate_career(entry, {"p1"}, {"t1"})
    assert any(e.field == "player_id" for e in errors)


def test_invalid_team_id_is_reported():
    entry = {
        "id": "h1",
        "player_id": "p1",
        "team_id": "nonexistent",
        "seasonStart": 2018,
        "seasonEnd": 2022,
    }
    errors = validate_career(entry, {"p1"}, {"t1"})
    assert any(e.field == "team_id" for e in errors)


def test_validate_all_with_bad_history_is_not_ok():
    players = [{"id": "p1", "name": "Foo"}]
    teams = [{"id": "t1", "name": "Bar"}]
    history = [{
        "id": "h1",
        "player_id": "p1",
        "team_id": "t1",
        "seasonStart": 2025,
        "seasonEnd": 2020,
    }]
    res = validate_all(players, teams, history)
    assert res.ok is False
    assert len(res.errors) >= 1


def test_validate_all_with_missing_name_reports_error():
    players = [{"id": "p1", "name": ""}]
    teams = [{"id": "t1", "name": "Bar"}]
    res = validate_all(players, teams, [])
    assert res.ok is False
    assert any(e.field == "name" and e.scope == "player" for e in res.errors)
