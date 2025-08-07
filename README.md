# flakewall

Local guard for flaky tests using JUnit XML: parse results, auto-quarantine known flakes, and gate CI exit codes.

Usage
- flakewall --help
- flakewall init
- flakewall report --junit "reports/**/*.xml"
- flakewall guard --junit "reports/**/*.xml"
- flakewall score --junit "reports/**/*.xml" --min-total 2 [--json]
- flakewall auto-quarantine --junit "reports/**/*.xml" --threshold 0.25 --min-total 2 [--dry-run]
- flakewall retry --framework pytest --from-junit "reports/**/*.xml" --max-retries 1 [--auto-quarantine] [--json]

Config files created by `init` under `.flakewall/`:
- config.yml (e.g., retries: 0, report_glob: "**/junit*.xml")
- quarantine.yml (list of quarantined test ids)

CI Example (GitHub Actions)
```yaml
name: tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: python -m pip install --upgrade pip
      - run: pip install flakewall
      - name: Run tests
        run: |
          pytest --junitxml=reports/junit.xml
      - name: Guard CI from known flakes
        run: |
          flakewall init
          flakewall guard --junit "reports/**/*.xml"
      - name: Flake scoring (for visibility)
        run: |
          flakewall score --junit "reports/**/*.xml" --min-total 2 --json > flakewall_score.json
      - name: Auto-quarantine candidates (optional)
        if: github.ref != 'refs/heads/main'
        run: |
          flakewall auto-quarantine --junit "reports/**/*.xml" --threshold 0.25 --min-total 2 --dry-run
```
