#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <upstream-ref> <destination>" >&2
  exit 64
fi

upstream_ref=$1
destination=$2
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
upstream_url=${HERMES_UPSTREAM_URL:-https://github.com/NousResearch/hermes-agent.git}

if [[ -z "$destination" || "$destination" == "/" ]]; then
  echo "refusing unsafe destination: '$destination'" >&2
  exit 64
fi

rm -rf "$destination"
git init -q "$destination"
git -C "$destination" remote add origin "$upstream_url"
git -C "$destination" fetch --depth=1 --no-tags origin "$upstream_ref"
git -C "$destination" checkout -q --detach FETCH_HEAD

if [[ -f "$destination/apps/desktop/electron/main.ts" ]]; then
  patch_kind=typescript
  patch_file="$repo_root/patches/desktop-client-ts.patch"
elif [[ -f "$destination/apps/desktop/electron/main.cjs" ]]; then
  patch_kind=commonjs
  patch_file="$repo_root/patches/desktop-client-cjs.patch"
else
  echo "unsupported upstream desktop layout at $upstream_ref" >&2
  exit 1
fi

git -C "$destination" apply --check "$patch_file"
git -C "$destination" apply "$patch_file"

"$repo_root/scripts/verify-source.sh" "$destination"

upstream_commit=$(git -C "$destination" rev-parse HEAD)
desktop_version=$(node -p "require(process.argv[1]).version" "$destination/apps/desktop/package.json")
patch_sha256=$(shasum -a 256 "$patch_file" | awk '{print $1}')

cat >"$destination/.hermes-desktop-client-source.json" <<EOF
{
  "upstream_repository": "NousResearch/hermes-agent",
  "upstream_ref": "${upstream_ref}",
  "upstream_commit": "${upstream_commit}",
  "desktop_version": "${desktop_version}",
  "patch_kind": "${patch_kind}",
  "patch_sha256": "${patch_sha256}"
}
EOF

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "upstream_ref=$upstream_ref"
    echo "upstream_commit=$upstream_commit"
    echo "desktop_version=$desktop_version"
    echo "patch_kind=$patch_kind"
    echo "patch_sha256=$patch_sha256"
  } >>"$GITHUB_OUTPUT"
fi

echo "Prepared Hermes $upstream_ref ($upstream_commit) with the $patch_kind desktop-client delta."
