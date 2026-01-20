---
title: Minimize Lock Scope
impact: MEDIUM-HIGH
impactDescription: reduces contention time
tags: async, lock, mutex, scope, contention
---

## Minimize Lock Scope

Hold locks for the shortest time possible. Extract data and release the lock before doing work on it.

**Incorrect (holds lock during computation):**

```rust
use tokio::sync::Mutex;

async fn process_user_data(cache: &Mutex<HashMap<u64, User>>, id: u64) -> Report {
    let data = cache.lock().await;
    let user = data.get(&id).unwrap().clone();
    generate_report(&user)  // Lock held during expensive operation
}  // Lock released after report generation
```

**Correct (releases lock immediately):**

```rust
use tokio::sync::Mutex;

async fn process_user_data(cache: &Mutex<HashMap<u64, User>>, id: u64) -> Report {
    let user = {
        let data = cache.lock().await;
        data.get(&id).unwrap().clone()
    };  // Lock released here
    generate_report(&user)  // No lock held during computation
}
```

**Alternative with scope block:**

```rust
async fn process_user_data(cache: &Mutex<HashMap<u64, User>>, id: u64) -> Report {
    let user = cache.lock().await.get(&id).unwrap().clone();
    // Lock dropped at end of statement
    generate_report(&user)
}
```

**Key insight:** The lock guard is dropped when it goes out of scope, so use explicit blocks or early drops.

Reference: [Tokio - Shared State](https://tokio.rs/tokio/tutorial/shared-state)
