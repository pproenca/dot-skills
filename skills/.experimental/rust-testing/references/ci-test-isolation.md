---
title: Ensure Test Isolation in Parallel CI
impact: MEDIUM
impactDescription: prevents flaky tests from shared state
tags: ci, isolation, parallel, flaky-tests, shared-state
---

## Ensure Test Isolation in Parallel CI

Design tests to run in isolation without shared mutable state. Parallel test execution exposes race conditions and shared state bugs.

**Incorrect (shared state between tests):**

```rust
static mut COUNTER: u32 = 0;

#[test]
fn test_increment() {
    unsafe {
        COUNTER += 1;
        assert_eq!(COUNTER, 1);  // Flaky! Other tests modify COUNTER
    }
}

#[test]
fn test_reset() {
    unsafe {
        COUNTER = 0;  // Affects other running tests
    }
}
```

**Incorrect (shared file path):**

```rust
#[test]
fn test_write_config() {
    std::fs::write("/tmp/test_config.json", config).unwrap();
    // Another test may overwrite this file
}

#[test]
fn test_read_config() {
    let config = std::fs::read("/tmp/test_config.json").unwrap();
    // May read data from different test
}
```

**Correct (isolated test state):**

```rust
use std::sync::atomic::{AtomicU32, Ordering};
use tempfile::TempDir;

#[test]
fn test_increment() {
    // Each test has its own counter
    let counter = AtomicU32::new(0);
    counter.fetch_add(1, Ordering::SeqCst);
    assert_eq!(counter.load(Ordering::SeqCst), 1);
}

#[test]
fn test_file_operations() {
    // Each test has its own temp directory
    let temp_dir = TempDir::new().unwrap();
    let config_path = temp_dir.path().join("config.json");

    std::fs::write(&config_path, config).unwrap();
    let loaded = std::fs::read(&config_path).unwrap();
    // No interference with other tests
}
```

**Database test isolation:**

```rust
#[tokio::test]
async fn test_user_creation() {
    // Use unique schema per test
    let schema = format!("test_{}", uuid::Uuid::new_v4().to_string().replace("-", ""));
    let pool = setup_test_database(&schema).await;

    // Test runs in isolated schema
    create_user(&pool).await;

    // Cleanup
    drop_schema(&pool, &schema).await;
}
```

**Detecting isolation issues:**

```yaml
# Run tests multiple times to detect flaky tests
- name: Stress test for flakiness
  run: |
    for i in {1..5}; do
      cargo nextest run --no-fail-fast || exit 1
    done
```

**Using serial test attribute when needed:**

```rust
use serial_test::serial;

#[test]
#[serial]  // Runs exclusively, not in parallel
fn test_that_modifies_global_state() {
    // Safe to modify global state
    std::env::set_var("CONFIG_PATH", "/test/path");
    run_test();
    std::env::remove_var("CONFIG_PATH");
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
serial_test = "3.0"
```

Reference: [cargo test - Test Parallelism](https://doc.rust-lang.org/book/ch11-02-running-tests.html#running-tests-in-parallel-or-consecutively)
