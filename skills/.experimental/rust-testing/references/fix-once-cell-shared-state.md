---
title: Use OnceCell for Expensive Shared Setup
impact: MEDIUM
impactDescription: initializes expensive resources once across tests
tags: fix, once-cell, lazy-static, shared-state, initialization
---

## Use OnceCell for Expensive Shared Setup

Use `std::sync::OnceLock` or `once_cell::sync::Lazy` for expensive one-time setup shared across tests. This initializes resources lazily and only once.

**Incorrect (repeated expensive setup):**

```rust
#[test]
fn test_query_1() {
    let pool = PgPool::connect("postgres://localhost/test").await.unwrap();
    pool.migrate().await.unwrap();  // Takes 5 seconds
    // ...
}

#[test]
fn test_query_2() {
    let pool = PgPool::connect("postgres://localhost/test").await.unwrap();
    pool.migrate().await.unwrap();  // Takes 5 seconds again!
    // ...
}
// Each test pays the 5-second migration cost
```

**Correct (shared one-time initialization):**

```rust
use std::sync::OnceLock;
use tokio::sync::OnceCell;

// For sync tests
static CONFIG: OnceLock<Config> = OnceLock::new();

fn get_config() -> &'static Config {
    CONFIG.get_or_init(|| {
        // Expensive config loading - runs once
        Config::load_from_file("test_config.toml").unwrap()
    })
}

#[test]
fn test_uses_config_1() {
    let config = get_config();  // First call initializes
    assert_eq!(config.env, "test");
}

#[test]
fn test_uses_config_2() {
    let config = get_config();  // Returns cached value
    assert!(config.debug_mode);
}

// For async tests
static DB_POOL: OnceCell<PgPool> = OnceCell::const_new();

async fn get_pool() -> &'static PgPool {
    DB_POOL.get_or_init(|| async {
        let pool = PgPool::connect("postgres://localhost/test").await.unwrap();
        pool.migrate().await.unwrap();  // Runs once
        pool
    }).await
}

#[tokio::test]
async fn test_async_1() {
    let pool = get_pool().await;  // First call initializes
    let rows = sqlx::query("SELECT 1").fetch_all(pool).await.unwrap();
    assert_eq!(rows.len(), 1);
}

#[tokio::test]
async fn test_async_2() {
    let pool = get_pool().await;  // Returns cached pool
    // Uses same connection pool
}
```

**With once_cell crate (pre-Rust 1.70):**

```rust
use once_cell::sync::Lazy;

static EXPENSIVE_RESOURCE: Lazy<ExpensiveResource> = Lazy::new(|| {
    ExpensiveResource::initialize().unwrap()
});

#[test]
fn test_uses_resource() {
    let resource = &*EXPENSIVE_RESOURCE;
    // ...
}
```

**When to use:**

| Pattern | Use Case |
|---------|----------|
| Per-test setup | Mutable state, test isolation needed |
| Shared OnceLock | Immutable config, read-only resources |
| Shared pool | Database connections, thread-safe resources |

**Warning:** Shared state between tests can cause flaky tests if tests modify the shared resource. Only share immutable or thread-safe resources.

Reference: [std::sync::OnceLock](https://doc.rust-lang.org/std/sync/struct.OnceLock.html)
