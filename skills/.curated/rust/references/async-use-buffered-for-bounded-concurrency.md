---
title: Use buffered() for Bounded Concurrency
impact: MEDIUM-HIGH
impactDescription: prevents resource exhaustion
tags: async, buffered, concurrency, stream, futures
---

## Use buffered() for Bounded Concurrency

Spawning unlimited concurrent tasks can exhaust resources. Use `buffered()` or `buffer_unordered()` to limit concurrency.

**Incorrect (unbounded concurrency):**

```rust
use futures::future::join_all;

async fn fetch_all_users(ids: Vec<u64>) -> Vec<User> {
    let futures: Vec<_> = ids.iter().map(|id| fetch_user(*id)).collect();
    join_all(futures).await  // All requests in parallel - may overwhelm server
}
```

**Correct (bounded concurrency):**

```rust
use futures::stream::{self, StreamExt};

async fn fetch_all_users(ids: Vec<u64>) -> Vec<User> {
    stream::iter(ids)
        .map(|id| fetch_user(id))
        .buffered(10)  // At most 10 concurrent requests
        .collect()
        .await
}
```

**For order-independent results:**

```rust
async fn fetch_all_users(ids: Vec<u64>) -> Vec<User> {
    stream::iter(ids)
        .map(|id| fetch_user(id))
        .buffer_unordered(10)  // Faster, results may arrive out of order
        .collect()
        .await
}
```

**Choosing concurrency limit:**
- Database connections: Match pool size
- External APIs: Respect rate limits
- CPU-bound: Match CPU core count

Reference: [futures::stream::StreamExt::buffered](https://docs.rs/futures/latest/futures/stream/trait.StreamExt.html#method.buffered)
