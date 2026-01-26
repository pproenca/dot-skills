---
title: Use spawn_blocking for CPU-Bound Work
impact: CRITICAL
impactDescription: prevents event loop starvation
tags: async, blocking, spawn, tokio, cpu-bound
---

## Use spawn_blocking for CPU-Bound Work

CPU-intensive operations block the async runtime's worker threads, preventing other tasks from making progress. Use `spawn_blocking` to move heavy computation to a dedicated thread pool.

**Incorrect (blocks async runtime):**

```rust
async fn process_data(data: Vec<u8>) -> Result<Hash, Error> {
    // Blocks the tokio worker thread for seconds
    let hash = expensive_hash_computation(&data);
    Ok(hash)
}
```

**Correct (offloads to blocking thread pool):**

```rust
async fn process_data(data: Vec<u8>) -> Result<Hash, Error> {
    let hash = tokio::task::spawn_blocking(move || {
        expensive_hash_computation(&data)
    }).await?;
    Ok(hash)
}
```

**When NOT to use this pattern:**
- Operations completing in microseconds (overhead exceeds benefit)
- Already running on a blocking thread pool

Reference: [Tokio spawn_blocking](https://docs.rs/tokio/latest/tokio/task/fn.spawn_blocking.html)
