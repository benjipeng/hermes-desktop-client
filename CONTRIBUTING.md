# Contributing

Contributions should remain narrowly focused on producing the remote-only Hermes desktop client.

## Principles

- Preserve the upstream Hermes Electron/React interface.
- Never replace it with a dashboard WebView.
- Never bundle, install, or launch the Hermes Python backend.
- Do not edit upstream `package.json` files or `package-lock.json`.
- Keep changes confined to `apps/desktop/`.
- Treat upstream release tags as immutable and reproducible.

## Before opening a pull request

Run:

```bash
./scripts/check-patches.sh
```

For packaging changes, also run an Apple Silicon build and confirm `scripts/verify-app.sh` passes.

General Hermes product changes should be contributed to [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) instead.
