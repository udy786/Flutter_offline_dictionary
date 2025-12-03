#!/usr/bin/env python3
"""
Process Wiktionary JSONL data to extract English-Hindi dictionary entries.

This script:
1. Reads the downloaded JSONL files from kaikki.org
2. Extracts English words with Hindi translations
3. Extracts Hindi words with English definitions
4. Outputs processed JSON files ready for database building
"""

import json
import os
from pathlib import Path
from typing import Optional, List, Dict, Any
from dataclasses import dataclass, asdict
from tqdm import tqdm

DATA_DIR = Path(__file__).parent / 'data'
OUTPUT_DIR = Path(__file__).parent / 'output'


@dataclass
class ProcessedWord:
    """Represents a processed dictionary entry."""
    word: str
    language: str  # 'en' or 'hi'
    pos: str  # Part of speech
    definitions: List[str]
    translations: Dict[str, List[str]]  # {'hi': [...], 'en': [...]}
    pronunciation_ipa: Optional[str]
    examples: List[str]
    etymology: Optional[str]


def extract_definitions(senses: List[Dict]) -> List[str]:
    """Extract definitions from senses."""
    definitions = []
    for sense in senses:
        glosses = sense.get('glosses', [])
        if glosses:
            # Take the first gloss as the main definition
            definitions.append(glosses[0])
    return definitions


def extract_translations(entry: Dict, target_lang: str) -> List[str]:
    """Extract translations for a specific target language."""
    translations = []
    for trans in entry.get('translations', []):
        if trans.get('lang') == target_lang or trans.get('code') == target_lang:
            word = trans.get('word', '').strip()
            if word:
                translations.append(word)
    return list(set(translations))  # Remove duplicates


def extract_pronunciation(entry: Dict) -> Optional[str]:
    """Extract IPA pronunciation."""
    for sound in entry.get('sounds', []):
        ipa = sound.get('ipa')
        if ipa:
            return ipa
    return None


def extract_examples(senses: List[Dict], max_examples: int = 3) -> List[str]:
    """Extract usage examples from senses."""
    examples = []
    for sense in senses:
        for example in sense.get('examples', []):
            text = example.get('text', '').strip()
            if text and len(examples) < max_examples:
                examples.append(text)
    return examples


def process_english_entry(entry: Dict) -> Optional[ProcessedWord]:
    """Process an English Wiktionary entry."""
    word = entry.get('word', '').strip()
    if not word:
        return None

    lang = entry.get('lang', '')
    lang_code = entry.get('lang_code', '')

    # We want English words
    if lang_code != 'en':
        return None

    pos = entry.get('pos', 'unknown')
    senses = entry.get('senses', [])

    definitions = extract_definitions(senses)
    if not definitions:
        return None

    # Get Hindi translations (optional - not all words have them)
    hindi_translations = extract_translations(entry, 'Hindi')

    # Include word even if no Hindi translations (hybrid approach)
    translations = {}
    if hindi_translations:
        translations['hi'] = hindi_translations

    return ProcessedWord(
        word=word,
        language='en',
        pos=pos,
        definitions=definitions,
        translations=translations,
        pronunciation_ipa=extract_pronunciation(entry),
        examples=extract_examples(senses),
        etymology=entry.get('etymology_text'),
    )


def process_hindi_entry(entry: Dict) -> Optional[ProcessedWord]:
    """Process a Hindi Wiktionary entry."""
    word = entry.get('word', '').strip()
    if not word:
        return None

    lang = entry.get('lang', '')
    lang_code = entry.get('lang_code', '')

    # We want Hindi words
    if lang_code != 'hi':
        return None

    pos = entry.get('pos', 'unknown')
    senses = entry.get('senses', [])

    definitions = extract_definitions(senses)
    if not definitions:
        return None

    # Get English translations
    english_translations = extract_translations(entry, 'English')

    return ProcessedWord(
        word=word,
        language='hi',
        pos=pos,
        definitions=definitions,
        translations={'en': english_translations},
        pronunciation_ipa=extract_pronunciation(entry),
        examples=extract_examples(senses),
        etymology=entry.get('etymology_text'),
    )


def process_file(input_path: Path, processor_func, description: str) -> List[ProcessedWord]:
    """Process a JSONL file and return processed words."""
    results = []

    if not input_path.exists():
        print(f"[SKIP] File not found: {input_path}")
        return results

    # Count lines for progress bar
    with open(input_path, 'r', encoding='utf-8') as f:
        total_lines = sum(1 for _ in f)

    with open(input_path, 'r', encoding='utf-8') as f:
        for line in tqdm(f, total=total_lines, desc=description):
            try:
                entry = json.loads(line)
                processed = processor_func(entry)
                if processed:
                    results.append(processed)
            except json.JSONDecodeError:
                continue
            except Exception as e:
                continue

    return results


def deduplicate_words(words: List[ProcessedWord]) -> List[ProcessedWord]:
    """Remove duplicate entries, keeping the one with most information."""
    seen = {}

    for word in words:
        key = (word.word.lower(), word.language, word.pos)
        if key not in seen:
            seen[key] = word
        else:
            # Keep the entry with more definitions/translations
            existing = seen[key]
            existing_score = len(existing.definitions) + sum(len(v) for v in existing.translations.values())
            new_score = len(word.definitions) + sum(len(v) for v in word.translations.values())
            if new_score > existing_score:
                seen[key] = word

    return list(seen.values())


def save_results(words: List[ProcessedWord], output_path: Path):
    """Save processed words to JSON file."""
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(
            [asdict(w) for w in words],
            f,
            ensure_ascii=False,
            indent=2
        )


def main():
    print("=" * 60)
    print("Wiktionary Data Processor")
    print("=" * 60)
    print()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    all_words = []

    # Process English Wiktionary (English words with Hindi translations)
    english_file = DATA_DIR / 'english_wiktionary.jsonl'
    if english_file.exists():
        print("\n[1/2] Processing English Wiktionary...")
        english_words = process_file(
            english_file,
            process_english_entry,
            "English entries"
        )
        print(f"  Found {len(english_words)} English words with Hindi translations")
        all_words.extend(english_words)

    # Process Hindi Wiktionary (Hindi words with definitions)
    hindi_file = DATA_DIR / 'hindi_wiktionary.jsonl'
    if hindi_file.exists():
        print("\n[2/2] Processing Hindi Wiktionary...")
        hindi_words = process_file(
            hindi_file,
            process_hindi_entry,
            "Hindi entries"
        )
        print(f"  Found {len(hindi_words)} Hindi words")
        all_words.extend(hindi_words)

    if not all_words:
        print("\n[ERROR] No words found! Make sure to run download_data.py first.")
        return

    # Deduplicate
    print("\n[DEDUP] Removing duplicates...")
    all_words = deduplicate_words(all_words)
    print(f"  {len(all_words)} unique entries after deduplication")

    # Separate by language
    english_words = [w for w in all_words if w.language == 'en']
    hindi_words = [w for w in all_words if w.language == 'hi']

    # Save results
    print("\n[SAVE] Saving processed data...")

    english_output = OUTPUT_DIR / 'english_processed.json'
    save_results(english_words, english_output)
    print(f"  English: {len(english_words)} words -> {english_output}")

    hindi_output = OUTPUT_DIR / 'hindi_processed.json'
    save_results(hindi_words, hindi_output)
    print(f"  Hindi: {len(hindi_words)} words -> {hindi_output}")

    combined_output = OUTPUT_DIR / 'all_words.json'
    save_results(all_words, combined_output)
    print(f"  Combined: {len(all_words)} words -> {combined_output}")

    print()
    print("=" * 60)
    print("Processing complete!")
    print()
    print("Summary:")
    print(f"  - English words: {len(english_words)}")
    print(f"  - Hindi words: {len(hindi_words)}")
    print(f"  - Total: {len(all_words)}")
    print()
    print("Next step: Run 'python build_database.py' to create the SQLite database")
    print("=" * 60)


if __name__ == '__main__':
    main()
