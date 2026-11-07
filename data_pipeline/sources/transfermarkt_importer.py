import csv
import gzip
import io
import json
import os
import urllib.request
from typing import Dict, List, Set, Any

CLUBS_URL = "https://pub-e682421888d945d684bcae8890b0ec20.r2.dev/data/clubs.csv.gz"
PLAYERS_URL = "https://pub-e682421888d945d684bcae8890b0ec20.r2.dev/data/players.csv.gz"
TRANSFERS_URL = "https://pub-e682421888d945d684bcae8890b0ec20.r2.dev/data/transfers.csv.gz"

# Top domestic competitions to focus on (Premier League, La Liga, Serie A, Bundesliga, Ligue 1, Süper Lig, Liga Portugal, Eredivisie)
TARGET_COMPETITIONS = {"GB1", "ES1", "IT1", "L1", "FR1", "TR1", "PO1", "NL1"}

def stream_csv_gz(url: str):
    req = urllib.request.Request(url, headers={"User-Agent": "FootballApp/1.0"})
    with urllib.request.urlopen(req) as resp:
        with gzip.GzipFile(fileobj=io.BytesIO(resp.read())) as gz:
            lines = io.TextIOWrapper(gz, encoding="utf-8")
            reader = csv.DictReader(lines)
            for row in reader:
                yield row

def import_transfermarkt_dataset(
    target_competitions: Set[str] = TARGET_COMPETITIONS,
    min_market_value: int = 1_000_000,
    max_clubs: int = 100,
) -> Dict[str, Any]:
    print(f"[1/4] Fetching clubs from {CLUBS_URL}...")
    valid_club_ids = set()
    clubs_data = []

    for row in stream_csv_gz(CLUBS_URL):
        comp = row.get("domestic_competition_id")
        if comp in target_competitions:
            club_id = row.get("club_id")
            name = row.get("name")
            valid_club_ids.add(club_id)
            clubs_data.append({
                "id": f"team_{club_id}",
                "raw_id": club_id,
                "name": name,
                "country": comp[:2],
                "normalizedName": name.lower(),
                "aliases": [row.get("club_code", "").replace("-", " ")],
            })
            if len(clubs_data) >= max_clubs:
                break

    print(f"      Selected {len(clubs_data)} clubs.")

    print(f"[2/4] Fetching players from {PLAYERS_URL}...")
    players_data = []
    valid_player_ids = set()

    for row in stream_csv_gz(PLAYERS_URL):
        current_club_id = row.get("current_club_id")
        # Include player if currently at or has played in our target pool
        if current_club_id in valid_club_ids:
            try:
                mv = int(float(row.get("market_value_in_eur") or 0))
            except ValueError:
                mv = 0

            # Only retain recognizable/prominent players
            if mv >= min_market_value:
                pid = row.get("player_id")
                valid_player_ids.add(pid)
                name = row.get("name")
                players_data.append({
                    "id": f"player_{pid}",
                    "raw_id": pid,
                    "name": name,
                    "normalizedName": name.lower(),
                    "nationality": row.get("country_of_citizenship"),
                    "position": row.get("position"),
                    "marketValueEuro": mv,
                    "photoUrl": row.get("image_url"),
                    "currentClubId": f"team_{current_club_id}",
                })

    print(f"      Selected {len(players_data)} players.")

    print(f"[3/4] Fetching transfers & career history from {TRANSFERS_URL}...")
    history = []
    history_set = set()

    for row in stream_csv_gz(TRANSFERS_URL):
        pid = row.get("player_id")
        if pid in valid_player_ids:
            from_club = row.get("from_club_id")
            to_club = row.get("to_club_id")
            season = row.get("transfer_season")

            year = 2020
            if season and "/" in season:
                try:
                    year = 2000 + int(season.split("/")[0])
                except Exception:
                    pass

            for cid in (from_club, to_club):
                if cid in valid_club_ids:
                    key = (pid, cid)
                    if key not in history_set:
                        history_set.add(key)
                        history.append({
                            "player_id": f"player_{pid}",
                            "team_id": f"team_{cid}",
                            "start_year": year,
                            "end_year": year + 2,
                        })

    print(f"      Extracted {len(history)} career club appearances.")

    return {
        "teams": clubs_data,
        "players": players_data,
        "player_team_history": history,
    }
