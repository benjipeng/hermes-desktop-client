#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/swift-env.sh"

bash -n "$ROOT/scripts/build.sh" "$ROOT/scripts/package.sh" "$ROOT/scripts/test.sh" "$ROOT/scripts/swift-env.sh"
swift test --package-path "$ROOT" --disable-sandbox "${SWIFT_PATH_FLAGS[@]}"
