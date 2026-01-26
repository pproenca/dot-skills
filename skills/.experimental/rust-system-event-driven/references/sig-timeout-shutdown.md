---
title: Set Shutdown Timeout to Force Exit
impact: MEDIUM
impactDescription: prevents indefinite hang on shutdown
tags: sig, shutdown, timeout, graceful, force
---

## Set Shutdown Timeout to Force Exit

Graceful shutdown can hang indefinitely if tasks don't cooperate. Set a timeout after which the application force-exits to ensure termination.

**Incorrect (can hang forever):**

```rust
async fn shutdown(tasks: JoinSet<()>) {
    // If any task ignores cancellation, this hangs forever
    tasks.join_all().await;
}
```

**Correct (timeout then force exit):**

```rust
use tokio::time::{timeout, Duration};

async fn shutdown(mut tasks: JoinSet<()>) {
    // Cancel all tasks
    tasks.abort_all();

    // Give tasks time to clean up
    match timeout(Duration::from_secs(10), tasks.join_all()).await {
        Ok(_) => println!("Clean shutdown complete"),
        Err(_) => {
            eprintln!("Shutdown timeout, forcing exit");
            std::process::exit(1);
        }
    }
}
```

**With phased shutdown:**

```rust
async fn graceful_shutdown(shutdown_tx: broadcast::Sender<()>) {
    // Phase 1: Signal shutdown, wait for voluntary completion
    drop(shutdown_tx);
    tokio::time::sleep(Duration::from_secs(5)).await;

    // Phase 2: Cancel remaining tasks
    TASK_TRACKER.close();
    match timeout(Duration::from_secs(5), TASK_TRACKER.wait()).await {
        Ok(_) => println!("All tasks completed"),
        Err(_) => {
            eprintln!("Force exit after timeout");
            std::process::exit(1);
        }
    }
}
```

Reference: [Graceful Shutdown - Tokio](https://tokio.rs/tokio/topics/shutdown)
