---
title: Use Semaphore to Limit Concurrency
impact: HIGH
impactDescription: prevents resource exhaustion from unbounded parallelism
tags: sync, semaphore, concurrency, rate-limit, tokio
---

## Use Semaphore to Limit Concurrency

When processing items in parallel, use a semaphore to limit the maximum number of concurrent operations. This prevents resource exhaustion (file handles, connections, memory).

**Incorrect (unbounded parallelism):**

```rust
async fn process_all(items: Vec<Item>) {
    let handles: Vec<_> = items
        .into_iter()
        .map(|item| tokio::spawn(process_item(item)))  // Spawns ALL at once
        .collect();

    for handle in handles {
        handle.await.unwrap();
    }
}
```

**Correct (semaphore-limited concurrency):**

```rust
async fn process_all(items: Vec<Item>) {
    let semaphore = Arc::new(Semaphore::new(10));  // Max 10 concurrent

    let handles: Vec<_> = items
        .into_iter()
        .map(|item| {
            let permit = semaphore.clone();
            tokio::spawn(async move {
                let _permit = permit.acquire().await.unwrap();
                process_item(item).await
                // permit dropped, slot available for next task
            })
        })
        .collect();

    for handle in handles {
        handle.await.unwrap();
    }
}
```

**Alternative with stream:**

```rust
use futures::stream::{self, StreamExt};

async fn process_all(items: Vec<Item>) {
    stream::iter(items)
        .map(|item| async move { process_item(item).await })
        .buffer_unordered(10)  // Max 10 concurrent
        .collect::<Vec<_>>()
        .await;
}
```

Reference: [tokio::sync::Semaphore](https://docs.rs/tokio/latest/tokio/sync/struct.Semaphore.html)
