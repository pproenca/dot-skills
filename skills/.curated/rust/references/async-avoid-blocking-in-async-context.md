---
title: Avoid Blocking in Async Context
impact: MEDIUM-HIGH
impactDescription: prevents executor starvation
tags: async, blocking, spawn_blocking, tokio, executor
---

## Avoid Blocking in Async Context

Blocking calls in async functions prevent the executor from running other tasks. Use `spawn_blocking` for CPU-heavy or blocking I/O operations.

**Incorrect (blocks the async executor):**

```rust
async fn process_file(path: &str) -> Result<Data, Error> {
    let content = std::fs::read_to_string(path)?;  // Blocks executor
    let data = parse_heavy(&content);  // CPU-intensive, blocks executor
    Ok(data)
}
```

**Correct (offloads blocking work):**

```rust
use tokio::task::spawn_blocking;

async fn process_file(path: &str) -> Result<Data, Error> {
    let path = path.to_string();
    let data = spawn_blocking(move || {
        let content = std::fs::read_to_string(&path)?;
        parse_heavy(&content)
    })
    .await??;
    Ok(data)
}
```

**Alternative (use async I/O):**

```rust
use tokio::fs;
use tokio::task::spawn_blocking;

async fn process_file(path: &str) -> Result<Data, Error> {
    let content = fs::read_to_string(path).await?;  // Non-blocking
    let data = spawn_blocking(move || parse_heavy(content)).await?;  // Moves owned String
    Ok(data)
}
```

**Rules of thumb:**
- Operations > 10-100μs are considered blocking
- File I/O, DNS, heavy computation need offloading
- Database clients usually handle this internally

Reference: [Tokio - Async in Depth](https://tokio.rs/tokio/tutorial/async)
