# Changelog

## v0.2.0
- score: add `--rich` with flips/instability/streaks
- retry: add vitest/go/dotnet/shell adapters; `--junit-out` writer
- guard: `--slack-webhook` notifications; GH annotations/summary options
- quarantine: TTL support and `quarantine-tick` command

## v0.1.2
- CLI: make --version work without subcommand; improve no-args help

## v0.1.1
- Add release workflow and polish docs/badges

## v0.1.0
- Initial release
- Commands: `init`, `report`, `guard`, `score`, `auto-quarantine`, `retry` (pytest/jest)
- JSON output for `score` and `retry`
- CI examples (GitHub Actions, GitLab, CircleCI, Azure Pipelines, Jenkins)
- Release workflow (tags `v*`)
