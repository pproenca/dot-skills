---
title: Use JoinSet for Structured Concurrency
impact: MEDIUM-HIGH
impactDescription: automatic cleanup of spawned tasks, prevents orphaned futures
tags: asyncp, joinset, structured-concurrency, tokio, task-management
---

## Use JoinSet for Structured Concurrency

Use `tokio::task::JoinSet` to spawn and collect multiple concurrent tasks. JoinSet tracks all spawned tasks and cancels any remaining when dropped, preventing orphaned background work. This is cleaner than manually collecting `JoinHandle` vectors.

**Incorrect (manual handle collection, no automatic cleanup):**

```rust
async fn connect_all(servers: &[ServerConfig]) -> Vec<Connection> {
    let mut handles = Vec::new();
    for server in servers {
        let cfg = server.clone();
        handles.push(tokio::spawn(async move {
            connect_to_server(&cfg).await
        }));
    }
    let mut connections = Vec::new();
    for handle in handles {
        if let Ok(conn) = handle.await {
            connections.push(conn);
        }
    }
    connections
}
```

**Correct (JoinSet with automatic cleanup on drop):**

```rust
use tokio::task::JoinSet;

async fn connect_all(servers: &[ServerConfig]) -> Vec<Connection> {
    let mut join_set = JoinSet::new();
    for server in servers {
        let cfg = server.clone();
        join_set.spawn(async move { connect_to_server(&cfg).await });
    }
    let mut connections = Vec::with_capacity(servers.len());
    while let Some(result) = join_set.join_next().await {
        if let Ok(conn) = result {
            connections.push(conn);
        }
    }
    connections
}
```
