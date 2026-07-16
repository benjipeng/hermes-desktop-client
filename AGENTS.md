# Repository guide

This is a small CI/distribution repository, not a Hermes source fork.

- Never add a dashboard wrapper or duplicate the Hermes UI.
- Never vendor the Python backend or a built `node_modules` tree.
- Fetch official Hermes source only into temporary build directories.
- Keep the maintained delta desktop-only and manifest-neutral.
- Stable builds use exact official release tags; nightly builds use exact `main` commits.
- A change is incomplete until source preparation, desktop tests, package inspection, and the no-Python invariant pass.
