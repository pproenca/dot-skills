---
title: Use Biased Select for Priority Handling
impact: CRITICAL
impactDescription: prevents starvation of high-priority events
tags: async, select, tokio, priority, fairness
---

## Use Biased Select for Priority Handling

When handling multiple event sources with different priorities, use `biased` in tokio's select macro to ensure high-priority events are always checked first.

**Incorrect (random selection may starve shutdown):**

```rust
loop {
    tokio::select! {
        _ = shutdown_rx.recv() => {
            break;
        }
        msg = message_rx.recv() => {
            process_message(msg).await;
        }
        _ = tick_interval.tick() => {
            do_periodic_work().await;
        }
    }
}
```

**Correct (shutdown always checked first):**

```rust
loop {
    tokio::select! {
        biased;

        _ = shutdown_rx.recv() => {
            break;  // Always exits promptly on shutdown
        }
        msg = message_rx.recv() => {
            process_message(msg).await;
        }
        _ = tick_interval.tick() => {
            do_periodic_work().await;
        }
    }
}
```

**When NOT to use this pattern:**
- All branches have equal priority
- Fair scheduling between producers is required

Reference: [Tokio select! macro](https://docs.rs/tokio/latest/tokio/macro.select.html)
