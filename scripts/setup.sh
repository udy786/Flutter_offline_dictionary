#!/bin/bash

# Setup script for Offline Dictionary App

set -e

echo "============================================"
echo "Offline Dictionary - Setup Script"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}Warning: Flutter not found in PATH${NC}"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}[1/5]${NC} Checking Flutter installation..."
flutter doctor -v

echo ""
echo -e "${GREEN}[2/5]${NC} Installing Flutter dependencies..."
flutter pub get

echo ""
echo -e "${GREEN}[3/5]${NC} Generating code (Drift, Freezed, etc.)..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo -e "${GREEN}[4/5]${NC} Checking data processor..."
if [ -f "tools/data_processor/output/dictionary.db" ]; then
    echo "Database found. Copying to assets..."
    cp tools/data_processor/output/dictionary.db assets/database/
else
    echo -e "${YELLOW}Warning: Dictionary database not found.${NC}"
    echo "Run the following to generate the database:"
    echo "  cd tools/data_processor"
    echo "  pip install -r requirements.txt"
    echo "  python download_data.py"
    echo "  python process_wiktionary.py"
    echo "  python build_database.py"
    echo "  cp output/dictionary.db ../../assets/database/"
fi

echo ""
echo -e "${GREEN}[5/5]${NC} Checking fonts..."
if [ ! -f "assets/fonts/NotoSans-Regular.ttf" ]; then
    echo -e "${YELLOW}Warning: Fonts not found.${NC}"
    echo "Download Noto Sans and Noto Sans Devanagari from Google Fonts:"
    echo "  https://fonts.google.com/noto"
    echo "Place the .ttf files in assets/fonts/"
fi

echo ""
echo "============================================"
echo "Setup complete!"
echo ""
echo "To run the app:"
echo "  flutter run"
echo "============================================"
