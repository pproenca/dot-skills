---
title: Design Cancellation-Safe Async Operations
impact: CRITICAL
impactDescription: prevents data loss on task cancellation
tags: async, cancellation, safety, tokio, select
---

## Design Cancellation-Safe Async Operations

When a future is dropped (cancelled), any partially-completed work is lost. Operations inside `select!` must be cancellation-safe to avoid data loss.

**Incorrect (loses message on cancellation):**

```rust
async fn process_messages(
    rx: &mut Receiver<Message>,
    shutdown: &mut broadcast::Receiver<()>,
) {
    loop {
        tokio::select! {
            // recv() is NOT cancellation-safe - message lost if other branch wins
            Some(msg) = rx.recv() => {
                process(msg).await;
            }
            _ = shutdown.recv() => break,
        }
    }
}
```

**Correct (biased ensures shutdown is checked first):**

```rust
async fn process_messages(
    rx: &mut Receiver<Message>,
    shutdown: &mut broadcast::Receiver<()>,
) {
    loop {
        tokio::select! {
            biased;  // Checks branches in order, shutdown first
            _ = shutdown.recv() => break,
            msg = rx.recv() => {
                if let Some(msg) = msg {
                    process(msg).await;
                }
            }
        }
    }
}
```

**Alternative (pin the future outside select):**

```rust
async fn process_messages(
    rx: &mut Receiver<Message>,
    shutdown: &mut broadcast::Receiver<()>,
) {
    let mut recv_fut = std::pin::pin!(rx.recv());
    loop {
        tokio::select! {
            biased;
            _ = shutdown.recv() => break,
            msg = &mut recv_fut => {
                if let Some(msg) = msg {
                    process(msg).await;
                }
                recv_fut.set(rx.recv());
            }
        }
    }
}
```

Reference: [Cancellation safety - Tokio](https://docs.rs/tokio/latest/tokio/macro.select.html#cancellation-safety)
