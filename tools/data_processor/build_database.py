#!/usr/bin/env python3
"""
Build SQLite database from processed Wiktionary data.

This script:
1. Reads the processed JSON files
2. Creates an optimized SQLite database with FTS5 support
3. Populates all tables with dictionary data
4. Creates indexes for fast searching
"""

import json
import sqlite3
from pathlib import Path
from typing import List, Dict, Any
from tqdm import tqdm

OUTPUT_DIR = Path(__file__).parent / 'output'
DATABASE_PATH = OUTPUT_DIR / 'dictionary.db'


def create_database(db_path: Path) -> sqlite3.Connection:
    """Create the SQLite database with all tables."""

    # Remove existing database
    if db_path.exists():
        db_path.unlink()

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Enable foreign keys
    cursor.execute("PRAGMA foreign_keys = ON;")

    # Create words table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            language_code TEXT NOT NULL,
            pos TEXT,
            pronunciation_ipa TEXT,
            etymology TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(word, language_code, pos)
        )
    """)

    # Create definitions table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS definitions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word_id INTEGER NOT NULL,
            definition TEXT NOT NULL,
            order_index INTEGER DEFAULT 0,
            FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
        )
    """)

    # Create translations table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS translations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_word_id INTEGER NOT NULL,
            target_language_code TEXT NOT NULL,
            translation TEXT NOT NULL,
            FOREIGN KEY (source_word_id) REFERENCES words(id) ON DELETE CASCADE
        )
    """)

    # Create examples table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS examples (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word_id INTEGER NOT NULL,
            example_text TEXT NOT NULL,
            FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
        )
    """)

    # Create favorites table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word_id INTEGER NOT NULL UNIQUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
        )
    """)

    # Create search history table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS search_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word_id INTEGER NOT NULL,
            searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE
        )
    """)

    # Create metadata table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS metadata (
            key TEXT PRIMARY KEY,
            value TEXT
        )
    """)

    # Create FTS5 virtual table for full-text search
    cursor.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS words_fts USING fts5(
            word,
            content='words',
            content_rowid='id',
            tokenize='unicode61'
        )
    """)

    # Create triggers to keep FTS in sync
    cursor.execute("""
        CREATE TRIGGER IF NOT EXISTS words_ai AFTER INSERT ON words BEGIN
            INSERT INTO words_fts(rowid, word) VALUES (new.id, new.word);
        END
    """)

    cursor.execute("""
        CREATE TRIGGER IF NOT EXISTS words_ad AFTER DELETE ON words BEGIN
            INSERT INTO words_fts(words_fts, rowid, word)
            VALUES ('delete', old.id, old.word);
        END
    """)

    cursor.execute("""
        CREATE TRIGGER IF NOT EXISTS words_au AFTER UPDATE ON words BEGIN
            INSERT INTO words_fts(words_fts, rowid, word)
            VALUES ('delete', old.id, old.word);
            INSERT INTO words_fts(rowid, word) VALUES (new.id, new.word);
        END
    """)

    # Create indexes
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_words_language ON words(language_code)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_words_word ON words(word)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_words_word_lang ON words(word, language_code)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_definitions_word ON definitions(word_id)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_translations_word ON translations(source_word_id)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_translations_target ON translations(target_language_code)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_examples_word ON examples(word_id)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_favorites_word ON favorites(word_id)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_history_word ON search_history(word_id)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_history_date ON search_history(searched_at)")

    conn.commit()
    return conn


def load_processed_data(file_path: Path) -> List[Dict[str, Any]]:
    """Load processed data from JSON file."""
    if not file_path.exists():
        return []

    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def populate_database(conn: sqlite3.Connection, words: List[Dict[str, Any]]):
    """Populate the database with word entries."""
    cursor = conn.cursor()

    for word_data in tqdm(words, desc="Inserting words"):
        try:
            # Insert word
            cursor.execute("""
                INSERT OR IGNORE INTO words (word, language_code, pos, pronunciation_ipa, etymology)
                VALUES (?, ?, ?, ?, ?)
            """, (
                word_data['word'],
                word_data['language'],
                word_data['pos'],
                word_data.get('pronunciation_ipa'),
                word_data.get('etymology'),
            ))

            # Get word ID (either newly inserted or existing)
            if cursor.lastrowid == 0:
                cursor.execute(
                    "SELECT id FROM words WHERE word = ? AND language_code = ? AND pos = ?",
                    (word_data['word'], word_data['language'], word_data['pos'])
                )
                result = cursor.fetchone()
                if result:
                    word_id = result[0]
                else:
                    continue
            else:
                word_id = cursor.lastrowid

            # Insert definitions
            for idx, definition in enumerate(word_data.get('definitions', [])):
                cursor.execute("""
                    INSERT INTO definitions (word_id, definition, order_index)
                    VALUES (?, ?, ?)
                """, (word_id, definition, idx))

            # Insert translations
            for lang_code, translations in word_data.get('translations', {}).items():
                for translation in translations:
                    cursor.execute("""
                        INSERT INTO translations (source_word_id, target_language_code, translation)
                        VALUES (?, ?, ?)
                    """, (word_id, lang_code, translation))

            # Insert examples
            for example in word_data.get('examples', []):
                cursor.execute("""
                    INSERT INTO examples (word_id, example_text)
                    VALUES (?, ?)
                """, (word_id, example))

        except sqlite3.Error as e:
            print(f"Error inserting word '{word_data.get('word', 'unknown')}': {e}")
            continue

    conn.commit()


def add_metadata(conn: sqlite3.Connection, word_count: int):
    """Add metadata to the database."""
    cursor = conn.cursor()

    from datetime import datetime

    metadata = {
        'version': '1.0.0',
        'created_at': datetime.now().isoformat(),
        'source': 'kaikki.org (Wiktionary)',
        'word_count': str(word_count),
        'languages': 'en,hi',
    }

    for key, value in metadata.items():
        cursor.execute("""
            INSERT OR REPLACE INTO metadata (key, value)
            VALUES (?, ?)
        """, (key, value))

    conn.commit()


def optimize_database(conn: sqlite3.Connection):
    """Optimize the database for size and performance."""
    cursor = conn.cursor()

    print("Optimizing database...")
    cursor.execute("VACUUM")
    cursor.execute("ANALYZE")

    conn.commit()


def get_stats(conn: sqlite3.Connection) -> Dict[str, int]:
    """Get database statistics."""
    cursor = conn.cursor()

    stats = {}

    cursor.execute("SELECT COUNT(*) FROM words WHERE language_code = 'en'")
    stats['english_words'] = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM words WHERE language_code = 'hi'")
    stats['hindi_words'] = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM words")
    stats['total_words'] = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM definitions")
    stats['definitions'] = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM translations")
    stats['translations'] = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM examples")
    stats['examples'] = cursor.fetchone()[0]

    return stats


def main():
    print("=" * 60)
    print("Dictionary Database Builder")
    print("=" * 60)
    print()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Load processed data
    print("[1/4] Loading processed data...")

    all_words_file = OUTPUT_DIR / 'all_words.json'
    if not all_words_file.exists():
        print(f"[ERROR] File not found: {all_words_file}")
        print("Please run process_wiktionary.py first")
        return

    words = load_processed_data(all_words_file)
    print(f"  Loaded {len(words)} words")

    if not words:
        print("[ERROR] No words to process!")
        return

    # Create database
    print("\n[2/4] Creating database schema...")
    conn = create_database(DATABASE_PATH)
    print(f"  Database created at {DATABASE_PATH}")

    # Populate database
    print("\n[3/4] Populating database...")
    populate_database(conn, words)

    # Add metadata
    add_metadata(conn, len(words))

    # Optimize
    print("\n[4/4] Optimizing database...")
    optimize_database(conn)

    # Get stats
    stats = get_stats(conn)

    conn.close()

    # Print summary
    db_size = DATABASE_PATH.stat().st_size / (1024 * 1024)

    print()
    print("=" * 60)
    print("Database build complete!")
    print()
    print("Statistics:")
    print(f"  - English words: {stats['english_words']:,}")
    print(f"  - Hindi words: {stats['hindi_words']:,}")
    print(f"  - Total words: {stats['total_words']:,}")
    print(f"  - Definitions: {stats['definitions']:,}")
    print(f"  - Translations: {stats['translations']:,}")
    print(f"  - Examples: {stats['examples']:,}")
    print(f"  - Database size: {db_size:.1f} MB")
    print()
    print(f"Database saved to: {DATABASE_PATH}")
    print()
    print("Next step: Copy the database to your Flutter project:")
    print(f"  cp {DATABASE_PATH} ../assets/database/")
    print("=" * 60)


if __name__ == '__main__':
    main()
