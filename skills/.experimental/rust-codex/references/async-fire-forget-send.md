---
title: Use let _ = tx.send() for Fire-and-Forget Channels
impact: MEDIUM-HIGH
impactDescription: prevents panic during shutdown when receivers are dropped
tags: async, fire-and-forget, channels, send
---

## Use let _ = tx.send() for Fire-and-Forget Channels

When sending a notification through a channel where the result does not affect control flow, use `let _ = tx.send(value)` to discard the error. This pattern appears throughout the codebase for SSE stream forwarding, transport events, and shutdown signals where the sender should not panic or propagate an error if the receiver has been dropped.

**Incorrect (propagates error when receiver drops during normal operation):**

```rust
async fn forward_sse_events(
    tx: mpsc::Sender<StreamEvent>,
    mut stream: EventStream,
) {
    while let Some(event) = stream.next().await {
        match event {
            Ok(data) => tx.send(Ok(data)).await?,
            Err(e) => tx.send(Err(StreamError::Stream(e.to_string()))).await?,
        }
    }
}
```

**Correct (silently drops if receiver is gone):**

```rust
async fn forward_sse_events(
    tx: mpsc::Sender<StreamEvent>,
    mut stream: EventStream,
) {
    while let Some(event) = stream.next().await {
        match event {
            Ok(data) => { let _ = tx.send(Ok(data)).await; }
            Err(e) => {
                let _ = tx.send(Err(StreamError::Stream(e.to_string()))).await;
            }
        }
    }
}
```
