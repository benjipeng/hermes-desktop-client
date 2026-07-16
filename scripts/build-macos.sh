#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <prepared-source> <output-directory> <artifact-label>" >&2
  exit 64
fi

source_dir=$(cd "$1" && pwd)
output_dir=$2
artifact_label=$(printf '%s' "$3" | tr -cs 'A-Za-z0-9._-' '-')
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

[[ "$(uname -s)" == "Darwin" ]] || { echo "macOS is required" >&2; exit 1; }
[[ "$(uname -m)" == "arm64" ]] || { echo "Apple Silicon runner is required" >&2; exit 1; }

mkdir -p "$output_dir"
output_dir=$(cd "$output_dir" && pwd)

cd "$source_dir"
npm ci --no-audit --no-fund
npm run typecheck --workspace apps/desktop

if [[ -f apps/desktop/electron/desktop-mode.ts ]]; then
  npm run test:desktop:platforms --workspace apps/desktop
else
  node --test apps/desktop/electron/desktop-mode.test.cjs
  npm run test:desktop:platforms --workspace apps/desktop
fi

npm run build --workspace apps/desktop

export CSC_IDENTITY_AUTO_DISCOVERY=false
npm run builder --workspace apps/desktop -- --mac --arm64 --dir

app_bundle=$(find apps/desktop/release -maxdepth 3 -type d -name 'Hermes.app' -print -quit)
[[ -n "$app_bundle" ]] || { echo "electron-builder did not produce Hermes.app" >&2; exit 1; }

# Ad-hoc signing keeps the bundle internally consistent. Official Developer ID
# signing/notarization can be added later through repository secrets without
# changing the source or packaging architecture.
codesign --force --deep --sign - "$app_bundle"
"$repo_root/scripts/verify-app.sh" "$source_dir" "$app_bundle"

zip_path="$output_dir/Hermes-${artifact_label}-mac-arm64.zip"
dmg_path="$output_dir/Hermes-${artifact_label}-mac-arm64.dmg"

ditto -c -k --sequesterRsrc --keepParent "$app_bundle" "$zip_path"

dmg_stage=$(mktemp -d)
trap 'rm -rf "$dmg_stage"' EXIT
ditto "$app_bundle" "$dmg_stage/Hermes.app"
ln -s /Applications "$dmg_stage/Applications"
hdiutil create -quiet -volname 'Install Hermes' -srcfolder "$dmg_stage" -ov -format UDZO "$dmg_path"

cp "$source_dir/.hermes-desktop-client-source.json" "$output_dir/build-metadata.json"
(
  cd "$output_dir"
  shasum -a 256 ./*.dmg ./*.zip build-metadata.json >SHA256SUMS.txt
)

du -sh "$app_bundle" "$zip_path" "$dmg_path"
echo "Packaged artifacts in $output_dir"
