---
title: Give spawned sub-tasks child tokens, not parent clones
impact: HIGH
impactDescription: prevents cancelling one child from cascading into all siblings
tags: async, cancellation, structured-concurrency, tokio-util
---

## Give spawned sub-tasks child tokens, not parent clones

`CancellationToken::clone()` and `CancellationToken::child_token()` look similar but have opposite semantics. Cloning gives you the *same* token — cancelling any clone cancels every other clone, including the parent. `child_token()` creates a derived token that inherits cancellation from its parent but can be cancelled independently. Codex uses `child_token()` religiously so a failed leg can be torn down without nuking its siblings, and a top-level cancel still cascades through the whole tree.

**Incorrect (clone cascades an unrelated failure):**

```rust
let events_cancel = cancel_token.clone();
let ops_cancel = cancel_token.clone();
tokio::spawn(async move { forward_events(rx, events_cancel).await });
tokio::spawn(async move { forward_ops(tx, ops_cancel).await });
// Cancelling events_cancel ALSO cancels ops — not what you want.
```

**Correct (child tokens scope independently):**

```rust
// core/src/codex_delegate.rs
let cancel_token_events = cancel_token.child_token();
let cancel_token_ops = cancel_token.child_token();
tokio::spawn(async move {
    forward_events(rx, cancel_token_events).await;
});
tokio::spawn(async move {
    forward_ops(tx, cancel_token_ops).await;
});

// core/src/tasks/mod.rs — body derives ITS OWN child, so outer
// code can't accidentally observe the local token
let task_cancellation_token = cancellation_token.child_token();
let handle = tokio::spawn(async move {
    task_for_run
        .run(ctx, input, task_cancellation_token.child_token())
        .await;
    if !task_cancellation_token.is_cancelled() {
        sess.on_task_finished(/* ... */).await;
    }
});
```

The local `is_cancelled()` check after `run(...)` is how Codex decides whether to emit the completion event: "finished normally" and "finished via cancellation" are both "the future returned" — the token is how you distinguish them.

Reference: `codex-rs/core/src/codex_delegate.rs:116`, `codex-rs/core/src/tasks/mod.rs:284`.
