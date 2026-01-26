---
title: Filter Tests for Faster Feedback Loops
impact: LOW-MEDIUM
impactDescription: run only relevant tests during development
tags: perf, filtering, development, iteration, focus
---

## Filter Tests for Faster Feedback Loops

Run only relevant tests during development using name filters, modules, and test attributes. Save full test runs for CI.

**Incorrect (running all tests every time):**

```bash
# Development workflow
cargo test  # Runs all 500 tests, takes 2 minutes
# Make small change
cargo test  # Runs all 500 tests again
```

**Correct (filtered test runs):**

```bash
# Run tests matching a pattern
cargo test user::        # Tests in user module
cargo test create_user   # Tests containing "create_user"
cargo test --test integration_tests  # Only integration tests

# Run single test
cargo test test_user_creation -- --exact

# Run tests in specific file
cargo test --test api_tests

# Skip slow tests
cargo test -- --skip slow
```

**Mark slow tests with ignore:**

```rust
#[test]
fn test_fast_operation() {
    assert!(quick_check());
}

#[test]
#[ignore]  // Skipped by default, run with --ignored
fn test_slow_database_migration() {
    // Takes 30 seconds
    run_full_migration();
}

#[test]
#[ignore = "requires external service"]
fn test_external_api_integration() {
    // Requires running service
}
```

**Running ignored tests:**

```bash
# Skip ignored tests (default)
cargo test

# Run ONLY ignored tests
cargo test -- --ignored

# Run ALL tests including ignored
cargo test -- --include-ignored
```

**Module-based test organization:**

```rust
#[cfg(test)]
mod fast_tests {
    #[test]
    fn test_parse() { }

    #[test]
    fn test_validate() { }
}

#[cfg(test)]
mod slow_tests {
    #[test]
    #[ignore]
    fn test_full_workflow() { }
}
```

```bash
# Development - fast feedback
cargo test fast_tests::

# Before commit - thorough check
cargo test -- --include-ignored
```

**Using cargo-nextest for filtering:**

```bash
# Run tests matching regex
cargo nextest run -E 'test(/user/)'

# Exclude integration tests
cargo nextest run -E 'not test(/integration/)'

# Run only unit tests (not in tests/ directory)
cargo nextest run -E 'kind(lib)'
```

**Development workflow:**

```bash
# Watch mode - rerun on changes
cargo watch -x 'test user::'

# Or with nextest
cargo watch -x 'nextest run -E "test(/user/)"'
```

Reference: [cargo test - Running Specific Tests](https://doc.rust-lang.org/book/ch11-02-running-tests.html#running-a-subset-of-tests-by-name)
