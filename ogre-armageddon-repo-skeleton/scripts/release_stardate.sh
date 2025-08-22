#!/usr/bin/env bash
set -euo pipefail
STARDATE="${1:-2025.234}"
NOTE="${2:-Ogre Armageddon Release}"

mkdir -p release
ZIP="release/Ogre_Core_Docs_Pack_Stardate_${STARDATE}.zip"
zip -r "$ZIP" docs/ README.md LICENSE

echo "Zip created: $ZIP"
echo "To release via GitHub Actions:"
echo "  1) Push commit, then"
echo "  2) In GitHub -> Actions -> 'Build & Release Stardate Pack' -> Run workflow"
echo "     with inputs: stardate=$STARDATE note="$NOTE""
