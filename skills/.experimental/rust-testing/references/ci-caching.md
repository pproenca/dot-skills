---
title: Cache Cargo Dependencies in CI
impact: MEDIUM
impactDescription: 50-80% faster CI builds
tags: ci, caching, github-actions, dependencies, performance
---

## Cache Cargo Dependencies in CI

Cache the Cargo registry and target directory in CI. Without caching, every CI run downloads and compiles all dependencies from scratch.

**Incorrect (no caching):**

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: cargo test
        # Downloads ~500 crates every run
        # Compiles everything from scratch
        # Takes 10+ minutes
```

**Correct (Rust-specific caching):**

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cache Cargo
        uses: actions/cache@v4
        with:
          path: |
            ~/.cargo/bin/
            ~/.cargo/registry/index/
            ~/.cargo/registry/cache/
            ~/.cargo/git/db/
            target/
          key: ${{ runner.os }}-cargo-${{ hashFiles('**/Cargo.lock') }}
          restore-keys: |
            ${{ runner.os }}-cargo-

      - name: Run tests
        run: cargo test
        # Incremental build - only changed crates recompile
```

**Using Swatinem/rust-cache (recommended):**

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cache Rust
        uses: Swatinem/rust-cache@v2
        with:
          # Cache key prefix for different jobs
          prefix-key: "v1-rust"
          # Additional paths to cache
          cache-directories: |
            ~/.cargo/bin/cargo-nextest

      - name: Run tests
        run: cargo test
```

**Separate cache for different workflows:**

```yaml
jobs:
  test:
    uses: Swatinem/rust-cache@v2
    with:
      shared-key: "test"  # Shared between test jobs

  build:
    uses: Swatinem/rust-cache@v2
    with:
      shared-key: "build"  # Separate cache for release builds
```

**Cache invalidation triggers:**

```yaml
key: ${{ runner.os }}-cargo-${{ hashFiles('**/Cargo.lock') }}-${{ hashFiles('**/Cargo.toml') }}
# Invalidates when:
# - Cargo.lock changes (dependency updates)
# - Cargo.toml changes (new dependencies)
# - OS changes (cross-platform builds)
```

**Typical speedup:**

| Scenario | Without Cache | With Cache |
|----------|---------------|------------|
| First run | 10 min | 10 min |
| No changes | 10 min | 1 min |
| Small change | 10 min | 2 min |
| Dep update | 10 min | 5 min |

Reference: [Swatinem/rust-cache](https://github.com/Swatinem/rust-cache)
