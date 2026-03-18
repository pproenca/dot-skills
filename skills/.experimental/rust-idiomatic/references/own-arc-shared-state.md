---
title: Use Arc for Shared Async State
impact: CRITICAL
impactDescription: enables safe shared ownership across spawned tasks
tags: own, arc, shared-state, async, concurrency
---

## Use Arc for Shared Async State

Wrap shared state in `Arc<T>` when multiple async tasks need concurrent read access. Use `Arc::clone(&value)` instead of `value.clone()` to make it visually clear that only the reference count is incremented, not the inner data.

**Incorrect (clones entire session data for each task):**

```rust
async fn spawn_workers(session: Session) {
    let session_a = session.clone();
    let session_b = session.clone();
    tokio::spawn(async move { session_a.process().await });
    tokio::spawn(async move { session_b.process().await });
}
```

**Correct (shares via Arc, only increments refcount):**

```rust
use std::sync::Arc;

async fn spawn_workers(session: Arc<Session>) {
    let session_a = Arc::clone(&session);
    let session_b = Arc::clone(&session);
    tokio::spawn(async move { session_a.process().await });
    tokio::spawn(async move { session_b.process().await });
}
```
