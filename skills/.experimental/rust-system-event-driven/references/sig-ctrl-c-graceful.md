---
title: Handle Ctrl-C for Graceful Shutdown
impact: MEDIUM
impactDescription: enables clean resource cleanup on interrupt
tags: sig, ctrl-c, shutdown, graceful, tokio
---

## Handle Ctrl-C for Graceful Shutdown

Catch SIGINT (Ctrl-C) to perform graceful shutdown instead of immediate termination. This ensures resources are cleaned up, connections are closed, and data is persisted.

**Incorrect (abrupt termination):**

```rust
#[tokio::main]
async fn main() {
    let server = Server::bind(&addr).serve(app);
    server.await.unwrap();
    // Ctrl-C kills immediately, connections dropped mid-request
}
```

**Correct (graceful shutdown on Ctrl-C):**

```rust
use tokio::signal;

#[tokio::main]
async fn main() {
    let server = Server::bind(&addr).serve(app);

    let graceful = server.with_graceful_shutdown(async {
        signal::ctrl_c().await.expect("failed to listen for ctrl-c");
        println!("Shutting down gracefully...");
    });

    graceful.await.unwrap();
    // Server waits for in-flight requests to complete
}
```

**With custom shutdown coordination:**

```rust
use tokio::sync::broadcast;

#[tokio::main]
async fn main() {
    let (shutdown_tx, _) = broadcast::channel(1);

    let server_shutdown = shutdown_tx.subscribe();
    let worker_shutdown = shutdown_tx.subscribe();

    tokio::spawn(run_server(server_shutdown));
    tokio::spawn(run_worker(worker_shutdown));

    signal::ctrl_c().await.expect("failed to listen for ctrl-c");
    drop(shutdown_tx);  // All receivers notified

    // Wait for tasks to finish gracefully
}
```

Reference: [tokio::signal::ctrl_c](https://docs.rs/tokio/latest/tokio/signal/fn.ctrl_c.html)
