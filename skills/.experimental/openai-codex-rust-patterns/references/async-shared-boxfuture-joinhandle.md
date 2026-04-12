---
title: Wrap background JoinHandle in Shared BoxFuture for multi-waiter joins
impact: MEDIUM-HIGH
impactDescription: enables multiple independent callers to await the same background task completion
tags: async, shutdown, futures, join-handle
---

## Wrap background JoinHandle in Shared BoxFuture for multi-waiter joins

A `JoinHandle` can only be awaited once — it takes `self`. When several call sites need to know "has this background task finished?" (shutdown, parent supervisor, tests), you either hand out the handle and pray, or wrap it in `Arc<Mutex<Option<JoinHandle>>>` and the "first waiter" semantics break the second. Codex uses `futures::future::Shared<BoxFuture<'static, ()>>`: the combinator turns any future into one that can be cloned and polled from multiple places, with every clone resolving to the same result when the inner future completes.

**Incorrect (single handle, second waiter panics):**

```rust
pub struct SessionHandle {
    pub join: JoinHandle<()>, // owned; only one caller can await
}
// Caller 1: await session.join — consumed.
// Caller 2: cannot even observe completion.
```

**Correct (Shared lets every caller await the same future):**

```rust
// core/src/codex.rs
pub(crate) type SessionLoopTermination = Shared<BoxFuture<'static, ()>>;

pub(crate) fn session_loop_termination_from_handle(
    handle: JoinHandle<()>,
) -> SessionLoopTermination {
    async move {
        let _ = handle.await;
    }
    .boxed()
    .shared()
}

// Codex struct holds one of these; any number of callers can clone + await.
```

The closure swallows `handle.await`'s `Result` (panic detail is dropped on purpose — callers only care *when* it ends). `Shared` requires the output to be `Clone`, which `()` trivially is — that is why the function returns `()` instead of propagating the result.

Reference: `codex-rs/core/src/codex.rs:408`.
