#!/usr/bin/env bash
set -euo pipefail

API_URL="https://api.github.com/repos/NousResearch/hermes-agent/releases/latest"

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  gh api repos/NousResearch/hermes-agent/releases/latest --jq .tag_name
else
  curl --fail --silent --show-error --location \
    -H 'Accept: application/vnd.github+json' \
    "$API_URL" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])'
fi

