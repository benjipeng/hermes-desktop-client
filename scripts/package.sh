#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
ARCH="$(uname -m)"
ARTIFACT_DIR="${ARTIFACT_DIR:-$ROOT/artifacts}"
UPSTREAM_RELEASE="${UPSTREAM_RELEASE:-unbound}"

APP_BUNDLE="$("$ROOT/scripts/build.sh")"
mkdir -p "$ARTIFACT_DIR"

UPSTREAM_SUFFIX=""
if [[ "$UPSTREAM_RELEASE" != "unbound" ]]; then
  SAFE_UPSTREAM="$(printf '%s' "$UPSTREAM_RELEASE" | tr -cs 'A-Za-z0-9._-' '-')"
  UPSTREAM_SUFFIX="-for-$SAFE_UPSTREAM"
fi

ARCHIVE="$ARTIFACT_DIR/Hermes-Dashboard-$VERSION$UPSTREAM_SUFFIX-macOS-$ARCH.zip"
CHECKSUM="$ARCHIVE.sha256"

rm -f "$ARCHIVE" "$CHECKSUM"
ditto -c -k --sequesterRsrc --keepParent "$APP_BUNDLE" "$ARCHIVE"
shasum -a 256 "$ARCHIVE" > "$CHECKSUM"

cat > "$ARTIFACT_DIR/build-metadata.json" <<JSON
{
  "application": "Hermes Dashboard",
  "version": "$VERSION",
  "architecture": "$ARCH",
  "defaultDashboardUrl": "${DEFAULT_DASHBOARD_URL:-http://127.0.0.1:9119}",
  "upstreamRelease": "$UPSTREAM_RELEASE",
  "builtAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON

printf '%s\n' "$ARCHIVE"
