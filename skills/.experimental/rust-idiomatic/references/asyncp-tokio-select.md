---
title: Use tokio select for Concurrent Branch Waiting
impact: MEDIUM-HIGH
impactDescription: enables responsive cancellation and timeout handling
tags: asyncp, select, tokio, concurrency, cancellation
---

## Use tokio select for Concurrent Branch Waiting

Use `tokio::select!` to race multiple async operations and respond to the first one that completes. This is the standard pattern for combining cancellation tokens, timeouts, and work futures in a single loop.

**Incorrect (sequential checks miss cancellation during work):**

```rust
async fn run_worker(token: CancellationToken) {
    loop {
        if token.is_cancelled() {
            break;
        }
        self.process_batch().await;
        tokio::time::sleep(Duration::from_secs(1)).await;
    }
}
```

**Correct (select! responds to cancellation immediately):**

```rust
async fn run_worker(token: CancellationToken) {
    loop {
        tokio::select! {
            _ = token.cancelled() => break,
            _ = self.process_batch() => {
                tokio::time::sleep(Duration::from_secs(1)).await;
            }
        }
    }
}
```
