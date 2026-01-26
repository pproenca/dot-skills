---
title: Use CancellationToken for Coordinated Shutdown
impact: LOW-MEDIUM
impactDescription: enables clean multi-task shutdown
tags: loop, cancellation, shutdown, coordination, tokio
---

## Use CancellationToken for Coordinated Shutdown

CancellationToken provides a clean way to signal shutdown to multiple tasks and wait for them to complete. It's more ergonomic than broadcast channels for shutdown coordination.

**Incorrect (manual shutdown coordination):**

```rust
struct App {
    shutdown_tx: broadcast::Sender<()>,
}

async fn worker(mut shutdown_rx: broadcast::Receiver<()>) {
    loop {
        tokio::select! {
            _ = shutdown_rx.recv() => break,
            _ = do_work() => {}
        }
    }
}
```

**Correct (CancellationToken):**

```rust
use tokio_util::sync::CancellationToken;

async fn run_app() {
    let token = CancellationToken::new();

    let worker1 = tokio::spawn(worker(token.child_token()));
    let worker2 = tokio::spawn(worker(token.child_token()));
    let server = tokio::spawn(server(token.child_token()));

    // Wait for shutdown signal
    signal::ctrl_c().await.unwrap();

    // Cancel all tasks
    token.cancel();

    // Wait for graceful completion
    let _ = tokio::join!(worker1, worker2, server);
}

async fn worker(token: CancellationToken) {
    loop {
        tokio::select! {
            biased;
            _ = token.cancelled() => break,
            _ = do_work() => {}
        }
    }
    // Cleanup code here
    cleanup().await;
}
```

**Hierarchical cancellation:**

```rust
let parent = CancellationToken::new();
let child = parent.child_token();

// Cancelling parent cancels all children
parent.cancel();

// Child can be cancelled independently without affecting parent
// child.cancel();
```

Reference: [tokio_util::sync::CancellationToken](https://docs.rs/tokio-util/latest/tokio_util/sync/struct.CancellationToken.html)
