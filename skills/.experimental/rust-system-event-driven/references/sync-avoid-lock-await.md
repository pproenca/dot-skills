---
title: Avoid Holding std Mutex Across Await
impact: HIGH
impactDescription: prevents deadlocks and runtime panics
tags: sync, mutex, await, deadlock, tokio
---

## Avoid Holding std Mutex Across Await

Standard library `Mutex` guards are not `Send`, so holding them across `.await` points causes compilation errors or runtime panics in multi-threaded runtimes.

**Incorrect (std Mutex across await):**

```rust
async fn update_cache(cache: &Arc<std::sync::Mutex<Cache>>) {
    let mut guard = cache.lock().unwrap();
    let data = fetch_data().await;  // ERROR: guard is not Send
    guard.insert(data);
}
```

**Correct (scope the lock or use async Mutex):**

```rust
// Option 1: Scope the lock before await
async fn update_cache(cache: &Arc<std::sync::Mutex<Cache>>) {
    let data = fetch_data().await;
    let mut guard = cache.lock().unwrap();
    guard.insert(data);  // Lock held only during insert
}

// Option 2: Use tokio's async Mutex when await is needed inside
async fn update_cache(cache: &Arc<tokio::sync::Mutex<Cache>>) {
    let mut guard = cache.lock().await;
    let data = fetch_data().await;  // Safe with tokio Mutex
    guard.insert(data);
}
```

**Guideline:**
- Use `std::sync::Mutex` when lock is held briefly without await
- Use `tokio::sync::Mutex` when you must await while holding the lock

Reference: [Which Mutex to use - Tokio](https://tokio.rs/tokio/tutorial/shared-state#which-kind-of-mutex-should-you-use)
