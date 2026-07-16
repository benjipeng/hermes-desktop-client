#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work_root=$(mktemp -d)
trap 'rm -rf "$work_root"' EXIT

"$repo_root/scripts/prepare-source.sh" main "$work_root/main"

latest_release=$(gh api repos/NousResearch/hermes-agent/releases/latest --jq .tag_name)
"$repo_root/scripts/prepare-source.sh" "$latest_release" "$work_root/stable"

echo "Both current-main and latest-stable patch paths apply cleanly."
