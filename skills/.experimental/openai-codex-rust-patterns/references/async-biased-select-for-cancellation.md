---
title: Use biased select when cancellation must win ties
impact: HIGH
impactDescription: prevents rare approval races where cancel and response fire in the same poll
tags: async, cancellation, select, tokio
---

## Use biased select when cancellation must win ties

`tokio::select!` picks a ready branch at random by default — deliberate to avoid starvation, but it means a cancelled token and a just-arrived response can coin-flip. One run in fifty, cancellation loses the race and an approval appears granted. Adding `biased;` evaluates branches top-down instead, so the cancellation arm always wins when both are ready. Critically, the cancel arm does not just break — it actively notifies the parent waiter with an empty response so any pending consumer unwinds instead of hanging on an orphaned approval.

**Incorrect (plain select, occasional lost cancellation):**

```rust
tokio::select! {
    _ = cancel_token.cancelled() => { /* tear down */ }
    response = fut => { return response; }
}
```

**Correct (biased + active unwind):**

```rust
// core/src/codex_delegate.rs
tokio::select! {
    biased;
    _ = cancel_token.cancelled() => {
        let empty = RequestUserInputResponse {
            answers: HashMap::new(),
        };
        parent_session
            .notify_user_input_response(sub_id, empty.clone())
            .await;
        empty
    }
    response = fut => response.unwrap_or_else(|| {
        RequestUserInputResponse { answers: HashMap::new() }
    }),
}
```

`biased;` plus an active unwind of the parent's wait queue. Cancellation does not just drop the future; it converts to a synthetic decline that every waiter can observe — which is what prevents the "ghost approval" bug.

Reference: `codex-rs/core/src/codex_delegate.rs:796`.
