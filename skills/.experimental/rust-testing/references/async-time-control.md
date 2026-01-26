---
title: Use Paused Time for Timeout Testing
impact: HIGH
impactDescription: makes timeout tests instant and deterministic
tags: async, tokio, time-control, timeouts, deterministic
---

## Use Paused Time for Timeout Testing

Use `start_paused = true` with `tokio::time::advance()` to test timeouts without waiting. This makes time-dependent tests run instantly and deterministically.

**Incorrect (real time waits):**

```rust
#[tokio::test]
async fn test_request_timeout() {
    let client = TimeoutClient::new(Duration::from_secs(30));

    let start = std::time::Instant::now();
    let result = client.fetch("/slow-endpoint").await;

    assert!(result.is_err());
    // Test takes 30+ seconds to run!
    assert!(start.elapsed() >= Duration::from_secs(30));
}
```

**Correct (paused time, instant execution):**

```rust
#[tokio::test(start_paused = true)]
async fn test_request_timeout() {
    let client = TimeoutClient::new(Duration::from_secs(30));

    // Spawn the request (uses tokio::time::timeout internally)
    let fetch_task = tokio::spawn(async move {
        client.fetch("/slow-endpoint").await
    });

    // Advance time by 30 seconds instantly
    tokio::time::advance(Duration::from_secs(30)).await;

    let result = fetch_task.await.unwrap();
    assert!(matches!(result, Err(Error::Timeout)));
    // Test completes in milliseconds!
}

#[tokio::test(start_paused = true)]
async fn test_retry_backoff() {
    let mut client = RetryClient::new();

    // Simulate 3 retries with exponential backoff
    let task = tokio::spawn(async move {
        client.fetch_with_retry("/api").await
    });

    // First retry after 1s
    tokio::time::advance(Duration::from_secs(1)).await;
    // Second retry after 2s
    tokio::time::advance(Duration::from_secs(2)).await;
    // Third retry after 4s
    tokio::time::advance(Duration::from_secs(4)).await;

    let result = task.await.unwrap();
    assert!(result.is_ok());
}
```

**Testing periodic tasks:**

```rust
#[tokio::test(start_paused = true)]
async fn test_periodic_cleanup() {
    let cache = Arc::new(TestCache::new());
    let cache_clone = cache.clone();

    // Start background cleanup task
    tokio::spawn(async move {
        let mut interval = tokio::time::interval(Duration::from_secs(60));
        loop {
            interval.tick().await;
            cache_clone.cleanup_expired();
        }
    });

    cache.insert("key", "value", Duration::from_secs(30));

    // Advance 60 seconds - cleanup should run
    tokio::time::advance(Duration::from_secs(60)).await;
    tokio::task::yield_now().await;  // Let cleanup task run

    assert!(cache.get("key").is_none());  // Expired and cleaned
}
```

**Required feature:**

```toml
[dev-dependencies]
tokio = { version = "1", features = ["test-util", "time", "macros", "rt"] }
```

Reference: [Tokio - Pausing Time](https://tokio.rs/tokio/topics/testing#pausing-time)
