# Hermes Dashboard for macOS

[![CI](https://github.com/benjipeng/hermes-dashboard-macos/actions/workflows/ci.yml/badge.svg)](https://github.com/benjipeng/hermes-dashboard-macos/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/benjipeng/hermes-dashboard-macos)](https://github.com/benjipeng/hermes-dashboard-macos/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A small native macOS window for a Hermes dashboard that is already running.

This project is deliberately **not a fork or distribution of Hermes Agent**. It contains no Hermes source, Python runtime, Electron runtime, npm dependencies, or patched upstream files. The application uses macOS WebKit to display the dashboard served by your existing Hermes installation.

## Why this exists

Hermes updates frequently, while a dashboard viewer should remain simple:

```text
Hermes gateway/dashboard  ── HTTP + WebSocket ──▶  native macOS WebKit window
```

- No upstream rebases
- No `node_modules`
- No bundled agent runtime
- No local backend installation or process management
- No duplicate chat implementation
- The dashboard updates when the connected Hermes installation updates

## Install

1. Download the Apple Silicon zip from [Releases](https://github.com/benjipeng/hermes-dashboard-macos/releases).
2. Extract `Hermes Dashboard.app`.
3. Drag it into `/Applications`.
4. Start your Hermes dashboard and open the app.

The default address is:

```text
http://127.0.0.1:9119
```

Change it at any time with **Hermes Dashboard → Connection Settings…**. HTTP and HTTPS dashboards on localhost, a private network, or a remote host are supported.

## Persistence and upgrades

Replacing the `.app` does not remove local settings. The dashboard address is stored by macOS under the bundle identifier:

```text
com.benjipeng.hermes-dashboard
```

WebKit cookies, local storage, and login state are stored separately under the user's Library. Chats, sessions, memory, skills, and agent configuration remain on the connected Hermes server.

## Build locally

Requirements:

- macOS 13 or newer
- Xcode command-line tools or Xcode

```bash
make test
make package
```

No package manager or third-party dependency download is required. The resulting zip is written to `artifacts/`.

Override the initial dashboard address for a particular build:

```bash
DEFAULT_DASHBOARD_URL=https://hermes.example.com make package
```

This only changes the first-run default. Users can still change the address from the app.

## Relationship to Hermes releases

The client does not embed the Hermes dashboard, so updating the gateway updates the UI and API served to this app automatically. There is no upstream rebase or source patch.

For traceability, a scheduled GitHub Actions workflow watches the official Hermes releases. When a new upstream release appears, it publishes a freshly tested compatibility build labeled with that Hermes version. The upstream source is neither copied into this repository nor modified during that process.

Upstream project: [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)

## Support

- Client bugs and feature requests: [this repository's issues](https://github.com/benjipeng/hermes-dashboard-macos/issues)
- Hermes gateway or dashboard bugs: [NousResearch/hermes-agent issues](https://github.com/NousResearch/hermes-agent/issues)
- Security reports: follow [SECURITY.md](SECURITY.md)

Maintained by [@benjipeng](https://github.com/benjipeng).

## License

MIT. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
