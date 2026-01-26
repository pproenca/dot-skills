---
title: Generate Coverage Reports in CI
impact: MEDIUM
impactDescription: 80%+ line coverage prevents regressions
tags: ci, coverage, llvm-cov, tarpaulin, quality
---

## Generate Coverage Reports in CI

Generate code coverage reports in CI to identify untested code. Use llvm-cov or tarpaulin for accurate Rust coverage measurement.

**Incorrect (no coverage tracking):**

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: cargo test
        # No visibility into which code paths are untested
        # Regressions can slip through untested branches
```

**Correct (coverage with cargo-llvm-cov):**

```yaml
# .github/workflows/ci.yml
jobs:
  coverage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install llvm-cov
        uses: taiki-e/install-action@cargo-llvm-cov

      - name: Generate coverage
        run: cargo llvm-cov --all-features --lcov --output-path lcov.info

      - name: Upload to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: lcov.info
          fail_ci_if_error: true
```

**Coverage with nextest (faster):**

```yaml
- name: Generate coverage with nextest
  run: |
    cargo llvm-cov nextest --all-features --lcov --output-path lcov.info
```

**Exclude test utilities from coverage:**

```rust
// Exclude test utilities from coverage metrics
#[cfg(not(tarpaulin_include))]
mod test_helpers {
    pub fn setup() { /* ... */ }
}

#[cfg_attr(coverage, ignore)]
fn test_utility() {}
```

**Minimum coverage enforcement:**

```bash
COVERAGE=$(cargo llvm-cov --summary-only | grep -oP 'line coverage: \K[\d.]+')
if (( $(echo "$COVERAGE < 80" | bc -l) )); then
  echo "Coverage $COVERAGE% is below 80% threshold"
  exit 1
fi
```

**Interpreting coverage:**

| Metric | Target | Notes |
|--------|--------|-------|
| Line coverage | >80% | Basic coverage |
| Branch coverage | >70% | Edge cases tested |
| Function coverage | >90% | All functions called |

Reference: [cargo-llvm-cov](https://github.com/taiki-e/cargo-llvm-cov)
