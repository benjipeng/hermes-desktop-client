# Contributing

Thanks for improving Hermes Dashboard for macOS.

## Scope

This repository owns only the native WebKit wrapper. Changes to Hermes Agent, its dashboard, APIs, authentication, or gateway behavior belong in the [upstream Hermes repository](https://github.com/NousResearch/hermes-agent).

## Development

```bash
make test
make build
```

Before opening a pull request:

1. Keep the client dependency-free.
2. Preserve dashboard URL and WebKit session persistence.
3. Avoid reproducing functionality already served by the dashboard.
4. Run `make test` and `make package`.
5. Describe any macOS version or dashboard authentication flow you exercised.

Use GitHub Issues for proposals that materially expand the native surface.

