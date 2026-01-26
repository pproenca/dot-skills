---
title: Use tokio::test for Async Test Functions
impact: HIGH
impactDescription: eliminates manual runtime setup boilerplate
tags: async, tokio, test-macro, runtime
---

## Use tokio::test for Async Test Functions

Use `#[tokio::test]` instead of manually creating a runtime. It automatically sets up a single-threaded runtime optimized for testing.

**Incorrect (manual runtime setup):**

```rust
use tokio::runtime::Runtime;

#[test]
fn test_async_function() {
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        let result = fetch_user(42).await;
        assert_eq!(result.name, "Alice");
    });
}

#[test]
fn test_another_async_function() {
    // Repeated boilerplate in every test
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        let orders = fetch_orders(42).await;
        assert_eq!(orders.len(), 3);
    });
}
```

**Correct (tokio::test macro):**

```rust
#[tokio::test]
async fn test_fetch_user() {
    let result = fetch_user(42).await;
    assert_eq!(result.name, "Alice");
}

#[tokio::test]
async fn test_fetch_orders() {
    let orders = fetch_orders(42).await;
    assert_eq!(orders.len(), 3);
}
```

**Configuration options:**

```rust
// Multi-threaded runtime (for testing concurrent behavior)
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn test_concurrent_operations() {
    let (result1, result2) = tokio::join!(
        fetch_user(1),
        fetch_user(2)
    );
    assert!(result1.is_ok());
    assert!(result2.is_ok());
}

// Start with time paused (for time-sensitive tests)
#[tokio::test(start_paused = true)]
async fn test_timeout_behavior() {
    // Time is paused - tokio::time::advance() controls time
    let start = tokio::time::Instant::now();
    tokio::time::advance(Duration::from_secs(60)).await;
    assert!(start.elapsed() >= Duration::from_secs(60));
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
tokio = { version = "1", features = ["rt", "macros", "test-util"] }
```

**Note:** Each test gets its own runtime. Tests run in parallel with isolated runtimes.

Reference: [Tokio - Unit Testing](https://tokio.rs/tokio/topics/testing)
