import os
import sys
from typing import Any, Dict, List

import click

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sources.sample_download import download_sample
from normalize.name_normalizer import normalize_name
from normalize.team_normalizer import normalize_team_name
from dedup import dedup_players
from validate import validate_all
from indexer import build_team_player_index, build_answer_index
from export_json import export_json
from export_sqlite import export_sqlite


def _apply_normalization(data: Dict[str, Any]) -> Dict[str, Any]:
    teams: List[Dict[str, Any]] = []
    for t in data.get("teams", []):
        nt = dict(t)
        nt["normalizedName"] = normalize_team_name(t.get("name", ""))
        teams.append(nt)

    players: List[Dict[str, Any]] = []
    for p in data.get("players", []):
        np = dict(p)
        np["normalizedName"] = normalize_name(p.get("name", ""))
        if "aliases" not in np:
            np["aliases"] = []
        players.append(np)

    return {
        "teams": teams,
        "players": players,
        "player_team_history": data.get("player_team_history", []),
    }


from sources.transfermarkt_importer import import_transfermarkt_dataset

@click.command()
@click.option("--fixture", is_flag=True, help="Use built-in sample fixture (500 players, 20 teams).")
@click.option("--source", "source", default="fixture", type=click.Choice(["fixture", "transfermarkt"]),
              help="Data source to use: fixture or transfermarkt.")
@click.option("--out-dir", "out_dir", required=True, type=click.Path(file_okay=False), help="Output directory.")
@click.option("--dedup-threshold", "dedup_threshold", default=0.92, type=float, show_default=True,
              help="RapidFuzz similarity threshold for player dedup.")
def main(fixture: bool, source: str, out_dir: str, dedup_threshold: float) -> None:
    chosen_source = "fixture" if fixture else source
    click.echo(f"[1/7] Downloading sources (source={chosen_source})...")
    if chosen_source == "fixture":
        raw = download_sample()
    elif chosen_source == "transfermarkt":
        raw = import_transfermarkt_dataset()
    else:
        raise click.UsageError(f"Unsupported source: {chosen_source}")

    click.echo(f"[2/7] Normalizing names (players={len(raw.get('players', []))}, teams={len(raw.get('teams', []))})...")
    data = _apply_normalization(raw)

    click.echo(f"[3/7] Deduplicating players (threshold={dedup_threshold})...")
    deduped_players = dedup_players(data["players"], threshold=dedup_threshold)
    valid_pids = {p["id"] for p in deduped_players}
    filtered_history = [h for h in data["player_team_history"] if h.get("player_id") in valid_pids]
    data["players"] = deduped_players
    data["player_team_history"] = filtered_history
    click.echo(f"      Deduplicated player count: {len(deduped_players)}")

    click.echo("[4/7] Validating data...")
    validation = validate_all(data["players"], data["teams"], data["player_team_history"])
    if not validation.ok:
        for err in validation.errors[:20]:
            click.echo(f"      ! [{err.scope}:{err.id}] {err.field}: {err.message}", err=True)
        raise click.ClickException(f"Validation failed with {len(validation.errors)} error(s).")
    click.echo("      Validation passed.")

    click.echo("[5/7] Building indexes...")
    team_player_index = build_team_player_index(data["player_team_history"])
    answer_index = build_answer_index(team_player_index)
    data["team_player_index"] = team_player_index
    data["answer_index"] = answer_index
    click.echo(f"      team_player_index entries: {len(team_player_index)}")
    click.echo(f"      answer_index entries (pairs): {len(answer_index)}")

    click.echo(f"[6/7] Exporting JSON to {out_dir}...")
    paths = export_json(data, out_dir)
    for k, v in paths.items():
        click.echo(f"      + {k}: {os.path.relpath(v, os.path.dirname(out_dir) or '.')}")

    db_path = os.path.join(out_dir, "players.db")
    click.echo(f"[7/7] Exporting SQLite to {db_path}...")
    export_sqlite(data, db_path)
    click.echo(f"      + db: {db_path}")

    click.echo("Pipeline completed successfully.")


if __name__ == "__main__":
    main()
