#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <prepared-source> <Hermes.app>" >&2
  exit 64
fi

source_dir=$1
app_bundle=$2

[[ -d "$app_bundle" ]] || { echo "missing app bundle: $app_bundle" >&2; exit 1; }

plist="$app_bundle/Contents/Info.plist"
bundle_name=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$plist")
bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist")

[[ "$bundle_name" == "Hermes" ]] || { echo "unexpected app name: $bundle_name" >&2; exit 1; }
[[ "$bundle_id" == "com.nousresearch.hermes" ]] || { echo "unexpected bundle id: $bundle_id" >&2; exit 1; }

if find "$app_bundle/Contents" \
  \( -type d \( -name venv -o -name .venv -o -name site-packages -o -name hermes-agent \) \
     -o -type f \( -name '*.py' -o -name 'python' -o -name 'python3' \) \) \
  -print -quit | grep -q .; then
  echo "packaged app contains a Python backend/runtime path" >&2
  exit 1
fi

asar="$app_bundle/Contents/Resources/app.asar"
[[ -f "$asar" ]] || { echo "missing app.asar" >&2; exit 1; }

asar_listing=$(mktemp)
extract_dir=$(mktemp -d)
trap 'rm -f "$asar_listing"; rm -rf "$extract_dir"' EXIT

(cd "$source_dir" && npx --no-install asar list "$asar") >"$asar_listing"

if grep -Eiq '(^|/)(venv|\.venv|site-packages|hermes-agent)(/|$)|\.py$' "$asar_listing"; then
  echo "app.asar contains Python backend/runtime content" >&2
  exit 1
fi

(cd "$source_dir" && npx --no-install asar extract "$asar" "$extract_dir")

main_bundle=$(find "$extract_dir" -type f \( -name 'electron-main.mjs' -o -name 'main.cjs' \) -print -quit)
[[ -n "$main_bundle" ]] || { echo "could not locate packaged Electron main process" >&2; exit 1; }

grep -Fq "remote-only desktop mode enabled" "$main_bundle"
grep -Fq "http://127.0.0.1:9119" "$main_bundle"
grep -Fq "cannot start a bundled local gateway" "$main_bundle"

codesign --verify --deep --strict "$app_bundle"

echo "Verified Hermes.app: real Electron UI, remote-only guard present, and no Python backend bundled."
