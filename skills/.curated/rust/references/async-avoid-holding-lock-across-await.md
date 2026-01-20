---
title: Avoid Holding Lock Across await Points
impact: MEDIUM-HIGH
impactDescription: prevents deadlocks and starvation
tags: async, lock, await, deadlock, send
---

## Avoid Holding Lock Across await Points

Holding a `std::sync::Mutex` guard across `.await` points can cause deadlocks and prevents the future from being `Send`.

**Incorrect (lock held across await):**

```rust
use std::sync::Mutex;

async fn update_cache(cache: &Mutex<HashMap<u64, User>>, id: u64) {
    let mut data = cache.lock().unwrap();
    let user = fetch_user(id).await;  // Lock held during network call
    data.insert(id, user);
}
```

**Correct (release lock before await):**

```rust
use std::sync::Mutex;

async fn update_cache(cache: &Mutex<HashMap<u64, User>>, id: u64) {
    let user = fetch_user(id).await;  // No lock held
    let mut data = cache.lock().unwrap();
    data.insert(id, user);  // Lock released at end of scope
}
```

**Alternative (use tokio::sync::Mutex):**

```rust
use tokio::sync::Mutex;

async fn update_cache(cache: &Mutex<HashMap<u64, User>>, id: u64) {
    let mut data = cache.lock().await;
    let user = fetch_user(id).await;  // Safe with tokio Mutex
    data.insert(id, user);
}
```

**Note:** Tokio's async Mutex is designed for this case but has higher overhead than std Mutex.

Reference: [Tokio - Shared State](https://tokio.rs/tokio/tutorial/shared-state)
