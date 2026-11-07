import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from normalize.name_normalizer import normalize_name
from normalize.team_normalizer import normalize_team_name


def test_cristiano_ronaldo_accent_normalization():
    assert normalize_name("CristiÁño Roñaldó") == "cristiano ronaldo"


def test_turkish_chars_normalization():
    assert normalize_name("ŞİRİN İSTANBULLU") == "sirin istanbullu"
    assert normalize_name("çıplak öğretmen") == "ciplak ogretmen"
    assert normalize_name("GĞLÜM ÇÖP") == "gglum cop"


def test_strip_and_whitespace():
    assert normalize_name("  Lionel   Messi  ") == "lionel messi"


def test_none_and_empty():
    assert normalize_name(None) == ""
    assert normalize_name("") == ""


def test_galatasaray_sk_suffix():
    assert normalize_team_name("Galatasaray SK") == "galatasaray"


def test_fc_suffixes():
    assert normalize_team_name("Arsenal FC") == "arsenal"
    assert normalize_team_name("Liverpool FC ") == "liverpool"
    assert normalize_team_name("Milan AC") == "milan"


def test_bvb_suffix():
    assert normalize_team_name("BVB Dortmund") == "bvb dortmund"


def test_team_with_turkish_chars():
    assert normalize_team_name("Galatasaray İ.S.K.") == "galatasaray i.s.k."
