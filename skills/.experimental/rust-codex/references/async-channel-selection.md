---
title: Use Appropriate Channel Types for Communication
impact: MEDIUM-HIGH
impactDescription: prevents deadlocks and memory leaks from wrong channel type
tags: async, channels, mpsc, oneshot, tokio
---

## Use Appropriate Channel Types for Communication

Select the right tokio channel type for each communication pattern. Using the wrong type causes subtle bugs: an unbounded mpsc can leak memory under backpressure, a bounded mpsc can deadlock if the receiver stalls, and an mpsc used for a single reply wastes resources compared to a oneshot.

**Incorrect (mpsc channel for a single response):**

```rust
async fn request_approval(question: String) -> Result<bool> {
    let (tx, mut rx) = mpsc::channel(1);
    approval_handler.send(ApprovalRequest { question, reply: tx }).await?;
    // mpsc overhead for a single message
    rx.recv().await.context("approval channel closed")
}
```

**Correct (oneshot for single response, mpsc for streams):**

```rust
// Single response: use oneshot
async fn request_approval(question: String) -> Result<bool> {
    let (tx, rx) = oneshot::channel();
    approval_handler.send(ApprovalRequest { question, reply: tx }).await?;
    rx.await.context("approval channel closed")
}

// Continuous event stream: use bounded mpsc
async fn subscribe_events() -> mpsc::Receiver<Event> {
    let (tx, rx) = mpsc::channel(64);
    tokio::spawn(async move {
        loop {
            let event = poll_next_event().await;
            if tx.send(event).await.is_err() {
                break; // receiver dropped
            }
        }
    });
    rx
}
```
