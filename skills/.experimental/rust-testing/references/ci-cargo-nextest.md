---
title: Use cargo-nextest for Faster CI
impact: MEDIUM
impactDescription: 2-3× faster test execution in CI
tags: ci, nextest, parallel, performance, github-actions
---

## Use cargo-nextest for Faster CI

Use cargo-nextest instead of cargo test in CI. It runs tests in parallel processes, provides better output, and detects flaky tests.

**Incorrect (standard cargo test):**

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: cargo test --all-features
        # Sequential test execution
        # Poor failure output
        # No flaky test detection
```

**Correct (cargo-nextest):**

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install cargo-nextest
        uses: taiki-e/install-action@nextest

      - name: Run tests
        run: cargo nextest run --all-features
        # Parallel process-per-test execution
        # Clear progress and failure output
        # Faster overall execution
```

**Configuration file for nextest:**

```toml
# .config/nextest.toml
[profile.default]
# Retry flaky tests up to 2 times
retries = 2

# Fail fast on first failure (good for local dev)
fail-fast = false

# Number of test threads
test-threads = "num-cpus"

[profile.ci]
# CI-specific settings
retries = 3
fail-fast = true

# Timeout for slow tests
slow-timeout = { period = "60s", terminate-after = 2 }
```

**Running with profile:**

```yaml
- name: Run tests
  run: cargo nextest run --profile ci --all-features
```

**Flaky test detection:**

```yaml
- name: Run tests with flaky detection
  run: |
    cargo nextest run --all-features 2>&1 | tee test-output.txt
    # nextest marks flaky tests with "FLAKY" in output
    if grep -q "FLAKY" test-output.txt; then
      echo "::warning::Flaky tests detected"
    fi
```

**Benefits over cargo test:**

| Feature | cargo test | cargo nextest |
|---------|------------|---------------|
| Execution | Sequential | Parallel processes |
| Output | Interleaved | Clean, organized |
| Retries | Manual | Built-in |
| Slow test detection | No | Yes |
| JUnit XML output | No | Yes |

Reference: [cargo-nextest documentation](https://nexte.st/)
