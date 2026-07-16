# Hermes Desktop Client

[![Validate client delta](https://github.com/benjipeng/hermes-desktop-client/actions/workflows/ci.yml/badge.svg)](https://github.com/benjipeng/hermes-desktop-client/actions/workflows/ci.yml)
[![Stable builds](https://github.com/benjipeng/hermes-desktop-client/actions/workflows/stable.yml/badge.svg)](https://github.com/benjipeng/hermes-desktop-client/actions/workflows/stable.yml)
[![Nightly builds](https://github.com/benjipeng/hermes-desktop-client/actions/workflows/nightly.yml/badge.svg)](https://github.com/benjipeng/hermes-desktop-client/actions/workflows/nightly.yml)

An unofficial macOS distribution of the **actual Hermes Electron desktop interface** for people who already run a Hermes gateway separately.

This project is deliberately client-only:

- It packages the upstream Hermes React/Electron desktop UI—not the web dashboard in a wrapper.
- It does not bundle the Hermes Python source, a Python interpreter, or a virtual environment.
- It never installs, repairs, or launches a local Hermes backend.
- It connects to `http://127.0.0.1:9119` by default; the gateway URL remains editable.
- It supports gateway sign-in (including username/password gateways) and session-token authentication.

Hermes itself is developed by [Nous Research](https://github.com/NousResearch/hermes-agent).

## Downloads

The [Releases](https://github.com/benjipeng/hermes-desktop-client/releases) page provides Apple Silicon builds:

- **Stable:** built from the exact source tag of each official Hermes release.
- **Nightly:** one rolling prerelease built from upstream `main`, replaced only when that commit changes.

Every release includes a DMG, ZIP, build metadata, and SHA-256 checksums.

## Requirements

- Apple Silicon Mac
- A separately managed Hermes gateway reachable from the Mac
- macOS permission to open an unofficial, ad-hoc-signed application

The default gateway expected by the client is:

```text
http://127.0.0.1:9119
```

You can confirm that the gateway is reachable with:

```bash
curl http://127.0.0.1:9119/api/status
```

## Install and connect

1. Download the stable DMG or ZIP from Releases.
2. Replace or drag `Hermes.app` into `/Applications`.
3. Open Hermes. For the first launch of an ad-hoc-signed build, Control-click the app and choose **Open** if macOS requests confirmation.
4. Open **Settings → Gateway**.
5. Keep `http://127.0.0.1:9119` or enter another gateway URL.
6. Sign in through the gateway window, or select token authentication and save its session token.

## Persistent state

Replacing `Hermes.app` does not delete client state. Electron stores connection settings, cookies, local storage, window state, and other UI preferences outside the application bundle, primarily under:

```text
~/Library/Application Support/Hermes/
```

The client intentionally retains the upstream app name and bundle identifier, so it replaces `Hermes.app` and uses the existing Hermes desktop state.

## How the CI build works

This repository does not vendor the Hermes codebase or its Python backend.

For each build, GitHub Actions:

1. Fetches the requested official `NousResearch/hermes-agent` tag or commit into an ephemeral runner.
2. Applies one coherent desktop-only delta from [`patches/`](patches/README.md).
3. Verifies that no package manifest or lockfile was modified.
4. Installs JavaScript build dependencies only inside the disposable CI runner.
5. Runs desktop type checks and tests.
6. Builds the upstream Electron renderer and macOS application.
7. Inspects `Hermes.app` and `app.asar` to ensure no Python backend/runtime was packaged.
8. Publishes the app, provenance metadata, and checksums.

The large `node_modules` directory exists only during the CI job and is discarded with the runner. It is neither committed nor included as a standalone development dependency on the user's Mac.

## Local verification

The fast compatibility check needs Git, Node.js 22, and GitHub CLI:

```bash
./scripts/check-patches.sh
```

A complete macOS build requires an Apple Silicon Mac:

```bash
./scripts/prepare-source.sh main /tmp/hermes-client-source
./scripts/build-macos.sh /tmp/hermes-client-source /tmp/hermes-client-dist local
```

All upstream source and build dependencies stay in the supplied temporary directories.

## Project scope

This repository only maintains the remote-only desktop distribution and its CI automation. General Hermes bugs and backend features belong in the [official Hermes repository](https://github.com/NousResearch/hermes-agent/issues).

## License and attribution

The client delta is distributed under the MIT License. Hermes source and branding remain attributable to Nous Research; see [LICENSE](LICENSE) and [NOTICE](NOTICE).
