---
title: Use JoinSet for Structured Concurrency
impact: CRITICAL
impactDescription: prevents orphaned tasks and resource leaks
tags: async, joinset, structured, concurrency, tokio
---

## Use JoinSet for Structured Concurrency

Spawned tasks can outlive their parent scope, causing resource leaks and making shutdown unpredictable. Use `JoinSet` to ensure all spawned tasks complete or are cancelled together.

**Incorrect (orphaned tasks on early return):**

```rust
async fn process_batch(items: Vec<Item>) -> Result<(), Error> {
    for item in items {
        tokio::spawn(async move {
            process_item(item).await;  // Orphaned if function returns early
        });
    }

    if should_abort() {
        return Err(Error::Aborted);  // Spawned tasks continue running!
    }

    Ok(())
}
```

**Correct (all tasks managed together):**

```rust
async fn process_batch(items: Vec<Item>) -> Result<(), Error> {
    let mut set = tokio::task::JoinSet::new();

    for item in items {
        set.spawn(async move {
            process_item(item).await
        });
    }

    if should_abort() {
        set.abort_all();  // Cancels all spawned tasks
        return Err(Error::Aborted);
    }

    while let Some(result) = set.join_next().await {
        result??;
    }

    Ok(())
}
```

**Benefits:**
- Tasks are cancelled when JoinSet is dropped
- Results can be collected as they complete
- Easier to implement graceful shutdown

Reference: [tokio::task::JoinSet](https://docs.rs/tokio/latest/tokio/task/struct.JoinSet.html)
