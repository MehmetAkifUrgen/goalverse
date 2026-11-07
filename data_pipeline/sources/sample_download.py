import random
import uuid
from typing import List, Dict, Any

TEAMS_DEFINITION = [
    {"name": "Real Madrid", "country": "ES"},
    {"name": "Barcelona", "country": "ES"},
    {"name": "Juventus", "country": "IT"},
    {"name": "Arsenal", "country": "EN"},
    {"name": "Liverpool", "country": "EN"},
    {"name": "Galatasaray", "country": "TR"},
    {"name": "Manchester United", "country": "EN"},
    {"name": "Manchester City", "country": "EN"},
    {"name": "Bayern Munich", "country": "DE"},
    {"name": "PSG", "country": "FR"},
    {"name": "Inter", "country": "IT"},
    {"name": "AC Milan", "country": "IT"},
    {"name": "Chelsea", "country": "EN"},
    {"name": "Atletico Madrid", "country": "ES"},
    {"name": "Dortmund", "country": "DE"},
    {"name": "Napoli", "country": "IT"},
    {"name": "Tottenham", "country": "EN"},
    {"name": "Roma", "country": "IT"},
    {"name": "Benfica", "country": "PT"},
    {"name": "Ajax", "country": "NL"},
]

FAMOUS_PLAYERS = [
    {
        "name": "Cristiano Ronaldo",
        "nationality": "PT",
        "position": "FW",
        "career": [
            ("Manchester United", 2003, 2009),
            ("Real Madrid", 2009, 2018),
            ("Juventus", 2018, 2021),
            ("Manchester United", 2021, 2022),
        ],
    },
    {
        "name": "Lionel Messi",
        "nationality": "AR",
        "position": "FW",
        "career": [
            ("Barcelona", 2004, 2021),
            ("PSG", 2021, 2023),
        ],
    },
    {
        "name": "Neymar Jr",
        "nationality": "BR",
        "position": "FW",
        "career": [
            ("Barcelona", 2013, 2017),
            ("PSG", 2017, 2023),
        ],
    },
    {
        "name": "Kylian Mbappe",
        "nationality": "FR",
        "position": "FW",
        "career": [
            ("PSG", 2017, 2024),
            ("Real Madrid", 2024, 2026),
        ],
    },
    {
        "name": "Zlatan Ibrahimovic",
        "nationality": "SE",
        "position": "FW",
        "career": [
            ("Ajax", 2001, 2004),
            ("Juventus", 2004, 2006),
            ("AC Milan", 2010, 2012),
            ("Manchester United", 2016, 2018),
        ],
    },
    {
        "name": "Paul Pogba",
        "nationality": "FR",
        "position": "MF",
        "career": [
            ("Manchester United", 2011, 2012),
            ("Juventus", 2012, 2016),
            ("Manchester United", 2016, 2022),
        ],
    },
    {
        "name": "Luka Modric",
        "nationality": "HR",
        "position": "MF",
        "career": [
            ("Tottenham", 2008, 2012),
            ("Real Madrid", 2012, 2024),
        ],
    },
    {
        "name": "Toni Kroos",
        "nationality": "DE",
        "position": "MF",
        "career": [
            ("Bayern Munich", 2007, 2014),
            ("Real Madrid", 2014, 2024),
        ],
    },
    {
        "name": "Mohamed Salah",
        "nationality": "EG",
        "position": "FW",
        "career": [
            ("Chelsea", 2014, 2016),
            ("Roma", 2015, 2017),
            ("Liverpool", 2017, 2026),
        ],
    },
    {
        "name": "Virgil van Dijk",
        "nationality": "NL",
        "position": "DF",
        "career": [
            ("Ajax", 2013, 2015),
            ("Liverpool", 2018, 2026),
        ],
    },
    {
        "name": "Kevin De Bruyne",
        "nationality": "BE",
        "position": "MF",
        "career": [
            ("Chelsea", 2012, 2014),
            ("Manchester City", 2015, 2026),
        ],
    },
    {
        "name": "Erling Haaland",
        "nationality": "NO",
        "position": "FW",
        "career": [
            ("Dortmund", 2020, 2022),
            ("Manchester City", 2022, 2026),
        ],
    },
    {
        "name": "Robert Lewandowski",
        "nationality": "PL",
        "position": "FW",
        "career": [
            ("Dortmund", 2010, 2014),
            ("Bayern Munich", 2014, 2022),
            ("Barcelona", 2022, 2026),
        ],
    },
    {
        "name": "Thibaut Courtois",
        "nationality": "BE",
        "position": "GK",
        "career": [
            ("Chelsea", 2011, 2018),
            ("Real Madrid", 2018, 2026),
        ],
    },
    {
        "name": "Sergio Ramos",
        "nationality": "ES",
        "position": "DF",
        "career": [
            ("Real Madrid", 2005, 2021),
            ("PSG", 2021, 2023),
        ],
    },
    {
        "name": "Andres Iniesta",
        "nationality": "ES",
        "position": "MF",
        "career": [
            ("Barcelona", 2002, 2018),
        ],
    },
    {
        "name": "Xavi Hernandez",
        "nationality": "ES",
        "position": "MF",
        "career": [
            ("Barcelona", 1998, 2015),
        ],
    },
    {
        "name": "Gianluigi Buffon",
        "nationality": "IT",
        "position": "GK",
        "career": [
            ("Juventus", 2001, 2018),
            ("PSG", 2018, 2019),
            ("Juventus", 2019, 2021),
        ],
    },
    {
        "name": "Gareth Bale",
        "nationality": "WAL",
        "position": "FW",
        "career": [
            ("Tottenham", 2007, 2013),
            ("Real Madrid", 2013, 2020),
            ("Tottenham", 2020, 2021),
        ],
    },
    {
        "name": "Luis Suarez",
        "nationality": "UY",
        "position": "FW",
        "career": [
            ("Ajax", 2007, 2011),
            ("Liverpool", 2011, 2014),
            ("Barcelona", 2014, 2020),
            ("Atletico Madrid", 2020, 2022),
        ],
    },
    {
        "name": "Antoine Griezmann",
        "nationality": "FR",
        "position": "FW",
        "career": [
            ("Atletico Madrid", 2014, 2019),
            ("Barcelona", 2019, 2021),
            ("Atletico Madrid", 2021, 2026),
        ],
    },
    {
        "name": "Alphonso Davies",
        "nationality": "CA",
        "position": "DF",
        "career": [
            ("Bayern Munich", 2019, 2026),
        ],
    },
    {
        "name": "Joshua Kimmich",
        "nationality": "DE",
        "position": "MF",
        "career": [
            ("Bayern Munich", 2015, 2026),
        ],
    },
    {
        "name": "Manuel Neuer",
        "nationality": "DE",
        "position": "GK",
        "career": [
            ("Bayern Munich", 2011, 2024),
        ],
    },
    {
        "name": "Thomas Muller",
        "nationality": "DE",
        "position": "FW",
        "career": [
            ("Bayern Munich", 2008, 2026),
        ],
    },
    {
        "name": "Jadon Sancho",
        "nationality": "EN",
        "position": "MF",
        "career": [
            ("Dortmund", 2017, 2021),
            ("Manchester United", 2021, 2024),
            ("Dortmund", 2024, 2026),
        ],
    },
    {
        "name": "Christian Eriksen",
        "nationality": "DK",
        "position": "MF",
        "career": [
            ("Tottenham", 2013, 2020),
            ("Inter", 2020, 2021),
            ("Manchester United", 2022, 2024),
        ],
    },
    {
        "name": "Romelu Lukaku",
        "nationality": "BE",
        "position": "FW",
        "career": [
            ("Chelsea", 2011, 2014),
            ("Manchester United", 2017, 2019),
            ("Inter", 2019, 2021),
            ("Chelsea", 2021, 2022),
            ("Roma", 2023, 2026),
        ],
    },
    {
        "name": "Lorenzo Insigne",
        "nationality": "IT",
        "position": "FW",
        "career": [
            ("Napoli", 2012, 2022),
        ],
    },
    {
        "name": "Kalidou Koulibaly",
        "nationality": "SN",
        "position": "DF",
        "career": [
            ("Napoli", 2014, 2022),
            ("Chelsea", 2022, 2023),
        ],
    },
    {
        "name": "Edinson Cavani",
        "nationality": "UY",
        "position": "FW",
        "career": [
            ("Napoli", 2010, 2013),
            ("PSG", 2013, 2020),
            ("Manchester United", 2020, 2022),
        ],
    },
    {
        "name": "David Silva",
        "nationality": "ES",
        "position": "MF",
        "career": [
            ("Manchester City", 2010, 2020),
            ("Real Madrid", 2006, 2010),
        ],
    },
    {
        "name": "Sergio Aguero",
        "nationality": "AR",
        "position": "FW",
        "career": [
            ("Atletico Madrid", 2006, 2011),
            ("Manchester City", 2011, 2021),
            ("Barcelona", 2021, 2021),
        ],
    },
    {
        "name": "Robin van Persie",
        "nationality": "NL",
        "position": "FW",
        "career": [
            ("Arsenal", 2004, 2012),
            ("Manchester United", 2012, 2015),
        ],
    },
    {
        "name": "Cesc Fabregas",
        "nationality": "ES",
        "position": "MF",
        "career": [
            ("Arsenal", 2003, 2011),
            ("Barcelona", 2011, 2014),
            ("Chelsea", 2014, 2019),
        ],
    },
    {
        "name": "Thierry Henry",
        "nationality": "FR",
        "position": "FW",
        "career": [
            ("Arsenal", 1999, 2007),
            ("Barcelona", 2007, 2010),
        ],
    },
    {
        "name": "Andrea Pirlo",
        "nationality": "IT",
        "position": "MF",
        "career": [
            ("AC Milan", 2001, 2011),
            ("Juventus", 2011, 2015),
        ],
    },
    {
        "name": "Paolo Maldini",
        "nationality": "IT",
        "position": "DF",
        "career": [
            ("AC Milan", 1985, 2009),
        ],
    },
    {
        "name": "Alessandro Del Piero",
        "nationality": "IT",
        "position": "FW",
        "career": [
            ("Juventus", 1993, 2012),
        ],
    },
    {
        "name": "Frank Rijkaard",
        "nationality": "NL",
        "position": "MF",
        "career": [
            ("Ajax", 1980, 1987),
            ("AC Milan", 1988, 1993),
            ("Ajax", 1993, 1995),
        ],
    },
    {
        "name": "Marco van Basten",
        "nationality": "NL",
        "position": "FW",
        "career": [
            ("Ajax", 1982, 1987),
            ("AC Milan", 1987, 1995),
        ],
    },
    {
        "name": "Ruud Gullit",
        "nationality": "NL",
        "position": "MF",
        "career": [
            ("PSG", 1987, 1987),
            ("AC Milan", 1987, 1993),
            ("Chelsea", 1995, 1998),
        ],
    },
    {
        "name": "Dennis Bergkamp",
        "nationality": "NL",
        "position": "FW",
        "career": [
            ("Ajax", 1986, 1993),
            ("Arsenal", 1995, 2006),
        ],
    },
    {
        "name": "Edwin van der Sar",
        "nationality": "NL",
        "position": "GK",
        "career": [
            ("Ajax", 1991, 1999),
            ("Manchester United", 2005, 2011),
        ],
    },
    {
        "name": "Wesley Sneijder",
        "nationality": "NL",
        "position": "MF",
        "career": [
            ("Ajax", 2002, 2007),
            ("Real Madrid", 2007, 2009),
            ("Inter", 2009, 2013),
        ],
    },
    {
        "name": "Arjen Robben",
        "nationality": "NL",
        "position": "FW",
        "career": [
            ("Chelsea", 2004, 2007),
            ("Real Madrid", 2007, 2009),
            ("Bayern Munich", 2009, 2019),
        ],
    },
    {
        "name": "Clarence Seedorf",
        "nationality": "NL",
        "position": "MF",
        "career": [
            ("Ajax", 1992, 1995),
            ("Real Madrid", 1996, 1999),
            ("AC Milan", 2002, 2012),
        ],
    },
    {
        "name": "Patrick Kluivert",
        "nationality": "NL",
        "position": "FW",
        "career": [
            ("Ajax", 1994, 1997),
            ("Barcelona", 1998, 2004),
        ],
    },
    {
        "name": "Rafael van der Vaart",
        "nationality": "NL",
        "position": "MF",
        "career": [
            ("Ajax", 2000, 2005),
            ("Tottenham", 2010, 2012),
        ],
    },
    {
        "name": "Mateo Kovacic",
        "nationality": "HR",
        "position": "MF",
        "career": [
            ("Inter", 2013, 2015),
            ("Real Madrid", 2015, 2018),
            ("Chelsea", 2018, 2023),
            ("Manchester City", 2023, 2026),
        ],
    },
    {
        "name": "Achraf Hakimi",
        "nationality": "MA",
        "position": "DF",
        "career": [
            ("Real Madrid", 2017, 2020),
            ("Dortmund", 2018, 2020),
            ("Inter", 2020, 2021),
            ("PSG", 2021, 2026),
        ],
    },
]

FIRST_NAMES = [
    "Ahmet", "Mehmet", "Mustafa", "Hakan", "Okan", "Burak", "Semih", "Can", "Kerem", "Eren",
    "Arda", "Baris", "Ugur", "Furkan", "Batuhan", "Kaan", "Enes", "Emre", "Tolgahan", "Sercan",
    "James", "John", "David", "Michael", "William", "Daniel", "Matthew", "Anthony", "Robert", "Joseph",
    "Carlos", "Juan", "Javier", "Luis", "Jose", "Miguel", "Antonio", "Francisco", "Rafael", "Pablo",
    "Marco", "Alessandro", "Andrea", "Luca", "Giovanni", "Francesco", "Matteo", "Davide", "Simone", "Nicolo",
    "Hans", "Peter", "Klaus", "Thomas", "Stefan", "Markus", "Michael", "Andreas", "Daniel", "Jens",
    "Lucas", "Arthur", "Caio", "Enzo", "Joao", "Diogo", "Bruno", "Bernardo", "Ruben", "Goncalo",
    "Florian", "Julian", "Maximilian", "Philipp", "Lukas", "Nico", "Jonas", "Timo", "Levin", "Jannik",
    "Victor", "Ibrahim", "Yusuf", "Omar", "Karim", "Bilal", "Amir", "Samir", "Rashid", "Hassan",
    "Henrik", "Erik", "Lars", "Anders", "Mats", "Kristian", "Oliver", "Alexander", "Emil", "Viktor",
]

LAST_NAMES = [
    "Yilmaz", "Demir", "Kaya", "Celik", "Arslan", "Korkmaz", "Ozdemir", "Aydin", "Yildiz", "Turan",
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Davis", "Miller", "Wilson", "Taylor", "Anderson",
    "Garcia", "Martinez", "Rodriguez", "Fernandez", "Lopez", "Gonzalez", "Sanchez", "Perez", "Ramirez", "Cruz",
    "Rossi", "Bianchi", "Ferrari", "Russo", "Fontana", "Moretti", "Marino", "Greco", "Bruno", "Lombardi",
    "Muller", "Schmidt", "Schneider", "Fischer", "Weber", "Meyer", "Wagner", "Becker", "Hoffmann", "Schulz",
    "Silva", "Santos", "Oliveira", "Souza", "Pereira", "Costa", "Carvalho", "Alves", "Ribeiro", "Gomes",
    "Dubois", "Martin", "Lefebvre", "Durand", "Moreau", "Fournier", "Roux", "Mercier", "Dupont", "Lambert",
    "Nielsen", "Jensen", "Hansen", "Petersen", "Andersen", "Kristensen", "Olsen", "Christensen", "Larsen", "Sorensen",
    "Khalil", "Hassan", "Ali", "Mahmoud", "El-Sayed", "Abdullah", "Ibrahim", "Saleh", "Farouk", "Hussein",
    "Ivanovic", "Popovic", "Jovanovic", "Petrovic", "Stojanovic", "Novak", "Djokovic", "Milic", "Kovacevic", "Maric",
]

NATIONALITIES = [
    "PT", "AR", "BR", "FR", "SE", "HR", "DE", "EG", "NL", "BE",
    "NO", "PL", "WAL", "UY", "CA", "DK", "SN", "EN", "ES", "IT",
    "TR", "MA", "TN", "DZ", "GH", "CM", "NG", "KE", "SN", "MG",
    "AT", "CH", "HU", "CZ", "SK", "PL", "UA", "RS", "HR", "SI",
    "US", "MX", "CO", "PE", "CL", "VE", "EC", "UY", "PY", "BO",
]

POSITIONS = ["GK", "DF", "MF", "FW"]


def _generate_team_id(idx: int) -> str:
    return f"team_{idx + 1:03d}"


def _generate_player_id(idx: int) -> str:
    return f"player_{idx + 1:04d}"


def download_sample() -> Dict[str, Any]:
    random.seed(42)

    teams: List[Dict[str, Any]] = []
    team_name_to_id: Dict[str, str] = {}
    for i, td in enumerate(TEAMS_DEFINITION):
        tid = _generate_team_id(i)
        teams.append({
            "id": tid,
            "name": td["name"],
            "country": td["country"],
        })
        team_name_to_id[td["name"]] = tid

    players: List[Dict[str, Any]] = []
    history: List[Dict[str, Any]] = []
    pid_counter = 0

    for fp in FAMOUS_PLAYERS:
        pid = _generate_player_id(pid_counter)
        pid_counter += 1
        players.append({
            "id": pid,
            "name": fp["name"],
            "nationality": fp["nationality"],
            "position": fp["position"],
            "aliases": [],
        })
        for team_name, season_start, season_end in fp["career"]:
            if team_name in team_name_to_id:
                history.append({
                    "id": f"hist_{len(history) + 1:05d}",
                    "player_id": pid,
                    "team_id": team_name_to_id[team_name],
                    "seasonStart": season_start,
                    "seasonEnd": season_end,
                })

    used_names = {fp["name"] for fp in FAMOUS_PLAYERS}

    while pid_counter < 500:
        first = random.choice(FIRST_NAMES)
        last = random.choice(LAST_NAMES)
        full_name = f"{first} {last}"
        if full_name in used_names:
            suffix = random.randint(2, 999)
            full_name = f"{first} {last} {suffix}"
        used_names.add(full_name)

        pid = _generate_player_id(pid_counter)
        pid_counter += 1
        nationality = random.choice(NATIONALITIES)
        position = random.choice(POSITIONS)
        players.append({
            "id": pid,
            "name": full_name,
            "nationality": nationality,
            "position": position,
            "aliases": [],
        })

        num_careers = random.randint(2, 5)
        chosen_team_indices = random.sample(range(len(TEAMS_DEFINITION)), min(num_careers, len(TEAMS_DEFINITION)))
        chosen_teams = [TEAMS_DEFINITION[i]["name"] for i in chosen_team_indices]
        chosen_teams = list(dict.fromkeys(chosen_teams))

        prev_end = random.randint(2000, 2015)
        for tname in chosen_teams:
            start = prev_end
            end = min(start + random.randint(1, 6), 2025)
            history.append({
                "id": f"hist_{len(history) + 1:05d}",
                "player_id": pid,
                "team_id": team_name_to_id[tname],
                "seasonStart": start,
                "seasonEnd": end,
            })
            prev_end = end + random.randint(0, 2)
            if prev_end > 2023:
                break

    return {
        "teams": teams,
        "players": players,
        "player_team_history": history,
    }
