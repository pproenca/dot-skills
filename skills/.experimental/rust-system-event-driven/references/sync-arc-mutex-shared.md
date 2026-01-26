---
title: Use Arc<Mutex> for Shared Mutable State
impact: HIGH
impactDescription: prevents data races at compile time
tags: sync, arc, mutex, shared-state, concurrency
---

## Use Arc<Mutex> for Shared Mutable State

When multiple tasks need to read and write shared state, wrap it in `Arc<Mutex>` for thread-safe access. Use tokio's async Mutex when holding the lock across await points.

**Incorrect (data race with RefCell):**

```rust
async fn run() {
    let state = Rc::new(RefCell::new(State::new()));  // Not Send!

    tokio::spawn({
        let state = state.clone();
        async move {
            state.borrow_mut().update();  // Compiler error: Rc is not Send
        }
    });
}
```

**Correct (Arc<Mutex> for sync access):**

```rust
async fn run() {
    let state = Arc::new(std::sync::Mutex::new(State::new()));

    tokio::spawn({
        let state = state.clone();
        async move {
            let mut guard = state.lock().unwrap();
            guard.update();  // Lock released when guard drops
        }
    });
}
```

**Use tokio::sync::Mutex when holding across .await:**

```rust
async fn run() {
    let state = Arc::new(tokio::sync::Mutex::new(State::new()));

    tokio::spawn({
        let state = state.clone();
        async move {
            let mut guard = state.lock().await;
            guard.async_update().await;  // Safe to await while holding
        }
    });
}
```

Reference: [Shared State - Tokio](https://tokio.rs/tokio/tutorial/shared-state)
