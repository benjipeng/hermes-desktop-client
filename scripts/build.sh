#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/swift-env.sh"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
BUILD_ROOT="${BUILD_ROOT:-$ROOT/build}"
APP_NAME="Hermes Dashboard"
APP_BUNDLE="$BUILD_ROOT/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
EXECUTABLE_NAME="HermesDashboard"
DEFAULT_DASHBOARD_URL="${DEFAULT_DASHBOARD_URL:-http://127.0.0.1:9119}"
BUNDLE_IDENTIFIER="${BUNDLE_IDENTIFIER:-com.benjipeng.hermes-dashboard}"
UPSTREAM_RELEASE="${UPSTREAM_RELEASE:-unbound}"

rm -rf "$APP_BUNDLE"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"

swift build --package-path "$ROOT" --disable-sandbox "${SWIFT_PATH_FLAGS[@]}" -c release >&2
BIN_DIR="$(swift build --package-path "$ROOT" --disable-sandbox "${SWIFT_PATH_FLAGS[@]}" -c release --show-bin-path)"
cp "$BIN_DIR/$EXECUTABLE_NAME" "$CONTENTS/MacOS/$EXECUTABLE_NAME"

ICON_WORK="$BUILD_ROOT/icon-work"
ICON_GENERATOR="$ICON_WORK/generate-icon"
mkdir -p "$ICON_WORK"
swiftc \
  -module-cache-path "$SWIFTPM_MODULECACHE_OVERRIDE" \
  -framework AppKit \
  "$ROOT/Tools/GenerateIcon.swift" \
  -o "$ICON_GENERATOR"
"$ICON_GENERATOR" "$CONTENTS/Resources/AppIcon.png"

cat > "$CONTENTS/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundleExecutable</key>
  <string>$EXECUTABLE_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_IDENTIFIER</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon.png</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$VERSION</string>
  <key>HermesDashboardDefaultURL</key>
  <string>$DEFAULT_DASHBOARD_URL</string>
  <key>HermesUpstreamRelease</key>
  <string>$UPSTREAM_RELEASE</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
  </dict>
  <key>NSCameraUsageDescription</key>
  <string>Hermes Dashboard may use the camera when a dashboard feature requests it.</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSHumanReadableCopyright</key>
  <string>Copyright © 2026 Benji Peng</string>
  <key>NSLocalNetworkUsageDescription</key>
  <string>Hermes Dashboard connects to a Hermes dashboard running on your Mac or local network.</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>Hermes Dashboard may use the microphone for voice features provided by the connected dashboard.</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

plutil -lint "$CONTENTS/Info.plist" >/dev/null
codesign --force --deep --sign - "$APP_BUNDLE"

echo "$APP_BUNDLE"
