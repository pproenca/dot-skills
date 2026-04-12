---
title: Use Arc AbortOnDropHandle for structured cancellation
impact: HIGH
impactDescription: prevents leaked background tasks when a session or turn is cleared
tags: async, cancellation, structured-concurrency, tokio-util
---

## Use Arc AbortOnDropHandle for structured cancellation

Raw `JoinHandle` storage forces every cleanup path to remember `handle.abort()` — and one missed error branch leaks the task. Codex wraps every `JoinHandle` in `tokio_util::task::AbortOnDropHandle`, then stores that in state structs so `Drop` aborts the task automatically. Wrapping in `Arc` lets multiple observers clone the handle while preserving single-owner abort semantics: the task aborts on the last `Arc` drop.

**Incorrect (easy to leak tasks on error paths):**

```rust
pub(crate) struct RunningTask {
    pub(crate) handle: JoinHandle<()>,
}
fn clear_turn(turn: &mut ActiveTurn) {
    for task in turn.drain_tasks() {
        task.handle.abort(); // easy to forget on error branches
    }
}
```

**Correct (Drop semantics do the work):**

```rust
// core/src/state/turn.rs
pub(crate) struct RunningTask {
    pub(crate) done: Arc<Notify>,
    pub(crate) kind: TaskKind,
    pub(crate) cancellation_token: CancellationToken,
    pub(crate) handle: Arc<AbortOnDropHandle<()>>,
}

// core/src/tasks/mod.rs — construction site
let handle = tokio::spawn(
    async move { /* task body */ }.instrument(task_span),
);
let running_task = RunningTask {
    handle: Arc::new(AbortOnDropHandle::new(handle)),
    /* ... */
};
turn.add_task(running_task);
```

`IndexMap<String, RunningTask>::clear()` now releases every `RunningTask`, which drops every `Arc<AbortOnDropHandle>`, which aborts the underlying task. You never grep for "where is the abort".

Reference: `codex-rs/core/src/state/turn.rs:69`, `codex-rs/core/src/tasks/mod.rs:294`.
