---
title: Use move Closures for tokio spawn
impact: CRITICAL
impactDescription: prevents lifetime errors in spawned async tasks
tags: own, move, closures, tokio, spawn, async
---

## Use move Closures for tokio spawn

Always use `move` closures when passing data to `tokio::spawn`. Spawned tasks run on an independent executor and outlive the calling scope. Without `move`, the closure tries to borrow from the caller, causing lifetime errors.

**Incorrect (borrows from caller, fails to compile):**

```rust
async fn start_background_sync(manager: Arc<SyncManager>, token: CancellationToken) {
    let child_token = token.child_token();
    tokio::spawn(async {
        manager.run_sync(child_token).await;
    });
}
```

**Correct (move transfers ownership into the spawned future):**

```rust
async fn start_background_sync(manager: Arc<SyncManager>, token: CancellationToken) {
    let child_token = token.child_token();
    tokio::spawn(async move {
        manager.run_sync(child_token).await;
    });
}
```
