#!/usr/bin/env bash
set -euo pipefail

source_dir=${1:?usage: verify-source.sh <prepared-source>}

git -C "$source_dir" diff --check

while IFS= read -r entry; do
  [[ -z "$entry" ]] && continue
  path=${entry:3}
  path=${path#* -> }
  if [[ "$path" != apps/desktop/* ]]; then
    echo "client delta unexpectedly changes non-desktop path: $path" >&2
    exit 1
  fi
done < <(git -C "$source_dir" status --short)

if ! git -C "$source_dir" diff --quiet -- apps/desktop/package.json package.json package-lock.json; then
  echo "client delta must not modify upstream package manifests or lockfiles" >&2
  exit 1
fi

if [[ -f "$source_dir/apps/desktop/electron/desktop-mode.ts" ]]; then
  mode_file="$source_dir/apps/desktop/electron/desktop-mode.ts"
else
  mode_file="$source_dir/apps/desktop/electron/desktop-mode.cjs"
fi

grep -Fq "http://127.0.0.1:9119" "$mode_file"
grep -Eq "remoteOnly:[[:space:]]*true" "$mode_file"
grep -Fq "defaultAuthMode" "$mode_file"

echo "Verified that the delta is desktop-only, manifest-neutral, and remote-only."
