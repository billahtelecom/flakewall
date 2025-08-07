# Contributing to flakewall

Thanks for your interest in contributing!

## Development setup
- Python 3.9+
- Create a virtualenv and install dev deps:
  ```bash
  make dev
  # or
  python -m venv .venv && . .venv/bin/activate && pip install -e .[dev]
  ```
- Run a quick smoke test:
  ```bash
  flakewall --help
  pytest -q  # if/when tests are added
  ```

## Conventional commits
Use short, informative commit messages, e.g. `feat: ...`, `fix: ...`, `docs: ...`.

## Releasing
Publishing is automated via GitHub Actions on tags that start with `v`.
1) Ensure `PYPI_API_TOKEN` is configured in repo secrets.
2) Bump version in `pyproject.toml`.
3) Tag and push:
   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```
The `release` workflow builds and publishes to PyPI.

## Code style
- Prefer readable, explicit code (see repository’s code style).
- Keep CLI output concise and script-friendly; offer `--json` where useful.

## Issues & PRs
- Please describe the problem and steps to reproduce.
- Keep PRs focused and include a brief rationale.


