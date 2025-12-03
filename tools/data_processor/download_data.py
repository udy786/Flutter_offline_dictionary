#!/usr/bin/env python3
"""
Download Wiktionary data from kaikki.org

This script downloads pre-extracted Wiktionary data in JSONL format.
The data is already processed by wiktextract, making it easy to filter.
"""

import os
import requests
from pathlib import Path
from tqdm import tqdm

# URLs for Wiktionary extracts from kaikki.org
DATA_URLS = {
    # English Wiktionary - contains Hindi words with English definitions
    'english': 'https://kaikki.org/dictionary/English/kaikki.org-dictionary-English.jsonl',
    # Hindi Wiktionary - contains Hindi definitions
    'hindi': 'https://kaikki.org/dictionary/Hindi/kaikki.org-dictionary-Hindi.jsonl',
}

OUTPUT_DIR = Path(__file__).parent / 'data'


def download_file(url: str, output_path: Path) -> bool:
    """Download a file with progress bar."""
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()

        total_size = int(response.headers.get('content-length', 0))

        output_path.parent.mkdir(parents=True, exist_ok=True)

        with open(output_path, 'wb') as f:
            with tqdm(total=total_size, unit='B', unit_scale=True, desc=output_path.name) as pbar:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
                        pbar.update(len(chunk))

        return True
    except Exception as e:
        print(f"Error downloading {url}: {e}")
        return False


def main():
    print("=" * 60)
    print("Wiktionary Data Downloader")
    print("=" * 60)
    print()
    print("This will download dictionary data from kaikki.org")
    print("(Pre-extracted Wiktionary dumps)")
    print()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for name, url in DATA_URLS.items():
        output_file = OUTPUT_DIR / f'{name}_wiktionary.jsonl'

        if output_file.exists():
            print(f"[SKIP] {name}: File already exists at {output_file}")
            continue

        print(f"[DOWNLOAD] {name}: {url}")
        success = download_file(url, output_file)

        if success:
            size_mb = output_file.stat().st_size / (1024 * 1024)
            print(f"[OK] Downloaded {size_mb:.1f} MB to {output_file}")
        else:
            print(f"[FAIL] Failed to download {name}")

    print()
    print("=" * 60)
    print("Download complete!")
    print()
    print("Next step: Run 'python process_wiktionary.py' to process the data")
    print("=" * 60)


if __name__ == '__main__':
    main()
