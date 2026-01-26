---
title: Test spawn_blocking with Multi-Threaded Runtime
impact: MEDIUM
impactDescription: prevents deadlocks in blocking code tests
tags: async, tokio, spawn-blocking, multi-threaded, deadlock
---

## Test spawn_blocking with Multi-Threaded Runtime

Use `flavor = "multi_thread"` when testing code that uses `spawn_blocking`. Single-threaded runtimes can deadlock when blocking threads wait for async tasks.

**Incorrect (single-threaded runtime with spawn_blocking):**

```rust
#[tokio::test]  // Default: single-threaded
async fn test_file_processing() {
    let result = process_large_file("data.csv").await;
    assert!(result.is_ok());
}

async fn process_large_file(path: &str) -> Result<Stats, Error> {
    let path = path.to_string();
    tokio::task::spawn_blocking(move || {
        // CPU-intensive work
        let content = std::fs::read_to_string(&path)?;
        compute_stats(&content)  // May deadlock in single-threaded test!
    }).await?
}
```

**Correct (multi-threaded runtime):**

```rust
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn test_file_processing() {
    let result = process_large_file("data.csv").await;
    assert!(result.is_ok());
}

#[tokio::test(flavor = "multi_thread")]
async fn test_concurrent_blocking_operations() {
    let (stats1, stats2) = tokio::join!(
        process_large_file("file1.csv"),
        process_large_file("file2.csv")
    );

    assert!(stats1.is_ok());
    assert!(stats2.is_ok());
}
```

**When to use each flavor:**

| Use Single-Threaded | Use Multi-Threaded |
|---------------------|-------------------|
| Pure async code | Uses `spawn_blocking` |
| No blocking calls | CPU-bound work |
| Simpler debugging | Tests concurrent behavior |
| Faster test startup | Tests thread pools |

**Testing blocking code patterns:**

```rust
#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
async fn test_parallel_compression() {
    let files = vec!["a.txt", "b.txt", "c.txt", "d.txt"];

    let handles: Vec<_> = files.iter().map(|path| {
        let path = path.to_string();
        tokio::spawn(async move {
            tokio::task::spawn_blocking(move || {
                compress_file(&path)
            }).await.unwrap()
        })
    }).collect();

    let results = futures::future::join_all(handles).await;
    assert!(results.iter().all(|r| r.is_ok()));
}
```

Reference: [Tokio - spawn_blocking](https://docs.rs/tokio/latest/tokio/task/fn.spawn_blocking.html)
