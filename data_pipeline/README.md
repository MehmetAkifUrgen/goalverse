# Football Tic Tac Toe - Data Pipeline

Futbolcu ve takım verilerinden Football Tic Tac Toe oyunu için answer index üreten Python pipeline.

## Klasör Yapısı

```
data_pipeline/
├── main.py                 # CLI entrypoint (click)
├── requirements.txt
├── README.md
├── sources/
│   ├── sample_download.py  # 500 oyuncu + 20 takım fixture
│   └── __init__.py
├── normalize/
│   ├── name_normalizer.py  # Oyuncu isim normalizasyonu
│   ├── team_normalizer.py  # Takım isim normalizasyonu
│   └── __init__.py
├── dedup.py                # rapidfuzz ile oyuncu eşleştirme
├── validate.py             # Pydantic ile data validasyon
├── indexer.py              # team_player_index & answer_index
├── export_json.py          # JSON export
├── export_sqlite.py        # SQLite export (4 tablo)
├── tests/                  # pytest testleri
└── output/                 # Pipeline çıktıları
```

## Kurulum

```bash
cd data_pipeline
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Çalıştırma

```bash
python main.py --fixture --out-dir output/
```

## Testler

```bash
python -m pytest tests/ -v
```

## Doğrulama

```bash
# JSON dosyaları
ls output/players.json output/teams.json output/player_team_history.json output/answer_index.json

# Oyuncu sayısı
python -c "import json; d=json.load(open('output/players.json')); print(f'players={len(d)}');"

# SQLite tabloları
sqlite3 output/players.db ".tables"
```

## Çıktılar

- `players.json`: Oyuncu listesi (name, nationality, position, normalizedName, aliases)
- `teams.json`: Takım listesi (name, country, normalizedName)
- `player_team_history.json`: Oyuncu-takım kariyer kayıtları (seasonStart / seasonEnd yıl)
- `team_player_index.json`: {"team_id": ["player_id_1", ...]}
- `answer_index.json`: {"team_A|team_B": ["player_id_1", ...]} (ortak oyuncular)
- `players.db`: 4 tablo SQLite DB
