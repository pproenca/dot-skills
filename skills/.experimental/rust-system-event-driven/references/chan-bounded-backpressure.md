---
title: Use Bounded Channels for Backpressure
impact: CRITICAL
impactDescription: prevents unbounded memory growth under load
tags: chan, bounded, backpressure, mpsc, memory
---

## Use Bounded Channels for Backpressure

Unbounded channels grow without limit when producers outpace consumers, eventually exhausting memory. Use bounded channels to apply backpressure and prevent OOM crashes.

**Incorrect (unbounded memory growth):**

```rust
let (tx, rx) = tokio::sync::mpsc::unbounded_channel();

// Producer sends faster than consumer processes
loop {
    let event = wait_for_event().await;
    tx.send(event).unwrap();  // Never blocks, memory grows forever
}
```

**Correct (bounded with backpressure):**

```rust
let (tx, rx) = tokio::sync::mpsc::channel(1000);

loop {
    let event = wait_for_event().await;
    // Blocks when buffer full, slowing producer to match consumer
    tx.send(event).await?;
}
```

**When to use unbounded channels:**
- Guaranteed bounded producers (e.g., fixed number of one-shot responses)
- Low-volume control signals where blocking would cause deadlock

Reference: [Tokio mpsc channel](https://docs.rs/tokio/latest/tokio/sync/mpsc/fn.channel.html)
