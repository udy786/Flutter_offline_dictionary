# Dictionary Data Processor

This directory contains Python scripts to download and process Wiktionary data for the offline dictionary app.

## Requirements

- Python 3.8+
- pip packages: see `requirements.txt`

## Setup

```bash
cd tools/data_processor
pip install -r requirements.txt
```

## Usage

Run the scripts in order:

### 1. Download Wiktionary Data

```bash
python download_data.py
```

This downloads pre-extracted Wiktionary data from kaikki.org:
- English Wiktionary (English words with translations)
- Hindi Wiktionary (Hindi words with definitions)

Downloads are saved to `data/` directory.

### 2. Process Data

```bash
python process_wiktionary.py
```

This processes the downloaded JSONL files and extracts:
- English words with Hindi translations
- Hindi words with English definitions

Processed data is saved to `output/` directory as JSON files.

### 3. Build Database

```bash
python build_database.py
```

This creates an optimized SQLite database with:
- Full-text search (FTS5) support
- Proper indexes for fast querying
- All dictionary data

The database is saved to `output/dictionary.db`.

### 4. Copy to Flutter Project

```bash
cp output/dictionary.db ../assets/database/
```

## Data Sources

- [kaikki.org](https://kaikki.org/dictionary/) - Pre-extracted Wiktionary data
- Data is licensed under [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) (same as Wiktionary)

## Output Structure

```
data/
├── english_wiktionary.jsonl  # Raw English Wiktionary data
└── hindi_wiktionary.jsonl    # Raw Hindi Wiktionary data

output/
├── english_processed.json    # Processed English words
├── hindi_processed.json      # Processed Hindi words
├── all_words.json           # Combined processed data
└── dictionary.db            # Final SQLite database
```

## Database Schema

The SQLite database contains:

- `words` - Main word entries
- `definitions` - Word definitions
- `translations` - Word translations
- `examples` - Usage examples
- `favorites` - User favorites (empty)
- `search_history` - Search history (empty)
- `metadata` - Database metadata
- `words_fts` - FTS5 virtual table for search
