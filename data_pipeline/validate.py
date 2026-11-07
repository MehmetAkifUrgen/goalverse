from datetime import datetime
from typing import List, Dict, Any, Tuple

from pydantic import BaseModel, field_validator, ConfigDict


class ValidationError(BaseModel):
    scope: str
    id: str
    field: str
    message: str


class ValidationResult(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    ok: bool
    errors: List[ValidationError] = []


def _current_year() -> int:
    return datetime.now().year


def validate_career(
    history_entry: Dict[str, Any],
    valid_player_ids: set,
    valid_team_ids: set,
) -> List[ValidationError]:
    errors: List[ValidationError] = []
    entry_id = str(history_entry.get("id", "UNKNOWN"))
    season_start = history_entry.get("seasonStart")
    season_end = history_entry.get("seasonEnd")
    player_id = history_entry.get("player_id")
    team_id = history_entry.get("team_id")

    if not isinstance(season_start, int) or not isinstance(season_end, int):
        errors.append(ValidationError(
            scope="career",
            id=entry_id,
            field="seasonStart/seasonEnd",
            message="Season years must be integers",
        ))
    else:
        if season_start > season_end:
            errors.append(ValidationError(
                scope="career",
                id=entry_id,
                field="seasonStart",
                message=f"seasonStart ({season_start}) cannot be greater than seasonEnd ({season_end})",
            ))
        cur_year = _current_year()
        if season_end > cur_year + 1:
            errors.append(ValidationError(
                scope="career",
                id=entry_id,
                field="seasonEnd",
                message=f"seasonEnd ({season_end}) exceeds current year + 1 ({cur_year + 1})",
            ))

    if player_id is None or player_id not in valid_player_ids:
        errors.append(ValidationError(
            scope="career",
            id=entry_id,
            field="player_id",
            message=f"Invalid player_id: {player_id}",
        ))

    if team_id is None or team_id not in valid_team_ids:
        errors.append(ValidationError(
            scope="career",
            id=entry_id,
            field="team_id",
            message=f"Invalid team_id: {team_id}",
        ))

    return errors


def validate_all(
    players: List[Dict[str, Any]],
    teams: List[Dict[str, Any]],
    player_team_history: List[Dict[str, Any]],
) -> ValidationResult:
    errors: List[ValidationError] = []
    valid_player_ids = {p.get("id") for p in players if p.get("id")}
    valid_team_ids = {t.get("id") for t in teams if t.get("id")}

    for p in players:
        if not p.get("id"):
            errors.append(ValidationError(
                scope="player",
                id=str(p.get("id", "MISSING")),
                field="id",
                message="Player is missing an id",
            ))
        if not p.get("name"):
            errors.append(ValidationError(
                scope="player",
                id=str(p.get("id", "MISSING")),
                field="name",
                message="Player is missing a name",
            ))

    for t in teams:
        if not t.get("id"):
            errors.append(ValidationError(
                scope="team",
                id=str(t.get("id", "MISSING")),
                field="id",
                message="Team is missing an id",
            ))
        if not t.get("name"):
            errors.append(ValidationError(
                scope="team",
                id=str(t.get("id", "MISSING")),
                field="name",
                message="Team is missing a name",
            ))

    for entry in player_team_history:
        errors.extend(validate_career(entry, valid_player_ids, valid_team_ids))

    return ValidationResult(ok=len(errors) == 0, errors=errors)
