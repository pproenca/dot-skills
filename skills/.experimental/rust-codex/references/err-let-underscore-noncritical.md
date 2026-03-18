---
title: Use let _ = for Non-Critical Send Failures
impact: CRITICAL
impactDescription: prevents panic during graceful shutdown
tags: err, channels, shutdown, send-failures
---

## Use let _ = for Non-Critical Send Failures

When sending on a channel where the receiver may already be dropped (shutdown paths, fire-and-forget notifications), always use `let _ =` to discard the `Result`. Calling `.unwrap()` or `?` on a channel send during cleanup causes panics when the receiving task has already exited.

**Incorrect (panics if receiver is dropped during shutdown):**

```rust
async fn cleanup(event_tx: mpsc::Sender<ShutdownEvent>) {
    event_tx.send(ShutdownEvent::Complete).await.unwrap();
    processor_handle.await.unwrap();
    outbound_handle.await.unwrap();
}
```

**Correct (gracefully ignores closed receivers):**

```rust
async fn cleanup(event_tx: mpsc::Sender<ShutdownEvent>) {
    let _ = event_tx.send(ShutdownEvent::Complete).await;
    let _ = processor_handle.await;
    let _ = outbound_handle.await;
}
```
