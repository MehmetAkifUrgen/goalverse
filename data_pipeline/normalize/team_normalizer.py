import re
from unidecode import unidecode


def normalize_team_name(name: str) -> str:
    if name is None:
        return ""
    s = str(name)
    s = s.replace("I", "i").replace("İ", "i")
    s = s.lower()
    s = unidecode(s)
    s = s.replace("ñ", "n")
    s = s.strip()
    s = re.sub(r"\s+", " ", s)
    s = re.sub(r"\b(fc|cf|sc|sk|ac|as|ss|uss|bv|bvb|psg|afc|bcfc)\b\s*$", "", s)
    s = re.sub(r"\s+", " ", s)
    return s.strip()
