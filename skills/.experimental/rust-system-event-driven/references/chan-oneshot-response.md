---
title: Use Oneshot Channels for Request-Response
impact: CRITICAL
impactDescription: prevents double-send bugs at compile time
tags: chan, oneshot, request-response, tokio, pattern
---

## Use Oneshot Channels for Request-Response

When implementing request-response patterns, use oneshot channels for the response. They guarantee single-use semantics and are dropped after the response is sent.

**Incorrect (mpsc for single response):**

```rust
struct Request {
    data: Data,
    response_tx: mpsc::Sender<Response>,  // Wasteful, allows multiple sends
}

async fn handle_request(req: Request) {
    let result = process(req.data).await;
    let _ = req.response_tx.send(result).await;  // Ignores if channel full
}
```

**Correct (oneshot for single response):**

```rust
struct Request {
    data: Data,
    response_tx: oneshot::Sender<Response>,
}

async fn handle_request(req: Request) {
    let result = process(req.data).await;
    let _ = req.response_tx.send(result);  // Consumes sender, cannot send twice
}

async fn send_request(tx: &mpsc::Sender<Request>, data: Data) -> Result<Response, Error> {
    let (response_tx, response_rx) = oneshot::channel();
    tx.send(Request { data, response_tx }).await?;
    response_rx.await.map_err(|_| Error::Cancelled)
}
```

**Benefits:**
- Type system prevents sending multiple responses
- Automatic cleanup when sender or receiver is dropped
- Caller can detect if handler dropped without responding

Reference: [tokio::sync::oneshot](https://docs.rs/tokio/latest/tokio/sync/oneshot/)
