---
title: Avoid std Blocking Calls in Async Context
impact: CRITICAL
impactDescription: prevents entire runtime from freezing
tags: async, blocking, std, tokio, runtime
---

## Avoid std Blocking Calls in Async Context

Standard library blocking calls like `std::thread::sleep`, `std::fs::read`, and `Mutex::lock` block the entire async worker thread, halting all other tasks on that thread.

**Incorrect (blocks worker thread):**

```rust
async fn fetch_with_retry(url: &str) -> Result<Response, Error> {
    loop {
        match client.get(url).send().await {
            Ok(resp) => return Ok(resp),
            Err(_) => {
                std::thread::sleep(Duration::from_secs(1));  // Blocks runtime!
            }
        }
    }
}
```

**Correct (uses async sleep):**

```rust
async fn fetch_with_retry(url: &str) -> Result<Response, Error> {
    loop {
        match client.get(url).send().await {
            Ok(resp) => return Ok(resp),
            Err(_) => {
                tokio::time::sleep(Duration::from_secs(1)).await;
            }
        }
    }
}
```

**Common std blocking calls to avoid:**
- `std::thread::sleep` → `tokio::time::sleep`
- `std::fs::*` → `tokio::fs::*`
- `std::sync::Mutex` → `tokio::sync::Mutex`
- `std::io::stdin().read_line` → `tokio::io::AsyncBufReadExt`

Reference: [Async in depth - Tokio](https://tokio.rs/tokio/tutorial/async)
