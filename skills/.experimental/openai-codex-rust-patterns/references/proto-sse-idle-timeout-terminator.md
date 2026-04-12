---
title: Treat SSE streams as idle-timeout with a required terminator
impact: HIGH
impactDescription: prevents long turns from being killed by wall-clock deadlines and silent half-closes
tags: proto, streaming, sse, timeouts
---

## Treat SSE streams as idle-timeout with a required terminator

A `while let Some(event) = stream.next().await` loop with a wall-clock deadline either kills legitimate long turns or never fires at all. Codex's `process_sse` loop re-arms the timeout on every `stream.next()` call — activity resets it, so long-running turns never hit a total deadline. And a clean `Ok(None)` return (stream closed) is treated as an *error* unless a `response.completed` event was observed: `"stream closed before response.completed"`.

**Incorrect (wall-clock deadline kills legit turns):**

```rust
let deadline = Instant::now() + Duration::from_secs(60);
while Instant::now() < deadline {
    match stream.next().await {
        Some(Ok(event)) => process(event),
        Some(Err(_)) | None => break,
    }
}
// A 90-second turn dies at 60s; a half-closed stream silently succeeds.
```

**Correct (per-poll idle timeout, terminator required):**

```rust
// codex-api/src/sse/responses.rs
loop {
    let response = timeout(idle_timeout, stream.next()).await;
    let sse = match response {
        Ok(Some(Ok(sse))) => sse,
        Ok(Some(Err(transport_err))) => {
            let _ = tx_event.send(Err(transport_err.into())).await;
            return;
        }
        Ok(None) => {
            let error = response_error.unwrap_or(ApiError::Stream(
                "stream closed before response.completed".into(),
            ));
            let _ = tx_event.send(Err(error)).await;
            return;
        }
        Err(_) => {
            let _ = tx_event
                .send(Err(ApiError::Stream(
                    "idle timeout waiting for SSE".into(),
                )))
                .await;
            return;
        }
    };
    /* dispatch sse event */
}
```

The missing-terminator error maps to `CodexErr::Stream`, which `is_retryable()` reports as `true` — so the session loop auto-retries half-closes instead of surfacing a mystery. The stream is bridged to the consumer via a bounded `mpsc::channel(1600)` rather than exposed as a raw `futures::Stream`, giving proper backpressure and an explicit close signal.

Reference: `codex-rs/codex-api/src/sse/responses.rs:367`, `codex-rs/protocol/src/error.rs:71`.
