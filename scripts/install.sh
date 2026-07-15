#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_APP="${1:-$ROOT/build/Hermes Dashboard.app}"
TARGET_APP="${TARGET_APP:-/Applications/Hermes Dashboard.app}"

if [[ ! -d "$SOURCE_APP" ]]; then
  echo "Application not found: $SOURCE_APP" >&2
  echo "Run 'make build' first, or pass the path to an extracted app bundle." >&2
  exit 1
fi

rm -rf "$TARGET_APP"
ditto "$SOURCE_APP" "$TARGET_APP"
echo "Installed: $TARGET_APP"

