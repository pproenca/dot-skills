---
title: Use Broadcast Channels for Fan-Out
impact: CRITICAL
impactDescription: eliminates O(n) clone overhead per publish
tags: chan, broadcast, fanout, pubsub, tokio
---

## Use Broadcast Channels for Fan-Out

When multiple consumers need to receive the same events, use broadcast channels. Each receiver gets its own copy of every message sent after subscription.

**Incorrect (manual fanout with multiple mpsc):**

```rust
struct EventBus {
    subscribers: Vec<mpsc::Sender<Event>>,
}

impl EventBus {
    async fn publish(&self, event: Event) {
        for tx in &self.subscribers {
            let _ = tx.send(event.clone()).await;  // Must clone for each
        }
    }
}
```

**Correct (broadcast channel):**

```rust
struct EventBus {
    sender: broadcast::Sender<Event>,
}

impl EventBus {
    fn new(capacity: usize) -> Self {
        let (sender, _) = broadcast::channel(capacity);
        Self { sender }
    }

    fn subscribe(&self) -> broadcast::Receiver<Event> {
        self.sender.subscribe()
    }

    fn publish(&self, event: Event) {
        let _ = self.sender.send(event);  // All subscribers receive
    }
}
```

**Handling lagged receivers:**

```rust
loop {
    match rx.recv().await {
        Ok(event) => process(event),
        Err(broadcast::error::RecvError::Lagged(n)) => {
            tracing::warn!("dropped {n} events");
        }
        Err(broadcast::error::RecvError::Closed) => break,
    }
}
```

Reference: [tokio::sync::broadcast](https://docs.rs/tokio/latest/tokio/sync/broadcast/)
