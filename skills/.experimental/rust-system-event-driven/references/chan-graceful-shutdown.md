---
title: Use Channel Closure for Graceful Shutdown
impact: CRITICAL
impactDescription: prevents message loss on shutdown
tags: chan, shutdown, graceful, tokio, drain
---

## Use Channel Closure for Graceful Shutdown

Signal shutdown by dropping the sender, causing receivers to return `None`. This ensures all buffered messages are processed before tasks exit.

**Incorrect (abrupt shutdown loses messages):**

```rust
async fn run(shutdown: CancellationToken) {
    let (tx, mut rx) = mpsc::channel(100);

    tokio::spawn(producer(tx));

    loop {
        tokio::select! {
            _ = shutdown.cancelled() => {
                break;  // Messages in buffer are lost!
            }
            Some(msg) = rx.recv() => {
                process(msg).await;
            }
        }
    }
}
```

**Correct (drain channel before shutdown):**

```rust
async fn run(shutdown: CancellationToken) {
    let (tx, mut rx) = mpsc::channel(100);

    tokio::spawn(async move {
        producer(tx, shutdown.clone()).await;
        // tx dropped here, signaling end of stream
    });

    // Process all messages until channel closes
    while let Some(msg) = rx.recv().await {
        process(msg).await;
    }
    // All messages processed, clean shutdown
}

async fn producer(tx: mpsc::Sender<Message>, shutdown: CancellationToken) {
    loop {
        tokio::select! {
            biased;
            _ = shutdown.cancelled() => break,
            event = next_event() => {
                if tx.send(event).await.is_err() {
                    break;
                }
            }
        }
    }
    // tx dropped, receiver will get None after buffer drains
}
```

Reference: [Graceful Shutdown - Tokio](https://tokio.rs/tokio/topics/shutdown)
