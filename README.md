# Offline Dictionary

A cross-platform Flutter mobile application for offline English-Hindi and Hindi-English dictionary using Wiktionary data.

## Features

- **Offline-first**: Works completely without internet
- **Bilingual**: English to Hindi and Hindi to English translations
- **Full-text search**: Fast search with FTS5 support
- **Favorites**: Save words for quick access
- **Search History**: Track recently looked up words
- **Dark Mode**: Light and dark theme support
- **Extensible**: Architecture supports adding more languages

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Python 3.8+ (for data processing)
- Android SDK / Xcode (for mobile builds)

### Setup

1. **Clone the repository**
   ```bash
   cd dictionary_app
   ```

2. **Process Dictionary Data**

   First, generate the dictionary database:
   ```bash
   cd tools/data_processor
   pip install -r requirements.txt

   # Download Wiktionary data
   python download_data.py

   # Process data
   python process_wiktionary.py

   # Build database
   python build_database.py

   # Copy to assets
   cp output/dictionary.db ../../assets/database/
   ```

3. **Install Flutter Dependencies**
   ```bash
   cd ../..
   flutter pub get
   ```

4. **Generate Code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app/                   # App configuration
│   ├── app.dart          # MaterialApp setup
│   ├── router.dart       # Navigation routes
│   └── theme/            # Theming
├── core/                  # Shared utilities
│   ├── constants/
│   └── utils/
├── data/                  # Data layer
│   ├── database/         # Drift database
│   │   ├── tables/       # Table definitions
│   │   └── daos/         # Data Access Objects
│   └── repositories/     # Repository implementations
├── domain/                # Business logic
│   ├── entities/         # Core data models
│   └── repositories/     # Repository interfaces
└── presentation/          # UI layer
    ├── providers/        # Riverpod providers
    ├── screens/          # App screens
    └── widgets/          # Reusable widgets
```

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **Drift** - SQLite database with type safety
- **go_router** - Declarative navigation
- **Freezed** - Immutable data classes

## Data Source

Dictionary data is sourced from [kaikki.org](https://kaikki.org/dictionary/), which provides pre-extracted Wiktionary data. The data is licensed under [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).

## Adding More Languages

The architecture is designed to support multiple languages. To add a new language:

1. Update `download_data.py` to fetch the new language data
2. Update `process_wiktionary.py` to handle the new language
3. Rebuild the database
4. Add the language to `Language` entity
5. Update UI to show the new language option

## License

This project is open source. Dictionary data is from Wiktionary (CC BY-SA 3.0).
