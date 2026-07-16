# Desktop-client delta

The files in this directory are a single logical product change applied to an ephemeral official Hermes checkout:

- `desktop-client-ts.patch` targets the current TypeScript Electron-main layout.
- `desktop-client-cjs.patch` targets the CommonJS layout used by official release `v2026.7.7.2`.

Both variants implement the same behavior:

- Use the real upstream Hermes desktop renderer.
- Default to `http://127.0.0.1:9119` and OAuth/password gateway sign-in.
- Continue supporting token-authenticated gateways.
- Remove local gateway choices from the client UI.
- Block every desktop path that could bootstrap, repair, or spawn a local Python backend.
- Store desktop logs under Electron user data rather than `~/.hermes`.
- Keep the selected black Nous dark surfaces.

The preparation script rejects any delta that changes files outside `apps/desktop/` or modifies an upstream package manifest/lockfile. Patch application is checked on every pull request against current upstream `main` and the latest official release.

When upstream changes make a variant fail to apply, rebase the corresponding implementation in a temporary official checkout, regenerate one clean binary diff, and verify both source layouts before merging.
